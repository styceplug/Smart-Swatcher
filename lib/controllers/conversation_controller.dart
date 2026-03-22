import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/data/repo/conversation_repo.dart';
import 'package:smart_swatcher/helpers/chat_socket_service.dart';
import 'package:smart_swatcher/models/conversation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

class ConversationController extends GetxController {
  ConversationController({
    required this.conversationRepo,
    required this.chatSocketService,
  });

  final ConversationRepo conversationRepo;
  final ChatSocketService chatSocketService;

  final RxList<ConversationSummaryModel> conversations =
      <ConversationSummaryModel>[].obs;
  final RxList<ConversationMessageModel> activeMessages =
      <ConversationMessageModel>[].obs;
  final RxList<ConnectionRecordModel> connectionContacts =
      <ConnectionRecordModel>[].obs;

  final RxString selectedTab = 'personal'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isLoadingConnections = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isBootstrapping = false.obs;
  final RxnString socketError = RxnString();
  final Rxn<ConversationSummaryModel> activeConversation =
      Rxn<ConversationSummaryModel>();

  StreamSubscription<ChatSocketEvent>? _socketSubscription;
  final Map<String, List<ConversationMessageModel>> _messageCache =
      <String, List<ConversationMessageModel>>{};
  bool _bootstrapped = false;

  String? get currentActorId {
    final authController = Get.find<AuthController>();

    switch (authController.currentAccountType.value) {
      case AccountType.stylist:
        return authController.stylistProfile.value?.id;
      case AccountType.company:
        return authController.companyProfile.value?.id;
      case null:
        return authController.companyProfile.value?.id ??
            authController.stylistProfile.value?.id;
    }
  }

  ChatSocketConnectionState get socketState =>
      chatSocketService.connectionState.value;

  bool get isSocketConnected => chatSocketService.isConnected;

  List<ConversationSummaryModel> get personalConversations =>
      _filterConversations(ConversationType.private);

  List<ConversationSummaryModel> get groupConversations =>
      _filterConversations(ConversationType.group);

  List<ConversationSummaryModel> get threadConversations =>
      const <ConversationSummaryModel>[];

  @override
  void onInit() {
    super.onInit();
    ever<ChatSocketConnectionState>(
      chatSocketService.connectionState,
      (state) {
        socketError.value = chatSocketService.lastError.value;
        update();
      },
    );
    _socketSubscription = chatSocketService.events.listen(_handleSocketEvent);
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> bootstrap({bool force = false}) async {
    if (_bootstrapped && !force) {
      return;
    }

    isBootstrapping.value = true;

    try {
      await chatSocketService.connect(force: force);
    } catch (error, stackTrace) {
      _log('bootstrap.socket.failure', error, stackTrace);
      socketError.value = error.toString();
    }

    await loadConversations(forceApi: !isSocketConnected);

    _bootstrapped = true;
    isBootstrapping.value = false;
  }

  Future<void> loadConversations({bool forceApi = false}) async {
    isLoadingConversations.value = true;

    try {
      List<ConversationSummaryModel> items;

      if (!forceApi && isSocketConnected) {
        final response = await chatSocketService.sendRequest(
          'listConversations',
          data: <String, dynamic>{'filter': 'all'},
        );
        items = _parseConversationList(response);
        _logState(
          'conversations.ws.success',
          {'count': items.length, 'connected': true},
        );
      } else {
        items = await conversationRepo.getConversations();
        _logState(
          'conversations.api.success',
          {'count': items.length, 'connected': isSocketConnected},
        );
      }

      conversations.assignAll(_sortConversations(items));
      _syncActiveConversationReference();
    } catch (error, stackTrace) {
      _log('loadConversations.failure', error, stackTrace);
      CustomSnackBar.failure(message: error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> loadConnections({bool forceRefresh = false}) async {
    if (isLoadingConnections.value) {
      return;
    }
    if (connectionContacts.isNotEmpty && !forceRefresh) {
      return;
    }

    isLoadingConnections.value = true;
    try {
      final items = await conversationRepo.getAcceptedConnections();
      connectionContacts.assignAll(items);
      _logState('connections.api.success', {'count': items.length});
    } catch (error, stackTrace) {
      _log('loadConnections.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isLoadingConnections.value = false;
    }
  }

  Future<void> openConversationById(String conversationId) async {
    await bootstrap();

    activeConversation.value = _findConversationById(conversationId);
    activeMessages.assignAll(
      _sortMessages(_messageCache[conversationId] ?? const []),
    );
    await loadMessages(conversationId);
  }

  Future<void> loadMessages(
    String conversationId, {
    bool forceApi = false,
  }) async {
    isLoadingMessages.value = true;

    try {
      List<ConversationMessageModel> items;

      if (!forceApi && isSocketConnected) {
        final response = await chatSocketService.sendRequest(
          'listMessages',
          data: <String, dynamic>{
            'conversationId': conversationId,
            'limit': 100,
          },
        );
        items = _parseMessageList(response);
        _logState(
          'messages.ws.success',
          {'conversationId': conversationId, 'count': items.length},
        );
      } else {
        items = await conversationRepo.getMessages(conversationId, limit: 100);
        _logState(
          'messages.api.success',
          {'conversationId': conversationId, 'count': items.length},
        );
      }

      final sortedItems = _sortMessages(items);
      _messageCache[conversationId] = sortedItems;
      if (activeConversation.value?.id == conversationId) {
        activeMessages.assignAll(sortedItems);
      }
    } catch (error, stackTrace) {
      _log('loadMessages.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendTextMessage(
    String conversationId,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSendingMessage.value) {
      return;
    }

    isSendingMessage.value = true;

    try {
      ConversationMessageModel message;

      if (isSocketConnected) {
        final response = await chatSocketService.sendRequest(
          'sendMessage',
          data: <String, dynamic>{
            'conversationId': conversationId,
            'text': trimmed,
          },
        );
        message = _parseMessage(response);
        _logState(
          'sendMessage.ws.success',
          {'conversationId': conversationId, 'messageId': message.id},
        );
      } else {
        message = await conversationRepo.sendMessage(
          conversationId,
          text: trimmed,
        );
        _logState(
          'sendMessage.api.success',
          {'conversationId': conversationId, 'messageId': message.id},
        );
      }

      _upsertMessage(message);
      _updateConversationPreview(
        conversationId,
        overrideLastMessage: message,
      );
    } catch (error, stackTrace) {
      _log('sendTextMessage.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      if (isSocketConnected) {
        await chatSocketService.sendRequest(
          'deleteConversation',
          data: <String, dynamic>{'conversationId': conversationId},
        );
        _logState(
          'deleteConversation.ws.success',
          {'conversationId': conversationId},
        );
      } else {
        await conversationRepo.deleteConversation(conversationId);
        _removeConversation(conversationId);
        _logState(
          'deleteConversation.api.success',
          {'conversationId': conversationId},
        );
      }
    } catch (error, stackTrace) {
      _log('deleteConversation.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<ConversationSummaryModel?> startPrivateConversation({
    required String targetId,
    bool navigate = true,
  }) async {
    await bootstrap();

    final existingConversation = findPrivateConversationWithUser(targetId);
    if (existingConversation != null) {
      if (navigate) {
        await _navigateToConversation(existingConversation.id);
      }
      return existingConversation;
    }

    try {
      ConversationSummaryModel conversation;

      if (isSocketConnected) {
        final response = await chatSocketService.sendRequest(
          'createPrivateConversation',
          data: <String, dynamic>{'targetId': targetId},
        );
        conversation = _parseConversation(response);
        _logState(
          'createPrivateConversation.ws.success',
          {'conversationId': conversation.id, 'targetId': targetId},
        );
      } else {
        conversation = await conversationRepo.createPrivateConversation(targetId);
        _logState(
          'createPrivateConversation.api.success',
          {'conversationId': conversation.id, 'targetId': targetId},
        );
      }

      _upsertConversation(conversation);

      if (navigate) {
        await _navigateToConversation(conversation.id);
      }

      return conversation;
    } catch (error, stackTrace) {
      _log('startPrivateConversation.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<ConversationSummaryModel?> createConversationFromSelection(
    List<String> participantIds, {
    bool navigate = true,
  }) async {
    await bootstrap();

    if (participantIds.isEmpty) {
      CustomSnackBar.failure(message: 'Select at least one connection');
      return null;
    }

    if (participantIds.length == 1) {
      return startPrivateConversation(targetId: participantIds.first);
    }

    try {
      ConversationSummaryModel conversation;

      if (isSocketConnected) {
        final response = await chatSocketService.sendRequest(
          'createGroupConversation',
          data: <String, dynamic>{'participantIds': participantIds},
        );
        conversation = _parseConversation(response);
        _logState(
          'createGroupConversation.ws.success',
          {'conversationId': conversation.id, 'count': participantIds.length},
        );
      } else {
        conversation = await conversationRepo.createGroupConversation(
          participantIds: participantIds,
        );
        _logState(
          'createGroupConversation.api.success',
          {'conversationId': conversation.id, 'count': participantIds.length},
        );
      }

      _upsertConversation(conversation);
      if (navigate) {
        await _navigateToConversation(conversation.id);
      }
      return conversation;
    } catch (error, stackTrace) {
      _log('createConversationFromSelection.failure', error, stackTrace);
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  ConversationSummaryModel? findPrivateConversationWithUser(String targetId) {
    for (final conversation in conversations) {
      if (!conversation.isPrivate) {
        continue;
      }

      final otherParticipant = conversation.otherParticipant(currentActorId);
      if (otherParticipant?.profile.id == targetId) {
        return conversation;
      }
    }

    return null;
  }

  void setSelectedTab(String value) {
    selectedTab.value = value;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearActiveConversation() {
    activeConversation.value = null;
    activeMessages.clear();
  }

  List<ConversationSummaryModel> _filterConversations(ConversationType type) {
    final query = searchQuery.value.trim().toLowerCase();

    return conversations.where((conversation) {
      if (conversation.type != type) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final values = <String>[
        conversation.displayTitle(currentActorId),
        conversation.displaySubtitle(),
        conversation.title ?? '',
        ...conversation.participants.map((item) => item.profile.displayName),
        ...conversation.participants.map((item) => item.profile.username ?? ''),
      ].join(' ').toLowerCase();

      return values.contains(query);
    }).toList();
  }

  Future<void> _navigateToConversation(String conversationId) async {
    await openConversationById(conversationId);
    Get.toNamed(
      AppRoutes.conversationDetailScreen,
      arguments: conversationId,
    );
  }

  Future<void> navigateToConversation(String conversationId) async {
    await _navigateToConversation(conversationId);
  }

  void _handleSocketEvent(ChatSocketEvent event) {
    if (event.action == 'error') {
      socketError.value = event.message;
      _logState('socket.event.error', {'message': event.message ?? 'Unknown'});
      return;
    }

    switch (event.action) {
      case 'conversationCreated':
      case 'conversationUpdated':
        final conversation = _tryParseConversation(event.data);
        if (conversation != null) {
          _upsertConversation(conversation);
        }
        break;
      case 'conversationDeleted':
        final conversationId = _extractId(event.data);
        if (conversationId != null) {
          _removeConversation(conversationId);
        }
        break;
      case 'messageCreated':
        final message = _tryParseMessage(event.data);
        if (message != null) {
          _upsertMessage(message);
          _updateConversationPreview(
            message.conversationId,
            overrideLastMessage: message,
          );
        }
        break;
      case 'messageDeleted':
        final message = _tryParseMessage(event.data);
        if (message != null) {
          _removeMessage(message.conversationId, message.id);
        }
        break;
      case 'connected':
        socketError.value = null;
        break;
      default:
        break;
    }
  }

  List<ConversationSummaryModel> _sortConversations(
    List<ConversationSummaryModel> items,
  ) {
    final sorted = List<ConversationSummaryModel>.from(items);
    sorted.sort((left, right) {
      final leftTime =
          left.lastMessage?.createdAt ?? left.updatedAt ?? left.createdAt;
      final rightTime =
          right.lastMessage?.createdAt ?? right.updatedAt ?? right.createdAt;
      final leftMillis = leftTime?.millisecondsSinceEpoch ?? 0;
      final rightMillis = rightTime?.millisecondsSinceEpoch ?? 0;
      return rightMillis.compareTo(leftMillis);
    });
    return sorted;
  }

  List<ConversationMessageModel> _sortMessages(
    List<ConversationMessageModel> items,
  ) {
    final sorted = List<ConversationMessageModel>.from(items);
    sorted.sort((left, right) {
      final leftMillis = left.createdAt?.millisecondsSinceEpoch ?? 0;
      final rightMillis = right.createdAt?.millisecondsSinceEpoch ?? 0;
      return leftMillis.compareTo(rightMillis);
    });
    return sorted;
  }

  ConversationSummaryModel? _findConversationById(String conversationId) {
    try {
      return conversations.firstWhere((item) => item.id == conversationId);
    } catch (_) {
      return null;
    }
  }

  void _upsertConversation(ConversationSummaryModel conversation) {
    final updatedList = List<ConversationSummaryModel>.from(conversations);
    final index = updatedList.indexWhere((item) => item.id == conversation.id);

    if (index >= 0) {
      updatedList[index] = conversation;
    } else {
      updatedList.add(conversation);
    }

    conversations.assignAll(_sortConversations(updatedList));
    _syncActiveConversationReference();
  }

  void _removeConversation(String conversationId) {
    conversations.removeWhere((item) => item.id == conversationId);
    _messageCache.remove(conversationId);
    if (activeConversation.value?.id == conversationId) {
      activeConversation.value = null;
      activeMessages.clear();
      if (Get.currentRoute == AppRoutes.conversationDetailScreen) {
        Get.back();
      }
    }
  }

  void _upsertMessage(ConversationMessageModel message) {
    final items = List<ConversationMessageModel>.from(
      _messageCache[message.conversationId] ?? const <ConversationMessageModel>[],
    );
    final index = items.indexWhere((item) => item.id == message.id);

    if (index >= 0) {
      items[index] = message;
    } else {
      items.add(message);
    }

    final sortedItems = _sortMessages(items);
    _messageCache[message.conversationId] = sortedItems;

    if (activeConversation.value?.id == message.conversationId) {
      activeMessages.assignAll(sortedItems);
    }
  }

  void _removeMessage(String conversationId, String messageId) {
    final items = List<ConversationMessageModel>.from(
      _messageCache[conversationId] ?? const <ConversationMessageModel>[],
    )..removeWhere((item) => item.id == messageId);

    _messageCache[conversationId] = items;
    if (activeConversation.value?.id == conversationId) {
      activeMessages.assignAll(_sortMessages(items));
    }
  }

  void _updateConversationPreview(
    String conversationId, {
    ConversationMessageModel? overrideLastMessage,
  }) {
    final currentConversation = _findConversationById(conversationId);
    if (currentConversation == null) {
      return;
    }

    final refreshedConversation = ConversationSummaryModel(
      id: currentConversation.id,
      type: currentConversation.type,
      title: currentConversation.title,
      createdBy: currentConversation.createdBy,
      participants: currentConversation.participants,
      lastMessage: overrideLastMessage ?? currentConversation.lastMessage,
      deletedAt: currentConversation.deletedAt,
      createdAt: currentConversation.createdAt,
      updatedAt: DateTime.now(),
    );

    _upsertConversation(refreshedConversation);
  }

  void _syncActiveConversationReference() {
    final currentId = activeConversation.value?.id;
    if (currentId == null) {
      return;
    }

    activeConversation.value = _findConversationById(currentId);
  }

  List<ConversationSummaryModel> _parseConversationList(dynamic response) {
    if (response is! List) {
      return const <ConversationSummaryModel>[];
    }

    return response
        .whereType<Map>()
        .map(
          (item) => ConversationSummaryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<ConversationMessageModel> _parseMessageList(dynamic response) {
    if (response is! List) {
      return const <ConversationMessageModel>[];
    }

    return response
        .whereType<Map>()
        .map(
          (item) => ConversationMessageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  ConversationSummaryModel _parseConversation(dynamic response) {
    if (response is! Map) {
      throw Exception('Conversation response was empty');
    }

    return ConversationSummaryModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  ConversationMessageModel _parseMessage(dynamic response) {
    if (response is! Map) {
      throw Exception('Message response was empty');
    }

    return ConversationMessageModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  ConversationSummaryModel? _tryParseConversation(dynamic response) {
    try {
      return _parseConversation(response);
    } catch (_) {
      return null;
    }
  }

  ConversationMessageModel? _tryParseMessage(dynamic response) {
    try {
      return _parseMessage(response);
    } catch (_) {
      return null;
    }
  }

  String? _extractId(dynamic response) {
    if (response is! Map) {
      return null;
    }

    return response['id']?.toString();
  }

  void _log(String event, Object error, StackTrace stackTrace) {
    debugPrint('[CHAT_CTRL] $event error=$error');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _logState(String event, Map<String, dynamic> payload) {
    debugPrint('[CHAT_CTRL] $event ${payload.toString()}');
  }
}
