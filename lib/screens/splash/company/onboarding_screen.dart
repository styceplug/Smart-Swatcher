import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';

class CompanyOnboarding extends StatefulWidget {
  const CompanyOnboarding({super.key});

  @override
  State<CompanyOnboarding> createState() => _CompanyOnboardingState();
}

class _CompanyOnboardingState extends State<CompanyOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _onboardImages = [
    AppConstants.getPngAsset('comp-onboard1'),
    AppConstants.getPngAsset('comp-onboard2'),
    AppConstants.getPngAsset('comp-onboard3'),
  ];

  final List<String> _onboardTitle = [
    'Track\nWhat Matters',
    'Share Your\nBrand, Your Way',
    'Create & Manage\nElite Rooms',
  ];

  final List<String> _onboardSubtitle = [
    'Get insights on performance, engagement, and growth all at a glance.',
    'Showcase your portfolio and connect with the right audience seamlessly.',
    'Organize exclusive events and manage your community efficiently.',
  ];

  void _showLoginOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder:
          (context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: Dimensions.font23,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Register for events, subscribe to calendars and manage events you’re going to',
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Dimensions.height40),
            CustomButton(
              text: 'Continue with Email',
              onPressed: () {
                // Navigate to create account
                Get.toNamed(AppRoutes.createCompanyAccount);
              },
              backgroundColor: AppColors.primary5,
            ),
            SizedBox(height: Dimensions.height10),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '',
                    onPressed: () {},
                    icon: Image.asset(
                      AppConstants.getPngAsset('apple-icon'),
                      scale: 2,
                    ),
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: '',
                    onPressed: () {},
                    icon: Image.asset(
                      AppConstants.getPngAsset('google-icon'),
                      scale: 2,
                    ),
                    backgroundColor: AppColors.primary1,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Column(
              children: [
                Text(
                  'By signing up on Smart Swatcher, you agree to',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Terms of use ',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'and ',
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Privacy.',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Dimensions.height50),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary5,
      body: Stack(
        children: [
          // 1. The Swipeable Page Content
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardImages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // The Image at the top
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: Dimensions.height50 * 2), // Space for indicators
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          _onboardImages[index],
                          height: Dimensions.height100 * 6,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // The Gradient and Text at the bottom
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: Dimensions.screenHeight / 1.8,
                      width: Dimensions.screenWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary5,
                            AppColors.primary5.withOpacity(0.9),
                            AppColors.primary5.withOpacity(0.6),
                            AppColors.white.withOpacity(0.0001),
                          ],
                          stops: const [0.4, 0.6, 0.8, 1.0],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _onboardTitle[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Dimensions.font22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              _onboardSubtitle[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: Dimensions.font16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: Dimensions.height100 * 2.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Fixed Progress Indicators (Top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                child: Row(
                  children: List.generate(_onboardImages.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.width5),
                        child: Divider(
                          color: _currentPage == index
                              ? AppColors.primary3 // Active Color
                              : AppColors.white.withOpacity(0.5), // Inactive Color
                          thickness: Dimensions.height5, // Used thickness instead of height for Divider
                          // Note: Divider doesn't support radius directly,
                          // if you need rounded corners specifically, use a Container instead.
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // 3. Fixed Continue Button (Bottom)
          Positioned(
            bottom: Dimensions.height50,
            left: Dimensions.width20,
            right: Dimensions.width20,
            child: CustomButton(
              text: _currentPage == _onboardImages.length - 1 ? 'Get Started' : 'Continue',
              onPressed: () {
                if (_currentPage == _onboardImages.length - 1) {
                  // If on last page, show login options
                  _showLoginOptions();
                } else {
                  // Otherwise, slide to next page
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              backgroundColor: AppColors.grey4,
              textStyle: TextStyle(
                color: AppColors.primary5,
                fontFamily: 'Poppins',
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
