import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/controllers/profile_content_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/post_card.dart';
import 'package:smart_swatcher/widgets/tips_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AuthController authController = Get.find<AuthController>();
  final PostController postController = Get.find<PostController>();
  final ClientFolderController folderController =
      Get.find<ClientFolderController>();
  final ProfileContentController contentController =
      Get.find<ProfileContentController>();

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureOwnContentLoaded(force: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _ensureOwnContentLoaded({bool force = false}) async {
    final profile = authController.stylistProfile.value;
    final ownerId = profile?.id;
    if (ownerId == null || ownerId.trim().isEmpty) {
      return;
    }

    if (force ||
        contentController.currentOwnerId != ownerId ||
        contentController.currentOwnerType != 'stylist') {
      await contentController.loadForOwner(
        ownerId: ownerId,
        ownerType: 'stylist',
        includeProducts: false,
      );
    }

    await Future.wait([
      postController.fetchOwnPosts(authorId: ownerId, authorType: 'stylist'),
      contentController.loadAcceptedConnectionsCount(),
      folderController.fetchAllFormulations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _ensureOwnContentLoaded();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                authController: authController,
                postController: postController,
                folderController: folderController,
                contentController: contentController,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.accent1,
                  labelColor: AppColors.black1,
                  unselectedLabelColor: AppColors.grey4,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Formulas'),
                    Tab(text: 'Posts'),
                    Tab(text: 'Tips'),
                    Tab(text: 'Media'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            _FormulasTab(),
            _PostsTab(),
            _TipsTab(),
            _MediaTab(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.authController,
    required this.postController,
    required this.folderController,
    required this.contentController,
  });

  final AuthController authController;
  final PostController postController;
  final ClientFolderController folderController;
  final ProfileContentController contentController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = authController.stylistProfile.value;
      final imageUrl = profile?.getProfileImage(AppConstants.BASE_URL);
      final location = [
        profile?.state,
        profile?.country,
      ].where((item) => item != null && item.trim().isNotEmpty).join(', ');

      return Column(
        children: [
          CustomAppbar(
            customTitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.recommendedAccountScreen),
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
                        height: Dimensions.height20 * 1.2,
                        width: Dimensions.width20 * 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height10,
              Dimensions.width20,
              Dimensions.height20,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: Dimensions.height70,
                      width: Dimensions.width70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey2,
                        image: imageUrl != null && imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.grey4,
                            )
                          : null,
                    ),
                    SizedBox(width: Dimensions.width20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.fullName?.capitalizeFirst ?? 'Stylist',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            '@${profile?.username ?? ""}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font14,
                              color: AppColors.grey4,
                            ),
                          ),
                          if ((profile?.saloonName ?? '').trim().isNotEmpty) ...[
                            SizedBox(height: Dimensions.height8),
                            _InfoChip(label: profile!.saloonName!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height15),
                Text(
                  location.isNotEmpty
                      ? location
                      : 'Complete your profile to show your location.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    color: AppColors.black1.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      value: '${folderController.allFormulations.length}',
                      label: 'Formulas',
                    ),
                    _Divider(),
                    _StatItem(
                      value: '${contentController.acceptedConnectionsCount.value}',
                      label: 'Networks',
                    ),
                    _Divider(),
                    _StatItem(
                      value: '${postController.ownPostsList.length}',
                      label: 'Posts',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _FormulasTab extends StatelessWidget {
  const _FormulasTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientFolderController>();

    return Obx(() {
      if (controller.isFetchingAllFormulations.value &&
          controller.allFormulations.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.fetchAllFormulations,
        child: controller.allFormulations.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height40,
                ),
                children: [
                  Center(
                    child: Text(
                      'No formulas yet',
                      style: TextStyle(color: AppColors.grey4),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: Dimensions.height15,
                  bottom: Dimensions.height80,
                ),
                itemCount: controller.allFormulations.length,
                itemBuilder: (_, index) {
                  return _FormulationCard(
                    formulation: controller.allFormulations[index],
                  );
                },
              ),
      );
    });
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();

    return Obx(() {
      if (controller.isOwnPostsLoading.value && controller.ownPostsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary5,
            onRefresh: () => controller.fetchOwnPosts(authorType: 'stylist'),
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
                          'No posts found',
                          style: TextStyle(color: AppColors.grey4),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: Dimensions.height100),
                    itemCount: controller.ownPostsList.length,
                    itemBuilder: (_, index) {
                      return PostCard(post: controller.ownPostsList[index]);
                    },
                  ),
          ),
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

class _TipsTab extends StatelessWidget {
  const _TipsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      return Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary5,
            onRefresh: controller.refreshCurrentOwner,
            child: controller.tips.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height40,
                    ),
                    children: [
                      Center(
                        child: Text(
                          'No tips yet',
                          style: TextStyle(color: AppColors.grey4),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: Dimensions.height100),
                    itemCount: controller.tips.length,
                    itemBuilder: (_, index) {
                      final tip = controller.tips[index];
                      return TipsCard(
                        title: tip.title,
                        description: tip.description,
                        saves: tip.saves,
                        isSaved: tip.isSaved,
                        onSave: () => controller.toggleTipSave(tip.id),
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: Dimensions.height20,
            right: Dimensions.width20,
            child: FloatingActionButton(
              heroTag: 'tips_fab',
              backgroundColor: AppColors.primary5,
              onPressed: () => _showCreateTipSheet(context),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.white,
                size: Dimensions.iconSize20,
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showCreateTipSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String visibility = 'General';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                MediaQuery.of(context).viewInsets.bottom + Dimensions.height20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create tip',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Dimensions.font18,
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Tip title',
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                  TextField(
                    controller: descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Share the tip details',
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),
                  Wrap(
                    spacing: Dimensions.width10,
                    children: ['General', 'Elite'].map((value) {
                      final selected = visibility == value;
                      return ChoiceChip(
                        label: Text(value),
                        selected: selected,
                        onSelected: (_) {
                          setSheetState(() {
                            visibility = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: Dimensions.height20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Get.find<ProfileContentController>().createTip(
                          title: titleController.text,
                          description: descriptionController.text,
                          visibility: visibility,
                        );
                        if (Navigator.of(sheetContext).canPop()) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary5,
                      ),
                      child: const Text(
                        'Publish tip',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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

class _MediaTab extends StatelessWidget {
  const _MediaTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child: controller.displayMedia.isEmpty
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
                  crossAxisSpacing: Dimensions.width15,
                  mainAxisSpacing: Dimensions.height15,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.displayMedia.length,
                itemBuilder: (_, index) {
                  final item = controller.displayMedia[index];
                  final imageUrl = MediaUrlHelper.resolve(item.url);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    child: imageUrl == null
                        ? Container(
                            color: AppColors.grey2,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.grey4,
                            ),
                          )
                        : Image.network(
                            imageUrl,
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

class _FormulationCard extends StatelessWidget {
  const _FormulationCard({required this.formulation});

  final FormulationModel formulation;

  @override
  Widget build(BuildContext context) {
    final imageUrl = MediaUrlHelper.resolve(
      formulation.hasPredictionImage
          ? formulation.predictionImageUrl
          : formulation.imageUrl,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimensions.width20,
        0,
        Dimensions.width20,
        Dimensions.height15,
      ),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radius12),
            child: imageUrl == null
                ? Container(
                    width: Dimensions.width100,
                    height: Dimensions.height100,
                    color: AppColors.grey2,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, color: AppColors.grey4),
                  )
                : Image.network(
                    imageUrl,
                    width: Dimensions.width100,
                    height: Dimensions.height100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: Dimensions.width100,
                      height: Dimensions.height100,
                      color: AppColors.grey2,
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image, color: AppColors.grey4),
                    ),
                  ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NBL ${formulation.naturalBaseLevel} • DL ${formulation.desiredLevel}',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height8),
                Text(
                  formulation.desiredTone?.trim().isNotEmpty == true
                      ? formulation.desiredTone!
                      : 'Formulation',
                  style: TextStyle(
                    color: AppColors.grey4,
                    fontSize: Dimensions.font13,
                  ),
                ),
                SizedBox(height: Dimensions.height8),
                Text(
                  formulation.noteToStylist?.trim().isNotEmpty == true
                      ? formulation.noteToStylist!
                      : 'Saved formulation',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grey5,
                    fontSize: Dimensions.font12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width10,
        vertical: Dimensions.height5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary5.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Dimensions.font12,
          color: AppColors.primary5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font17,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font14,
            color: AppColors.grey5,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Dimensions.height10 * 4.5,
      color: AppColors.grey2,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
