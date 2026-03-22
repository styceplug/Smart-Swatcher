import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/event_controller.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/controllers/profile_content_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/models/profile_content_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/post_card.dart';
import 'package:smart_swatcher/widgets/reminder_card.dart';
import 'package:smart_swatcher/widgets/tips_card.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile>
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
    _tabController = TabController(length: 7, vsync: this);
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
    final company = authController.companyProfile.value;
    final ownerId = company?.id;
    if (ownerId == null || ownerId.trim().isEmpty) {
      return;
    }

    if (force ||
        contentController.currentOwnerId != ownerId ||
        contentController.currentOwnerType != 'company') {
      await contentController.loadForOwner(
        ownerId: ownerId,
        ownerType: 'company',
        includeProducts: true,
      );
    }

    await Future.wait([
      postController.fetchOwnPosts(authorId: ownerId, authorType: 'company'),
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
              child: _CompanyHeader(
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
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.accent1,
                  labelColor: AppColors.black1,
                  unselectedLabelColor: AppColors.grey4,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Formulas'),
                    Tab(text: 'Posts'),
                    Tab(text: 'Tips'),
                    Tab(text: 'Media'),
                    Tab(text: 'About'),
                    Tab(text: 'Products'),
                    Tab(text: 'Events'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            _CompanyFormulasTab(),
            _CompanyPostsTab(),
            _CompanyTipsTab(),
            _CompanyMediaTab(),
            _CompanyAboutTab(),
            _CompanyProductsTab(),
            _CompanyEventsTab(),
          ],
        ),
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({
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
      final company = authController.companyProfile.value;
      final baseUrl = authController.authRepo.apiClient.baseUrl ?? '';
      final profileUrl = company?.getProfileImage(baseUrl) ?? '';
      final coverUrl = company?.getBackgroundImage(baseUrl) ?? '';

      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Dimensions.screenWidth,
                height: Dimensions.height100 * 1.65,
                decoration: BoxDecoration(
                  color: AppColors.primary1,
                  image: coverUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(coverUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    MediaQuery.of(context).padding.top + Dimensions.height15,
                    Dimensions.width20,
                    Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.recommendedAccountScreen),
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.width10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.user_add,
                            color: Colors.white,
                            size: Dimensions.iconSize20,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.editProfileScreen),
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
                                color: Colors.white,
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
                                color: Colors.white,
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
                      ? Icon(Icons.business, size: 38, color: AppColors.grey4)
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
                  company?.companyName?.capitalizeFirst ?? 'Company',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  '@${company?.username ?? ""}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    color: AppColors.grey4,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Wrap(
                  spacing: Dimensions.width10,
                  runSpacing: Dimensions.height10,
                  children: [
                    const _InfoChip(label: 'Company profile'),
                    if ((company?.role ?? '').trim().isNotEmpty)
                      _InfoChip(label: company!.role!),
                    if (company?.isVerified == true)
                      const _InfoChip(label: 'Verified'),
                  ],
                ),
                SizedBox(height: Dimensions.height12),
                Text(
                  company?.missionStatement?.trim().isNotEmpty == true
                      ? company!.missionStatement!
                      : 'No company description added yet.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    color: AppColors.black1.withValues(alpha: 0.75),
                    height: 1.5,
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

class _CompanyFormulasTab extends StatelessWidget {
  const _CompanyFormulasTab();

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
            ? _EmptyList(label: 'No formulas yet')
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: Dimensions.height15,
                  bottom: Dimensions.height80,
                ),
                itemCount: controller.allFormulations.length,
                itemBuilder: (_, index) {
                  return _CompanyFormulationCard(
                    formulation: controller.allFormulations[index],
                  );
                },
              ),
      );
    });
  }
}

class _CompanyPostsTab extends StatelessWidget {
  const _CompanyPostsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();

    return Obx(() {
      if (controller.isOwnPostsLoading.value && controller.ownPostsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: () => controller.fetchOwnPosts(authorType: 'company'),
        child: controller.ownPostsList.isEmpty
            ? _EmptyList(label: 'No posts found')
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: Dimensions.height100),
                itemCount: controller.ownPostsList.length,
                itemBuilder: (_, index) {
                  return PostCard(post: controller.ownPostsList[index]);
                },
              ),
      );
    });
  }
}

class _CompanyTipsTab extends StatelessWidget {
  const _CompanyTipsTab();

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
                ? _EmptyList(label: 'No tips yet')
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
              heroTag: 'company_tips_fab',
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
                    decoration: const InputDecoration(hintText: 'Tip title'),
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

class _CompanyMediaTab extends StatelessWidget {
  const _CompanyMediaTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child: controller.displayMedia.isEmpty
            ? _EmptyList(label: 'No media found')
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

class _CompanyAboutTab extends StatelessWidget {
  const _CompanyAboutTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(Dimensions.width20),
      child: Obx(() {
        final company = controller.companyProfile.value;
        final aboutText = company?.about?.trim().isNotEmpty == true
            ? company!.about!
            : (company?.missionStatement?.trim().isNotEmpty == true
                ? company!.missionStatement!
                : 'No about info added yet.');

        return Text(
          aboutText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font14,
            height: 1.6,
          ),
        );
      }),
    );
  }
}

class _CompanyProductsTab extends StatelessWidget {
  const _CompanyProductsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child: controller.products.isEmpty
            ? _EmptyList(label: 'No products found')
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(Dimensions.width20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: Dimensions.width15,
                  mainAxisSpacing: Dimensions.height15,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.products.length,
                itemBuilder: (_, index) {
                  final product = controller.products[index];
                  return _ProductCard(product: product);
                },
              ),
      );
    });
  }
}

class _CompanyEventsTab extends StatelessWidget {
  const _CompanyEventsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();
    final eventController = Get.find<EventController>();

    return Obx(() {
      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child: controller.events.isEmpty
            ? _EmptyList(label: 'No events found')
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                itemCount: controller.events.length,
                itemBuilder: (_, index) {
                  final event = controller.events[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height15),
                    child: ReminderCard(
                      hostName: event.creator?.name ?? 'Host',
                      hostRole: event.creator?.role ?? 'Host',
                      sessionType: event.audioOnly == true ? 'A U D I O' : 'L I V E',
                      title: event.title ?? 'Untitled Event',
                      dateTime: eventController.formatEventDate(
                        event.scheduledStartAt,
                      ),
                      description: event.description ?? '',
                      isReminderSet: event.viewer?.isSubscribed ?? false,
                      onTap: () async {
                        await eventController.fetchSingleEvent(event.id ?? '');
                        Get.toNamed(AppRoutes.shareSpaceScreen);
                      },
                      onReminderTap: () async {
                        await eventController.toggleSubscription(event);
                      },
                    ),
                  );
                },
              ),
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = MediaUrlHelper.resolve(product.productImageUrl);

    return Container(
      padding: EdgeInsets.all(Dimensions.width10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radius12),
              child: imageUrl == null
                  ? Container(
                      color: AppColors.grey2,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.grey4,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      width: double.infinity,
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
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            product.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.font14,
            ),
          ),
          SizedBox(height: Dimensions.height5),
          Text(
            product.description?.trim().isNotEmpty == true
                ? product.description!
                : product.visibility,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.grey4,
              fontSize: Dimensions.font12,
            ),
          ),
          if (product.price != null) ...[
            SizedBox(height: Dimensions.height8),
            Text(
              'N${product.price!.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.primary5,
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanyFormulationCard extends StatelessWidget {
  const _CompanyFormulationCard({required this.formulation});

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

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height40,
      ),
      children: [
        Center(
          child: Text(
            label,
            style: TextStyle(color: AppColors.grey4),
          ),
        ),
      ],
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
