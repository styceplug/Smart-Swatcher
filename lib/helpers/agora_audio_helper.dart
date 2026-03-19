import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AgoraAudioHelper extends GetxService {
  RtcEngine? _engine;
  String? _currentAppId;
  String _currentRole = 'audience';

  final RxList<int> remoteUserUids = <int>[].obs;
  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool micMuted = false.obs;
  final RxBool speakerEnabled = true.obs;
  final RxInt remoteUsersCount = 0.obs;

  bool _isInitializing = false;
  bool _isJoining = false;

  Future<void> initialize({
    required String appId,
    required bool audioOnly,
    required String clientRole,
  }) async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      _currentRole = clientRole.toLowerCase();
      // 1. Sanitize the App ID to prevent hidden character errors
      final sanitizedAppId = appId.trim().replaceAll(RegExp(r'[^\x20-\x7E]'), '');

      if (_engine != null &&
          isInitialized.value &&
          _currentAppId == sanitizedAppId) {
        debugPrint('AGORA REUSE EXISTING ENGINE');
        await _setClientRole(_currentRole);
        _isInitializing = false;
        return;
      }

      if (_engine != null) {
        await resetEngine();
      }

      debugPrint('AGORA STEP 1: create engine');
      _engine = createAgoraRtcEngine();
      _currentAppId = sanitizedAppId;

      debugPrint('AGORA STEP 2: initialize engine');
      // 2. Initialize with ONLY the AppId first.
      // Setting channelProfile inside the context can sometimes trigger -3 on certain devices.
      await _engine!.initialize(RtcEngineContext(appId: sanitizedAppId));

      // 3. Set the Channel Profile explicitly after initialization
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );

      debugPrint('AGORA STEP 3: register handlers');
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) async {
            isJoined.value = true;
            micMuted.value = false;
            speakerEnabled.value = true;
            debugPrint('AGORA EVENT: joined channel');
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (!remoteUserUids.contains(remoteUid)) {
              remoteUserUids.add(remoteUid);
            }
            remoteUsersCount.value = remoteUserUids.length;
          },
          onUserOffline: (connection, remoteUid, reason) {
            remoteUserUids.remove(remoteUid);
            remoteUsersCount.value = remoteUserUids.length;
          },
          onLeaveChannel: (connection, stats) {
            isJoined.value = false;
            remoteUserUids.clear();
            remoteUsersCount.value = 0;
          },
          onError: (err, msg) {
            debugPrint('AGORA ERROR => code: $err, message: $msg');
          },
        ),
      );

      debugPrint('AGORA STEP 4: set role and enable audio');
      // 4. Set the role before enabling the audio module
      await _setClientRole(_currentRole);

      // 5. Finally, enable audio
      await _engine!.enableAudio();

      // Set speakerphone last
      await _engine!.setEnableSpeakerphone(true);

      speakerEnabled.value = true;
      isInitialized.value = true;

      debugPrint('AGORA INIT SUCCESS');
    } catch (e) {
      debugPrint('AGORA INIT ERROR => $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }


  Future<void> _setClientRole(String role) async {
    if (_engine == null) return;

    ClientRoleType roleType = role.toLowerCase() == 'broadcaster'
        ? ClientRoleType.clientRoleBroadcaster
        : ClientRoleType.clientRoleAudience;

    if (roleType == ClientRoleType.clientRoleBroadcaster) {
      // Broadcasters do not use ClientRoleOptions for latency
      await _engine!.setClientRole(role: roleType);
    } else {
      // Only audiences need the latency level
      await _engine!.setClientRole(
        role: roleType,
        options: const ClientRoleOptions(
          audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        ),
      );
    }
  }




  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null) {
      throw Exception('Agora engine is null');
    }

    if (!isInitialized.value) {
      throw Exception('Agora engine not initialized');
    }

    if (_isJoining) return;
    _isJoining = true;

    try {
      if (isJoined.value) {
        await leaveChannel();
        await Future.delayed(const Duration(milliseconds: 350));
      }

      debugPrint('AGORA JOIN START');
      debugPrint('channelName => $channelName');
      debugPrint('uid => $uid');
      debugPrint('role => $_currentRole');

      final options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType:
            _currentRole == 'broadcaster'
                ? ClientRoleType.clientRoleBroadcaster
                : ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        publishMicrophoneTrack: _currentRole == 'broadcaster',
      );

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: options,
      );

      debugPrint('AGORA JOIN CALLED');
    } catch (e) {
      debugPrint('AGORA JOIN ERROR => $e');
      rethrow;
    } finally {
      _isJoining = false;
    }
  }

  Future<void> toggleMute() async {
    if (_engine == null || !isJoined.value) return;

    final next = !micMuted.value;
    await _engine!.muteLocalAudioStream(next);
    micMuted.value = next;
  }

  Future<void> toggleSpeaker() async {
    if (_engine == null || !isJoined.value) return;

    final next = !speakerEnabled.value;
    await _engine!.setEnableSpeakerphone(next);
    speakerEnabled.value = next;
  }

  Future<void> leaveChannel() async {
    try {
      if (_engine != null && isJoined.value) {
        await _engine!.leaveChannel();
      }
    } catch (e) {
      debugPrint('AGORA LEAVE ERROR => $e');
    } finally {
      isJoined.value = false;
      micMuted.value = false;
      remoteUserUids.clear();
      remoteUsersCount.value = 0;
    }
  }

  Future<void> resetEngine() async {
    try {
      if (_engine != null) {
        try {
          if (isJoined.value) await _engine!.leaveChannel();
        } catch (_) {}
        await _engine!.release();
        await Future.delayed(const Duration(milliseconds: 300)); // <-- add
      }
    } catch (_) {}

    _engine = null;
    _currentAppId = null;
    isInitialized.value = false;
    isJoined.value = false;
    micMuted.value = false;
    speakerEnabled.value = true;
    remoteUserUids.clear();
    remoteUsersCount.value = 0;
  }
}
