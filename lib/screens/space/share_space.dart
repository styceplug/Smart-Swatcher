import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/reminder_card.dart';
import 'package:smart_swatcher/widgets/share_event_card.dart';

import '../../controllers/event_controller.dart';


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
          final event = controller.selectedEvent.value ?? controller.createdEvent.value;

          if (event == null) {
            return const Center(
              child: Text('No event found'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width40),
                child: Text(
                  'Event Created. Time to share it with your people',
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
                onPressed: () {},
              ),
            ],
          );
        }),
      ),
    );
  }
}
