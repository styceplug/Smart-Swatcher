import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

class FormulationOrCorrectionScreen extends StatefulWidget {
  const FormulationOrCorrectionScreen({super.key});

  @override
  State<FormulationOrCorrectionScreen> createState() =>
      _FormulationOrCorrectionScreenState();
}

class _FormulationOrCorrectionScreenState
    extends State<FormulationOrCorrectionScreen> {
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton()),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what you\'d like to do today.',
              style: TextStyle(fontSize: Dimensions.font28),
            ),
            SizedBox(height: Dimensions.height20),

            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'formulation';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selectedOption == 'formulation'
                            ? AppColors.primary3
                            : AppColors.primary3.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color formulation',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: Dimensions.font16,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            'The planned recipe for achieving a target hair color.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Icon(
                      selectedOption == 'formulation'
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: AppColors.primary3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Dimensions.height20),

            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'correction';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selectedOption == 'correction'
                            ? AppColors.primary3
                            : AppColors.primary3.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color correction',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: Dimensions.font16,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            'When transitioning from one color history to another.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Icon(
                      selectedOption == 'correction'
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: AppColors.primary3,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            CustomButton(
              text: 'Continue',
              onPressed: () {
                if (selectedOption == 'formulation') {
                  Get.toNamed(AppRoutes.uploadHair);
                } else {
                  //fix this
                }
              },
            ),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    );
  }
}
