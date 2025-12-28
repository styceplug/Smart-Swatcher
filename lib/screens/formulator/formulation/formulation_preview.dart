import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../../routes/routes.dart';

class FormulationPreview extends StatefulWidget {
  const FormulationPreview({super.key});

  @override
  State<FormulationPreview> createState() => _FormulationPreviewState();
}

class _FormulationPreviewState extends State<FormulationPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        actionIcon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.share),
            SizedBox(width: Dimensions.width15),
            Text(
              'Save',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: Dimensions.width10),
          ],
        ),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //preview original
            Container(height: Dimensions.height100 * 2.5, color: Colors.green),
            //preview new
            Container(height: Dimensions.height100 * 2.5, color: Colors.yellow),
            SizedBox(height: Dimensions.height20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.drop, color: AppColors.accent1),
                      SizedBox(width: Dimensions.width10),
                      Text('NBL 3 - G%40 - DL 8 = 5 Lvl'),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Divider(color: AppColors.grey2),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb,
                        color: AppColors.accent1,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          'Your formulation requires 5 levels of lift you will need to pre-lighten client to achieve a pure level 8. Suggestion lift client to the raw base pigment (RBP) of level 8 then apply desired control or enhancement color tone.',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Divider(color: AppColors.grey2),
                  SizedBox(height: Dimensions.height10),
                  IntrinsicWidth(
                    child: CustomButton(
                      text: 'Add description',
                      onPressed: () {
                        Get.toNamed(AppRoutes.addDescription);
                      },
                      icon: Icon(CupertinoIcons.pencil),
                      backgroundColor: AppColors.bgColor,
                      borderColor: AppColors.primary5,
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10,
                        vertical: Dimensions.height10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
