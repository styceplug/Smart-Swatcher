import 'package:smart_swatcher/utils/app_constants.dart';

class AppointmentEmailDeliveryModel {
  final bool attempted;
  final String status;
  final String? destination;
  final String? messageId;
  final String? reason;
  final String? error;

  const AppointmentEmailDeliveryModel({
    this.attempted = false,
    this.status = 'not_requested',
    this.destination,
    this.messageId,
    this.reason,
    this.error,
  });

  factory AppointmentEmailDeliveryModel.fromJson(Map<String, dynamic> json) {
    return AppointmentEmailDeliveryModel(
      attempted: json['attempted'] == true,
      status: json['status']?.toString() ?? 'not_requested',
      destination: json['destination']?.toString(),
      messageId: json['messageId']?.toString(),
      reason: json['reason']?.toString(),
      error: json['error']?.toString(),
    );
  }
}

class ClientFolderModel {
  String? id;
  String? ownerId;
  String? ownerType;
  String? clientName;
  String? clientEmail;
  String? clientPhone;
  String? dateOfBirth;
  String? appointmentDate;
  String? profileImageUrl;
  bool? setReminder;
  String? consentStatus;
  bool? shouldSendConsent;
  String? createdAt;
  String? updatedAt;

  ClientFolderModel({
    this.id,
    this.ownerId,
    this.ownerType,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.dateOfBirth,
    this.appointmentDate,
    this.profileImageUrl,
    this.setReminder,
    this.consentStatus,
    this.shouldSendConsent,
    this.createdAt,
    this.updatedAt,
  });

  // Helper to handle relative image paths automatically
  String? get fullProfileImageUrl {
    if (profileImageUrl == null) return null;
    if (profileImageUrl!.startsWith('/')) {
      return '${AppConstants.BASE_URL}$profileImageUrl';
    }
    return profileImageUrl;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "ownerId": ownerId,
      "ownerType": ownerType,
      "clientName": clientName,
      "clientEmail": clientEmail,
      "clientPhone": clientPhone,
      "dateOfBirth": dateOfBirth,
      "appointmentDate": appointmentDate,
      "profileImageUrl": profileImageUrl,
      "setReminder": setReminder,
      "consentStatus": consentStatus,
      "shouldSendConsent": shouldSendConsent,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory ClientFolderModel.fromJson(Map<String, dynamic> json) {
    return ClientFolderModel(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerType: json['ownerType'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      dateOfBirth: json['dateOfBirth'],
      appointmentDate: json['appointmentDate'],
      profileImageUrl: json['profileImageUrl'],
      // Handle potential nulls for booleans safely if needed, or let them be null
      setReminder: json['setReminder'],
      consentStatus: json['consentStatus'],
      shouldSendConsent: json['shouldSendConsent'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
