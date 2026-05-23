import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

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
  final ClientFolderController controller = Get.find<ClientFolderController>();

  bool get isCorrectionFlow =>
      (Get.arguments is Map &&
          (Get.arguments as Map)['formulationType'] == 'color_correction');

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            height: Dimensions.height10 * 17,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Gallery'),
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
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: LayoutBuilder(
        builder:
            (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        isCorrectionFlow
                            ? 'Choose a clear photo of the client’s hair so the current state can be assessed before planning the correction.'
                            : 'Choose a clear photo of the client’s hair to preview and try new colors.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: Dimensions.font14,
                        ),
                      ),
                      SizedBox(height: Dimensions.height40),
                      Center(
                        child: Obx(() {
                          final hasImage = controller.clientImage.value != null;

                          return GestureDetector(
                            onTap: _showPickerOptions,
                            child: Column(
                              children: [
                                Container(
                                  height: Dimensions.height100 * 3,
                                  width: Dimensions.width100 * 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey2.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.grey4),
                                    image:
                                        hasImage
                                            ? DecorationImage(
                                              image: FileImage(
                                                controller.clientImage.value!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                  child:
                                      !hasImage
                                          ? Image.asset(
                                            AppConstants.getPngAsset(
                                              'no-formulation',
                                            ),
                                            fit: BoxFit.contain,
                                          )
                                          : null,
                                ),
                                SizedBox(height: Dimensions.height20),
                                Text(
                                  hasImage
                                      ? 'Tap to change photo'
                                      : isCorrectionFlow
                                      ? 'Select a photo to assess the current color and plan a correction.'
                                      : 'Select a photo to try various tones on.',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!hasImage) ...[
                                  SizedBox(height: Dimensions.height10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Take a photo',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.width10),
                                      const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.primary5,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      Obx(
                        () => CustomButton(
                          text:
                              controller.isLoading.value
                                  ? 'Uploading...'
                                  : 'Next',
                          isDisabled: controller.clientImage.value == null,
                          onPressed: () {
                            if (!controller.isLoading.value) {
                              controller.uploadAndNext();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: Dimensions.height50),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
