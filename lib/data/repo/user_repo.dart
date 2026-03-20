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
}
