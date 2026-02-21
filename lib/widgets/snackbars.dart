import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/dimensions.dart';
import '../utils/colors.dart';

class CustomSnackBar {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void _show({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (_isVisible) return;
    _isVisible = true;

    final overlay = Overlay.of(Get.overlayContext!);
    final animationController = AnimationController(
      vsync: overlay!,
      duration: const Duration(milliseconds: 300),
    );
    final animation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
        child: SlideTransition(
          position: animation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15,
                vertical: Dimensions.height12,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.95),
                borderRadius: BorderRadius.circular(Dimensions.radius30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: Dimensions.iconSize20),
                  SizedBox(width: Dimensions.width10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.font15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    animationController.forward();

    // Auto dismiss after 2s
    Future.delayed(const Duration(seconds: 2), () async {
      await animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      animationController.dispose();
    });
  }

  static void success({required String message}) {
    _show(
      message: message,
      color: AppColors.success2,
      icon: Icons.check_circle_rounded,
    );
  }

  static void failure({required String message}) {
    _show(
      message: message,
      color: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  static void processing({required String message}) {
    _show(
      message: message,
      color: AppColors.primary5,
      icon: Icons.hourglass_empty,
    );
  }
}
