import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

class AgoraAudioHelper {
  RtcEngine? _engine;

  bool _initialized = false;
  bool _joined = false;
  bool _localMuted = false;
  bool _speakerEnabled = true;
  bool _isBroadcaster = false;

  int? localUid;
  final ValueNotifier<int> remoteUserCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> joinedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> mutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> speakerNotifier = ValueNotifier<bool>(true);

  bool get isInitialized => _initialized;
  bool get isJoined => _joined;
  bool get isMuted => _localMuted;
  bool get isSpeakerEnabled => _speakerEnabled;
  bool get isBroadcaster => _isBroadcaster;
  RtcEngine? get engine => _engine;

  Future<void> initialize({
    required String appId,
    required bool audioOnly,
    required String clientRole,
  }) async {
    if (_initialized) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine!.enableAudio();

    if (audioOnly) {
      await _engine!.disableVideo();
    }

    _isBroadcaster = clientRole.toLowerCase() == 'broadcaster';

    await _engine!.setClientRole(
      role: _isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    if (!kIsWeb && Platform.isIOS) {
      await _engine!.setEnableSpeakerphone(true);
      _speakerEnabled = true;
      speakerNotifier.value = true;
    }

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          localUid = connection.localUid;
          _joined = true;
          joinedNotifier.value = true;
          debugPrint('Agora joined successfully: uid=${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          remoteUserCount.value = remoteUserCount.value + 1;
          debugPrint('Remote user joined: $remoteUid');
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {
          if (remoteUserCount.value > 0) {
            remoteUserCount.value = remoteUserCount.value - 1;
          }
          debugPrint('Remote user left: $remoteUid');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _joined = false;
          joinedNotifier.value = false;
          remoteUserCount.value = 0;
          debugPrint('Left agora channel');
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora error: $err, $msg');
        },
      ),
    );

    _initialized = true;
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null) return;

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: _isBroadcaster,
        clientRoleType: _isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }

  Future<void> toggleMute() async {
    if (_engine == null || !_isBroadcaster) return;

    _localMuted = !_localMuted;
    await _engine!.muteLocalAudioStream(_localMuted);
    mutedNotifier.value = _localMuted;
  }

  Future<void> toggleSpeaker() async {
    if (_engine == null) return;

    _speakerEnabled = !_speakerEnabled;
    await _engine!.setEnableSpeakerphone(_speakerEnabled);
    speakerNotifier.value = _speakerEnabled;
  }

  Future<void> leaveChannel() async {
    if (_engine == null || !_joined) return;
    await _engine!.leaveChannel();
  }

  Future<void> disposeEngine() async {
    await leaveChannel();

    if (_engine != null) {
      await _engine!.release();
    }

    _engine = null;
    _initialized = false;
    _joined = false;
    _localMuted = false;
    _speakerEnabled = true;
    _isBroadcaster = false;
    localUid = null;
    remoteUserCount.value = 0;
    joinedNotifier.value = false;
    mutedNotifier.value = false;
    speakerNotifier.value = true;
  }
}