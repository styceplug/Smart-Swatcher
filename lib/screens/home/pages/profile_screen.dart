import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/post_card.dart';

import '../../../models/post_model.dart';
import '../../../routes/routes.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/tips_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

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

  void showSwatchBadge() {
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
            color: Color(0XFF75A2B6).withOpacity(0.3),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AppConstants.getBadgeAsset('swatch-bg')),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Swatchsmith',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Text(
                  'Earned by creators of quality formulas. Unlock faster as more people save or use them.',
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
                AppConstants.getBadgeAsset('swatcher-verified'),
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

  void showLaureateBadge() {
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
            color: Color(0XFFD4A391).withOpacity(0.3),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AppConstants.getBadgeAsset('laureate-bg')),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The Laureate',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Text(
                  'Awarded to active and helpful members. Unlock it through likes, comments, and saves',
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
                AppConstants.getBadgeAsset('laureate'),
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

  void showSwatcherVerifiedBadge() {
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
            color: Color(0XFFF2A646).withOpacity(0.3),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                AppConstants.getBadgeAsset('swatcher-verified-bg'),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Swatcher Verified',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Text(
                  'Given to verified pros or brand ambassadors. Their profile shows a gold glow with this badge',
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
                AppConstants.getBadgeAsset('swatcher-verified'),
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
    super.build(context);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, Dimensions.height20),
                child: Column(
                  children: [
                    CustomAppbar(
                      customTitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Iconsax.user_add,
                            size: Dimensions.iconSize20 * 1.4,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: (){
                                  Get.toNamed(AppRoutes.editProfileScreen);
                                },
                                child: Image.asset(
                                  AppConstants.getPngAsset('edit-icon'),
                                  height: Dimensions.height20,
                                  width: Dimensions.width20,
                                ),
                              ),
                              SizedBox(width: Dimensions.width20),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.settingsScreen);
                                },
                                child: Image.asset(AppConstants.getPngAsset('settings-icon'),
                                  height: Dimensions.height20*1.3,
                                  width: Dimensions.width20*1.3,
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
                      width: Dimensions.screenWidth,
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.grey3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: Dimensions.height70,
                                width: Dimensions.width70,
                                decoration: BoxDecoration(
                                  color: AppColors.grey3,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: Dimensions.width20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sophy Anderson',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height5),
                                  Text(
                                    'sophy_anderszn',
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showSwatchBadge();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.width10,
                                      vertical: Dimensions.height5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.grey4,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radius20,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'SWATCHSMITH',
                                          style: TextStyle(
                                            color: AppColors.grey4,
                                            fontSize: Dimensions.font14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        SizedBox(width: Dimensions.width10),
                                        Image.asset(
                                          AppConstants.getPngAsset(
                                            'swatch-smith',
                                          ),
                                          height: Dimensions.height15,
                                          width: Dimensions.width15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: Dimensions.width10),
                                InkWell(
                                  onTap: () {
                                    showLaureateBadge();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.width10,
                                      vertical: Dimensions.height5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.grey4,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radius20,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppConstants.getPngAsset('laurette'),
                                          height: Dimensions.height15,
                                          width: Dimensions.width15,
                                        ),
                                        SizedBox(width: Dimensions.width10),
                                        Text(
                                          'THE LAURETTE',
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
                                ),
                                SizedBox(width: Dimensions.width10),
                                InkWell(
                                  onTap: () {
                                    showSwatcherVerifiedBadge();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.width10,
                                      vertical: Dimensions.height5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.grey4,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radius20,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppConstants.getBadgeAsset(
                                            'swatcher-verified',
                                          ),
                                          height: Dimensions.height15,
                                          width: Dimensions.width15,
                                        ),
                                        SizedBox(width: Dimensions.width10),
                                        Text(
                                          'SWATCHER VERIFIED',
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '128',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      'Formulars',
                                      style: TextStyle(
                                        fontSize: Dimensions.font14,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                        color: AppColors.grey5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: Dimensions.width5 / Dimensions.width5,
                                  height: Dimensions.height50,
                                  color: AppColors.grey2,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '4.2K',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      'Networks',
                                      style: TextStyle(
                                        fontSize: Dimensions.font14,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                        color: AppColors.grey5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: Dimensions.width5 / Dimensions.width5,
                                  height: Dimensions.height50,
                                  color: AppColors.grey2,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '256',
                                      style: TextStyle(
                                        fontSize: Dimensions.font17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      'Posts',
                                      style: TextStyle(
                                        fontSize: Dimensions.font14,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                        color: AppColors.grey5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.height20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              floating: true,
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
          children: [formulasTab(), feedScreen(), tipsTab(), mediaTab()],
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

Widget formulasTab() {
  final List<Map<String, dynamic>> postsData = [
    {
      "username": "Jakobjelling",
      "role": "Color Specialist",
      "timeAgo": "2h ago",
      "content":
          "Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante.",
      "likes": 124,
      "comments": 65,
      "bookmarks": 32,
      "imageUrl": "https://picsum.photos/200/300",
      "base": "6N + 6G (1:1)",
      "lights": "30vol + Bond Protector",
      "toner": "9NB + 10V (2:1)",
    },
    {
      "username": "JaneDoe",
      "role": "Hair Stylist",
      "timeAgo": "5h ago",
      "content": "This is another post!",
      "likes": 90,
      "comments": 12,
      "bookmarks": 5,
      "base": "5N",
      "lights": "20vol",
      "toner": "8A + 9V",
    },
  ];

  final List<PostModel> posts =
      postsData.map((item) {
        return PostModel(
          username: item["username"] ?? "",
          role: item["role"] ?? "",
          timeAgo: item["timeAgo"] ?? "",
          content: item["content"] ?? "",
          likes: (item["likes"] ?? 0) as int,
          comments: (item["comments"] ?? 0) as int,
          bookmarks: (item["bookmarks"] ?? 0) as int,
          imageUrl: item["imageUrl"],
          base: item["base"] ?? "",
          lights: item["lights"] ?? "",
          toner: item["toner"] ?? "",
        );
      }).toList();

  return Container(
    child: Column(
      children: [
        Expanded(
          child: Container(
            width: Dimensions.screenWidth,
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final p = posts[index];
                      return PostCard(post: p);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget feedScreen() {
  final List<Map<String, dynamic>> alerts = [
    {
      "title": "Best Toning Sequence for Level 9",
      "description":
          "Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante.",
      "indicators": [Colors.grey, Colors.blue, Colors.grey],
      "action": "Bookmark",
    },
    {
      "title": "How to Maintain Level 7 Ash Tone",
      "description": "Quick tips on maintaining ash tones without brassiness.",
      "indicators": [Colors.blue, Colors.grey, Colors.grey],
      "action": "Save",
    },
    {
      "title": "New Styling Guide",
      "description": "Discover trendy styles for 2025 with simple steps.",
      "indicators": [Colors.grey, Colors.grey, Colors.blue],
      "action": "Read More",
    },
  ];
  final postsData = [
    {
      "username": "Jakobjelling",
      "role": "Color Specialist",
      "timeAgo": "2h ago",
      "content":
          "Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante. Pellentesque scelerisque malesuada arcu integer sapien.",
      "likes": 124,
      "comments": 65,
      "bookmarks": 32,
      "imageUrl": "https://picsum.photos/200/300",
    },
    {
      "username": "JaneDoe",
      "role": "Hair Stylist",
      "timeAgo": "5h ago",
      "content": "This is another post!",
      "likes": 90,
      "comments": 12,
      "bookmarks": 5,
    },
  ];
  final List<PostModel> posts =
      postsData.map((item) {
        return PostModel(
          username: item["username"] as String? ?? "",
          role: item["role"] as String? ?? "",
          timeAgo: item["timeAgo"] as String? ?? "",
          content: item["content"] as String? ?? "",
          likes: item["likes"] as int? ?? 0,
          comments: item["comments"] as int? ?? 0,
          bookmarks: item["bookmarks"] as int? ?? 0,
          imageUrl: item["imageUrl"] as String?,
        );
      }).toList();
  return Container(
    width: Dimensions.screenWidth,
    child: Stack(
      children: [
        Container(
          width: Dimensions.screenWidth,
          height: Dimensions.screenHeight,
          padding: EdgeInsets.only(bottom: Dimensions.height50),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final p = posts[index];
                    return PostCard(post: p);
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: Dimensions.height70,

          right: Dimensions.width20,

          child: Container(
            height: Dimensions.height50,
            width: Dimensions.width50,
            decoration: BoxDecoration(
              color: AppColors.primary5,
              shape: BoxShape.circle,
            ),
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

Widget tipsTab() {
  List<Map<String, dynamic>> tips = [
    {
      "title": "Balance Warmth",
      "description":
          "Hair dye passes the cuticle to reach the cortex, and developer helps open the cuticle so color.",
      "saves": 124,
      "isSaved": true,
    },
    {
      "title": "Protect Your Hair",
      "description":
          "Use a toner to keep your hair color fresh and reduce brassiness.",
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
        onSave: () {
          // Handle save click (setState if needed)
          print("Saved tip: ${tip["title"]}");
        },
      );
    },
  );
}

Widget mediaTab() {
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: Dimensions.height20,
      horizontal: Dimensions.width20,
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: Dimensions.height100 * 2,
              width: Dimensions.screenWidth / 2.5,
              decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
            Container(
              height: Dimensions.height100 * 2,
              width: Dimensions.screenWidth / 2.5,
              decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: Dimensions.height100 * 2,
              width: Dimensions.screenWidth / 2.5,
              decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
            Container(
              height: Dimensions.height100 * 2,
              width: Dimensions.screenWidth / 2.5,
              decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
