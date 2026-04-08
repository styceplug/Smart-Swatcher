import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/models/formulation_model.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/formulation_analysis_card.dart';

class GreyCoverage extends StatefulWidget {
  const GreyCoverage({super.key});

  @override
  State<GreyCoverage> createState() => _GreyCoverageState();
}

class _GreyCoverageState extends State<GreyCoverage> {
  // 1. Data Pile
  Map<String, dynamic> wizardData = {};

  // 2. State
  int? selectedValue; // Store as int (10, 20...) for API
  FormulationAnalysisModel? suggestion;

  // Data Options (0 to 100)
  final List<int> percents = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  @override
  void initState() {
    super.initState();
    // Retrieve previous data
    if (Get.arguments is Map) {
      wizardData = Map<String, dynamic>.from(Get.arguments as Map);
      suggestion = FormulationAnalysisModel.fromJsonLike(
        wizardData['suggestion'],
      );

      // Auto-fill from the upload suggestion if available
      if (wizardData['suggestion'] != null) {
        var suggestion = wizardData['suggestion'];
        int? estimated = suggestion['estimatedGreyPercentage'];

        // Round to nearest 10 if needed, or just set if matches
        if (estimated != null && percents.contains(estimated)) {
          selectedValue = estimated;
        } else if (estimated != null) {
          final rounded = ((estimated / 10).round() * 10).clamp(0, 100);
          selectedValue = rounded;
        }
      }
    }
  }

  void _onNext() {
    if (selectedValue == null) return;

    wizardData['greyPercentage'] = selectedValue;

    if ((selectedValue ?? 0) > 10) {
      Get.toNamed(AppRoutes.greyExceeds, arguments: wizardData);
      return;
    }

    Get.toNamed(AppRoutes.chooseCdl, arguments: wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          0,
          Dimensions.width20,
          Dimensions.height30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar (5/6)
            Container(
              width: (Dimensions.screenWidth / 6) * 5,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),

            Text(
              'Grey Coverage %',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Estimate the percentage of grey hair your client has.',
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
              title: 'Recommendations',
            ),
            if (suggestion != null) SizedBox(height: Dimensions.height15),

            // --- DROPDOWN FIELD ---
            InkWell(
              onTap: _showSelectionModal,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey3),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedValue != null
                          ? '$selectedValue%'
                          : 'Select Percentage',
                      style: TextStyle(
                        color:
                            selectedValue != null
                                ? Colors.black
                                : AppColors.grey3,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_outlined,
                      color: AppColors.grey3,
                      size: Dimensions.iconSize20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Dimensions.height40),

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
                  child: CustomButton(
                    text: 'Next',
                    // Disable if nothing selected
                    isDisabled: selectedValue == null,
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

  void _showSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15),
        ),
      ),
      builder: (context) {
        return Container(
          height: Dimensions.screenHeight * 0.6, // Not too tall
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grey %',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.cancel, color: AppColors.grey4),
                  ),
                ],
              ),
              Divider(color: AppColors.grey2),

              // List
              Expanded(
                child: ListView.builder(
                  itemCount: percents.length,
                  itemBuilder: (context, index) {
                    final int val = percents[index];
                    final bool isSelected = val == selectedValue;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedValue = val;
                        });
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height15,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.grey2.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color:
                                  isSelected
                                      ? AppColors.primary4
                                      : AppColors.grey4,
                              size: 20,
                            ),
                            SizedBox(width: Dimensions.width15),
                            Text(
                              '$val%',
                              style: TextStyle(
                                fontSize: Dimensions.font15,
                                fontFamily: 'Poppins',
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    isSelected
                                        ? AppColors.black1
                                        : AppColors.grey5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
