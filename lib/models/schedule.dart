class Schedule {
  final int id;
  final int tripRoomId;
  final String title;
  final String location;
  final String description;
  final String scheduleDate;
  final String scheduleTime;
  final String createdAt;

  Schedule({
    required this.id,
    required this.tripRoomId,
    required this.title,
    required this.location,
    required this.description,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.createdAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      tripRoomId: json['tripRoomId'] ?? 0,
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      scheduleDate: json['scheduleDate'] ?? '',
      scheduleTime: json['scheduleTime'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
