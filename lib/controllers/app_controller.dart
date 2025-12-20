import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:smart_swatcher/screens/home/pages/studio_screen.dart';
import 'package:smart_swatcher/utils/colors.dart';

import '../data/repo/app_repo.dart';
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

  final List<Widget> pages = [
    const StudioScreen(),
    const FormulatorScreen(),
    const ColorClub(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    // initializeApp();
    super.onInit();
  }

  void initializeApp() async {
    await Future.wait([
      // Get.find<VersionController>().fetchActiveClasses(),
    ]);
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
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey2),
                    borderRadius: BorderRadius.circular(Dimensions.radius15)
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
                      SizedBox(width: Dimensions.width10,),
                      Text(
                        'Sophy_AnderSZN',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.radio_button_checked,color: AppColors.primary5,)
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
