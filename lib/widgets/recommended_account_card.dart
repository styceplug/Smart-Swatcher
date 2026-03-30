import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';

import '../models/user_model.dart';
import '../routes/routes.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'app_cached_network_image.dart';
import 'custom_button.dart';

class RecommendedAccountCard extends StatelessWidget {
  final RecommendedAccountModel account;

  const RecommendedAccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final imageUrl = controller.resolveImageUrl(account.profileImageUrl);
    final hasImage = imageUrl.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      onTap:
          () =>
              Get.toNamed(AppRoutes.otherProfileScreen, arguments: account.id),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height15),
        padding: EdgeInsets.all(Dimensions.height15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: AppColors.grey2.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// AVATAR SECTION
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(account.isElite ? 2.5 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            account.isElite
                                ? Border.all(
                                  color: AppColors.primary5,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: CircleAvatar(
                        radius: Dimensions.height20,
                        backgroundColor: AppColors.grey2,
                        backgroundImage:
                            hasImage ? appCachedImageProvider(imageUrl) : null,
                        child:
                            !hasImage
                                ? Icon(
                                  Icons.person,
                                  color: AppColors.grey4,
                                  size: Dimensions.iconSize24,
                                )
                                : null,
                      ),
                    ),
                    if (account.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.primary5,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: Dimensions.width10),

                /// INFO SECTION
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppColors.black1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _handleLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.font12,
                          color: AppColors.grey4,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                /// ACTION BUTTON
                Obx(() {
                  final isLoading = controller.isRequestingConnection(
                    account.id,
                  );
                  final status = controller.getConnectionStatus(account.id);

                  final isPending =
                      status == 'pending' ||
                      status == 'requested_by_viewer' ||
                      status == 'requested_by_them';
                  final isConnected =
                      status == 'accepted' || status == 'connected';

                  final buttonText =
                      isLoading
                          ? 'Sending...'
                          : isConnected
                          ? 'Connected'
                          : isPending
                          ? 'Pending'
                          : 'Connect';

                  final buttonColor =
                      isConnected || isPending
                          ? AppColors.grey4
                          : AppColors.primary5;

                  return CustomButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                    text: buttonText,
                    textStyle: TextStyle(
                      fontSize: Dimensions.font12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      if (isLoading || isPending || isConnected) return;
                      controller.requestConnection(account.id);
                    },
                    backgroundColor: buttonColor,
                  );
                }),
              ],
            ),

            /// FOOTER SECTION (Location & Recommendation Tags)
            if (_locationText().isNotEmpty ||
                account.recommendationReason != null) ...[
              SizedBox(height: Dimensions.height12),
              Row(
                children: [
                  if (_locationText().isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.grey4,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _locationText(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Dimensions.font10,
                                color: AppColors.grey4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (account.recommendationReason != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary5.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Text(
                        account.recommendationReason!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _handleLine() {
    final username =
        (account.username != null && account.username!.trim().isNotEmpty)
            ? '@${account.username}'
            : '';
    final role = _subtitleText();
    if (username.isEmpty) return role;
    return '$username • $role';
  }

  String _subtitleText() {
    if (account.type == 'company') {
      return (account.role != null && account.role!.trim().isNotEmpty)
          ? account.role!
          : 'Company';
    }
    if (account.saloonName != null && account.saloonName!.trim().isNotEmpty) {
      return account.saloonName!;
    }
    return 'Stylist';
  }

  String _locationText() {
    final parts = <String>[];
    if (account.state != null && account.state!.trim().isNotEmpty) {
      parts.add(account.state!.trim());
    }
    if (account.country != null && account.country!.trim().isNotEmpty) {
      parts.add(account.country!.trim());
    }
    return parts.join(', ');
  }
}
