enum TransactionType {
  income('income', 'Pemasukan'),
  expense('expense', 'Pengeluaran');

  const TransactionType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TransactionType fromString(String? value) {
    if (value?.toLowerCase() == 'income') return TransactionType.income;
    return TransactionType.expense;
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.costCenter,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String costCenter;

  String get displayLabel => '$name ($costCenter)';

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? '',
      type: TransactionType.fromString(json['type'] as String?),
      costCenter: (json['cost_center'] as String?) ?? 'Umum',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.dbValue,
        'cost_center': costCenter,
      };
}
