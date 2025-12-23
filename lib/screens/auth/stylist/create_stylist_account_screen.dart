import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/models/stylist_model.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/country_state_dropdown.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';
import 'package:smart_swatcher/widgets/otp_box.dart';

import '../../../routes/routes.dart';

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
  bool isButtonEnabled = false;
  String otp = "";
  AuthController authController = Get.find<AuthController>();

  late Future<List<CountryData>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = loadCountries();
  }

  Future<List<CountryData>> loadCountries() async {
    final jsonStr = await rootBundle.loadString('assets/countries_state.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => CountryData.fromJson(e)).toList();
  }

  void viewPassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void showOtpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Icon(Icons.cancel, color: Colors.grey),
                  ],
                ),

                SizedBox(height: Dimensions.height40),
                Text(
                  'Enter the code sent to ${emailController.text}',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                OtpInput(
                  length: 6,
                  onCompleted: (enteredOtp) {
                    setState(() {
                      otp = enteredOtp;
                      isButtonEnabled = true;
                    });
                  },
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  'Resend Code in 00:32',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: Dimensions.height20),
                CustomButton(
                  text: 'Verify',
                  onPressed: () {
                    authController.verifyOtp(otp);
                  },
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height50),
              ],
            ),
          ),
    );
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
    showOtpModal();
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
                    onPressed: (){
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
