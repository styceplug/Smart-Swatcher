import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import '../../controllers/post_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/draft_card.dart';
import 'create_post_screen.dart';

class PostDraftsScreen extends StatelessWidget {
  const PostDraftsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.put(PostController());

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: BackButton(),
        title: 'Drafts',
        actionIcon: Obx(() => controller.drafts.isNotEmpty
            ? InkWell(
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: Text(
                  'Clear All Drafts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete all drafts?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.grey4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.clearAllDrafts();
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'Clear All',
            style: TextStyle(
              fontSize: Dimensions.font14,
              fontFamily: 'Poppins',
              color: Colors.red,
            ),
          ),
        )
            : SizedBox.shrink()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary5,
            ),
          );
        }

        if (controller.drafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.drafts_outlined,
                  size: Dimensions.height50 * 2,
                  color: AppColors.grey4,
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  'No drafts yet',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  'Your saved drafts will appear here',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontFamily: 'Poppins',
                    color: AppColors.grey4,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
          child: ListView.builder(
            itemCount: controller.drafts.length,
            itemBuilder: (context, index) {
              final draft = controller.drafts[index];
              return DraftCard(
                content: draft.content,
                timeAgo: controller.getTimeAgo(draft.createdAt),
                onTap: () {
                  Get.to(
                        () => CreatePostScreen(
                      draftId: draft.id,
                      draftContent: draft.content,
                    ),
                  );
                },
                onDelete: () {
                  controller.deleteDraft(draft.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
