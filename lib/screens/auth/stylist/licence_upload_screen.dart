import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class LicenceUploadScreen extends StatefulWidget {
  const LicenceUploadScreen({super.key});

  @override
  State<LicenceUploadScreen> createState() => _LicenceUploadScreenState();
}

class _LicenceUploadScreenState extends State<LicenceUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: Dimensions.width50,
        leading: Container(
          margin: EdgeInsets.only(left: Dimensions.width20),
          alignment: Alignment.center,
          height: Dimensions.height10,
          width: Dimensions.width10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey2,
          ),
          child: const Icon(Icons.chevron_left),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Your License',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Please provide a valid license or certification that includes your salon name.',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(height: Dimensions.height50),
              CustomTextField(
                hintText: 'Business Licence',
                labelText: 'Select Document Type',
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              SizedBox(height: Dimensions.height20),


              ///Give option to open camera and gallery..
              Container(
                width: Dimensions.screenWidth,
                height: Dimensions.height150 * 1.2,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary2),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_present, size: Dimensions.iconSize30 * 1.4),
                    SizedBox(height: Dimensions.height10),
                    Text(
                      'Upload document',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Your document must be a PDF and no larger than 10MB.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font15,
                ),
              ),
              Spacer(),
              CustomButton(
                text: 'Submit',
                onPressed: () {
                  Get.toNamed(AppRoutes.stylistLoginScreen);
                },
                backgroundColor: AppColors.primary5,
              ),
              SizedBox(height: Dimensions.height20),
              InkWell(
                onTap: (){Get.offAllNamed(AppRoutes.homeScreen);},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Skip, I will do it later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
        
              SizedBox(height: Dimensions.height50),
            ],
          ),
        ),
      ),
    );
  }
}
