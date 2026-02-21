import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';

class CompanyRoleSelection extends StatefulWidget {
  const CompanyRoleSelection({super.key});

  @override
  State<CompanyRoleSelection> createState() => _CompanyRoleSelectionState();
}

class _CompanyRoleSelectionState extends State<CompanyRoleSelection> {
  int? selectedIndex;

  void selectExperience(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        "title": "Company",
        "description":
        "For salons or distributors managing multiple stylists or outlets."
      },
      {
        "title": "Brand",
        "description":
        "For hair care brands that want to showcase and sell directly."
      },
      {
        "title": "Educator",
        "description":
        "Expert professional guiding and training other stylists."
      },
    ];

    void onContinuePressed() {
      if (selectedIndex == null) return;

      final roleTitle = roles[selectedIndex!]["title"]!;
      authController.companyRegistrationData["role"] = roleTitle;

      Get.toNamed(AppRoutes.companyProfileInfo);
    }

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
                'Role Selection',
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Select your role to get started.',
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height50),

              // Loop through experiences
              ...List.generate(roles.length, (index) {
                final isSelected = selectedIndex == index;
                final exp = roles[index];

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
                onPressed: onContinuePressed,


                backgroundColor: selectedIndex != null
                    ? AppColors.primary5
                    : AppColors.grey3,
              ),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      ),
    );
  }


}