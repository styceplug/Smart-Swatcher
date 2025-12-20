import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/widgets/country_state_dropdown.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class ProRegistrationScreen extends StatefulWidget {
  const ProRegistrationScreen({super.key});

  @override
  State<ProRegistrationScreen> createState() => _ProRegistrationScreenState();
}

class _ProRegistrationScreenState extends State<ProRegistrationScreen> {

  String? selectedCountry;


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
                'Are you a Pro?',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'This form is for stylists who want to join as licensed professionals.',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(height: Dimensions.height50),
              CustomTextField(
                hintText: 'License Number',
                labelText: 'License Number',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                hintText: 'Salon Name',
                labelText: 'Salon Name',
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                hintText: 'Certification Type',
                labelText: 'Certification Type',
                autofillHints: [AutofillHints.telephoneNumber],
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                hintText: 'Years of Experience',
                labelText: 'Years of Experience',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: Dimensions.height20),
              CountryDropdown(selectedCountry: selectedCountry,
                onCountryChanged: (value) {
                  setState(() {
                    selectedCountry = value!;
                  });
                },),
              Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: (){
                  Get.toNamed(AppRoutes.licenceUploadScreen);
                },
                backgroundColor: AppColors.primary5,
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Skip Pro Registration',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w600),
                  ),
                ],
              ),
        
              SizedBox(height: Dimensions.height50),
            ],
          ),
        ),
      ),


    );
  }
}
