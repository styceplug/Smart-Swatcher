import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

import '../../../controllers/auth_controller.dart';
import '../../../widgets/snackbars.dart';

class CompanyProfileInfo extends StatefulWidget {
  const CompanyProfileInfo({super.key});

  @override
  State<CompanyProfileInfo> createState() => _CompanyProfileInfoState();
}


class _CompanyProfileInfoState extends State<CompanyProfileInfo> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController missionController = TextEditingController();

  @override
  void dispose() {
    missionController.dispose();
    super.dispose();
  }

  void _openLogoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.grey3,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              SizedBox(height: Dimensions.height20),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () => authController.pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Take a photo"),
                onTap: () => authController.pickImage(ImageSource.camera),
              ),

              Obx(() {
                final hasImage = authController.selectedImage.value != null;
                if (!hasImage) return const SizedBox.shrink();

                return ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    "Remove logo",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: authController.removeImage,
                );
              }),

              SizedBox(height: Dimensions.height10),
            ],
          ),
        );
      },
    );
  }

  void _continue() {
    final mission = missionController.text.trim();
    if (mission.isEmpty) {
      CustomSnackBar.failure(message: "Please enter your mission statement");
      return;
    }

    // save mission
    authController.companyRegistrationData.addAll({
      "missionStatement": mission,
    });


    if (authController.selectedImage.value != null) {
      authController.companyRegistrationData.addAll({
        "profileImageFile": authController.selectedImage.value,
      });
    }

    // Final submit
    authController.registerCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
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
                'Profile info',
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                'Please provide your logo and your mission statement.',
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                  color: AppColors.grey5,
                ),
              ),

              SizedBox(height: Dimensions.height40),

              // Logo picker
              Center(
                child: Obx(() {
                  final File? img = authController.selectedImage.value;
                  final hasImage = img != null;

                  return InkWell(
                    onTap: _openLogoPickerSheet,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey2,
                        border: Border.all(
                          color: hasImage ? AppColors.primary5 : AppColors.grey3,
                          width: 1.2,
                        ),
                      ),
                      child: hasImage
                          ? ClipOval(
                        child: Image.file(
                          img,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: AppColors.grey5,
                            size: 28,
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            "Add logo",
                            style: TextStyle(
                              fontSize: Dimensions.font12,
                              color: AppColors.grey5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: Dimensions.height30),

              CustomTextField(
                hintText: 'Mission Statement',
                labelText: 'Mission Statement',
                maxLines: 3,
                controller: missionController,
              ),

              const Spacer(),

              // Button never null callback
              CustomButton(
                text: 'Continue',
                onPressed: _continue,
                backgroundColor: AppColors.primary5,
              ),

              SizedBox(height: Dimensions.height10),
            ],
          ),
        ),
      ),
    );
  }
}

