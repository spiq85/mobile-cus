class ReturnsModel {
  final int id;
  final int borrowedId;
  final String returnDate;
  final String conditionNote;

  ReturnsModel({
    required this.id,
    required this.borrowedId,
    required this.returnDate,
    required this.conditionNote,
  });

  factory ReturnsModel.fromJson(Map<String, dynamic> json) {
    return ReturnsModel(
      id: json['id'],
      borrowedId: json['borrowed_id'],
      returnDate: json['return_date'],
      conditionNote: json['condition_note'],
    );
  }
}
