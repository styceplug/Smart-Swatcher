import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/formulation_analysis_card.dart';

class ChooseNbl extends StatefulWidget {
  const ChooseNbl({Key? key}) : super(key: key);

  @override
  State<ChooseNbl> createState() => _ChooseNblState();
}

class _ChooseNblState extends State<ChooseNbl> {
  Map<String, dynamic>? previousData;
  FormulationAnalysisModel? suggestion;

  int selectedLevel = 0;
  String imageUrl = "";

  final List<Map<String, dynamic>> nblOptions = [
    {
      'level': 1,
      'title': '1. Black',
      'subtitle': 'Underlying pigment: Black/Blue',
      'asset': 'black',
    },
    {
      'level': 2,
      'title': '2. Dark Brown',
      'subtitle': 'Underlying pigment: Dark Red',
      'asset': 'dark-brown',
    },
    {
      'level': 3,
      'title': '3. Medium Brown',
      'subtitle': 'Underlying pigment: Red',
      'asset': 'medium-brown',
    },
    {
      'level': 4,
      'title': '4. Light Brown',
      'subtitle': 'Underlying pigment: Orange',
      'asset': 'light-brown',
    },
    {
      'level': 5,
      'title': '5. Dark Blonde',
      'subtitle': 'Underlying pigment: Gold',
      'asset': 'dark-blonde',
    },
    {
      'level': 6,
      'title': '6. Blonde',
      'subtitle': 'Underlying pigment: Yellow/Gold',
      'asset': 'blonde',
    },
    {
      'level': 7,
      'title': '7. Light Blonde',
      'subtitle': 'Underlying pigment: Yellow',
      'asset': 'light-blonde',
    },
    {
      'level': 8,
      'title': '8. Very Light Blonde',
      'subtitle': 'Underlying pigment: Pale Yellow',
      'asset': 'very-light-blonde',
    },
    {
      'level': 9,
      'title': '9. Platinum Blonde',
      'subtitle': 'Underlying pigment: Pale Yellow/White',
      'asset': 'plat-blonde',
    },
    {
      'level': 10,
      'title': '10. Extra Light Blonde',
      'subtitle': 'Underlying pigment: White',
      'asset': 'extra-light-blonde',
    },
    {
      'level': 11,
      'title': '11. Lightest Blonde',
      'subtitle': 'Underlying pigment: White',
      'asset': 'lightest-blonde',
    },
    {
      'level': 12,
      'title': '12. Extremely Light Blonde',
      'subtitle': 'Underlying pigment: White',
      'asset': 'extrem-light-blonde',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map) {
      previousData = Map<String, dynamic>.from(Get.arguments as Map);
      imageUrl = previousData?['imageUrl'] ?? "";
      suggestion = FormulationAnalysisModel.fromJsonLike(
        previousData?['suggestion'],
      );

      if (previousData?['suggestion'] != null) {
        var suggestion = previousData!['suggestion'];
        int estimated = suggestion['estimatedBaseLevel'] ?? 0;

        if (estimated > 0 && estimated <= 12) {
          selectedLevel = estimated;
        }
      }
    }
  }

  void _onNext() {
    Map<String, dynamic> wizardData = {
      ...?previousData,
      'imageUrl': imageUrl,
      'naturalBaseLevel': selectedLevel,
      'suggestion': previousData?['suggestion'],
    };

    final formulationType =
        wizardData['formulationType']?.toString() ?? 'color_formulation';

    Get.toNamed(
      formulationType == 'color_correction'
          ? AppRoutes.correctionDetails
          : AppRoutes.greyCoverage,
      arguments: wizardData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        actionIcon: Text(
          'Preview',
          style: TextStyle(
            fontSize: Dimensions.font15,
            color: AppColors.primary5,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (Dimensions.screenWidth / 6) * 3,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),

            Text(
              'Choose Natural Base Color (NBL)',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Pick the base color that matches your client’s hair.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            FormulationAnalysisCard(
              analysis: suggestion,
              title: 'AI Upload Reading',
            ),
            if (suggestion != null) SizedBox(height: Dimensions.height20),

            // --- SCROLLABLE LIST ---
            Expanded(
              child: ListView.builder(
                itemCount: nblOptions.length,
                itemBuilder: (context, index) {
                  final option = nblOptions[index];
                  return nblCard(
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
                    onPressed: () => Get.back(), // Go back to upload
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    // Disable if nothing selected
                    isDisabled: selectedLevel == 0,
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

  Widget nblCard(String title, String subtitle, String imageAsset, int level) {
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
        margin: EdgeInsets.only(bottom: 2), // Tiny gap or keep logic
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
          image: DecorationImage(
            fit: BoxFit.cover,
            // Assuming your AppConstants.getBaseAsset adds the path/extension
            image: AssetImage(AppConstants.getBaseAsset(imageAsset)),
            // Optional: Darken non-selected items slightly for focus
            colorFilter:
                isSelected
                    ? null
                    : ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3),
                      BlendMode.darken,
                    ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.circle : Icons.circle_outlined,
              color: AppColors.primary1, // Or White depending on contrast
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
