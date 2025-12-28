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
  var isLoading = false.obs;
  var isFetching = false.obs;
  var formulationsList = <FormulationModel>[].obs;
  var clientImage = Rxn<File>();
  Map<String, dynamic>? suggestedMetrics;

  @override
  void onInit() {
    super.onInit();
    getFolders();
  }


  Future<void> getPreview(Map<String, dynamic> requestData) async {
    loader.showLoader();
    update();

    try {
      Response response = await repo.previewFormulation(requestData);

      if (response.statusCode == 200) {

        var resultData = response.body;

        Get.toNamed(AppRoutes.formulationPreview, arguments: resultData);
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Preview failed");
      }
    } catch (e) {
      print("Preview Error: $e");
      CustomSnackBar.failure(message: "An error occurred");
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

        if (data is String) {
          suggestedMetrics = jsonDecode(data);
        } else {
          suggestedMetrics = data;
        }

        Get.toNamed(AppRoutes.chooseNbl, arguments: suggestedMetrics);

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
    loader.showLoader;
    try {
      Response response = await repo.getFormulations(folderId);
      if (response.statusCode == 200) {
        var data = response.body['formulations'] ?? response.body;
        if (data is List) {
          formulationsList.assignAll(
              data.map((e) => FormulationModel.fromJson(e)).toList()
          );
        }
      }
    } catch (e) {
      print("Error fetching formulations: $e");
    } finally {
      loader.hideLoader();
    }
  }

  Future<void> getFolders() async {
    isFetching.value = true;
    try {
      Response response = await repo.getFolders();

      if (response.statusCode == 200) {
        List<dynamic> data = response.body['folders'] ?? response.body;

        foldersList.assignAll(
            data.map((e) => ClientFolderModel.fromJson(e)).toList()
        );
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
        getFolders();
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