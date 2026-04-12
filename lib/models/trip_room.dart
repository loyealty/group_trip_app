class TripRoom {
  final int id;
  final String title;
  final String description;
  final int ownerId;
  final String startDate;
  final String endDate;
  final String destination;
  final String status;
  final String createdAt;

  TripRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.status,
    required this.createdAt,
  });

  factory TripRoom.fromJson(Map<String, dynamic> json) {
    return TripRoom(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['ownerId'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
