class AppConstants {

  // basic
  static const String APP_NAME = 'SMART SWATCHER';


  static const String BASE_URL = 'https://swatcher.thecribbers.ng';

  //TOKEN
  static const authToken = 'authToken';
  static const header = 'header';
  static const String lastVersionCheck = 'lastVersionCheck';

  //update
  static const String VERSION_CHECK = '';



  //POST

  static const String CREATE_POST = '/api/posts';
  static const String UPLOAD_MEDIA = '/api/media/upload';


  //FOLDER
  static const String GET_FOLDERS = '/api/folders';
  static const String CREATE_FOLDERS = '/api/folders';




  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';
  static const String STYLIST_KEY = 'stylist-key';
  static const String COMPANY_KEY = 'company-key';



  static const String STYLIST_SIGN_UP = '/api/stylists/signup';
  static const String PATCH_STYLIST_PROFILE = '/api/stylists/me';
  static const String LOGIN_STYLIST = '/api/stylists/signin';
  static const String LOGIN_COMPANY = '/api/companies/signin';
  static const String VERIFY_OTP = '/api/otp/verify';
  static const String RESEND_OTP = '/api/otp/resend';
  static const String CHECK_USERNAME = '/api/usernames/availability';
  static const String STYLIST_PROFILE_URI = '/api/stylists/me';
  static const String COMPANY_PROFILE_URI = '/api/companies/me';
  static const String GET_RECOMMENDED_PROFILE = '/api/connections/suggestions';
  static const String REQUEST_CONNECTION = '/api/connections';
  static String ACCEPT_CONNECTION(String targetId) => '/api/connections/$targetId/accept';


  static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }
  static String getGifAsset(String image) {
    return 'assets/gifs/$image.gif';
  }
  static String getBadgeAsset(String image) {
    return 'assets/badges/$image.png';
  }

  static String getBaseAsset(String image) {
    return 'assets/base/$image.png';
  }



}

class MediaUrlHelper {
  static const String baseUrl = 'https://swatcher.thecribbers.ng';

  static String? resolve(String? url) {
    if (url == null) return null;

    final value = url.trim();
    if (value.isEmpty || value == 'null') return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }
}

