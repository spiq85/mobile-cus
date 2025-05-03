class DetailBorrow {
  final int id;
  final int borrowId;
  final int itemId;
  final int quantity;

  DetailBorrow({
    required this.id,
    required this.borrowId,
    required this.itemId,
    required this.quantity,
  });

  factory DetailBorrow.fromJson(Map<String, dynamic> json) {
    return DetailBorrow(
      id: json['id'],
      borrowId: json['borrow_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
    );
  }
}
