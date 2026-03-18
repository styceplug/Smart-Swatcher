import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraAudioHelper extends GetxService {
  RtcEngine? _engine;

  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool micMuted = false.obs;
  final RxBool speakerEnabled = false.obs;
  final RxInt remoteUsersCount = 0.obs;

  RtcEngine? get engine => _engine;

  Future<void> initialize({
    required String appId,
    bool audioOnly = true,
    String clientRole = 'audience',
  }) async {
    if (isInitialized.value && _engine != null) return;

    if (Platform.isIOS || Platform.isAndroid) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        throw Exception('Microphone permission denied');
      }
    }

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

    await _engine!.setClientRole(
      role: clientRole.toLowerCase() == 'broadcaster'
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    await _engine!.setEnableSpeakerphone(true);
    speakerEnabled.value = true;

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined.value = true;
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          isJoined.value = false;
          remoteUsersCount.value = 0;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          remoteUsersCount.value++;
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {
          if (remoteUsersCount.value > 0) {
            remoteUsersCount.value--;
          }
        },
        onError: (ErrorCodeType err, String msg) {
          print('AGORA ERROR => ${err.value} | $msg');
        },
      ),
    );

    isInitialized.value = true;
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null || !isInitialized.value) {
      throw Exception('Agora engine is not initialized');
    }

    if (isJoined.value) {
      await leaveChannel();
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
        publishCameraTrack: false,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> joinAsAudience({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null || !isInitialized.value) {
      throw Exception('Agora engine is not initialized');
    }

    if (isJoined.value) {
      await leaveChannel();
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;
    micMuted.value = !micMuted.value;
    await _engine!.muteLocalAudioStream(micMuted.value);
  }

  Future<void> toggleSpeaker() async {
    if (_engine == null) return;
    speakerEnabled.value = !speakerEnabled.value;
    await _engine!.setEnableSpeakerphone(speakerEnabled.value);
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
    isJoined.value = false;
    remoteUsersCount.value = 0;
  }

  Future<void> disposeEngine() async {
    await leaveChannel();
    await _engine?.release();
    _engine = null;
    isInitialized.value = false;
  }
}