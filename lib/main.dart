import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/app_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/controllers/version_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/app_loading_overlay.dart';
import 'package:smart_swatcher/widgets/country_state_dropdown.dart';

import 'helpers/dependencies.dart' as VersionService;
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
  await VersionService.init();
  await dep.init();
  Get.put(GlobalLoaderController(), permanent: true);
  await CountryService().preload();
  HardwareKeyboard.instance.clearState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Dimensions.init(context);
    return GetBuilder<AppController>(builder: (_){
      return GetBuilder<VersionController>(builder: (_){
        return GetBuilder<PostController>(builder: (_) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.APP_NAME,
            theme: ThemeData(
                fontFamily: 'Poppins',
                scaffoldBackgroundColor: AppColors.bgColor
            ),
            getPages: AppRoutes.routes,
            initialRoute: AppRoutes.splashScreen,
            builder: (context, child) {
              final loaderController = Get.find<GlobalLoaderController>();
              return Obx(() {
                return Stack(
                  children: [
                    child!,
                    if (loaderController.isLoading.value)
                      Positioned.fill(
                        child: const AppLoadingOverlay(),
                      ),
                  ],
                );
              });
            },
          );
        });
      });
    });
  }
}

