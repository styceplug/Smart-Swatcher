import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';

import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../routes/routes.dart';
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
    final UserController userController = Get.find<UserController>();

    final imageUrl =
    controller.resolveImageUrl(notification.actor?.profileImageUrl);
    final hasImage = imageUrl.isNotEmpty;

    final isConnectionRequest = notification.type == 'connection_request';
    final connectionId = notification.data?['connectionId']?.toString();
    final connectionStatus = notification.connectionStatus;
    final isAccepted = connectionStatus == 'accepted';
    final isDeclined = connectionStatus == 'declined';

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height12),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: notification.isRead
              ? AppColors.grey2
              : AppColors.primary5.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// MAIN ROW
          Row(
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
                    /// TITLE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'Notification',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font14,
                              fontWeight: FontWeight.w600,
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

                    /// BODY
                    Text(
                      notification.body ?? '',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font13,
                        color: AppColors.grey5,
                      ),
                    ),

                    SizedBox(height: Dimensions.height10),

                    /// TIME
                    Text(
                      controller.formatNotificationTime(
                        notification.createdAt,
                      ),
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

          /// 👇 ACTIONS (ONLY FOR CONNECTION REQUEST)
          if (isConnectionRequest) ...[
            SizedBox(height: Dimensions.height15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (notification.id != null) {
                        await controller.markNotificationRead(notification.id!);
                      }

                      final actorId = notification.actor?.id;

                      if (actorId != null) {
                        Get.toNamed(
                          AppRoutes.otherProfileScreen,
                          arguments: actorId,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary5),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(Dimensions.radius10),
                      ),
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font12,
                        color: AppColors.primary5,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: Dimensions.width10),

                Expanded(
                  child: isAccepted || isDeclined
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isAccepted ? AppColors.success2 : AppColors.grey4,
                            disabledBackgroundColor:
                                isAccepted ? AppColors.success2 : AppColors.grey4,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius10),
                            ),
                          ),
                          child: Text(
                            isAccepted ? 'Accepted' : 'Declined',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font12,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: connectionId == null
                              ? null
                              : () async {
                                  final success =
                                      await userController.declineConnection(
                                    connectionId,
                                    targetId: notification.actor?.id,
                                  );
                                  if (success && notification.id != null) {
                                    await controller.markNotificationRead(
                                      notification.id!,
                                    );
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius10),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                ),

                if (!isAccepted && !isDeclined) ...[
                  SizedBox(width: Dimensions.width10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: connectionId == null
                          ? null
                          : () async {
                              final success =
                                  await userController.acceptConnection(
                                connectionId,
                                targetId: notification.actor?.id,
                              );
                              if (success && notification.id != null) {
                                await controller.markNotificationRead(
                                  notification.id!,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary5,
                        disabledBackgroundColor: AppColors.grey4,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius10),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
