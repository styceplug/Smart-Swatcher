import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';

import '../models/post_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

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
          // Header
          Row(
            children: [
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // username
                    Text(
                      post.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // role + time
                    Row(
                      children: [
                        Text(
                          post.role,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Icon(
                          Icons.circle,
                          size: Dimensions.iconSize16 / 2,
                          color: AppColors.grey4,
                        ),
                        SizedBox(width: Dimensions.width10),
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
              SizedBox(width: Dimensions.width10),
              InkWell(
                onTap: () {
                  debugPrint('post tapped');
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(
                              Dimensions.width20,
                              Dimensions.height20,
                              Dimensions.width20,
                              Dimensions.height20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.height10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.grey2,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'More..',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(
                                          Icons.cancel,
                                          color: AppColors.grey4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.plus,
                                    title: 'Follow Profile',
                                  ),
                                  OptionTile(
                                    icon: Iconsax.bookmark,
                                    title: 'Save',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.share,
                                    title: 'Share',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.link,
                                    title: 'Copy Link',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.heart_slash,
                                    title: 'Not Interested',
                                  ),
                                  OptionTile(icon: Icons.block, title: 'Block'),
                                  OptionTile(
                                    icon: Icons.outlined_flag,
                                    title: 'Report',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Icon(Icons.more_horiz),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // Post text
          Text(
            post.content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          // Post image (supports asset or network)
          if (post.imageAsset != null || post.imageUrl != null)
            Container(
              height: Dimensions.height40 * 5,
              width: Dimensions.screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: AppColors.grey3,
                image:
                    post.imageAsset != null
                        ? DecorationImage(
                          image: AssetImage(post.imageAsset!),
                          fit: BoxFit.cover,
                        )
                        : (post.imageUrl != null
                            ? DecorationImage(
                              image: NetworkImage(post.imageUrl!),
                              fit: BoxFit.cover,
                            )
                            : null),
              ),
            ),

          SizedBox(height: Dimensions.height10),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    Icons.favorite,
                    post.likes.toString(),
                    Colors.red,
                    () {},
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    post.comments.toString(),
                    AppColors.grey4,
                    () {
                      Get.toNamed(AppRoutes.commentsScreen);
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Icons.bookmark_border,
                    post.bookmarks.toString(),
                    AppColors.grey4,
                      (){}
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

  Widget _actionButton(
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: AppColors.grey4),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: Dimensions.iconSize16),
            SizedBox(width: Dimensions.width5),
            Text(
              count,
              style: TextStyle(
                fontSize: Dimensions.font12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
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
          // Header
          Row(
            children: [
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // username
                    Text(
                      post.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // role + time
                    Row(
                      children: [
                        Text(
                          post.role,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Icon(
                          Icons.circle,
                          size: Dimensions.iconSize16 / 2,
                          color: AppColors.grey4,
                        ),
                        SizedBox(width: Dimensions.width10),
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
              SizedBox(width: Dimensions.width10),
              InkWell(
                onTap: () {
                  debugPrint('formular tapped');
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(
                              Dimensions.width20,
                              Dimensions.height20,
                              Dimensions.width20,
                              Dimensions.height20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.height10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.grey2,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'More..',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(
                                          Icons.cancel,
                                          color: AppColors.grey4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.plus,
                                    title: 'Follow Profile',
                                  ),
                                  OptionTile(
                                    icon: Iconsax.bookmark,
                                    title: 'Save',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.share,
                                    title: 'Share',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.link,
                                    title: 'Copy Link',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.heart_slash,
                                    title: 'Not Interested',
                                  ),
                                  OptionTile(icon: Icons.block, title: 'Block'),
                                  OptionTile(
                                    icon: Icons.outlined_flag,
                                    title: 'Report',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Icon(Icons.more_horiz),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // Post text
          Text(
            post.content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          Container(
            height: Dimensions.height40 * 3,
            width: Dimensions.screenWidth,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              color: AppColors.primary1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.base ?? '',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  post.lights ?? '',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  post.toner ?? '',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height10),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionButton(
                    Icons.favorite,
                    post.likes.toString(),
                    Colors.red,
                    () {},
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Iconsax.message,
                    post.comments.toString(),
                    AppColors.grey4,
                    () {
                      Get.toNamed(AppRoutes.commentsScreen);
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                  _actionButton(
                    Icons.bookmark_border,
                    post.bookmarks.toString(),
                    AppColors.grey4,
                    () {},
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

  Widget _actionButton(
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: AppColors.grey4),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: Dimensions.iconSize16),
            SizedBox(width: Dimensions.width5),
            Text(
              count,
              style: TextStyle(
                fontSize: Dimensions.font12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
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

class CommentCard extends StatelessWidget {
  final CommentModel post;

  const CommentCard({super.key, required this.post});

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
          // Header
          Row(
            children: [
              Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey3,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // username
                    Text(
                      post.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Icon(
                      Icons.circle,
                      size: Dimensions.iconSize16 / 2,
                      color: AppColors.grey4,
                    ),
                    SizedBox(width: Dimensions.width10),
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
              ),
              SizedBox(width: Dimensions.width10),
              InkWell(
                onTap: () {
                  debugPrint('tapped');
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(
                              Dimensions.width20,
                              Dimensions.height20,
                              Dimensions.width20,
                              Dimensions.height20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.height10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.grey2,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'More..',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Dimensions.font17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(
                                          Icons.cancel,
                                          color: AppColors.grey4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.plus,
                                    title: 'Follow Profile',
                                  ),
                                  OptionTile(
                                    icon: Iconsax.bookmark,
                                    title: 'Save',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.share,
                                    title: 'Share',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.link,
                                    title: 'Copy Link',
                                  ),
                                  OptionTile(
                                    icon: CupertinoIcons.heart_slash,
                                    title: 'Not Interested',
                                  ),
                                  OptionTile(icon: Icons.block, title: 'Block'),
                                  OptionTile(
                                    icon: Icons.outlined_flag,
                                    title: 'Report',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Icon(Icons.more_horiz),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),

          // Post text
          Text(
            post.content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width5),
                      Text(
                        post.likes.toString(),
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: Dimensions.width20),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        color: Colors.red,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width5),
                      Text(
                        post.bookmarks.toString(),
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: Dimensions.width20),
                  Row(
                    children: [
                      Icon(
                        Iconsax.message,
                        color: Colors.red,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width5),
                      Text(
                        post.comments.toString(),
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: Dimensions.width20),

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
        ],
      ),
    );
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
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: AppColors.grey4),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: Dimensions.iconSize16),
            SizedBox(width: Dimensions.width5),
            Text(
              count,
              style: TextStyle(
                fontSize: Dimensions.font12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
