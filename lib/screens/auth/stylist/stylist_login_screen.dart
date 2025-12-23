import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class StylistLoginScreen extends StatefulWidget {
  const StylistLoginScreen({super.key});

  @override
  State<StylistLoginScreen> createState() => _StylistLoginScreenState();
}

class _StylistLoginScreenState extends State<StylistLoginScreen> {
  bool passwordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthController authController = Get.find<AuthController>();

  void viewPassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return CustomSnackBar.failure(message: 'Pls fill all fields');
    } else {
      authController.loginStylist(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        customTitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: Dimensions.width100,
              child: Image.asset(AppConstants.getPngAsset('logo')),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: Dimensions.font22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Log in to continue and pick up right where you left off.',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                SizedBox(height: Dimensions.height50),

                AutofillGroup(
                  child: CustomTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    labelText: 'Email Address',
                    autofillHints: [AutofillHints.email],
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                CustomTextField(
                  hintText: 'Password',
                  labelText: 'Password',
                  controller: passwordController,
                  autofillHints: [AutofillHints.password],
                  obscureText: !passwordVisible,
                  maxLines: 1,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        viewPassword();
                      });
                    },
                    child:
                        passwordVisible
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.forgotPasswordScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height50),
                CustomButton(
                  text: 'Log In',
                  onPressed: login,
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: Dimensions.width20),
                        width: Dimensions.screenWidth,
                        height: Dimensions.height5 / Dimensions.height10,
                        color: AppColors.grey4,
                      ),
                    ),
                    Text(
                      'Log in with',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.grey4,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: Dimensions.width20),

                        width: Dimensions.screenWidth,
                        height: Dimensions.height5 / Dimensions.height10,
                        color: AppColors.grey4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height30),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '',
                        onPressed: () {},
                        icon: Image.asset(
                          AppConstants.getPngAsset('apple-icon'),
                          scale: 2,
                        ),
                        backgroundColor: AppColors.primary1,
                      ),
                    ),
                    SizedBox(width: Dimensions.width20),
                    Expanded(
                      child: CustomButton(
                        text: '',
                        onPressed: () {},
                        icon: Image.asset(
                          AppConstants.getPngAsset('google-icon'),
                          scale: 2,
                        ),
                        backgroundColor: AppColors.primary1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height30),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.createStylistAccountScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
