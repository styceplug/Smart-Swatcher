import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/conversation_controller.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';
import 'package:smart_swatcher/widgets/post_card.dart';

import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/snackbars.dart';
import '../../widgets/tips_card.dart';


class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen({super.key});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final UserController controller = Get.find<UserController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // length 5 to match your initial tabs: Posts, Media, About, Products, Events
    _tabController = TabController(length: 5, vsync: this);

    final id = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProfile(id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Profile Header
            SliverToBoxAdapter(
              child: _OtherProfileHeader(controller: controller),
            ),

            // 2. Sticky Tab Bar - Using your specific delegate style
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  indicatorColor: AppColors.accent1,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height20,
                    Dimensions.width20,
                    0,
                  ),
                  indicatorWeight: 4,
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: "Posts"),
                    Tab(text: "Media"),
                    Tab(text: "About"),
                    Tab(text: "Products"),
                    Tab(text: "Events"),
                  ],
                ),
              ),
            ),
          ];
        },
        // 3. Body - Wrapped in Obx here so the NestedScrollView remains stable
        body: Obx(() {
          final profile = controller.profile.value;

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary5),
            );
          }

          return TabBarView(
            controller: _tabController,
            // ValueKey ensures clean semantics when profile data arrives
            key: ValueKey(profile.id ?? 'other_profile_view'),
            children: [
              const FeedTab(),
              const MediaTab(),
               AboutTab(), // Using the class-based Tab you showed later
              const Center(child: Text("Products")),
              const Center(child: Text("Events")),
            ],
          );
        }),
      ),
    );
  }
}

class _OtherProfileHeader extends StatelessWidget {
  final UserController controller;

  const _OtherProfileHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return SizedBox(height: Dimensions.height100 * 3);

      final profileUrl = controller.resolveImage(profile.profileImageUrl);
      final coverUrl = controller.resolveImage(profile.backgroundImageUrl);

      return Column(
        children: [
          // Using your Stack structure for the Banner and Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Dimensions.screenWidth,
                height: Dimensions.height100 * 1.6,
                decoration: BoxDecoration(
                  color: AppColors.primary1,
                  image: coverUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(coverUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
              Positioned(
                left: Dimensions.width20,
                bottom: -Dimensions.height10 * 3.5,
                child: Container(
                  height: Dimensions.height10 * 7.5,
                  width: Dimensions.width10 * 7.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.white, width: 3),
                    image: profileUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(profileUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: profileUrl.isEmpty
                      ? Icon(Icons.person, size: 38, color: AppColors.grey4)
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10 * 4.5),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name?.capitalizeFirst ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${profile.username ?? ""}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    color: AppColors.grey4,
                  ),
                ),

                if (profile.role != null) ...[
                  SizedBox(height: Dimensions.height10),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary5.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Text(
                      profile.role!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font12,
                        color: AppColors.primary5,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: Dimensions.height12),
                Text(
                  profile.description ?? 'No description added.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    color: AppColors.black1.withValues(alpha: 0.75),
                  ),
                ),

                SizedBox(height: Dimensions.height20),
                // Your Stat Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('${profile.posts ?? 0}', 'Posts'),
                    _buildStatItem('${profile.likes ?? 0}', 'Likes'),
                    _buildStatItem('${profile.connections ?? 0}', 'Connections'),
                  ],
                ),

                SizedBox(height: Dimensions.height20),

                if (!profile.viewer.isSelf) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _ProfileActionButton(profile: profile),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: Dimensions.font17, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(fontSize: Dimensions.font14, color: AppColors.grey5)),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.profile});

  final OtherProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final conversationController = Get.find<ConversationController>();
    final action = profile.viewer.primaryAction;
    final targetId = profile.id ?? '';
    final isBusy = userController.isRequestingConnection(targetId);
    final isEnabled = profile.viewer.isPrimaryActionEnabled && !isBusy;
    final isGhost = action == ProfilePrimaryAction.requested;

    final label = isBusy ? 'Please wait...' : profile.viewer.primaryActionLabel;

    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: isEnabled
          ? () async {
              switch (action) {
                case ProfilePrimaryAction.connect:
                  await userController.requestConnection(
                    targetId,
                    refreshProfile: true,
                  );
                  break;
                case ProfilePrimaryAction.accept:
                  final connectionId = profile.viewer.connectionId;
                  if (connectionId == null || connectionId.trim().isEmpty) {
                    CustomSnackBar.failure(
                      message: 'Connection request information is missing.',
                    );
                    return;
                  }
                  await userController.acceptConnection(
                    connectionId,
                    targetId: targetId,
                    refreshProfile: true,
                  );
                  break;
                case ProfilePrimaryAction.message:
                  await conversationController.startPrivateConversation(
                    targetId: targetId,
                  );
                  break;
                case ProfilePrimaryAction.none:
                case ProfilePrimaryAction.requested:
                  break;
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isGhost ? AppColors.grey2 : AppColors.primary5,
        disabledBackgroundColor: isGhost ? AppColors.grey2 : AppColors.grey4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
        ),
        padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isGhost ? AppColors.grey5 : Colors.white,
          fontSize: Dimensions.font14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}




class AboutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
      final profile = controller.profile.value;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(profile?.about ?? 'No about info'),
      );
    });
  }
}

class FeedTab extends StatelessWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
      if (controller.isFetchingProfilePosts.value &&
          controller.profilePosts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshActiveProfile,
        child: controller.profilePosts.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height40,
                ),
                children: [
                  Center(
                    child: Text(
                      'No posts found',
                      style: TextStyle(color: AppColors.grey4),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: Dimensions.height70),
                itemCount: controller.profilePosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: controller.profilePosts[index]);
                },
              ),
      );
    });
  }
}

class TipsTab extends StatelessWidget {
  const TipsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tips = [
      {
        "title": "Balance Warmth",
        "description": "Hair dye passes the cuticle...",
        "saves": 124,
        "isSaved": true,
      },
      {
        "title": "Protect Your Hair",
        "description": "Use a toner...",
        "saves": 89,
        "isSaved": false,
      },
    ];

    return ListView.builder(
      itemCount: tips.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return TipsCard(
          title: tip["title"],
          description: tip["description"],
          saves: tip["saves"],
          isSaved: tip["isSaved"],
          onSave: () => print("Saved tip: ${tip["title"]}"),
        );
      },
    );
  }
}

class MediaTab extends StatelessWidget {
  const MediaTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
      final media = controller.profilePosts
          .expand((post) => post.media)
          .where((item) => item.url.trim().isNotEmpty)
          .toList();

      if (media.isEmpty) {
        return Center(
          child: Text(
            'No media found',
            style: TextStyle(color: AppColors.grey4),
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.all(Dimensions.width20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Dimensions.width20,
          mainAxisSpacing: Dimensions.height20,
          childAspectRatio: 0.8,
        ),
        itemCount: media.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            child: Image.network(
              media[index].url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.grey2,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image, color: AppColors.grey4),
              ),
            ),
          );
        },
      );
    });
  }
}
