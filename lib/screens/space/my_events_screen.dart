import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/event_controller.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/reminder_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final EventController controller = Get.find<EventController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEvents(createdByMe: true, limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        title: 'My Events',
      ),
      body: Obx(() {
        if (controller.isGettingEvents.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          );
        }

        if (controller.events.isEmpty) {
          return Center(
            child: Text(
              'No events yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.grey4,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(Dimensions.width20),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];

            return Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height15),
              child: ReminderCard(
                hostName: event.creator?.name ?? 'Unknown Host',
                hostRole: event.creator?.role ?? 'Host',
                sessionType: 'A U D I O',
                title: event.title ?? 'Untitled Event',
                description: event.description ?? '',
                dateTime: controller.formatEventDate(event.scheduledStartAt),
                isReminderSet: event.viewer?.isSubscribed ?? false,
                onTap: () async {
                  await controller.fetchSingleEvent(event.id ?? '');
                  Get.toNamed(AppRoutes.shareSpaceScreen);
                },
                onReminderTap: () async {
                  await controller.toggleSubscription(event);
                },
              ),
            );
          },
        );
      }),
    );
  }
}