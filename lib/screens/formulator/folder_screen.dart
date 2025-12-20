import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../utils/dimensions.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  String clientName = Get.arguments as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: clientName,
        leadingIcon: BackButton(),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppConstants.getPngAsset('no-formulation'),
              height: Dimensions.height100 * 2,
              width: Dimensions.width100 * 2,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No formulation yet, create one \nto get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width70),
              child: CustomButton(
                text: 'Add New',
                onPressed: () {
                  Get.toNamed(AppRoutes.formulationOrCorrection);
                },
                backgroundColor: AppColors.primary4,
                icon: Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                  size: Dimensions.iconSize20,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height150),
          ],
        ),
      ),
    );
  }
}
