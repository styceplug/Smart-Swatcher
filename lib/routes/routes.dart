import 'package:get/get.dart';
import 'package:smart_swatcher/screens/auth/stylist/create_stylist_account_screen.dart';
import 'package:smart_swatcher/screens/auth/stylist/licence_upload_screen.dart';
import 'package:smart_swatcher/screens/auth/stylist/pro_registration_screen.dart';
import 'package:smart_swatcher/screens/auth/stylist/stylist_login_screen.dart';
import 'package:smart_swatcher/screens/auth/stylist/update_password_screen.dart';
import 'package:smart_swatcher/screens/formulator/formulation/add_description.dart';
import 'package:smart_swatcher/screens/formulator/formulation/client_details.dart';
import 'package:smart_swatcher/screens/formulator/formulation/grey_exceeds.dart';
import 'package:smart_swatcher/screens/formulator/formulation_or_correction.dart';
import 'package:smart_swatcher/screens/home/home_screen.dart';
import 'package:smart_swatcher/screens/reference/hair_formulator_guide.dart';
import 'package:smart_swatcher/screens/reference/mixing_ratio_guide.dart';
import 'package:smart_swatcher/screens/reference/reference_hub.dart';
import 'package:smart_swatcher/screens/reference/trouble_shooting_guide.dart';
import 'package:smart_swatcher/screens/settings/blocked_accounts_screen.dart';
import 'package:smart_swatcher/screens/settings/bookmarked_screen.dart';
import 'package:smart_swatcher/screens/settings/change_password_screen.dart';
import 'package:smart_swatcher/screens/settings/faq_screen.dart';
import 'package:smart_swatcher/screens/settings/privacy_policy_screen.dart';
import 'package:smart_swatcher/screens/settings/terms_condition_screen.dart';
import 'package:smart_swatcher/screens/space/create_space.dart';
import 'package:smart_swatcher/screens/space/share_space.dart';
import 'package:smart_swatcher/screens/notification/notification_screen.dart';
import 'package:smart_swatcher/screens/notification/notification_settings.dart';
import 'package:smart_swatcher/screens/posts/comments_screen.dart';
import 'package:smart_swatcher/screens/posts/create_post_screen.dart';
import 'package:smart_swatcher/screens/posts/post_drafts_screen.dart';
import 'package:smart_swatcher/screens/settings/edit_profile.dart';
import 'package:smart_swatcher/screens/splash/stylist/onboarding_screen.dart';
import 'package:smart_swatcher/screens/subscription/plan_overview.dart';
import 'package:smart_swatcher/screens/subscription/subscription_plans_screen.dart';

import '../screens/auth/stylist/experience_screen.dart';
import '../screens/auth/stylist/forgot_password_screen.dart';
import '../screens/auth/stylist/set_username_screen.dart';
import '../screens/formulator/create_folder.dart';
import '../screens/formulator/folder_screen.dart';
import '../screens/formulator/formulation/choose_nbl.dart';
import '../screens/formulator/formulation/formulation_preview.dart';
import '../screens/formulator/formulation/grey_coverage.dart';
import '../screens/formulator/formulation/select_desire_level.dart';
import '../screens/formulator/formulation/upload_hair.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  //general
  static const String splashScreen = '/splash-screen';
  static const String onboardingScreen = '/onboarding-screen';
  static const String updateAppScreen = '/update-app-screen';
  static const String noInternetScreen = '/no-internet-screen';
  static const String notificationScreen = '/notification-screen';
  static const String notificationSettingsScreen = '/notification-settings-screen';
  static const String commentsScreen = '/comments-screen';


  //auth
  static const String createStylistAccountScreen = '/create-stylist-account-screen';
  static const String setStylistUsernameScreen = '/set-stylist-username-screen';
  static const String experienceScreen = '/experience-screen';
  static const String licenceUploadScreen = '/licence-upload-screen';
  static const String proRegistrationScreen = '/pro-registration-screen';
  static const String updatePasswordScreen = '/update-password-screen';
  static const String forgotPasswordScreen = '/forgot-password-screen';
  static const String stylistLoginScreen = '/stylist-login-screen';
  static const String editProfileScreen = '/edit-profile-screen';



  //stylist
  static const String homeScreen = '/home-screen';
  static const String studioScreen = '/studio-screen';
  static const String formulatorScreen = '/formulator-screen';
  static const String colorClubScreen = '/color-club-screen';
  static const String profileScreen = '/profile-screen';
  static const String settingsScreen = '/settings-screen';
  static const String shareSpaceScreen = '/share-space-screen';
  static const String createSpaceScreen = '/create-space-screen';
  static const String createPost = '/create-post';
  static const String postDraftsScreen = '/post-draft-screen';
  static const String subscriptionPlansScreen = '/subscription-plans-screen';
  static const String subscriptionPlanOverviewScreen = '/subscription-plan-overview-screen';
  static const String referenceHubScreen = '/reference-hub-screen';
  static const String hairFormulatorGuide = '/hair-formulator-guide';
  static const String mixingRatioGuide = '/mixing-ratio-guide';
  static const String troubleShootingGuide = '/trouble-shooting-guide';



  static const String blockedAccountScreen = '/blocked-accounts-screen';
  static const String changePasswordScreen = '/change-password-screen';
  static const String faqScreen = '/faq-screen';
  static const String privacyPolicyScreen = '/privacy-policy-screen';
  static const String termsConditionScreen = '/terms-condition-screen';
  static const String bookmarkedScreen = '/bookmarked-screen';




  static const String createFolder = '/create-folder';
  static const String folderScreen = '/folder-screen';
  static const String formulationOrCorrection = '/formulation-or-correction';
  static const String addDescription = '/add-description';
  static const String chooseNbl = '/choose-nbl';
  static const String clientDetails = '/client-details';
  static const String formulationPreview = '/formulation-preview';
  static const String greyCoverage = '/grey-coverage';
  static const String greyExceeds = '/grey-exceeds';
  static const String selectDesireLevel = '/select-desire-level';
  static const String uploadHair = '/upload-hair';











  //company






  static final routes = [

    GetPage(
      name: splashScreen,
      page: () {
        return const SplashScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createStylistAccountScreen,
      page: () {
        return const CreateStylistAccountScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: setStylistUsernameScreen,
      page: () {
        return const SetUsernameScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: homeScreen,
      page: () {
        return const HomeScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: experienceScreen,
      page: () {
        return const ExperienceScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: licenceUploadScreen,
      page: () {
        return const LicenceUploadScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: proRegistrationScreen,
      page: () {
        return const ProRegistrationScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: updatePasswordScreen,
      page: () {
        return const UpdatePasswordScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPasswordScreen,
      page: () {
        return const ForgotPasswordScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: stylistLoginScreen,
      page: () {
        return const StylistLoginScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settingsScreen,
      page: () {
        return const SettingsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notificationScreen,
      page: () {
        return const NotificationScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notificationSettingsScreen,
      page: () {
        return const NotificationSettings();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboardingScreen,
      page: () {
        return const OnboardingScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createSpaceScreen,
      page: () {
        return const CreateSpaceScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: shareSpaceScreen,
      page: () {
        return const ShareSpaceScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: commentsScreen,
      page: () {
        return const CommentsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createPost,
      page: () {
        return const CreatePostScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: postDraftsScreen,
      page: () {
        return const PostDraftsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: editProfileScreen,
      page: () {
        return const EditProfileScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: subscriptionPlansScreen,
      page: () {
        return const SubscriptionPlansScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: referenceHubScreen,
      page: () {
        return const ReferenceHub();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: subscriptionPlanOverviewScreen,
      page: () {
        return const PlanOverviewScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: hairFormulatorGuide,
      page: () {
        return const HairFormulatorGuide();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: mixingRatioGuide,
      page: () {
        return const MixingRatioGuide();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: troubleShootingGuide,
      page: () {
        return const TroubleShootingGuide();
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: blockedAccountScreen,
      page: () {
        return const BlockedAccountsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: bookmarkedScreen,
      page: () {
        return const BookmarkedScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: changePasswordScreen,
      page: () {
        return const ChangePasswordScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: faqScreen,
      page: () {
        return const FaqScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: privacyPolicyScreen,
      page: () {
        return const PrivacyPolicyScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: termsConditionScreen,
      page: () {
        return const TermsConditionScreen();
      },
      transition: Transition.fadeIn,
    ),


    GetPage(
      name: createFolder,
      page: () {
        return const CreateFolderScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: folderScreen,
      page: () {
        return const FolderScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: formulationOrCorrection,
      page: () {
        return const FormulationOrCorrectionScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addDescription,
      page: () {
        return const AddDescription();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: chooseNbl,
      page: () {
        return const ChooseNbl();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clientDetails,
      page: () {
        return const ClientDetails();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: formulationPreview,
      page: () {
        return const FormulationPreview();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: greyCoverage,
      page: () {
        return const GreyCoverage();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: greyExceeds,
      page: () {
        return const GreyExceeds();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: selectDesireLevel,
      page: () {
        return const SelectDesireLevel();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: uploadHair,
      page: () {
        return const UploadHair();
      },
      transition: Transition.fadeIn,
    ),






  ];
}
