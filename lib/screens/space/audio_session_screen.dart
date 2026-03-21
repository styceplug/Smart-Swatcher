import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../utils/app_constants.dart';
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
  late Worker _remoteJoinWorker;
  Timer? _participantRefreshTimer;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.refreshActiveEvent();
      _startParticipantRefresh();
    });
    _remoteJoinWorker = ever(agoraHelper.remoteUsersCount, (_) {
      controller.refreshActiveEvent();
    });
  }

  @override
  void dispose() {
    _participantRefreshTimer?.cancel();
    _remoteJoinWorker.dispose();
    super.dispose();
  }

  void _startParticipantRefresh() {
    _participantRefreshTimer?.cancel();
    _participantRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      controller.refreshActiveEvent();
    });
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
          final joined = agoraHelper.isJoined.value;
          final speakerOn = agoraHelper.speakerEnabled.value;
          final isMuted = agoraHelper.micMuted.value;
          final participants = [...event.liveParticipants]
            ..sort((left, right) {
              if (left.isCreator != right.isCreator) {
                return left.isCreator ? -1 : 1;
              }
              return (left.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .compareTo(
                right.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              );
            });
          final totalListeners =
              event.liveParticipantCount > 0
                  ? event.liveParticipantCount
                  : participants.length;

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
                    color: Colors.red.withValues(alpha: 0.2),
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
                  '$totalListeners in this live room',
                  style: const TextStyle(color: Colors.white70),
                ),

                SizedBox(height: Dimensions.height5),

                Text(
                  joined
                      ? participants.length > 1
                          ? 'Live roster is updating'
                          : 'Connected. Waiting for others...'
                      : 'Connecting...',
                  style: TextStyle(
                    color: joined ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),

                SizedBox(height: Dimensions.height10),

                Text(
                  joined ? 'Connected to live audio' : 'Connecting...',
                  style: TextStyle(
                    color: joined ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: Dimensions.font13,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Expanded(
                  child: _buildParticipantsList(participants),
                ),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _audioAction(
                        icon: speakerOn ? Icons.volume_up : Icons.volume_off,
                        onTap: () async {
                          await agoraHelper.toggleSpeaker();
                        },
                      ),
                      SizedBox(width: Dimensions.width20),

                      _audioAction(
                        icon: isMuted ? Icons.mic_off : Icons.mic,
                        onTap: isCreator
                            ? () async {
                          await agoraHelper.toggleMute();
                        }
                            : null,
                        disabled: !isCreator,
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

  Widget _buildParticipantsList(List<EventParticipantModel> participants) {
    if (participants.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'No participant data yet. Waiting for the live roster...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      itemCount: participants.length,
      separatorBuilder: (_, __) => SizedBox(height: Dimensions.height10),
      itemBuilder: (context, index) {
        final participant = participants[index];
        final imageUrl = MediaUrlHelper.resolve(participant.profileImageUrl);
        final subtitleParts = <String>[
          if (participant.isCreator) 'Host',
          if (!participant.isCreator && (participant.role?.isNotEmpty ?? false))
            participant.role!,
          if (participant.isVerified) 'Verified',
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height12,
          ),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Text(
                        (participant.name?.isNotEmpty ?? false)
                            ? participant.name![0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name?.isNotEmpty == true
                          ? participant.name!
                          : participant.username?.isNotEmpty == true
                              ? participant.username!
                              : 'Unknown participant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitleParts.isNotEmpty)
                      Text(
                        subtitleParts.join(' • '),
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
              if (participant.isCreator)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'HOST',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
