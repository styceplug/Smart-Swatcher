import 'dart:convert';

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
  PostFormula? formula;
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
    this.formula,
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
      media:
          json['media'] != null
              ? (json['media'] as List)
                  .map((e) => MediaItem.fromJson(e))
                  .toList()
              : [],
      formula:
          json['formula'] is Map<String, dynamic>
              ? PostFormula.fromJson(json['formula'] as Map<String, dynamic>)
              : null,
      tags:
          json['tags'] != null
              ? (json['tags'] as List)
                  .map((tag) {
                    if (tag is String) {
                      return tag;
                    }
                    if (tag is Map && tag['name'] != null) {
                      return tag['name'].toString();
                    }
                    return '';
                  })
                  .where((tag) => tag.trim().isNotEmpty)
                  .toList()
              : [],
      isLiked: viewer['liked'] ?? false,
      isSaved: viewer['saved'] ?? false,
      metrics:
          json['metrics'] != null
              ? PostMetrics.fromJson(json['metrics'])
              : null,
      base: null,
      lights: null,
      toner: null,
    );
  }

  bool get hasFormula => formula != null;

  int get saveCount => metrics?.saves ?? 0;

  String get username => author?.username ?? "Unknown";
  String get userRole =>
      (author?.type ?? "stylist").capitalizeFirst ??
      "Stylist"; // e.g., "Stylist"
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

class PostFormula {
  final String id;
  final String? formulationType;
  final String? imageUrl;
  final String? predictionImageUrl;
  final String? predictionImageStatus;
  final String? predictionImageError;
  final int? naturalBaseLevel;
  final int? greyPercentage;
  final int? desiredLevel;
  final int? developerVolume;
  final String? shadeType;
  final String? desiredTone;
  final String? mixingRatio;
  final String? noteToStylist;
  final Map<String, dynamic>? resultData;
  final List<PostFormulaStep> steps;
  final List<MediaItem> media;

  const PostFormula({
    required this.id,
    this.formulationType,
    this.imageUrl,
    this.predictionImageUrl,
    this.predictionImageStatus,
    this.predictionImageError,
    this.naturalBaseLevel,
    this.greyPercentage,
    this.desiredLevel,
    this.developerVolume,
    this.shadeType,
    this.desiredTone,
    this.mixingRatio,
    this.noteToStylist,
    this.resultData,
    this.steps = const [],
    this.media = const [],
  });

  factory PostFormula.fromJson(Map<String, dynamic> json) {
    return PostFormula(
      id: json['id']?.toString() ?? '',
      formulationType: json['formulationType']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      predictionImageUrl: json['predictionImageUrl']?.toString(),
      predictionImageStatus: json['predictionImageStatus']?.toString(),
      predictionImageError: json['predictionImageError']?.toString(),
      naturalBaseLevel: _asInt(json['naturalBaseLevel']),
      greyPercentage: _asInt(json['greyPercentage']),
      desiredLevel: _asInt(json['desiredLevel']),
      developerVolume: _asInt(json['developerVolume']),
      shadeType: json['shadeType']?.toString(),
      desiredTone: json['desiredTone']?.toString(),
      mixingRatio: json['mixingRatio']?.toString(),
      noteToStylist: json['noteToStylist']?.toString(),
      resultData: _mapFromJsonLike(json['resultData']),
      steps:
          json['steps'] is List
              ? (json['steps'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(PostFormulaStep.fromJson)
                  .toList()
              : const [],
      media:
          json['media'] is List
              ? (json['media'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(MediaItem.fromJson)
                  .toList()
              : const [],
    );
  }

  bool get isGenerating =>
      predictionImageStatus == 'queued' ||
      predictionImageStatus == 'in_progress';

  String? get displayImageUrl {
    final preferred = predictionImageUrl;
    if (preferred != null && preferred.trim().isNotEmpty) {
      return preferred.startsWith('/')
          ? '${AppConstants.BASE_URL}$preferred'
          : preferred;
    }

    final fallback = imageUrl;
    if (fallback == null || fallback.trim().isEmpty) {
      return null;
    }

    return fallback.startsWith('/')
        ? '${AppConstants.BASE_URL}$fallback'
        : fallback;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static Map<String, dynamic>? _mapFromJsonLike(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, item) => MapEntry(key.toString(), item));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

class PostFormulaStep {
  final int stepOrder;
  final String? stepType;
  final String? title;
  final String? description;

  const PostFormulaStep({
    required this.stepOrder,
    this.stepType,
    this.title,
    this.description,
  });

  factory PostFormulaStep.fromJson(Map<String, dynamic> json) {
    return PostFormulaStep(
      stepOrder: PostFormula._asInt(json['stepOrder']) ?? 0,
      stepType: json['stepType']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
    );
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
  String? get displayImageUrl {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return null;
    }

    String rawUrl = profileImageUrl!;
    if (rawUrl.startsWith('/')) {
      return '${AppConstants.BASE_URL}$rawUrl';
    }
    return rawUrl;
  }
}

class MediaItem {
  String url;
  String mediaType;
  int position;

  MediaItem({
    required this.url,
    required this.mediaType,
    required this.position,
  });

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
