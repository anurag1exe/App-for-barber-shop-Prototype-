import 'package:uuid/uuid.dart';
import '../models/wallet.dart';
import 'database_service.dart';

class WalletService {
  static final WalletService instance = WalletService._();
  WalletService._();

  final _db = DatabaseService.instance;

  /// Get wallet balance for a user
  Future<double> getBalance(String userId) async {
    final rows = await _db.rawQuery(
      '''SELECT 
        COALESCE(SUM(CASE WHEN type IN ('recharge', 'bonus', 'referralCredit') THEN amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN type = 'serviceDeduction' THEN amount ELSE 0 END), 0) AS balance
      FROM wallet_transactions WHERE userId = ?''',
      [userId],
    );
    return (rows.first['balance'] as num?)?.toDouble() ?? 0.0;
  }

  /// Recharge wallet with bonus logic
  Future<({bool success, String message, double newBalance})> recharge(
    String userId,
    double amount,
  ) async {
    if (amount <= 0) {
      return (success: false, message: 'Amount must be greater than zero', newBalance: 0.0);
    }
    if (amount > 50000) {
      return (success: false, message: 'Maximum recharge amount is ₹50,000', newBalance: 0.0);
    }

    // Main recharge transaction
    await _db.insert('wallet_transactions', WalletTransaction(
      id: const Uuid().v4(),
      userId: userId,
      type: TransactionType.recharge,
      amount: amount,
      description: 'Wallet recharge of ₹${amount.toInt()}',
    ).toMap());

    // Bonus: ₹50 if recharge >= ₹200
    if (amount >= 200) {
      await _db.insert('wallet_transactions', WalletTransaction(
        id: const Uuid().v4(),
        userId: userId,
        type: TransactionType.bonus,
        amount: 50,
        description: 'Bonus ₹50 on recharge of ₹${amount.toInt()}',
      ).toMap());
    }

    final newBalance = await getBalance(userId);
    final bonusMsg = amount >= 200 ? ' + ₹50 bonus!' : '';
    return (
      success: true,
      message: '₹${amount.toInt()} added to wallet$bonusMsg',
      newBalance: newBalance,
    );
  }

  /// Deduct amount for service
  Future<({bool success, String message, double newBalance})> deductForService(
    String userId,
    double amount,
    String serviceName,
  ) async {
    final balance = await getBalance(userId);
    if (balance < amount) {
      return (
        success: false,
        message: 'Insufficient balance. You need ₹${amount.toInt()} but have ₹${balance.toInt()}. Please recharge.',
        newBalance: balance,
      );
    }

    await _db.insert('wallet_transactions', WalletTransaction(
      id: const Uuid().v4(),
      userId: userId,
      type: TransactionType.serviceDeduction,
      amount: amount,
      description: 'Payment for $serviceName — ₹${amount.toInt()}',
    ).toMap());

    final newBalance = await getBalance(userId);
    return (success: true, message: 'Paid ₹${amount.toInt()} for $serviceName', newBalance: newBalance);
  }

  /// Credit referral bonus
  Future<void> creditReferralBonus(String userId, String description) async {
    await _db.insert('wallet_transactions', WalletTransaction(
      id: const Uuid().v4(),
      userId: userId,
      type: TransactionType.referralCredit,
      amount: 100,
      description: description,
    ).toMap());
  }

  /// Get transaction history
  Future<List<WalletTransaction>> getTransactionHistory(String userId) async {
    final rows = await _db.query(
      'wallet_transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => WalletTransaction.fromMap(r)).toList();
  }
}
