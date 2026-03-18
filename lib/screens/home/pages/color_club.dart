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

import '../../../controllers/event_controller.dart';
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
                      InkWell(
                        onTap: (){
                          Get.toNamed(AppRoutes.notificationScreen);
                        },
                        child: Image.asset(
                          AppConstants.getPngAsset('notification-icon'),
                          height: Dimensions.height10 * 2.5,
                          width: Dimensions.width10 * 2.5,
                          color: Colors.black,
                        ),
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
  final EventController controller = Get.find<EventController>();

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
                  'Recommended Events',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: Obx(() {
                if (controller.isGettingRecommendedEvents.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary5,
                    ),
                  );
                }

                if (controller.recommendedEvents.isEmpty) {
                  return Center(
                    child: Text(
                      'No events available',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.grey4,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.recommendedEvents.length,
                  itemBuilder: (context, index) {
                    final event = controller.recommendedEvents[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height15),
                      child: ReminderCard(
                        hostName: event.creator?.name ?? 'Unknown Host',
                        hostRole: event.creator?.role ?? 'Host',
                        sessionType: 'A U D I O',
                        title: event.title ?? 'Untitled Event',
                        dateTime: controller.formatEventDate(
                          event.scheduledStartAt,
                        ),
                        isReminderSet: event.viewer?.isSubscribed ?? false,
                        onPressed: () async {
                          print('event ${event.id} tapped');
                          await controller.fetchSingleEvent(event.id ?? '');
                          Get.toNamed(AppRoutes.shareSpaceScreen);
                        },
                        description: event.description ?? '',
                      ),
                    );
                  },
                );
              }),
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


