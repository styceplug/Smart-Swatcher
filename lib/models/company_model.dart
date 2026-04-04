class CompanyModel {
  final String? id;
  final String? token;
  final String? companyName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? country;
  final String? state;

  final String? profileImageUrl;
  final String? backgroundImageUrl;

  final String? role;
  final int accountTier;
  final String? missionStatement;
  final String? about;

  final String? licenseNumber;
  final String? saloonName;
  final String? certificationType;
  final int? yearsOfExperience;
  final String? licenseCountry;
  final String? documentType;
  final String? documentUrl;
  final String? authProvider;

  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isImageVerified;
  final bool isVerified;
  final bool isIdentityVerified;
  final bool isActive;
  final bool isPremium;

  final DateTime? lastSeen;
  final String? lastIpAddress;
  final String? lastDeviceName;
  final String? lastDeviceId;
  final String? lastDeviceType;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyModel({
    this.id,
    this.token,
    this.companyName,
    this.username,
    this.email,
    this.phoneNumber,
    this.country,
    this.state,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.role,
    this.accountTier = 0,
    this.missionStatement,
    this.about,
    this.licenseNumber,
    this.saloonName,
    this.certificationType,
    this.yearsOfExperience,
    this.licenseCountry,
    this.documentType,
    this.documentUrl,
    this.authProvider,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isImageVerified = false,
    this.isVerified = false,
    this.isIdentityVerified = false,
    this.isActive = false,
    this.isPremium = false,
    this.lastSeen,
    this.lastIpAddress,
    this.lastDeviceName,
    this.lastDeviceId,
    this.lastDeviceType,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString(),
      token: json['token']?.toString(),
      companyName: json['companyName']?.toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      backgroundImageUrl: json['backgroundImageUrl']?.toString(),
      role: json['role']?.toString(),
      accountTier: int.tryParse(json['accountTier']?.toString() ?? '0') ?? 0,
      missionStatement: json['missionStatement']?.toString(),
      about: json['about']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      saloonName: json['saloonName']?.toString(),
      certificationType: json['certificationType']?.toString(),
      yearsOfExperience:
          json['yearsOfExperience'] != null
              ? int.tryParse(json['yearsOfExperience'].toString())
              : null,
      licenseCountry: json['licenseCountry']?.toString(),
      documentType: json['documentType']?.toString(),
      documentUrl: json['documentUrl']?.toString(),
      authProvider: json['authProvider']?.toString(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isImageVerified: json['isImageVerified'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isIdentityVerified: json['isIdentityVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      isPremium: json['isPremium'] ?? false,
      lastSeen:
          json['lastSeen'] != null
              ? DateTime.tryParse(json['lastSeen'].toString())
              : null,
      lastIpAddress: json['lastIpAddress']?.toString(),
      lastDeviceName: json['lastDeviceName']?.toString(),
      lastDeviceId: json['lastDeviceId']?.toString(),
      lastDeviceType: json['lastDeviceType']?.toString(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "token": token,
      "companyName": companyName,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
      "country": country,
      "state": state,
      "profileImageUrl": profileImageUrl,
      "backgroundImageUrl": backgroundImageUrl,
      "role": role,
      "accountTier": accountTier,
      "missionStatement": missionStatement,
      "about": about,
      "licenseNumber": licenseNumber,
      "saloonName": saloonName,
      "certificationType": certificationType,
      "yearsOfExperience": yearsOfExperience,
      "licenseCountry": licenseCountry,
      "documentType": documentType,
      "documentUrl": documentUrl,
      "authProvider": authProvider,
      "isEmailVerified": isEmailVerified,
      "isPhoneVerified": isPhoneVerified,
      "isImageVerified": isImageVerified,
      "isVerified": isVerified,
      "isIdentityVerified": isIdentityVerified,
      "isActive": isActive,
      "isPremium": isPremium,
      "lastSeen": lastSeen?.toIso8601String(),
      "lastIpAddress": lastIpAddress,
      "lastDeviceName": lastDeviceName,
      "lastDeviceId": lastDeviceId,
      "lastDeviceType": lastDeviceType,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  CompanyModel copyWith({
    String? id,
    String? token,
    String? companyName,
    String? username,
    String? email,
    String? phoneNumber,
    String? country,
    String? state,
    String? profileImageUrl,
    String? backgroundImageUrl,
    String? role,
    int? accountTier,
    String? missionStatement,
    String? about,
    String? licenseNumber,
    String? saloonName,
    String? certificationType,
    int? yearsOfExperience,
    String? licenseCountry,
    String? documentType,
    String? documentUrl,
    String? authProvider,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isImageVerified,
    bool? isVerified,
    bool? isIdentityVerified,
    bool? isActive,
    bool? isPremium,
    DateTime? lastSeen,
    String? lastIpAddress,
    String? lastDeviceName,
    String? lastDeviceId,
    String? lastDeviceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      token: token ?? this.token,
      companyName: companyName ?? this.companyName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      state: state ?? this.state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      role: role ?? this.role,
      accountTier: accountTier ?? this.accountTier,
      missionStatement: missionStatement ?? this.missionStatement,
      about: about ?? this.about,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      saloonName: saloonName ?? this.saloonName,
      certificationType: certificationType ?? this.certificationType,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      licenseCountry: licenseCountry ?? this.licenseCountry,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isImageVerified: isImageVerified ?? this.isImageVerified,
      isVerified: isVerified ?? this.isVerified,
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      lastSeen: lastSeen ?? this.lastSeen,
      lastIpAddress: lastIpAddress ?? this.lastIpAddress,
      lastDeviceName: lastDeviceName ?? this.lastDeviceName,
      lastDeviceId: lastDeviceId ?? this.lastDeviceId,
      lastDeviceType: lastDeviceType ?? this.lastDeviceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String resolveImage(String? url, String baseUrl) {
    if (url == null) return '';

    final value = url.trim();

    if (value.isEmpty || value == 'null' || value == 'string') {
      return '';
    }

    if (value.startsWith('http')) return value;

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  String getProfileImage(String baseUrl) {
    return resolveImage(profileImageUrl, baseUrl);
  }

  String getBackgroundImage(String baseUrl) {
    return resolveImage(backgroundImageUrl, baseUrl);
  }
}
