import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_swatcher/data/api/api_client.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

class AuthRepo extends GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> signUp(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.STYLIST_SIGN_UP, body);
  }

  Future<Response> updateProfile(Map<String, dynamic> body) async {
    return await apiClient.patchData(AppConstants.PATCH_STYLIST_PROFILE, body);
  }

  Future<Response> login(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.LOGIN_STYLIST, body);
  }

  Future<bool> saveUserToken(String token) async {
    apiClient.updateHeader(token);
    return await sharedPreferences.setString(AppConstants.authToken, token);
  }

  Future<Response> verifyOtp(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.VERIFY_OTP, body);
  }

  Future<Response> resendOtp(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.RESEND_OTP, body);
  }

Future<Response> checkUsernameAvailability(String username) async {
  return await apiClient.getData('${AppConstants.CHECK_USERNAME}?username=$username');
}

}
