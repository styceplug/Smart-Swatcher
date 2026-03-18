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

  EventViewerModel({
    this.isCreator = false,
    this.isSubscribed = false,
    this.canView = false,
    this.canEdit = false,
    this.canStart = false,
    this.canEnd = false,
    this.canJoin = false,
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
    );
  }
}

class EventModel {
  final String? id;
  final String? title;
  final String? description;
  final String? coverImageUrl;
  final String? visibility;
  final DateTime? scheduledStartAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? status;
  final EventCreatorModel? creator;
  final int subscriberCount;
  final int liveParticipantCount;
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
    this.scheduledStartAt,
    this.startedAt,
    this.endedAt,
    this.status,
    this.creator,
    this.subscriberCount = 0,
    this.liveParticipantCount = 0,
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
  final String? clientRole;
  final String? channelProfile;
  final bool audioOnly;
  final DateTime? tokenExpiresAt;
  final DateTime? joinPrivilegeExpiresAt;
  final DateTime? publishAudioPrivilegeExpiresAt;

  EventRtcModel({
    this.appId,
    this.channelName,
    this.uid,
    this.token,
    this.clientRole,
    this.channelProfile,
    this.audioOnly = true,
    this.tokenExpiresAt,
    this.joinPrivilegeExpiresAt,
    this.publishAudioPrivilegeExpiresAt,
  });

  factory EventRtcModel.fromJson(Map<String, dynamic> json) {
    return EventRtcModel(
      appId: json['appId']?.toString(),
      channelName: json['channelName']?.toString(),
      uid: int.tryParse(json['uid']?.toString() ?? ''),
      token: json['token']?.toString(),
      clientRole: json['clientRole']?.toString(),
      channelProfile: json['channelProfile']?.toString(),
      audioOnly: json['audioOnly'] ?? true,
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
    );
  }
}