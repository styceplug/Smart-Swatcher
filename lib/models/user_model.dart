class RecommendedAccountModel {
  final String id;
  final String type;
  final String name;
  final String? username;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String? role;
  final bool isVerified;
  final int accountTier;
  final String? country;
  final String? state;
  final String? description;
  final String? about;
  final String? saloonName;
  final bool isElite;
  final DateTime? lastSeen;
  final String? recommendationReason;
  final List<String> recommendationReasons;
  final int recommendationScore;

  RecommendedAccountModel({
    required this.id,
    required this.type,
    required this.name,
    this.username,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.role,
    required this.isVerified,
    required this.accountTier,
    this.country,
    this.state,
    this.description,
    this.about,
    this.saloonName,
    required this.isElite,
    this.lastSeen,
    this.recommendationReason,
    required this.recommendationReasons,
    required this.recommendationScore,
  });

  factory RecommendedAccountModel.fromJson(Map<String, dynamic> json) {
    return RecommendedAccountModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      backgroundImageUrl: json['backgroundImageUrl']?.toString(),
      role: json['role']?.toString(),
      isVerified: json['isVerified'] ?? false,
      accountTier: int.tryParse(json['accountTier'].toString()) ?? 0,
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      description: json['description']?.toString(),
      about: json['about']?.toString(),
      saloonName: json['saloonName']?.toString(),
      isElite: json['isElite'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'].toString())
          : null,
      recommendationReason: json['recommendationReason']?.toString(),
      recommendationReasons: json['recommendationReasons'] != null
          ? List<String>.from(json['recommendationReasons'])
          : [],
      recommendationScore:
      int.tryParse(json['recommendationScore'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "name": name,
      "username": username,
      "profileImageUrl": profileImageUrl,
      "backgroundImageUrl": backgroundImageUrl,
      "role": role,
      "isVerified": isVerified,
      "accountTier": accountTier,
      "country": country,
      "state": state,
      "description": description,
      "about": about,
      "saloonName": saloonName,
      "isElite": isElite,
      "lastSeen": lastSeen?.toIso8601String(),
      "recommendationReason": recommendationReason,
      "recommendationReasons": recommendationReasons,
      "recommendationScore": recommendationScore,
    };
  }

  String get displayHandle {
    if (username != null && username!.trim().isNotEmpty) {
      return '@$username';
    }
    return '';
  }

  String get displayLocation {
    final parts = [state, country]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();

    return parts.join(', ');
  }

  String get subtitle {
    if (type == 'company') {
      return role?.trim().isNotEmpty == true ? role! : 'Company';
    }

    if (saloonName != null && saloonName!.trim().isNotEmpty) {
      return saloonName!;
    }

    return 'Stylist';
  }
}

class ConnectionPeerModel {
  final String connectionId;
  final String status;
  final String id;
  final String type;
  final String name;
  final String? username;
  final String? profileImageUrl;
  final String? role;
  final bool isVerified;
  final bool isElite;

  const ConnectionPeerModel({
    required this.connectionId,
    required this.status,
    required this.id,
    required this.type,
    required this.name,
    this.username,
    this.profileImageUrl,
    this.role,
    this.isVerified = false,
    this.isElite = false,
  });

  factory ConnectionPeerModel.fromConnectionJson(
    Map<String, dynamic> json, {
    required String selfId,
    required String selfType,
  }) {
    final requester = Map<String, dynamic>.from(
      json['requester'] as Map? ?? const <String, dynamic>{},
    );
    final addressee = Map<String, dynamic>.from(
      json['addressee'] as Map? ?? const <String, dynamic>{},
    );
    final isRequesterSelf =
        requester['id']?.toString() == selfId &&
        requester['type']?.toString() == selfType;
    final peer = isRequesterSelf ? addressee : requester;

    return ConnectionPeerModel(
      connectionId: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      id: peer['id']?.toString() ?? '',
      type: peer['type']?.toString() ?? '',
      name: peer['name']?.toString() ?? '',
      username: peer['username']?.toString(),
      profileImageUrl: peer['profileImageUrl']?.toString(),
      role: peer['role']?.toString(),
      isVerified: peer['isVerified'] == true,
      isElite: peer['isElite'] == true,
    );
  }
}

class OtherProfileModel {
  final String? id;
  final String? type;
  final String? name;
  final String? username;
  final String? description;
  final String? about;
  final String? role;
  final bool? isElite;
  final String? profileImageUrl;
  final String? backgroundImageUrl;

  final int? likes;
  final int? posts;
  final int? connections;
  final ProfileViewerRelationshipModel viewer;

  OtherProfileModel({
    this.id,
    this.type,
    this.name,
    this.username,
    this.description,
    this.about,
    this.role,
    this.isElite,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.likes,
    this.posts,
    this.connections,
    this.viewer = const ProfileViewerRelationshipModel(),
  });

  factory OtherProfileModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'];

    return OtherProfileModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      username: json['username'],
      description: json['description'],
      about: json['about'],
      role: json['role'],
      isElite: json['isElite'],
      profileImageUrl: json['profileImageUrl'],
      backgroundImageUrl: json['backgroundImageUrl'],
      likes: totals?['likes'],
      posts: totals?['generalPosts'],
      connections: totals?['connections'],
      viewer: ProfileViewerRelationshipModel.fromJson(
        json['viewer'] is Map<String, dynamic>
            ? json['viewer'] as Map<String, dynamic>
            : null,
      ),
    );
  }

  OtherProfileModel copyWith({
    String? id,
    String? type,
    String? name,
    String? username,
    String? description,
    String? about,
    String? role,
    bool? isElite,
    String? profileImageUrl,
    String? backgroundImageUrl,
    int? likes,
    int? posts,
    int? connections,
    ProfileViewerRelationshipModel? viewer,
  }) {
    return OtherProfileModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      about: about ?? this.about,
      role: role ?? this.role,
      isElite: isElite ?? this.isElite,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      likes: likes ?? this.likes,
      posts: posts ?? this.posts,
      connections: connections ?? this.connections,
      viewer: viewer ?? this.viewer,
    );
  }
}

enum ProfilePrimaryAction {
  none,
  connect,
  requested,
  accept,
  message,
}

class ProfileViewerRelationshipModel {
  final bool isSelf;
  final String? connectionId;
  final String connectionStatus;
  final bool requestedByViewer;
  final bool requestedByThem;
  final bool isConnected;
  final bool canRequestConnection;
  final bool canAcceptConnection;
  final bool canMessage;

  const ProfileViewerRelationshipModel({
    this.isSelf = false,
    this.connectionId,
    this.connectionStatus = 'none',
    this.requestedByViewer = false,
    this.requestedByThem = false,
    this.isConnected = false,
    this.canRequestConnection = false,
    this.canAcceptConnection = false,
    this.canMessage = false,
  });

  factory ProfileViewerRelationshipModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProfileViewerRelationshipModel();
    }

    return ProfileViewerRelationshipModel(
      isSelf: json['isSelf'] == true,
      connectionId: json['connectionId']?.toString(),
      connectionStatus: json['connectionStatus']?.toString() ?? 'none',
      requestedByViewer: json['requestedByViewer'] == true,
      requestedByThem: json['requestedByThem'] == true,
      isConnected: json['isConnected'] == true,
      canRequestConnection: json['canRequestConnection'] == true,
      canAcceptConnection: json['canAcceptConnection'] == true,
      canMessage: json['canMessage'] == true,
    );
  }

  ProfileViewerRelationshipModel copyWith({
    bool? isSelf,
    String? connectionId,
    String? connectionStatus,
    bool? requestedByViewer,
    bool? requestedByThem,
    bool? isConnected,
    bool? canRequestConnection,
    bool? canAcceptConnection,
    bool? canMessage,
  }) {
    return ProfileViewerRelationshipModel(
      isSelf: isSelf ?? this.isSelf,
      connectionId: connectionId ?? this.connectionId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      requestedByViewer: requestedByViewer ?? this.requestedByViewer,
      requestedByThem: requestedByThem ?? this.requestedByThem,
      isConnected: isConnected ?? this.isConnected,
      canRequestConnection: canRequestConnection ?? this.canRequestConnection,
      canAcceptConnection: canAcceptConnection ?? this.canAcceptConnection,
      canMessage: canMessage ?? this.canMessage,
    );
  }

  ProfilePrimaryAction get primaryAction {
    if (isSelf) {
      return ProfilePrimaryAction.none;
    }
    if (canMessage || isConnected || connectionStatus == 'connected') {
      return ProfilePrimaryAction.message;
    }
    if (canAcceptConnection || requestedByThem) {
      return ProfilePrimaryAction.accept;
    }
    if (requestedByViewer || connectionStatus == 'requested_by_viewer') {
      return ProfilePrimaryAction.requested;
    }
    if (canRequestConnection || connectionStatus == 'none') {
      return ProfilePrimaryAction.connect;
    }
    return ProfilePrimaryAction.connect;
  }

  bool get isPrimaryActionEnabled {
    switch (primaryAction) {
      case ProfilePrimaryAction.requested:
      case ProfilePrimaryAction.none:
        return false;
      case ProfilePrimaryAction.connect:
      case ProfilePrimaryAction.accept:
      case ProfilePrimaryAction.message:
        return true;
    }
  }

  String get primaryActionLabel {
    switch (primaryAction) {
      case ProfilePrimaryAction.none:
        return '';
      case ProfilePrimaryAction.connect:
        return 'Connect';
      case ProfilePrimaryAction.requested:
        return 'Requested';
      case ProfilePrimaryAction.accept:
        return 'Accept';
      case ProfilePrimaryAction.message:
        return 'Message';
    }
  }
}
