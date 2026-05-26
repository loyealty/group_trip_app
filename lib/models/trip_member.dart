class TripMember {
  final int id;
  final int tripRoomId;
  final int userId;
  final String memberName;
  final String role;
  final String joinedAt;

  TripMember({
    required this.id,
    required this.tripRoomId,
    required this.userId,
    required this.memberName,
    required this.role,
    required this.joinedAt,
  });

  factory TripMember.fromJson(Map<String, dynamic> json) {
    return TripMember(
      id: json['id'] ?? 0,
      tripRoomId: json['tripRoomId'] ?? 0,
      userId: json['userId'] ?? 0,
      memberName: json['memberName'] ?? '',
      role: json['role'] ?? 'MEMBER',
      joinedAt: json['joinedAt'] ?? '',
    );
  }
}
