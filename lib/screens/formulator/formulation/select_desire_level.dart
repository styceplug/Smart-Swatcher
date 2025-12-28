import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';


class SelectDesireLevel extends StatefulWidget {
  const SelectDesireLevel({Key? key}) : super(key: key);

  @override
  State<SelectDesireLevel> createState() => _SelectDesireLevelState();
}

class _SelectDesireLevelState extends State<SelectDesireLevel> {
  Map<String, dynamic> wizardData = {};

  int selectedLevel = 0;
  String? selectedTitle;
  String? selectedSubtitle;

  // 3. Reusing the Data List for consistency
  final List<Map<String, dynamic>> levelsList = [
    {'level': 1, 'title': '1. Black', 'subtitle': 'Underlying pigment: Black/Blue', 'asset': 'black'},
    {'level': 2, 'title': '2. Dark Brown', 'subtitle': 'Underlying pigment: Dark Red', 'asset': 'dark-brown'},
    {'level': 3, 'title': '3. Medium Brown', 'subtitle': 'Underlying pigment: Red', 'asset': 'medium-brown'},
    {'level': 4, 'title': '4. Light Brown', 'subtitle': 'Underlying pigment: Orange', 'asset': 'light-brown'},
    {'level': 5, 'title': '5. Dark Blonde', 'subtitle': 'Underlying pigment: Gold', 'asset': 'dark-blonde'},
    {'level': 6, 'title': '6. Blonde', 'subtitle': 'Underlying pigment: Yellow/Gold', 'asset': 'blonde'},
    {'level': 7, 'title': '7. Light Blonde', 'subtitle': 'Underlying pigment: Yellow', 'asset': 'light-blonde'},
    {'level': 8, 'title': '8. Very Light Blonde', 'subtitle': 'Underlying pigment: Pale Yellow', 'asset': 'very-light-blonde'},
    {'level': 9, 'title': '9. Platinum Blonde', 'subtitle': 'Underlying pigment: Pale Yellow/White', 'asset': 'plat-blonde'},
    {'level': 10, 'title': '10. Extra Light Blonde', 'subtitle': 'Underlying pigment: White', 'asset': 'extra-light-blonde'},
    {'level': 11, 'title': '11. Lightest Blonde', 'subtitle': 'Underlying pigment: White', 'asset': 'lightest-blonde'},
    {'level': 12, 'title': '12. Extremely Light Blonde', 'subtitle': 'Underlying pigment: White', 'asset': 'extrem-light-blonde'},
  ];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Get.arguments;
    }
  }

  void _onNext() {
    // Add the Desired Level to our data pile
    wizardData['desiredLevel'] = selectedLevel;

    // Navigate to Grey Coverage to get the next piece of data
    Get.toNamed(AppRoutes.greyCoverage, arguments: wizardData);
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
            // Progress Bar (4/6)
            Container(
              width: (Dimensions.screenWidth / 6) * 4,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),

            Text(
              'Select Desire Level ',
              style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Choose client’s desired color level',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // --- MAIN PREVIEW IMAGE ---
            Expanded(

              child: Container(
                width: Dimensions.screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getPngAsset('level-preview')),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height10, horizontal: 10),
                  child: Text(
                    selectedTitle != null
                        ? "$selectedTitle\n$selectedSubtitle"
                        : "Select a level to preview",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: Dimensions.height20),

            // --- HORIZONTAL LIST ---
            SizedBox(
              height: Dimensions.height10*8, // Slightly taller for padding
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: levelsList.length,
                itemBuilder: (context, index) {
                  final item = levelsList[index];
                  return nblCard(
                    item['title'],
                    item['subtitle'],
                    item['asset'],
                    item['level'],
                  );
                },
              ),
            ),

            const Spacer(),

            // --- NAVIGATION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () => Get.back(),
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    isDisabled: selectedLevel == 0, // Disable if nothing selected
                    onPressed: _onNext,
                    backgroundColor: AppColors.primary4,
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

  Widget nblCard(String title, String subtitle, String image, int level) {
    bool isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
          selectedTitle = title;
          selectedSubtitle = subtitle;
        });
      },
      child: Container(
        width: Dimensions.width70,
        margin: EdgeInsets.only(right: Dimensions.width10),
        // Visual indicator logic
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.getBaseAsset(image)),
          ),
          border: Border.all(
            color: isSelected ? AppColors.primary5 : Colors.grey.shade300,
            width: isSelected ? 3 : 1, // Thicker border when selected
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary4.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
      ),
    );
  }
}
