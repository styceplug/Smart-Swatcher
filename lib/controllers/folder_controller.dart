import 'package:get/get.dart';
import 'package:smart_swatcher/data/repo/folder_repo.dart';

import '../models/folder_model.dart';
import '../widgets/snackbars.dart';


class ClientFolderController extends GetxController {
  final FolderRepo repo = Get.find<FolderRepo>();

  var foldersList = <ClientFolderModel>[].obs;
  var isLoading = false.obs;
  var isFetching = false.obs;

  @override
  void onInit() {
    super.onInit();
    getFolders();
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