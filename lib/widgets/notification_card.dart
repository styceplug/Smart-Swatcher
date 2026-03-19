import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();
    final imageUrl = controller.resolveImageUrl(notification.actor?.profileImageUrl);
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height12),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: notification.isRead ? AppColors.grey2 : AppColors.primary5.withOpacity(.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Dimensions.height50,
            width: Dimensions.width50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
              image: hasImage
                  ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: !hasImage
                ? Icon(Icons.person, color: AppColors.grey4)
                : null,
          ),
          SizedBox(width: Dimensions.width10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? 'Notification',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary5,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  notification.body ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    color: AppColors.grey5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  controller.formatNotificationTime(notification.createdAt),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font12,
                    color: AppColors.grey4,
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