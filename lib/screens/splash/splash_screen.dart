
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/screens/splash/stylist/onboarding_screen.dart';

import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../controllers/version_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  // late Animation<double> _fadeAnimation;
  String? selectedUserType;

  @override
  void initState() {
    super.initState();

    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 3),
    // );
    // _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    // _controller.forward();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void getStarted(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                Dimensions.height20
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select User Type',
                      style: TextStyle(
                        fontSize: Dimensions.font20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),
                
                    // Stylist option
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedUserType = "stylist";
                        });
                      },
                      child: Container(
                        width: Dimensions.screenWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(Dimensions.radius20),
                          color: AppColors.grey1,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              child: Image.asset(
                                AppConstants.getPngAsset('stylist-icon'),
                              ),
                            ),
                            SizedBox(width: Dimensions.width20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stylist',
                                    style: TextStyle(
                                      fontSize: Dimensions.font17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'For hairstylists, colorists, salon owners, students, and educators.',
                                    style: TextStyle(
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selectedUserType == "stylist"
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: selectedUserType == "stylist"
                                  ? AppColors.primary5
                                  : AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                
                    SizedBox(height: Dimensions.height20),
                
                    // Company option
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedUserType = "company";
                        });
                      },
                      child: Container(
                        width: Dimensions.screenWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(Dimensions.radius20),
                          color: AppColors.grey1,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              child: Image.asset(
                                AppConstants.getPngAsset('company-icon'),
                              ),
                            ),
                            SizedBox(width: Dimensions.width20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Company',
                                    style: TextStyle(
                                      fontSize: Dimensions.font17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'For product manufacturers, color brands, educators, and brand reps.',
                                    style: TextStyle(
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selectedUserType == "company"
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: selectedUserType == "company"
                                  ? AppColors.primary5
                                  : AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                
                    SizedBox(height: Dimensions.height30),
                
                    // Done button
                    Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height40),
                      child: CustomButton(
                        text: 'Done',
                        backgroundColor: AppColors.primary5,
                        onPressed: () async {
                          if (selectedUserType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a user type"),
                              ),
                            );
                            return;
                          }
                
                
                
                          Navigator.pop(context); // close bottom sheet
                
                          if (selectedUserType == "stylist") {
                            Get.offAllNamed(AppRoutes.onboardingScreen);
                          } else if (selectedUserType == "company") {
                            Get.offAllNamed(AppRoutes.onboardCompany);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.zero,
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(AppConstants.getPngAsset('splash')),
                ),
              ),
            ),
        
            // Content
            SizedBox(
              height: Dimensions.screenHeight,
              width: Dimensions.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Dimensions.height50),
        

                  Container(
                    height: Dimensions.height100 * 3,
                    width: Dimensions.width100 * 3,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(Dimensions.radius15),
                      image: DecorationImage(
                        image: AssetImage(AppConstants.getPngAsset('logo')),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
        
                  const Spacer(),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.width20,
                      0,
                      Dimensions.width20,
                      Dimensions.height50,
                    ),
                    child: CustomButton(
                      text: 'Get Started',
                      onPressed: () => getStarted(context),
                      backgroundColor: AppColors.primary5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





///INITIALIZE

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