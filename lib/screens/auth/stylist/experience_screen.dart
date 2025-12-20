import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  int? selectedIndex;

  void selectExperience(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final experiences = [
      {
        "title": "Beginner",
        "description":
        "Just starting your journey, building confidence and skills."
      },
      {
        "title": "Advanced",
        "description":
        "Experienced stylist with strong techniques and creativity."
      },
      {
        "title": "Educator",
        "description":
        "Expert professional guiding and training other stylists."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leadingWidth: Dimensions.width50,
        leading: Container(
          margin: EdgeInsets.only(left: Dimensions.width20),
          alignment: Alignment.center,
          height: Dimensions.height10,
          width: Dimensions.width10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey2,
          ),
          child: const Icon(Icons.chevron_left),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience Level',
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Select the level that best matches your skills',
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height50),
        
              // Loop through experiences
              ...List.generate(experiences.length, (index) {
                final isSelected = selectedIndex == index;
                final exp = experiences[index];
        
                return GestureDetector(
                  onTap: () => selectExperience(index),
                  child: Container(
                    margin: EdgeInsets.only(bottom: Dimensions.height20),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height20,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.grey2 : AppColors.grey1,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp["title"]!,
                                style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: Dimensions.height5),
                              Text(
                                exp["description"]!,
                                style: TextStyle(
                                  fontSize: Dimensions.font15,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: Dimensions.width20),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? AppColors.primary5
                              : AppColors.white,
                          size: Dimensions.iconSize30,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        
              const Spacer(),
        
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  Get.toNamed(AppRoutes.proRegistrationScreen);
                },
                backgroundColor: AppColors.primary5,
              ),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      ),
    );
  }
}