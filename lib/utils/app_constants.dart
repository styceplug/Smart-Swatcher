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
  static const String COMPANY_DASHBOARD_COACH_SHOWN =
      'company-dashboard-coach-shown';



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
  static const String GET_CONNECTIONS = '/api/connections';
  static const String REQUEST_CONNECTION = '/api/connections';
  static String ACCEPT_CONNECTION(String targetId) => '/api/connections/$targetId/accept';
  static String DECLINE_CONNECTION(String targetId) => '/api/connections/$targetId/decline';
  static String DELETE_CONNECTION(String targetId) => '/api/connections/$targetId';
  static const String BLOCKS_URI = '/api/blocks';

  static String GET_PUBLIC_PROFILE(String profileId) => '/api/profiles/$profileId';
  static const String DISPLAY_MEDIA_URI = '/api/display-media';
  static const String TIPS_URI = '/api/tips';
  static const String PRODUCTS_URI = '/api/products';

  static const String GET_CONVERSATIONS = '/api/conversations';
  static const String GET_PRIVATE_CONVERSATIONS = '/api/conversations/private';
  static const String GET_GROUP_CONVERSATIONS = '/api/conversations/groups';
  static const String CREATE_PRIVATE_CONVERSATION = '/api/conversations/private';
  static const String CREATE_PRIVATE_CONVERSATION_WITH_MESSAGE =
      '/api/conversations/private/with-message';
  static const String CREATE_GROUP_CONVERSATION = '/api/conversations/groups';
  static String GET_CONVERSATION_MESSAGES(String conversationId) =>
      '/api/conversations/$conversationId/messages';
  static String SEND_CONVERSATION_MESSAGE(String conversationId) =>
      '/api/conversations/$conversationId/messages';
  static String DELETE_CONVERSATION(String conversationId) =>
      '/api/conversations/$conversationId';


  static const String CREATE_EVENT = '/api/events';
  static const String GET_EVENT = '/api/events';
  static const String GET_RECOMMENDED_EVENT = '/api/events/recommended';
  static String PATCH_EVENT(String eventId) => '/api/events/$eventId';
  static String GET_SINGLE_EVENT(String eventId) => '/api/events/$eventId';
  static String SUBSCRIBE_EVENT(String eventId) => '/api/events/$eventId/subscribe';
  static String UNSUBSCRIBE_EVENT(String eventId) => '/api/events/$eventId/subscribe';
  static String START_EVENT(String eventId) => '/api/events/$eventId/start';
  static String JOIN_EVENT(String eventId) => '/api/events/$eventId/join';
  static String LEAVE_EVENT(String eventId) => '/api/events/$eventId/leave';
  static String END_EVENT(String eventId) => '/api/events/$eventId/end';



  static const String GET_NOTIFICATIONS = '/api/notifications';
  static String MARK_NOTIFICATION_READ(String notificationId) =>
      '/api/notifications/$notificationId/read';
  static const String COMPANY_ANALYTICS_OVERVIEW =
      '/api/company-analytics/overview';
  static const String COMPANY_ANALYTICS_BREAKDOWN =
      '/api/company-analytics/breakdown';




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
