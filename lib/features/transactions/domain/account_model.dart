enum AccountType {
  kas('kas', 'Kas Tunai'),
  bank('bank', 'Rekening Bank'),
  ewallet('ewallet', 'E-Wallet');

  const AccountType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static AccountType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'ewallet':
        return AccountType.ewallet;
      case 'kas':
      default:
        return AccountType.kas;
    }
  }
}

class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? '',
      type: AccountType.fromString(json['type'] as String?),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.dbValue,
        'balance': balance,
      };
}
