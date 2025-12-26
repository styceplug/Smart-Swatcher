import 'package:get/get.dart';

import '../../models/folder_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class FolderRepo {
  final ApiClient apiClient;

  FolderRepo({required this.apiClient});

  Future<Response> createFolder(ClientFolderModel folder) async {
    return await apiClient.postData(AppConstants.GET_FOLDERS, folder.toJson());
  }

  Future<Response> getFolders() async {
    return await apiClient.getData(AppConstants.GET_FOLDERS);
  }
}
