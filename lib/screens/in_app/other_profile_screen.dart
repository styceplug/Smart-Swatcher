import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';

import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/post_card.dart';
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
                      color: AppColors.primary5.withOpacity(.08),
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
                    color: AppColors.black1.withOpacity(0.75),
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

                Center(
                  child: ElevatedButton(
                    onPressed: () => controller.requestConnection(profile.id!),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Connect", style: TextStyle(color: Colors.white)),
                  ),
                ),
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
    // final UserController controller = Get.find<UserController>();
    // final PostController postController = Get.find<PostController>();

    return SizedBox();

  /*  return Obx(() {
      if (postController.isFeedLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      if (postController.postsList.isEmpty) {
        return Center(
          child: Text(
            "No posts found",
            style: TextStyle(color: AppColors.grey4),
          ),
        );
      }

      return Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: Dimensions.height70),
            itemCount: postController.postsList.length,
            itemBuilder: (context, index) {
              return PostCard(post: postController.postsList[index]);
            },
          ),
        ],
      );
    });*/
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
    return GridView.builder(
      padding: EdgeInsets.all(Dimensions.width20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Dimensions.width20,
        mainAxisSpacing: Dimensions.height20,
        childAspectRatio: 0.8,
      ),
      itemCount: 4, // Dummy count
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey2,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
        );
      },
    );
  }
}
