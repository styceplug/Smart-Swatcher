import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

class ClientDetails extends StatefulWidget {
  const ClientDetails({super.key});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  bool reminder = false;

  void toggleReminder() {
    setState(() {
      reminder = !reminder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton()),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (Dimensions.screenWidth/6)*1,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20,),
            Text(
              'Client\'s details',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Provide your client’s information to keep their formulas organized.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(hintText: 'Client\'s Name'),
            SizedBox(height: Dimensions.height20),
            CustomTextField(hintText: 'Phone number'),
            SizedBox(height: Dimensions.height20),
            CustomTextField(hintText: 'Email address'),
            SizedBox(height: Dimensions.height20),
            CustomTextField(hintText: 'Appointment date'),
            SizedBox(height: Dimensions.height50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Reminder',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Iconsax.toggle_off),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: CustomButton(text: 'Prev', onPressed: () {},backgroundColor: AppColors.grey3,),),
                SizedBox(width: Dimensions.width20),
                Expanded(child: CustomButton(text: 'Next', onPressed: () {
                  Get.toNamed(AppRoutes.uploadHair);
                })),
              ],
            ),
            SizedBox(
              height: Dimensions.height30,
            )
          ],
        ),
      ),
    );
  }
}
