import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../../routes/routes.dart';
import '../../../widgets/advert_card.dart';
import '../../../widgets/reference_card.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AuthController authController = Get.find<AuthController>();

  final List<AdvertItem> adverts = [
    AdvertItem(
      title: 'Hair Has Layers',
      subtitle: 'Hair dye passes the cuticle to reach the cortex...',
      imageAsset: 'assets/images/brush.png',
    ),
    AdvertItem(
      title: 'Shiny Hair Secrets',
      subtitle: 'Discover products that make your hair glow naturally.',
      imageAsset: 'assets/images/brush.png',
      backgroundColor: Color(0XFFE5F8FD),
      gradientColors: [Color(0XFF57C3E9), Color(0XFF1D75BC)],
    ),
    AdvertItem(
      title: 'Pro Styling Tools',
      subtitle: 'Get tools trusted by experts worldwide.',
      imageAsset: 'assets/images/brush.png',
    ),
  ];

  final List<Map<String, String>> references = [
    {
      "time": "02 HR AGO",
      "title": "From Level to Lift: Understanding Hair Color Changes",
    },
    {
      "time": "05 HR AGO",
      "title": "10 Tips for Maintaining Your Hair After Dye",
    },
    {"time": "1 DAY AGO", "title": "Best Tools Every Stylist Should Own"},
  ];

  // AuthController authController = Get.find<AuthController>();
  // late final profile = authController.stylistProfile;



  @override
  void initState() {
    // authController.getProfile();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   authController.getProfile();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return  SingleChildScrollView(
        child: Container(
          width: Dimensions.screenWidth,
          padding: EdgeInsets.fromLTRB(
            0,
            Dimensions.width20,
            0,
            Dimensions.height20 + kBottomNavigationBarHeight,
          ),
          child: Column(
            children: [
              CustomAppbar(
                centerTitle: false,
                customTitle: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Afternoon ${authController.stylistProfile.value?.fullName?.capitalize}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: Dimensions.font18),
                        ),
                        SizedBox(height: Dimensions.height5),
                        Text(
                          'Level your hair color today!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: Dimensions.font14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey4,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.notificationScreen);
                      },
                      child: Container(
                        height: Dimensions.height40,
                        width: Dimensions.width40,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            scale: 2,

                            image: AssetImage(
                              AppConstants.getPngAsset('notification-icon'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height20),
              //advert card
              AdvertCarousel(adverts: adverts),
              SizedBox(height: Dimensions.height50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Formulations',
                          style: TextStyle(
                            fontSize: Dimensions.font20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.grey4),
                      ],
                    ),
                    SizedBox(height: Dimensions.height40),
                    Text(
                      'No formulation yet, Add a photo',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey4,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add a Photo',
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary5,
                            fontFamily: 'Poppins',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: Dimensions.width5),
                        Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.primary5,
                          size: Dimensions.iconSize20,
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height40),
                    Row(
                      children: [
                        Text(
                          'Quick Reference',
                          style: TextStyle(
                            fontSize: Dimensions.font20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.grey4),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    //reference card
                    Container(
                      height: Dimensions.height10 * 25,
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        itemCount: references.length,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.zero,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = references[index];
                          return ReferenceCard(
                            timeAgo: item["time"]!,
                            title: item["title"]!,
                            // optionally pass imageAsset: 'assets/images/hair.png',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
