import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';

class SelectDesireLevel extends StatefulWidget {
  const SelectDesireLevel({super.key});

  @override
  State<SelectDesireLevel> createState() => _SelectDesireLevelState();
}

class _SelectDesireLevelState extends State<SelectDesireLevel> {
  String? selectedTitle;
  String? selectedSubtitle;

  Widget nblCard(String title, String subtitle, String image) {
    bool isSelected = selectedTitle == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTitle = title;
          selectedSubtitle = subtitle;
        });
      },
      child: Container(
        width: Dimensions.width70,
        margin: EdgeInsets.only(right: Dimensions.width10),
        padding: EdgeInsets.all(Dimensions.height10),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.getBaseAsset(image)),
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary5 : Colors.grey.shade300,
            width: 2,
          ),
          color:
              isSelected ? AppColors.primary4.withOpacity(0.1) : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        actionIcon: const Text('Colors Only'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (Dimensions.screenWidth/6)*4,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Select Desire Level',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Choose client’s desired color level',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            Container(
              height: Dimensions.height20 * 20,
              width: Dimensions.screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConstants.getPngAsset('level-preview')),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
                width: double.infinity,
                child: Text(
                  selectedTitle != null
                      ? "${selectedTitle!} | ${selectedSubtitle!}"
                      : "Select a level to preview",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'
                  ),
                ),
              ),
            ),

            SizedBox(height: Dimensions.height20),

            SizedBox(
              height: Dimensions.height70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  nblCard(
                    '1. Black',
                    'Underlying pigment: Black/Blue',
                    'black',
                  ),
                  nblCard(
                    '2. Dark Brown',
                    'Underlying pigment: Dark Red',
                    'dark-brown',
                  ),
                  nblCard(
                    '3. Medium Brown',
                    'Underlying pigment: Red',
                    'medium-brown',
                  ),
                  nblCard(
                    '4. Light Brown',
                    'Underlying pigment: Orange',
                    'light-brown',
                  ),
                  nblCard(
                    '5. Dark Blonde',
                    'Underlying pigment: Gold',
                    'dark-blonde',
                  ),
                  nblCard(
                    '6. Blonde',
                    'Underlying pigment: Yellow/Gold',
                    'blonde',
                  ),
                  nblCard(
                    '7. Light Blonde',
                    'Underlying pigment: Yellow',
                    'light-blonde',
                  ),
                  nblCard(
                    '8. Very Light Blonde',
                    'Underlying pigment: Pale Yellow',
                    'very-light-blonde',
                  ),
                  nblCard(
                    '9. Platinum Blonde',
                    'Underlying pigment: Pale Yellow/White',
                    'plat-blonde',
                  ),
                  nblCard(
                    '10. Extra Light Blonde',
                    'Underlying pigment: White',
                    'extra-light-blonde',
                  ),
                  nblCard(
                    '11. Lightest Blonde',
                    'Underlying pigment: White',
                    'lightest-blonde',
                  ),
                  nblCard(
                    '12. Extremely Light Blonde',
                    'Underlying pigment: White',
                    'extrem-light-blonde',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () {
                      Get.toNamed(AppRoutes.chooseNbl);
                    },
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      Get.toNamed(AppRoutes.greyCoverage);
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
