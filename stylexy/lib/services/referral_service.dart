import '../models/user.dart';
import 'database_service.dart';
import 'wallet_service.dart';

class ReferralService {
  static final ReferralService instance = ReferralService._();
  ReferralService._();

  final _db = DatabaseService.instance;
  final _wallet = WalletService.instance;

  /// Get user's referral code
  Future<String?> getReferralCode(String userId) async {
    final rows = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) return null;
    return rows.first['referralCode'] as String;
  }

  /// Apply a referral code
  Future<({bool success, String message})> applyReferralCode(
    String currentUserId,
    String code,
  ) async {
    final codeUpper = code.trim().toUpperCase();

    if (codeUpper.isEmpty) {
      return (success: false, message: 'Please enter a referral code');
    }

    // Check if current user already used a referral code
    final currentUserRows = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [currentUserId],
    );
    if (currentUserRows.isEmpty) {
      return (success: false, message: 'User not found');
    }
    final currentUser = AppUser.fromMap(currentUserRows.first);

    if (currentUser.hasUsedReferral) {
      return (success: false, message: 'You have already used a referral code');
    }

    // Find the referrer by code
    final referrerRows = await _db.query(
      'users',
      where: 'referralCode = ?',
      whereArgs: [codeUpper],
    );
    if (referrerRows.isEmpty) {
      return (success: false, message: 'Invalid referral code');
    }

    final referrer = AppUser.fromMap(referrerRows.first);

    // Prevent self-referral
    if (referrer.id == currentUserId) {
      return (success: false, message: 'You cannot use your own referral code');
    }

    // Credit ₹100 to both
    await _wallet.creditReferralBonus(
      currentUserId,
      'Referral bonus — applied code $codeUpper',
    );
    await _wallet.creditReferralBonus(
      referrer.id,
      'Referral bonus — ${currentUser.name} used your code',
    );

    // Mark current user as having used a referral
    await _db.update(
      'users',
      {'hasUsedReferral': 1, 'appliedReferralCode': codeUpper},
      where: 'id = ?',
      whereArgs: [currentUserId],
    );

    return (
      success: true,
      message: '₹100 credited to your wallet! The referrer also received ₹100.',
    );
  }
}
