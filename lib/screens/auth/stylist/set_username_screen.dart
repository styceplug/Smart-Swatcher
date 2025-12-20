import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

import '../../../routes/routes.dart';

class SetUsernameScreen extends StatefulWidget {
  const SetUsernameScreen({super.key});

  @override
  State<SetUsernameScreen> createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends State<SetUsernameScreen> {
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
          child: Icon(Icons.chevron_left),
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
                  'Set your username',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Your username is how others will know you here.',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Poppins'
                  ),
                ),
                SizedBox(height: Dimensions.height50,),
                CustomTextField(
                  hintText: 'User Name',
                  labelText: 'User Name',
                  suffixIcon: Icon(Icons.change_circle_outlined),
                ),
                SizedBox(height: Dimensions.height5),
                Text('Checking Username availability...',style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12
                ),),
                Spacer(),
                CustomButton(text: 'Continue', onPressed: (){
                  Get.toNamed(AppRoutes.experienceScreen);
                },backgroundColor: AppColors.primary5,),
                SizedBox(height: Dimensions.height20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
