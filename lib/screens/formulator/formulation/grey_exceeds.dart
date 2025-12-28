import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';

class GreyExceeds extends StatefulWidget {
  const GreyExceeds({super.key});

  @override
  State<GreyExceeds> createState() => _GreyExceedsState();
}

class _GreyExceedsState extends State<GreyExceeds> {
  Map<String, dynamic> wizardData = {};

  String? selectedShadeType;
  String? selectedDesiredTone;
  String? selectedMixingRatio;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Get.arguments;
    }
  }

  void _onNext() {
    wizardData['shadeType'] = selectedShadeType;
    wizardData['desiredTone'] = selectedDesiredTone;

    Get.toNamed(AppRoutes.chooseCdl, arguments: wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Dimensions.screenWidth,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),

            Text(
              'Grey Hair Coverage Exceeds 10%',
              style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Please select the appropriate grey coverage shade for the client’s hair.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),

            SizedBox(height: Dimensions.height20),

            // --- SHADE TYPE SELECTION ---
            Text(
              'Available Shades',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            _radioOption(
              label: 'Fashion Shade',
              value: 'fashion',
              groupValue: selectedShadeType,
              onChanged: (val) => setState(() => selectedShadeType = val),
            ),
            SizedBox(height: Dimensions.height20),
            _radioOption(
              label: 'Natural Shade',
              value: 'natural',
              groupValue: selectedShadeType,
              onChanged: (val) => setState(() => selectedShadeType = val),
            ),

            SizedBox(height: Dimensions.height40),

            // --- DESIRED TONE SELECTION ---
            Text(
              'Add Natural or Gold',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            _radioOption(
              label: 'Natural',
              value: 'Natural',
              groupValue: selectedDesiredTone,
              onChanged: (val) => setState(() => selectedDesiredTone = val),
            ),
            SizedBox(height: Dimensions.height20),
            _radioOption(
              label: 'Gold',
              value: 'Gold',
              groupValue: selectedDesiredTone,
              onChanged: (val) => setState(() => selectedDesiredTone = val),
            ),

            SizedBox(height: Dimensions.height20),

            // --- MIXING RATIO MODAL ---
            IntrinsicWidth(
              child: CustomButton(
                text: selectedMixingRatio ?? 'Mixing Ratios',
                icon: Icon(Icons.calculate_outlined, size: Dimensions.iconSize20, color: AppColors.primary5),
                backgroundColor: Colors.white,
                borderColor: AppColors.primary5,
                onPressed: _showRatioModal,
              ),
            ),

            const Spacer(),

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
                  isDisabled: selectedShadeType == null || selectedDesiredTone == null,
                  onPressed: _onNext,
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

  Widget _radioOption({
    required String label,
    required String value,
    required String? groupValue,
    required Function(String) onChanged,
  }) {
    bool isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
            size: Dimensions.iconSize20,
            color: isSelected ? AppColors.primary4 : AppColors.grey4,
          ),
          SizedBox(width: Dimensions.width10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: Dimensions.font15,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatioModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius15)),
      ),
      builder: (context) {
        final List<String> percents = ['Up to 25%', '25% - 50%', '50% - 100%'];
        final List<String> ratios = ['2:1', '1:1', '1:1'];

        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('% Grey', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  Text('Mixing ratio (DL:N/G)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: percents.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedMixingRatio = "${percents[index]} (${ratios[index]})";
                        });
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(percents[index], style: TextStyle(fontFamily: 'Poppins')),
                            Text(ratios[index], style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
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
