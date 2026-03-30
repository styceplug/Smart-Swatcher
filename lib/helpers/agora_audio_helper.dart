import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AgoraAudioHelper extends GetxService {
  RtcEngine? _engine;
  String? _currentAppId;
  String? _currentChannelName;
  int? _localUid;
  String _currentRole = 'audience';
  String _currentSessionMode = 'interactive';
  String _participantRole = 'audience';
  bool _canPublishAudio = false;
  bool _canPublishVideo = false;

  final RxList<int> remoteUserUids = <int>[].obs;
  final RxList<int> remoteVideoUserUids = <int>[].obs;
  final RxBool isInitialized = false.obs;
  final RxBool isJoined = false.obs;
  final RxBool micMuted = true.obs;
  final RxBool speakerEnabled = true.obs;
  final RxBool cameraEnabled = false.obs;
  final RxInt remoteUsersCount = 0.obs;

  bool _isInitializing = false;
  bool _isJoining = false;

  RtcEngine? get engine => _engine;
  String? get currentChannelName => _currentChannelName;
  int? get localUid => _localUid;
  bool get canPublishAudio => _canPublishAudio;
  bool get canPublishVideo => _canPublishVideo;
  String get participantRole => _participantRole;

  Future<void> initialize({
    required String appId,
    required String sessionMode,
    required String participantRole,
    required bool canPublishAudio,
    required bool canPublishVideo,
    required String clientRole,
  }) async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final sanitizedAppId = _sanitizeAppId(appId);

      if (_engine != null &&
          isInitialized.value &&
          _currentAppId == sanitizedAppId) {
        debugPrint('AGORA REUSE EXISTING ENGINE');
        await _applyRtcState(
          sessionMode: sessionMode,
          participantRole: participantRole,
          canPublishAudio: canPublishAudio,
          canPublishVideo: canPublishVideo,
          clientRole: clientRole,
        );
        await _configureAudioDefaults();
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
            _currentChannelName = connection.channelId;
            _localUid = connection.localUid;
            _applySpeakerphonePreference();
            _applyPostJoinMediaState();
            debugPrint('AGORA EVENT: joined channel');
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('AGORA USER JOINED => uid=$remoteUid elapsed=$elapsed');
            if (!remoteUserUids.contains(remoteUid)) {
              remoteUserUids.add(remoteUid);
            }
            remoteUsersCount.value = remoteUserUids.length;
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint('AGORA USER OFFLINE => uid=$remoteUid reason=$reason');
            remoteUserUids.remove(remoteUid);
            remoteVideoUserUids.remove(remoteUid);
            remoteUsersCount.value = remoteUserUids.length;
          },
          onLeaveChannel: (connection, stats) {
            isJoined.value = false;
            _currentChannelName = null;
            _localUid = null;
            remoteUserUids.clear();
            remoteVideoUserUids.clear();
            remoteUsersCount.value = 0;
          },
          onError: (err, msg) {
            debugPrint('AGORA ERROR => code: $err, message: $msg');
          },
          onConnectionStateChanged: (connection, state, reason) {
            debugPrint('AGORA CONNECTION => state=$state reason=$reason');
          },
          onRemoteAudioStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
            debugPrint(
              'AGORA REMOTE AUDIO => uid=$remoteUid state=$state reason=$reason elapsed=$elapsed',
            );
          },
          onUserEnableVideo: (connection, remoteUid, enabled) {
            debugPrint(
              'AGORA REMOTE VIDEO ENABLE => uid=$remoteUid enabled=$enabled',
            );
            if (enabled) {
              if (!remoteVideoUserUids.contains(remoteUid)) {
                remoteVideoUserUids.add(remoteUid);
              }
            } else {
              remoteVideoUserUids.remove(remoteUid);
            }
          },
          onUserMuteVideo: (connection, remoteUid, muted) {
            debugPrint('AGORA REMOTE VIDEO MUTE => uid=$remoteUid muted=$muted');
            if (muted) {
              remoteVideoUserUids.remove(remoteUid);
            } else if (!remoteVideoUserUids.contains(remoteUid)) {
              remoteVideoUserUids.add(remoteUid);
            }
          },
          onAudioVolumeIndication:
              (connection, speakers, speakerNumber, totalVolume) {
            if (speakers.isEmpty) return;
            final summary = speakers
                .map((speaker) => '${speaker.uid}:${speaker.volume}')
                .join(', ');
            debugPrint(
              'AGORA VOLUME => total=$totalVolume speakers=$summary count=$speakerNumber',
            );
          },
          onRequestToken: (connection) {
            debugPrint(
              'AGORA TOKEN REQUESTED => channel=${connection.channelId} uid=${connection.localUid}',
            );
          },
        ),
      );

      debugPrint('AGORA STEP 4: set role and media state');
      await _runAgoraBestEffortStep('enable audio', () => _engine!.enableAudio());
      await _runAgoraBestEffortStep(
        'set audio profile',
        () => _engine!.setAudioProfile(
          profile: AudioProfileType.audioProfileDefault,
          scenario: AudioScenarioType.audioScenarioChatroom,
        ),
      );
      await _runAgoraBestEffortStep(
        'enable audio volume indication',
        () => _engine!.enableAudioVolumeIndication(
          interval: 400,
          smooth: 3,
          reportVad: true,
        ),
      );
      await _applyRtcState(
        sessionMode: sessionMode,
        participantRole: participantRole,
        canPublishAudio: canPublishAudio,
        canPublishVideo: canPublishVideo,
        clientRole: clientRole,
      );
      await _configureAudioDefaults();

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

  Future<void> applyRtcUpdate({
    required String sessionMode,
    required String participantRole,
    required bool canPublishAudio,
    required bool canPublishVideo,
    required String clientRole,
    String? token,
  }) async {
    await _applyRtcState(
      sessionMode: sessionMode,
      participantRole: participantRole,
      canPublishAudio: canPublishAudio,
      canPublishVideo: canPublishVideo,
      clientRole: clientRole,
      token: token,
    );
  }

  Future<void> _applyRtcState({
    required String sessionMode,
    required String participantRole,
    required bool canPublishAudio,
    required bool canPublishVideo,
    required String clientRole,
    String? token,
  }) async {
    final previousCanPublishAudio = _canPublishAudio;
    final previousCanPublishVideo = _canPublishVideo;

    _currentRole = clientRole.toLowerCase();
    _currentSessionMode = sessionMode.toLowerCase();
    _participantRole = participantRole.toLowerCase();
    _canPublishAudio = canPublishAudio;
    _canPublishVideo = canPublishVideo;

    if (!_canPublishAudio) {
      micMuted.value = true;
    } else if (!previousCanPublishAudio && _participantRole == 'speaker') {
      micMuted.value = true;
    } else if (!previousCanPublishAudio &&
        (_participantRole == 'host' || _participantRole == 'cohost')) {
      micMuted.value = false;
    }

    if (!_canPublishVideo) {
      cameraEnabled.value = false;
    } else if (!previousCanPublishVideo && _participantRole == 'host') {
      cameraEnabled.value = true;
    }

    await _runAgoraBestEffortStep(
      'set client role',
      () => _setClientRole(_currentRole),
    );

    if (_currentSessionMode == 'interactive') {
      await _runAgoraBestEffortStep('enable video', () => _engine!.enableVideo());
    } else {
      cameraEnabled.value = false;
      remoteVideoUserUids.clear();
      await _runAgoraBestEffortStep(
        'disable video',
        () => _engine!.disableVideo(),
      );
    }

    if (isJoined.value && _engine != null) {
      if (token != null && token.trim().isNotEmpty) {
        await _runAgoraBestEffortStep('renew token', () => _engine!.renewToken(token));
      }
      await _updateChannelMediaOptions(token: token);
      _applyPostJoinMediaState();
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

  Future<void> _runAgoraBestEffortStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      debugPrint('AGORA STEP SOFT FAIL [$label] => $e');
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

  Future<void> _configureAudioDefaults() async {
    await _runAgoraBestEffortStep(
      'set default audio route to speakerphone',
      () => _engine!.setDefaultAudioRouteToSpeakerphone(true),
    );
    await _runAgoraBestEffortStep(
      'set speakerphone preference',
      () => _engine!.setEnableSpeakerphone(speakerEnabled.value),
    );
  }

  Future<void> _updateChannelMediaOptions({String? token}) async {
    if (_engine == null || !isJoined.value) return;

    await _runAgoraBestEffortStep(
      'update media options',
      () => _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(
          token: token,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: _currentRole == 'broadcaster'
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
          audienceLatencyLevel:
              AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          enableAudioRecordingOrPlayout: true,
          publishMicrophoneTrack: _canPublishAudio && !micMuted.value,
          publishCameraTrack: _canPublishVideo && cameraEnabled.value,
        ),
      ),
    );
  }

  void _applyPostJoinMediaState() {
    final engine = _engine;
    if (engine == null) return;

    unawaited(
      engine.enableLocalAudio(_canPublishAudio).catchError((Object e) {
        debugPrint('AGORA LOCAL AUDIO ENABLE ERROR => $e');
      }),
    );
    unawaited(
      engine
          .muteLocalAudioStream(!_canPublishAudio || micMuted.value)
          .catchError((Object e) {
        debugPrint('AGORA LOCAL MUTE APPLY ERROR => $e');
      }),
    );

    if (_currentSessionMode == 'interactive') {
      unawaited(
        engine.enableLocalVideo(_canPublishVideo).catchError((Object e) {
          debugPrint('AGORA LOCAL VIDEO ENABLE ERROR => $e');
        }),
      );
      unawaited(
        engine
            .muteLocalVideoStream(!_canPublishVideo || !cameraEnabled.value)
            .catchError((Object e) {
          debugPrint('AGORA LOCAL VIDEO MUTE ERROR => $e');
        }),
      );
      if (_canPublishVideo && cameraEnabled.value) {
        unawaited(
          engine.startPreview().catchError((Object e) {
            debugPrint('AGORA PREVIEW START ERROR => $e');
          }),
        );
      } else {
        unawaited(
          engine.stopPreview().catchError((Object e) {
            debugPrint('AGORA PREVIEW STOP ERROR => $e');
          }),
        );
      }
    }
  }

  Future<void> _setClientRole(String role) async {
    if (_engine == null) return;

    final roleType = role.toLowerCase() == 'broadcaster'
        ? ClientRoleType.clientRoleBroadcaster
        : ClientRoleType.clientRoleAudience;

    if (roleType == ClientRoleType.clientRoleBroadcaster) {
      await _engine!.setClientRole(role: roleType);
    } else {
      await _engine!.setClientRole(
        role: roleType,
        options: const ClientRoleOptions(
          audienceLatencyLevel:
              AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
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

      _currentChannelName = channelName;
      _localUid = uid;

      debugPrint('AGORA JOIN START');
      debugPrint('channelName => $channelName');
      debugPrint('uid => $uid');
      debugPrint('role => $_currentRole');

      final options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: _currentRole == 'broadcaster'
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        audienceLatencyLevel:
            AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        enableAudioRecordingOrPlayout: true,
        publishMicrophoneTrack: _canPublishAudio && !micMuted.value,
        publishCameraTrack: _canPublishVideo && cameraEnabled.value,
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
    if (_engine == null || !isJoined.value || !_canPublishAudio) return;

    final next = !micMuted.value;
    await _engine!.muteLocalAudioStream(next);
    micMuted.value = next;
    await _updateChannelMediaOptions();
  }

  Future<void> toggleSpeaker() async {
    if (_engine == null || !isJoined.value) return;

    final next = !speakerEnabled.value;
    await _engine!.setEnableSpeakerphone(next);
    speakerEnabled.value = next;
  }

  Future<void> toggleCamera() async {
    if (_engine == null || !isJoined.value || !_canPublishVideo) return;

    final next = !cameraEnabled.value;
    if (next) {
      await _engine!.enableVideo();
      await _engine!.enableLocalVideo(true);
      await _engine!.startPreview();
      await _engine!.muteLocalVideoStream(false);
    } else {
      await _engine!.muteLocalVideoStream(true);
      await _engine!.stopPreview();
      await _engine!.enableLocalVideo(false);
    }

    cameraEnabled.value = next;
    await _updateChannelMediaOptions();
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
      micMuted.value = true;
      cameraEnabled.value = false;
      _currentChannelName = null;
      _localUid = null;
      remoteUserUids.clear();
      remoteVideoUserUids.clear();
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
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (_) {}

    _engine = null;
    _currentAppId = null;
    _currentChannelName = null;
    _localUid = null;
    _currentRole = 'audience';
    _participantRole = 'audience';
    _currentSessionMode = 'interactive';
    _canPublishAudio = false;
    _canPublishVideo = false;
    isInitialized.value = false;
    isJoined.value = false;
    micMuted.value = true;
    cameraEnabled.value = false;
    speakerEnabled.value = true;
    remoteUserUids.clear();
    remoteVideoUserUids.clear();
    remoteUsersCount.value = 0;
  }
}
