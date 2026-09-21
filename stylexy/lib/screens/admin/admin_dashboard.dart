import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import 'customer_management.dart';
import 'barber_leaderboard.dart';
import 'ratings_overview.dart';
import 'slot_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Security: Double-check admin role
    if (!AuthService.instance.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'You do not have permission to access this page.',
            style: TextStyle(color: StylexyTheme.errorRed, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: StylexyTheme.adminGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Management',
              style: TextStyle(color: StylexyTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage customers, track barber performance, and view ratings',
              style: TextStyle(color: StylexyTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _AdminCard(
              icon: Icons.people_outline,
              title: 'Customer Management',
              subtitle: 'View all customers, visits, and contact info',
              color: StylexyTheme.accentTeal,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerManagementScreen())),
            ),
            _AdminCard(
              icon: Icons.leaderboard_outlined,
              title: 'Barber Leaderboard',
              subtitle: 'Daily & monthly service counts per barber',
              color: StylexyTheme.primaryGold,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarberLeaderboardScreen())),
            ),
            _AdminCard(
              icon: Icons.star_outline,
              title: 'Ratings Overview',
              subtitle: 'Average ratings, star breakdown, recent comments',
              color: Colors.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingsOverviewScreen())),
            ),
            _AdminCard(
              icon: Icons.calendar_month_outlined,
              title: 'Slot & Booking Management',
              subtitle: 'View all bookings and slot availability',
              color: StylexyTheme.adminAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StylexyTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: StylexyTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
