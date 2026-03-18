import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repo/event_repo.dart';
import '../helpers/agora_audio_helper.dart';
import '../helpers/global_loader_controller.dart';
import '../models/event_model.dart';
import '../routes/routes.dart';
import '../widgets/snackbars.dart';

class EventController extends GetxController {
  final EventRepo eventRepo;

  EventController({required this.eventRepo});

  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final AgoraAudioHelper agoraAudioHelper = Get.find<AgoraAudioHelper>();
  final RxString selectedVisibility = 'General'.obs;
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

  final Rxn<EventRtcModel> currentRtc = Rxn<EventRtcModel>();

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<EventModel> recommendedEvents = <EventModel>[].obs;
  final Rxn<EventModel> selectedEvent = Rxn<EventModel>();
  final Rxn<EventModel> createdEvent = Rxn<EventModel>();

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchRecommendedEvents();
    fetchEvents();
  }

  Future<void> setupAndJoinAgoraFromCurrentRtc() async {
    final rtc = currentRtc.value;
    if (rtc == null) {
      CustomSnackBar.failure(message: 'RTC details not available');
      return;
    }

    debugPrint('RTC DEBUG →');
    debugPrint('appId: ${rtc.appId}');
    debugPrint('channelName: ${rtc.channelName}');
    debugPrint('token: ${rtc.token}');
    debugPrint('uid: ${rtc.uid}');
    debugPrint('role: ${rtc.clientRole}');

    if (rtc.appId == null ||
        rtc.appId!.isEmpty ||
        rtc.channelName == null ||
        rtc.channelName!.isEmpty ||
        rtc.token == null ||
        rtc.token!.isEmpty ||
        rtc.uid == null) {
      CustomSnackBar.failure(message: 'Incomplete RTC payload');
      return;
    }

    await agoraAudioHelper.initialize(
      appId: rtc.appId!,
      audioOnly: rtc.audioOnly,
      clientRole: rtc.clientRole ?? 'audience',
    );

    await Future.delayed(const Duration(milliseconds: 300));

    await agoraAudioHelper.joinChannel(
      channelName: rtc.channelName!,
      token: rtc.token!,
      uid: rtc.uid!,
    );
  }

  Future<void> startEventSession(String eventId) async {
    if (isStartingEvent.value) return;

    isStartingEvent.value = true;
    loader.showLoader();

    try {
      final response = await eventRepo.startEvent(eventId);

      if (response.statusCode == 200) {
        final eventJson = response.body['event'];
        final rtcJson = response.body['rtc'];

        if (eventJson != null) {
          final updatedEvent = EventModel.fromJson(eventJson);
          _replaceEventEverywhere(updatedEvent);
          selectedEvent.value = updatedEvent;
        }

        if (rtcJson != null) {
          currentRtc.value = EventRtcModel.fromJson(rtcJson);
        }

        await setupAndJoinAgoraFromCurrentRtc();
        Get.toNamed(AppRoutes.audioSessionScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to start event',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to start event');
      debugPrint('startEventSession error: $e');
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
        final eventJson = response.body['event'];
        final rtcJson = response.body['rtc'];

        if (eventJson != null) {
          final updatedEvent = EventModel.fromJson(eventJson);
          _replaceEventEverywhere(updatedEvent);
          selectedEvent.value = updatedEvent;
        }

        if (rtcJson != null) {
          currentRtc.value = EventRtcModel.fromJson(rtcJson);
        }

        await setupAndJoinAgoraFromCurrentRtc();
        Get.toNamed(AppRoutes.audioSessionScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to join event',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to join event');
      debugPrint('joinEventSession error: $e');
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
        await leaveEventSession();
      }
    } catch (e) {
      debugPrint('leaveCurrentAudioSession error: $e');
    }
  }

  Future<void> endEventSession() async {
    final eventId = selectedEvent.value?.id;
    if (eventId == null || eventId.isEmpty) return;

    try {
      await agoraAudioHelper.leaveChannel();
      await endEventSession();
    } catch (e) {
      debugPrint('endCurrentAudioSession error: $e');
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

  Future<void> toggleSubscription(EventModel event) async {
    if (event.id == null) return;

    if (event.viewer?.isSubscribed == true) {
      await unsubscribeFromEvent(event.id!);
    } else {
      await subscribeToEvent(event.id!);
    }
  }

  void _replaceEventEverywhere(EventModel updatedEvent) {
    final eventId = updatedEvent.id;
    if (eventId == null) return;

    final eventIndex = events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      events[eventIndex] = updatedEvent;
      events.refresh();
    }

    final recommendedIndex = recommendedEvents.indexWhere((e) => e.id == eventId);
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

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDateTime.value != null
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
        "title": title,
        "description": description,
        "visibility": selectedVisibility.value,
        "scheduledStartAt": scheduledAt.toUtc().toIso8601String(),
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