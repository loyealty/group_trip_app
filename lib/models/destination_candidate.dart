class DestinationCandidate {
  final int id;
  final int tripRoomId;
  final String name;
  final String region;
  final String description;
  final int votes;
  final String createdAt;

  DestinationCandidate({
    required this.id,
    required this.tripRoomId,
    required this.name,
    required this.region,
    required this.description,
    required this.votes,
    required this.createdAt,
  });

  factory DestinationCandidate.fromJson(Map<String, dynamic> json) {
    return DestinationCandidate(
      id: json['id'] ?? 0,
      tripRoomId: json['tripRoomId'] ?? 0,
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      description: json['description'] ?? '',
      votes: json['votes'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
