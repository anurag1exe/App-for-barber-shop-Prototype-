import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Booking> _allBookings = [];
  List<TimeSlot> _slots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (AuthService.instance.isAdmin) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final bookings = await BookingService.instance.getAllBookings();
    final slots = await BookingService.instance.getSlotsForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _allBookings = bookings;
        _slots = slots;
        _loading = false;
      });
    }
  }

  List<Booking> get _todayBookings {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    return _allBookings.where((b) => b.date.toIso8601String().split('T')[0] == dateStr).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Unauthorized', style: TextStyle(color: StylexyTheme.errorRed))),
      );
    }

    final bookedCount = _slots.where((s) => s.isBooked).length;
    final freeCount = _slots.where((s) => !s.isBooked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Slot Management')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : Column(
              children: [
                // Date selector
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: 7,
                    itemBuilder: (context, i) {
                      final date = DateTime.now().add(Duration(days: i));
                      final isSelected = _selectedDate.year == date.year &&
                          _selectedDate.month == date.month &&
                          _selectedDate.day == date.day;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = date);
                          _loadData();
                        },
                        child: Container(
                          width: 64,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? StylexyTheme.adminAccent : StylexyTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat('EEE').format(date), style: TextStyle(color: isSelected ? Colors.white : StylexyTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(date.day.toString(), style: TextStyle(color: isSelected ? Colors.white : StylexyTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatBadge(label: 'Booked', value: '$bookedCount', color: StylexyTheme.errorRed),
                      const SizedBox(width: 12),
                      _StatBadge(label: 'Available', value: '$freeCount', color: StylexyTheme.successGreen),
                      const SizedBox(width: 12),
                      _StatBadge(label: 'Bookings', value: '${_todayBookings.length}', color: StylexyTheme.primaryGold),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Bookings list
                Expanded(
                  child: _todayBookings.isEmpty
                      ? const Center(child: Text('No bookings for this day', style: TextStyle(color: StylexyTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _todayBookings.length,
                          itemBuilder: (context, i) {
                            final b = _todayBookings[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: StylexyTheme.cardBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: StylexyTheme.primaryGold.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(b.startTime, style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(b.userName, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                        Text('${b.serviceName} • ${b.barberName}', style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text('₹${b.servicePrice.toInt()}', style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
