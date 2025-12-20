import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class TipsCard extends StatelessWidget {
  final String title;
  final String description;
  final int saves;
  final bool isSaved;
  final VoidCallback? onSave;

  const TipsCard({
    Key? key,
    required this.title,
    required this.description,
    required this.saves,
    this.isSaved = false,
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.font15,
            ),
          ),
          SizedBox(height: Dimensions.height10),

          /// Description
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: Dimensions.font14,
            ),
          ),
          SizedBox(height: Dimensions.height10),

          /// Saves row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$saves Saves',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: Dimensions.font14,
                  color: AppColors.grey3,
                ),
              ),
              GestureDetector(
                onTap: onSave,
                child: Icon(
                  isSaved
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  size: Dimensions.iconSize16,
                  color: isSaved ? Colors.black : AppColors.grey3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}