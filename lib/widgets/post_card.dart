import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';

import '../models/post_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    PostController postController = Get.find<PostController>();
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
          // --- HEADER ---
          Row(
            children: [
              // Avatar
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,
                  image:
                      post.userProfileImage.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(post.author?.profileImageUrl ?? ''),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    post.userProfileImage.isEmpty
                        ? Icon(Icons.person, color: AppColors.grey4)
                        : null,
              ),
              SizedBox(width: Dimensions.width10),

              // Name & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author!.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          post.userRole,
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
                          post.timeAgo,
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

              // Menu Button
              InkWell(
                onTap: () => _showMoreOptions(context),
                child: Icon(Icons.more_horiz, color: AppColors.black1),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // --- CAPTION ---
          if (post.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10),
              child: Text(
                post.caption,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font14,
                ),
              ),
            ),

          // --- IMAGE ---
          if (post.displayImageUrl != null)
            Container(
              height: Dimensions.height40 * 5,
              width: Dimensions.screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: AppColors.grey3,
                image: DecorationImage(
                  image: NetworkImage(post.displayImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          SizedBox(height: Dimensions.height10),

          // --- ACTIONS ROW ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,

                    post.likeCount.toString(),

                    post.isLiked ? Colors.red : AppColors.grey4,
                    () {
                      postController.toggleLike(post.id);
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    post.commentCount.toString(),
                    AppColors.grey4,
                    () {
                      Get.toNamed(AppRoutes.commentsScreen, arguments: post);
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    post.saveCount.toString(),
                    post.isSaved ? AppColors.black1 : AppColors.grey4,
                    () {
                      postController.toggleSave(post.id);
                    },
                  ),
                ],
              ),
              // Share Button
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
          // --- HEADER ---
          Row(
            children: [
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,
                  image:
                      post.userProfileImage.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(post.displayImageUrl ?? ''),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          post.userRole,
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
                          post.timeAgo,
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
              InkWell(
                onTap: () => _showMoreOptions(context),
                child: Icon(Icons.more_horiz),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // --- CAPTION ---
          Text(
            post.caption,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          // --- FORMULA BOX ---
          // Only show if data exists (Base, Lights, or Toner)
          if ((post.base != null) ||
              (post.lights != null) ||
              (post.toner != null))
            Container(
              width: Dimensions.screenWidth,
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: AppColors.primary1, // Light background
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.base != null) _buildFormulaRow("Base", post.base!),
                  if (post.lights != null)
                    _buildFormulaRow("Lights", post.lights!),
                  if (post.toner != null)
                    _buildFormulaRow("Toner", post.toner!),
                ],
              ),
            ),

          SizedBox(height: Dimensions.height10),

          // --- ACTIONS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    Icons.favorite_border,
                    post.likeCount.toString(),
                    Colors.red,
                    () {},
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    post.commentCount.toString(),
                    AppColors.grey4,
                    () {
                      Get.toNamed(AppRoutes.commentsScreen, arguments: post);
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Icons.bookmark_border,
                    post.saveCount.toString(),
                    AppColors.grey4,
                    () {},
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
      padding: EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(fontWeight: FontWeight.normal),
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
          // --- HEADER ---
          Row(
            children: [
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,

                  image:
                      (comment.author?.profileImageUrl != null)
                          ? DecorationImage(
                            image: NetworkImage(
                              comment.author!.displayImageUrl!,
                            ),
                          )
                          : null,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          comment.author!.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 4,
                            color: AppColors.grey4,
                          ),
                        ),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      comment.author!.username,
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
              InkWell(
                onTap: () => _showMoreOptions(context),
                child: Icon(Icons.more_horiz),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // --- CONTENT ---
          Text(
            comment.body, // FIXED: was post.content
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          // --- ACTIONS ---
          // Assuming you want basic interactions for comments
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.grey4,
                size: Dimensions.iconSize16,
              ),
              SizedBox(width: 5),
              Text("0", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              // Add like count if available
              SizedBox(width: 20),
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

class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const OptionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.width15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: Dimensions.iconSize20),
            SizedBox(width: Dimensions.width10),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 5),
          Text(
            count,
            style: TextStyle(
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

void _showMoreOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More..',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.cancel, color: AppColors.grey4),
                    ),
                  ],
                ),
              ),
              OptionTile(icon: CupertinoIcons.plus, title: 'Follow Profile'),
              OptionTile(icon: Iconsax.bookmark, title: 'Save'),
              OptionTile(icon: CupertinoIcons.share, title: 'Share'),
              OptionTile(icon: CupertinoIcons.link, title: 'Copy Link'),
              OptionTile(
                icon: CupertinoIcons.heart_slash,
                title: 'Not Interested',
              ),
              OptionTile(icon: Icons.block, title: 'Block'),
              OptionTile(icon: Icons.outlined_flag, title: 'Report'),
            ],
          ),
        ),
      );
    },
  );
}
