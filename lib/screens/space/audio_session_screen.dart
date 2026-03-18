import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class AudioSessionScreen extends StatelessWidget {
  const AudioSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();

    return Scaffold(
      backgroundColor: AppColors.black1,
      body: SafeArea(
        child: Obx(() {
          final event = controller.selectedEvent.value;

          if (event == null) {
            return const Center(
              child: Text(
                'No active event',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final isCreator = event.viewer?.isCreator ?? false;

          return Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await controller.leaveEventSession(event.id ?? '');
                        Get.back();
                      },
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ),
                    const Spacer(),
                    if (isCreator)
                      InkWell(
                        onTap: () => controller.endEventSession(event.id ?? ''),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width15,
                            vertical: Dimensions.height10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'End',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: Dimensions.height30),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  event.title ?? 'Untitled Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.font22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  event.description ?? '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Dimensions.font14,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: Dimensions.height30),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.creator?.name ?? 'Host',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          event.creator?.role ?? 'Host',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height30),
                Text(
                  '${event.liveParticipantCount} listening',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _audioAction(Icons.volume_up),
                      SizedBox(width: Dimensions.width20),
                      _audioAction(Icons.mic_off),
                      SizedBox(width: Dimensions.width20),
                      InkWell(
                        onTap: () async {
                          await controller.leaveEventSession(event.id ?? '');
                          Get.back();
                        },
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call_end, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height30),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _audioAction(IconData icon) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}