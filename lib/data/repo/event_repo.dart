
import 'package:get/get.dart';
import 'package:smart_swatcher/data/api/api_client.dart';

import '../../utils/app_constants.dart';

class EventRepo {
  final ApiClient apiClient;

  EventRepo({required this.apiClient});

  Future<Response> createEvent(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.CREATE_EVENT, body);
  }
}
