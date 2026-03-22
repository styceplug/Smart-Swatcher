import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/data/repo/folder_repo.dart';
import 'package:smart_swatcher/helpers/global_loader_controller.dart';

import '../models/folder_model.dart';
import '../models/formulation_model.dart';
import '../routes/routes.dart';
import '../widgets/snackbars.dart';

class ClientFolderController extends GetxController {
  final FolderRepo repo = Get.find<FolderRepo>();

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  var foldersList = <ClientFolderModel>[].obs;
  var currentFolder = Rxn<ClientFolderModel>();
  var isLoading = false.obs;
  var isFetching = false.obs;
  var formulationsList = <FormulationModel>[].obs;
  var recentFormulations = <FormulationModel>[].obs;
  var allFormulations = <FormulationModel>[].obs;
  var isFetchingRecentFormulations = false.obs;
  var isFetchingAllFormulations = false.obs;
  final RxSet<String> refreshingPredictionIds = <String>{}.obs;
  var clientImage = Rxn<File>();
  Map<String, dynamic>? suggestedMetrics;

  @override
  void onInit() {
    super.onInit();
    getFolders();
  }

  void _replaceInList(
    RxList<FormulationModel> list,
    FormulationModel formulation,
  ) {
    final index = list.indexWhere((item) => item.id == formulation.id);
    if (index == -1) {
      list.insert(0, formulation);
    } else {
      list[index] = formulation;
    }
    list.refresh();
  }

  void _upsertFormulation(FormulationModel formulation) {
    _replaceInList(formulationsList, formulation);
    _replaceInList(recentFormulations, formulation);
  }

  Future<FormulationModel?> _fetchFormulationById(
    String formulationId, {
    bool refreshPrediction = false,
  }) async {
    if (formulationId.trim().isEmpty) {
      return null;
    }

    final response = await repo.getFormulation(
      formulationId,
      refreshPrediction: refreshPrediction,
    );

    if (response.statusCode != 200 || response.body is! Map) {
      return null;
    }

    final payload = response.body['formulation'];
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final formulation = FormulationModel.fromJson(payload);
    print(
      '[FORMULATION_CTRL] prediction.state '
      '{formulationId: ${formulation.id}, '
      'status: ${formulation.predictionImageStatus}, '
      'error: ${formulation.predictionImageError}}',
    );
    _upsertFormulation(formulation);
    return formulation;
  }

  Future<void> trackPredictionJob(
    String formulationId, {
    bool notifyOnFailure = false,
  }) async {
    if (formulationId.trim().isEmpty ||
        refreshingPredictionIds.contains(formulationId)) {
      return;
    }

    refreshingPredictionIds.add(formulationId);

    try {
      for (int attempt = 0; attempt < 12; attempt++) {
        final formulation = await _fetchFormulationById(
          formulationId,
          refreshPrediction: true,
        );

        if (formulation == null) {
          break;
        }

        if (!formulation.isPredictionActive) {
          if (notifyOnFailure &&
              formulation.predictionImageStatus == 'failed' &&
              (formulation.predictionImageError?.trim().isNotEmpty ?? false)) {
            CustomSnackBar.failure(
              message: formulation.predictionImageError!,
            );
          }
          break;
        }

        await Future.delayed(const Duration(seconds: 4));
      }
    } catch (e) {
      print('Prediction tracking error: $e');
    } finally {
      refreshingPredictionIds.remove(formulationId);
    }
  }

  Future<void> getPreview(Map<String, dynamic> requestData) async {
    isLoading.value = true;
    update();

    try {
      Response response = await repo.previewFormulation(requestData);

      if (response.statusCode == 200) {
        var bundle = {
          'inputs': requestData,
          'outputs': response.body['preview'] ?? response.body,
          // Handle nesting
        };

        Get.toNamed(AppRoutes.formulationPreview, arguments: bundle);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? "Preview failed",
        );
      }
    } catch (e) {
      print("Preview Error: $e");
      CustomSnackBar.failure(message: "An error occurred");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> saveFormulation(Map<String, dynamic> requestBody) async {
    loader.showLoader();
    update();

    try {
      Response response = await repo.saveFormulation(requestBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body is Map && response.body['debug'] != null) {
          print('[FORMULATION_CTRL] save.debug ${response.body['debug']}');
        }

        FormulationModel? savedFormulation;

        if (response.body is Map &&
            response.body['formulation'] is Map<String, dynamic>) {
          savedFormulation = FormulationModel.fromJson(
            response.body['formulation'] as Map<String, dynamic>,
          );
          _upsertFormulation(savedFormulation);
        }

        CustomSnackBar.success(message: "Formulation saved successfully!");

        Get.until((route) => Get.currentRoute == AppRoutes.folderScreen);

        if (Get.isRegistered<ClientFolderController>()) {
          String folderId = requestBody['folderId'];
          Get.find<ClientFolderController>().fetchFormulations(folderId);
          Get.find<ClientFolderController>().fetchRecentFormulations();
        }

        if (savedFormulation != null) {
          if (savedFormulation.predictionImageStatus == 'not_requested' &&
              (savedFormulation.imageUrl?.trim().isNotEmpty ?? false)) {
            print(
              '[FORMULATION_CTRL] prediction.retry.auto '
              '{formulationId: ${savedFormulation.id}}',
            );
            final retryResponse = await repo.retryPredictionImage(
              savedFormulation.id,
            );

            if (retryResponse.body is Map && retryResponse.body['debug'] != null) {
              print(
                '[FORMULATION_CTRL] retry.debug '
                '${retryResponse.body['debug']}',
              );
            }

            if ((retryResponse.statusCode == 200 ||
                    retryResponse.statusCode == 202) &&
                retryResponse.body is Map &&
                retryResponse.body['formulation'] is Map<String, dynamic>) {
              savedFormulation = FormulationModel.fromJson(
                retryResponse.body['formulation'] as Map<String, dynamic>,
              );
              _upsertFormulation(savedFormulation);
            }
          }

          if (savedFormulation.isPredictionActive) {
            unawaited(
              trackPredictionJob(
                savedFormulation.id,
                notifyOnFailure: true,
              ),
            );
          } else if (savedFormulation.predictionImageStatus == 'failed' &&
              (savedFormulation.predictionImageError?.trim().isNotEmpty ??
                  false)) {
            CustomSnackBar.failure(
              message: savedFormulation.predictionImageError!,
            );
          }
        }
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? "Failed to save formulation",
        );
        print("Failed to save formulation: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Save Error: $e");
      CustomSnackBar.failure(message: "An error occurred while saving");
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      clientImage.value = File(pickedFile.path);
    }
  }

  Future<void> uploadAndNext() async {
    if (clientImage.value == null) return;

    loader.showLoader();
    update();

    try {
      Response response = await repo.uploadClientImage(clientImage.value!);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        Map<String, dynamic> results; // Use a temp variable

        if (data is String) {
          results = jsonDecode(data);
        } else {
          results = data;
        }

        // --- THE FIX STARTS HERE ---

        // 1. Retrieve the folderId passed from the previous screen
        // (We check Get.arguments safety)
        String? passedFolderId;
        if (Get.arguments != null && Get.arguments is Map) {
          passedFolderId = Get.arguments['folderId'];
        }

        // 2. Merge it into the next arguments
        Map<String, dynamic> nextArgs = {
          ...results, // The API results
          'folderId': passedFolderId // Pass the baton!
        };

        // 3. Send the merged arguments
        Get.toNamed(AppRoutes.chooseNbl, arguments: nextArgs);

        // --- THE FIX ENDS HERE ---

      } else {
        var errorBody = response.body is String ? jsonDecode(response.body) : response.body;
        CustomSnackBar.failure(message: errorBody['message'] ?? "Upload failed");
      }
    } catch (e) {
      print("Upload Error: $e");
      CustomSnackBar.failure(message: "An error occurred during upload");
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> fetchFormulations(String folderId) async {
    if (folderId.trim().isEmpty) {
      formulationsList.clear();
      return;
    }

    loader.showLoader();
    try {
      Response response = await repo.getFormulations(folderId);
      if (response.statusCode == 200) {
        var data = response.body['formulations'] ?? response.body;
        if (data is List) {
          final formulations =
              data.map((e) => FormulationModel.fromJson(e)).toList();
          formulationsList.assignAll(formulations);
          await _refreshPredictionStates(formulations);
        }
      }
    } catch (e) {
      print("Error fetching formulations: $e");
    } finally {
      loader.hideLoader();
    }
  }

  Future<void> _refreshPredictionStates(
    List<FormulationModel> formulations,
  ) async {
    for (final formulation in formulations) {
      if (formulation.isPredictionActive) {
        unawaited(trackPredictionJob(formulation.id));
      }
    }
  }

  Future<void> fetchRecentFormulations({int limit = 5}) async {
    if (isFetchingRecentFormulations.value) {
      return;
    }

    isFetchingRecentFormulations.value = true;

    try {
      if (foldersList.isEmpty) {
        recentFormulations.clear();
        return;
      }

      final responses = await Future.wait(
        foldersList
            .where((folder) => folder.id != null && folder.id!.trim().isNotEmpty)
            .map((folder) => repo.getFormulations(folder.id!)),
      );

      final aggregated = <FormulationModel>[];

      for (final response in responses) {
        if (response.statusCode != 200) {
          continue;
        }

        final data = response.body['formulations'] ?? response.body;
        if (data is List) {
          aggregated.addAll(
            data.map((item) => FormulationModel.fromJson(item)).toList(),
          );
        }
      }

      aggregated.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      recentFormulations.assignAll(aggregated.take(limit).toList());
      await _refreshPredictionStates(recentFormulations);
    } catch (e) {
      print("Recent formulations error: $e");
    } finally {
      isFetchingRecentFormulations.value = false;
    }
  }

  Future<void> fetchAllFormulations() async {
    if (isFetchingAllFormulations.value) {
      return;
    }

    isFetchingAllFormulations.value = true;

    try {
      if (foldersList.isEmpty) {
        allFormulations.clear();
        return;
      }

      final responses = await Future.wait(
        foldersList
            .where((folder) => folder.id != null && folder.id!.trim().isNotEmpty)
            .map((folder) => repo.getFormulations(folder.id!)),
      );

      final aggregated = <FormulationModel>[];

      for (final response in responses) {
        if (response.statusCode != 200) {
          continue;
        }

        final data = response.body['formulations'] ?? response.body;
        if (data is List) {
          aggregated.addAll(
            data.map((item) => FormulationModel.fromJson(item)).toList(),
          );
        }
      }

      aggregated.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      allFormulations.assignAll(aggregated);
      await _refreshPredictionStates(allFormulations);
    } catch (e) {
      print("All formulations error: $e");
    } finally {
      isFetchingAllFormulations.value = false;
    }
  }

  Future<void> getFolders() async {
    isFetching.value = true;
    try {
      Response response = await repo.getFolders();

      if (response.statusCode == 200) {
        List<dynamic> data = response.body['folders'] ?? response.body;

        foldersList.assignAll(
          data.map((e) => ClientFolderModel.fromJson(e)).toList(),
        );
        await fetchRecentFormulations();
        await fetchAllFormulations();
      } else {
        print("Failed to fetch folders: ${response.statusCode}");
      }
    } catch (e) {
      print("Get Folders Error: $e");
    } finally {
      isFetching.value = false;
    }
  }


  Future<bool> createClientFolder({
    required String name,
    required String email,
    required String phone,
    String? dob,
    String? appointmentDate,
    bool shouldSendConsent = false,
  }) async {
    if (name.isEmpty) {
      CustomSnackBar.failure(message: "Client name is required");
      return false;
    }

    isLoading.value = true;
    update();

    ClientFolderModel newFolder = ClientFolderModel(
      clientName: name,
      clientEmail: email,
      clientPhone: phone,
      dateOfBirth: dob,
      appointmentDate: appointmentDate,
      shouldSendConsent: shouldSendConsent,
    );

    try {
      Response response = await repo.createFolder(newFolder);

      if (response.statusCode == 201) {
        CustomSnackBar.success(message: "Folder created successfully!");
        await getFolders();
        return true;
      } else {
        String msg = response.body['message'] ?? response.statusText;
        CustomSnackBar.failure(message: msg);
        return false;
      }
    } catch (e) {
      CustomSnackBar.failure(message: "An error occurred");
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
