import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/country_state_dropdown.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/otp_box.dart';
import '../../../widgets/snackbars.dart';

class CreateCompanyAccount extends StatefulWidget {
  const CreateCompanyAccount({super.key});

  @override
  State<CreateCompanyAccount> createState() => _CreateCompanyAccountState();
}

class _CreateCompanyAccountState extends State<CreateCompanyAccount> {
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
                    hintText: 'Company Name',
                    labelText: 'Company Name',
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
                    labelText: 'Password',
                    autofillHints: [AutofillHints.password],
                    obscureText: !passwordVisible,
                    maxLines: 1,
                    controller: passwordController,
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
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          passwordController.text.trim().isEmpty ||
                          selectedCountry == null ||
                          selectedState == null) {
                        CustomSnackBar.failure(message: "Please fill all fields");
                        return;
                      }

                      authController.companyRegistrationData.addAll({
                        "companyName": nameController.text.trim(),
                        "email": emailController.text.trim(),
                        "phoneNumber": phoneController.text.trim(),
                        "country": selectedCountry!,
                        "state": selectedState!,
                        "password": passwordController.text.trim(),
                        "authProvider": "email",
                      });

                      Get.toNamed(AppRoutes.companyUsernameScreen);

                    },
                    backgroundColor: AppColors.primary5,
                  ),

                  SizedBox(height: Dimensions.height20),
                  InkWell(
                    onTap: (){
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
