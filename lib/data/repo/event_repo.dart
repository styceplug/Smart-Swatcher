import 'package:get/get.dart';
import 'package:smart_swatcher/data/api/api_client.dart';

import '../../utils/app_constants.dart';

class EventRepo {
  final ApiClient apiClient;

  EventRepo({required this.apiClient});

  Future<Response> subscribeToEvent(String eventId) async {
    return await apiClient.postData(AppConstants.SUBSCRIBE_EVENT(eventId), {});
  }

  Future<Response> unsubscribeFromEvent(String eventId) async {
    return await apiClient.deleteData(AppConstants.UNSUBSCRIBE_EVENT(eventId));
  }

  Future<Response> startEvent(String eventId) async {
    return await apiClient.postData(AppConstants.START_EVENT(eventId), {});
  }

  Future<Response> joinEvent(String eventId) async {
    return await apiClient.postData(AppConstants.JOIN_EVENT(eventId), {});
  }

  Future<Response> leaveEvent(String eventId) async {
    return await apiClient.postData(AppConstants.LEAVE_EVENT(eventId), {});
  }

  Future<Response> endEvent(String eventId) async {
    return await apiClient.postData(AppConstants.END_EVENT(eventId), {});
  }

  Future<Response> assignCohost(
    String eventId, {
    required String targetId,
    required String targetType,
  }) async {
    return await apiClient.postData(AppConstants.ASSIGN_COHOST(eventId), {
      'targetId': targetId,
      'targetType': targetType,
    });
  }

  Future<Response> revokeCohost(
    String eventId, {
    required String targetId,
    required String targetType,
  }) async {
    return await apiClient.deleteData(
      AppConstants.REVOKE_COHOST(eventId, targetType, targetId),
    );
  }

  Future<Response> raiseHand(String eventId) async {
    return await apiClient.postData(AppConstants.RAISE_EVENT_HAND(eventId), {});
  }

  Future<Response> lowerHand(String eventId) async {
    return await apiClient.deleteData(AppConstants.LOWER_EVENT_HAND(eventId));
  }

  Future<Response> grantSpeaker(
    String eventId, {
    required String targetId,
    required String targetType,
  }) async {
    return await apiClient.postData(AppConstants.GRANT_EVENT_SPEAKER(eventId), {
      'targetId': targetId,
      'targetType': targetType,
    });
  }

  Future<Response> revokeSpeaker(
    String eventId, {
    required String targetId,
    required String targetType,
  }) async {
    return await apiClient.deleteData(
      AppConstants.REVOKE_EVENT_SPEAKER(eventId, targetType, targetId),
    );
  }

  Future<Response> sendReaction(
    String eventId, {
    required String reaction,
  }) async {
    return await apiClient.postData(AppConstants.SEND_EVENT_REACTION(eventId), {
      'reaction': reaction,
    });
  }

  Future<Response> createEvent(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.CREATE_EVENT, body);
  }

  Future<Response> getEvents({
    String? status,
    String? visibility,
    String? creatorId,
    String? creatorType,
    bool? createdByMe,
    bool? subscribedOnly,
    int? limit,
    int? offset,
  }) async {
    String uri = AppConstants.GET_EVENT;

    final queryParams = <String, String>{};

    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }
    if (visibility != null && visibility.trim().isNotEmpty) {
      queryParams['visibility'] = visibility.trim();
    }
    if (creatorId != null && creatorId.trim().isNotEmpty) {
      queryParams['creatorId'] = creatorId.trim();
    }
    if (creatorType != null && creatorType.trim().isNotEmpty) {
      queryParams['creatorType'] = creatorType.trim();
    }
    if (createdByMe != null) {
      queryParams['createdByMe'] = createdByMe.toString();
    }
    if (subscribedOnly != null) {
      queryParams['subscribedOnly'] = subscribedOnly.toString();
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (offset != null) {
      queryParams['offset'] = offset.toString();
    }

    if (queryParams.isNotEmpty) {
      uri += '?${Uri(queryParameters: queryParams).query}';
    }

    return await apiClient.getData(uri);
  }

  Future<Response> getRecommendedEvents({int limit = 20}) async {
    return await apiClient.getData(
      '${AppConstants.GET_RECOMMENDED_EVENT}?limit=$limit',
    );
  }

  Future<Response> getSingleEvent(String eventId) async {
    return await apiClient.getData(AppConstants.GET_SINGLE_EVENT(eventId));
  }
}
