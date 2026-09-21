enum TransactionType {
  recharge,
  bonus,
  serviceDeduction,
  referralCredit,
}

class WalletTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.recharge,
      ),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get typeDisplay {
    switch (type) {
      case TransactionType.recharge:
        return 'Recharge';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.serviceDeduction:
        return 'Service Payment';
      case TransactionType.referralCredit:
        return 'Referral Credit';
    }
  }

  bool get isCredit =>
      type == TransactionType.recharge ||
      type == TransactionType.bonus ||
      type == TransactionType.referralCredit;
}
