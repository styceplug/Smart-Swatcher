import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/post_card.dart';
import 'package:smart_swatcher/models/post_model.dart';
import 'package:smart_swatcher/widgets/tips_card.dart';
import '../../../routes/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final AuthController authController = Get.find<AuthController>();
  PostController postController = Get.find<PostController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAlive

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Profile Header (Avatar, Info, Badges, Stats)
            SliverToBoxAdapter(
              child: _ProfileHeader(authController: authController),
            ),

            // 2. Sticky Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.height10,
                    horizontal: Dimensions.width20,
                  ),
                  indicatorWeight: 2,
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: "Formulas"),
                    Tab(text: "Post"),
                    Tab(text: "Tips"),
                    Tab(text: "Media"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [FormulasTab(), FeedTab(), TipsTab(), MediaTab()],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthController authController;

  const _ProfileHeader({Key? key, required this.authController})
    : super(key: key);

  void _showBadgeModal(
    BuildContext context,
    String title,
    String desc,
    String iconAsset,
    Color bgColor,
    String bgAsset,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (context) {
        return Container(
          width: Dimensions.screenWidth,
          height: Dimensions.screenHeight / 2.2,
          padding: EdgeInsets.only(bottom: Dimensions.height20),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AppConstants.getBadgeAsset(bgAsset)),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Image.asset(
                AppConstants.getBadgeAsset(iconAsset),
                height: Dimensions.height150,
                width: Dimensions.width15 * 10,
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'You\'ve earned it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font13,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Dimensions.height20),
      child: Column(
        children: [
          CustomAppbar(
            customTitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Iconsax.user_add, size: Dimensions.iconSize20 * 1.4),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Get.toNamed(AppRoutes.editProfileScreen),
                      child: Image.asset(
                        AppConstants.getPngAsset('edit-icon'),
                        height: Dimensions.height20,
                        width: Dimensions.width20,
                      ),
                    ),
                    SizedBox(width: Dimensions.width20),
                    InkWell(
                      onTap: () => Get.toNamed(AppRoutes.settingsScreen),
                      child: Image.asset(
                        AppConstants.getPngAsset('settings-icon'),
                        height: Dimensions.height20 * 1.3,
                        width: Dimensions.width20 * 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() {
                      ImageProvider? bgImage;
                      String? networkUrl =
                          authController
                              .stylistProfile
                              .value
                              ?.fullProfileImageUrl;
                      if (networkUrl != null && networkUrl.isNotEmpty) {
                        bgImage = NetworkImage(networkUrl);
                      }

                      return Container(
                        height: Dimensions.height70,
                        width: Dimensions.width70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey2,
                          image:
                              bgImage != null
                                  ? DecorationImage(
                                    image: bgImage,
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            bgImage == null
                                ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.grey4,
                                )
                                : null,
                      );
                    }),
                    SizedBox(width: Dimensions.width20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Only wrap the text that changes with Obx/GetBuilder
                        GetBuilder<AuthController>(
                          builder: (controller) {
                            return Text(
                              controller
                                      .stylistProfile
                                      .value
                                      ?.fullName
                                      ?.capitalizeFirst ??
                                  'Stylist',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.height5),
                        Text(
                          '@${authController.stylistProfile.value?.username ?? ""}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),

                // --- Badges Row ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBadgeItem(
                        context,
                        'SWATCHSMITH',
                        'swatchsmith',
                        () => _showBadgeModal(
                          context,
                          'Swatchsmith',
                          'Earned by creators...',
                          'swatcher-verified',
                          const Color(0XFF75A2B6),
                          'swatch-bg',
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      _buildBadgeItem(
                        context,
                        'THE LAURETTE',
                        'laureate',
                        () => _showBadgeModal(
                          context,
                          'The Laureate',
                          'Awarded to active members...',
                          'laureate',
                          const Color(0XFFD4A391),
                          'laureate-bg',
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      _buildBadgeItem(
                        context,
                        'SWATCHER VERIFIED',
                        'swatcher-verified',
                        () => _showBadgeModal(
                          context,
                          'Swatcher Verified',
                          'Given to verified pros...',
                          'swatcher-verified',
                          const Color(0XFFF2A646),
                          'swatcher-verified-bg',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height10),
                Text(
                  'Lorem ipsum dolor sit amet consectetur. Dui integer pretium tempor mauris quam fames aliquet.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.black1.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // --- Stats Row ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('128', 'Formulas'),
                      _buildDivider(),
                      _buildStatItem('4.2K', 'Networks'),
                      _buildDivider(),
                      _buildStatItem('256', 'Posts'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(
    BuildContext context,
    String label,
    String iconName,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height5,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey4),
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Row(
          children: [
            Image.asset(
              AppConstants.getBadgeAsset(iconName),
              height: Dimensions.height15,
              width: Dimensions.width15,
            ),
            SizedBox(width: Dimensions.width10),
            Text(
              label,
              style: TextStyle(
                color: AppColors.grey4,
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: Dimensions.font17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font14,
            fontWeight: FontWeight.w300,
            fontFamily: 'Poppins',
            color: AppColors.grey5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: Dimensions.height50,
      color: AppColors.grey2,
    );
  }
}

class FormulasTab extends StatelessWidget {
  const FormulasTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.find<PostController>();

    return Obx(() {
      if (controller.isFeedLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      // Filter: Only show posts that have formula data
      // Note: Adjust logic if your backend identifies formulas differently (e.g. post.type == 'formula')
      final formulaPosts =
          controller.postsList
              .where(
                (p) => p.base != null || p.lights != null || p.toner != null,
              )
              .toList();

      if (formulaPosts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 50, color: AppColors.grey4),
              Text("No formulas yet", style: TextStyle(color: AppColors.grey4)),
            ],
          ),
        );
      }

      return ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: formulaPosts.length,
        itemBuilder: (context, index) {
          return FormulasCard(post: formulaPosts[index]);
        },
      );
    });
  }
}

class FeedTab extends StatelessWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.find<PostController>();

    return Obx(() {
      if (controller.isFeedLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      if (controller.postsList.isEmpty) {
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
            itemCount: controller.postsList.length,
            itemBuilder: (context, index) {
              return PostCard(post: controller.postsList[index]);
            },
          ),

          // Floating Action Button
          Positioned(
            bottom: Dimensions.height20,
            right: Dimensions.width20,
            child: FloatingActionButton(
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 2; // +2 for border correction

  @override
  double get maxExtent => tabBar.preferredSize.height + 2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      // Ensure background is white so it hides content scrolling behind it
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
