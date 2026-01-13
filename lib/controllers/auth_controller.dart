import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/helpers/global_loader_controller.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

import '../data/repo/auth_repo.dart';
import '../models/stylist_model.dart';
import '../routes/routes.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  StylistModel _tempUserData = StylistModel();
  Rx<StylistModel?> stylistProfile = Rx<StylistModel?>(null);
  var selectedImage = Rxn<File>();
  RxInt usernameCheckStatus = 0.obs;
  RxString usernameCheckMessage = "".obs;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController stateController;
  // late TextEditingController bioController;
  late TextEditingController licenseController;
  late TextEditingController salonController;
  late TextEditingController certTypeController;
  late TextEditingController yearsController;
  late TextEditingController licenseCountryController;

  @override
  void onInit() {
    _initControllers();
    loadStylistProfile();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _initControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    phoneController = TextEditingController();
    countryController = TextEditingController();
    stateController = TextEditingController();
    licenseController = TextEditingController();
    salonController = TextEditingController();
    certTypeController = TextEditingController();
    yearsController = TextEditingController();
    licenseCountryController = TextEditingController();
  }

  void _fillUserData() {
    var user = stylistProfile
            .value;

    nameController = TextEditingController(text: user?.fullName ?? '');
    emailController = TextEditingController(
      text: user?.email ?? '',
    );
    usernameController = TextEditingController(text: user?.username ?? '');
    phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    countryController = TextEditingController(text: user?.country ?? '');
    stateController = TextEditingController(text: user?.state ?? '');

    licenseController = TextEditingController(text: user?.licenseNumber ?? '');
    salonController = TextEditingController(text: user?.saloonName ?? '');
    certTypeController = TextEditingController(
      text: user?.certificationType ?? '',
    );
    yearsController = TextEditingController(
      text: user?.yearsOfExperience?.toString() ?? '',
    );
    licenseCountryController = TextEditingController(
      text: user?.licenseCountry ?? '',
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      Get.back();
    }
  }

  void removeImage() {
    selectedImage.value = null;
    Get.back();
  }

  Future<void> saveChanges() async {
    loader.showLoader();
    try {
      if (selectedImage.value != null) {
        Response imgResponse = await authRepo.updateProfilePicture(
          selectedImage.value!,
        );
        if (imgResponse.statusCode != 200 && imgResponse.statusCode != 201) {
          CustomSnackBar.failure(message: "Failed to upload image");
          loader.hideLoader();
          update();
          return;
        }
      }

      Map<String, dynamic> body = {
        "fullName": nameController.text.trim(),
        "username": usernameController.text.trim(),
        "phone": phoneController.text.trim(),
        "country": countryController.text.trim(),
        "state": stateController.text.trim(),
        "licenseNumber": licenseController.text.trim(),
        "salonName": salonController.text.trim(),
        "certificationType": certTypeController.text.trim(),
        "licensingCountry": licenseCountryController.text.trim(),
      };

      // Handle integer parsing for years
      if (yearsController.text.isNotEmpty) {
        body["yearsOfExperience"] = int.tryParse(yearsController.text) ?? 0;
      }

      // C. Update Text Data
      Response response = await authRepo.updateProfile(body);

      if (response.statusCode == 200) {
        await getProfile();
        Get.back(); // Close screen
        CustomSnackBar.success(message: "Profile updated successfully");
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? "Update failed",
        );
      }
    } catch (e) {
      print("Update Error: $e");
      CustomSnackBar.failure(message: "An error occurred");
    } finally {
      loader.hideLoader();
    }
  }

  Future<void> logout() async {
    await authRepo.clearSharedData();
    stylistProfile.value = null;
    Get.offAllNamed(AppRoutes.splashScreen);
    update();
  }

  Future<void> loadStylistProfile() async {
    StylistModel? stylistProfile = await authRepo.loadSTypeListerProfile();
    if (stylistProfile != null) {
      this.stylistProfile.value = stylistProfile;
    }
    getProfile();
  }

  Future<void> saveStylistProfile(StylistModel stylistProfile) async {
    await authRepo.saveStylistProfile(stylistProfile);
    this.stylistProfile.value = stylistProfile;
    _fillUserData();
    update();
  }

  Future<void> getProfile() async {
    loader.showLoader();
    update();

    try {
      Response response = await authRepo.getStylistProfile();

      if (response.statusCode == 200) {
        await saveStylistProfile(
          StylistModel.fromJson(response.body['stylist']),
        );
        print("Profile loaded for: ${stylistProfile.value?.fullName}");
      } else {
        // Get.snackbar("Error", "Failed to load profile");
      }
    } catch (e) {
      print("Profile fetch error: $e");
    } finally {
      loader.hideLoader();
      update();
    }
  }

  String _getErrorMessage(Response response) {
    if (response.body != null && response.body is Map) {
      if (response.body['error'] != null) {
        return response.body['error'].toString();
      }
      if (response.body['message'] != null) {
        return response.body['message'].toString();
      }
    }
    return response.statusText ?? "An unknown error occurred";
  }

  Future<void> checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      usernameCheckStatus.value = 0;
      usernameCheckMessage.value = "";
      return;
    }

    usernameCheckStatus.value = 1;

    try {
      Response response = await authRepo.checkUsernameAvailability(username);

      if (response.statusCode == 200) {
        bool isAvailable = response.body['available'] ?? false;

        if (isAvailable) {
          usernameCheckStatus.value = 2;
          usernameCheckMessage.value = "Username is available";
        } else {
          usernameCheckStatus.value = 3;
          usernameCheckMessage.value = "Username is already taken";
        }
      } else {
        usernameCheckStatus.value = 3;
        usernameCheckMessage.value = "Unable to validate username";
      }
    } catch (e) {
      usernameCheckStatus.value = 3;
      usernameCheckMessage.value = "Connection error";
      print(e);
    }
  }

  Future<void> registerStylist(StylistModel initialData) async {
    loader.showLoader();
    update();

    _tempUserData = initialData;

    try {
      Response response = await authRepo.signUp(_tempUserData.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Account Created');
        String token = response.body['token'];
        await authRepo.saveUserToken(token);
      } else {
        Get.snackbar("Error", response.statusText.toString());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> patchStylistData(
    Map<String, dynamic> data, {
    String? nextRoute,
  }) async {
    loader.showLoader();
    update();

    try {
      Response response = await authRepo.updateProfile(data);

      if (response.statusCode == 200) {
        if (nextRoute != null) {
          Get.toNamed(nextRoute);
        } else {
          CustomSnackBar.success(message: "Successfully Updated");
        }
      } else {
        Get.snackbar("Update Failed", _getErrorMessage(response));
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> loginStylist(String email, String password) async {
    loader.showLoader();
    update();

    try {
      Response response = await authRepo.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        String token = response.body['token'];
        await authRepo.saveUserToken(token);

        loader.hideLoader();
        Get.offAllNamed(AppRoutes.homeScreen);
        update();
      } else {
        loader.hideLoader();
        Get.snackbar("Error", response.statusText ?? "Login failed");
      }
    } catch (e) {
      loader.hideLoader();
      Get.snackbar("Error", "An unexpected error occurred");
      print(e);
    }
  }

  Future<void> verifyOtp(String otp) async {
    loader.showLoader();
    update();
    try {
      Response response = await authRepo.verifyOtp({'otp': otp});

      if (response.statusCode == 200) {
        print(response.body);
        CustomSnackBar.success(message: 'Account Verified');
        Get.toNamed(AppRoutes.setStylistUsernameScreen);
      }
    } catch (e) {
      print(e);
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> resendOtp() async {
    loader.showLoader();
    try {
      Response response = await authRepo.resendOtp({});

      if (response.statusCode == 200) {
        print(response.body);
        CustomSnackBar.success(message: 'OTP Sent');
      }
    } catch (e) {
      print(e);
    } finally {
      loader.hideLoader();
      update();
    }
  }
}
