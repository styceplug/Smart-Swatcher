import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

import '../../controllers/event_controller.dart';
import '../../widgets/custom_textfield.dart';

class CreateSpaceScreen extends StatelessWidget {
  const CreateSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
        title: 'Event',
        actionIcon: Obx(
          () => InkWell(
            onTap:
                controller.isCreatingEvent.value
                    ? null
                    : controller.createEvent,
            child: Text(
              'Done',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color:
                    controller.isCreatingEvent.value
                        ? AppColors.grey4
                        : AppColors.primary5,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.titleController,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Enter Space Name',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.grey4,
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    SizedBox(height: Dimensions.height20),
                    TextField(
                      controller: controller.descriptionController,

                      maxLines: 5,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Tell people what this event is about',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.grey4,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),

                    Obx(
                      () => OptionTile(
                        icon: CupertinoIcons.time,
                        title: 'Time',
                        value: controller.formattedDateTime,
                        onTap: () => controller.pickDateTime(context),
                      ),
                    ),

                    OptionTile(
                      icon: CupertinoIcons.mic,
                      title: 'Event Type',
                      value: 'Audio',
                      onTap: () {
                        CustomSnackBar.processing(
                          message: 'Only audio events are available for now',
                        );
                      },
                    ),

                    Obx(
                      () => OptionTile(
                        icon: CupertinoIcons.person,
                        title: 'Audience',
                        value: controller.selectedVisibility.value,
                        onTap: () {
                          _showAudienceSheet(context, controller);
                        },
                      ),
                    ),

                    OptionTile(
                      icon: Iconsax.record,
                      title: 'Session',
                      value: 'Live Only',
                      onTap: () {
                        CustomSnackBar.processing(
                          message: 'Only live sessions are available for now',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Obx(
                () => CustomButton(
                  text:
                      controller.isCreatingEvent.value
                          ? 'Creating...'
                          : 'Create Event',
                  onPressed:
                      controller.isCreatingEvent.value
                          ? () {}
                          : controller.createEvent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudienceSheet(BuildContext context, EventController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Obx(
          () => Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height20,
              Dimensions.width20,
              Dimensions.height40,
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
                      child: const Icon(Icons.close),
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

                InkWell(
                  onTap: () {
                    controller.setVisibility('General');
                    Get.back();
                  },
                  child: Row(
                    children: [
                      Text(
                        'General',
                        style: TextStyle(
                          fontSize: Dimensions.font17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        controller.selectedVisibility.value == 'General'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                InkWell(
                  onTap: () {
                    controller.setVisibility('Elite');
                    Get.back();
                  },
                  child: Row(
                    children: [
                      Text(
                        'Elite',
                        style: TextStyle(
                          fontSize: Dimensions.font17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        controller.selectedVisibility.value == 'Elite'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const OptionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.width20,
          horizontal: Dimensions.height10,
        ),
        child: Row(
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
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Icon(
              CupertinoIcons.chevron_forward,
              size: Dimensions.iconSize20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
