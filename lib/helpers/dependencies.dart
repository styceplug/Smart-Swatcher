
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../controllers/app_controller.dart';
import '../data/api/api_client.dart';
import '../data/repo/app_repo.dart';
import '../utils/app_constants.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.put(sharedPreferences);

  //api clients
  Get.lazyPut(
    () => ApiClient(
      appBaseUrl: AppConstants.BASE_URL,
      sharedPreferences: Get.find(),
    ),
  );



  // repos
  Get.lazyPut(() => AppRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  // Get.lazyPut(() => VersionRepo(apiClient: Get.find()));
  // Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()),





  //controllers

  Get.lazyPut(() => AppController(appRepo: Get.find()));
  // Get.lazyPut(() => VersionController(versionRepo: Get.find()));
  // Get.lazyPut(() => GlobalLoaderController());
  // Get.lazyPut(() => AuthController(authRepo: Get.find()));


}
