import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/custom_appbar.dart';
import '../../../../widgets/trend_line_chart.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final points = [
    4.5,
    6.2,
    5.1,
    4.8,
    -1.2,
    6.8,
    5.4,
    6.0,
    -3.6,
    6.9,
    5.2,
    6.1,
    -2.8,
    5.0,
  ];
  late final dates = List.generate(
    points.length,
    (i) => DateTime(2026, 7, 19 + i),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Followers',
        leadingIcon: BackButton(),
        actionIcon: Icon(Iconsax.info_circle, color: AppColors.grey5),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10,
                        vertical: Dimensions.height5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey3),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
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
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Text('21 Jul - 22 Aug'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3,995 followers',
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
                        Text(
                          '+33% vs Last Week',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth',
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                        Text('9', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Follows',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                        Text('34', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Unfollows',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                        Text('24', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Followers Details',
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                            border: Border.all(color: AppColors.grey5),
                            color: AppColors.black1,
                          ),
                          child: Text(
                            'Overall',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                        SizedBox(width: Dimensions.width20),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                            border: Border.all(color: AppColors.grey5),
                          ),
                          child: Text('Follows'),
                        ),
                        SizedBox(width: Dimensions.width20),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                            border: Border.all(color: AppColors.grey5),
                          ),
                          child: Text('Unfollows'),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    TrendLineChart(
                      points: points,
                      dates: dates,
                      selectedIndex: 7, // Jul 26
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Engaged stylist',
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.grey4,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              'CurlCraze92',
                              style: TextStyle(color: AppColors.grey5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.grey4,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              'CurlCraze92',
                              style: TextStyle(color: AppColors.grey5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                  ],
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
