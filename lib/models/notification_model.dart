class NotificationActorModel {
  final String? id;
  final String? type;
  final String? name;
  final String? username;
  final String? profileImageUrl;
  final DateTime? lastSeen;

  NotificationActorModel({
    this.id,
    this.type,
    this.name,
    this.username,
    this.profileImageUrl,
    this.lastSeen,
  });

  factory NotificationActorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationActorModel();

    return NotificationActorModel(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'].toString())
          : null,
    );
  }
}

class AppNotificationModel {
  final String? id;
  final String? recipientId;
  final String? recipientType;
  final NotificationActorModel? actor;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppNotificationModel({
    this.id,
    this.recipientId,
    this.recipientType,
    this.actor,
    this.type,
    this.title,
    this.body,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id']?.toString(),
      recipientId: json['recipientId']?.toString(),
      recipientType: json['recipientType']?.toString(),
      actor: NotificationActorModel.fromJson(json['actor']),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  bool get isRead => readAt != null;

  AppNotificationModel copyWith({
    String? id,
    String? recipientId,
    String? recipientType,
    NotificationActorModel? actor,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientType: recipientType ?? this.recipientType,
      actor: actor ?? this.actor,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String? get connectionStatus => data?['connectionStatus']?.toString();

  bool get isConnectionNotification =>
      type == 'connection_request' || type == 'connection_accepted';

  bool get isReplyNotification => type == 'reply' || type == 'comment_reply';

  bool get isActivityNotification =>
      !isConnectionNotification && !isReplyNotification;
}
