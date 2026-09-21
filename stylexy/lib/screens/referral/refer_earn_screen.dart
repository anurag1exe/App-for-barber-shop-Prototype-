import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/referral_service.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  final _codeController = TextEditingController();
  String _myCode = '';
  bool _hasUsedReferral = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = AuthService.instance.currentUser!;
    _myCode = user.referralCode;
    _hasUsedReferral = user.hasUsedReferral;
    if (mounted) setState(() {});
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a referral code'), backgroundColor: StylexyTheme.errorRed),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ReferralService.instance.applyReferralCode(
      AuthService.instance.currentUser!.id,
      code,
    );
    await AuthService.instance.refreshCurrentUser();
    setState(() => _isLoading = false);

    if (!mounted) return;
    _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? StylexyTheme.successGreen : StylexyTheme.errorRed,
      ),
    );
    if (result.success) _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Earn info banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: StylexyTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: StylexyTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.card_giftcard, color: StylexyTheme.darkBg, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Earn ₹100 for each referral!',
                    style: TextStyle(color: StylexyTheme.darkBg, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Share your code with friends. Both you and your friend get ₹100 wallet credit!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Your referral code
            const Text('Your Referral Code', style: TextStyle(color: StylexyTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StylexyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StylexyTheme.primaryGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _myCode,
                      style: const TextStyle(
                        color: StylexyTheme.primaryGold,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: StylexyTheme.textSecondary),
                    tooltip: 'Copy',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _myCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!'), backgroundColor: StylexyTheme.successGreen),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: StylexyTheme.primaryGold),
                    tooltip: 'Share',
                    onPressed: () {
                      Share.share(
                        'Join Stylexy and get ₹100! Use my referral code: $_myCode\nDownload now!',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Apply a referral code
            const Text('Have a Referral Code?', style: TextStyle(color: StylexyTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_hasUsedReferral)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StylexyTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: StylexyTheme.successGreen),
                    SizedBox(width: 12),
                    Text(
                      'You\'ve already used a referral code!',
                      style: TextStyle(color: StylexyTheme.successGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else ...[
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: StylexyTheme.textPrimary, fontSize: 18, letterSpacing: 2),
                decoration: const InputDecoration(
                  hintText: 'Enter code',
                  prefixIcon: Icon(Icons.confirmation_number_outlined, color: StylexyTheme.primaryGold),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _applyCode,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: StylexyTheme.darkBg, strokeWidth: 2.5))
                      : const Text('APPLY CODE'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
