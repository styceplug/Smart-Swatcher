import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../models/folder_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class FolderRepo {
  final ApiClient apiClient;

  FolderRepo({required this.apiClient});

  Future<Response> saveFormulation(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/formulations/save', body);
  }

  Future<Response> previewFormulation(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/formulations/preview', body);
  }

  Future<Response> previewCorrection(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/corrections/preview', body);
  }

  Future<Response> saveCorrection(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/corrections/save', body);
  }

  Future<Response> uploadClientImage(File file) async {
    final uri = Uri.parse('${AppConstants.BASE_URL}/api/formulations/upload');
    var request = http.MultipartRequest('POST', uri);

    // Add file
    var multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    return await apiClient.postMultipartData(
      '/api/formulations/upload',
      request,
    );
  }

  Future<Response> createFolder(ClientFolderModel folder) async {
    return await apiClient.postData(AppConstants.GET_FOLDERS, folder.toJson());
  }

  Future<Response> getFolders() async {
    return await apiClient.getData(AppConstants.GET_FOLDERS);
  }

  Future<Response> getFormulations(String folderId) async {
    return await apiClient.getData('/api/folders/$folderId/formulations');
  }

  Future<Response> getFormulation(
    String formulationId, {
    bool refreshPrediction = false,
  }) async {
    final uri =
        Uri(
          path: '/api/formulations/$formulationId',
          queryParameters:
              refreshPrediction
                  ? <String, String>{'refreshPrediction': 'true'}
                  : null,
        ).toString();

    return await apiClient.getData(uri);
  }

  Future<Response> retryPredictionImage(String formulationId) async {
    return await apiClient.postData(
      '/api/formulations/$formulationId/prediction-image/retry',
      {},
    );
  }

  Future<Response> deleteFormulation(String formulationId) async {
    return await apiClient.deleteData('/api/formulations/$formulationId');
  }
}
