import 'package:get/get.dart';

import '../../models/user_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class UserRepo {
  final ApiClient apiClient;

  UserRepo({required this.apiClient});







  Future<OtherProfileModel?> getProfile(String id) async {
    final response = await apiClient.getData(AppConstants.GET_PUBLIC_PROFILE(id));

    if (response.statusCode == 200) {
      return OtherProfileModel.fromJson(response.body['profile']);
    }

    return null;
  }


  Future<Response> getRecommendedProfiles({
    int limit = 20,
    String? type,
  }) async {
    String uri = '${AppConstants.GET_RECOMMENDED_PROFILE}?limit=$limit';

    if (type != null && type.trim().isNotEmpty) {
      uri += '&type=$type';
    }

    return await apiClient.getData(uri);
  }

  Future<Response> requestConnection(String targetId) async {
    return await apiClient.postData(AppConstants.REQUEST_CONNECTION, {
      "targetId": targetId,
    });
  }

  Future<Response> acceptConnection(String connectionId) async {
    return await apiClient.postData(
      AppConstants.ACCEPT_CONNECTION(connectionId),
      {},
    );
  }

  Future<Response> declineConnection(String connectionId) async {
    return await apiClient.postData(
      AppConstants.DECLINE_CONNECTION(connectionId),
      {},
    );
  }

  Future<Response> deleteConnection(String connectionId) async {
    return await apiClient.deleteData(
      AppConstants.DELETE_CONNECTION(connectionId),
    );
  }

  Future<Response> blockUser(String targetId) async {
    return await apiClient.postData(
      AppConstants.BLOCKS_URI,
      <String, dynamic>{'targetId': targetId},
    );
  }

  Future<int> getAcceptedConnectionsCount() async {
    final response = await apiClient.getData(
      '${AppConstants.GET_CONNECTIONS}?status=accepted',
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    if (response.body is Map && response.body['count'] != null) {
      return int.tryParse(response.body['count'].toString()) ?? 0;
    }

    return 0;
  }
}
