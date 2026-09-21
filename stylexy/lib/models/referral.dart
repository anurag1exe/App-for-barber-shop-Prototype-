/// Referral model — the referral code is stored directly in the AppUser model.
/// This file contains helper utilities for referral code display.

class ReferralInfo {
  final String code;
  final bool hasBeenUsed;
  final String? appliedCode;

  const ReferralInfo({
    required this.code,
    required this.hasBeenUsed,
    this.appliedCode,
  });

  String get shareMessage =>
      'Join Stylexy and get ₹100! Use my referral code: $code\nDownload now!';
}
