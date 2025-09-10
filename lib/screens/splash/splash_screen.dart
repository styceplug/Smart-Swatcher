import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_swatcher/data/api/api_checker.dart';
import 'package:smart_swatcher/data/api/api_client.dart';

import '../../controllers/version_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late ApiClient apiClient;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:  Duration(seconds: 3),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  Future<void> initialize() async {
    // Step 1: Connectivity check
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Get.offAllNamed(AppRoutes.noInternetScreen);
      return;
    }

    // Step 2: DNS check
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        Get.offAllNamed(AppRoutes.noInternetScreen);
        return;
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.noInternetScreen);
      return;
    }

    // Step 3: Version check (daily or weekly)
    final versionController = Get.find<VersionController>();
    final SharedPreferences prefs = Get.find<SharedPreferences>();

    final now = DateTime.now();
    final lastCheckString = prefs.getString(AppConstants.lastVersionCheck);
    bool shouldCheckVersion = true;

    if (lastCheckString != null) {
      final lastCheck = DateTime.tryParse(lastCheckString);
      if (lastCheck != null && now.difference(lastCheck).inDays < 1) {
        shouldCheckVersion = false;
      }
    }

    if (shouldCheckVersion) {
      await versionController.checkAppVersion();
      await prefs.setString(AppConstants.lastVersionCheck, now.toIso8601String());

      final versionStatus = versionController.versionStatus.value;
      if (versionStatus == 'no-internet') {
        Get.offAllNamed(AppRoutes.noInternetScreen);
        return;
      } else if (versionStatus != 'OK') {
        Get.offAllNamed(AppRoutes.updateAppScreen);
        return;
      }
    } else {
      print("⏭️ Skipping version check (last checked $lastCheckString)");
    }

    // Step 4: Check token and route accordingly
    final token = prefs.getString(AppConstants.authToken);


    await Future.delayed(const Duration(seconds: 1));

    if (token != null && token.isNotEmpty) {
      apiClient.updateHeader(token);
      print("🔑 Header updated with token: $token");




    } else {
      print("👤 No token found. Going to onboarding.");
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: Dimensions.screenWidth,
        height: Dimensions.screenHeight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Dimensions.height313),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: Dimensions.height100 * 2,
                  width: Dimensions.width100 * 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    image: DecorationImage(
                      image: AssetImage(AppConstants.getPngAsset('logo')),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );  }
}
