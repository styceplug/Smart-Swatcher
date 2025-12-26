import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(onPressed: Get.back),
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.bgColor,

          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCESS & RESOURCES',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      leadingIcon: Iconsax.crown_1,
                      title: 'Membership',
                      onTap: () {
                        Get.toNamed(AppRoutes.subscriptionPlansScreen);
                      },
                    ),
                    ProfileOptionTile(
                      leadingIcon: Iconsax.book,
                      title: 'Resources hub',
                      onTap: (){
                        Get.toNamed(AppRoutes.referenceHubScreen);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height50),
              Text(
                'SUPPORT',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      leadingIcon: CupertinoIcons.question_circle,
                      title: 'FAQ',
                      onTap: (){Get.toNamed(AppRoutes.faqScreen);},
                    ),
                    ProfileOptionTile(
                      leadingIcon: Iconsax.call,
                      title: 'Help Center',
                      onTap: (){},
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height50),
              Text(
                'LEGAL',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      leadingIcon: CupertinoIcons.shield,
                      title: 'Privacy Policy',
                      onTap: (){
                        Get.toNamed(AppRoutes.privacyPolicyScreen);
                      },
                    ),
                    ProfileOptionTile(
                      leadingIcon: Icons.description_outlined,
                      title: 'Terms and conditions',
                      onTap: (){
                        Get.toNamed(AppRoutes.termsConditionScreen);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height50),
              Text(
                'ACCOUNT & SECURITY',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      leadingIcon: CupertinoIcons.lock,
                      title: 'Change password',
                      onTap: (){
                        Get.toNamed(AppRoutes.changePasswordScreen);
                      },
                    ),
                    ProfileOptionTile(
                      leadingIcon: Icons.person_add_disabled,
                      title: 'Blocked Accounts',
                      onTap: (){
                        Get.toNamed(AppRoutes.blockedAccountScreen);
                      },
                    ),
                    ProfileOptionTile(
                      leadingIcon: Icons.logout,
                      title: 'Log out',
                      onTap: (){
                        authController.logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileOptionTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final VoidCallback? onTap;

  const ProfileOptionTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          children: [
            Icon(leadingIcon),
            SizedBox(width: Dimensions.width10),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, size: Dimensions.iconSize16),
          ],
        ),
      ),
    );
  }
}
