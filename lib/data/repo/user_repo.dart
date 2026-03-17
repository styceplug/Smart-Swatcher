import 'package:get/get.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class UserRepo {
  final ApiClient apiClient;

  UserRepo({required this.apiClient});

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

  Future<Response> requestConnection(String targetId)async {
     return await apiClient.postData(AppConstants.REQUEST_CONNECTION, {
       "targetId": targetId,
     },);
  }
}
