import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_cached_network_image.dart';
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
  late Worker _remoteVideoWorker;
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
    _remoteVideoWorker = ever(agoraHelper.remoteVideoUserUids, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _participantRefreshTimer?.cancel();
    _remoteJoinWorker.dispose();
    _remoteVideoWorker.dispose();
    super.dispose();
  }

  void _startParticipantRefresh() {
    _participantRefreshTimer?.cancel();
    _participantRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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

          final viewer = event.viewer;
          final isCreator = viewer?.isCreator ?? false;
          final joined = agoraHelper.isJoined.value;
          final speakerOn = agoraHelper.speakerEnabled.value;
          final isMuted = agoraHelper.micMuted.value;
          final cameraOn = agoraHelper.cameraEnabled.value;
          final participants = [...event.liveParticipants]..sort((left, right) {
            final order = {'host': 0, 'cohost': 1, 'speaker': 2, 'audience': 3};
            final leftRank = order[left.role] ?? 99;
            final rightRank = order[right.role] ?? 99;
            if (leftRank != rightRank) return leftRank - rightRank;
            return (left.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  right.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                );
          });
          final stageParticipants =
              participants
                  .where(
                    (participant) =>
                        participant.role == 'host' ||
                        participant.role == 'cohost',
                  )
                  .toList();
          final totalListeners =
              event.liveParticipantCount > 0
                  ? event.liveParticipantCount
                  : participants.length;

          return Padding(
            padding: EdgeInsets.all(Dimensions.width18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(event, isCreator),
                SizedBox(height: Dimensions.height18),
                _buildStage(event, stageParticipants),
                SizedBox(height: Dimensions.height15),
                _buildEventMeta(event, joined, totalListeners),
                if (event.handRaiseQueue.isNotEmpty &&
                    (viewer?.canManageHands ?? false)) ...[
                  SizedBox(height: Dimensions.height15),
                  _buildHandRaiseQueue(event.handRaiseQueue),
                ],
                SizedBox(height: Dimensions.height15),
                Expanded(
                  child: _buildParticipantsList(
                    event,
                    participants,
                    viewer?.canManageHands ?? false,
                    viewer?.canInviteCohosts ?? false,
                  ),
                ),
                SizedBox(height: Dimensions.height12),
                _buildReactionStrip(viewer?.canSendReactions ?? false),
                SizedBox(height: Dimensions.height12),
                _buildControls(
                  event,
                  speakerOn: speakerOn,
                  isMuted: isMuted,
                  cameraOn: cameraOn,
                  canPublishAudio: viewer?.canPublishAudio ?? false,
                  canPublishVideo: viewer?.canPublishVideo ?? false,
                  canRaiseHand: viewer?.canRaiseHand ?? false,
                  isHandRaised: viewer?.isHandRaised ?? false,
                  isCreator: isCreator,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(EventModel event, bool isCreator) {
    return Row(
      children: [
        InkWell(
          onTap: _leaveSession,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
        SizedBox(width: Dimensions.width10),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height5,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            event.sessionMode == 'audio' ? 'LIVE AUDIO' : 'LIVE STAGE',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
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
              child: const Text('End', style: TextStyle(color: Colors.white)),
            ),
          ),
      ],
    );
  }

  Widget _buildStage(
    EventModel event,
    List<EventParticipantModel> stageParticipants,
  ) {
    if (event.sessionMode == 'audio') {
      return _buildAudioOnlyStage(event);
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          padding: EdgeInsets.all(Dimensions.width10),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(24),
          ),
          child:
              stageParticipants.isEmpty
                  ? _buildEmptyStage()
                  : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stageParticipants.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: stageParticipants.length == 1 ? 1 : 2,
                      crossAxisSpacing: Dimensions.width10,
                      mainAxisSpacing: Dimensions.height10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildStageTile(event, stageParticipants[index]);
                    },
                  ),
        ),
        if (controller.liveReactions.isNotEmpty)
          Positioned(right: 12, top: 12, child: _buildReactionOverlay()),
      ],
    );
  }

  Widget _buildAudioOnlyStage(EventModel event) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.mic, color: Colors.white, size: 30),
              ),
              SizedBox(height: Dimensions.height15),
              Text(
                'Audio room in progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                event.title ?? 'Live event',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: Dimensions.font13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        if (controller.liveReactions.isNotEmpty)
          Positioned(right: 12, top: 12, child: _buildReactionOverlay()),
      ],
    );
  }

  Widget _buildEmptyStage() {
    return Center(
      child: Text(
        'Waiting for host video',
        style: TextStyle(
          color: Colors.white70,
          fontSize: Dimensions.font14,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildStageTile(EventModel event, EventParticipantModel participant) {
    final currentRtc = controller.currentRtc.value;
    final channelName =
        currentRtc?.channelName ?? agoraHelper.currentChannelName;
    final isSelf =
        currentRtc?.uid != null && currentRtc!.uid == participant.agoraUid;
    final hasVideo =
        event.sessionMode == 'interactive' &&
        participant.canPublishVideo &&
        ((isSelf && agoraHelper.cameraEnabled.value) ||
            (!isSelf &&
                agoraHelper.remoteVideoUserUids.contains(
                  participant.agoraUid,
                )));

    Widget child;
    if (hasVideo && agoraHelper.engine != null && channelName != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child:
            isSelf
                ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraHelper.engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                : AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: agoraHelper.engine!,
                    canvas: VideoCanvas(uid: participant.agoraUid),
                    connection: RtcConnection(channelId: channelName),
                  ),
                ),
      );
    } else {
      child = Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            backgroundImage:
                MediaUrlHelper.resolve(participant.profileImageUrl) != null
                    ? appCachedImageProvider(
                      MediaUrlHelper.resolve(participant.profileImageUrl),
                    )
                    : null,
            child:
                MediaUrlHelper.resolve(participant.profileImageUrl) == null
                    ? Text(
                      participant.name?.isNotEmpty == true
                          ? participant.name![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                    : null,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    participant.name?.isNotEmpty == true
                        ? participant.name!
                        : participant.username?.isNotEmpty == true
                        ? participant.username!
                        : 'Participant',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  participant.role?.toUpperCase() ?? 'LIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionOverlay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          controller.liveReactions
              .take(4)
              .map(
                (reaction) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _reactionIcon(reaction.reaction),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reaction.actorName?.isNotEmpty == true
                            ? reaction.actorName!
                            : 'Reaction',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildEventMeta(EventModel event, bool joined, int totalListeners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title ?? 'Untitled Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: Dimensions.font22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: Dimensions.height8),
        Text(
          event.description ?? '',
          style: TextStyle(
            color: Colors.white70,
            fontSize: Dimensions.font14,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: Dimensions.height15),
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: Column(
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
                    '${event.creator?.role ?? 'Host'} • $totalListeners listening',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Text(
              joined ? 'Connected' : 'Connecting...',
              style: TextStyle(
                color: joined ? Colors.greenAccent : Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHandRaiseQueue(List<EventParticipantModel> queue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hands Raised',
            style: TextStyle(
              color: Colors.white,
              fontSize: Dimensions.font15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Wrap(
            spacing: Dimensions.width10,
            runSpacing: Dimensions.height10,
            children:
                queue.map((participant) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          participant.name?.isNotEmpty == true
                              ? participant.name!
                              : participant.username ?? 'Participant',
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: Dimensions.width10),
                        TextButton(
                          onPressed:
                              () => controller.grantSpeaker(
                                targetId: participant.id ?? '',
                                targetType: participant.type ?? '',
                              ),
                          child: const Text('Let speak'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(
    EventModel event,
    List<EventParticipantModel> participants,
    bool canManageHands,
    bool canInviteCohosts,
  ) {
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
          if (participant.role?.isNotEmpty ?? false) participant.role!,
          if (participant.handRaisedAt != null) 'Hand raised',
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
                backgroundImage:
                    imageUrl != null ? appCachedImageProvider(imageUrl) : null,
                child:
                    imageUrl == null
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
              if (canManageHands || canInviteCohosts)
                PopupMenuButton<String>(
                  color: AppColors.black1,
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'make_cohost':
                        controller.assignCohost(
                          eventId: event.id ?? '',
                          targetId: participant.id ?? '',
                          targetType: participant.type ?? '',
                        );
                        break;
                      case 'remove_cohost':
                        controller.revokeCohost(
                          eventId: event.id ?? '',
                          targetId: participant.id ?? '',
                          targetType: participant.type ?? '',
                        );
                        break;
                      case 'make_speaker':
                        controller.grantSpeaker(
                          targetId: participant.id ?? '',
                          targetType: participant.type ?? '',
                        );
                        break;
                      case 'remove_speaker':
                        controller.revokeSpeaker(
                          targetId: participant.id ?? '',
                          targetType: participant.type ?? '',
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) {
                    final items = <PopupMenuEntry<String>>[];
                    if (canInviteCohosts && participant.role != 'host') {
                      items.add(
                        PopupMenuItem<String>(
                          value:
                              participant.role == 'cohost'
                                  ? 'remove_cohost'
                                  : 'make_cohost',
                          child: Text(
                            participant.role == 'cohost'
                                ? 'Remove cohost'
                                : 'Make cohost',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    if (canManageHands) {
                      if (participant.role == 'audience') {
                        items.add(
                          const PopupMenuItem<String>(
                            value: 'make_speaker',
                            child: Text(
                              'Invite to speak',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      } else if (participant.role == 'speaker') {
                        items.add(
                          const PopupMenuItem<String>(
                            value: 'remove_speaker',
                            child: Text(
                              'Move to audience',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                    return items;
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionStrip(bool canSendReactions) {
    final reactions = <String>[
      'clap',
      'heart',
      'fire',
      'party',
      'wow',
      'thumbs_up',
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reactions.length,
        separatorBuilder: (_, __) => SizedBox(width: Dimensions.width10),
        itemBuilder: (context, index) {
          final reaction = reactions[index];
          return InkWell(
            onTap:
                canSendReactions
                    ? () => controller.sendReaction(reaction)
                    : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canSendReactions ? Colors.white12 : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _reactionIcon(reaction),
                color: canSendReactions ? Colors.white : Colors.white38,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(
    EventModel event, {
    required bool speakerOn,
    required bool isMuted,
    required bool cameraOn,
    required bool canPublishAudio,
    required bool canPublishVideo,
    required bool canRaiseHand,
    required bool isHandRaised,
    required bool isCreator,
  }) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _controlButton(
            icon: speakerOn ? Icons.volume_up : Icons.volume_off,
            onTap: () async {
              await agoraHelper.toggleSpeaker();
            },
          ),
          SizedBox(width: Dimensions.width15),
          _controlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            onTap:
                canPublishAudio
                    ? () async {
                      await agoraHelper.toggleMute();
                    }
                    : null,
            disabled: !canPublishAudio,
          ),
          if (event.sessionMode == 'interactive') ...[
            SizedBox(width: Dimensions.width15),
            _controlButton(
              icon: cameraOn ? Icons.videocam : Icons.videocam_off,
              onTap:
                  canPublishVideo
                      ? () async {
                        final granted =
                            await controller.requestCameraPermission();
                        if (!granted) {
                          return;
                        }
                        await agoraHelper.toggleCamera();
                      }
                      : null,
              disabled: !canPublishVideo,
            ),
          ],
          if (canRaiseHand || isHandRaised) ...[
            SizedBox(width: Dimensions.width15),
            _controlButton(
              icon: isHandRaised ? Icons.pan_tool_alt : Icons.pan_tool_outlined,
              onTap: () async {
                if (isHandRaised) {
                  await controller.lowerHand();
                } else {
                  await controller.raiseHand();
                }
              },
            ),
          ],
          SizedBox(width: Dimensions.width15),
          InkWell(
            onTap: isCreator ? _endSession : _leaveSession,
            child: Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCreator ? Icons.call_end : Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
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
        child: Icon(icon, color: disabled ? Colors.white38 : Colors.white),
      ),
    );
  }

  IconData _reactionIcon(String reaction) {
    switch (reaction) {
      case 'heart':
        return Icons.favorite;
      case 'fire':
        return Icons.local_fire_department;
      case 'party':
        return Icons.celebration;
      case 'wow':
        return Icons.sentiment_very_satisfied;
      case 'thumbs_up':
        return Icons.thumb_up;
      case 'clap':
      default:
        return Icons.pan_tool_alt_rounded;
    }
  }
}
