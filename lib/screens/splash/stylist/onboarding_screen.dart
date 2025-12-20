import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _onboardImages = [
    AppConstants.getPngAsset('onboard1'),
    AppConstants.getPngAsset('onboard2'),
    AppConstants.getPngAsset('onboard3'),
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
                    Get.toNamed(AppRoutes.createStylistAccountScreen);
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
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _onboardImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_onboardImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
        
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width50),
                  child: Column(
                    children: [
                      Text(
                        'Smart Color \nformulation starts here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Dimensions.font23,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: Dimensions.height5),
                      Text(
                        'Color with precision and formulate with freedom on smart swatcher',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_onboardImages.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: Dimensions.width5),
                      width: _currentPage == index ? 10 : 8,
                      height: _currentPage == index ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.white : Colors.grey,
                      ),
                    );
                  }),
                ),
        
                SizedBox(height: Dimensions.height70),
        
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: CustomButton(
                    text: _currentPage == _onboardImages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    onPressed: _showLoginOptions,
                    backgroundColor: AppColors.primary6,
                  ),
                ),
        
                SizedBox(height: Dimensions.height70),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
