class StylistModel {
  String? fullName;
  String? username;
  String? email;
  String? phoneNumber;
  String? country;
  String? state;
  String? password;
  String? experienceLevel;
  String? licenseNumber;
  String? saloonName;
  String? certificationType;
  int? yearsOfExperience;
  String? licenseCountry;
  String? documentType;
  String? documentUrl;
  String? profileImageUrl;

  StylistModel({
    this.fullName,
    this.username,
    this.email,
    this.phoneNumber,
    this.country,
    this.state,
    this.password,
    this.experienceLevel,
    this.licenseNumber,
    this.saloonName,
    this.certificationType,
    this.yearsOfExperience,
    this.licenseCountry,
    this.documentType,
    this.documentUrl,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) "fullName": fullName,
      if (username != null) "username": username,
      if (email != null) "email": email,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (country != null) "country": country,
      if (state != null) "state": state,
      if (password != null) "password": password,
      if (experienceLevel != null) "experienceLevel": experienceLevel,
      if (licenseNumber != null) "licenseNumber": licenseNumber,
      if (saloonName != null) "saloonName": saloonName,
      if (certificationType != null) "certificationType": certificationType,
      if (yearsOfExperience != null) "yearsOfExperience": yearsOfExperience,
      if (licenseCountry != null) "licenseCountry": licenseCountry,
      if (documentType != null) "documentType": documentType,
      if (documentUrl != null) "documentUrl": documentUrl,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
    };
  }

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    return StylistModel(
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      country: json['country'],
      state: json['state'],
      experienceLevel: json['experienceLevel'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}