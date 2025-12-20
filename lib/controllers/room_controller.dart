import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/push_notification.dart';
import '../models/room_model.dart';

class RoomController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RxList<RoomReminder> reminders = <RoomReminder>[].obs;
  final RxBool isLoading = false.obs;

  static const String _remindersKey = 'room_reminders';

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    loadReminders();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> loadReminders() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_remindersKey);

      if (remindersJson != null) {
        final List<dynamic> remindersList = json.decode(remindersJson);
        reminders.value = remindersList
            .map((reminder) => RoomReminder.fromJson(reminder))
            .toList();
      }
    } catch (e) {
      print('Error loading reminders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson =
      json.encode(reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_remindersKey, remindersJson);
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  Future<bool> setReminder(RoomReminder reminder) async {
    try {
      // Check if time is in the future
      if (reminder.dateTime.isBefore(DateTime.now())) {
        Get.snackbar(
          'Error',
          'Cannot set reminder for past events',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return false;
      }

      // Schedule notification
      await _notificationService.scheduleRoomNotification(
        id: reminder.id,
        title: reminder.title,
        hostName: reminder.hostName,
        sessionType: reminder.sessionType,
        scheduledDateTime: reminder.dateTime,
      );

      // Update reminder status
      final index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder.copyWith(isReminderSet: true);
      } else {
        reminders.add(reminder.copyWith(isReminderSet: true));
      }

      await _saveReminders();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set reminder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationService.cancelNotification(id);

      final index = reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        reminders[index] = reminders[index].copyWith(isReminderSet: false);
        await _saveReminders();
      }

      Get.snackbar(
        'Success',
        'Reminder cancelled',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel reminder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  bool isReminderSet(int id) {
    final reminder = reminders.firstWhereOrNull((r) => r.id == id);
    return reminder?.isReminderSet ?? false;
  }

  DateTime parseDateTime(String dateTimeString) {
    // Parse format: "18 Aug 2025 at 18:30"
    try {
      final format = DateFormat('dd MMM yyyy \'at\' HH:mm');
      return format.parse(dateTimeString);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  String formatDateTime(DateTime dateTime) {
    final format = DateFormat('dd MMM yyyy \'at\' HH:mm');
    return format.format(dateTime);
  }
}