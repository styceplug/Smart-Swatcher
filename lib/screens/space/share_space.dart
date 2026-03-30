import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/widgets/app_cached_network_image.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/share_event_card.dart';

import '../../controllers/event_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';

class ShareSpaceScreen extends StatelessWidget {
  const ShareSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();
    final UserController userController = Get.find<UserController>();

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
                sessionType:
                    event.sessionMode == 'audio' ? 'AUDIO' : 'INTERACTIVE',
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
                  CustomSnackBar.processing(message: 'Share flow coming next');
                },
              ),

              SizedBox(height: Dimensions.height15),

              if (isCreator)
                CustomButton(
                  text: 'Invite Co-host',
                  backgroundColor: Colors.white,
                  borderColor: AppColors.primary5,
                  textStyle: TextStyle(
                    color: AppColors.primary5,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  onPressed: () async {
                    await userController.fetchAcceptedConnections();
                    if (!context.mounted) return;
                    _showCohostPicker(
                      context,
                      controller,
                      userController.acceptedConnections,
                      event.id ?? '',
                    );
                  },
                ),

              if (isCreator) SizedBox(height: Dimensions.height15),

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

  void _showCohostPicker(
    BuildContext context,
    EventController controller,
    List<ConnectionPeerModel> peers,
    String eventId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (peers.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Text(
              'No accepted connections yet. Connect with someone first before assigning them as a co-host.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font14,
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Invite Co-host',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: peers.length,
                    separatorBuilder:
                        (_, __) => SizedBox(height: Dimensions.height10),
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.grey2,
                          backgroundImage:
                              MediaUrlHelper.resolve(peer.profileImageUrl) !=
                                      null
                                  ? appCachedImageProvider(
                                    MediaUrlHelper.resolve(
                                      peer.profileImageUrl,
                                    ),
                                  )
                                  : null,
                          child:
                              peer.profileImageUrl == null
                                  ? Text(
                                    peer.name.isNotEmpty
                                        ? peer.name[0].toUpperCase()
                                        : '?',
                                  )
                                  : null,
                        ),
                        title: Text(
                          peer.name,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        subtitle: Text(
                          peer.role?.trim().isNotEmpty == true
                              ? peer.role!
                              : peer.type,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font12,
                            color: AppColors.grey4,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            Get.back();
                            await controller.assignCohost(
                              eventId: eventId,
                              targetId: peer.id,
                              targetType: peer.type,
                            );
                          },
                          child: const Text('Invite'),
                        ),
                      );
                    },
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
