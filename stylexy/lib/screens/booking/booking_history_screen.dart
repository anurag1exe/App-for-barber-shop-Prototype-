import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../rating/rate_barber_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final userId = AuthService.instance.currentUser!.id;
    final bookings = await BookingService.instance.getUserBookings(userId);
    if (mounted) setState(() { _bookings = bookings; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _bookings.where((b) =>
      b.date.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
      b.status == BookingStatus.confirmed
    ).toList();
    final past = _bookings.where((b) =>
      b.date.isBefore(DateTime.now()) || b.status != BookingStatus.confirmed
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, color: StylexyTheme.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text('No bookings yet', style: TextStyle(color: StylexyTheme.textMuted, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Book a service to get started!', style: TextStyle(color: StylexyTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: StylexyTheme.primaryGold,
                  onRefresh: _loadBookings,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        const Text('Upcoming', style: TextStyle(color: StylexyTheme.primaryGold, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...upcoming.map((b) => _BookingCard(booking: b, onRate: () => _goToRate(b), onRefresh: _loadBookings)),
                        const SizedBox(height: 20),
                      ],
                      if (past.isNotEmpty) ...[
                        const Text('Past Visits', style: TextStyle(color: StylexyTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...past.map((b) => _BookingCard(booking: b, onRate: () => _goToRate(b), onRefresh: _loadBookings)),
                      ],
                    ],
                  ),
                ),
    );
  }

  void _goToRate(Booking booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RateBarberScreen(booking: booking)),
    );
    _loadBookings();
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onRate;
  final VoidCallback onRefresh;

  const _BookingCard({required this.booking, required this.onRate, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(booking.date);
    final isPast = booking.date.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StylexyTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StylexyTheme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StylexyTheme.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.content_cut, color: StylexyTheme.primaryGold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text('with ${booking.barberName}', style: const TextStyle(color: StylexyTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text('₹${booking.servicePrice.toInt()}', style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: StylexyTheme.textMuted),
              const SizedBox(width: 6),
              Text(dateStr, style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: StylexyTheme.textMuted),
              const SizedBox(width: 6),
              Text('${booking.startTime} – ${booking.endTime}', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12)),
            ],
          ),
          if (isPast && !booking.isRated) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRate,
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Rate this visit'),
              ),
            ),
          ],
          if (booking.isRated) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: StylexyTheme.successGreen, size: 16),
                const SizedBox(width: 6),
                const Text('Rated', style: TextStyle(color: StylexyTheme.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
