import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';

class UploadHair extends StatefulWidget {
  const UploadHair({super.key});

  @override
  State<UploadHair> createState() => _UploadHairState();
}


class _UploadHairState extends State<UploadHair> {

  ClientFolderController controller = Get.find<ClientFolderController>();


  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: Dimensions.height10*17,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton()),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Container(
                width: (Dimensions.screenWidth / 6) * 2,
                height: Dimensions.height5,
                color: AppColors.primary4,
              ),
              SizedBox(height: Dimensions.height20),

              Text(
                'Upload Client\'s Photo',
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                'Choose a clear photo of client’s hair to preview and try new colors.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: Dimensions.font14,
                ),
              ),
              SizedBox(height: Dimensions.height50),

              // --- IMAGE SELECTION AREA ---
              Center(
                child: Obx(() {
                  bool hasImage = controller.clientImage.value != null;

                  return GestureDetector(
                    onTap: _showPickerOptions,
                    child: Column(
                      children: [
                        Container(
                          height: Dimensions.height100 * 3,
                          width: Dimensions.width100 * 3,
                          decoration: BoxDecoration(
                            color: AppColors.grey2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.grey4),
                            image: hasImage
                                ? DecorationImage(
                              image: FileImage(controller.clientImage.value!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          // Show placeholder ONLY if no image
                          child: !hasImage
                              ? Image.asset(
                            AppConstants.getPngAsset('no-formulation'),
                            fit: BoxFit.contain,
                          )
                              : null, // Empty if image exists (decoration handles it)
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Text changes based on state
                        Text(
                          hasImage ? 'Tap to change photo' : 'Select a photo to try various tones on.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        if (!hasImage) ...[
                          SizedBox(height: Dimensions.height10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Take a photo',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: Dimensions.width10),
                              Icon(Icons.camera_alt, color: AppColors.primary5),
                            ],
                          ),
                        ]
                      ],
                    ),
                  );
                }),
              ),

              Spacer(),

              // --- NEXT BUTTON ---
              Obx(() => CustomButton(
                text: controller.isLoading.value ? 'Uploading...' : 'Next',
                // Disable if no image selected or currently uploading
                isDisabled: controller.clientImage.value == null,

                onPressed: () {
                  if (!controller.isLoading.value) {
                    controller.uploadAndNext();
                  }
                },
              )),
              SizedBox(height: Dimensions.height50),
            ],
          ),
        ),
      ),
    );
  }
}