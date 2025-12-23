import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey2,
          ),
          child: BackButton(),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: Dimensions.screenWidth,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.grey2)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Enter the email address associated with your account, and we’ll email you a link.',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: Dimensions.height50),
                CustomTextField(
                  hintText: 'Email Address',
                  labelText: 'Email Address',
                ),

                SizedBox(height: Dimensions.height20),
                CustomButton(
                  text: 'Continue',
                  onPressed: () {
                    Get.toNamed(AppRoutes.stylistLoginScreen);
                  },
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
