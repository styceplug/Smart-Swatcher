import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class ReferenceCard extends StatelessWidget {
  final String timeAgo;
  final String title;
  final Color color;
  final String? imageAsset;

  const ReferenceCard({
    Key? key,
    required this.timeAgo,
    required this.title,
    this.color = const Color(0XFF968282),
    this.imageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height12*10,
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey4, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: Dimensions.height70,
            width: Dimensions.width70,
            decoration: BoxDecoration(
              color: imageAsset == null ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              image: imageAsset != null
                  ? DecorationImage(
                      image: AssetImage(imageAsset!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w200,
                    color: AppColors.grey4,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}