class AppConstants {

  // basic
  static const String APP_NAME = 'SMART SWATCHER';


  static const String BASE_URL = 'https://api.fyndr.ng/api';

  //TOKEN
  static const authToken = 'authToken';
  static const header = 'header';
  static const String lastVersionCheck = 'lastVersionCheck';

  //update
  static const String VERSION_CHECK = '';







  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';



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
