import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class DraftCard extends StatelessWidget {
  final String content;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DraftCard({
    Key? key,
    required this.content,
    required this.timeAgo,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height20,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey2,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: Dimensions.height50,
              width: Dimensions.width50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey2,
              ),
            ),
            SizedBox(width: Dimensions.width20),
            Expanded(
              child: Text(
                content,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: Dimensions.font15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: Dimensions.font13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(width: Dimensions.width20),
            InkWell(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'Delete Draft',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this draft?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.grey4,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          onDelete();
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.delete_outline,
                color: AppColors.grey4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}