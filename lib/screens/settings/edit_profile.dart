import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        title: "Edit Profile",
        actionIcon: Text(
          'Done',
          style: TextStyle(fontSize: Dimensions.font17, fontFamily: 'Poppins'),
        ),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            height: Dimensions.screenHeight / 4,
                            padding: EdgeInsets.fromLTRB(
                              Dimensions.width20,
                              Dimensions.height20,
                              Dimensions.width20,
                              Dimensions.height20,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.gallery,
                                      size: Dimensions.iconSize20,
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.camera,
                                      size: Dimensions.iconSize20,
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: Dimensions.iconSize20,
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Text(
                                      'Remove Image',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.height30),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },

                child: Container(
                  height: Dimensions.height100,
                  width: Dimensions.width100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey2,
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Edit Picture',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height50),
              CustomTextField(labelText: 'Full Name'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Email Address'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Username'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Phone number'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Country'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'State'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Bio'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'License Number'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Salon Name'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Certification Type'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Years of experience'),
              SizedBox(height: Dimensions.height20),
              CustomTextField(labelText: 'Licencing Country'),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      ),
    );
  }
}
