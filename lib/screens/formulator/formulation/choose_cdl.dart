import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

class ChooseCdl extends StatefulWidget {
  const ChooseCdl({Key? key}) : super(key: key);

  @override
  State<ChooseCdl> createState() => _ChooseCdlState();
}

class _ChooseCdlState extends State<ChooseCdl> {
  // 1. Inject Controller
  final ClientFolderController controller = Get.find<ClientFolderController>();

  // 2. Data Pile
  Map<String, dynamic> wizardData = {};

  int selectedLevel = 0;

  // Data List
  final List<Map<String, dynamic>> cdlOptions = [
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
    // Retrieve data from previous steps
    if (Get.arguments is Map) {
      wizardData = Get.arguments;
      // print("Data so far: $wizardData");
    }
  }

  void _onNext() {
    if (selectedLevel == 0) return;

    // 1. Add final data point
    wizardData['desiredLevel'] = selectedLevel;

    // 2. Clean up (remove internal suggestion data not needed by API)
    wizardData.remove('suggestion');

    // 3. Trigger API Call via Controller
    // The controller will handle the navigation to the Preview Screen on success
    controller.getPreview(wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        actionIcon: Text(
          'Preview',
          style: TextStyle(fontSize: Dimensions.font15, color: AppColors.primary5),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar (Adjust fraction as needed, e.g. 6/6)
            Container(
              width: Dimensions.screenWidth,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),

            Text(
              'Choose your client\'s Desired Level ',
              style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Client\'s desired color outcome',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // --- SCROLLABLE LIST ---
            Expanded(
              child: ListView.builder(
                itemCount: cdlOptions.length,
                itemBuilder: (context, index) {
                  final option = cdlOptions[index];
                  return cdlCard(
                    option['title'],
                    option['subtitle'],
                    option['asset'],
                    option['level'],
                  );
                },
              ),
            ),

            SizedBox(height: Dimensions.height20),

            // --- BUTTONS ---
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
                  child: Obx(() => CustomButton(
                    // Show Loading State
                    text: controller.isLoading.value ? 'Generating...' : 'Next',
                    isDisabled: controller.isLoading.value || selectedLevel == 0,
                    onPressed: _onNext,
                    backgroundColor: AppColors.primary4,
                  )),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height30),
          ],
        ),
      ),
    );
  }

  Widget cdlCard(String title, String subtitle, String imageAsset, int level) {
    bool isSelected = selectedLevel == level;

    return InkWell(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      child: Container(
        height: Dimensions.height100,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        margin: EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.getBaseAsset(imageAsset)),
            colorFilter: isSelected
                ? null
                : ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.circle : Icons.circle_outlined,
              color: AppColors.primary1,
              size: Dimensions.iconSize20,
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