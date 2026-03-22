import 'package:get/get.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class NotificationRepo {
  final ApiClient apiClient;

  NotificationRepo({required this.apiClient});

  Future<Response> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    return await apiClient.getData(
      '${AppConstants.GET_NOTIFICATIONS}?limit=$limit&unreadOnly=$unreadOnly',
    );
  }

  Future<Response> markNotificationRead(String notificationId) async {
    return await apiClient.postData(
      AppConstants.MARK_NOTIFICATION_READ(notificationId),
      {},
    );
  }
}
