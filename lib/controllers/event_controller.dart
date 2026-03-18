import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repo/event_repo.dart';
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

  final RxString selectedVisibility = 'General'.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();

  final RxBool isCreatingEvent = false.obs;
  final RxBool isGettingEvents = false.obs;
  final RxBool isGettingRecommendedEvents = false.obs;
  final RxBool isGettingSingleEvent = false.obs;

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