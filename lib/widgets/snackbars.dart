import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MySnackBars {
  static void success({required String title, required String message}) {
    final theme = Get.context?.theme;
    final isDark = theme?.brightness == Brightness.dark;

    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.85),
      colorText: isDark ? Colors.black : Colors.white,
      icon: Icon(
        Icons.check_circle_outline,
        size: 30,
        color: isDark ? Colors.black : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static void failure({required String title, required String message}) {
    final theme = Get.context?.theme;
    final isDark = theme?.brightness == Brightness.dark;

    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: isDark ? Colors.black : Colors.white,
      icon: Icon(
        Icons.error_outline,
        size: 30,
        color: isDark ? Colors.black : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static void processing({required String title, required String message}) {
    final theme = Get.context?.theme;
    final isDark = theme?.brightness == Brightness.dark;

    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.85),
      colorText: isDark ? Colors.black : Colors.white,
      icon: Icon(
        Icons.hourglass_empty,
        size: 30,
        color: isDark ? Colors.black : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}