import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/rating.dart';
import '../../services/auth_service.dart';
import '../../services/rating_service.dart';

class RatingsOverviewScreen extends StatefulWidget {
  const RatingsOverviewScreen({super.key});

  @override
  State<RatingsOverviewScreen> createState() => _RatingsOverviewScreenState();
}

class _RatingsOverviewScreenState extends State<RatingsOverviewScreen> {
  List<BarberRatingSummary> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (AuthService.instance.isAdmin) _loadData();
  }

  Future<void> _loadData() async {
    final summaries = await RatingService.instance.getAllBarberRatingSummaries();
    if (mounted) setState(() { _summaries = summaries; _loading = false; });
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
      appBar: AppBar(title: const Text('Ratings Overview')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _summaries.length,
              itemBuilder: (context, i) {
                final s = _summaries[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StylexyTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: StylexyTheme.primaryGold.withOpacity(0.12),
                            child: Text(s.barberName[0], style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.barberName, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                                Text('${s.totalRatings} reviews', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: StylexyTheme.primaryGold, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                s.totalRatings > 0 ? s.averageRating.toStringAsFixed(1) : '—',
                                style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w900, fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (s.totalRatings > 0) ...[
                        const SizedBox(height: 16),
                        // Star breakdown bars
                        ...List.generate(5, (j) {
                          final star = 5 - j;
                          final count = s.starCounts[star] ?? 0;
                          final pct = s.totalRatings > 0 ? count / s.totalRatings : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                SizedBox(width: 16, child: Text('$star', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12))),
                                const Icon(Icons.star, size: 12, color: StylexyTheme.primaryGold),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: StylexyTheme.cardBgLight,
                                      color: StylexyTheme.primaryGold,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(width: 24, child: Text('$count', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12))),
                              ],
                            ),
                          );
                        }),
                        // Recent comments
                        if (s.recentRatings.any((r) => r.comment != null)) ...[
                          const SizedBox(height: 12),
                          const Divider(color: StylexyTheme.dividerColor),
                          const SizedBox(height: 8),
                          const Text('Recent Comments', style: TextStyle(color: StylexyTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...s.recentRatings.where((r) => r.comment != null).take(3).map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(r.stars.toInt(), (_) => const Icon(Icons.star, size: 10, color: StylexyTheme.primaryGold)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '"${r.comment}"',
                                    style: const TextStyle(color: StylexyTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                      if (s.totalRatings == 0) ...[
                        const SizedBox(height: 8),
                        const Text('No ratings yet', style: TextStyle(color: StylexyTheme.textMuted, fontSize: 13)),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
