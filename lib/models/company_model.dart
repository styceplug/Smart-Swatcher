class CompanyModel {
  final String? id;
  final String? companyName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? country;
  final String? state;
  final String? profileImageUrl;
  final String? role;
  final String? missionStatement;
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

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyModel({
    this.id,
    this.companyName,
    this.username,
    this.email,
    this.phoneNumber,
    this.country,
    this.state,
    this.profileImageUrl,
    this.role,
    this.missionStatement,
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
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      companyName: json['companyName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      country: json['country'],
      state: json['state'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'],
      missionStatement: json['missionStatement'],
      licenseNumber: json['licenseNumber'],
      saloonName: json['saloonName'],
      certificationType: json['certificationType'],
      yearsOfExperience: json['yearsOfExperience'] != null
          ? int.tryParse(json['yearsOfExperience'].toString())
          : null,
      licenseCountry: json['licenseCountry'],
      documentType: json['documentType'],
      documentUrl: json['documentUrl'],
      authProvider: json['authProvider'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isImageVerified: json['isImageVerified'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isIdentityVerified: json['isIdentityVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      isPremium: json['isPremium'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "companyName": companyName,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
      "country": country,
      "state": state,
      "profileImageUrl": profileImageUrl,
      "role": role,
      "missionStatement": missionStatement,
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
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  CompanyModel copyWith({
    String? companyName,
    String? username,
    String? profileImageUrl,
    String? missionStatement,
    bool? isPremium,
    bool? isVerified,
  }) {
    return CompanyModel(
      id: id,
      companyName: companyName ?? this.companyName,
      username: username ?? this.username,
      email: email,
      phoneNumber: phoneNumber,
      country: country,
      state: state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role,
      missionStatement: missionStatement ?? this.missionStatement,
      licenseNumber: licenseNumber,
      saloonName: saloonName,
      certificationType: certificationType,
      yearsOfExperience: yearsOfExperience,
      licenseCountry: licenseCountry,
      documentType: documentType,
      documentUrl: documentUrl,
      authProvider: authProvider,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      isImageVerified: isImageVerified,
      isVerified: isVerified ?? this.isVerified,
      isIdentityVerified: isIdentityVerified,
      isActive: isActive,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}