class DetailReturn {
  final int id;
  final int returnId;
  final int itemId;
  final int quantity;

  DetailReturn({
    required this.id,
    required this.returnId,
    required this.itemId,
    required this.quantity,
  });

  factory DetailReturn.fromJson(Map<String, dynamic> json) {
    return DetailReturn(
      id: json['id'],
      returnId: json['return_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
    );
  }
}
