import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/alert_card.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/empty_state_widget.dart';
import 'package:smart_swatcher/widgets/expandable_fab.dart';

import '../../../controllers/post_controller.dart';
import '../../../controllers/room_controller.dart';
import '../../../models/post_model.dart';
import '../../../models/room_model.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/reminder_card.dart';

class ColorClub extends StatefulWidget {
  const ColorClub({super.key});

  @override
  State<ColorClub> createState() => _ColorClubState();
}

class _ColorClubState extends State<ColorClub>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        0,
        Dimensions.width20,
        0,
        Dimensions.height20 + kBottomNavigationBarHeight,
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            CustomAppbar(
              centerTitle: false,
              customTitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Color Club'),
                  Row(
                    children: [
                      Image.asset(
                        AppConstants.getPngAsset('search-icon'),
                        height: Dimensions.height10 * 2.5,
                        width: Dimensions.width10 * 2.5,
                        color: Colors.black,
                      ),
                      SizedBox(width: Dimensions.width15),
                      Image.asset(
                        AppConstants.getPngAsset('notification-icon'),
                        height: Dimensions.height10 * 2.5,
                        width: Dimensions.width10 * 2.5,
                        color: Colors.black,
                      ),
                      SizedBox(width: Dimensions.width15),
                      Image.asset(
                        AppConstants.getPngAsset('message-icon'),
                        height: Dimensions.height10 * 2.5,
                        width: Dimensions.width10 * 2.5,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              automaticIndicatorColorAdjustment: true,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              enableFeedback: true,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: "Feeds"),
                Tab(text: "Live Rooms"),
                Tab(text: "Media"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FeedTab(),
                  liveRoom(),
                  Center(
                    child: Text(
                      'Media',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedTab extends StatelessWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.find<PostController>();

    return SizedBox(
      height: Dimensions.screenHeight,
      width: Dimensions.screenWidth,
      child: Stack(
        children: [
          // Layer 1: The Content (List, Loading, or Empty)
          Obx(() {
            // A. Loading State
            if (controller.isFeedLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary5),
              );
            }

            // B. Empty State
            if (controller.postsList.isEmpty) {
              return Center(
                child: Text(
                  "No posts found",
                  style: TextStyle(color: AppColors.grey4),
                ),
              );
            }

            // C. List State
            return ListView.builder(
              padding: EdgeInsets.only(bottom: Dimensions.height100), // Add padding for FAB
              itemCount: controller.postsList.length,
              itemBuilder: (context, index) {
                return PostCard(post: controller.postsList[index]);
              },
            );
          }),

          // Layer 2: The Floating Button (Always Visible)
          Positioned(
            bottom: Dimensions.height100, // Adjusted to be visible within TabBarView
            right: Dimensions.width20,
            child: FloatingActionButton(
              heroTag: "feed_fab",
              backgroundColor: AppColors.primary5,
              onPressed: () => Get.toNamed(AppRoutes.createPost),
              child: Icon(
                  CupertinoIcons.plus,
                  color: AppColors.white,
                  size: Dimensions.iconSize20
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget liveRoom() {
  final RoomController controller = Get.put(RoomController());

  List<Map<String, dynamic>> remindersData =
      [
        {
          "id": 1,
          "hostName": "Macho",
          "hostRole": "Host",
          "sessionType": "A U D I O",
          "title": "Grey Coverage Q&A",
          "dateTime": "18 Aug 2025 at 18:30",
        },
        {
          "id": 2,
          "hostName": "Lily",
          "hostRole": "Co-Host",
          "sessionType": "V I D E O",
          "title": "Color Mixing 101",
          "dateTime": "20 Oct 2025 at 15:42",
        },
      ].obs;

  return Stack(
    children: [
      Container(
        width: Dimensions.screenWidth,
        height: Dimensions.screenHeight,
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height20,
          Dimensions.width20,
          Dimensions.height20 + kBottomNavigationBarHeight,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'All Rooms',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: Dimensions.width5),
                Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: remindersData.length,
                  itemBuilder: (context, index) {
                    final reminderData = remindersData[index];
                    final dateTime = controller.parseDateTime(
                      reminderData["dateTime"],
                    );

                    final reminder = RoomReminder(
                      id: reminderData["id"],
                      hostName: reminderData["hostName"],
                      hostRole: reminderData["hostRole"],
                      sessionType: reminderData["sessionType"],
                      title: reminderData["title"],
                      dateTime: dateTime,
                      isReminderSet: controller.isReminderSet(
                        reminderData["id"],
                      ),
                    );

                    return Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height15),
                      child: ReminderCard(
                        hostName: reminder.hostName,
                        hostRole: reminder.hostRole,
                        sessionType: reminder.sessionType,
                        title: reminder.title,
                        dateTime: reminderData["dateTime"],
                        isReminderSet: reminder.isReminderSet,
                        onPressed: () async {
                          if (reminder.isReminderSet) {
                            // Show option to cancel reminder
                            _showCancelReminderDialog(
                              context,
                              controller,
                              reminder,
                            );
                          } else {
                            // Set reminder
                            final success = await controller.setReminder(
                              reminder,
                            );

                            if (success) {
                              _showReminderSetDialog(context);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: Dimensions.height70,
        right: Dimensions.width20,
        child: ExpandableFab(),
      ),
    ],
  );
}

void _showReminderSetDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20 * 2,
          Dimensions.height20 * 2,
          Dimensions.width20 * 2,
          Dimensions.height70,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppConstants.getPngAsset('done'),
                height: Dimensions.height100,
                width: Dimensions.width100,
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'We\'ll notify you 5 minutes before this space goes live—you won\'t miss it!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              CustomButton(
                text: 'Done',
                onPressed: () {
                  Get.back();
                },
                backgroundColor: AppColors.primary6,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showCancelReminderDialog(
  BuildContext context,
  RoomController controller,
  RoomReminder reminder,
) {
  Get.dialog(
    AlertDialog(
      title: Text(
        'Cancel Reminder',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: Dimensions.font16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Do you want to cancel the reminder for this live room?',
        style: TextStyle(fontFamily: 'Poppins', fontSize: Dimensions.font14),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'No',
            style: TextStyle(fontFamily: 'Poppins', color: AppColors.grey4),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            controller.cancelReminder(reminder.id);
          },
          child: Text(
            'Yes, Cancel',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
