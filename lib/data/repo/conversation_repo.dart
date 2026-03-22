import 'package:get/get.dart';
import 'package:smart_swatcher/models/conversation_model.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

import '../api/api_client.dart';

class ConversationRepo {
  final ApiClient apiClient;

  ConversationRepo({required this.apiClient});

  Future<List<ConversationSummaryModel>> getConversations() async {
    final response = await apiClient.getData(AppConstants.GET_CONVERSATIONS);
    _ensureSuccess(response, fallbackMessage: 'Failed to load conversations');

    final rawItems = response.body is Map ? response.body['conversations'] : null;
    return _parseConversationList(rawItems);
  }

  Future<List<ConversationSummaryModel>> getPrivateConversations() async {
    final response = await apiClient.getData(
      AppConstants.GET_PRIVATE_CONVERSATIONS,
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'Failed to load private conversations',
    );

    final rawItems = response.body is Map ? response.body['conversations'] : null;
    return _parseConversationList(rawItems);
  }

  Future<List<ConversationSummaryModel>> getGroupConversations() async {
    final response = await apiClient.getData(
      AppConstants.GET_GROUP_CONVERSATIONS,
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'Failed to load group conversations',
    );

    final rawItems = response.body is Map ? response.body['conversations'] : null;
    return _parseConversationList(rawItems);
  }

  Future<ConversationSummaryModel> createPrivateConversation(
    String targetId,
  ) async {
    final response = await apiClient.postData(
      AppConstants.CREATE_PRIVATE_CONVERSATION,
      {'targetId': targetId},
    );
    _ensureSuccess(
      response,
      expectedCodes: const [200, 201],
      fallbackMessage: 'Failed to start conversation',
    );

    return _parseConversation(response.body is Map
        ? response.body['conversation']
        : null);
  }

  Future<ConversationSummaryModel> createPrivateConversationWithMessage({
    required String targetId,
    required Map<String, dynamic> message,
  }) async {
    final response = await apiClient.postData(
      AppConstants.CREATE_PRIVATE_CONVERSATION_WITH_MESSAGE,
      {
        'targetId': targetId,
        'message': message,
      },
    );
    _ensureSuccess(
      response,
      expectedCodes: const [200, 201],
      fallbackMessage: 'Failed to start conversation',
    );

    return _parseConversation(response.body is Map
        ? response.body['conversation']
        : null);
  }

  Future<ConversationSummaryModel> createGroupConversation({
    String? title,
    required List<String> participantIds,
  }) async {
    final response = await apiClient.postData(
      AppConstants.CREATE_GROUP_CONVERSATION,
      {
        'title': title,
        'participantIds': participantIds,
      },
    );
    _ensureSuccess(
      response,
      expectedCodes: const [200, 201],
      fallbackMessage: 'Failed to create group chat',
    );

    return _parseConversation(response.body is Map
        ? response.body['conversation']
        : null);
  }

  Future<List<ConversationMessageModel>> getMessages(
    String conversationId, {
    int limit = 100,
    String? before,
  }) async {
    final uri = StringBuffer(
      '${AppConstants.GET_CONVERSATION_MESSAGES(conversationId)}?limit=$limit',
    );

    if (before != null && before.trim().isNotEmpty) {
      uri.write('&before=${Uri.encodeQueryComponent(before)}');
    }

    final response = await apiClient.getData(uri.toString());
    _ensureSuccess(response, fallbackMessage: 'Failed to load messages');

    final rawItems = response.body is Map ? response.body['messages'] : null;
    return _parseMessageList(rawItems);
  }

  Future<ConversationMessageModel> sendMessage(
    String conversationId, {
    String? text,
    List<String>? mediaIds,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await apiClient.postData(
      AppConstants.SEND_CONVERSATION_MESSAGE(conversationId),
      {
        'text': text,
        'mediaIds': mediaIds,
        'replyToMessageId': replyToMessageId,
        'metadata': metadata,
      },
    );
    _ensureSuccess(
      response,
      expectedCodes: const [200, 201],
      fallbackMessage: 'Failed to send message',
    );

    return _parseMessage(response.body is Map ? response.body['message'] : null);
  }

  Future<void> deleteConversation(String conversationId) async {
    final response = await apiClient.deleteData(
      AppConstants.DELETE_CONVERSATION(conversationId),
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to delete conversation');
  }

  Future<List<ConnectionRecordModel>> getAcceptedConnections() async {
    final response = await apiClient.getData(
      '${AppConstants.GET_CONNECTIONS}?status=accepted',
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to load connections');

    final rawItems = response.body is Map ? response.body['connections'] : null;
    if (rawItems is! List) {
      return const <ConnectionRecordModel>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => ConnectionRecordModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<ConversationSummaryModel> _parseConversationList(dynamic rawItems) {
    if (rawItems is! List) {
      return const <ConversationSummaryModel>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => ConversationSummaryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<ConversationMessageModel> _parseMessageList(dynamic rawItems) {
    if (rawItems is! List) {
      return const <ConversationMessageModel>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => ConversationMessageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  ConversationSummaryModel _parseConversation(dynamic rawConversation) {
    if (rawConversation is! Map) {
      throw Exception('Conversation payload missing from response');
    }

    return ConversationSummaryModel.fromJson(
      Map<String, dynamic>.from(rawConversation),
    );
  }

  ConversationMessageModel _parseMessage(dynamic rawMessage) {
    if (rawMessage is! Map) {
      throw Exception('Message payload missing from response');
    }

    return ConversationMessageModel.fromJson(
      Map<String, dynamic>.from(rawMessage),
    );
  }

  void _ensureSuccess(
    Response response, {
    List<int> expectedCodes = const [200],
    required String fallbackMessage,
  }) {
    if (expectedCodes.contains(response.statusCode)) {
      return;
    }

    final body = response.body;
    final message = body is Map
        ? body['message']?.toString()
        : response.statusText?.toString();

    throw Exception(message?.trim().isNotEmpty == true ? message : fallbackMessage);
  }
}
