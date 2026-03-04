import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/app_controller.dart';
import 'package:smart_swatcher/screens/splash/stylist/onboarding_screen.dart';

import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../controllers/version_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    AppController appController = Get.find<AppController>();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      appController.initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: Dimensions.width20*4),
        child: Center(child: Image.asset(AppConstants.getPngAsset('logo'))),
      ),
    );
  }
}


/*Future<void> initialize() async {
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
  }*/
