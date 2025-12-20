import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

class HairFormulatorGuide extends StatefulWidget {
  const HairFormulatorGuide({super.key});

  @override
  State<HairFormulatorGuide> createState() => _HairFormulatorGuideState();
}

class _HairFormulatorGuideState extends State<HairFormulatorGuide> {
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
                    AppConstants.getPngAsset('formulator-guide'),
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
                          Image.asset(
                            AppConstants.getPngAsset('back-icon'),
                            height: Dimensions.height40,
                            width: Dimensions.width40,
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
                            'Hair Formulator Guide.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Hair color theory fundamentals - reference guide',
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
                          'The Color Wheel Basics',
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
                            'Primary Colors: Red, Blue, Yellow (Cannot be made by mixing other colors).',
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
                            'Secondary Colors: Orange, Green, Violet (Made by mixing two primary colors)',
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
                            'Tertiary Colors: Red-Orange, Yellow-Green, Blue-Violet, etc. (Mix of a primary and adjacent secondary color)',
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
                          'Levels of Hair Color',
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
                            'Hair color is measured on a scale from 1 (black) to 10 (lightest blonde).',
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
                            'Each level represents depth or darkness, not tone.',
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
                            'Important for formulation and predicting lift or deposit results.',
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
                        Expanded(
                          child: Text(
                            'Underlying Pigment (Contributing Pigment)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w600,
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
                            'Natural pigment revealed when lifting/lightening hair color. /nExample/n',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Example',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Text(
                          'Level 4 (Dark Brown) - Red/Red-Orange',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Text(
                          'Level 6 (Dark Blonde) - Orange',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Text(
                          'Level 8 (Light Blonde) - Yellow',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w400,
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
                            'Must be neutralized or enhanced for desired results.',
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
                          'Tones and Their Meanings',
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
                            'Warm: Red, Orange, Yellow (add warmth, richness, or golden effect).',
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
                            'Cool: Blue, Green, Violet (counteract brassiness, add ash or neutral effect).',
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
                            'Neutral: Balanced tone (no visible warmth or coolness).',
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
                          'The Law of Color Neutralization',
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
                            'Complementary Colors: (opposites on the color wheel) cancel each other out:\nBlue neutralises orange\nViolet neutralises yellow\nGreen neutralises red',
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
                            'Used to correct unwanted tones (brassiness, warmth)',
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
                          'Formulation Fundamentals',
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
                            'Determine: \n1. Natural Level (of client’s hair)\n2. Target Level\n3. Tone desired \n4.  Underlying pigment at target level 5. Need to lift, deposit, or both',
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
                            'Use complementary tones to cancel undesired undertones',
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
                            'Consider porosity, texture, and history of the hair',
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
                          'Developer Volumes',
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
                            '10 Volume - Deposit ony',
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
                            '20 Volume - Lifts 1-2 levels (also for gray coverage)',
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
                            '30 Volume - Lifts up to 3 levels',
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
                            '40 Volume - Lifts up to 4 levels(with caution)',
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
                          'Hair Color Categories',
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
                            'Permanent: Long-lasting, lifts and deposits, mixed with developer, high-lift color and bleach also fall into this category',
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
                            'Demi-Permanent: Deposits only, blends gray, fades over time',
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
                            'Semi-Permanent: Coats surface, non-peroxide (direct dyes that are vibrant but fades faster',
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
                            'Temporary:  Washes out with shampoo (indirect dyes like chalks, sprays, etc.)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                      ],
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
