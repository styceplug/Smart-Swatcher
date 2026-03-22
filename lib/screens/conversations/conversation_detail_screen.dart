import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/controllers/conversation_controller.dart';
import 'package:smart_swatcher/models/conversation_model.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final ConversationController controller = Get.find<ConversationController>();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String conversationId;

  @override
  void initState() {
    super.initState();
    conversationId = Get.arguments?.toString() ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.openConversationById(conversationId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    controller.clearActiveConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final conversation = controller.activeConversation.value;

      if (conversation == null && controller.isLoadingMessages.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          ),
        );
      }

      final title = conversation?.displayTitle(controller.currentActorId) ?? 'Chat';
      final subtitle = conversation == null
          ? ''
          : conversation.isGroup
              ? '${conversation.participants.length} members'
              : conversation.otherParticipant(controller.currentActorId)?.profile.username !=
                      null
                  ? '@${conversation.otherParticipant(controller.currentActorId)!.profile.username}'
                  : 'Private chat';

      final avatarUrl = conversation?.isGroup == true
          ? null
          : MediaUrlHelper.resolve(
              conversation?.otherParticipant(controller.currentActorId)
                  ?.profile
                  .profileImageUrl,
            );
      final otherProfileId = conversation?.isGroup == true
          ? null
          : conversation?.otherParticipant(controller.currentActorId)?.profile.id;

      if (controller.activeMessages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }

      return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.black1,
          titleSpacing: 0,
          title: InkWell(
            onTap: otherProfileId == null
                ? null
                : () => Get.toNamed(
                      AppRoutes.otherProfileScreen,
                      arguments: otherProfileId,
                    ),
            child: Row(
              children: [
                Container(
                  width: Dimensions.height40,
                  height: Dimensions.height40,
                  decoration: BoxDecoration(
                    color: AppColors.primary1,
                    shape: BoxShape.circle,
                    image: avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarUrl == null
                      ? Icon(
                          conversation?.isGroup == true
                              ? Icons.group_outlined
                              : Icons.person_outline,
                          color: AppColors.primary5,
                        )
                      : null,
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.font15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black1,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Dimensions.font12,
                            color: AppColors.grey5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showComingSoon,
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              onPressed: _showComingSoon,
              icon: const Icon(Icons.videocam_outlined),
            ),
            SizedBox(width: Dimensions.width10),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: controller.isLoadingMessages.value &&
                      controller.activeMessages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary5,
                      ),
                    )
                  : controller.activeMessages.isEmpty
                      ? _EmptyChatState(title: title)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width15,
                            vertical: Dimensions.height20,
                          ),
                          itemCount: controller.activeMessages.length,
                          itemBuilder: (context, index) {
                            final message = controller.activeMessages[index];
                            final previous = index > 0
                                ? controller.activeMessages[index - 1]
                                : null;

                            final widgets = <Widget>[];
                            if (_shouldShowDateHeader(previous, message)) {
                              widgets.add(
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: Dimensions.height12,
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Dimensions.width13,
                                        vertical: Dimensions.height5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radius20,
                                        ),
                                      ),
                                      child: Text(
                                        _formatDateHeader(message.createdAt),
                                        style: TextStyle(
                                          fontSize: Dimensions.font10,
                                          color: AppColors.grey5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            widgets.add(
                              _MessageBubble(
                                message: message,
                                isMine: message.sender.id ==
                                    controller.currentActorId,
                              ),
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: widgets,
                            );
                          },
                        ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width15,
                Dimensions.height10,
                Dimensions.width15,
                Dimensions.height10 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showComingSoon,
                    icon: const Icon(Icons.attach_file_outlined),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey1,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: TextField(
                        controller: _composerController,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                            color: AppColors.grey4,
                            fontSize: Dimensions.font13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showComingSoon,
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    onPressed: _showComingSoon,
                    icon: const Icon(Icons.mic_none_outlined),
                  ),
                  IconButton(
                    onPressed: controller.isSendingMessage.value
                        ? null
                        : _handleSend,
                    icon: controller.isSendingMessage.value
                        ? SizedBox(
                            width: Dimensions.iconSize16,
                            height: Dimensions.iconSize16,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary5,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.primary5,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _handleSend() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _composerController.clear();
    await controller.sendTextMessage(conversationId, text);
    _scrollToBottom();
  }

  void _showComingSoon() {
    CustomSnackBar.processing(
      message: 'Media, voice, and in-chat calling will be added next.',
    );
  }

  bool _shouldShowDateHeader(
    ConversationMessageModel? previous,
    ConversationMessageModel current,
  ) {
    if (current.createdAt == null) {
      return previous == null;
    }

    if (previous?.createdAt == null) {
      return true;
    }

    final left = current.createdAt!.toLocal();
    final right = previous!.createdAt!.toLocal();

    return left.year != right.year ||
        left.month != right.month ||
        left.day != right.day;
  }

  String _formatDateHeader(DateTime? value) {
    if (value == null) {
      return 'Today';
    }

    return DateFormat('EEE, d MMM').format(value.toLocal()).toUpperCase();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final ConversationMessageModel message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.primary3 : Colors.white;
    final textColor = isMine ? Colors.white : AppColors.black1;
    final media = message.media;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimensions.height15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.width10,
                    bottom: Dimensions.height5,
                  ),
                  child: Text(
                    message.sender.displayName,
                    style: TextStyle(
                      fontSize: Dimensions.font10,
                      color: AppColors.grey5,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (media.isNotEmpty) ...[
                      ...media.map((item) => Padding(
                            padding: EdgeInsets.only(
                              bottom: message.hasText
                                  ? Dimensions.height10
                                  : 0,
                            ),
                            child: _MessageMediaView(
                              media: item,
                              isMine: isMine,
                            ),
                          )),
                    ],
                    if (message.hasText)
                      Text(
                        message.text!.trim(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: Dimensions.font13,
                          height: 1.45,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: Dimensions.height5,
                  left: Dimensions.width10,
                  right: Dimensions.width10,
                ),
                child: Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: Dimensions.font10,
                    color: AppColors.grey5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    return DateFormat('HH:mm').format(value.toLocal());
  }
}

class _MessageMediaView extends StatelessWidget {
  const _MessageMediaView({
    required this.media,
    required this.isMine,
  });

  final ConversationMediaModel media;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = MediaUrlHelper.resolve(media.url);

    if (media.mediaType == MessageMediaType.image && resolvedUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width13,
        vertical: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary4 : AppColors.grey1,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            media.mediaType == MessageMediaType.audio ||
                    media.mediaType == MessageMediaType.voice
                ? Icons.graphic_eq
                : Icons.insert_drive_file_outlined,
            color: isMine ? Colors.white : AppColors.primary5,
          ),
          SizedBox(width: Dimensions.width10),
          Flexible(
            child: Text(
              media.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMine ? Colors.white : AppColors.black1,
                fontSize: Dimensions.font12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Dimensions.height70,
              height: Dimensions.height70,
              decoration: const BoxDecoration(
                color: AppColors.primary1,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                color: AppColors.primary5,
              ),
            ),
            SizedBox(height: Dimensions.height15),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w700,
                color: AppColors.black1,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Start the conversation with $title.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font13,
                color: AppColors.grey5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
