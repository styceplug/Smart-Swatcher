class PostModel {
  final String username;
  final String role;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final int bookmarks;
  final String? imageUrl;
  final String? imageAsset;
  final String? base;
  final String? lights;
  final String? toner;


  PostModel({
    required this.username,
    required this.role,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.bookmarks,
    this.imageUrl,
    this.imageAsset,
    this.base,
    this.lights,
    this.toner,
  });
}

class CommentModel {
  final String username;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final int bookmarks;


  CommentModel({
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.bookmarks,
  });
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
