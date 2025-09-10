import 'package:get/get.dart';

import '../screens/splash/splash_screen.dart';

class AppRoutes {
  //general
  static const String splashScreen = '/splash-screen';
  static const String onboardingScreen = '/onboarding-screen';
  static const String updateAppScreen = '/update-app-screen';
  static const String noInternetScreen = '/no-internet-screen';

  //stylist
  static const String homeScreen = '/home-screen';
  static const String studioScreen = '/studio-screen';
  static const String formulatorScreen = '/formulator-screen';
  static const String colorClubScreen = '/color-club-screen';
  static const String profileScreen = '/profile-screen';


  //company






  static final routes = [

    GetPage(
      name: splashScreen,
      page: () {
        return const SplashScreen();
      },
      transition: Transition.fadeIn,
    ),


  ];
}
