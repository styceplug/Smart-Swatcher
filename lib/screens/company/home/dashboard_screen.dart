import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

import '../../../routes/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        customTitle: Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Text(
            'Welcome, L\'Oréal Paris',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        actionIcon: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width5,
            vertical: Dimensions.height5,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grey3),
          ),
          child: Icon(
            Icons.notifications_active_outlined,
            color: AppColors.grey5,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey3),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Row(
                      children: [
                        Text('1 Week'),
                        SizedBox(width: Dimensions.width5),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey3),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Text('21 Jul - 22 Aug'),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.viewsScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary1,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.primary2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Views',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '16,912',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_circle,
                                  color: AppColors.primary5,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text('+33%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.engagementScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary1,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.primary2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Engagement',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '7,912',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_circle,
                                  color: AppColors.primary5,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text('+33%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.grey3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formulas usage',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '430',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_circle_fill,
                                  color: AppColors.primary3,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text('+33%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.savesScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.grey3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '1,530',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_down_circle_fill,
                                  color: AppColors.grey4,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text(
                                  '-33%',
                                  style: TextStyle(color: AppColors.grey5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.downloadsScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.grey3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Downloads',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '1,430',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_circle_fill,
                                  color: AppColors.primary3,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text('+33%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.eventsScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(color: AppColors.grey3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Events',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              '15',
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_down_circle_fill,
                                  color: AppColors.grey4,
                                  size: Dimensions.iconSize16,
                                ),
                                SizedBox(width: Dimensions.width5),
                                Text(
                                  '-5%',
                                  style: TextStyle(color: AppColors.grey5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.followersScreen);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height20,
                  ),
                  width: Dimensions.screenWidth / 2.3,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    border: Border.all(color: AppColors.grey3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: Dimensions.font13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),
                      Text(
                        '230',
                        style: TextStyle(
                          fontSize: Dimensions.font25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),

                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_up_circle_fill,
                            color: AppColors.primary3,
                            size: Dimensions.iconSize16,
                          ),
                          SizedBox(width: Dimensions.width5),
                          Text('+33%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height100),
            ],
          ),
        ),
      ),
    );
  }
}
