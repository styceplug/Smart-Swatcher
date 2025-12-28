import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthController controller = Get.find<AuthController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        title: "Edit Profile",
        actionIcon: InkWell(
          onTap: () => controller.saveChanges(),
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: Dimensions.font17,
              fontFamily: 'Poppins',
              color: AppColors.primary5,
            ),
          ),
        ),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _showImagePickerModal(context, controller),
                child: Obx(() {
                  ImageProvider? bgImage;
                  if (controller.selectedImage.value != null) {
                    bgImage = FileImage(controller.selectedImage.value!);
                  } else {
                    String? networkUrl =
                        controller.stylistProfile.value?.profileImageUrl;
                    if (networkUrl != null && networkUrl.isNotEmpty) {
                      bgImage = NetworkImage(networkUrl);
                    }
                  }

                  return Container(
                    height: Dimensions.height100,
                    width: Dimensions.width100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey2,
                      image:
                          bgImage != null
                              ? DecorationImage(
                                image: bgImage,
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        bgImage == null
                            ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.grey4,
                            )
                            : null,
                  );
                }),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Edit Picture',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height50),

              // --- FORM FIELDS ---
              CustomTextField(
                controller: controller.nameController,
                labelText: 'Full Name',
              ),
              SizedBox(height: Dimensions.height20),

              // Email is usually read-only
              CustomTextField(
                controller: controller.emailController,
                labelText: 'Email Address',
                readOnly: true,
              ),
              SizedBox(height: Dimensions.height20),

              CustomTextField(
                controller: controller.usernameController,
                labelText: 'Username',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.phoneController,
                labelText: 'Phone number',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: Dimensions.height20),

              // Location
              CustomTextField(
                controller: controller.countryController,
                labelText: 'Country',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.stateController,
                labelText: 'State',
              ),
              SizedBox(height: Dimensions.height20),

              // Professional Details
              CustomTextField(
                controller: controller.licenseController,
                labelText: 'License Number',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.salonController,
                labelText: 'Salon Name',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.certTypeController,
                labelText: 'Certification Type',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.yearsController,
                labelText: 'Years of experience',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                controller: controller.licenseCountryController,
                labelText: 'Licencing Country',
              ),
              SizedBox(height: Dimensions.height50), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerModal(BuildContext context, AuthController controller) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: Dimensions.screenHeight / 4,
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _modalItem(Iconsax.gallery, 'Gallery', () {
                FocusScope.of(context).unfocus();
                controller.pickImage(ImageSource.gallery);
              }),
              _modalItem(Iconsax.camera, 'Camera', () {
                FocusScope.of(context).unfocus();
                controller.pickImage(ImageSource.camera);
              }),
              _modalItem(Icons.delete, 'Remove Image', () {
                FocusScope.of(context).unfocus();
                controller.removeImage();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _modalItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: Dimensions.iconSize20),
          SizedBox(width: Dimensions.width10),
          Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.font17,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
