enum ConversationType {
  private,
  group,
  unknown;

  factory ConversationType.fromJson(dynamic value) {
    switch (value?.toString()) {
      case 'private':
        return ConversationType.private;
      case 'group':
        return ConversationType.group;
      default:
        return ConversationType.unknown;
    }
  }
}

enum MessageMediaType {
  image,
  video,
  audio,
  voice,
  sticker,
  file,
  unknown;

  factory MessageMediaType.fromJson(dynamic value) {
    switch (value?.toString()) {
      case 'image':
        return MessageMediaType.image;
      case 'video':
        return MessageMediaType.video;
      case 'audio':
        return MessageMediaType.audio;
      case 'voice':
        return MessageMediaType.voice;
      case 'sticker':
        return MessageMediaType.sticker;
      case 'file':
        return MessageMediaType.file;
      default:
        return MessageMediaType.unknown;
    }
  }
}

class ConversationProfileModel {
  final String id;
  final String? type;
  final String? name;
  final String? username;
  final String? profileImageUrl;
  final DateTime? lastSeen;

  const ConversationProfileModel({
    required this.id,
    this.type,
    this.name,
    this.username,
    this.profileImageUrl,
    this.lastSeen,
  });

  factory ConversationProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ConversationProfileModel(id: '');
    }

    return ConversationProfileModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'].toString())
          : null,
    );
  }

  String get displayName {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedUsername = username?.trim() ?? '';
    if (trimmedUsername.isNotEmpty) {
      return '@$trimmedUsername';
    }

    return 'Unknown user';
  }
}

class ConversationActorRef {
  final String id;
  final String type;

  const ConversationActorRef({
    required this.id,
    required this.type,
  });

  factory ConversationActorRef.fromJson(Map<String, dynamic>? json) {
    return ConversationActorRef(
      id: json?['id']?.toString() ?? '',
      type: json?['type']?.toString() ?? '',
    );
  }
}

class ConversationParticipantModel {
  final String id;
  final String? role;
  final ConversationProfileModel profile;
  final DateTime? removedAt;
  final DateTime? joinedAt;

  const ConversationParticipantModel({
    required this.id,
    required this.role,
    required this.profile,
    required this.removedAt,
    required this.joinedAt,
  });

  factory ConversationParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantModel(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString(),
      profile: ConversationProfileModel.fromJson(
        json['profile'] is Map<String, dynamic>
            ? json['profile'] as Map<String, dynamic>
            : null,
      ),
      removedAt: json['removedAt'] != null
          ? DateTime.tryParse(json['removedAt'].toString())
          : null,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
    );
  }
}

class ConversationMediaModel {
  final String id;
  final String? url;
  final MessageMediaType mediaType;
  final Map<String, dynamic> metadata;
  final int? position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationMediaModel({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.metadata,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationMediaModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];

    return ConversationMediaModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString(),
      mediaType: MessageMediaType.fromJson(json['mediaType']),
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
      position: json['position'] is int
          ? json['position'] as int
          : int.tryParse(json['position']?.toString() ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  String get fileName {
    final metadataName = metadata['name']?.toString().trim() ?? '';
    if (metadataName.isNotEmpty) {
      return metadataName;
    }

    final rawUrl = url?.trim() ?? '';
    if (rawUrl.isEmpty) {
      return 'Attachment';
    }

    final segments = rawUrl.split('/');
    return segments.isNotEmpty ? segments.last : 'Attachment';
  }
}

class ConversationMessageModel {
  final String id;
  final String conversationId;
  final ConversationProfileModel sender;
  final String? text;
  final List<ConversationMediaModel> media;
  final String? replyToMessageId;
  final ConversationMessageModel? replyTo;
  final Map<String, dynamic> metadata;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationMessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.text,
    required this.media,
    required this.replyToMessageId,
    required this.replyTo,
    required this.metadata,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    final rawMetadata = json['metadata'];

    return ConversationMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      sender: ConversationProfileModel.fromJson(
        json['sender'] is Map<String, dynamic>
            ? json['sender'] as Map<String, dynamic>
            : null,
      ),
      text: json['text']?.toString(),
      media: rawMedia is List
          ? rawMedia
              .whereType<Map>()
              .map(
                (item) => ConversationMediaModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <ConversationMediaModel>[],
      replyToMessageId: json['replyToMessageId']?.toString(),
      replyTo: json['replyTo'] is Map<String, dynamic>
          ? ConversationMessageModel.fromJson(
              json['replyTo'] as Map<String, dynamic>,
            )
          : null,
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  bool get hasText => (text?.trim().isNotEmpty ?? false);
  bool get hasMedia => media.isNotEmpty;
}

class ConversationSummaryModel {
  final String id;
  final ConversationType type;
  final String? title;
  final ConversationActorRef createdBy;
  final List<ConversationParticipantModel> participants;
  final ConversationMessageModel? lastMessage;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationSummaryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.createdBy,
    required this.participants,
    required this.lastMessage,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];

    return ConversationSummaryModel(
      id: json['id']?.toString() ?? '',
      type: ConversationType.fromJson(json['type']),
      title: json['title']?.toString(),
      createdBy: ConversationActorRef.fromJson(
        json['createdBy'] is Map<String, dynamic>
            ? json['createdBy'] as Map<String, dynamic>
            : null,
      ),
      participants: rawParticipants is List
          ? rawParticipants
              .whereType<Map>()
              .map(
                (item) => ConversationParticipantModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <ConversationParticipantModel>[],
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? ConversationMessageModel.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            )
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  bool get isPrivate => type == ConversationType.private;
  bool get isGroup => type == ConversationType.group;

  ConversationParticipantModel? otherParticipant(String? actorId) {
    if (actorId == null || actorId.trim().isEmpty) {
      return participants.isNotEmpty ? participants.first : null;
    }

    try {
      return participants.firstWhere((item) => item.profile.id != actorId);
    } catch (_) {
      return participants.isNotEmpty ? participants.first : null;
    }
  }

  String displayTitle(String? actorId) {
    if (isGroup) {
      final trimmedTitle = title?.trim() ?? '';
      if (trimmedTitle.isNotEmpty) {
        return trimmedTitle;
      }
      return 'Group chat';
    }

    return otherParticipant(actorId)?.profile.displayName ?? 'Conversation';
  }

  String displaySubtitle() {
    final message = lastMessage;
    if (message == null) {
      return 'No messages yet';
    }

    if (message.hasText) {
      return message.text!.trim();
    }

    if (message.hasMedia) {
      final firstMedia = message.media.first;
      switch (firstMedia.mediaType) {
        case MessageMediaType.image:
          return 'Photo';
        case MessageMediaType.video:
          return 'Video';
        case MessageMediaType.audio:
        case MessageMediaType.voice:
          return 'Audio';
        case MessageMediaType.file:
          return firstMedia.fileName;
        case MessageMediaType.sticker:
          return 'Sticker';
        case MessageMediaType.unknown:
          return 'Attachment';
      }
    }

    return 'Unsupported message';
  }
}

class ConnectionProfileModel {
  final String id;
  final String? type;
  final String? name;
  final String? username;
  final String? profileImageUrl;

  const ConnectionProfileModel({
    required this.id,
    this.type,
    this.name,
    this.username,
    this.profileImageUrl,
  });

  factory ConnectionProfileModel.fromJson(Map<String, dynamic>? json) {
    return ConnectionProfileModel(
      id: json?['id']?.toString() ?? '',
      type: json?['type']?.toString(),
      name: json?['name']?.toString(),
      username: json?['username']?.toString(),
      profileImageUrl: json?['profileImageUrl']?.toString(),
    );
  }

  String get displayName {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedUsername = username?.trim() ?? '';
    if (trimmedUsername.isNotEmpty) {
      return '@$trimmedUsername';
    }

    return 'Unknown user';
  }
}

class ConnectionRecordModel {
  final String id;
  final String? status;
  final ConnectionProfileModel requester;
  final ConnectionProfileModel addressee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConnectionRecordModel({
    required this.id,
    required this.status,
    required this.requester,
    required this.addressee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConnectionRecordModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRecordModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString(),
      requester: ConnectionProfileModel.fromJson(
        json['requester'] is Map<String, dynamic>
            ? json['requester'] as Map<String, dynamic>
            : null,
      ),
      addressee: ConnectionProfileModel.fromJson(
        json['addressee'] is Map<String, dynamic>
            ? json['addressee'] as Map<String, dynamic>
            : null,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  ConnectionProfileModel otherParty(String currentActorId) {
    if (requester.id == currentActorId) {
      return addressee;
    }

    return requester;
  }
}
