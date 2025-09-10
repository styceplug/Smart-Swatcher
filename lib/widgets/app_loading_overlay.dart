import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({super.key});

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.white,
              ),
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage(AppConstants.getPngAsset('logo')),
                  //   fit: BoxFit.contain,
                  // ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}