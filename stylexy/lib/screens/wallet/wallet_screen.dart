import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/wallet.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../utils/validators.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;
  final _rechargeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _rechargeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = AuthService.instance.currentUser!.id;
    final balance = await WalletService.instance.getBalance(userId);
    final txns = await WalletService.instance.getTransactionHistory(userId);
    if (mounted) {
      setState(() {
        _balance = balance;
        _transactions = txns;
        _loading = false;
      });
    }
  }

  Future<void> _showRechargeDialog() async {
    _rechargeController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StylexyTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recharge Wallet',
                style: TextStyle(
                  color: StylexyTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StylexyTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: StylexyTheme.successGreen, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Add ₹200 or more to get ₹50 bonus!',
                        style: TextStyle(color: StylexyTheme.successGreen, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _rechargeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: StylexyTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: StylexyTheme.primaryGold, fontSize: 24, fontWeight: FontWeight.w700),
                ),
                validator: Validators.amount,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              // Quick amount buttons
              Wrap(
                spacing: 8,
                children: [100, 200, 500, 1000].map((amount) {
                  return ActionChip(
                    label: Text('₹$amount'),
                    backgroundColor: StylexyTheme.cardBgLight,
                    labelStyle: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w600),
                    side: BorderSide(color: StylexyTheme.primaryGold.withOpacity(0.3)),
                    onPressed: () {
                      _rechargeController.text = amount.toString();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final amount = double.parse(_rechargeController.text.trim());
                    final result = await WalletService.instance.recharge(
                      AuthService.instance.currentUser!.id,
                      amount,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: result.success ? StylexyTheme.successGreen : StylexyTheme.errorRed,
                        ),
                      );
                      _loadData();
                    }
                  },
                  child: const Text('RECHARGE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : RefreshIndicator(
              color: StylexyTheme.primaryGold,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Balance Card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wallet Balance',
                          style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_balance.toInt()}',
                          style: const TextStyle(
                            color: StylexyTheme.darkBg,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showRechargeDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('ADD MONEY'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StylexyTheme.darkBg,
                              foregroundColor: StylexyTheme.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Transaction History
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      color: StylexyTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: Text(
                          'No transactions yet.\nRecharge to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: StylexyTheme.textMuted, fontSize: 14),
                        ),
                      ),
                    ),
                  ..._transactions.map((txn) => _TransactionTile(txn: txn)),
                ],
              ),
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction txn;
  const _TransactionTile({required this.txn});

  IconData get _icon {
    switch (txn.type) {
      case TransactionType.recharge:
        return Icons.add_circle_outline;
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.serviceDeduction:
        return Icons.remove_circle_outline;
      case TransactionType.referralCredit:
        return Icons.people_outline;
    }
  }

  Color get _color {
    return txn.isCredit ? StylexyTheme.successGreen : StylexyTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM, h:mm a').format(txn.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StylexyTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.typeDisplay,
                  style: const TextStyle(
                    color: StylexyTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateStr,
                  style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${txn.isCredit ? '+' : '-'}₹${txn.amount.toInt()}',
            style: TextStyle(
              color: _color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
