import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/controllers/conversation_controller.dart';
import 'package:smart_swatcher/models/conversation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/app_cached_network_image.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationController controller = Get.find<ConversationController>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.bootstrap();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        foregroundColor: AppColors.black1,
        titleSpacing: Dimensions.width10,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: AppColors.grey4,
                      fontSize: Dimensions.font14,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: AppColors.black1,
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                  ),
                )
                : Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black1,
                  ),
                ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.newConversationScreen),
            icon: const Icon(Icons.add_circle_outline),
          ),
          SizedBox(width: Dimensions.width10),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Dimensions.height65),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              0,
              Dimensions.width20,
              Dimensions.height12,
            ),
            child: Obx(
              () => Row(
                children: [
                  _ConversationTabButton(
                    label: 'Personal',
                    count: controller.personalConversations.length,
                    isSelected: controller.selectedTab.value == 'personal',
                    onTap: () => controller.setSelectedTab('personal'),
                  ),
                  SizedBox(width: Dimensions.width15),
                  _ConversationTabButton(
                    label: 'Groups',
                    count: controller.groupConversations.length,
                    isSelected: controller.selectedTab.value == 'groups',
                    onTap: () => controller.setSelectedTab('groups'),
                  ),
                  SizedBox(width: Dimensions.width15),
                  _ConversationTabButton(
                    label: 'Threads',
                    count: controller.threadConversations.length,
                    isSelected: controller.selectedTab.value == 'threads',
                    onTap: () => controller.setSelectedTab('threads'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingConversations.value &&
            controller.conversations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          );
        }

        if (controller.selectedTab.value == 'threads') {
          return _UnsupportedThreadsState(query: controller.searchQuery.value);
        }

        final items =
            controller.selectedTab.value == 'groups'
                ? controller.groupConversations
                : controller.personalConversations;

        return RefreshIndicator(
          color: AppColors.primary5,
          onRefresh:
              () => controller.loadConversations(
                forceApi: !controller.isSocketConnected,
              ),
          child:
              items.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height40,
                    ),
                    children: [
                      _EmptyConversationState(
                        title:
                            controller.searchQuery.value.trim().isEmpty
                                ? 'No conversations yet'
                                : 'No results found',
                        message:
                            controller.searchQuery.value.trim().isEmpty
                                ? 'Your chats will show up here once you connect and start messaging.'
                                : 'Try a different name, username, or message keyword.',
                      ),
                    ],
                  )
                  : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(item),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD93A2F),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        child: _ConversationListItem(
                          conversation: item,
                          currentActorId: controller.currentActorId,
                          onTap:
                              () => controller.navigateToConversation(item.id),
                        ),
                      );
                    },
                    separatorBuilder:
                        (_, __) => SizedBox(height: Dimensions.height10),
                    itemCount: items.length,
                  ),
        );
      }),
    );
  }

  Future<bool?> _confirmDelete(ConversationSummaryModel conversation) {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete chat'),
        content: Text(
          'This will remove "${conversation.displayTitle(controller.currentActorId)}" for all participants.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD93A2F)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        controller.setSearchQuery('');
      }
    });
  }
}

class _ConversationTabButton extends StatelessWidget {
  const _ConversationTabButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary5 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: TextStyle(
            color: isSelected ? AppColors.primary5 : AppColors.grey4,
            fontSize: Dimensions.font13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ConversationListItem extends StatelessWidget {
  const _ConversationListItem({
    required this.conversation,
    required this.currentActorId,
    required this.onTap,
  });

  final ConversationSummaryModel conversation;
  final String? currentActorId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        conversation.isGroup
            ? null
            : MediaUrlHelper.resolve(
              conversation
                  .otherParticipant(currentActorId)
                  ?.profile
                  .profileImageUrl,
            );

    final timestamp =
        conversation.lastMessage?.createdAt ?? conversation.updatedAt;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Dimensions.height15),
          child: Row(
            children: [
              _ConversationAvatar(
                imageUrl: avatarUrl,
                isGroup: conversation.isGroup,
              ),
              SizedBox(width: Dimensions.width13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.displayTitle(currentActorId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black1,
                            ),
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(
                              fontSize: Dimensions.font10,
                              color: AppColors.grey4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height5),
                    Text(
                      conversation.displaySubtitle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Dimensions.font12,
                        color: AppColors.grey5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) {
      return DateFormat('HH:mm').format(local);
    }
    if (diffDays == 1) {
      return 'Yesterday';
    }
    if (diffDays < 7) {
      return DateFormat('EEEE').format(local);
    }
    return DateFormat('dd/MM/yyyy').format(local);
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.imageUrl, required this.isGroup});

  final String? imageUrl;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.height50,
      height: Dimensions.height50,
      decoration: BoxDecoration(
        color: AppColors.primary1,
        shape: BoxShape.circle,
        image:
            imageUrl != null
                ? DecorationImage(
                  image: appCachedImageProvider(imageUrl)!,
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          imageUrl == null
              ? Icon(
                isGroup ? Icons.group_outlined : Icons.person_outline,
                color: AppColors.primary5,
              )
              : null,
    );
  }
}

class _EmptyConversationState extends StatelessWidget {
  const _EmptyConversationState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.height40),
      child: Column(
        children: [
          Container(
            width: Dimensions.height70,
            height: Dimensions.height70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary1,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary5,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w700,
              color: AppColors.black1,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimensions.font13,
              color: AppColors.grey5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsupportedThreadsState extends StatelessWidget {
  const _UnsupportedThreadsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height40,
      ),
      children: [
        _EmptyConversationState(
          title:
              query.trim().isEmpty
                  ? 'Threads not available yet'
                  : 'No threads found',
          message:
              query.trim().isEmpty
                  ? 'The current backend only supports personal and group conversations.'
                  : 'Threads are not supported by the current API.',
        ),
      ],
    );
  }
}
