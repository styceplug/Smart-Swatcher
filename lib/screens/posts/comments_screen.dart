import 'package:flutter/material.dart';
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

  PostModel posts (){
     return PostModel(
       username: "Jakobjelling",
       role: "Color Specialist",
       timeAgo: "2h ago",
       content:
       "Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante. Pellentesque scelerisque malesuada arcu integer sapien.",
       likes: 124,
       comments: 65,
       bookmarks: 32,
       imageUrl: "https://picsum.photos/200/300",
  );
}


  final commentData = [
    {
      "username": "Jakobjelling",
      "timeAgo": "2h ago",
      "content":
      "Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante. Pellentesque scelerisque malesuada arcu integer sapien.",
      "likes": 124,
      "comments": 65,
      "bookmarks": 32,
    },
    {
      "username": "JaneDoe",
      "timeAgo": "5h ago",
      "content": "This is another post!",
      "likes": 90,
      "comments": 12,
      "bookmarks": 5,
    },
  ];






  @override
  Widget build(BuildContext context) {

    final List<CommentModel> comments =
    commentData.map((item) {
      return CommentModel(
        username: item["username"] as String? ?? "",
        timeAgo: item["timeAgo"] as String? ?? "",
        content: item["content"] as String? ?? "",
        likes: item["likes"] as int? ?? 0,
        comments: item["comments"] as int? ?? 0,
        bookmarks: item["bookmarks"] as int? ?? 0,
      );
    }).toList();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        title: 'Comments',
        actionIcon: Icon(Icons.notifications),
      ),
      body: Container(
        child: Column(
          children: [
            PostCard(post: posts()),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final p = comments[index];
                  return CommentCard(post: p);
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height40),
        child: CustomTextField(
          hintText: 'Reply to ...',
          suffixIcon: Icon(Icons.send),
        ),
      ),
    );
  }
}
