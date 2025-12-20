import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import '../../controllers/post_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';



class CreatePostScreen extends StatefulWidget {
  final String? draftId;
  final String? draftContent;

  const CreatePostScreen({
    Key? key,
    this.draftId,
    this.draftContent,
  }) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController postController;
  final PostController controller = Get.put(PostController());

  @override
  void initState() {
    super.initState();
    postController = TextEditingController(text: widget.draftContent ?? '');
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  void _showExitDialog() {
    if (postController.text.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height50,
              Dimensions.width20,
              Dimensions.height70,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Save before you exit?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Dimensions.height40),
                CustomButton(
                  text: 'Save to Drafts',
                  onPressed: () async {
                    await controller.saveDraft(
                      postController.text,
                      draftId: widget.draftId,
                    );
                    Get.offAllNamed(AppRoutes.homeScreen);
                  },
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height20),
                CustomButton(
                  text: 'Don\'t Save',
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  backgroundColor: AppColors.primary1,
                ),
              ],
            ),
          );
        },
      );
    } else {
      Get.back();
    }
  }

  void _showAudienceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Obx(() => Container(
          padding: EdgeInsets.fromLTRB(
            Dimensions.width20,
            Dimensions.height20,
            Dimensions.width20,
            Dimensions.height70,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Audience',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Container(
                height: 1,
                width: Dimensions.screenWidth,
                color: AppColors.grey2,
              ),
              SizedBox(height: Dimensions.height20),
              _buildAudienceOption(
                icon: CupertinoIcons.globe,
                title: 'General Color Club',
                isSelected:
                controller.selectedAudience.value == 'General Color Club',
                onTap: () => controller.setAudience('General Color Club'),
              ),
              SizedBox(height: Dimensions.height20),
              _buildAudienceOption(
                icon: Iconsax.people,
                title: 'Elite Only',
                isSelected: controller.selectedAudience.value == 'Elite Only',
                onTap: () => controller.setAudience('Elite Only'),
              ),
              SizedBox(height: Dimensions.height20 * 2),
              CustomButton(
                text: 'Done',
                onPressed: () => Get.back(),
                backgroundColor: AppColors.primary5,
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildAudienceOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: Dimensions.width10),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font17,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              color: AppColors.primary5,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: InkWell(
          onTap: _showExitDialog,
          child: Icon(CupertinoIcons.xmark),
        ),
        title: 'New Post',
        actionIcon: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.postDraftsScreen);
          },
          child: Text(
            'Drafts',
            style: TextStyle(
              fontSize: Dimensions.font16,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20 * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Dimensions.height50,
              width: Dimensions.width50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey2,
              ),
            ),
            Expanded(
              child: TextField(
                style: TextStyle(fontFamily: 'Poppins'),
                cursorOpacityAnimates: true,
                controller: postController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Got a fresh dye? Tell us!!',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.grey4,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Obx(() => InkWell(
              onTap: _showAudienceModal,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.grey2),
                    top: BorderSide(color: AppColors.grey2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.selectedAudience.value == 'General Color Club'
                          ? CupertinoIcons.globe
                          : Iconsax.people,
                    ),
                    SizedBox(width: Dimensions.width20),
                    Text(
                      controller.selectedAudience.value,
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
              child: Row(
                children: [
                  Icon(CupertinoIcons.photo),
                  SizedBox(width: Dimensions.width20),
                  Icon(CupertinoIcons.camera),
                  Spacer(),
                  CustomButton(
                    text: 'Upload',
                    onPressed: () {
                      // TODO: Implement post upload
                    },
                    backgroundColor: AppColors.primary4,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height10,
                      horizontal: Dimensions.width10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
