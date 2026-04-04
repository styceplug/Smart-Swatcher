import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../helpers/agora_audio_helper.dart';
import '../../helpers/navigation_helper.dart';
import '../../models/event_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_cached_network_image.dart';

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
  bool _chromeVisible = true;

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

  Future<void> _leaveSession() async {
    await controller.leaveEventSession();
    if (mounted) {
      await NavigationHelper.maybePop(context);
    }
  }

  Future<void> _endSession() async {
    await controller.endEventSession();
    if (mounted && !Get.isOverlaysOpen) {
      await NavigationHelper.maybePop(context);
    }
  }

  void _toggleChrome() {
    if (!mounted) return;
    setState(() {
      _chromeVisible = !_chromeVisible;
    });
  }

  Widget _chrome({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool visible = true,
  }) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0, 0.06),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black1,
      body: Obx(() {
        final event = controller.selectedEvent.value;
        if (event == null) {
          return const SafeArea(
            child: Center(
              child: Text(
                'No active event',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final viewer = event.viewer;
        final joined = agoraHelper.isJoined.value;
        final participants = [...event.liveParticipants]..sort((left, right) {
          const order = {'host': 0, 'cohost': 1, 'speaker': 2, 'audience': 3};
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
        final featuredParticipant =
            stageParticipants.isNotEmpty ? stageParticipants.first : null;
        final supportingStageParticipants =
            stageParticipants.length > 1
                ? stageParticipants.skip(1).take(3).toList()
                : const <EventParticipantModel>[];
        final totalListeners =
            event.liveParticipantCount > 0
                ? event.liveParticipantCount
                : participants.length;
        final isCreator = viewer?.isCreator ?? false;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleChrome,
                child: _buildStageBackdrop(
                  event: event,
                  featuredParticipant: featuredParticipant,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.18),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                      stops: const [0.0, 0.28, 0.58, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 8,
                    child: _chrome(
                      visible: _chromeVisible,
                      child: _GlassPanel(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            _CircleIconButton(
                              icon: Icons.keyboard_arrow_down_rounded,
                              onTap: _leaveSession,
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(
                              text:
                                  event.sessionMode == 'audio'
                                      ? 'LIVE AUDIO'
                                      : 'LIVE STAGE',
                              color: const Color(0xFFFF5D5D),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(
                              text: '$totalListeners',
                              color: Colors.white,
                              icon: Icons.remove_red_eye_outlined,
                              textColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            const Spacer(),
                            _CircleIconButton(
                              icon: Icons.group_outlined,
                              onTap:
                                  () => _showPeopleSheet(
                                    event: event,
                                    participants: participants,
                                    canManageHands:
                                        viewer?.canManageHands ?? false,
                                    canInviteCohosts:
                                        viewer?.canInviteCohosts ?? false,
                                  ),
                            ),
                            if (isCreator) ...[
                              const SizedBox(width: 8),
                              _StatusPill(
                                text: 'End',
                                color: Colors.white,
                                textColor: Colors.white,
                                backgroundColor: const Color(0xFFEB5545),
                                onTap: _endSession,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (supportingStageParticipants.isNotEmpty)
                    Positioned(
                      top: 82,
                      right: 16,
                      child: _chrome(
                        visible: _chromeVisible,
                        child: Column(
                          children:
                              supportingStageParticipants
                                  .map(
                                    (participant) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: SizedBox(
                                        width: 88,
                                        height: 128,
                                        child: _GlassPanel(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          backgroundColor: Colors.black
                                              .withValues(alpha: 0.18),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: _buildParticipantVideoTile(
                                              event: event,
                                              participant: participant,
                                              fullscreen: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 112,
                    child: _chrome(
                      visible: _chromeVisible,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GlassPanel(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title ?? 'Untitled Event',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Dimensions.font18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  if (event.handRaiseQueue.isNotEmpty &&
                                      (viewer?.canManageHands ?? false))
                                    _StatusPill(
                                      text:
                                          '${event.handRaiseQueue.length} hands',
                                      color: const Color(0xFFFFC95B),
                                      textColor: AppColors.black1,
                                      backgroundColor: const Color(0xFFFFC95B),
                                      onTap:
                                          () => _showPeopleSheet(
                                            event: event,
                                            participants: participants,
                                            canManageHands:
                                                viewer?.canManageHands ?? false,
                                            canInviteCohosts:
                                                viewer?.canInviteCohosts ??
                                                false,
                                          ),
                                    ),
                                ],
                              ),
                              if ((event.description ?? '')
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  event.description!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.35,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: appCachedImageProvider(
                                      event.creator?.profileImageUrl,
                                    ),
                                    child:
                                        event.creator?.profileImageUrl == null
                                            ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.creator?.name ?? 'Host',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${_formatRoleLabel(event.creator?.role ?? 'Host')} • $totalListeners in room',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    joined ? 'Connected' : 'Connecting...',
                                    style: TextStyle(
                                      color:
                                          joined
                                              ? const Color(0xFF8AFBA6)
                                              : const Color(0xFFFFC95B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _reactionOrder.length,
                            separatorBuilder:
                                (_, __) => SizedBox(width: Dimensions.width10),
                            itemBuilder: (context, index) {
                              final reaction = _reactionOrder[index];
                              final meta = _reactionMeta(reaction);
                              final enabled = viewer?.canSendReactions ?? false;

                              return GestureDetector(
                                onTap:
                                    enabled
                                        ? () =>
                                            controller.sendReaction(reaction)
                                        : null,
                                child: _GlassPanel(
                                  borderRadius: BorderRadius.circular(999),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  backgroundColor:
                                      enabled
                                          ? meta.background
                                          : Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                  child: AnimatedScale(
                                    scale: enabled ? 1 : 0.96,
                                    duration: const Duration(milliseconds: 180),
                                    child: Text(
                                      meta.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(child: _buildFloatingReactions()),
                  ),
                  if (!_chromeVisible)
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _GlassPanel(
                          borderRadius: BorderRadius.circular(999),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          backgroundColor: Colors.black.withValues(alpha: 0.16),
                          child: InkWell(
                            onTap: _toggleChrome,
                            borderRadius: BorderRadius.circular(999),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Show controls',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _chrome(
                      visible: _chromeVisible,
                      child: _GlassPanel(
                        borderRadius: BorderRadius.circular(999),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _controlButton(
                              icon:
                                  agoraHelper.speakerEnabled.value
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                              onTap: () => agoraHelper.toggleSpeaker(),
                            ),
                            _controlButton(
                              icon:
                                  agoraHelper.micMuted.value
                                      ? Icons.mic_off_rounded
                                      : Icons.mic_rounded,
                              onTap:
                                  viewer?.canPublishAudio ?? false
                                      ? () => agoraHelper.toggleMute()
                                      : null,
                              disabled: !(viewer?.canPublishAudio ?? false),
                            ),
                            if (event.sessionMode == 'interactive')
                              _controlButton(
                                icon:
                                    agoraHelper.cameraEnabled.value
                                        ? Icons.videocam_rounded
                                        : Icons.videocam_off_rounded,
                                onTap:
                                    viewer?.canPublishVideo ?? false
                                        ? () async {
                                          final granted =
                                              await controller
                                                  .requestCameraPermission();
                                          if (!granted) {
                                            return;
                                          }
                                          await agoraHelper.toggleCamera();
                                        }
                                        : null,
                                disabled: !(viewer?.canPublishVideo ?? false),
                              ),
                            if ((viewer?.canRaiseHand ?? false) ||
                                (viewer?.isHandRaised ?? false))
                              _controlButton(
                                icon:
                                    (viewer?.isHandRaised ?? false)
                                        ? Icons.pan_tool_alt_rounded
                                        : Icons.pan_tool_outlined,
                                onTap: () async {
                                  if (viewer?.isHandRaised ?? false) {
                                    await controller.lowerHand();
                                  } else {
                                    await controller.raiseHand();
                                  }
                                },
                                accentColor: const Color(0xFFFFC95B),
                              ),
                            _controlButton(
                              icon:
                                  isCreator
                                      ? Icons.call_end_rounded
                                      : Icons.logout,
                              onTap: isCreator ? _endSession : _leaveSession,
                              backgroundColor: const Color(0xFFEB5545),
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStageBackdrop({
    required EventModel event,
    required EventParticipantModel? featuredParticipant,
  }) {
    final fallbackImage =
        MediaUrlHelper.resolve(event.coverImageUrl) ??
        MediaUrlHelper.resolve(event.creator?.backgroundImageUrl) ??
        MediaUrlHelper.resolve(event.creator?.profileImageUrl);

    if (event.sessionMode == 'audio') {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (fallbackImage != null)
            AppCachedNetworkImage(
              imageUrl: fallbackImage,
              fit: BoxFit.cover,
              placeholderColor: AppColors.primary6,
              placeholderIcon: Icons.mic_none_rounded,
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF302018), Color(0xFF141414)],
                ),
              ),
            ),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.multitrack_audio_rounded,
                color: Colors.white,
                size: 58,
              ),
            ),
          ),
        ],
      );
    }

    if (featuredParticipant == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (fallbackImage != null)
            AppCachedNetworkImage(
              imageUrl: fallbackImage,
              fit: BoxFit.cover,
              placeholderColor: AppColors.primary6,
              placeholderIcon: Icons.videocam_off_rounded,
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF493226), Color(0xFF141414)],
                ),
              ),
            ),
          const Center(
            child: Text(
              'Waiting for host video',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return _buildParticipantVideoTile(
      event: event,
      participant: featuredParticipant,
      fullscreen: true,
    );
  }

  Widget _buildParticipantVideoTile({
    required EventModel event,
    required EventParticipantModel participant,
    required bool fullscreen,
  }) {
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

    final label =
        participant.name?.isNotEmpty == true
            ? participant.name!
            : participant.username?.isNotEmpty == true
            ? participant.username!
            : 'Participant';

    Widget content;
    if (hasVideo && agoraHelper.engine != null && channelName != null) {
      content =
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
              );
    } else {
      final imageUrl = MediaUrlHelper.resolve(participant.profileImageUrl);
      content = Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            AppCachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholderColor: Colors.black,
              placeholderIcon: Icons.person,
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF69473A), Color(0xFF1E1E1E)],
                ),
              ),
            ),
          Center(
            child: CircleAvatar(
              radius: fullscreen ? 54 : 30,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              backgroundImage:
                  imageUrl != null ? appCachedImageProvider(imageUrl) : null,
              child:
                  imageUrl == null
                      ? Text(
                        label.isNotEmpty ? label[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fullscreen ? 30 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                      : null,
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: content),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Row(
            children: [
              Flexible(
                child: _GlassPanel(
                  borderRadius: BorderRadius.circular(999),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  backgroundColor: Colors.black.withValues(alpha: 0.24),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _GlassPanel(
                borderRadius: BorderRadius.circular(999),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                backgroundColor: Colors.black.withValues(alpha: 0.24),
                child: Text(
                  (participant.role ?? 'live').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingReactions() {
    final reactions = controller.liveReactions.reversed.take(6).toList();
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        for (int index = 0; index < reactions.length; index++)
          Positioned(
            right: 18 + (index % 2) * 34,
            bottom: 92 + (index * 6),
            child: _FloatingReactionBubble(
              key: ValueKey(
                '${reactions[index].createdAt?.millisecondsSinceEpoch}-${reactions[index].actorId}-${reactions[index].reaction}-$index',
              ),
              reaction: reactions[index],
              meta: _reactionMeta(reactions[index].reaction),
            ),
          ),
      ],
    );
  }

  void _showPeopleSheet({
    required EventModel event,
    required List<EventParticipantModel> participants,
    required bool canManageHands,
    required bool canInviteCohosts,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.48,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF151515),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  SizedBox(height: Dimensions.height12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Row(
                      children: [
                        const Text(
                          'People in room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${participants.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  if (event.handRaiseQueue.isNotEmpty && canManageHands)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hands raised',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                event.handRaiseQueue.map((participant) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          participant.name?.isNotEmpty == true
                                              ? participant.name!
                                              : participant.username ??
                                                  'Participant',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed:
                                              () => controller.grantSpeaker(
                                                targetId: participant.id ?? '',
                                                targetType:
                                                    participant.type ?? '',
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
                    ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        final imageUrl = MediaUrlHelper.resolve(
                          participant.profileImageUrl,
                        );
                        final subtitleParts = <String>[
                          if (participant.role?.isNotEmpty ?? false)
                            _formatRoleLabel(participant.role!),
                          if (participant.handRaisedAt != null) 'Hand raised',
                          if (participant.isVerified) 'Verified',
                        ];

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    imageUrl != null
                                        ? appCachedImageProvider(imageUrl)
                                        : null,
                                child:
                                    imageUrl == null
                                        ? Text(
                                          (participant.name?.isNotEmpty ??
                                                  false)
                                              ? participant.name![0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      participant.name?.isNotEmpty == true
                                          ? participant.name!
                                          : participant.username?.isNotEmpty ==
                                              true
                                          ? participant.username!
                                          : 'Unknown participant',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (subtitleParts.isNotEmpty)
                                      Text(
                                        subtitleParts.join(' • '),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (canManageHands || canInviteCohosts)
                                PopupMenuButton<String>(
                                  color: AppColors.black1,
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ),
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
                                    if (canInviteCohosts &&
                                        participant.role != 'host') {
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
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
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
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (participant.role ==
                                          'speaker') {
                                        items.add(
                                          const PopupMenuItem<String>(
                                            value: 'remove_speaker',
                                            child: Text(
                                              'Move to audience',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _ReactionMeta _reactionMeta(String reaction) {
    switch (reaction) {
      case 'heart':
        return const _ReactionMeta(emoji: '❤️', background: Color(0x66FF577A));
      case 'fire':
        return const _ReactionMeta(emoji: '🔥', background: Color(0x66FF8C42));
      case 'party':
        return const _ReactionMeta(emoji: '🎉', background: Color(0x66C26DFF));
      case 'wow':
        return const _ReactionMeta(emoji: '😮', background: Color(0x66FFD76A));
      case 'thumbs_up':
        return const _ReactionMeta(emoji: '👍', background: Color(0x665A9CFF));
      case 'clap':
      default:
        return const _ReactionMeta(emoji: '👏', background: Color(0x66FFB15A));
    }
  }

  String _formatRoleLabel(String value) {
    switch (value.toLowerCase()) {
      case 'cohost':
        return 'Cohost';
      case 'speaker':
        return 'Speaker';
      case 'audience':
        return 'Audience';
      case 'host':
      default:
        return 'Host';
    }
  }

  static const List<String> _reactionOrder = <String>[
    'clap',
    'heart',
    'fire',
    'party',
    'wow',
    'thumbs_up',
  ];
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    required this.borderRadius,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.14),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.onTap,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: content,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ReactionMeta {
  const _ReactionMeta({required this.emoji, required this.background});

  final String emoji;
  final Color background;
}

class _FloatingReactionBubble extends StatelessWidget {
  const _FloatingReactionBubble({
    super.key,
    required this.reaction,
    required this.meta,
  });

  final LiveEventReactionModel reaction;
  final _ReactionMeta meta;

  @override
  Widget build(BuildContext context) {
    final seed = ((reaction.actorId ?? reaction.reaction).hashCode & 0x7fffffff);
    final horizontalDirection = seed.isEven ? 1.0 : -1.0;
    final horizontalDrift = 12 + (seed % 12);
    final spin = ((seed % 9) / 9) * 0.26;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        final sway =
            math.sin((value * math.pi * 1.6) + spin) *
            horizontalDrift *
            horizontalDirection;
        final opacity = value < 0.84 ? 1.0 : (1 - ((value - 0.84) / 0.16));
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(sway, -value * 220),
            child: Transform.rotate(
              angle: (value - 0.5) * spin,
              child: Transform.scale(
                scale: 0.82 + (value * 0.34),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: meta.background.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  meta.background,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: meta.background.withValues(alpha: 0.5),
                  blurRadius: 22,
                  spreadRadius: 1.5,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(meta.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }
}

Widget _controlButton({
  required IconData icon,
  Future<void> Function()? onTap,
  bool disabled = false,
  Color? backgroundColor,
  Color? iconColor,
  Color? accentColor,
}) {
  return InkWell(
    onTap: disabled || onTap == null ? null : () => onTap(),
    borderRadius: BorderRadius.circular(999),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            backgroundColor ??
            (disabled
                ? Colors.white.withValues(alpha: 0.08)
                : (accentColor ?? Colors.white).withValues(alpha: 0.14)),
        border: Border.all(
          color: (accentColor ?? Colors.white).withValues(
            alpha: disabled ? 0.08 : 0.22,
          ),
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color:
            disabled
                ? Colors.white38
                : iconColor ?? accentColor ?? Colors.white,
      ),
    ),
  );
}
