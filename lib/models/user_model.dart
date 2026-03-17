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
        .where((e) => e != null && e!.trim().isNotEmpty)
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