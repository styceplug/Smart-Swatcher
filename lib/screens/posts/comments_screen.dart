import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/post_controller.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';
import 'package:smart_swatcher/widgets/post_card.dart';

import '../../models/post_model.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  PostController postController = Get.find<PostController>();
  final TextEditingController commentInputController = TextEditingController();

  late PostModel post;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments is PostModel) {
      post = Get.arguments as PostModel;
    } else {
      post = PostModel(
        id: "",
        caption: "",
        targetAudience: "",
        createdAt: "",
        author: Author(
          id: "",
          type: "",
          name: "Unknown",
          username: "",
          isVerified: false,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postController.loadPostDetails(post.id);
    });
  }

  @override
  void dispose() {
    commentInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        title: 'Comments',
        actionIcon: Icon(Icons.notifications),
      ),
      body: Container(
        child: Column(
          children: [
            Obx((){
              var livePost = postController.postsList.firstWhere(
                      (p) => p.id == post.id,
                  orElse: () => post
              );


              return PostCard(post: post);
            }),
            Expanded(
              child: Obx(() {
                if (postController.isCommentsLoading.value &&
                    postController.currentPostComments.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary5),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: postController.currentPostComments.length,
                  itemBuilder: (context, index) {
                    final comment = postController.currentPostComments[index];

                    return CommentCard(comment: comment);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height40,
        ),
        child: CustomTextField(
          hintText: 'Reply to ...',
          suffixIcon: InkWell(
            onTap: () {
              if (commentInputController.text.isNotEmpty) {
                postController.postComment(
                  post.id,
                  commentInputController.text,
                );
                commentInputController.clear();
                FocusScope.of(context).unfocus();
              }
            },
            child: Icon(Icons.send),
          ),
          controller: commentInputController,
        ),
      ),
    );
  }
}
