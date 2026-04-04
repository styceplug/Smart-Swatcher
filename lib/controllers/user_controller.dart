import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/notification_controller.dart';
import 'package:smart_swatcher/data/repo/post_repo.dart';
import 'package:smart_swatcher/models/post_model.dart';
import 'package:smart_swatcher/models/user_model.dart';
import '../data/repo/user_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../widgets/snackbars.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final PostRepo postRepo;

  UserController({required this.userRepo, required this.postRepo});

  final RxList<RecommendedAccountModel> suggestedAccounts =
      <RecommendedAccountModel>[].obs;
  final RxList<ConnectionPeerModel> acceptedConnections =
      <ConnectionPeerModel>[].obs;
  final RxString selectedTypeFilter = ''.obs;
  final RxBool isFetchingSuggestions = false.obs;
  final RxBool isFetchingAcceptedConnections = false.obs;
  var profile = Rxn<OtherProfileModel>();
  final RxList<PostModel> profilePosts = <PostModel>[].obs;
  final RxBool isFetchingProfilePosts = false.obs;
  final RxSet<String> requestingConnectionIds = <String>{}.obs;
  final RxMap<String, String> connectionStatuses = <String, String>{}.obs;
  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    if (_hasSessionContext) {
      Future.microtask(refreshAfterAuthChange);
    }
  }

  bool get _hasSessionContext =>
      authController.companyProfile.value != null ||
      authController.stylistProfile.value != null;

  Future<void> refreshAfterAuthChange() async {
    if (!_hasSessionContext) {
      suggestedAccounts.clear();
      acceptedConnections.clear();
      return;
    }

    await Future.wait([
      fetchSuggestions(
        type:
            selectedTypeFilter.value.isEmpty ? null : selectedTypeFilter.value,
      ),
      fetchAcceptedConnections(),
    ]);
  }

  Future<void> fetchProfile(String id, {bool showLoader = true}) async {
    try {
      if (showLoader) {
        loader.showLoader();
      }
      final res = await userRepo.getProfile(id);

      if (res != null) {
        profile.value = res;
        connectionStatuses[id] = _normaliseConnectionStatus(
          res.viewer.connectionStatus,
        );
        await fetchProfilePosts(
          authorId: id,
          authorType: res.type,
          showLoader: false,
        );
      } else {
        profilePosts.clear();
      }
    } catch (e) {
      debugPrint('Profile error: $e');
      profilePosts.clear();
    } finally {
      if (showLoader) {
        loader.hideLoader();
      }
    }
  }

  Future<void> fetchProfilePosts({
    required String authorId,
    String? authorType,
    bool showLoader = true,
  }) async {
    if (authorId.trim().isEmpty) {
      profilePosts.clear();
      return;
    }

    if (showLoader) {
      isFetchingProfilePosts.value = true;
    }

    try {
      final response = await postRepo.getPosts(
        limit: 50,
        authorId: authorId,
        authorType: authorType,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['posts'] ?? <dynamic>[];
        profilePosts.assignAll(data.map((e) => PostModel.fromJson(e)).toList());
      } else {
        profilePosts.clear();
      }
    } catch (e) {
      profilePosts.clear();
      debugPrint('fetchProfilePosts error: $e');
    } finally {
      if (showLoader) {
        isFetchingProfilePosts.value = false;
      }
    }
  }

  Future<void> refreshActiveProfile() async {
    final targetId = profile.value?.id;
    if (targetId == null || targetId.trim().isEmpty) {
      return;
    }

    await fetchProfile(targetId, showLoader: false);
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
      type: selectedTypeFilter.value.isEmpty ? null : selectedTypeFilter.value,
    );
  }

  Future<void> fetchAcceptedConnections() async {
    if (isFetchingAcceptedConnections.value) return;

    final selfId =
        authController.companyProfile.value?.id ??
        authController.stylistProfile.value?.id;
    final selfType =
        authController.companyProfile.value != null
            ? 'company'
            : authController.stylistProfile.value != null
            ? 'stylist'
            : null;

    if (selfId == null || selfType == null) {
      acceptedConnections.clear();
      return;
    }

    isFetchingAcceptedConnections.value = true;

    try {
      final response = await userRepo.getConnections(status: 'accepted');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['connections'] ?? <dynamic>[];
        acceptedConnections.assignAll(
          data
              .whereType<Map>()
              .map(
                (item) => ConnectionPeerModel.fromConnectionJson(
                  Map<String, dynamic>.from(item),
                  selfId: selfId,
                  selfType: selfType,
                ),
              )
              .where((peer) => peer.id.trim().isNotEmpty)
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('fetchAcceptedConnections error: $e');
    } finally {
      isFetchingAcceptedConnections.value = false;
    }
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
    return connectionStatuses[targetId] == 'requested_by_viewer' ||
        connectionStatuses[targetId] == 'requested_by_them' ||
        connectionStatuses[targetId] == 'pending';
  }

  bool isConnected(String targetId) {
    return connectionStatuses[targetId] == 'connected' ||
        connectionStatuses[targetId] == 'accepted';
  }

  Future<bool> requestConnection(
    String targetId, {
    bool refreshProfile = false,
  }) async {
    if (targetId.trim().isEmpty) return false;
    if (requestingConnectionIds.contains(targetId)) return false;
    if (isPendingConnection(targetId) || isConnected(targetId)) {
      return false;
    }

    requestingConnectionIds.add(targetId);
    final previousStatus = connectionStatuses[targetId];
    final previousRelationship =
        profile.value?.id == targetId ? profile.value?.viewer : null;

    connectionStatuses[targetId] = 'requested_by_viewer';
    _updateProfileRelationship(
      targetId,
      _buildRelationshipFromStatus('requested_by_viewer'),
    );

    try {
      final response = await userRepo.requestConnection(targetId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? status;
        String? connectionId;

        if (response.body is Map) {
          final connection = response.body['connection'];

          if (connection is Map && connection['status'] != null) {
            status = connection['status'].toString();
            connectionId = connection['id']?.toString();
          }
        }

        final normalizedStatus = _normaliseConnectionStatus(
          status,
          outgoingRequest: true,
        );

        connectionStatuses[targetId] = normalizedStatus;
        _updateProfileRelationship(
          targetId,
          _buildRelationshipFromStatus(
            normalizedStatus,
            connectionId: connectionId,
          ),
        );

        final successMessage =
            normalizedStatus == 'connected'
                ? 'Connection accepted'
                : 'Connection request sent';

        CustomSnackBar.success(message: successMessage);
        if (refreshProfile || profile.value?.id == targetId) {
          await fetchProfile(targetId, showLoader: false);
        }
        return true;
      } else {
        final message =
            response.body is Map
                ? (response.body['message'] ??
                    'Failed to send connection request')
                : 'Failed to send connection request';

        CustomSnackBar.failure(message: message);
        return false;
      }
    } catch (e) {
      if (previousStatus == null) {
        connectionStatuses.remove(targetId);
      } else {
        connectionStatuses[targetId] = previousStatus;
      }

      if (previousRelationship != null) {
        _updateProfileRelationship(targetId, previousRelationship);
      } else {
        _updateProfileRelationship(
          targetId,
          _buildRelationshipFromStatus('none'),
        );
      }
      CustomSnackBar.failure(message: 'Failed to send connection request');
      return false;
    } finally {
      requestingConnectionIds.remove(targetId);
    }
  }

  Future<bool> acceptConnection(
    String connectionId, {
    String? targetId,
    bool refreshProfile = false,
  }) async {
    try {
      loader.showLoader();

      final response = await userRepo.acceptConnection(connectionId);

      if (response.statusCode == 200) {
        CustomSnackBar.success(message: 'Connection accepted');
        final normalizedTargetId =
            targetId ?? _extractConnectionTargetId(response.body);

        if (normalizedTargetId != null) {
          connectionStatuses[normalizedTargetId] = 'connected';
          _updateProfileRelationship(
            normalizedTargetId,
            _buildRelationshipFromStatus(
              'connected',
              connectionId: connectionId,
            ),
          );
          if (refreshProfile || profile.value?.id == normalizedTargetId) {
            await fetchProfile(normalizedTargetId, showLoader: false);
          }
        }

        NotificationController notificationController =
            Get.find<NotificationController>();

        await notificationController.refreshNotifications();
        return true;
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to accept connection',
        );
        return false;
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to accept connection');
      debugPrint('acceptConnection error: $e');
      return false;
    } finally {
      loader.hideLoader();
    }
  }

  Future<bool> declineConnection(
    String connectionId, {
    String? targetId,
    bool refreshProfile = false,
  }) async {
    if (connectionId.trim().isEmpty) {
      return false;
    }

    try {
      loader.showLoader();

      final response = await userRepo.declineConnection(connectionId);

      if (response.statusCode == 200) {
        final normalizedTargetId =
            targetId ?? _extractConnectionTargetId(response.body);

        if (normalizedTargetId != null) {
          connectionStatuses[normalizedTargetId] = 'none';
          _updateProfileRelationship(
            normalizedTargetId,
            _buildRelationshipFromStatus('none'),
          );
          if (refreshProfile || profile.value?.id == normalizedTargetId) {
            await fetchProfile(normalizedTargetId, showLoader: false);
          }
        }

        final notificationController = Get.find<NotificationController>();
        await notificationController.refreshNotifications();
        CustomSnackBar.success(message: 'Connection request declined');
        return true;
      }

      CustomSnackBar.failure(
        message: response.body?['message'] ?? 'Failed to decline connection',
      );
      return false;
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to decline connection');
      debugPrint('declineConnection error: $e');
      return false;
    } finally {
      loader.hideLoader();
    }
  }

  Future<bool> deleteConnection(
    String connectionId, {
    String? targetId,
    bool refreshProfile = false,
    String successMessage = 'Connection removed',
  }) async {
    if (connectionId.trim().isEmpty) {
      return false;
    }

    try {
      loader.showLoader();

      final response = await userRepo.deleteConnection(connectionId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final normalizedTargetId =
            targetId ?? _extractConnectionTargetId(response.body);

        if (normalizedTargetId != null) {
          connectionStatuses[normalizedTargetId] = 'none';
          _updateProfileRelationship(
            normalizedTargetId,
            _buildRelationshipFromStatus('none'),
          );

          if (refreshProfile || profile.value?.id == normalizedTargetId) {
            await fetchProfile(normalizedTargetId, showLoader: false);
          }
        }

        final notificationController = Get.find<NotificationController>();
        await notificationController.refreshNotifications();
        CustomSnackBar.success(message: successMessage);
        return true;
      }

      CustomSnackBar.failure(
        message: response.body?['message'] ?? 'Failed to update connection',
      );
      return false;
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to update connection');
      debugPrint('deleteConnection error: $e');
      return false;
    } finally {
      loader.hideLoader();
    }
  }

  Future<bool> blockUser(String targetId, {bool closeProfile = false}) async {
    if (targetId.trim().isEmpty) {
      return false;
    }

    try {
      loader.showLoader();

      final response = await userRepo.blockUser(targetId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        connectionStatuses[targetId] = 'none';
        if (profile.value?.id == targetId) {
          profile.value = profile.value?.copyWith(
            viewer: _buildRelationshipFromStatus('none'),
          );
        }
        CustomSnackBar.success(message: 'Account blocked');
        if (closeProfile && Get.isOverlaysClosed == false) {
          Get.back();
        }
        return true;
      }

      CustomSnackBar.failure(
        message: response.body?['message'] ?? 'Failed to block account',
      );
      return false;
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to block account');
      return false;
    } finally {
      loader.hideLoader();
    }
  }

  String _normaliseConnectionStatus(
    String? status, {
    bool outgoingRequest = false,
  }) {
    switch (status) {
      case 'accepted':
      case 'connected':
        return 'connected';
      case 'requested_by_viewer':
      case 'requested_by_them':
        return status!;
      case 'pending':
        return outgoingRequest ? 'requested_by_viewer' : 'requested_by_them';
      case 'self':
        return 'self';
      case 'none':
      case null:
        return 'none';
      default:
        return status;
    }
  }

  ProfileViewerRelationshipModel _buildRelationshipFromStatus(
    String status, {
    String? connectionId,
  }) {
    switch (status) {
      case 'connected':
        return ProfileViewerRelationshipModel(
          connectionId: connectionId,
          connectionStatus: 'connected',
          isConnected: true,
          canMessage: true,
        );
      case 'requested_by_viewer':
        return ProfileViewerRelationshipModel(
          connectionId: connectionId,
          connectionStatus: 'requested_by_viewer',
          requestedByViewer: true,
        );
      case 'requested_by_them':
        return ProfileViewerRelationshipModel(
          connectionId: connectionId,
          connectionStatus: 'requested_by_them',
          requestedByThem: true,
          canAcceptConnection: true,
        );
      case 'self':
        return const ProfileViewerRelationshipModel(
          isSelf: true,
          connectionStatus: 'self',
        );
      case 'none':
      default:
        return const ProfileViewerRelationshipModel(
          connectionStatus: 'none',
          canRequestConnection: true,
        );
    }
  }

  void _updateProfileRelationship(
    String targetId,
    ProfileViewerRelationshipModel relationship,
  ) {
    if (profile.value?.id != targetId) {
      return;
    }

    profile.value = profile.value?.copyWith(viewer: relationship);
  }

  String? _extractConnectionTargetId(dynamic body) {
    if (body is! Map) {
      return null;
    }

    final connection = body['connection'];
    if (connection is! Map) {
      return null;
    }

    final requester = connection['requester'];
    final addressee = connection['addressee'];
    final currentProfileId = profile.value?.id;

    final requesterId = requester is Map ? requester['id']?.toString() : null;
    final addresseeId = addressee is Map ? addressee['id']?.toString() : null;

    if (requesterId == currentProfileId) {
      return requesterId;
    }
    if (addresseeId == currentProfileId) {
      return addresseeId;
    }

    return requesterId ?? addresseeId;
  }
}
