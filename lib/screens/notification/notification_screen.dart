import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../routes/routes.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NotificationController>();
    controller.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: Colors.white,
        leadingIcon: BackButton(
          onPressed: () {
            Get.back();
          },
        ),
        title: 'Notifications',
        actionIcon: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.notificationSettingsScreen);
          },
          child: Icon(Iconsax.setting),
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Container(
          color: Colors.white,
          width: Dimensions.screenWidth,
          child: Column(
            children: [
              Obx(
                    () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: TabBar(
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        text: controller.unreadCount.value > 0
                            ? 'All (${controller.notifications.length})'
                            : 'All',
                      ),
                      const Tab(text: 'Activity'),
                      const Tab(text: 'Connection'),
                      const Tab(text: 'Replies'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.bgColor,
                  child: Obx(
                        () => TabBarView(
                      children: [
                        NotificationTabList(
                          items: controller.allNotifications,
                          isLoading: controller.isGettingNotifications.value,
                        ),
                        NotificationTabList(
                          items: controller.activityNotifications,
                          isLoading: controller.isGettingNotifications.value,
                        ),
                        NotificationTabList(
                          items: controller.connectionNotifications,
                          isLoading: controller.isGettingNotifications.value,
                        ),
                        NotificationTabList(
                          items: controller.replyNotifications,
                          isLoading: controller.isGettingNotifications.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class NotificationTabList extends StatelessWidget {
  final List<AppNotificationModel> items;
  final bool isLoading;

  const NotificationTabList({
    super.key,
    required this.items,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary5),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: EmptyState(
          message: 'No notifications yet',
          imageAsset: 'notification-icon',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Dimensions.width20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return NotificationCard(notification: items[index]);
        },
      ),
    );
  }
}