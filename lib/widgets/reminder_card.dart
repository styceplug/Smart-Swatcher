import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import '../utils/app_constants.dart';
import 'custom_button.dart';


class ReminderCard extends StatelessWidget {
  final String hostName;
  final String hostRole;
  final String sessionType;
  final String title;
  final String dateTime;
  final bool isReminderSet;
  final VoidCallback onPressed;

  const ReminderCard({
    super.key,
    required this.hostName,
    required this.hostRole,
    required this.sessionType,
    required this.title,
    required this.dateTime,
    this.isReminderSet = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(height: Dimensions.height20),


          CustomButton(
            text: isReminderSet ? 'Cancel reminder' : 'Set reminder',
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font16,
            ),
            onPressed: onPressed,
            backgroundColor: isReminderSet ? Colors.redAccent : AppColors.primary1,
            icon: Image.asset(
              AppConstants.getPngAsset('notification-icon'),
              height: Dimensions.height20,
              width: Dimensions.width20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

