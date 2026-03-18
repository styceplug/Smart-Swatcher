import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import 'package:smart_swatcher/helpers/agora_audio_helper.dart';


class AudioSessionScreen extends StatefulWidget {
  const AudioSessionScreen({super.key});

  @override
  State<AudioSessionScreen> createState() => _AudioSessionScreenState();
}

class _AudioSessionScreenState extends State<AudioSessionScreen> {
  final EventController controller = Get.find<EventController>();
  final AgoraAudioHelper agoraHelper = Get.find<AgoraAudioHelper>();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _leaveSession() async {
    await controller.leaveEventSession();
    if (mounted) Get.back();
  }

  Future<void> _endSession() async {
    await controller.endEventSession();
    if (mounted && Get.isOverlaysOpen == false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: _leaveSession,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (isCreator)
                      InkWell(
                        onTap: _endSession,
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

                ValueListenableBuilder<int>(
                  valueListenable: agoraHelper.remoteUserCount,
                  builder: (context, remoteCount, _) {
                    final totalListeners = isCreator
                        ? remoteCount + 1
                        : remoteCount;

                    return Text(
                      '$totalListeners listening',
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),

                SizedBox(height: Dimensions.height10),

                ValueListenableBuilder<bool>(
                  valueListenable: agoraHelper.joinedNotifier,
                  builder: (context, joined, _) {
                    return Text(
                      joined ? 'Connected to live audio' : 'Connecting...',
                      style: TextStyle(
                        color: joined ? Colors.greenAccent : Colors.orangeAccent,
                        fontSize: Dimensions.font13,
                        fontFamily: 'Poppins',
                      ),
                    );
                  },
                ),

                const Spacer(),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: agoraHelper.speakerNotifier,
                        builder: (context, speakerOn, _) {
                          return _audioAction(
                            icon: speakerOn
                                ? Icons.volume_up
                                : Icons.volume_off,
                            onTap: () async {
                              await agoraHelper.toggleSpeaker();
                            },
                          );
                        },
                      ),
                      SizedBox(width: Dimensions.width20),

                      ValueListenableBuilder<bool>(
                        valueListenable: agoraHelper.mutedNotifier,
                        builder: (context, isMuted, _) {
                          return _audioAction(
                            icon: isMuted ? Icons.mic_off : Icons.mic,
                            onTap: isCreator
                                ? () async {
                              await agoraHelper.toggleMute();
                            }
                                : null,
                            disabled: !isCreator,
                          );
                        },
                      ),

                      SizedBox(width: Dimensions.width20),

                      InkWell(
                        onTap: _leaveSession,
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
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

  Widget _audioAction({
    required IconData icon,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 54,
        width: 54,
        decoration: BoxDecoration(
          color: disabled ? Colors.white10 : Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: disabled ? Colors.white38 : Colors.white,
        ),
      ),
    );
  }
}