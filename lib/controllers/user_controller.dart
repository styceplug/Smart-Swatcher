import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/notification_controller.dart';
import '../data/repo/user_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../models/user_model.dart';
import '../widgets/snackbars.dart';

class UserController extends GetxController {
  final UserRepo userRepo;

  UserController({required this.userRepo});

  final RxList<RecommendedAccountModel> suggestedAccounts =
      <RecommendedAccountModel>[].obs;
  final RxString selectedTypeFilter = ''.obs;
  final RxBool isFetchingSuggestions = false.obs;
  var profile = Rxn<OtherProfileModel>();
  final RxSet<String> requestingConnectionIds = <String>{}.obs;
  final RxMap<String, String> connectionStatuses = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchSuggestions());
  }



  Future<void> fetchProfile(String id) async {
    try {
      loader.showLoader();
      final res = await userRepo.getProfile(id);

      if (res != null) {
        profile.value = res;
      }
    } catch (e) {
      print('Profile error: $e');
    } finally {
      loader.hideLoader();
    }
  }

  String resolveImage(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${userRepo.apiClient.baseUrl}$path';
  }

  Future<void> fetchSuggestions({int limit = 20, String? type}) async {
    if (isFetchingSuggestions.value) return;

    isFetchingSuggestions.value = true;

    try {
      final cleanType =
      (type == null || type.trim().isEmpty || type == 'null')
          ? null
          : type.trim();

      final response = await userRepo.getRecommendedProfiles(
        limit: limit,
        type: cleanType,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['suggestions'] ?? [];

        suggestedAccounts.assignAll(
          data.map((e) => RecommendedAccountModel.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Failed to load suggestions',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suggestions');
    } finally {
      isFetchingSuggestions.value = false;
    }
  }

  Future<void> refreshSuggestions() async {
    await fetchSuggestions(
      type: selectedTypeFilter.value.isEmpty
          ? null
          : selectedTypeFilter.value,
    );
  }

  void setFilter(String value) {
    selectedTypeFilter.value = value;
    fetchSuggestions(type: value.isEmpty ? null : value);
  }

  String resolveImageUrl(String? url) {
    if (url == null) return '';

    final value = url.trim();

    if (value.isEmpty || value == 'null' || value == 'string') {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${userRepo.apiClient.baseUrl}$value';
    }

    return '${userRepo.apiClient.baseUrl}/$value';
  }

  bool isRequestingConnection(String targetId) {
    return requestingConnectionIds.contains(targetId);
  }

  String? getConnectionStatus(String targetId) {
    return connectionStatuses[targetId];
  }

  bool isPendingConnection(String targetId) {
    return connectionStatuses[targetId] == 'pending';
  }

  bool isConnected(String targetId) {
    return connectionStatuses[targetId] == 'accepted';
  }

  Future<void> requestConnection(String targetId) async {
    if (targetId.trim().isEmpty) return;
    if (requestingConnectionIds.contains(targetId)) return;
    if (connectionStatuses[targetId] == 'pending' ||
        connectionStatuses[targetId] == 'accepted') {
      return;
    }

    requestingConnectionIds.add(targetId);

    try {
      final response = await userRepo.requestConnection(targetId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? status;

        if (response.body is Map) {
          final connection = response.body['connection'];

          if (connection is Map && connection['status'] != null) {
            status = connection['status'].toString();
          }
        }

        connectionStatuses[targetId] = status ?? 'pending';

        final successMessage = status == 'accepted'
            ? 'Connection accepted'
            : 'Connection request sent';

        CustomSnackBar.success(message: successMessage);
      } else {
        final message = response.body is Map
            ? (response.body['message'] ?? 'Failed to send connection request')
            : 'Failed to send connection request';

        CustomSnackBar.failure(message: message);
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to send connection request');
    } finally {
      requestingConnectionIds.remove(targetId);
    }
  }

  Future<void> acceptConnection(String connectionId) async {
    try {
      loader.showLoader();

      final response = await userRepo.acceptConnection(connectionId);

      if (response.statusCode == 200) {
        CustomSnackBar.success(message: 'Connection accepted');

        NotificationController notificationController =
        Get.find<NotificationController>();

        await notificationController.refreshNotifications();
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to accept connection',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to accept connection');
      debugPrint('acceptConnection error: $e');
    } finally {
      loader.hideLoader();
    }
  }
}
