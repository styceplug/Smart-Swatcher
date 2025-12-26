import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  bool reminder = false;
  bool checkBox = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,

        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client\'s Details',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Dimensions.font22,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Add Client information to start the formulation process',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                fontFamily: 'Poppins',
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              labelText: 'Client\'s name',
              hintText: 'Client\'s name',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              labelText: 'Phone number',
              hintText: 'Phone number',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              labelText: 'Email address',
              hintText: 'Email address',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              labelText: 'Date of birth',
              hintText: 'Date of birth',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              labelText: 'Appointment date',
              hintText: 'Appointment date',
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Reminder',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Switch(
                  value: reminder,
                  onChanged: (value) {},
                  activeTrackColor: AppColors.primary5,
                  activeColor: AppColors.primary4,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.grey2,
                ),
              ],
            ),

            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(value: checkBox, onChanged: (value) {}),
                Expanded(
                  child: Text(
                    'Email the client a consent form to approve or waive the 24-hour color patch test.',
                    style: TextStyle(
                      fontSize: Dimensions.font13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            CustomButton(
              text: 'Next',
              onPressed: () {},
              backgroundColor: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height50),
          ],
        ),
      ),
    );
  }
}
