import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/app_loading_overlay.dart';
import 'package:smart_swatcher/widgets/country_state_dropdown.dart';

import 'helpers/dependencies.dart' as version_service;
import 'helpers/dependencies.dart' as dep;
import 'helpers/global_loader_controller.dart';
import 'helpers/push_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,

      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );*/

  await NotificationService().initialize();
  await version_service.init();
  await dep.init();
  await CountryService().preload();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.APP_NAME,
      theme: _buildTheme(),
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.splashScreen,
      builder: (context, child) {
        final loaderController = Get.find<GlobalLoaderController>();
        final mediaQuery = MediaQuery.of(context);
        final baseScale = mediaQuery.textScaler.scale(1).clamp(0.95, 1.14);
        final adjustedMediaQuery = mediaQuery.copyWith(
          textScaler: TextScaler.linear(baseScale),
          boldText: false,
        );

        Dimensions.initFromMediaQuery(adjustedMediaQuery);

        return MediaQuery(
          data: adjustedMediaQuery,
          child: Obx(() {
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                if (loaderController.isLoading.value)
                  const Positioned.fill(child: AppLoadingOverlay()),
              ],
            );
          }),
        );
      },
    );
  }
}

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.light(
    primary: AppColors.primary5,
    secondary: AppColors.primary4,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.black1,
    error: AppColors.error,
  );

  final base = ThemeData.light(useMaterial3: false);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgColor,
    colorScheme: colorScheme,
    hintColor: AppColors.grey5,
    dividerColor: AppColors.grey2,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.black1,
      displayColor: AppColors.black1,
      fontFamily: 'Poppins',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.black1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.black1,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primary1.withValues(alpha: 0.24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.grey5,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.grey5,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: AppColors.primary5.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: AppColors.primary5.withValues(alpha: 0.14),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary5, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.error, width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary5,
      selectionColor: AppColors.primary2.withValues(alpha: 0.25),
      selectionHandleColor: AppColors.primary5,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
