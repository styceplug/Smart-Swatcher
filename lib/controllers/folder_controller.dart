import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
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
  var isFetchingFolderFormulations = false.obs;
  final RxSet<String> refreshingPredictionIds = <String>{}.obs;
  var clientImage = Rxn<File>();
  Map<String, dynamic>? suggestedMetrics;
  final Rxn<Map<String, dynamic>> formulationConfig =
      Rxn<Map<String, dynamic>>();
  final isLoadingFormulationConfig = false.obs;

  void resetFormulationDraft() {
    clientImage.value = null;
    suggestedMetrics = null;
  }

  @override
  void onInit() {
    super.onInit();
    if (_hasSessionContext) {
      refreshAfterAuthChange();
    }
  }

  bool get _hasSessionContext {
    final authController = Get.find<AuthController>();
    return authController.stylistProfile.value != null ||
        authController.companyProfile.value != null;
  }

  Future<void> refreshAfterAuthChange() async {
    if (isFetching.value) {
      return;
    }

    await getFolders();
  }

  Future<Map<String, dynamic>?> loadFormulationConfig({
    bool force = false,
  }) async {
    if (!force && formulationConfig.value != null) {
      return formulationConfig.value;
    }

    if (isLoadingFormulationConfig.value) {
      return formulationConfig.value;
    }

    isLoadingFormulationConfig.value = true;
    try {
      final response = await repo.getFormulationConfig();
      if (response.statusCode == 200) {
        final body = _parseMapBody(response.body);
        final config = _parseMapBody(body?['config']);
        if (config != null) {
          formulationConfig.value = config;
          return config;
        }
      }
      return formulationConfig.value;
    } catch (error) {
      print('Formulation config error: $error');
      return formulationConfig.value;
    } finally {
      isLoadingFormulationConfig.value = false;
      update();
    }
  }

  List<Map<String, dynamic>> get baseLevelOptions {
    final items = formulationConfig.value?['baseLevels'];
    if (items is! List) {
      return const [];
    }
    return items
        .map((item) => _parseMapBody(item))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<int> get greyPercentageOptions {
    final items = formulationConfig.value?['greyPercentageOptions'];
    if (items is! List) {
      return const [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
    }
    return items
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .toList();
  }

  List<Map<String, dynamic>> get toneFamilyOptions {
    final items = formulationConfig.value?['toneFamilies'];
    if (items is! List) {
      return const [
        {'id': 'natural', 'label': 'Natural'},
        {'id': 'warm', 'label': 'Warm'},
        {'id': 'cool', 'label': 'Cool'},
      ];
    }
    return items
        .map((item) => _parseMapBody(item))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> toneOptionsForLevel(int level, {String? family}) {
    final tonesByLevel = formulationConfig.value?['tonesByLevel'];
    if (tonesByLevel is! List) {
      return const [];
    }

    final entries =
        tonesByLevel
            .map((item) => _parseMapBody(item))
            .whereType<Map<String, dynamic>>()
            .toList();
    final entry = _firstWhereOrNull<Map<String, dynamic>>(
      entries,
      (item) => int.tryParse(item['level']?.toString() ?? '') == level,
    );
    final tones = entry?['tones'];
    if (tones is! List) {
      return const [];
    }

    return tones
        .map((item) => _parseMapBody(item))
        .whereType<Map<String, dynamic>>()
        .where((item) {
          if (family == null || family.trim().isEmpty) return true;
          return item['family']?.toString().trim().toLowerCase() ==
              family.trim().toLowerCase();
        })
        .toList();
  }

  FormulationToneProfile buildToneProfile({
    required String family,
    required List<String> toneIds,
    required int? level,
  }) {
    final normalizedFamily =
        family.trim().isEmpty ? 'natural' : family.trim().toLowerCase();
    final selected = <Map<String, dynamic>>[];
    final available =
        level == null ? <Map<String, dynamic>>[] : toneOptionsForLevel(level);
    for (final toneId in toneIds.take(3)) {
      final match = _firstWhereOrNull<Map<String, dynamic>>(
        available,
        (item) => item['id']?.toString() == toneId,
      );
      if (match != null) {
        selected.add(match);
      }
    }

    final toneLabels =
        selected
            .map((item) => item['label']?.toString().trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toList();
    final toneCodes =
        selected
            .map((item) => item['code']?.toString().trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toList();

    return FormulationToneProfile(
      family: normalizedFamily,
      tones: toneIds.take(3).toList(),
      toneCodes: toneCodes,
      toneLabels: toneLabels,
      display:
          toneLabels.isEmpty
              ? _titleCase(normalizedFamily)
              : '${_titleCase(normalizedFamily)}: ${toneLabels.join(', ')}',
      familyLabel: _titleCase(normalizedFamily),
    );
  }

  String composeLegacyTone(FormulationToneProfile? profile) {
    if (profile == null) {
      return '';
    }
    return profile.effectiveDisplay;
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
    _replaceInList(allFormulations, formulation);
  }

  String _responseMessage(Response response, String fallback) {
    if (response.body is Map) {
      return response.body['message']?.toString() ??
          response.body['error']?.toString() ??
          response.statusText ??
          fallback;
    }

    return response.statusText ?? fallback;
  }

  Map<String, dynamic> _buildPreviewBundle(
    Map<String, dynamic> requestData,
    Response response, {
    required String formulationType,
  }) {
    return {
      'inputs': {...requestData, 'formulationType': formulationType},
      'outputs': response.body['preview'] ?? response.body,
    };
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
      'error: ${formulation.predictionImageError}, '
      'retryNextAt: ${formulation.predictionRetryNextAt}}',
    );
    _upsertFormulation(formulation);
    return formulation;
  }

  Future<FormulationModel?> fetchFormulationById(
    String formulationId, {
    bool refreshPrediction = false,
  }) async {
    return _fetchFormulationById(
      formulationId,
      refreshPrediction: refreshPrediction,
    );
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
      for (int attempt = 0; attempt < 90; attempt++) {
        final formulation = await _fetchFormulationById(
          formulationId,
          refreshPrediction: true,
        );

        if (formulation == null) {
          break;
        }

        if (formulation.isPredictionDelayed) {
          final retryAt = formulation.predictionRetryNextDate;
          final waitSeconds =
              retryAt == null
                  ? 10
                  : retryAt
                      .difference(DateTime.now())
                      .inSeconds
                      .clamp(4, 60);
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (!formulation.isPredictionActive) {
          if (notifyOnFailure &&
              formulation.predictionImageStatus == 'failed' &&
              (formulation.predictionImageError?.trim().isNotEmpty ?? false)) {
            CustomSnackBar.failure(message: formulation.predictionImageError!);
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
        Get.toNamed(
          AppRoutes.formulationPreview,
          arguments: _buildPreviewBundle(
            requestData,
            response,
            formulationType:
                requestData['formulationType']?.toString() ??
                'color_formulation',
          ),
        );
      } else {
        CustomSnackBar.failure(
          message: _responseMessage(response, 'Preview failed'),
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

  Future<void> getCorrectionPreview(Map<String, dynamic> requestData) async {
    isLoading.value = true;
    update();

    try {
      Response response = await repo.previewCorrection(requestData);

      if (response.statusCode == 200) {
        Get.toNamed(
          AppRoutes.formulationPreview,
          arguments: _buildPreviewBundle(
            requestData,
            response,
            formulationType: 'color_correction',
          ),
        );
      } else {
        CustomSnackBar.failure(
          message: _responseMessage(response, 'Preview failed'),
        );
      }
    } catch (e) {
      print("Correction Preview Error: $e");
      CustomSnackBar.failure(message: "An error occurred");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _saveWizardResult({
    required Map<String, dynamic> requestBody,
    required Future<Response> Function(Map<String, dynamic> body) saver,
    required String successMessage,
  }) async {
    loader.showLoader();
    update();

    try {
      Response response = await saver(requestBody);

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

        CustomSnackBar.success(message: successMessage);

        Get.until((route) => route.settings.name == AppRoutes.folderScreen);

        if (Get.isRegistered<ClientFolderController>()) {
          final folderId = requestBody['folderId']?.toString() ?? '';
          if (folderId.isNotEmpty) {
            await Get.find<ClientFolderController>().fetchFormulations(
              folderId,
            );
          }
          await Get.find<ClientFolderController>().fetchRecentFormulations();
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

            if (retryResponse.body is Map &&
                retryResponse.body['debug'] != null) {
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
              trackPredictionJob(savedFormulation.id, notifyOnFailure: true),
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
          message: _responseMessage(response, 'Failed to save item'),
        );
        print(
          "Failed to save formulation: ${response.statusCode}, ${response.body}",
        );
      }
    } catch (e) {
      print("Save Error: $e");
      CustomSnackBar.failure(message: "An error occurred while saving");
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> saveFormulation(Map<String, dynamic> requestBody) async {
    await _saveWizardResult(
      requestBody: requestBody,
      saver: repo.saveFormulation,
      successMessage: 'Formulation saved successfully!',
    );
  }

  Future<void> saveCorrection(Map<String, dynamic> requestBody) async {
    await _saveWizardResult(
      requestBody: requestBody,
      saver: repo.saveCorrection,
      successMessage: 'Correction saved successfully!',
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2200,
      maxHeight: 2200,
      requestFullMetadata: false,
    );
    if (pickedFile != null) {
      clientImage.value = await _normalizeFormulationImage(
        File(pickedFile.path),
      );
    }
  }

  Future<File> _normalizeFormulationImage(File sourceFile) async {
    try {
      final path = sourceFile.path;
      final extensionIndex = path.lastIndexOf('.');
      final basePath =
          extensionIndex == -1 ? path : path.substring(0, extensionIndex);
      final targetPath = '${basePath}_normalized.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        format: CompressFormat.jpeg,
        quality: 90,
        minWidth: 1800,
        minHeight: 1800,
        autoCorrectionAngle: true,
        keepExif: false,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      print('Formulation image normalization error: $e');
    }

    return sourceFile;
  }

  Future<void> uploadAndNext() async {
    if (clientImage.value == null) return;

    loader.showLoader();
    update();

    try {
      Response response = await repo.uploadClientImage(clientImage.value!);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadFormulationConfig();
        final results = _parseMapBody(response.body);
        if (results == null) {
          CustomSnackBar.failure(message: 'Upload failed');
          return;
        }

        // --- THE FIX STARTS HERE ---

        // 1. Retrieve the folderId passed from the previous screen
        // (We check Get.arguments safety)
        final routeArguments =
            Get.arguments is Map
                ? Map<String, dynamic>.from(Get.arguments as Map)
                : <String, dynamic>{};

        String? passedFolderId = routeArguments['folderId']?.toString();

        // 2. Merge it into the next arguments
        Map<String, dynamic> nextArgs = {
          ...routeArguments,
          ...results, // The API results
          'folderId': passedFolderId, // Pass the baton!
          'formulationType':
              routeArguments['formulationType'] ?? 'color_formulation',
        };

        // 3. Send the merged arguments
        Get.toNamed(AppRoutes.chooseNbl, arguments: nextArgs);

        // --- THE FIX ENDS HERE ---
      } else {
        CustomSnackBar.failure(message: _uploadErrorMessage(response));
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

    isFetchingFolderFormulations.value = true;
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
      isFetchingFolderFormulations.value = false;
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
            .where(
              (folder) => folder.id != null && folder.id!.trim().isNotEmpty,
            )
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
        final aDate =
            DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            DateTime.tryParse(b.createdAt ?? '') ??
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
            .where(
              (folder) => folder.id != null && folder.id!.trim().isNotEmpty,
            )
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
        final aDate =
            DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            DateTime.tryParse(b.createdAt ?? '') ??
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
    bool setReminder = false,
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
      setReminder: setReminder,
      shouldSendConsent: shouldSendConsent,
    );

    try {
      Response response = await repo.createFolder(newFolder);

      if (response.statusCode == 201 || response.statusCode == 200) {
        EmailDeliveryResultModel? appointmentEmailDelivery;
        EmailDeliveryResultModel? consentEmailDelivery;
        if (response.body is Map &&
            response.body['appointmentEmailDelivery'] is Map) {
          appointmentEmailDelivery = EmailDeliveryResultModel.fromJson(
            Map<String, dynamic>.from(
              response.body['appointmentEmailDelivery'],
            ),
          );
        }
        if (response.body is Map &&
            response.body['consentEmailDelivery'] is Map) {
          consentEmailDelivery = EmailDeliveryResultModel.fromJson(
            Map<String, dynamic>.from(response.body['consentEmailDelivery']),
          );
        }

        _showFolderCreationFeedback(
          appointmentEmailDelivery: appointmentEmailDelivery,
          consentEmailDelivery: consentEmailDelivery,
        );
        await getFolders();
        return true;
      } else {
        final String msg =
            response.body is Map
                ? response.body['message']?.toString() ??
                    response.statusText ??
                    'Failed to create folder'
                : response.statusText ?? 'Failed to create folder';
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

  void _showFolderCreationFeedback({
    EmailDeliveryResultModel? appointmentEmailDelivery,
    EmailDeliveryResultModel? consentEmailDelivery,
  }) {
    final messages = <String>[];
    final failures = <String>[];

    final appointmentFeedback = _emailDeliveryFeedback(
      delivery: appointmentEmailDelivery,
      sentMessage:
          (destination) =>
              'Appointment details sent${destination.isNotEmpty ? ' to $destination' : ''}',
      skippedPrefix: 'Appointment email',
      failedPrefix: 'Appointment email',
    );
    final consentFeedback = _emailDeliveryFeedback(
      delivery: consentEmailDelivery,
      sentMessage:
          (destination) =>
              'Consent form sent${destination.isNotEmpty ? ' to $destination' : ''}',
      skippedPrefix: 'Consent email',
      failedPrefix: 'Consent email',
    );

    if (appointmentFeedback != null) {
      if (appointmentFeedback.isFailure) {
        failures.add(appointmentFeedback.message);
      } else {
        messages.add(appointmentFeedback.message);
      }
    }

    if (consentFeedback != null) {
      if (consentFeedback.isFailure) {
        failures.add(consentFeedback.message);
      } else {
        messages.add(consentFeedback.message);
      }
    }

    if (messages.isEmpty && failures.isEmpty) {
      CustomSnackBar.success(message: 'Folder created successfully!');
      return;
    }

    if (messages.isNotEmpty) {
      CustomSnackBar.success(
        message: ['Folder created successfully!', ...messages].join('\n'),
      );
    }

    if (failures.isNotEmpty) {
      CustomSnackBar.failure(message: failures.join('\n'));
    }
  }

  _DeliveryFeedback? _emailDeliveryFeedback({
    required EmailDeliveryResultModel? delivery,
    required String Function(String destination) sentMessage,
    required String skippedPrefix,
    required String failedPrefix,
  }) {
    if (delivery == null || delivery.status == 'not_requested') {
      return null;
    }

    final destination = delivery.destination?.trim() ?? '';
    switch (delivery.status) {
      case 'sent':
        return _DeliveryFeedback(sentMessage(destination), isFailure: false);
      case 'skipped':
        return _DeliveryFeedback(
          '$skippedPrefix skipped: ${_emailSkippedMessage(delivery)}',
          isFailure: false,
        );
      case 'failed':
        final error =
            delivery.error?.trim().isNotEmpty == true
                ? delivery.error!.trim()
                : '$failedPrefix could not be sent.';
        return _DeliveryFeedback(error, isFailure: true);
      default:
        return null;
    }
  }

  String _emailSkippedMessage(EmailDeliveryResultModel delivery) {
    final reason = delivery.reason?.toLowerCase().trim() ?? '';
    if (reason.contains('email')) {
      return 'client email is missing.';
    }
    if (reason.contains('appointment') || reason.contains('date')) {
      return 'no appointment date was set.';
    }
    if (reason.contains('not requested') ||
        reason.contains('setreminder') ||
        reason.contains('reminder') ||
        reason.contains('consent')) {
      return 'it was not requested.';
    }
    if (delivery.reason?.trim().isNotEmpty == true) {
      return delivery.reason!.trim();
    }
    return 'delivery was skipped.';
  }

  Map<String, dynamic>? _parseMapBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }
    if (body is String && body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _uploadErrorMessage(Response response) {
    final errorBody = _parseMapBody(response.body);
    final backendMessage = errorBody?['message']?.toString().trim();
    final maxSizeMb = errorBody?['maxSizeMb']?.toString().trim();

    if (backendMessage != null && backendMessage.isNotEmpty) {
      if (maxSizeMb != null && maxSizeMb.isNotEmpty) {
        return '$backendMessage (max $maxSizeMb MB)';
      }
      return backendMessage;
    }

    return response.statusText ?? 'Upload failed';
  }

  Future<bool> deleteFormulation(String formulationId) async {
    if (formulationId.trim().isEmpty) {
      return false;
    }

    try {
      final response = await repo.deleteFormulation(formulationId);
      final deleted =
          response.statusCode == 200 &&
          response.body is Map &&
          response.body['deleted'] == true;
      if (deleted || response.statusCode == 204) {
        formulationsList.removeWhere((item) => item.id == formulationId);
        recentFormulations.removeWhere((item) => item.id == formulationId);
        allFormulations.removeWhere((item) => item.id == formulationId);
        formulationsList.refresh();
        recentFormulations.refresh();
        allFormulations.refresh();
        CustomSnackBar.success(message: 'Formulation deleted');
        return true;
      }

      final message =
          response.body is Map
              ? response.body['message']?.toString()
              : response.statusText;
      CustomSnackBar.failure(message: message ?? 'Formulation not found');
      return false;
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<FormulationModel?> retryPredictionImage(
    String formulationId, {
    bool notifyOnFailure = true,
  }) async {
    if (formulationId.trim().isEmpty) {
      return null;
    }

    try {
      final response = await repo.retryPredictionImage(formulationId);
      if ((response.statusCode == 200 || response.statusCode == 202) &&
          response.body is Map &&
          response.body['formulation'] is Map<String, dynamic>) {
        final formulation = FormulationModel.fromJson(
          response.body['formulation'] as Map<String, dynamic>,
        );
        _upsertFormulation(formulation);
        if (formulation.isPredictionActive) {
          unawaited(
            trackPredictionJob(
              formulation.id,
              notifyOnFailure: notifyOnFailure,
            ),
          );
        }
        return formulation;
      }

      CustomSnackBar.failure(
        message: _responseMessage(response, 'Unable to retry preview image'),
      );
      return null;
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }
}

class _DeliveryFeedback {
  const _DeliveryFeedback(this.message, {required this.isFailure});

  final String message;
  final bool isFailure;
}

String _titleCase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  return trimmed
      .split(RegExp(r'[\s_-]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}
