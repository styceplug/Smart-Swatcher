class EventCreatorModel {
  final String? id;
  final String? type;
  final String? name;
  final String? username;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String? about;
  final String? role;
  final String? country;
  final String? state;
  final bool isVerified;
  final bool isElite;

  EventCreatorModel({
    this.id,
    this.type,
    this.name,
    this.username,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.about,
    this.role,
    this.country,
    this.state,
    this.isVerified = false,
    this.isElite = false,
  });

  factory EventCreatorModel.fromJson(Map<String, dynamic> json) {
    return EventCreatorModel(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      backgroundImageUrl: json['backgroundImageUrl']?.toString(),
      about: json['about']?.toString(),
      role: json['role']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      isVerified: json['isVerified'] ?? false,
      isElite: json['isElite'] ?? false,
    );
  }
}

class EventViewerModel {
  final bool isCreator;
  final bool isSubscribed;
  final bool canView;
  final bool canEdit;
  final bool canStart;
  final bool canEnd;
  final bool canJoin;
  final String currentRole;
  final bool isOnStage;
  final bool isHandRaised;
  final DateTime? handRaisedAt;
  final bool canRaiseHand;
  final bool canManageHands;
  final bool canInviteCohosts;
  final bool canPublishAudio;
  final bool canPublishVideo;
  final bool canSendReactions;

  EventViewerModel({
    this.isCreator = false,
    this.isSubscribed = false,
    this.canView = false,
    this.canEdit = false,
    this.canStart = false,
    this.canEnd = false,
    this.canJoin = false,
    this.currentRole = 'audience',
    this.isOnStage = false,
    this.isHandRaised = false,
    this.handRaisedAt,
    this.canRaiseHand = false,
    this.canManageHands = false,
    this.canInviteCohosts = false,
    this.canPublishAudio = false,
    this.canPublishVideo = false,
    this.canSendReactions = false,
  });

  factory EventViewerModel.fromJson(Map<String, dynamic> json) {
    return EventViewerModel(
      isCreator: json['isCreator'] ?? false,
      isSubscribed: json['isSubscribed'] ?? false,
      canView: json['canView'] ?? false,
      canEdit: json['canEdit'] ?? false,
      canStart: json['canStart'] ?? false,
      canEnd: json['canEnd'] ?? false,
      canJoin: json['canJoin'] ?? false,
      currentRole: json['currentRole']?.toString() ?? 'audience',
      isOnStage: json['isOnStage'] ?? false,
      isHandRaised: json['isHandRaised'] ?? false,
      handRaisedAt: json['handRaisedAt'] != null
          ? DateTime.tryParse(json['handRaisedAt'].toString())
          : null,
      canRaiseHand: json['canRaiseHand'] ?? false,
      canManageHands: json['canManageHands'] ?? false,
      canInviteCohosts: json['canInviteCohosts'] ?? false,
      canPublishAudio: json['canPublishAudio'] ?? false,
      canPublishVideo: json['canPublishVideo'] ?? false,
      canSendReactions: json['canSendReactions'] ?? false,
    );
  }
}

class EventParticipantModel {
  final String? id;
  final String? type;
  final String? role;
  final int agoraUid;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final DateTime? handRaisedAt;
  final DateTime? speakerGrantedAt;
  final String? name;
  final String? username;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isCreator;
  final bool isJoined;
  final bool isOnStage;
  final bool canPublishAudio;
  final bool canPublishVideo;

  EventParticipantModel({
    this.id,
    this.type,
    this.role,
    this.agoraUid = 0,
    this.joinedAt,
    this.leftAt,
    this.handRaisedAt,
    this.speakerGrantedAt,
    this.name,
    this.username,
    this.profileImageUrl,
    this.isVerified = false,
    this.isCreator = false,
    this.isJoined = false,
    this.isOnStage = false,
    this.canPublishAudio = false,
    this.canPublishVideo = false,
  });

  factory EventParticipantModel.fromJson(Map<String, dynamic> json) {
    return EventParticipantModel(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      role: json['role']?.toString(),
      agoraUid: int.tryParse(json['agoraUid']?.toString() ?? '0') ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
      leftAt: json['leftAt'] != null
          ? DateTime.tryParse(json['leftAt'].toString())
          : null,
      handRaisedAt: json['handRaisedAt'] != null
          ? DateTime.tryParse(json['handRaisedAt'].toString())
          : null,
      speakerGrantedAt: json['speakerGrantedAt'] != null
          ? DateTime.tryParse(json['speakerGrantedAt'].toString())
          : null,
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      isVerified: json['isVerified'] ?? false,
      isCreator: json['isCreator'] ?? false,
      isJoined: json['isJoined'] ?? false,
      isOnStage: json['isOnStage'] ?? false,
      canPublishAudio: json['canPublishAudio'] ?? false,
      canPublishVideo: json['canPublishVideo'] ?? false,
    );
  }
}

class EventModel {
  final String? id;
  final String? title;
  final String? description;
  final String? coverImageUrl;
  final String? visibility;
  final String sessionMode;
  final bool audioOnly;
  final bool allowHandRaises;
  final DateTime? scheduledStartAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? status;
  final EventCreatorModel? creator;
  final int subscriberCount;
  final int liveParticipantCount;
  final List<EventParticipantModel> liveParticipants;
  final List<EventParticipantModel> assignedCohosts;
  final List<EventParticipantModel> handRaiseQueue;
  final EventViewerModel? viewer;

  final num? recommendationScore;
  final String? recommendationReason;
  final List<String> recommendationReasons;

  EventModel({
    this.id,
    this.title,
    this.description,
    this.coverImageUrl,
    this.visibility,
    this.sessionMode = 'interactive',
    this.audioOnly = true,
    this.allowHandRaises = true,
    this.scheduledStartAt,
    this.startedAt,
    this.endedAt,
    this.status,
    this.creator,
    this.subscriberCount = 0,
    this.liveParticipantCount = 0,
    this.liveParticipants = const [],
    this.assignedCohosts = const [],
    this.handRaiseQueue = const [],
    this.viewer,
    this.recommendationScore,
    this.recommendationReason,
    this.recommendationReasons = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      visibility: json['visibility']?.toString(),
      sessionMode: json['sessionMode']?.toString() ?? 'interactive',
      audioOnly: json['audioOnly'] ?? true,
      allowHandRaises: json['allowHandRaises'] ?? true,
      scheduledStartAt: json['scheduledStartAt'] != null
          ? DateTime.tryParse(json['scheduledStartAt'].toString())
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'].toString())
          : null,
      status: json['status']?.toString(),
      creator: json['creator'] != null
          ? EventCreatorModel.fromJson(json['creator'])
          : null,
      subscriberCount:
      int.tryParse(json['subscriberCount']?.toString() ?? '0') ?? 0,
      liveParticipantCount:
      int.tryParse(json['liveParticipantCount']?.toString() ?? '0') ?? 0,
      liveParticipants: json['liveParticipants'] != null
          ? List<Map<String, dynamic>>.from(json['liveParticipants'])
              .map(EventParticipantModel.fromJson)
              .toList()
          : const [],
      assignedCohosts: json['assignedCohosts'] != null
          ? List<Map<String, dynamic>>.from(json['assignedCohosts'])
              .map(EventParticipantModel.fromJson)
              .toList()
          : const [],
      handRaiseQueue: json['handRaiseQueue'] != null
          ? List<Map<String, dynamic>>.from(json['handRaiseQueue'])
              .map(EventParticipantModel.fromJson)
              .toList()
          : const [],
      viewer: json['viewer'] != null
          ? EventViewerModel.fromJson(json['viewer'])
          : null,
      recommendationScore: json['recommendationScore'],
      recommendationReason: json['recommendationReason']?.toString(),
      recommendationReasons: json['recommendationReasons'] != null
          ? List<String>.from(json['recommendationReasons'])
          : [],
    );
  }
}

class EventRtcModel {
  final String? appId;
  final String? channelName;
  final int? uid;
  final String? token;
  final String participantRole;
  final String sessionMode;
  final String? clientRole;
  final String? channelProfile;
  final bool audioOnly;
  final bool canPublishAudio;
  final bool canPublishVideo;
  final bool canManageHands;
  final bool canInviteCohosts;
  final DateTime? tokenExpiresAt;
  final DateTime? joinPrivilegeExpiresAt;
  final DateTime? publishAudioPrivilegeExpiresAt;
  final DateTime? publishVideoPrivilegeExpiresAt;

  EventRtcModel({
    this.appId,
    this.channelName,
    this.uid,
    this.token,
    this.participantRole = 'audience',
    this.sessionMode = 'interactive',
    this.clientRole,
    this.channelProfile,
    this.audioOnly = true,
    this.canPublishAudio = false,
    this.canPublishVideo = false,
    this.canManageHands = false,
    this.canInviteCohosts = false,
    this.tokenExpiresAt,
    this.joinPrivilegeExpiresAt,
    this.publishAudioPrivilegeExpiresAt,
    this.publishVideoPrivilegeExpiresAt,
  });

  factory EventRtcModel.fromJson(Map<String, dynamic> json) {
    return EventRtcModel(
      appId: json['appId']?.toString(),
      channelName: json['channelName']?.toString(),
      uid: int.tryParse(json['uid']?.toString() ?? ''),
      token: json['token']?.toString(),
      participantRole: json['participantRole']?.toString() ?? 'audience',
      sessionMode: json['sessionMode']?.toString() ?? 'interactive',
      clientRole: json['clientRole']?.toString(),
      channelProfile: json['channelProfile']?.toString(),
      audioOnly: json['audioOnly'] ?? true,
      canPublishAudio: json['canPublishAudio'] ?? false,
      canPublishVideo: json['canPublishVideo'] ?? false,
      canManageHands: json['canManageHands'] ?? false,
      canInviteCohosts: json['canInviteCohosts'] ?? false,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.tryParse(json['tokenExpiresAt'].toString())
          : null,
      joinPrivilegeExpiresAt: json['joinPrivilegeExpiresAt'] != null
          ? DateTime.tryParse(json['joinPrivilegeExpiresAt'].toString())
          : null,
      publishAudioPrivilegeExpiresAt:
      json['publishAudioPrivilegeExpiresAt'] != null
          ? DateTime.tryParse(
        json['publishAudioPrivilegeExpiresAt'].toString(),
      )
          : null,
      publishVideoPrivilegeExpiresAt:
      json['publishVideoPrivilegeExpiresAt'] != null
          ? DateTime.tryParse(
              json['publishVideoPrivilegeExpiresAt'].toString(),
            )
          : null,
    );
  }
}

class LiveEventReactionModel {
  final String eventId;
  final String reaction;
  final String? actorId;
  final String? actorType;
  final String? actorName;
  final String? actorProfileImageUrl;
  final DateTime? createdAt;

  LiveEventReactionModel({
    required this.eventId,
    required this.reaction,
    this.actorId,
    this.actorType,
    this.actorName,
    this.actorProfileImageUrl,
    this.createdAt,
  });

  factory LiveEventReactionModel.fromJson(Map<String, dynamic> json) {
    return LiveEventReactionModel(
      eventId: json['eventId']?.toString() ?? '',
      reaction: json['reaction']?.toString() ?? 'clap',
      actorId: json['actorId']?.toString(),
      actorType: json['actorType']?.toString(),
      actorName: json['actorName']?.toString(),
      actorProfileImageUrl: json['actorProfileImageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
