import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repo/notification_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../models/notification_model.dart';
import '../widgets/snackbars.dart';

class NotificationController extends GetxController {
  final NotificationRepo notificationRepo;

  NotificationController({required this.notificationRepo});

  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  final RxBool isGettingNotifications = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxList<AppNotificationModel> notifications = <AppNotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({
    int limit = 50,
    bool unreadOnly = false,
    bool showLoader = false,
  }) async {
    if (showLoader) {
      loader.showLoader();
    }

    isGettingNotifications.value = true;

    try {
      final response = await notificationRepo.getNotifications(
        limit: limit,
        unreadOnly: unreadOnly,
      );

      if (response.statusCode == 200) {
        unreadCount.value = response.body['unreadCount'] ?? 0;

        final List<dynamic> data = response.body['notifications'] ?? [];
        notifications.assignAll(
          data.map((e) => AppNotificationModel.fromJson(e)).toList(),
        );
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to load notifications',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to load notifications');
      debugPrint('fetchNotifications error: $e');
    } finally {
      isGettingNotifications.value = false;
      if (showLoader) {
        loader.hideLoader();
      }
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  List<AppNotificationModel> get allNotifications => notifications;

  List<AppNotificationModel> get connectionNotifications =>
      notifications.where((e) => e.isConnectionNotification).toList();

  List<AppNotificationModel> get replyNotifications =>
      notifications.where((e) => e.isReplyNotification).toList();

  List<AppNotificationModel> get activityNotifications =>
      notifications.where((e) => e.isActivityNotification).toList();

  String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty || url == 'null' || url == 'string') {
      return '';
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final baseUrl = notificationRepo.apiClient.baseUrl;

    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }

    return '$baseUrl/$url';
  }

  String formatNotificationTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}