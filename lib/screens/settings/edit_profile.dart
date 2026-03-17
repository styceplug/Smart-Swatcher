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
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        title: "Edit Profile",
        actionIcon: InkWell(
          onTap: () => controller.saveCurrentProfileChanges(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.primary5,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final type = controller.currentAccountType.value;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: Dimensions.height40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (type == AccountType.company)
                _buildCompanyHeader(context, controller)
              else
                _buildStylistHeader(context, controller),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Dimensions.height30),

                    _sectionTitle('Basic Information'),
                    SizedBox(height: Dimensions.height15),

                    ...(type == AccountType.company
                        ? _companyBasicFields(controller)
                        : _stylistBasicFields(controller)),

                    SizedBox(height: Dimensions.height30),

                    _sectionTitle('Professional Information'),
                    SizedBox(height: Dimensions.height15),

                    ...(type == AccountType.company
                        ? _companyProfessionalFields(controller)
                        : _stylistProfessionalFields(controller)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCompanyHeader(
      BuildContext context,
      AuthController controller,
      ) {
    final baseUrl = controller.authRepo.apiClient.baseUrl;

    return Obx(() {
      ImageProvider? coverImage;
      ImageProvider? profileImage;

      if (controller.selectedBackgroundImage.value != null) {
        coverImage = FileImage(controller.selectedBackgroundImage.value!);
      } else {
        final url =
        controller.companyProfile.value?.getBackgroundImage(baseUrl!);
        if (url != null && url.isNotEmpty) {
          coverImage = NetworkImage(url);
        }
      }

      if (controller.selectedImage.value != null) {
        profileImage = FileImage(controller.selectedImage.value!);
      } else {
        final url =
        controller.companyProfile.value?.getProfileImage(baseUrl!);
        if (url != null && url.isNotEmpty) {
          profileImage = NetworkImage(url);
        }
      }

      return SizedBox(
        height: Dimensions.height10*18,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => _showBackgroundImagePickerModal(context, controller),
              child: Container(
                height: Dimensions.height10*13,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  image: coverImage != null
                      ? DecorationImage(
                    image: coverImage,
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: coverImage == null
                    ? Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: Dimensions.iconSize30,
                    color: AppColors.grey4,
                  ),
                )
                    : null,
              ),
            ),

            Positioned(
              right: Dimensions.width20,
              top: Dimensions.height15,
              child: _miniEditChip(
                text: 'Edit cover',
                onTap: () => _showBackgroundImagePickerModal(context, controller),
              ),
            ),

            Positioned(
              left: Dimensions.width20,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _showImagePickerModal(context, controller),
                    child: Container(
                      height: Dimensions.height10*9.5,
                      width: Dimensions.width10*9.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        border: Border.all(
                          color: AppColors.white,
                          width: 4,
                        ),
                        image: profileImage != null
                            ? DecorationImage(
                          image: profileImage,
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: profileImage == null
                          ? Icon(
                        Icons.person,
                        size: 42,
                        color: AppColors.grey4,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: Dimensions.width15),
                  Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height10),
                    child: _miniEditChip(
                      text: 'Edit photo',
                      onTap: () => _showImagePickerModal(context, controller),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStylistHeader(
      BuildContext context,
      AuthController controller,
      ) {
    final baseUrl = controller.authRepo.apiClient.baseUrl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      child: Obx(() {
        ImageProvider? profileImage;

        if (controller.selectedImage.value != null) {
          profileImage = FileImage(controller.selectedImage.value!);
        } else {
          final url =
          controller.stylistProfile.value?.getProfileImage(baseUrl!);
          if (url != null && url.isNotEmpty) {
            profileImage = NetworkImage(url);
          }
        }

        return Center(
          child: Column(
            children: [
              InkWell(
                onTap: () => _showImagePickerModal(context, controller),
                child: Container(
                  height: Dimensions.height100,
                  width: Dimensions.width100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey2,
                    image: profileImage != null
                        ? DecorationImage(
                      image: profileImage,
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: profileImage == null
                      ? Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.grey4,
                  )
                      : null,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              InkWell(
                onTap: () => _showImagePickerModal(context, controller),
                child: Text(
                  'Edit Picture',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.primary5,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _stylistBasicFields(AuthController controller) {
    return [
      _field(controller.nameController, 'Full Name'),
      _gap(),
      _field(controller.emailController, 'Email Address', readOnly: true),
      _gap(),
      _field(controller.usernameController, 'Username'),
      _gap(),
      _field(
        controller.phoneController,
        'Phone Number',
        keyboardType: TextInputType.phone,
      ),
      _gap(),
      _field(controller.countryController, 'Country'),
      _gap(),
      _field(controller.stateController, 'State'),
    ];
  }

  List<Widget> _stylistProfessionalFields(AuthController controller) {
    return [
      _field(controller.licenseController, 'License Number'),
      _gap(),
      _field(controller.salonController, 'Salon Name'),
      _gap(),
      _field(controller.certTypeController, 'Certification Type'),
      _gap(),
      _field(
        controller.yearsController,
        'Years of Experience',
        keyboardType: TextInputType.number,
      ),
      _gap(),
      _field(controller.licenseCountryController, 'Licensing Country'),
    ];
  }

  List<Widget> _companyBasicFields(AuthController controller) {
    return [
      _field(controller.companyNameController, 'Company Name'),
      _gap(),
      _field(controller.emailController, 'Email Address', readOnly: true),
      _gap(),
      _field(controller.usernameController, 'Username'),
      _gap(),
      _field(
        controller.phoneController,
        'Phone Number',
        keyboardType: TextInputType.phone,
      ),
      _gap(),
      _field(controller.countryController, 'Country'),
      _gap(),
      _field(controller.stateController, 'State'),
    ];
  }

  List<Widget> _companyProfessionalFields(AuthController controller) {
    return [
      // _field(controller.roleController, 'Role'),
      // _gap(),
      _field(
        controller.missionController,
        'Mission Statement',
        maxLines: 4,
      ),
      _gap(),
      _field(
        controller.aboutController,
        'About',
        maxLines: 4,
      ),
      _gap(),
      _field(controller.salonController, 'Salon Name'),
      _gap(),
      _field(controller.licenseController, 'License Number'),
      _gap(),
      _field(controller.certTypeController, 'Certification Type'),
      _gap(),
      _field(
        controller.yearsController,
        'Years of Experience',
        keyboardType: TextInputType.number,
      ),
      _gap(),
      _field(controller.licenseCountryController, 'License Country'),
    ];
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool readOnly = false,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return CustomTextField(
      controller: controller,
      labelText: label,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.font16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: AppColors.black1,
      ),
    );
  }

  Widget _miniEditChip({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(.55),
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height10,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Dimensions.font12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _gap() => SizedBox(height: Dimensions.height20);

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

  void _showBackgroundImagePickerModal(
      BuildContext context,
      AuthController controller,
      ) {
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
                controller.pickBackgroundImage(ImageSource.gallery);
              }),
              _modalItem(Iconsax.camera, 'Camera', () {
                FocusScope.of(context).unfocus();
                controller.pickBackgroundImage(ImageSource.camera);
              }),
              _modalItem(Icons.delete, 'Remove Image', () {
                FocusScope.of(context).unfocus();
                controller.removeBackgroundImage();
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