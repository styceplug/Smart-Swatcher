import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/app_controller.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

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
  final ClientFolderController folderController =
      Get.find<ClientFolderController>();

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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      folderController.fetchRecentFormulations();
    });
  }

  void _openFormulatorTab() {
    Get.find<AppController>().changeCurrentAppPage(1);
  }

  String _resolveFormulationImage(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    if (path.startsWith('http')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '${AppConstants.BASE_URL}$path';
    }

    return '${AppConstants.BASE_URL}/$path';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    Obx(() {
                      if (folderController.isFetchingRecentFormulations.value &&
                          folderController.recentFormulations.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary5,
                          ),
                        );
                      }

                      if (folderController.recentFormulations.isEmpty) {
                        return Column(
                          children: [
                            Text(
                              'No formulation yet, add a photo',
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: Dimensions.height20),
                            InkWell(
                              onTap: _openFormulatorTab,
                              child: Row(
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
                            ),
                          ],
                        );
                      }

                      return SizedBox(
                        height: Dimensions.height100 * 1.6,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: folderController.recentFormulations.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: Dimensions.width15),
                          itemBuilder: (context, index) {
                            final formulation =
                                folderController.recentFormulations[index];
                            final imageUrl = _resolveFormulationImage(
                              formulation.hasPredictionImage
                                  ? formulation.predictionImageUrl
                                  : formulation.imageUrl,
                            );

                            return GestureDetector(
                              onTap: _openFormulatorTab,
                              child: Container(
                                width: Dimensions.width100 * 1.45,
                                padding: EdgeInsets.all(Dimensions.width13),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radius15,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radius10,
                                        ),
                                        child: imageUrl.isEmpty
                                            ? Container(
                                                color: AppColors.grey2,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: AppColors.grey4,
                                                ),
                                              )
                                            : Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  color: AppColors.grey2,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: AppColors.grey4,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height10),
                                    Text(
                                      'Lvl ${formulation.naturalBaseLevel} to ${formulation.desiredLevel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Dimensions.font14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height5),
                                    Text(
                                      formulation.desiredTone?.trim().isNotEmpty ==
                                              true
                                          ? formulation.desiredTone!
                                          : 'Formulation',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Dimensions.font12,
                                        color: AppColors.grey4,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height5),
                                    Text(
                                      formulation.isPredictionActive
                                          ? 'Generating preview...'
                                          : formulation.predictionImageStatus ==
                                                  'failed'
                                              ? 'Preview failed'
                                              : 'Ready',
                                      style: TextStyle(
                                        fontSize: Dimensions.font12,
                                        color: formulation.isPredictionActive
                                            ? AppColors.primary5
                                            : formulation.predictionImageStatus ==
                                                    'failed'
                                                ? Colors.red
                                                : AppColors.grey4,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
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
                    Column(
                      children: references.map((item) {
                        return ReferenceCard(
                          timeAgo: item["time"]!,
                          title: item["title"]!,
                        );
                      }).toList(),
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
