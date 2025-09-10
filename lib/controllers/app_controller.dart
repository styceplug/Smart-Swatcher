import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:smart_swatcher/screens/home/pages/studio_screen.dart';

import '../data/repo/app_repo.dart';
import '../screens/home/pages/color_club.dart';
import '../screens/home/pages/formulator_screen.dart';
import '../screens/home/pages/profile_screen.dart';

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
    const ProfileScreen(),
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
  }}
