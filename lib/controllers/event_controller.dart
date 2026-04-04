import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repo/event_repo.dart';
import '../helpers/agora_audio_helper.dart';
import '../helpers/chat_socket_service.dart';
import '../helpers/global_loader_controller.dart';
import '../models/event_model.dart';
import '../routes/routes.dart';
import '../widgets/snackbars.dart';
import 'auth_controller.dart';

class EventController extends GetxController {
  final EventRepo eventRepo;

  EventController({required this.eventRepo});

  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  final AgoraAudioHelper agoraAudioHelper = Get.find<AgoraAudioHelper>();
  final ChatSocketService chatSocketService = Get.find<ChatSocketService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedVisibility = 'General'.obs;
  final RxString selectedSessionMode = 'interactive'.obs;
  final RxBool allowHandRaises = true.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();

  final RxBool isCreatingEvent = false.obs;
  final RxBool isGettingEvents = false.obs;
  final RxBool isGettingRecommendedEvents = false.obs;
  final RxBool isGettingSingleEvent = false.obs;
  final RxBool isTogglingReminder = false.obs;
  final RxBool isStartingEvent = false.obs;
  final RxBool isJoiningEvent = false.obs;
  final RxBool isLeavingEvent = false.obs;
  final RxBool isEndingEvent = false.obs;
  final RxBool isAssigningCohost = false.obs;
  final RxBool isUpdatingSpeaker = false.obs;
  final RxBool isUpdatingHand = false.obs;
  final RxBool isSendingReaction = false.obs;

  final Rxn<EventRtcModel> currentRtc = Rxn<EventRtcModel>();
  final RxList<LiveEventReactionModel> liveReactions =
      <LiveEventReactionModel>[].obs;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<EventModel> recommendedEvents = <EventModel>[].obs;
  final Rxn<EventModel> selectedEvent = Rxn<EventModel>();
  final Rxn<EventModel> createdEvent = Rxn<EventModel>();

  StreamSubscription<ChatSocketEvent>? _chatEventSubscription;

  @override
  void onClose() {
    _chatEventSubscription?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _bindRealtimeEvents();
    if (_hasSessionContext) {
      refreshAfterAuthChange();
    }
  }

  bool get _hasSessionContext {
    final authController = Get.find<AuthController>();
    return authController.companyProfile.value != null ||
        authController.stylistProfile.value != null;
  }

  Future<void> refreshAfterAuthChange() async {
    if (isGettingEvents.value || isGettingRecommendedEvents.value) {
      return;
    }

    await Future.wait([fetchRecommendedEvents(), fetchEvents()]);
  }

  void _bindRealtimeEvents() {
    _chatEventSubscription?.cancel();
    _chatEventSubscription = chatSocketService.events.listen(
      _handleSocketEvent,
    );
  }

  void _handleSocketEvent(ChatSocketEvent socketEvent) {
    final rawData = socketEvent.data;
    if (rawData is! Map) {
      return;
    }

    final data = Map<String, dynamic>.from(rawData);
    final currentEventId = selectedEvent.value?.id ?? createdEvent.value?.id;
    final eventId = data['eventId']?.toString();

    if (eventId == null ||
        currentEventId == null ||
        eventId != currentEventId) {
      return;
    }

    switch (socketEvent.action) {
      case 'eventUpdated':
        debugPrint('[EVENT_CTRL] realtime.eventUpdated => $data');
        unawaited(refreshActiveEvent());
        break;
      case 'eventRtcUpdated':
        if (data['rtc'] is Map<String, dynamic>) {
          debugPrint('[EVENT_CTRL] realtime.eventRtcUpdated => $data');
          final rtc = EventRtcModel.fromJson(
            Map<String, dynamic>.from(data['rtc'] as Map<String, dynamic>),
          );
          unawaited(_applyRtcRoleChange(rtc));
        }
        break;
      case 'eventReaction':
        debugPrint('[EVENT_CTRL] realtime.eventReaction => $data');
        _addReaction(
          LiveEventReactionModel.fromJson(<String, dynamic>{
            ...data,
            'eventId': eventId,
          }),
        );
        break;
    }
  }

  void _logEventDebug(String label, dynamic payload) {
    if (payload == null) return;
    debugPrint('$label DEBUG => $payload');
  }

  Future<void> _ensureLiveRealtimeConnected() async {
    try {
      await chatSocketService.connect();
    } catch (error) {
      debugPrint('[EVENT_CTRL] realtime.connect.skip => $error');
    }
  }

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> setupAndJoinAgoraFromCurrentRtc() async {
    final rtc = currentRtc.value;
    if (rtc == null) {
      throw Exception('RTC details not available');
    }

    debugPrint('RTC DEBUG →');
    debugPrint('appIdLength: ${rtc.appId?.trim().length ?? 0}');
    debugPrint('channelName: ${rtc.channelName}');
    debugPrint('tokenLength: ${rtc.token?.length ?? 0}');
    debugPrint('uid: ${rtc.uid}');
    debugPrint('role: ${rtc.clientRole}');
    debugPrint('participantRole: ${rtc.participantRole}');
    debugPrint('sessionMode: ${rtc.sessionMode}');

    if (rtc.appId == null ||
        rtc.appId!.isEmpty ||
        rtc.channelName == null ||
        rtc.channelName!.isEmpty ||
        rtc.token == null ||
        rtc.token!.isEmpty ||
        rtc.uid == null) {
      throw Exception('Incomplete RTC payload');
    }

    await agoraAudioHelper.initialize(
      appId: rtc.appId!,
      sessionMode: rtc.sessionMode,
      participantRole: rtc.participantRole,
      canPublishAudio: rtc.canPublishAudio,
      canPublishVideo: rtc.canPublishVideo,
      clientRole: rtc.clientRole ?? 'audience',
    );

    await Future.delayed(const Duration(milliseconds: 250));

    await agoraAudioHelper.joinChannel(
      channelName: rtc.channelName!,
      token: rtc.token!,
      uid: rtc.uid!,
    );

    int attempts = 0;
    while (!agoraAudioHelper.isJoined.value && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 250));
      attempts++;
    }

    if (!agoraAudioHelper.isJoined.value) {
      throw Exception('Agora joined event not received');
    }
  }

  Future<void> _applyRtcRoleChange(EventRtcModel rtc) async {
    final previousRtc = currentRtc.value;
    currentRtc.value = rtc;

    final needsMicPermission =
        rtc.canPublishAudio && !(previousRtc?.canPublishAudio ?? false);
    if (needsMicPermission) {
      final granted = await requestMicPermission();
      if (!granted) {
        CustomSnackBar.failure(
          message: 'Microphone permission is required to speak in this event.',
        );
      }
    }

    await agoraAudioHelper.applyRtcUpdate(
      sessionMode: rtc.sessionMode,
      participantRole: rtc.participantRole,
      canPublishAudio: rtc.canPublishAudio,
      canPublishVideo: rtc.canPublishVideo,
      clientRole: rtc.clientRole ?? 'audience',
      token: rtc.token,
    );
    await refreshActiveEvent();
  }

  Future<void> startEventSession(String eventId) async {
    if (isStartingEvent.value) return;

    isStartingEvent.value = true;
    loader.showLoader();

    try {
      final hasMic = await requestMicPermission();
      if (!hasMic) {
        CustomSnackBar.failure(message: 'Microphone permission is required');
        return;
      }

      final response = await eventRepo.startEvent(eventId);

      if (response.statusCode == 200) {
        _logEventDebug('startEventSession', response.body?['debug']);
        final eventJson = response.body['event'];
        final rtcJson = response.body['rtc'];

        if (eventJson != null) {
          final updatedEvent = EventModel.fromJson(eventJson);
          _replaceEventEverywhere(updatedEvent);
          selectedEvent.value = updatedEvent;
        }

        if (rtcJson != null) {
          currentRtc.value = EventRtcModel.fromJson(
            Map<String, dynamic>.from(rtcJson),
          );
        }

        await _ensureLiveRealtimeConnected();
        await setupAndJoinAgoraFromCurrentRtc();
        Get.toNamed(AppRoutes.audioSessionScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to start event',
        );
      }
    } catch (e, st) {
      debugPrint('startEventSession error: $e');
      debugPrintStack(stackTrace: st);
      CustomSnackBar.failure(message: 'Failed to start live session');
    } finally {
      isStartingEvent.value = false;
      loader.hideLoader();
    }
  }

  Future<void> joinEventSession(String eventId) async {
    if (isJoiningEvent.value) return;

    isJoiningEvent.value = true;
    loader.showLoader();

    try {
      final response = await eventRepo.joinEvent(eventId);

      if (response.statusCode == 200) {
        _logEventDebug('joinEventSession', response.body?['debug']);
        selectedEvent.value = EventModel.fromJson(response.body['event']);
        currentRtc.value = EventRtcModel.fromJson(
          Map<String, dynamic>.from(response.body['rtc']),
        );

        if (currentRtc.value?.canPublishAudio == true) {
          final hasMic = await requestMicPermission();
          if (!hasMic) {
            CustomSnackBar.failure(
              message: 'Microphone permission is required',
            );
            return;
          }
        }

        await _ensureLiveRealtimeConnected();
        await setupAndJoinAgoraFromCurrentRtc();
        Get.toNamed(AppRoutes.audioSessionScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to join event',
        );
      }
    } catch (e, st) {
      debugPrint('joinEventSession error: $e');
      debugPrintStack(stackTrace: st);
      CustomSnackBar.failure(message: 'Unable to join live event');
    } finally {
      isJoiningEvent.value = false;
      loader.hideLoader();
    }
  }

  Future<void> leaveEventSession() async {
    final eventId = selectedEvent.value?.id;
    try {
      await agoraAudioHelper.leaveChannel();
      if (eventId != null && eventId.isNotEmpty) {
        await eventRepo.leaveEvent(eventId);
      }
    } catch (e) {
      debugPrint('leaveEventSession error: $e');
    } finally {
      currentRtc.value = null;
      liveReactions.clear();
    }
  }

  Future<void> endEventSession() async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty) return;
    try {
      await agoraAudioHelper.leaveChannel();
      await eventRepo.endEvent(eventId);
      liveReactions.clear();
      currentRtc.value = null;
    } catch (e) {
      debugPrint('endEventSession error: $e');
    }
  }

  Future<void> toggleSubscription(EventModel event) async {
    if (event.id == null) return;

    if (event.viewer?.isSubscribed == true) {
      await unsubscribeFromEvent(event.id!);
    } else {
      await subscribeToEvent(event.id!);
    }
  }

  Future<void> subscribeToEvent(String eventId) async {
    if (isTogglingReminder.value) return;

    isTogglingReminder.value = true;
    try {
      final response = await eventRepo.subscribeToEvent(eventId);

      if (response.statusCode == 200) {
        final eventJson = response.body['event'];
        if (eventJson != null) {
          final updatedEvent = EventModel.fromJson(eventJson);
          _replaceEventEverywhere(updatedEvent);
        }
        CustomSnackBar.success(message: 'Reminder set');
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to set reminder',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to set reminder');
    } finally {
      isTogglingReminder.value = false;
    }
  }

  Future<void> unsubscribeFromEvent(String eventId) async {
    if (isTogglingReminder.value) return;

    isTogglingReminder.value = true;
    try {
      final response = await eventRepo.unsubscribeFromEvent(eventId);

      if (response.statusCode == 200) {
        final eventJson = response.body['event'];
        if (eventJson != null) {
          final updatedEvent = EventModel.fromJson(eventJson);
          _replaceEventEverywhere(updatedEvent);
        }
        CustomSnackBar.success(message: 'Reminder cancelled');
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to cancel reminder',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to cancel reminder');
    } finally {
      isTogglingReminder.value = false;
    }
  }

  Future<void> refreshActiveEvent({bool showErrors = false}) async {
    final eventId = selectedEvent.value?.id ?? createdEvent.value?.id;
    if (eventId == null || eventId.isEmpty) return;

    try {
      final response = await eventRepo.getSingleEvent(eventId);
      if (response.statusCode == 200 && response.body?['event'] != null) {
        _logEventDebug('refreshActiveEvent', response.body?['debug']);
        final updatedEvent = EventModel.fromJson(response.body['event']);
        _replaceEventEverywhere(updatedEvent);
        selectedEvent.value = updatedEvent;
      } else if (showErrors) {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to refresh live event',
        );
      }
    } catch (e, st) {
      debugPrint('refreshActiveEvent error: $e');
      debugPrintStack(stackTrace: st);
      if (showErrors) {
        CustomSnackBar.failure(message: 'Failed to refresh live event');
      }
    }
  }

  Future<void> assignCohost({
    required String eventId,
    required String targetId,
    required String targetType,
  }) async {
    if (isAssigningCohost.value) return;
    isAssigningCohost.value = true;
    try {
      final response = await eventRepo.assignCohost(
        eventId,
        targetId: targetId,
        targetType: targetType,
      );
      if (response.statusCode == 200) {
        if (response.body?['event'] != null) {
          final updatedEvent = EventModel.fromJson(response.body['event']);
          _replaceEventEverywhere(updatedEvent);
          selectedEvent.value = updatedEvent;
        } else {
          await refreshActiveEvent();
        }
        CustomSnackBar.success(message: 'Cohost assigned');
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to assign cohost',
        );
      }
    } catch (e) {
      debugPrint('assignCohost error: $e');
      CustomSnackBar.failure(message: 'Failed to assign cohost');
    } finally {
      isAssigningCohost.value = false;
    }
  }

  Future<void> revokeCohost({
    required String eventId,
    required String targetId,
    required String targetType,
  }) async {
    if (isAssigningCohost.value) return;
    isAssigningCohost.value = true;
    try {
      final response = await eventRepo.revokeCohost(
        eventId,
        targetId: targetId,
        targetType: targetType,
      );
      if (response.statusCode == 200) {
        if (response.body?['event'] != null) {
          final updatedEvent = EventModel.fromJson(response.body['event']);
          _replaceEventEverywhere(updatedEvent);
          selectedEvent.value = updatedEvent;
        } else {
          await refreshActiveEvent();
        }
        CustomSnackBar.success(message: 'Cohost access revoked');
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to revoke cohost',
        );
      }
    } catch (e) {
      debugPrint('revokeCohost error: $e');
      CustomSnackBar.failure(message: 'Failed to revoke cohost');
    } finally {
      isAssigningCohost.value = false;
    }
  }

  Future<void> raiseHand() async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty || isUpdatingHand.value) return;
    isUpdatingHand.value = true;
    try {
      final response = await eventRepo.raiseHand(eventId);
      if (response.statusCode == 200) {
        await refreshActiveEvent();
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to raise hand',
        );
      }
    } catch (e) {
      debugPrint('raiseHand error: $e');
      CustomSnackBar.failure(message: 'Failed to raise hand');
    } finally {
      isUpdatingHand.value = false;
    }
  }

  Future<void> lowerHand() async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty || isUpdatingHand.value) return;
    isUpdatingHand.value = true;
    try {
      final response = await eventRepo.lowerHand(eventId);
      if (response.statusCode == 200) {
        await refreshActiveEvent();
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to lower hand',
        );
      }
    } catch (e) {
      debugPrint('lowerHand error: $e');
      CustomSnackBar.failure(message: 'Failed to lower hand');
    } finally {
      isUpdatingHand.value = false;
    }
  }

  Future<void> grantSpeaker({
    required String targetId,
    required String targetType,
  }) async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty || isUpdatingSpeaker.value) return;
    isUpdatingSpeaker.value = true;
    try {
      final response = await eventRepo.grantSpeaker(
        eventId,
        targetId: targetId,
        targetType: targetType,
      );
      if (response.statusCode == 200) {
        await refreshActiveEvent();
        CustomSnackBar.success(message: 'Speaker access granted');
      } else {
        CustomSnackBar.failure(
          message:
              response.body?['message'] ?? 'Failed to grant speaker access',
        );
      }
    } catch (e) {
      debugPrint('grantSpeaker error: $e');
      CustomSnackBar.failure(message: 'Failed to grant speaker access');
    } finally {
      isUpdatingSpeaker.value = false;
    }
  }

  Future<void> revokeSpeaker({
    required String targetId,
    required String targetType,
  }) async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty || isUpdatingSpeaker.value) return;
    isUpdatingSpeaker.value = true;
    try {
      final response = await eventRepo.revokeSpeaker(
        eventId,
        targetId: targetId,
        targetType: targetType,
      );
      if (response.statusCode == 200) {
        await refreshActiveEvent();
        CustomSnackBar.success(message: 'Speaker access revoked');
      } else {
        CustomSnackBar.failure(
          message:
              response.body?['message'] ?? 'Failed to revoke speaker access',
        );
      }
    } catch (e) {
      debugPrint('revokeSpeaker error: $e');
      CustomSnackBar.failure(message: 'Failed to revoke speaker access');
    } finally {
      isUpdatingSpeaker.value = false;
    }
  }

  Future<void> sendReaction(String reaction) async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty || isSendingReaction.value) return;
    isSendingReaction.value = true;
    try {
      final response = await eventRepo.sendReaction(
        eventId,
        reaction: reaction,
      );
      if (response.statusCode == 200 && response.body?['reaction'] != null) {
        _addReaction(
          LiveEventReactionModel.fromJson(<String, dynamic>{
            ...Map<String, dynamic>.from(response.body['reaction']),
            'eventId': eventId,
          }),
        );
      } else if (response.statusCode != 200) {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to send reaction',
        );
      }
    } catch (e) {
      debugPrint('sendReaction error: $e');
    } finally {
      isSendingReaction.value = false;
    }
  }

  void _addReaction(LiveEventReactionModel reaction) {
    liveReactions.add(reaction);
    Future.delayed(const Duration(seconds: 4), () {
      liveReactions.remove(reaction);
    });
  }

  void _replaceEventEverywhere(EventModel updatedEvent) {
    final eventId = updatedEvent.id;
    if (eventId == null) return;

    final eventIndex = events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      events[eventIndex] = updatedEvent;
      events.refresh();
    }

    final recommendedIndex = recommendedEvents.indexWhere(
      (e) => e.id == eventId,
    );
    if (recommendedIndex != -1) {
      recommendedEvents[recommendedIndex] = updatedEvent;
      recommendedEvents.refresh();
    }

    if (selectedEvent.value?.id == eventId) {
      selectedEvent.value = updatedEvent;
    }

    if (createdEvent.value?.id == eventId) {
      createdEvent.value = updatedEvent;
    }
  }

  void setVisibility(String value) {
    selectedVisibility.value = value;
  }

  void setSessionMode(String value) {
    selectedSessionMode.value = value;
  }

  void setScheduledDateTime(DateTime dateTime) {
    selectedDateTime.value = dateTime;
  }

  Future<void> pickDateTime(BuildContext context) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          selectedDateTime.value != null
              ? TimeOfDay.fromDateTime(selectedDateTime.value!)
              : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    selectedDateTime.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> createEvent() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final scheduledAt = selectedDateTime.value;

    if (title.isEmpty) {
      CustomSnackBar.failure(message: 'Please enter event name');
      return;
    }

    if (description.isEmpty) {
      CustomSnackBar.failure(message: 'Please enter description');
      return;
    }

    if (scheduledAt == null) {
      CustomSnackBar.failure(message: 'Please select time');
      return;
    }

    if (isCreatingEvent.value) return;

    isCreatingEvent.value = true;
    loader.showLoader();

    try {
      final body = {
        'title': title,
        'description': description,
        'visibility': selectedVisibility.value,
        'sessionMode': selectedSessionMode.value,
        'allowHandRaises': allowHandRaises.value,
        'scheduledStartAt': scheduledAt.toUtc().toIso8601String(),
      };

      final response = await eventRepo.createEvent(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final eventJson = response.body['event'];
        if (eventJson != null) {
          final event = EventModel.fromJson(eventJson);
          createdEvent.value = event;
          selectedEvent.value = event;
        }

        CustomSnackBar.success(message: 'Event created successfully');
        Get.toNamed(AppRoutes.shareSpaceScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to create event',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to create event');
    } finally {
      isCreatingEvent.value = false;
      loader.hideLoader();
    }
  }

  Future<void> fetchEvents({
    String? status,
    String? visibility,
    String? creatorId,
    String? creatorType,
    bool? createdByMe,
    bool? subscribedOnly,
    int limit = 20,
    int offset = 0,
  }) async {
    isGettingEvents.value = true;

    try {
      final response = await eventRepo.getEvents(
        status: status,
        visibility: visibility,
        creatorId: creatorId,
        creatorType: creatorType,
        createdByMe: createdByMe,
        subscribedOnly: subscribedOnly,
        limit: limit,
        offset: offset,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['events'] ?? [];
        events.assignAll(data.map((e) => EventModel.fromJson(e)).toList());
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to fetch events',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to fetch events');
    } finally {
      isGettingEvents.value = false;
    }
  }

  Future<void> fetchRecommendedEvents({int limit = 20}) async {
    isGettingRecommendedEvents.value = true;

    try {
      final response = await eventRepo.getRecommendedEvents(limit: limit);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['events'] ?? [];
        recommendedEvents.assignAll(
          data.map((e) => EventModel.fromJson(e)).toList(),
        );
      } else {
        CustomSnackBar.failure(
          message:
              response.body?['message'] ?? 'Failed to fetch recommended events',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to fetch recommended events');
    } finally {
      isGettingRecommendedEvents.value = false;
    }
  }

  Future<void> fetchSingleEvent(String eventId) async {
    isGettingSingleEvent.value = true;

    try {
      final response = await eventRepo.getSingleEvent(eventId);

      if (response.statusCode == 200) {
        final eventJson = response.body['event'];
        if (eventJson != null) {
          selectedEvent.value = EventModel.fromJson(eventJson);
        }
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to fetch event',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to fetch event');
    } finally {
      isGettingSingleEvent.value = false;
    }
  }

  String get formattedDateTime {
    final value = selectedDateTime.value;
    if (value == null) return 'Select Time';

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';

    return '${value.day}/${value.month}/${value.year}  $hour:$minute $suffix';
  }

  String formatEventDate(DateTime? value) {
    if (value == null) return 'No date';

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';

    return '${value.day}/${value.month}/${value.year} at $hour:$minute $suffix';
  }
}
