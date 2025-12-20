import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../routes/routes.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';



class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.width50,
      height: Dimensions.height50 * 5,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main FAB button (always at bottom of stack, renders first/behind)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              height: Dimensions.height50,
              width: Dimensions.width50,
              decoration: BoxDecoration(
                color: AppColors.primary5,
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _expandAnimation.value * math.pi / 4,
                    child: Icon(
                      _isExpanded ? Icons.close : CupertinoIcons.mic,
                      color: AppColors.white,
                      size: Dimensions.iconSize20,
                    ),
                  );
                },
              ),
            ),
          ),

          // Video button (middle distance)
          _buildExpandingButton(
            icon: Iconsax.video,
            distance: Dimensions.height70,
            onTap: () {
              Get.toNamed(AppRoutes.createSpaceScreen);
              debugPrint("Video tapped");
              _toggle();
            },
          ),

          // Audio button (furthest, renders last/on top)
          _buildExpandingButton(
            icon: Icons.multitrack_audio_outlined,
            distance: Dimensions.height70 * 2,
            onTap: () {
              Get.toNamed(AppRoutes.createSpaceScreen);
              debugPrint("Audio tapped");
              _toggle();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandingButton({
    required IconData icon,
    required double distance,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final offset = Offset(
          0,
          -distance * _expandAnimation.value,
        );

        return Transform.translate(
          offset: offset,
          child: Transform.scale(
            scale: _expandAnimation.value,
            child: Opacity(
              opacity: _expandAnimation.value,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: Dimensions.height70,
                  width: Dimensions.width70,
                  decoration: BoxDecoration(
                    color: _isExpanded? AppColors.white : AppColors.primary5.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: _isExpanded? AppColors.primary5 : AppColors.white,
                    size: Dimensions.iconSize20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



