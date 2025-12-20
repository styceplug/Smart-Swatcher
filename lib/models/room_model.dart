class RoomReminder {
  final int id;
  final String hostName;
  final String hostRole;
  final String sessionType;
  final String title;
  final DateTime dateTime;
  final bool isReminderSet;

  RoomReminder({
    required this.id,
    required this.hostName,
    required this.hostRole,
    required this.sessionType,
    required this.title,
    required this.dateTime,
    this.isReminderSet = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hostName': hostName,
    'hostRole': hostRole,
    'sessionType': sessionType,
    'title': title,
    'dateTime': dateTime.toIso8601String(),
    'isReminderSet': isReminderSet,
  };

  factory RoomReminder.fromJson(Map<String, dynamic> json) => RoomReminder(
    id: json['id'],
    hostName: json['hostName'],
    hostRole: json['hostRole'],
    sessionType: json['sessionType'],
    title: json['title'],
    dateTime: DateTime.parse(json['dateTime']),
    isReminderSet: json['isReminderSet'] ?? false,
  );

  RoomReminder copyWith({bool? isReminderSet}) => RoomReminder(
    id: id,
    hostName: hostName,
    hostRole: hostRole,
    sessionType: sessionType,
    title: title,
    dateTime: dateTime,
    isReminderSet: isReminderSet ?? this.isReminderSet,
  );
}