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








  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';
  static const String STYLIST_KEY = 'stylist-key';



  static const String STYLIST_SIGN_UP = '/api/stylists/signup';
  static const String PATCH_STYLIST_PROFILE = '/api/stylists/me';
  static const String LOGIN_STYLIST = '/api/stylists/signin';
  static const String VERIFY_OTP = '/api/otp/verify';
  static const String RESEND_OTP = '/api/otp/resend';
  static const String CHECK_USERNAME = '/api/usernames/availability';
  static const String STYLIST_PROFILE_URI = '/api/stylists/me';


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
