import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/referral/refer_earn_screen.dart';
import '../screens/booking/booking_history_screen.dart';
import '../screens/booking/slots_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/login_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final user = auth.currentUser;

    return Drawer(
      child: Container(
        color: StylexyTheme.surfaceBg,
        child: SafeArea(
          child: Column(
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: StylexyTheme.goldGradient,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: StylexyTheme.darkBg,
                      backgroundImage: user?.photoPath != null
                          ? FileImage(File(user!.photoPath!))
                          : null,
                      child: user?.photoPath == null
                          ? Text(
                              (user?.name.isNotEmpty == true)
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: StylexyTheme.primaryGold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest',
                            style: const TextStyle(
                              color: StylexyTheme.darkBg,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.phone ?? '',
                            style: TextStyle(
                              color: StylexyTheme.darkBg.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Menu Items
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ));
                },
              ),
              _DrawerItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet & Recharge',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const WalletScreen(),
                  ));
                },
              ),
              _DrawerItem(
                icon: Icons.card_giftcard_outlined,
                label: 'Refer & Earn',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ReferEarnScreen(),
                  ));
                },
              ),
              _DrawerItem(
                icon: Icons.calendar_today_outlined,
                label: 'Book a Slot',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SlotsScreen(),
                  ));
                },
              ),
              _DrawerItem(
                icon: Icons.history_outlined,
                label: 'My Bookings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const BookingHistoryScreen(),
                  ));
                },
              ),
              const Divider(color: StylexyTheme.dividerColor),
              // Admin Dashboard - ONLY visible to admin
              if (auth.isAdmin)
                _DrawerItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin Dashboard',
                  color: StylexyTheme.adminAccent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AdminDashboard(),
                    ));
                  },
                ),
              const Spacer(),
              const Divider(color: StylexyTheme.dividerColor),
              _DrawerItem(
                icon: Icons.logout_outlined,
                label: 'Logout',
                color: StylexyTheme.errorRed,
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // App Version
              const Text(
                'Stylexy v1.0.0',
                style: TextStyle(
                  color: StylexyTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? StylexyTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: itemColor, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: itemColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: StylexyTheme.cardBgLight,
    );
  }
}
