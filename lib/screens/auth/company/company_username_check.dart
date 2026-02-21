import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

import '../../../routes/routes.dart';

class CompanyUsernameScreen extends StatefulWidget {
  const CompanyUsernameScreen({super.key});

  @override
  State<CompanyUsernameScreen> createState() => _CompanyUsernameScreenState();
}

class _CompanyUsernameScreenState extends State<CompanyUsernameScreen> {
  AuthController authController = Get.find();
  TextEditingController usernameController = TextEditingController();

  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    usernameController.dispose();
    super.dispose();
  }

  void onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(Duration(milliseconds: 500), () {
      authController.checkUsernameAvailability(query);
    });
  }

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
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: Dimensions.height50),
                CustomTextField(
                  hintText: 'User Name',
                  labelText: 'User Name',
                  suffixIcon: Icon(Icons.change_circle_outlined),
                  onChanged: onSearchChanged,
                  controller: usernameController,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: Dimensions.height5),
                Obx(() {
                  if (authController.usernameCheckStatus.value == 0) {
                    return SizedBox.shrink();
                  }

                  Color statusColor;
                  IconData statusIcon;
                  String statusText = authController.usernameCheckMessage.value;

                  switch (authController.usernameCheckStatus.value) {
                    case 1:
                      return Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Checking availability...",
                            style: TextStyle(
                              fontSize: Dimensions.font12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    case 2:
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      break;
                    case 3:
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      break;
                    default:
                      return SizedBox.shrink();
                  }
                  return Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: Dimensions.font16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font12,
                          color: statusColor,
                        ),
                      ),
                    ],
                  );
                }),
                Spacer(),
                Obx(() {
                  bool isBtnEnabled =
                      authController.usernameCheckStatus.value == 2;

                  return CustomButton(
                    text: 'Continue',
                    onPressed: onContinuePressed,
                    backgroundColor:
                    isBtnEnabled ? AppColors.primary5 : AppColors.grey4,
                  );
                }),
                SizedBox(height: Dimensions.height20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onContinuePressed() {
    final isEnabled = authController.usernameCheckStatus.value == 2;
    if (!isEnabled) return;

    final username = usernameController.text.trim();
    if (username.isEmpty) return;

    authController.companyRegistrationData['username'] = username;
    Get.toNamed(AppRoutes.companyRoleScreen);
  }
}
