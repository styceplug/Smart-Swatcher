import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/helpers/global_loader_controller.dart';
import 'package:smart_swatcher/models/company_model.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

import '../data/repo/auth_repo.dart';
import '../models/stylist_model.dart';
import '../routes/routes.dart';

class AuthController extends GetxController {
  // ─── Dependencies ────────────────────────────────────────────────────────────

  final AuthRepo authRepo;
  AuthController({required this.authRepo});

  final GlobalLoaderController _loader = Get.find<GlobalLoaderController>();

  // ─── Reactive State ──────────────────────────────────────────────────────────

  final Rx<StylistModel?> stylistProfile = Rx<StylistModel?>(null);
  final Rx<CompanyModel?> companyProfile = Rx<CompanyModel?>(null);
  final Rxn<File> selectedImage = Rxn<File>();

  /// 0 = idle, 1 = checking, 2 = available, 3 = taken/error
  final RxInt usernameCheckStatus = 0.obs;
  final RxString usernameCheckMessage = ''.obs;

  final RxMap<String, dynamic> companyRegistrationData =
      <String, dynamic>{}.obs;

  // ─── Form Controllers ────────────────────────────────────────────────────────

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController stateController;
  late TextEditingController licenseController;
  late TextEditingController salonController;
  late TextEditingController certTypeController;
  late TextEditingController yearsController;
  late TextEditingController licenseCountryController;

  // ─── Private ─────────────────────────────────────────────────────────────────

  StylistModel _tempUserData = StylistModel();

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initTextControllers();

  }

  // ─── Setup ───────────────────────────────────────────────────────────────────

  void _initTextControllers() {
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

  /// Populate form fields from the currently loaded stylist profile.
  void _fillFormFromProfile() {
    final user = stylistProfile.value;

    nameController.text = user?.fullName ?? '';
    emailController.text = user?.email ?? '';
    usernameController.text = user?.username ?? '';
    phoneController.text = user?.phoneNumber ?? '';
    countryController.text = user?.country ?? '';
    stateController.text = user?.state ?? '';
    licenseController.text = user?.licenseNumber ?? '';
    salonController.text = user?.saloonName ?? '';
    certTypeController.text = user?.certificationType ?? '';
    yearsController.text = user?.yearsOfExperience?.toString() ?? '';
    licenseCountryController.text = user?.licenseCountry ?? '';
  }

  // ─── Profile Loading ─────────────────────────────────────────────────────────

  /// Load cached stylist profile from storage, then refresh from the API.
  Future<void> loadStylistProfile() async {
    final cached = await authRepo.loadStylistProfile();
    if (cached != null) stylistProfile.value = cached;
    await getProfile();
  }

  /// Load cached company profile from storage, then refresh from the API.
  Future<void> loadCompanyProfile() async {
    final cached = await authRepo.loadCompanyProfile();
    if (cached != null) companyProfile.value = cached;
    await getCompanyProfile();
  }

  /// Persist stylist profile to local storage and update reactive state.
  Future<void> saveStylistProfile(StylistModel model) async {
    await authRepo.saveStylistProfile(model);
    stylistProfile.value = model;
    _fillFormFromProfile();
    update();
  }

  /// Persist company profile to local storage and update reactive state.
  Future<void> saveCompanyProfile(CompanyModel model) async {
    await authRepo.saveCompanyProfile(model);
    companyProfile.value = model;
    update();
  }

  // ─── Auth — Registration ──────────────────────────────────────────────────────

  /// Register a new stylist account.
  Future<void> registerStylist(StylistModel initialData) async {
    _loader.showLoader();
    update();

    _tempUserData = initialData;

    try {
      final response = await authRepo.signUp(_tempUserData.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body['token'] as String;
        await authRepo.saveUserToken(token);
      } else {
        Get.snackbar('Error', response.statusText ?? 'Registration failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  /// Register a new company account.
  Future<void> registerCompany() async {
    _loader.showLoader();

    try {
      final data = Map<String, dynamic>.from(companyRegistrationData)
        ..['authProvider'] ??= 'local'
        ..remove('profileImageFile'); // never send the raw File object

      final response = await authRepo.registerCompany(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body['token'];
        if (token != null) await authRepo.saveUserToken(token as String);

        Get.offAllNamed(AppRoutes.companyHomePage);
        CustomSnackBar.success(message: 'Company account created!');
      } else {
        CustomSnackBar.failure(message: _extractErrorMessage(response));
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Registration failed: $e');
    } finally {
      _loader.hideLoader();
    }
  }

  // ─── Auth — Login ─────────────────────────────────────────────────────────────

  /// Log in as a stylist and navigate to the stylist home screen.
  Future<void> loginStylist(String email, String password) async {
    _loader.showLoader();
    update();

    try {
      final response = await authRepo.loginStylist({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        await authRepo.saveUserToken(response.body['token'] as String);
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        Get.snackbar('Error', response.statusText ?? 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      debugPrint('loginStylist error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  /// Log in as a company and navigate to the company home screen.
  Future<void> loginCompany(String email, String password) async {
    _loader.showLoader();
    update();

    try {
      final response = await authRepo.loginCompany({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        await authRepo.saveUserToken(response.body['token'] as String);
        Get.offAllNamed(AppRoutes.companyHomePage);
      } else {
        Get.snackbar('Error', response.statusText ?? 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      debugPrint('loginCompany error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  // ─── Auth — OTP ───────────────────────────────────────────────────────────────

  Future<void> verifyOtp(String otp) async {
    _loader.showLoader();
    update();

    try {
      final response = await authRepo.verifyOtp({'otp': otp});

      if (response.statusCode == 200) {
        CustomSnackBar.success(message: 'Account Verified');
        Get.toNamed(AppRoutes.setStylistUsernameScreen);
      }
    } catch (e) {
      debugPrint('verifyOtp error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  Future<void> resendOtp() async {
    _loader.showLoader();

    try {
      final response = await authRepo.resendOtp({});
      if (response.statusCode == 200) {
        CustomSnackBar.success(message: 'OTP Sent');
      }
    } catch (e) {
      debugPrint('resendOtp error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  // ─── Profile — API Calls ──────────────────────────────────────────────────────

  /// Fetch the latest stylist profile from the server.
  Future<void> getProfile() async {
    // _loader.showLoader();
    update();
    try {
      final response = await authRepo.getStylistProfile();
      if (response.statusCode == 200) {
        final model = StylistModel.fromJson(response.body['stylist']);
        await saveStylistProfile(model);
      } else {
        stylistProfile.value = null; // 401 or any error → clear
      }
    } catch (e) {
      stylistProfile.value = null;
      debugPrint('getProfile error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  /// Fetch the latest company profile from the server.
  Future<void> getCompanyProfile() async {
    // _loader.showLoader();
    update();
    try {
      final response = await authRepo.getCompanyProfile();
      if (response.statusCode == 200) {
        final model = CompanyModel.fromJson(response.body['company']);
        await saveCompanyProfile(model);
      } else {
        companyProfile.value = null; // 401 or any error → clear
      }
    } catch (e) {
      companyProfile.value = null;
      debugPrint('getCompanyProfile error: $e');
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  // ─── Profile — Updates ────────────────────────────────────────────────────────

  /// Save all pending form changes (image + text data) to the server.
  Future<void> saveChanges() async {
    _loader.showLoader();

    try {
      // 1. Upload new profile picture if one was selected.
      if (selectedImage.value != null) {
        final imgResponse =
        await authRepo.updateProfilePicture(selectedImage.value!);

        if (imgResponse.statusCode != 200 && imgResponse.statusCode != 201) {
          CustomSnackBar.failure(message: 'Failed to upload image');
          return;
        }
      }

      // 2. Build the update payload from form fields.
      final body = <String, dynamic>{
        'fullName': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'country': countryController.text.trim(),
        'state': stateController.text.trim(),
        'licenseNumber': licenseController.text.trim(),
        'salonName': salonController.text.trim(),
        'certificationType': certTypeController.text.trim(),
        'licensingCountry': licenseCountryController.text.trim(),
      };

      final years = int.tryParse(yearsController.text);
      if (years != null) body['yearsOfExperience'] = years;

      // 3. Submit text data.
      final response = await authRepo.updateProfile(body);

      if (response.statusCode == 200) {
        await getProfile();
        Get.back();
        CustomSnackBar.success(message: 'Profile updated successfully');
      } else {
        CustomSnackBar.failure(
            message: response.body['message'] ?? 'Update failed');
      }
    } catch (e) {
      debugPrint('saveChanges error: $e');
      CustomSnackBar.failure(message: 'An error occurred');
    } finally {
      _loader.hideLoader();
    }
  }

  /// Partially update stylist fields; optionally navigate to [nextRoute].
  Future<void> patchStylistData(
      Map<String, dynamic> data, {
        String? nextRoute,
      }) async {
    _loader.showLoader();
    update();

    try {
      final response = await authRepo.updateProfile(data);

      if (response.statusCode == 200) {
        if (nextRoute != null) {
          Get.toNamed(nextRoute);
        } else {
          CustomSnackBar.success(message: 'Successfully Updated');
        }
      } else {
        Get.snackbar('Update Failed', _extractErrorMessage(response));
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _loader.hideLoader();
      update();
    }
  }

  // ─── Media ───────────────────────────────────────────────────────────────────

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      selectedImage.value = File(picked.path);
      Get.back();
    }
  }

  void removeImage() {
    selectedImage.value = null;
    Get.back();
  }

  /// Upload a media file and return its URL, or null on failure.
  Future<String?> uploadCompanyLogoAndGetUrl(File file) async {
    _loader.showLoader();

    try {
      final response = await authRepo.uploadMedia(file);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic body = response.body;

        // Decode if the body came back as a raw string.
        if (body is String) {
          try {
            body = jsonDecode(body);
          } catch (_) {}
        }

        final url =
            body['url'] ?? body['location'] ?? body['path'] ?? body['data'];

        if (url == null) {
          CustomSnackBar.failure(
              message: 'Upload succeeded but no URL returned');
          return null;
        }

        return url.toString();
      }

      CustomSnackBar.failure(
        message: response.body is Map
            ? (response.body['message'] ?? 'Upload failed')
            : 'Upload failed',
      );
      return null;
    } catch (e) {
      CustomSnackBar.failure(message: 'Logo upload error: $e');
      return null;
    } finally {
      _loader.hideLoader();
    }
  }

  // ─── Username Availability ────────────────────────────────────────────────────

  Future<void> checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      usernameCheckStatus.value = 0;
      usernameCheckMessage.value = '';
      return;
    }

    usernameCheckStatus.value = 1; // checking…

    try {
      final response = await authRepo.checkUsernameAvailability(username);

      if (response.statusCode == 200) {
        final isAvailable = response.body['available'] as bool? ?? false;
        usernameCheckStatus.value = isAvailable ? 2 : 3;
        usernameCheckMessage.value =
        isAvailable ? 'Username is available' : 'Username is already taken';
      } else {
        usernameCheckStatus.value = 3;
        usernameCheckMessage.value = 'Unable to validate username';
      }
    } catch (e) {
      usernameCheckStatus.value = 3;
      usernameCheckMessage.value = 'Connection error';
      debugPrint('checkUsernameAvailability error: $e');
    }
  }

  // ─── Session ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await authRepo.clearSharedData();
    stylistProfile.value = null;
    companyProfile.value = null;
    Get.offAllNamed(AppRoutes.getStarted);
    update();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Extract a human-readable error message from a [Response].
  String _extractErrorMessage(Response response) {
    if (response.body is Map) {
      return (response.body['error'] ?? response.body['message'])?.toString() ??
          response.statusText ??
          'An unknown error occurred';
    }
    return response.statusText ?? 'An unknown error occurred';
  }

  /// Ensure a relative URL/path is made absolute using [baseUrl].
  String _toAbsoluteUrl(String urlOrPath) {
    if (urlOrPath.startsWith('http')) return urlOrPath;
    final base = authRepo.apiClient.baseUrl;
    return urlOrPath.startsWith('/') ? '$base$urlOrPath' : '$base/$urlOrPath';
  }
}
