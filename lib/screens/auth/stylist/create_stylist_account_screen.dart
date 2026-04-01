import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/models/stylist_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/country_state_dropdown.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

class CreateStylistAccountScreen extends StatefulWidget {
  const CreateStylistAccountScreen({super.key});

  @override
  State<CreateStylistAccountScreen> createState() =>
      _CreateStylistAccountScreenState();
}

class _CreateStylistAccountScreenState
    extends State<CreateStylistAccountScreen> {
  String? selectedCountry;
  String? selectedState;
  bool passwordVisible = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthController authController = Get.find<AuthController>();

  void viewPassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void signUp() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }
    StylistModel signupData = StylistModel(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      country: selectedCountry,
      state: selectedState,
    );
    authController.registerStylist(signupData);
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lets get you started',
                    style: TextStyle(
                      fontSize: Dimensions.font22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Just a few steps and you’ll be part of the experience.',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  SizedBox(height: Dimensions.height50),
                  CustomTextField(
                    hintText: 'Full Name',
                    labelText: 'Full Name',
                    autofillHints: [AutofillHints.name],
                    controller: nameController,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Email Address',
                    labelText: 'Email Address',
                    autofillHints: [AutofillHints.email],
                    controller: emailController,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Phone Number',
                    labelText: 'Phone Number',
                    autofillHints: [AutofillHints.telephoneNumber],
                    controller: phoneController,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CountryState(
                    selectedCountry: selectedCountry,
                    selectedState: selectedState,
                    onCountryChanged: (country) {
                      setState(() {
                        selectedCountry = country;
                        selectedState = null;
                      });
                    },
                    onStateChanged: (state) {
                      setState(() {
                        selectedState = state;
                      });
                    },
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Password',
                    controller: passwordController,
                    labelText: 'Password',
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
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'Create Account',
                    onPressed: () {
                      signUp();
                    },
                    backgroundColor: AppColors.primary5,
                  ),
                  SizedBox(height: Dimensions.height20),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.stylistLoginScreen);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Have an account?',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        Text(
                          ' Log in',

                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}
