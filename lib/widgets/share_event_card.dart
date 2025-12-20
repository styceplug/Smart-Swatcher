import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import '../utils/app_constants.dart';
import 'custom_button.dart';

class ShareEventCard extends StatelessWidget {
  final String hostName;
  final String hostRole;
  final String sessionType;
  final String title;
  final String dateTime;
  final VoidCallback onPressed;

  const ShareEventCard({
    super.key,
    required this.hostName,
    required this.hostRole,
    required this.sessionType,
    required this.title,
    required this.dateTime,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Row
              Row(
                children: [
                  Text(
                    hostName,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Dimensions.width5),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width5,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                    child: Text(
                      hostRole,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: Dimensions.font14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sessionType,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),

              /// Title
              Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height20),

              /// Date/Time Row
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: Dimensions.iconSize20),
                  SizedBox(width: Dimensions.width5),
                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary1,
                  ),
                  child: Icon(Icons.multitrack_audio_outlined),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  'Post',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary1,
                  ),
                  child: Icon(Iconsax.message),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  'DM',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary1,
                  ),
                  child: Icon(Iconsax.link),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  'Copy Link',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary1,
                  ),
                  child: Icon(Iconsax.share),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  'Share',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
