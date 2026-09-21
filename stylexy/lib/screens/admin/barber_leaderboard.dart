import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class BarberLeaderboardScreen extends StatefulWidget {
  const BarberLeaderboardScreen({super.key});

  @override
  State<BarberLeaderboardScreen> createState() => _BarberLeaderboardScreenState();
}

class _BarberLeaderboardScreenState extends State<BarberLeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _todayData = [];
  List<Map<String, dynamic>> _monthData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (AuthService.instance.isAdmin) _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final today = await BookingService.instance.getBarberLeaderboard(today: true);
    final month = await BookingService.instance.getBarberLeaderboard(today: false);
    if (mounted) {
      setState(() {
        _todayData = today;
        _monthData = month;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Unauthorized', style: TextStyle(color: StylexyTheme.errorRed))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barber Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: StylexyTheme.primaryGold,
          labelColor: StylexyTheme.primaryGold,
          unselectedLabelColor: StylexyTheme.textMuted,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : TabBarView(
              controller: _tabController,
              children: [
                _LeaderboardList(data: _todayData, period: 'today'),
                _LeaderboardList(data: _monthData, period: 'this month'),
              ],
            ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String period;

  const _LeaderboardList({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No services completed $period',
          style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final item = data[i];
        final rank = i + 1;
        final name = item['barberName'] as String;
        final count = item['serviceCount'] as int;
        final earnings = (item['totalEarnings'] as num?)?.toDouble() ?? 0;

        Color rankColor;
        IconData rankIcon;
        switch (rank) {
          case 1:
            rankColor = const Color(0xFFFFD700);
            rankIcon = Icons.emoji_events;
            break;
          case 2:
            rankColor = const Color(0xFFC0C0C0);
            rankIcon = Icons.emoji_events;
            break;
          case 3:
            rankColor = const Color(0xFFCD7F32);
            rankIcon = Icons.emoji_events;
            break;
          default:
            rankColor = StylexyTheme.textMuted;
            rankIcon = Icons.circle;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: StylexyTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: rank == 1 ? Border.all(color: rankColor.withOpacity(0.4), width: 1.5) : null,
          ),
          child: Row(
            children: [
              Icon(rankIcon, color: rankColor, size: rank <= 3 ? 30 : 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('$count services • ₹${earnings.toInt()} earned', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              Text('#$rank', style: TextStyle(color: rankColor, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        );
      },
    );
  }
}
