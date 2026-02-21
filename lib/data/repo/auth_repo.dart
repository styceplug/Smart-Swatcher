import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_swatcher/data/api/api_client.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

import '../../models/stylist_model.dart';

class AuthRepo extends GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});




  Future<Response> registerCompanyMultipart(Map<String, dynamic> body) async {
    final File? imageFile = body['profileImageFile'];

    final uri = Uri.parse('${apiClient.baseUrl}/api/companies/signup');
    final request = http.MultipartRequest('POST', uri);

    // ✅ Accept json back
    request.headers['Accept'] = 'application/json';

    // ✅ Add auth header if you have it (usually empty for signup but safe)
    final headers = Map<String, String>.from(apiClient.mainHeadersForMultipart);
    request.headers.addAll(headers);

    // ✅ Clean up bad characters (your state had a trailing apostrophe)
    String clean(dynamic v) => v.toString().trim().replaceAll("'", "");

    // ---- REQUIRED (make sure backend sees them) ----
    final email = clean(body['email'] ?? '');
    final password = clean(body['password'] ?? '');
    final phoneNumber = clean(body['phoneNumber'] ?? body['phone'] ?? '');

    // Force what the error message calls it: "local sign up"
    // Some backends treat "email" as provider but actually expect "local"
    request.fields['authProvider'] = 'local';

    // Add these in multiple forms so backend can pick what it expects
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['phoneNumber'] = phoneNumber; // swagger style
    request.fields['phone'] = phoneNumber;       // common backend style

    // ---- Add rest of fields (strings) ----
    void addField(String key, dynamic value) {
      if (value == null) return;
      final val = clean(value);
      if (val.isEmpty) return;
      request.fields[key] = val;
    }

    addField('companyName', body['companyName']);
    addField('username', body['username']);
    addField('country', body['country']);
    addField('state', body['state']);
    addField('role', body['role']);
    addField('missionStatement', body['missionStatement']);

    // ---- Attach file ----
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage', // ✅ if backend expects another key, change it here
          imageFile.path,
          filename: p.basename(imageFile.path),
        ),
      );
    }

    // Send with your existing helper
    final res = await apiClient.postMultipartData('/api/companies/signup', request);

    // If your helper returns body as string, decode it
    if (res.body is String) {
      try {
        return Response(
          statusCode: res.statusCode,
          body: jsonDecode(res.body),
          statusText: res.statusText,
        );
      } catch (_) {}
    }

    return res;
  }

  Future<Response> registerCompany(Map<String, dynamic> body) async { return await apiClient.postData('/api/companies/signup', body); }

  Future<void> clearSharedData() async {
    await sharedPreferences.remove(AppConstants.authToken);
    await sharedPreferences.clear();
  }

  Future<Response> updateProfilePicture(File file) async {
    final uri = Uri.parse('${AppConstants.BASE_URL}/api/media/profile-picture');
    var request = http.MultipartRequest('POST', uri);

    var multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    return await apiClient.postMultipartData('/api/media/profile-picture', request);
  }

  Future<void> saveStylistProfile(StylistModel stylistProfile) async {
    Map<String, dynamic> stylistJson = stylistProfile.toJson();
    await sharedPreferences.setString(
      AppConstants.STYLIST_KEY,
      jsonEncode(stylistJson),
    );
  }

  Future<StylistModel?> loadSTypeListerProfile() async {
    String? stylistJson = await sharedPreferences.getString(
      AppConstants.STYLIST_KEY,
    );
    if (stylistJson == null) return null;
    return StylistModel.fromJson(jsonDecode(stylistJson));
  }

  Future<Response> getStylistProfile() async {
    return await apiClient.getData(AppConstants.STYLIST_PROFILE_URI);
  }

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
    return await apiClient.getData(
      '${AppConstants.CHECK_USERNAME}?username=$username',
    );
  }
}
