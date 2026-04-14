class Expense {
  final int id;
  final int tripRoomId;
  final String category;
  final String title;
  final String payer;
  final int amount;
  final String createdAt;

  Expense({
    required this.id,
    required this.tripRoomId,
    required this.category,
    required this.title,
    required this.payer,
    required this.amount,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      tripRoomId: json['tripRoomId'] ?? 0,
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      payer: json['payer'] ?? '',
      amount: json['amount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
