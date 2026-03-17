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
import 'package:smart_swatcher/widgets/reminder_card.dart';
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
    return Container(
      padding: EdgeInsets.only(bottom: Dimensions.height20),
      child: Column(
        children: [
          Container(
            width: Dimensions.screenWidth,
            height: Dimensions.height100 * 1.5,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            color: AppColors.primary1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.recommendedAccountScreen);
                  },
                  child: Icon(
                    Iconsax.user_add,
                    size: Dimensions.iconSize20 * 1.4,
                  ),
                ),
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

            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() {
                      ImageProvider? bgImage;
                      String? networkUrl =
                          authController.companyProfile.value?.profileImageUrl;
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
                                      .companyProfile
                                      .value
                                      ?.companyName
                                      ?.capitalizeFirst ??
                                  'Company',
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
                          '@${authController.companyProfile.value?.username ?? ""}',
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

        return Text(
          company?.missionStatement ?? 'No about info added yet.',
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
        return ReminderCard(
          title: event['title'] as String,
          hostName: event['host'] as String,
          hostRole: 'HOST',
          sessionType: event['type'] as String,
          dateTime: event['date'] as String,
          onPressed: () {},
          description: event['description'] as String,
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
