class Item {
  final int id;
  final String name;
  final String code;
  final int stock;
  final int categoryId;

  Item({
    required this.id,
    required this.name,
    required this.code,
    required this.stock,
    required this.categoryId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      stock: json['stock'],
      categoryId: json['category_item_id'],
    );
  }
}
