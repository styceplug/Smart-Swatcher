import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/post_card.dart';
import 'package:smart_swatcher/widgets/tips_card.dart';
import '../../../routes/routes.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final AuthController authController = Get.find<AuthController>();
  PostController postController = Get.find<PostController>();
  String? _lastLoadedProfileId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _ensureOwnPostsLoaded() {
    final profileId = authController.companyProfile.value?.id;
    if (profileId == null || profileId.trim().isEmpty) {
      return;
    }

    if (_lastLoadedProfileId == profileId) {
      return;
    }

    _lastLoadedProfileId = profileId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postController.fetchOwnPosts(
        authorId: profileId,
        authorType: 'company',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAlive
    _ensureOwnPostsLoaded();

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Profile Header (Avatar, Info, Badges, Stats)
            SliverToBoxAdapter(
              child: _ProfileHeader(authController: authController),
            ),

            //make this scrollable horizontally
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
                    Tab(text: "Formulas"),
                    Tab(text: "Post"),
                    Tab(text: "Tips"),
                    Tab(text: "Media"),
                    Tab(text: "About"),
                    Tab(text: "Feature Products"),
                    Tab(text: "Educators"),
                    Tab(text: "Events"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,

          children: const [
            FormulasTab(),
            FeedTab(),
            TipsTab(),
            MediaTab(),
            AboutTab(),
            FeaturedProductsTab(),
            EducatorsTab(),
            EventsTab(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthController authController;

  const _ProfileHeader({Key? key, required this.authController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseUrl = authController.authRepo.apiClient.baseUrl;

    return Obx(() {
      final company = authController.companyProfile.value;

      final profileUrl = company?.getProfileImage(baseUrl!);
      final coverUrl = company?.getBackgroundImage(baseUrl!);

      final hasCover = coverUrl != null && coverUrl.isNotEmpty;
      final hasProfile = profileUrl != null && profileUrl.isNotEmpty;

      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Dimensions.screenWidth,
                height: Dimensions.height100 * 1.6,
                decoration: BoxDecoration(
                  color: AppColors.primary1,
                  image:
                      hasCover
                          ? DecorationImage(
                            image: NetworkImage(coverUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height50,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.recommendedAccountScreen);
                        },
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.width10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.user_add,
                            color: AppColors.white,
                            size: Dimensions.iconSize20,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap:
                                () => Get.toNamed(AppRoutes.editProfileScreen),
                            child: Container(
                              padding: EdgeInsets.all(Dimensions.width10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                AppConstants.getPngAsset('edit-icon'),
                                height: Dimensions.height18,
                                width: Dimensions.width18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.settingsScreen),
                            child: Container(
                              padding: EdgeInsets.all(Dimensions.width10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                AppConstants.getPngAsset('settings-icon'),
                                height: Dimensions.height20,
                                width: Dimensions.width20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: Dimensions.width20,
                bottom: -Dimensions.height10*3.5,
                child: Container(
                  height: Dimensions.height10*7.5,
                  width: Dimensions.width10*7.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.white, width: 3),
                    image:
                        hasProfile
                            ? DecorationImage(
                              image: NetworkImage(profileUrl),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      !hasProfile
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        company?.companyName?.capitalizeFirst ?? 'Company',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if ((company?.isVerified ?? false))
                      Icon(
                        Icons.verified,
                        color: AppColors.primary5,
                        size: Dimensions.iconSize20,
                      ),
                  ],
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  '@${company?.username ?? ""}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grey4,
                  ),
                ),

                if ((company?.role ?? '').isNotEmpty) ...[
                  SizedBox(height: Dimensions.height10),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary5.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Text(
                      company!.role!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary5,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: Dimensions.height12),

                Text(
                 company?.missionStatement?.trim().isNotEmpty == true
                      ? company!.missionStatement!
                      : 'No company description added yet.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.black1.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
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
      );
    });
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
      height: Dimensions.height10 * 4.5,
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
      if (controller.isOwnPostsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      final formulaPosts =
          controller.ownPostsList
              .where(
                (p) => p.hasFormula || p.base != null || p.lights != null || p.toner != null,
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

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: () => controller.fetchOwnPosts(authorType: 'company'),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: formulaPosts.length,
          itemBuilder: (context, index) {
            return FormulasCard(post: formulaPosts[index]);
          },
        ),
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
      if (controller.isOwnPostsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary5,
            onRefresh: () => controller.fetchOwnPosts(authorType: 'company'),
            child: controller.ownPostsList.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height40,
                    ),
                    children: [
                      Center(
                        child: Text(
                          "No posts found",
                          style: TextStyle(color: AppColors.grey4),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: Dimensions.height70),
                    itemCount: controller.ownPostsList.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: controller.ownPostsList[index]);
                    },
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
    final controller = Get.find<PostController>();

    return Obx(() {
      final media = controller.ownPostsList
          .expand((post) => post.media)
          .where((item) => item.url.trim().isNotEmpty)
          .toList();

      if (controller.isOwnPostsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: () => controller.fetchOwnPosts(authorType: 'company'),
        child: media.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height40,
                ),
                children: [
                  Center(
                    child: Text(
                      'No media found',
                      style: TextStyle(color: AppColors.grey4),
                    ),
                  ),
                ],
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.grey4,
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      child: Obx(() {
        final company = authController.companyProfile.value;

        final text =
            company?.about?.trim().isNotEmpty == true
                ? company!.about!
                : company?.missionStatement?.trim().isNotEmpty == true
                ? company!.missionStatement!
                : 'No about info added yet.';

        return Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font14,
            fontWeight: FontWeight.w400,
            color: AppColors.black1,
            height: 1.6,
          ),
        );
      }),
    );
  }
}

class FeaturedProductsTab extends StatelessWidget {
  const FeaturedProductsTab({Key? key}) : super(key: key);

  // Dummy data — replace with real model/controller when backend is ready
  static const List<Map<String, dynamic>> _dummyProducts = [
    {'color': Color(0xFFE07A8A)},
    {'color': Color(0xFFD4C5B8)},
    {'color': Color(0xFF4B9E8E)},
    {'color': Color(0xFFE8B4C0)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(Dimensions.width20),
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Dimensions.width10,
        mainAxisSpacing: Dimensions.height10,
        childAspectRatio: 0.85,
      ),
      itemCount: _dummyProducts.length,
      itemBuilder: (context, index) {
        final product = _dummyProducts[index];
        return _ProductCard(bgColor: product['color'] as Color);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Color bgColor;

  const _ProductCard({required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      // Replace with Image.network(product.imageUrl) when data is ready
    );
  }
}

class EducatorsTab extends StatelessWidget {
  const EducatorsTab({Key? key}) : super(key: key);

  // Dummy data — replace with real model/controller when backend is ready
  static const List<Map<String, dynamic>> _dummyEducators = [
    {
      'name': 'Jordan Blake',
      'username': '@jordanb_23',
      'role': 'Moderator',
      'avatarColor': Color(0xFFB0C4DE),
    },
    {
      'name': 'Jakob Jelling',
      'username': '@jakobjelling',
      'role': 'Moderator',
      'avatarColor': Color(0xFFD2B48C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      itemCount: _dummyEducators.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.grey2, height: 1),
      itemBuilder: (context, index) {
        final educator = _dummyEducators[index];
        return _EducatorRow(
          name: educator['name'] as String,
          username: educator['username'] as String,
          role: educator['role'] as String,
          avatarColor: educator['avatarColor'] as Color,
        );
      },
    );
  }
}

class _EducatorRow extends StatelessWidget {
  final String name;
  final String username;
  final String role;
  final Color avatarColor;

  const _EducatorRow({
    required this.name,
    required this.username,
    required this.role,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
      child: Row(
        children: [
          // Avatar
          Container(
            height: Dimensions.height50,
            width: Dimensions.width50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),

          SizedBox(width: Dimensions.width15),

          // Name + username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
                SizedBox(height: Dimensions.height5 / 2),
                Text(
                  username,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grey4,
                  ),
                ),
              ],
            ),
          ),

          // Role + chevron
          Row(
            children: [
              Text(
                role,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey4,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.grey4,
                size: Dimensions.iconSize20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({Key? key}) : super(key: key);

  // Dummy data — replace with real model/controller when backend is ready
  static final List<Map<String, dynamic>> _dummyEvents = [
    {
      'host': 'Macho',
      'type': 'VIDEO',
      'title': 'Your haircare products',
      'description':
          'Stay in the loop with everything happening around your hair journey — from styli...',
      'date': '18 Aug 2025 at 18:30',
      'reminderSet': true,
    },
    {
      'host': 'Macho',
      'type': 'AUDIO',
      'title': 'Your haircare products',
      'description':
          'Stay in the loop with everything happening around your hair journey — from styli...',
      'date': '20 Aug 2025 at 10:00',
      'reminderSet': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      itemCount: _dummyEvents.length,
      itemBuilder: (context, index) {
        final event = _dummyEvents[index];
        return Container(
          margin: EdgeInsets.only(bottom: Dimensions.height15),
          padding: EdgeInsets.all(Dimensions.width15),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(color: AppColors.grey2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title']?.toString() ?? 'Event',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                event['description']?.toString() ?? '',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font13,
                  color: AppColors.grey4,
                  height: 1.5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                '${event['type']} • ${event['date']}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  color: AppColors.primary5,
                ),
              ),
            ],
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
