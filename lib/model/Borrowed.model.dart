class Borrowed {
  final int id;
  final int userId;
  final String borrowDate;
  final String status;

  Borrowed({
    required this.id,
    required this.userId,
    required this.borrowDate,
    required this.status,
  });

  factory Borrowed.fromJson(Map<String, dynamic> json) {
    return Borrowed(
      id: json['id'],
      userId: json['user_id'],
      borrowDate: json['borrow_date'],
      status: json['status'],
    );
  }
}
