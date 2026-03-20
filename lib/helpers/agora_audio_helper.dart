import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
      final sanitizedAppId = _sanitizeAppId(appId);

      if (_engine != null &&
          isInitialized.value &&
          _currentAppId == sanitizedAppId) {
        debugPrint('AGORA REUSE EXISTING ENGINE');
        await _runAgoraStep('set client role', () => _setClientRole(_currentRole));
        return;
      }

      if (_engine != null) {
        await resetEngine();
      }

      debugPrint('AGORA APP ID LENGTH => ${sanitizedAppId.length}');
      if (!_looksLikeAgoraAppId(sanitizedAppId)) {
        debugPrint('AGORA WARNING => appId format looks unexpected');
      }

      debugPrint('AGORA STEP 1: create engine');
      _engine = createAgoraRtcEngine();
      _currentAppId = sanitizedAppId;

      debugPrint('AGORA STEP 2: initialize engine');
      await _runAgoraStep(
        'initialize engine',
        () => _engine!.initialize(
          RtcEngineContext(
            appId: sanitizedAppId,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          ),
        ),
      );

      debugPrint('AGORA STEP 3: register handlers');
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            isJoined.value = true;
            micMuted.value = false;
            speakerEnabled.value = true;
            _applySpeakerphonePreference();
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
      await _runAgoraStep('enable audio', () => _engine!.enableAudio());
      await _runAgoraStep('set client role', () => _setClientRole(_currentRole));
      await _runAgoraStep(
        'set audio profile',
        () => _engine!.setAudioProfile(
          profile: AudioProfileType.audioProfileDefault,
          scenario: AudioScenarioType.audioScenarioGameStreaming,
        ),
      );

      speakerEnabled.value = true;
      isInitialized.value = true;

      debugPrint('AGORA INIT SUCCESS');
    } catch (e) {
      debugPrint('AGORA INIT ERROR => $e');
      await resetEngine();
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _runAgoraStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      debugPrint('AGORA STEP FAILED [$label] => $e');
      rethrow;
    }
  }

  String _sanitizeAppId(String appId) {
    return appId.trim().replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\s]+'), '');
  }

  bool _looksLikeAgoraAppId(String appId) {
    return RegExp(r'^[a-fA-F0-9]{32}$').hasMatch(appId);
  }

  void _applySpeakerphonePreference() {
    final engine = _engine;
    if (engine == null) return;

    unawaited(
      engine.setEnableSpeakerphone(speakerEnabled.value).catchError((Object e) {
        debugPrint('AGORA SPEAKERPHONE ERROR => $e');
      }),
    );
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
