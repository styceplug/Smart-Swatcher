import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/share_event_card.dart';

import '../../controllers/event_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';


class ShareSpaceScreen extends StatelessWidget {
  const ShareSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
        backgroundColor: AppColors.white,
      ),
      body: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Obx(() {
          final event =
              controller.selectedEvent.value ?? controller.createdEvent.value;

          if (event == null) {
            return Center(
              child: Text(
                'No event found',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font15,
                ),
              ),
            );
          }

          final isLive = event.status?.toLowerCase() == 'live';
          final canStart = event.viewer?.canStart ?? false;
          final canJoin = event.viewer?.canJoin ?? false;
          final isCreator = event.viewer?.isCreator ?? false;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width40),
                child: Text(
                  isLive
                      ? (isCreator
                          ? 'Your event is live now. Jump back in.'
                          : 'This event is live now. Jump in.')
                      : 'Event Created. Time to share it with your people',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),

              ShareEventCard(
                hostName: event.creator?.name ?? 'Unknown Host',
                hostRole: event.creator?.role ?? 'Host',
                sessionType: 'AUDIO',
                title: event.title ?? 'Untitled Event',
                dateTime: controller.formatEventDate(event.scheduledStartAt),
                description: event.description ?? 'No description available',
                visibility: event.visibility ?? 'General',
                status: event.status ?? 'upcoming',
                subscriberCount: event.subscriberCount,
                isLive: isLive,
                onPressed: () {},
              ),

              SizedBox(height: Dimensions.height30),

              CustomButton(
                text: 'Share Event',
                onPressed: () {
                  CustomSnackBar.processing(
                    message: 'Share flow coming next',
                  );
                },
              ),

              SizedBox(height: Dimensions.height15),

              if (isLive && (canJoin || isCreator))
                CustomButton(
                  text: 'Rejoin Live Event',
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await controller.joinEventSession(event.id ?? '');
                  },
                )
              else if (canStart)
                CustomButton(
                  text: 'Start Event',
                  backgroundColor: AppColors.primary1,
                  onPressed: () async {
                    await controller.startEventSession(event.id ?? '');
                  },
                ),
            ],
          );
        }),
      ),
    );
  }
}
