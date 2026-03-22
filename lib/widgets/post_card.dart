import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';

import '../models/post_model.dart';
import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'snackbars.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostController postController = Get.find<PostController>();
  ScrollPosition? _scrollPosition;
  Timer? _visibilityDebounce;
  bool _impressionTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollListener();
    _scheduleVisibilityCheck(const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _visibilityDebounce?.cancel();
    _detachScrollListener();
    super.dispose();
  }

  void _attachScrollListener() {
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition == nextPosition) {
      return;
    }

    _detachScrollListener();
    _scrollPosition = nextPosition;
    _scrollPosition?.addListener(_handleScroll);
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_handleScroll);
    _scrollPosition = null;
  }

  void _handleScroll() {
    _scheduleVisibilityCheck(const Duration(milliseconds: 180));
  }

  void _scheduleVisibilityCheck(Duration delay) {
    if (_impressionTriggered || !mounted) {
      return;
    }

    _visibilityDebounce?.cancel();
    _visibilityDebounce = Timer(delay, _checkAndRecordIfVisible);
  }

  Future<void> _checkAndRecordIfVisible() async {
    if (!mounted || _impressionTriggered) {
      return;
    }

    if (!postController.canRecordImpression(widget.post.id)) {
      _impressionTriggered = true;
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final viewport = Rect.fromLTWH(
      0,
      mediaQuery.padding.top,
      mediaQuery.size.width,
      mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom,
    );
    final visibleRect = rect.intersect(viewport);
    if (visibleRect.isEmpty || rect.width <= 0 || rect.height <= 0) {
      return;
    }

    final visibleFraction =
        (visibleRect.width * visibleRect.height) / (rect.width * rect.height);
    if (visibleFraction < 0.65) {
      return;
    }

    _impressionTriggered = true;
    final recorded = await postController.recordImpression(widget.post.id);
    if (!recorded && mounted) {
      _impressionTriggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = MediaUrlHelper.resolve(
      widget.post.author?.profileImageUrl,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      width: Dimensions.screenWidth,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            profileImageUrl: profileImageUrl,
            title: widget.post.author?.name ?? '',
            subtitle: widget.post.userRole,
            timeAgo: widget.post.timeAgo,
            onProfileTap: () => _openPostAuthorProfile(
              widget.post.author?.id,
              postController,
            ),
            onMoreTap: () => _showPostOptions(
              context,
              widget.post,
              postController,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10),
              child: Text(
                widget.post.caption,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font14,
                ),
              ),
            ),
          if (widget.post.displayImageUrl != null)
            Container(
              height: Dimensions.height40 * 5,
              width: Dimensions.screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: AppColors.grey3,
                image: DecorationImage(
                  image: NetworkImage(widget.post.displayImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(height: Dimensions.height10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    widget.post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    widget.post.likeCount.toString(),
                    widget.post.isLiked ? Colors.red : AppColors.grey4,
                    () => postController.toggleLike(widget.post.id),
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    widget.post.commentCount.toString(),
                    AppColors.grey4,
                    () => Get.toNamed(
                      AppRoutes.commentsScreen,
                      arguments: widget.post,
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    widget.post.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    widget.post.saveCount.toString(),
                    widget.post.isSaved
                        ? AppColors.black1
                        : AppColors.grey4,
                    () => postController.toggleSave(widget.post.id),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  border: Border.all(color: AppColors.grey4),
                ),
                child: Icon(
                  Iconsax.send_1,
                  color: Colors.red,
                  size: Dimensions.iconSize16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormulasCard extends StatelessWidget {
  final PostModel post;

  const FormulasCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = MediaUrlHelper.resolve(post.author?.profileImageUrl);
    final postController = Get.find<PostController>();
    final formula = post.formula;
    final formulaRows = <MapEntry<String, String>>[
      if (formula?.naturalBaseLevel != null)
        MapEntry("Base Level", formula!.naturalBaseLevel.toString()),
      if (formula?.greyPercentage != null)
        MapEntry("Grey", '${formula!.greyPercentage}%'),
      if (formula?.desiredLevel != null)
        MapEntry("Desired Level", formula!.desiredLevel.toString()),
      if (formula?.desiredTone?.trim().isNotEmpty == true)
        MapEntry("Tone", formula!.desiredTone!),
      if (formula?.developerVolume != null)
        MapEntry("Developer", '${formula!.developerVolume} Vol'),
      if (formula?.mixingRatio?.trim().isNotEmpty == true)
        MapEntry("Mix Ratio", formula!.mixingRatio!),
      if (formula?.predictionImageStatus?.trim().isNotEmpty == true)
        MapEntry("Preview", formula!.predictionImageStatus!),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      width: Dimensions.screenWidth,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            profileImageUrl: profileImageUrl,
            title: post.username,
            subtitle: post.userRole,
            timeAgo: post.timeAgo,
            onProfileTap: () => _openPostAuthorProfile(post.author?.id, postController),
            onMoreTap: () => _showPostOptions(context, post, postController),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            post.caption,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          if (formula != null || post.base != null || post.lights != null || post.toner != null)
            Container(
              width: Dimensions.screenWidth,
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: AppColors.primary1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (formula != null) ...[
                    for (final row in formulaRows)
                      _buildFormulaRow(row.key, row.value),
                    if (formula.noteToStylist?.trim().isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          formula.noteToStylist!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font12,
                            color: AppColors.grey4,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ] else ...[
                    if (post.base != null) _buildFormulaRow("Base", post.base!),
                    if (post.lights != null) _buildFormulaRow("Lights", post.lights!),
                    if (post.toner != null) _buildFormulaRow("Toner", post.toner!),
                  ],
                ],
              ),
            ),
          SizedBox(height: Dimensions.height10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    post.likeCount.toString(),
                    post.isLiked ? Colors.red : AppColors.grey4,
                    () => postController.toggleLike(post.id),
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    post.commentCount.toString(),
                    AppColors.grey4,
                    () => Get.toNamed(
                      AppRoutes.commentsScreen,
                      arguments: post,
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    post.saveCount.toString(),
                    post.isSaved ? AppColors.black1 : AppColors.grey4,
                    () => postController.toggleSave(post.id),
                  ),
                ],
              ),
              Icon(
                Iconsax.send_1,
                color: Colors.red,
                size: Dimensions.iconSize20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final CommentModel comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = MediaUrlHelper.resolve(
      comment.author?.profileImageUrl,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      width: Dimensions.screenWidth,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            profileImageUrl: profileImageUrl,
            title: comment.author?.name ?? '',
            subtitle: comment.author?.username ?? '',
            timeAgo: comment.timeAgo,
            onProfileTap: () {},
            onMoreTap: () => _showGenericOptions(context),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            comment.body,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.grey4,
                size: Dimensions.iconSize16,
              ),
              const SizedBox(width: 5),
              const Text(
                "0",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
              const SizedBox(width: 20),
              Text(
                "Reply",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.profileImageUrl,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.onProfileTap,
    required this.onMoreTap,
  });

  final String? profileImageUrl;
  final String title;
  final String subtitle;
  final String timeAgo;
  final VoidCallback onProfileTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onProfileTap,
            child: Row(
              children: [
                Container(
                  height: Dimensions.height40,
                  width: Dimensions.width40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey3,
                    image: profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileImageUrl == null
                      ? Icon(Icons.person, color: AppColors.grey4)
                      : null,
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font13,
                              fontWeight: FontWeight.w300,
                              color: AppColors.grey4,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width5,
                            ),
                            child: Icon(
                              Icons.circle,
                              size: 4,
                              color: AppColors.grey4,
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font13,
                              fontWeight: FontWeight.w300,
                              color: AppColors.grey4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onMoreTap,
          child: Icon(Icons.more_horiz, color: AppColors.black1),
        ),
      ],
    );
  }
}

class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.width15),
        child: Row(
          children: [
            Icon(icon, size: Dimensions.iconSize20, color: iconColor),
            SizedBox(width: Dimensions.width10),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _actionButton(
  IconData icon,
  String count,
  Color color,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );
}

void _openPostAuthorProfile(String? authorId, PostController controller) {
  if (authorId == null || authorId.trim().isEmpty) {
    return;
  }

  if (authorId == controller.currentActorId) {
    return;
  }

  Get.toNamed(AppRoutes.otherProfileScreen, arguments: authorId);
}

Future<void> _showPostOptions(
  BuildContext context,
  PostModel post,
  PostController controller,
) async {
  final isOwnPost = controller.isOwnPost(post);

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'More',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(Icons.cancel, color: AppColors.grey4),
                    ),
                  ],
                ),
              ),
              if (isOwnPost)
                OptionTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Post',
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final shouldDelete = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('Delete post'),
                        content: const Text(
                          'This post will be removed permanently.',
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

                    if (shouldDelete == true) {
                      await controller.deletePost(post.id);
                    }
                  },
                )
              else ...[
                OptionTile(
                  icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  title: post.isSaved ? 'Unsave' : 'Save',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.toggleSave(post.id);
                  },
                ),
                OptionTile(
                  icon: CupertinoIcons.link,
                  title: 'Copy Link',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: '${AppConstants.BASE_URL}/posts/${post.id}',
                      ),
                    );
                    Navigator.pop(sheetContext);
                    CustomSnackBar.success(message: 'Post link copied');
                  },
                ),
                OptionTile(
                  icon: Icons.outlined_flag,
                  title: 'Report',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    CustomSnackBar.processing(
                      message: 'Report flow will be added next.',
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

void _showGenericOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'More',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(Icons.cancel, color: AppColors.grey4),
                    ),
                  ],
                ),
              ),
              OptionTile(
                icon: Icons.outlined_flag,
                title: 'Report',
                onTap: () {
                  Navigator.pop(sheetContext);
                  CustomSnackBar.processing(
                    message: 'Report flow will be added next.',
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
