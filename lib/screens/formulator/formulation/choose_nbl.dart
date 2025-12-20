import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/app_constants.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';

class ChooseNbl extends StatefulWidget {
  const ChooseNbl({super.key});

  @override
  State<ChooseNbl> createState() => _ChooseNblState();
}

class _ChooseNblState extends State<ChooseNbl> {
  String selectedNbl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        actionIcon: Text('Preview'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (Dimensions.screenWidth/6)*3,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Choose Natural Base Color (NBL)',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Pick the base color that matches your client’s hair.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    nblCard('1. Black', 'Underlying pigment: Black/Blue', 'black'),
                    nblCard('2. Dark Brown', 'Underlying pigment: Dark Red', 'dark-brown'),
                    nblCard('3. Medium Brown', 'Underlying pigment: Red', 'medium-brown'),
                    nblCard('4. Light Brown', 'Underlying pigment: Orange', 'light-brown'),
                    nblCard('5. Dark Blonde', 'Underlying pigment: Gold', 'dark-blonde'),
                    nblCard('6. Blonde', 'Underlying pigment: Yellow/Gold', 'blonde'),
                    nblCard('7. Light Blonde', 'Underlying pigment: Yellow', 'light-blonde'),
                    nblCard('8. Very Light Blonde', 'Underlying pigment: Pale Yellow', 'very-light-blonde'),
                    nblCard('9. Platinum Blonde', 'Underlying pigment: Pale Yellow/White', 'plat-blonde'),
                    nblCard('10. Extra Light Blonde', 'Underlying pigment: White', 'extra-light-blonde'),
                    nblCard('11. Lightest Blonde', 'Underlying pigment: White', 'lightest-blonde'),
                    nblCard('12. Extremely Light Blonde', 'Underlying pigment: White', 'extrem-light-blonde'),
                  ],
                ),
              ),
            ),
            SizedBox(height: Dimensions.height50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () {
                      Get.toNamed(AppRoutes.uploadHair);
                    },
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      Get.toNamed(AppRoutes.selectDesireLevel);
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

  Widget nblCard (String title, String subtitle, String image) {
    return InkWell(
      onTap: (){
        setState(() {
          selectedNbl = title;
        });
      },
      child: Container(
        height: Dimensions.height100,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white)),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.getBaseAsset(image)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selectedNbl == title ? Icons.circle : Icons.circle_outlined,
              color: AppColors.primary1,
              size: Dimensions.iconSize16,
            ),
            SizedBox(width: Dimensions.width10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: Dimensions.font15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: Dimensions.font12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}





