import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/event_controller.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/controllers/notification_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';
import 'package:smart_swatcher/screens/company/home/company_profile.dart';
import 'package:smart_swatcher/screens/company/home/dashboard_screen.dart';
import 'package:smart_swatcher/screens/home/pages/studio_screen.dart';
import 'package:smart_swatcher/utils/colors.dart';

import '../data/repo/app_repo.dart';
import '../routes/routes.dart';
import '../screens/home/pages/color_club.dart';
import '../screens/home/pages/formulator_screen.dart';
import '../screens/home/pages/profile_screen.dart';
import '../utils/dimensions.dart';

class AppController extends GetxController {
  final AppRepo appRepo;

  AppController({required this.appRepo});

  Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  var currentAppPage = 0.obs;
  PageController pageController = PageController();
  AuthController get authController => Get.find<AuthController>();

  final List<Widget> pages = [
    const StudioScreen(),
    const FormulatorScreen(),
    const ColorClub(),
    ProfileScreen(),
  ];

  final List<Widget> companyPages = [
    const DashboardScreen(),
    const FormulatorScreen(),
    const ColorClub(),
    const CompanyProfile(),
  ];

  @override
  void onInit() {
    // initializeApp();
    super.onInit();
  }

  Future<void> initializeApp() async {
    await _loadProfiles();
    _routeByAccountType();
  }

  Future<void> refreshSessionControllers() async {
    final hasAuthenticatedProfile =
        authController.companyProfile.value != null ||
        authController.stylistProfile.value != null;

    if (!hasAuthenticatedProfile) {
      return;
    }

    changeCurrentAppPage(0, movePage: false);

    final postController = Get.find<PostController>();
    final folderController = Get.find<ClientFolderController>();
    final notificationController = Get.find<NotificationController>();
    final userController = Get.find<UserController>();
    final eventController = Get.find<EventController>();

    await Future.wait([
      postController.refreshAfterAuthChange(),
      folderController.refreshAfterAuthChange(),
      notificationController.refreshAfterAuthChange(),
      userController.refreshAfterAuthChange(),
      eventController.refreshAfterAuthChange(),
    ]);
  }

  Future<void> _loadProfiles() async {
    await Future.wait([
      authController.loadCompanyProfile(),
      authController.loadStylistProfile(),
    ]);
  }

  void _routeByAccountType() {
    final company = authController.companyProfile.value;
    final stylist = authController.stylistProfile.value;
    final hasCompany = company != null;
    final hasStylist = stylist != null;

    if (hasCompany) {
      if (company.isEmailVerified) {
        Get.offAllNamed(AppRoutes.companyHomePage);
      } else {
        authController.pendingOtpFlow.value = PendingOtpFlow(
          accountType: AccountType.company,
          destination: company.email,
          message: 'Enter the verification code sent to your email',
          postVerifyRoute: AppRoutes.companyHomePage,
        );
        Get.offAllNamed(AppRoutes.otpVerificationScreen);
      }
    } else if (hasStylist) {
      if (stylist.isEmailVerified) {
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        authController.pendingOtpFlow.value = PendingOtpFlow(
          accountType: AccountType.stylist,
          destination: stylist.email,
          message: 'Enter the verification code sent to your email',
          postVerifyRoute: AppRoutes.setStylistUsernameScreen,
        );
        Get.offAllNamed(AppRoutes.otpVerificationScreen);
      }
    } else {
      Get.offAllNamed(AppRoutes.getStarted);
    }
  }

  void changeCurrentAppPage(int page, {bool movePage = true}) {
    currentAppPage.value = page;

    if (movePage) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }

    update();
  }

  void showMoreAccount(context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Accounts',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Icon(Icons.cancel, color: Colors.grey),
                  ],
                ),
                SizedBox(height: Dimensions.height40),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey2),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: Dimensions.height50,
                        width: Dimensions.width50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey2,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Text(
                        'Sophy_AnderSZN',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.radio_button_checked,
                        color: AppColors.primary5,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height70),
              ],
            ),
          ),
    );
  }
}
