import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton()),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (Dimensions.screenWidth/6)*2,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Upload Client\'s Hair',
              style: TextStyle(fontSize: Dimensions.font20),
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
            SizedBox(height: Dimensions.height20),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    AppConstants.getPngAsset('no-formulation'),
                    height: Dimensions.height100 * 3,
                    width: Dimensions.width100 * 3,
                  ),
                  SizedBox(height: Dimensions.height10),
                  Text(
                    'Select a photo to try various tones on.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      Icon(Icons.image)
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: Dimensions.height50),

            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () {
                      Get.toNamed(AppRoutes.clientDetails);
                    },
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      Get.toNamed(AppRoutes.chooseNbl);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height30),
          ],
        ),
      ),
    );
  }
}
