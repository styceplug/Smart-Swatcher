import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

class CreateSpaceScreen extends StatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  State<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends State<CreateSpaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: Icon(Icons.close),
        title: 'Event',
        actionIcon: Text(
          'Done',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            child: TextField(
              style: TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Enter Space Name',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.grey4,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height40,
            ),
            child: Column(
              children: [
                OptionTile(
                  icon: CupertinoIcons.time,
                  title: 'Time',
                  value: 'Select Time',
                  onTap: () {},
                ),
                OptionTile(
                  icon: CupertinoIcons.mic,
                  title: 'Event Type',
                  value: 'Video',
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
                              padding: EdgeInsets.fromLTRB(
                                Dimensions.width20,
                                Dimensions.height20,
                                Dimensions.width20,
                                Dimensions.height70,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Event Type',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(Icons.close),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Container(
                                      height: 1,
                                      width: Dimensions.screenWidth,
                                      color: AppColors.grey2,
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Icon(Icons.multitrack_audio_outlined),
                                        SizedBox(width: Dimensions.width10),
                                        Text(
                                          'Audio',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_checked),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Icon(Iconsax.video),
                                        SizedBox(width: Dimensions.width10),
                                        Text(
                                          'Video',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_off),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                OptionTile(
                  icon: CupertinoIcons.person,
                  title: 'Audience',
                  value: 'Connections Only',
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
                              padding: EdgeInsets.fromLTRB(
                                Dimensions.width20,
                                Dimensions.height20,
                                Dimensions.width20,
                                Dimensions.height70,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Audience',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(Icons.close),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Container(
                                      height: 1,
                                      width: Dimensions.screenWidth,
                                      color: AppColors.grey2,
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Text(
                                          'Connections only',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_checked),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Text(
                                          'Everyone',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_off),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },

                ),
                OptionTile(
                  icon: Iconsax.record,
                  title: 'Session',
                  value: 'Recorded',
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
                              padding: EdgeInsets.fromLTRB(
                                Dimensions.width20,
                                Dimensions.height20,
                                Dimensions.width20,
                                Dimensions.height70,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Session',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(Icons.close),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Container(
                                      height: 1,
                                      width: Dimensions.screenWidth,
                                      color: AppColors.grey2,
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Text(
                                          'Live Only',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_checked),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                    Row(
                                      children: [
                                        Text(
                                          'Recorded',
                                          style: TextStyle(
                                            fontSize: Dimensions.font17,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.radio_button_off),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },

                ),
                SizedBox(height: Dimensions.height30),
                CustomButton(text: 'Create Space', onPressed: () {
                  Get.toNamed(AppRoutes.shareSpaceScreen);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const OptionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.width20,
          horizontal: Dimensions.height10,
        ),
        child: Row(
          children: [
            Icon(icon, size: Dimensions.iconSize20),
            SizedBox(width: Dimensions.width10),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Icon(
              CupertinoIcons.chevron_forward,
              size: Dimensions.iconSize20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
