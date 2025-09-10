
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/widgets/app_loading_overlay.dart';

import 'helpers/dependencies.dart' as VersionService;
import 'helpers/dependencies.dart' as dep;
import 'helpers/global_loader_controller.dart';

Future<void> main() async {

  await VersionService.init();
  await dep.init();
  Get.put(GlobalLoaderController(), permanent: true);

  HardwareKeyboard.instance.clearState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fyndr',

      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.splashScreen,
      builder: (context, child) {
        final loaderController =
        Get.find<GlobalLoaderController>();
        return Obx(() {
          return Stack(
            children: [
              child!,
              if (loaderController.isLoading.value)
                const AppLoadingOverlay(),
            ],
          );
        });
      },
    );
  }
}

