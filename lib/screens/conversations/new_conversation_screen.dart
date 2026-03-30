import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/conversation_controller.dart';
import 'package:smart_swatcher/models/conversation_model.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';
import 'package:smart_swatcher/widgets/app_cached_network_image.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final ConversationController controller = Get.find<ConversationController>();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadConnections();
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
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: AppColors.black1,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New chat',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w700,
                color: AppColors.black1,
              ),
            ),
            Obx(
              () => Text(
                '${_selectedIds.length}/${controller.connectionContacts.length}',
                style: TextStyle(
                  fontSize: Dimensions.font12,
                  color: AppColors.grey5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _handleDone,
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary5,
              ),
            ),
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.width15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                border: Border.all(color: AppColors.grey2),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: AppColors.grey4),
                  hintText: 'Search username',
                  hintStyle: TextStyle(
                    color: AppColors.grey4,
                    fontSize: Dimensions.font13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingConnections.value &&
                  controller.connectionContacts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary5),
                );
              }

              final filteredConnections = _filteredConnections(
                controller.connectionContacts,
              );

              if (filteredConnections.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width30,
                    ),
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? 'Your accepted connections will appear here.'
                          : 'No matching connections found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Dimensions.font13,
                        color: AppColors.grey5,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.width15,
                  0,
                  Dimensions.width15,
                  Dimensions.height20,
                ),
                itemCount: filteredConnections.length,
                separatorBuilder:
                    (_, __) => SizedBox(height: Dimensions.height10),
                itemBuilder: (context, index) {
                  final connection = filteredConnections[index];
                  final profile = connection.otherParty(
                    controller.currentActorId ?? '',
                  );
                  final imageUrl = MediaUrlHelper.resolve(
                    profile.profileImageUrl,
                  );
                  final isSelected = _selectedIds.contains(profile.id);

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      onTap: () => _toggleSelection(profile.id),
                      child: Padding(
                        padding: EdgeInsets.all(Dimensions.height15),
                        child: Row(
                          children: [
                            Container(
                              width: Dimensions.height50,
                              height: Dimensions.height50,
                              decoration: BoxDecoration(
                                color: AppColors.primary1,
                                shape: BoxShape.circle,
                                image:
                                    imageUrl != null
                                        ? DecorationImage(
                                          image:
                                              appCachedImageProvider(imageUrl)!,
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  imageUrl == null
                                      ? const Icon(
                                        Icons.person_outline,
                                        color: AppColors.primary5,
                                      )
                                      : null,
                            ),
                            SizedBox(width: Dimensions.width13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black1,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height5),
                                  Text(
                                    profile.username?.trim().isNotEmpty == true
                                        ? '@${profile.username}'
                                        : (profile.type ?? 'Connection'),
                                    style: TextStyle(
                                      fontSize: Dimensions.font12,
                                      color: AppColors.grey5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: Dimensions.height24,
                              height: Dimensions.height24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary5
                                          : AppColors.grey3,
                                ),
                                color:
                                    isSelected
                                        ? AppColors.primary5
                                        : Colors.transparent,
                              ),
                              child:
                                  isSelected
                                      ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<ConnectionRecordModel> _filteredConnections(
    List<ConnectionRecordModel> items,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items.where((connection) {
      final profile = connection.otherParty(controller.currentActorId ?? '');
      final haystack =
          <String>[
            profile.displayName,
            profile.username ?? '',
            profile.type ?? '',
          ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _handleDone() async {
    if (_selectedIds.isEmpty) {
      CustomSnackBar.failure(message: 'Select at least one connection');
      return;
    }

    final conversation = await controller.createConversationFromSelection(
      _selectedIds.toList(),
      navigate: false,
    );

    if (conversation == null) {
      return;
    }

    if (mounted) {
      Get.back();
    }

    await controller.navigateToConversation(conversation.id);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }
}
