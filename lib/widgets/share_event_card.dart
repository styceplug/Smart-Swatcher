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
  final int? subscriberCount;
  final bool isLive;
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
    required this.isLive,
    this.subscriberCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HOST ROW
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 18),
              ),
              SizedBox(width: Dimensions.width10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hostName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: Dimensions.font14,
                    ),
                  ),
                  Text(
                    hostRole,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                      fontSize: Dimensions.font12,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              /// SESSION TYPE
              Text(
                sessionType,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height20),

          /// LIVE INDICATOR
          if (isLive)
            Row(
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Text(
                  'LIVE NOW',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font12,
                  ),
                ),
                SizedBox(width: Dimensions.width10),

                /// FAKE AUDIO BARS (clean subtle animation feel)
                Row(
                  children: List.generate(
                    6,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 3,
                      height: (i % 3 + 1) * 6,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (isLive) SizedBox(height: Dimensions.height15),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),

          SizedBox(height: Dimensions.height10),

          /// DESCRIPTION
          Text(
            description,
            style: TextStyle(
              fontSize: Dimensions.font13,
              fontFamily: 'Poppins',
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: Dimensions.height20),

          /// META ROW
          Row(
            children: [
              Icon(CupertinoIcons.calendar, size: Dimensions.iconSize16),
              SizedBox(width: Dimensions.width5),
              Text(
                dateTime,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                ),
              ),
              const Spacer(),
              Text(
                visibility,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          /// SUBSCRIBERS
          if (subscriberCount != null)
            Text(
              '${subscriberCount} interested',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
