import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/conversation_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/profile_content_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_cached_network_image.dart';
import '../../widgets/post_card.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/snackbars.dart';
import '../../widgets/tips_card.dart';

class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen({super.key});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final UserController userController = Get.find<UserController>();
  final ProfileContentController contentController =
      Get.find<ProfileContentController>();

  late final String profileId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    profileId = Get.arguments?.toString() ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userController.fetchProfile(profileId);
      final profile = userController.profile.value;
      if (profile != null && profile.id?.trim().isNotEmpty == true) {
        await contentController.loadForOwner(
          ownerId: profile.id!,
          ownerType: profile.type ?? 'stylist',
          includeProducts: profile.type == 'company',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final profile = userController.profile.value;
      if (profile == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          ),
        );
      }

      final tabs = _buildTabs(profile);

      return DefaultTabController(
        key: ValueKey('${profile.id}_${profile.type}'),
        length: tabs.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return [
                SliverToBoxAdapter(
                  child: _OtherProfileHeader(profile: profile),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      isScrollable: true,
                      indicatorColor: AppColors.accent1,
                      labelColor: AppColors.black1,
                      unselectedLabelColor: AppColors.grey4,
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.width20,
                        Dimensions.height15,
                        Dimensions.width20,
                        0,
                      ),
                      indicatorWeight: 4,
                      tabs: tabs.map((tab) => Tab(text: tab.label)).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(children: tabs.map((tab) => tab.child).toList()),
          ),
        ),
      );
    });
  }

  List<_ProfileTabItem> _buildTabs(OtherProfileModel profile) {
    final tabs = <_ProfileTabItem>[
      const _ProfileTabItem(label: 'Posts', child: _PostsTab()),
      const _ProfileTabItem(label: 'Media', child: _DisplayMediaTab()),
      const _ProfileTabItem(label: 'Tips', child: _TipsTab()),
      const _ProfileTabItem(label: 'About', child: _AboutTab()),
    ];

    if (profile.type == 'company') {
      tabs.addAll(const [
        _ProfileTabItem(label: 'Products', child: _ProductsTab()),
        _ProfileTabItem(label: 'Events', child: _EventsTab()),
      ]);
    }

    return tabs;
  }
}

class _ProfileTabItem {
  const _ProfileTabItem({required this.label, required this.child});

  final String label;
  final Widget child;
}

class _OtherProfileHeader extends StatelessWidget {
  const _OtherProfileHeader({required this.profile});

  final OtherProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final contentController = Get.find<ProfileContentController>();
    final profileUrl = controller.resolveImage(profile.profileImageUrl);
    final coverUrl = controller.resolveImage(profile.backgroundImageUrl);
    final isCompany = profile.type == 'company';

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
                    coverUrl.isNotEmpty
                        ? DecorationImage(
                          image: appCachedImageProvider(coverUrl)!,
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + Dimensions.height10,
              left: Dimensions.width10,
              child: IconButton(
                onPressed: Get.back,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: coverUrl.isNotEmpty ? Colors.white : AppColors.black1,
                ),
              ),
            ),
            if (!profile.viewer.isSelf)
              Positioned(
                top: MediaQuery.of(context).padding.top + Dimensions.height10,
                right: Dimensions.width10,
                child: _ProfileMenu(profile: profile),
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
                  image:
                      profileUrl.isNotEmpty
                          ? DecorationImage(
                            image: appCachedImageProvider(profileUrl)!,
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    profileUrl.isEmpty
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
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                '@${profile.username ?? ""}',
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
                  if (isCompany) _InfoChip(label: 'Company'),
                  if ((profile.role ?? '').trim().isNotEmpty)
                    _InfoChip(label: profile.role!),
                  if (profile.isElite == true) const _InfoChip(label: 'Elite'),
                ],
              ),
              SizedBox(height: Dimensions.height12),
              Text(
                profile.description?.trim().isNotEmpty == true
                    ? profile.description!
                    : 'No description added.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font14,
                  color: AppColors.black1.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(value: '${profile.posts ?? 0}', label: 'Posts'),
                  _StatItem(value: '${profile.likes ?? 0}', label: 'Likes'),
                  _StatItem(
                    value: '${profile.connections ?? 0}',
                    label: 'Connections',
                  ),
                ],
              ),
              if (!profile.viewer.isSelf) ...[
                SizedBox(height: Dimensions.height20),
                _ProfileActionArea(profile: profile),
              ],
              SizedBox(height: Dimensions.height10),
              if (!profile.viewer.isSelf &&
                  contentController.currentOwnerId == profile.id &&
                  contentController.currentOwnerType == profile.type)
                SizedBox(height: Dimensions.height10),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionArea extends StatelessWidget {
  const _ProfileActionArea({required this.profile});

  final OtherProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final conversationController = Get.find<ConversationController>();
    final targetId = profile.id ?? '';

    return Obx(() {
      final currentProfile = userController.profile.value ?? profile;
      final viewer = currentProfile.viewer;
      final action = viewer.primaryAction;
      final isBusy = userController.isRequestingConnection(targetId);
      final primaryLabel = viewer.primaryActionLabel;

      if (viewer.requestedByThem) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    isBusy
                        ? null
                        : () async {
                          final connectionId = viewer.connectionId;
                          if (connectionId == null ||
                              connectionId.trim().isEmpty) {
                            CustomSnackBar.failure(
                              message:
                                  'Connection request information is missing.',
                            );
                            return;
                          }

                          await userController.acceptConnection(
                            connectionId,
                            targetId: targetId,
                            refreshProfile: true,
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary5,
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                ),
                child: Text(
                  primaryLabel.isEmpty ? 'Accept' : primaryLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: OutlinedButton(
                onPressed:
                    isBusy
                        ? null
                        : () async {
                          final connectionId = viewer.connectionId;
                          if (connectionId == null ||
                              connectionId.trim().isEmpty) {
                            return;
                          }

                          await userController.declineConnection(
                            connectionId,
                            targetId: targetId,
                            refreshProfile: true,
                          );
                        },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.grey3),
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                ),
                child: const Text(
                  'Decline',
                  style: TextStyle(color: AppColors.black1),
                ),
              ),
            ),
          ],
        );
      }

      final isGhost = action == ProfilePrimaryAction.requested;
      final isEnabled = viewer.isPrimaryActionEnabled && !isBusy;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              isEnabled
                  ? () async {
                    switch (action) {
                      case ProfilePrimaryAction.connect:
                        await userController.requestConnection(
                          targetId,
                          refreshProfile: true,
                        );
                        break;
                      case ProfilePrimaryAction.accept:
                        final connectionId = viewer.connectionId;
                        if (connectionId == null ||
                            connectionId.trim().isEmpty) {
                          CustomSnackBar.failure(
                            message:
                                'Connection request information is missing.',
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
            disabledBackgroundColor:
                isGhost ? AppColors.grey2 : AppColors.grey4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius10),
            ),
            padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
          ),
          child: Text(
            primaryLabel,
            style: TextStyle(
              color: isGhost ? AppColors.grey5 : Colors.white,
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

enum _ProfileMenuAction { withdrawRequest, removeConnection, block }

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.profile});

  final OtherProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final menuColor =
        (profile.backgroundImageUrl ?? '').isNotEmpty
            ? Colors.white
            : AppColors.black1;

    return PopupMenuButton<_ProfileMenuAction>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: menuColor),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (_) {
        final items = <PopupMenuEntry<_ProfileMenuAction>>[];
        final viewer = profile.viewer;

        if (viewer.requestedByViewer && viewer.connectionId != null) {
          items.add(
            const PopupMenuItem(
              value: _ProfileMenuAction.withdrawRequest,
              child: Text('Withdraw request'),
            ),
          );
        }

        if (viewer.isConnected && viewer.connectionId != null) {
          items.add(
            const PopupMenuItem(
              value: _ProfileMenuAction.removeConnection,
              child: Text('Remove connection'),
            ),
          );
        }

        items.add(
          const PopupMenuItem(
            value: _ProfileMenuAction.block,
            child: Text('Block account'),
          ),
        );

        return items;
      },
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    _ProfileMenuAction action,
  ) async {
    final userController = Get.find<UserController>();
    final targetId = profile.id ?? '';
    final connectionId = profile.viewer.connectionId;

    switch (action) {
      case _ProfileMenuAction.withdrawRequest:
        if (connectionId == null || connectionId.trim().isEmpty) {
          return;
        }
        if (await _confirm(
          context,
          title: 'Withdraw request?',
          message: 'This pending connection request will be cancelled.',
        )) {
          await userController.deleteConnection(
            connectionId,
            targetId: targetId,
            refreshProfile: true,
            successMessage: 'Connection request withdrawn',
          );
        }
        break;
      case _ProfileMenuAction.removeConnection:
        if (connectionId == null || connectionId.trim().isEmpty) {
          return;
        }
        if (await _confirm(
          context,
          title: 'Remove connection?',
          message: 'You will no longer be connected to this account.',
        )) {
          await userController.deleteConnection(
            connectionId,
            targetId: targetId,
            refreshProfile: true,
            successMessage: 'Connection removed',
          );
        }
        break;
      case _ProfileMenuAction.block:
        if (await _confirm(
          context,
          title: 'Block account?',
          message: 'You will stop seeing each other across the app.',
        )) {
          final blocked = await userController.blockUser(
            targetId,
            closeProfile: false,
          );
          if (blocked && Get.key.currentState?.canPop() == true) {
            Get.back();
          }
        }
        break;
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final contentController = Get.find<ProfileContentController>();

    return Obx(() {
      if (controller.isFetchingProfilePosts.value &&
          controller.profilePosts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: () async {
          await controller.refreshActiveProfile();
          await contentController.refreshCurrentOwner();
        },
        child:
            controller.profilePosts.isEmpty
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
                  itemBuilder: (_, index) {
                    return PostCard(post: controller.profilePosts[index]);
                  },
                ),
      );
    });
  }
}

class _DisplayMediaTab extends StatelessWidget {
  const _DisplayMediaTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      if (controller.isLoadingMedia.value && controller.displayMedia.isEmpty) {
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

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      child: AppCachedNetworkImage(
                        imageUrl: item.url,
                        fit: BoxFit.cover,
                        enableFullscreen: true,
                        heroTag: 'other_profile_media_${item.id}',
                      ),
                    );
                  },
                ),
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
      if (controller.isLoadingTips.value && controller.tips.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child:
            controller.tips.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height40,
                  ),
                  children: [
                    Center(
                      child: Text(
                        'No tips available',
                        style: TextStyle(color: AppColors.grey4),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
      );
    });
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
      final profile = controller.profile.value;
      final aboutText =
          profile?.about?.trim().isNotEmpty == true
              ? profile!.about!
              : (profile?.description?.trim().isNotEmpty == true
                  ? profile!.description!
                  : 'No about info');

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Dimensions.width20),
        child: Text(
          aboutText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font14,
            height: 1.6,
          ),
        ),
      );
    });
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();

    return Obx(() {
      if (controller.isLoadingProducts.value && controller.products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child:
            controller.products.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height40,
                  ),
                  children: [
                    Center(
                      child: Text(
                        'No products found',
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
                    childAspectRatio: 0.7,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (_, index) {
                    final product = controller.products[index];
                    final imageUrl = MediaUrlHelper.resolve(
                      product.productImageUrl,
                    );
                    return Container(
                      padding: EdgeInsets.all(Dimensions.width10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                        border: Border.all(color: AppColors.grey2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius12,
                              ),
                              child:
                                  imageUrl == null
                                      ? Container(
                                        color: AppColors.grey2,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.inventory_2_outlined,
                                          color: AppColors.grey4,
                                        ),
                                      )
                                      : AppCachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        enableFullscreen: true,
                                        heroTag: 'other_product_${product.id}',
                                      ),
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                          Text(
                            product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font14,
                              fontWeight: FontWeight.w600,
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
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary5,
                                fontSize: Dimensions.font13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
      );
    });
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileContentController>();
    final eventController = Get.find<EventController>();

    return Obx(() {
      if (controller.isLoadingEvents.value && controller.events.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary5),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary5,
        onRefresh: controller.refreshCurrentOwner,
        child:
            controller.events.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height40,
                  ),
                  children: [
                    Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(color: AppColors.grey4),
                      ),
                    ),
                  ],
                )
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
                        sessionType:
                            event.sessionMode == 'audio'
                                ? 'A U D I O'
                                : 'I N T E R A C T I V E',
                        title: event.title ?? 'Untitled Event',
                        dateTime: eventController.formatEventDate(
                          event.scheduledStartAt,
                        ),
                        description: event.description ?? '',
                        isReminderSet: event.viewer?.isSubscribed ?? false,
                        onTap: () async {
                          await eventController.fetchSingleEvent(
                            event.id ?? '',
                          );
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
          fontFamily: 'Poppins',
          fontSize: Dimensions.font12,
          color: AppColors.primary5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: Dimensions.font14, color: AppColors.grey5),
        ),
      ],
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
