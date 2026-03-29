import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/expandable_fab.dart';

import '../../../controllers/event_controller.dart';
import '../../../controllers/post_controller.dart';
import '../../../controllers/profile_content_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/app_cached_network_image.dart';
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
  final AuthController authController = Get.find<AuthController>();
  final ProfileContentController profileContentController =
      Get.find<ProfileContentController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnMedia();
    });
  }

  Future<void> _loadOwnMedia() async {
    final ownerId = postController.currentActorId;
    final ownerType =
        authController.currentAccountType.value == AccountType.company
            ? 'company'
            : 'stylist';

    if (ownerId == null || ownerId.trim().isEmpty) {
      return;
    }

    await profileContentController.loadForOwner(
      ownerId: ownerId,
      ownerType: ownerType,
      includeProducts: ownerType == 'company',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                        onTap: () {
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
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.conversationsScreen);
                        },
                        child: Image.asset(
                          AppConstants.getPngAsset('message-icon'),
                          height: Dimensions.height10 * 2.5,
                          width: Dimensions.width10 * 2.5,
                          color: Colors.black,
                        ),
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
                children: [FeedTab(), liveRoom(), const _ColorClubMediaTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorClubMediaTab extends StatelessWidget {
  const _ColorClubMediaTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Stack(
      children: [
        Obx(() {
          if (controller.isLoadingMedia.value &&
              controller.displayMedia.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary5),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary5,
            onRefresh: controller.refreshCurrentOwner,
            child:
                controller.displayMedia.isEmpty
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height40,
                      ),
                      children: [
                        Center(
                          child: Text(
                            'No display media yet',
                            style: TextStyle(color: AppColors.grey4),
                          ),
                        ),
                      ],
                    )
                    : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.width20,
                        Dimensions.height20,
                        Dimensions.width20,
                        Dimensions.height100,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: Dimensions.width15,
                        mainAxisSpacing: Dimensions.height15,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: controller.displayMedia.length,
                      itemBuilder: (_, index) {
                        final item = controller.displayMedia[index];

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius15,
                                ),
                                child: AppCachedNetworkImage(
                                  imageUrl: item.url,
                                  fit: BoxFit.cover,
                                  enableFullscreen: true,
                                  heroTag: 'color_club_media_${item.id}',
                                ),
                              ),
                            ),
                            Positioned(
                              top: Dimensions.height10,
                              right: Dimensions.width10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width8,
                                  vertical: Dimensions.height5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radius20,
                                  ),
                                ),
                                child: Text(
                                  item.visibility,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Dimensions.font10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          );
        }),
        Positioned(
          bottom: Dimensions.height100,
          right: Dimensions.width20,
          child: FloatingActionButton(
            heroTag: 'media_upload_fab',
            backgroundColor: AppColors.primary5,
            onPressed: () => _showUploadSheet(context),
            child: Icon(
              CupertinoIcons.plus,
              color: AppColors.white,
              size: Dimensions.iconSize20,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showUploadSheet(BuildContext context) async {
    String visibility = 'General';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload display media',
                    style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                  Text(
                    'Choose who can view this media in your profile and Color Club media tab.',
                    style: TextStyle(
                      color: AppColors.grey4,
                      fontSize: Dimensions.font13,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Wrap(
                    spacing: Dimensions.width10,
                    children:
                        ['General', 'Elite'].map((value) {
                          final selected = visibility == value;
                          return ChoiceChip(
                            label: Text(value),
                            selected: selected,
                            onSelected: (_) {
                              setSheetState(() {
                                visibility = value;
                              });
                            },
                            selectedColor: AppColors.primary5.withValues(
                              alpha: 0.14,
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: Dimensions.height25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.of(sheetContext).pop();
                            await Get.find<ProfileContentController>()
                                .pickAndUploadDisplayMedia(
                                  visibility: visibility,
                                  source: ImageSource.gallery,
                                );
                          },
                          child: const Text('Gallery'),
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(sheetContext).pop();
                            await Get.find<ProfileContentController>()
                                .pickAndUploadDisplayMedia(
                                  visibility: visibility,
                                  source: ImageSource.camera,
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary5,
                          ),
                          child: const Text(
                            'Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
            return RefreshIndicator(
              color: AppColors.primary5,
              onRefresh: controller.fetchFeed,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: Dimensions.height100),
                itemCount: controller.postsList.length,
                itemBuilder: (context, index) {
                  return PostCard(post: controller.postsList[index]);
                },
              ),
            );
          }),

          // Layer 2: The Floating Button (Always Visible)
          Positioned(
            bottom:
                Dimensions
                    .height100, // Adjusted to be visible within TabBarView
            right: Dimensions.width20,
            child: FloatingActionButton(
              heroTag: "feed_fab",
              backgroundColor: AppColors.primary5,
              onPressed: () => Get.toNamed(AppRoutes.createPost),
              child: Icon(
                CupertinoIcons.plus,
                color: AppColors.white,
                size: Dimensions.iconSize20,
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
                    child: CircularProgressIndicator(color: AppColors.primary5),
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
                        sessionType:
                            event.sessionMode == 'audio'
                                ? 'A U D I O'
                                : 'I N T E R A C T I V E',
                        title: event.title ?? 'Untitled Event',
                        dateTime: controller.formatEventDate(
                          event.scheduledStartAt,
                        ),
                        isReminderSet: event.viewer?.isSubscribed ?? false,
                        description: event.description ?? '',
                        onTap: () async {
                          await controller.fetchSingleEvent(event.id ?? '');
                          Get.toNamed(AppRoutes.shareSpaceScreen);
                        },
                        onReminderTap: () async {
                          await controller.toggleSubscription(event);
                        },
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
