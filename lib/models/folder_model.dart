class ClientFolderModel {
  String clientName;
  String clientEmail;
  String clientPhone;
  String? dateOfBirth;
  String? appointmentDate;
  String? profileImageUrl;
  bool setReminder;
  String consentStatus;
  bool shouldSendConsent;

  ClientFolderModel({
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    this.dateOfBirth,
    this.appointmentDate,
    this.profileImageUrl,
    this.setReminder = false,
    this.consentStatus = "pending",
    this.shouldSendConsent = false,
  });


  Map<String, dynamic> toJson() {
    return {
      "clientName": clientName,
      "clientEmail": clientEmail,
      "clientPhone": clientPhone,
      "dateOfBirth": dateOfBirth,
      "appointmentDate": appointmentDate,
      "profileImageUrl": profileImageUrl,
      "setReminder": setReminder,
      "consentStatus": consentStatus,
      "shouldSendConsent": shouldSendConsent,
    };
  }

  factory ClientFolderModel.fromJson(Map<String, dynamic> json) {
    return ClientFolderModel(
      clientName: json['clientName'] ?? "",
      clientEmail: json['clientEmail'] ?? "",
      clientPhone: json['clientPhone'] ?? "",
      dateOfBirth: json['dateOfBirth'],
      appointmentDate: json['appointmentDate'],
      profileImageUrl: json['profileImageUrl'],
      setReminder: json['setReminder'] ?? false,
      consentStatus: json['consentStatus'] ?? "pending",
      shouldSendConsent: json['shouldSendConsent'] ?? false,
    );
  }
}