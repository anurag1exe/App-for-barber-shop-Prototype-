import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';

class WalletIcon extends StatefulWidget {
  final VoidCallback onTap;
  const WalletIcon({super.key, required this.onTap});

  @override
  State<WalletIcon> createState() => _WalletIconState();
}

class _WalletIconState extends State<WalletIcon> {
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      final balance = await WalletService.instance.getBalance(user.id);
      if (mounted) setState(() => _balance = balance);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: StylexyTheme.goldGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: StylexyTheme.primaryGold.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, color: StylexyTheme.darkBg, size: 20),
            const SizedBox(width: 6),
            Text(
              '₹${_balance.toInt()}',
              style: const TextStyle(
                color: StylexyTheme.darkBg,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
