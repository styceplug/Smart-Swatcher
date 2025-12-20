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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Create Folder',
        leadingIcon: BackButton(),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,

        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
        child: Column(
          children: [
            CustomTextField(
              labelText: 'Folder name',
              hintText: 'Folder name',
            ),
            Spacer(),
            CustomButton(text: 'Create Folder', onPressed: (){},backgroundColor: AppColors.primary4,),
            SizedBox(height: Dimensions.height50,)
          ],
        ),
      ),
    );
  }
}
