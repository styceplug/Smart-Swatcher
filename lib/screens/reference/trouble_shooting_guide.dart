import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class TroubleShootingGuide extends StatefulWidget {
  const TroubleShootingGuide({super.key});

  @override
  State<TroubleShootingGuide> createState() => _TroubleShootingGuideState();
}

class _TroubleShootingGuideState extends State<TroubleShootingGuide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    fit: BoxFit.cover,
                    AppConstants.getPngAsset('trouble'),
                    height: Dimensions.screenHeight * 0.35,
                    width: Dimensions.screenWidth,
                  ),
                  Positioned(
                    top: Dimensions.height65,
                    right: Dimensions.width20,
                    left: Dimensions.width20,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){
                              Get.back();
                            },
                            child: Image.asset(
                              AppConstants.getPngAsset('back-icon'),
                              height: Dimensions.height40,
                              width: Dimensions.width40,
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                AppConstants.getPngAsset('share-icon'),
                                height: Dimensions.height40,
                                width: Dimensions.width40,
                              ),
                              SizedBox(width: Dimensions.width20),
                              Image.asset(
                                AppConstants.getPngAsset('bookmark-icon'),
                                height: Dimensions.height40,
                                width: Dimensions.width40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: Dimensions.height20,
                    right: Dimensions.width20,
                    left: Dimensions.width20,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Trouble Shooting at a Glance',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Quick Fixes for Common Formulation Issues',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('book-icon'),
                          height: Dimensions.height15,
                          width: Dimensions.width15,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Permanent Hair Color',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Purpose: Lifts and deposits color; long-lasting results.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Developer Needed:  Yes (10–40 volume)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Cream/Liquid color',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '1:1',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Standard permanent color coverage',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'High Lift Color',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '1:2',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Used for maximum lift (up to 4 levels)',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Gray Coverage',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '1:1 with 20 Vol',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: 100% gray coverage; mix neutral base if needed',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height20
                    ),
                    Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('book-icon'),
                          height: Dimensions.height15,
                          width: Dimensions.width15,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Demi-Permanent Hair Color'
                              '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Purpose: Tone, refresh, blend gray without lift.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Developer Needed:  Yes (low volume, typically 5-10 vol)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Liquid/Cream Demi',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '1:2',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Gentle deposit, subtle enhancement',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Acid-Based Formulas',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '1:2 or 1:1.5',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Use manufacturer instructions for pH-sensitive formulations.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height20
                    ),
                    Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('book-icon'),
                          height: Dimensions.height15,
                          width: Dimensions.width15,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Semi-Permanent Hair Color',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Purpose: Direct dye that enhances or refreshes tone; no developer needed.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Developer Needed:  No',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Ready to use Color',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Direct Apply',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: No mixing required',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Custom Toning Shades',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Optional 1:1 \nwith clear',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Mix with clear to dilute intensity',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height20
                    ),
      
                    Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('book-icon'),
                          height: Dimensions.height15,
                          width: Dimensions.width15,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Temporary Hair Color',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Purpose: Short-term color for special effects or maintenance.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Developer Needed:  No',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Spray/Mouse',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Direct Apply',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Washes out with 1 shampoo',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Chalks/Waxes',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Direct Apply',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: Surface-only; fades quickly',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
                    SizedBox(
                        height: Dimensions.height20
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: AppColors.grey2)
                      ),
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.home,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Rinses/Color Shampoo',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(Iconsax.chart,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Standard mixing ratio',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Ready to Use',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
      
      
                              ],
                            ),
                            SizedBox(
                                height: Dimensions.height20
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                                  child: Icon(CupertinoIcons.lightbulb,size: Dimensions.iconSize16,color: AppColors.grey3,),
                                ),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Text(
                                    'Note: May stain porous hair slightly',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
      
      
                              ],
                            ),
                          ]
      
                      ),
                    ),
      
                    SizedBox(
                        height: Dimensions.height20
                    ),
                    Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('book-icon'),
                          height: Dimensions.height15,
                          width: Dimensions.width15,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Pro Tips',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Always follow manufacturer guidelines for specific brands.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Adjust ratio for porosity, tone intensity, or desired longevity.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height10
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                          child: Icon(Icons.circle,size: Dimensions.iconSize16,color: AppColors.grey3,),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'When diluting any direct dye, use conditioner or clear base (not developer).',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    SizedBox(
                        height: Dimensions.height100
                    ),
      
      
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height100)
            ],
          ),
        ),
      ),
    );
  }
}
