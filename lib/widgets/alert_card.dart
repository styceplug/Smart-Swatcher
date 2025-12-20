import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import '../utils/colors.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Color> indicators; // pass a list of colors for the small dots
  final String actionText;
  final VoidCallback? onActionTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.description,
    required this.indicators,
    required this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.screenWidth,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + indicators row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style:  TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: indicators
                    .map((color) => Container(
                  margin: const EdgeInsets.only(left: 4),
                  height: Dimensions.height10,
                  width: Dimensions.width10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height5),
          Expanded(
            child: Text(
              description,
              style:  TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: Dimensions.height5,),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style:  TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}