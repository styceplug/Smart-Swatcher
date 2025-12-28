import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/app_constants.dart';

class PostModel {
  String id;
  String caption;
  String targetAudience;
  String createdAt;
  Author? author;
  List<MediaItem> media;
  List<String> tags;
  PostMetrics? metrics;
  bool isLiked;
  bool isSaved;
  String? base;
  String? lights;
  String? toner;

  PostModel({
    required this.id,
    required this.caption,
    required this.targetAudience,
    required this.createdAt,
    this.author,
    this.media = const [],
    this.tags = const [],
    this.metrics,
    this.isLiked = false,
    this.isSaved = false,
    this.base,
    this.lights,
    this.toner,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {

    var viewer = json['viewer'] ?? {};

    return PostModel(
      id: json['id'],
      caption: json['caption'] ?? "",
      targetAudience: json['targetAudience'] ?? "General",
      createdAt: json['createdAt'] ?? "",
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      media: json['media'] != null
          ? (json['media'] as List).map((e) => MediaItem.fromJson(e)).toList()
          : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isLiked: viewer['liked'] ?? false,
      isSaved: viewer['saved'] ?? false,
      metrics: json['metrics'] != null ? PostMetrics.fromJson(json['metrics']) : null,
      base: null,
      lights: null,
      toner: null,
    );
  }


  int get saveCount => metrics?.saves ?? 0;

  String get username => author?.username ?? "Unknown";
  String get userRole => author?.type?.capitalizeFirst ?? "Stylist"; // e.g., "Stylist"
  String get userProfileImage => author?.profileImageUrl ?? "";

  String? get displayImageUrl {
    if (media.isNotEmpty) {
      String rawUrl = media.first.url;
      if (rawUrl.startsWith('/')) {
        return '${AppConstants.BASE_URL}$rawUrl';
      }
      return rawUrl;
    }
    return null;
  }

  int get likeCount => metrics?.likes ?? 0;
  int get commentCount => metrics?.comments ?? 0;


  String get timeAgo {
    if (createdAt.isEmpty) return "";
    DateTime created = DateTime.parse(createdAt);
    Duration diff = DateTime.now().difference(created);

    if (diff.inDays > 7) {
      return DateFormat('MMM d').format(created);
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class Author {
  String id;
  String type;
  String name;
  String username;
  String? profileImageUrl;
  bool isVerified;

  Author({
    required this.id,
    required this.type,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.isVerified,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      type: json['type'] ?? "stylist",
      name: json['name'] ?? "",
      username: json['username'] ?? "",
      profileImageUrl: json['profileImageUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class MediaItem {
  String url;
  String mediaType;
  int position;

  MediaItem({required this.url, required this.mediaType, required this.position});

  factory MediaItem.fromJson(Map<String, dynamic> json) {

    String rawUrl = json['url'] ?? "";

    // FIX: Automatically prepend Base URL if relative
    if (rawUrl.startsWith('/')) {
      rawUrl = '${AppConstants.BASE_URL}$rawUrl';
    }


    return MediaItem(
      url: rawUrl,
      mediaType: json['mediaType'] ?? "image",
      position: json['position'] ?? 0,
    );
  }
}

class PostMetrics {
  int likes;
  int comments;
  int saves;
  int shares;

  PostMetrics({
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.shares = 0,
  });

  factory PostMetrics.fromJson(Map<String, dynamic> json) {
    return PostMetrics(
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      saves: json['saves'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }
}

class CommentModel {
  String id;
  String body;
  String createdAt;
  Author? author;

  CommentModel({
    required this.id,
    required this.body,
    required this.createdAt,
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      body: json['body'] ?? "",
      createdAt: json['createdAt'] ?? "",
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
    );
  }

  String get username => author?.username ?? "User";

  String get timeAgo {
    if (createdAt.isEmpty) return "";
    DateTime created = DateTime.parse(createdAt);
    Duration diff = DateTime.now().difference(created);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}

class PostDraft {
  final String id;
  final String content;
  final DateTime createdAt;
  final String audience;

  PostDraft({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.audience,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'audience': audience,
  };

  factory PostDraft.fromJson(Map<String, dynamic> json) => PostDraft(
    id: json['id'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    audience: json['audience'],
  );
}

