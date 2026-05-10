import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/formulation_analysis_card.dart';

class ChooseNbl extends StatefulWidget {
  const ChooseNbl({super.key});

  @override
  State<ChooseNbl> createState() => _ChooseNblState();
}

class _ChooseNblState extends State<ChooseNbl> {
  final ClientFolderController controller = Get.find<ClientFolderController>();
  Map<String, dynamic>? previousData;
  FormulationAnalysisModel? suggestion;

  int selectedLevel = 0;
  String imageUrl = "";

  final Map<int, String> _baseAssets = const {
    1: 'black',
    2: 'dark-brown',
    3: 'medium-brown',
    4: 'light-brown',
    5: 'dark-blonde',
    6: 'blonde',
    7: 'light-blonde',
    8: 'very-light-blonde',
    9: 'plat-blonde',
    10: 'extra-light-blonde',
    11: 'lightest-blonde',
    12: 'extrem-light-blonde',
  };

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
    controller.loadFormulationConfig();
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            SizedBox(height: Dimensions.height5),
            Text(
              'If the client is fully grey, choose the natural base that best matches their youthful natural color.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font12,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height15),
            FormulationAnalysisCard(
              analysis: suggestion,
              title: 'Recommendations',
            ),
            if (suggestion != null) SizedBox(height: Dimensions.height15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nblOptions.length,
              itemBuilder: (context, index) {
                final option = _nblOptions[index];
                return nblCard(
                  option['title'],
                  option['subtitle'],
                  option['asset'],
                  option['level'],
                );
              },
            ),
            SizedBox(height: Dimensions.height20),
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

  List<Map<String, dynamic>> get _nblOptions {
    final configured = controller.baseLevelOptions;
    if (configured.isNotEmpty) {
      return configured.map((item) {
        final level = int.tryParse(item['level']?.toString() ?? '') ?? 0;
        return {
          'level': level,
          'title': '$level. ${item['label'] ?? 'Level $level'}',
          'subtitle':
              'Underlying pigment: ${item['underlyingPigment'] ?? item['undertone'] ?? 'Review visually'}',
          'asset': _baseAssets[level] ?? 'blonde',
        };
      }).toList();
    }

    return List.generate(
      12,
      (index) => {
        'level': index + 1,
        'title': '${index + 1}. Level ${index + 1}',
        'subtitle': 'Underlying pigment: Review visually',
        'asset': _baseAssets[index + 1] ?? 'blonde',
      },
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
