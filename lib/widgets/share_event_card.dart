import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final String description;
  final String visibility;
  final String status;
  final int subscriberCount;
  final VoidCallback onPressed;

  const ShareEventCard({
    super.key,
    required this.hostName,
    required this.hostRole,
    required this.sessionType,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.visibility,
    required this.status,
    required this.subscriberCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// top row
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
                    fontSize: Dimensions.font12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                sessionType,
                style: TextStyle(
                  fontSize: Dimensions.font13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height20),

          /// title
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: Dimensions.height15),

          /// description
          Text(
            description,
            style: TextStyle(
              fontSize: Dimensions.font14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.black1.withOpacity(.75),
            ),
          ),

          SizedBox(height: Dimensions.height20),

          /// date row
          Row(
            children: [
              Icon(CupertinoIcons.calendar, size: Dimensions.iconSize20),
              SizedBox(width: Dimensions.width5),
              Expanded(
                child: Text(
                  dateTime,
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height12),

          /// extra details
          Wrap(
            spacing: Dimensions.width10,
            runSpacing: Dimensions.height10,
            children: [
              _tag('Audience: $visibility'),
              _tag('Status: ${status.capitalizeFirst ?? status}'),
              _tag('$subscriberCount Reminders'),
            ],
          ),

          SizedBox(height: Dimensions.height20),

          CustomButton(
            text: 'Preview Event',
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font16,
            ),
            onPressed: onPressed,
            backgroundColor: AppColors.primary1,
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
