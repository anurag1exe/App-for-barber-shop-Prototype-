import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../models/service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class SlotsScreen extends StatefulWidget {
  final BarberService? preSelectedService;
  const SlotsScreen({super.key, this.preSelectedService});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _slots = [];
  bool _loading = true;
  BarberService? _selectedService;
  String? _selectedBarberId;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preSelectedService;
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _loading = true);
    final slots = await BookingService.instance.getSlotsForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _slots = slots;
        _loading = false;
      });
    }
  }

  List<TimeSlot> get _filteredSlots {
    var filtered = _slots;
    if (_selectedBarberId != null) {
      filtered = filtered.where((s) => s.barberId == _selectedBarberId).toList();
    }
    return filtered;
  }

  Future<void> _bookSlot(TimeSlot slot) async {
    if (_selectedService == null) {
      // Show service picker
      final service = await showModalBottomSheet<BarberService>(
        context: context,
        backgroundColor: StylexyTheme.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a Service',
                style: TextStyle(color: StylexyTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ...BarberService.allServices.map((s) => ListTile(
                leading: Text(s.icon, style: const TextStyle(fontSize: 24)),
                title: Text(s.name, style: const TextStyle(color: StylexyTheme.textPrimary)),
                trailing: Text(s.priceDisplay, style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, s),
              )),
            ],
          ),
        ),
      );
      if (service == null) return;
      _selectedService = service;
    }

    if (!mounted) return;

    // Confirm booking dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StylexyTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Booking', style: TextStyle(color: StylexyTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Service', value: _selectedService!.name),
            _InfoRow(label: 'Price', value: _selectedService!.priceDisplay),
            _InfoRow(label: 'Barber', value: slot.barberName),
            _InfoRow(label: 'Date', value: DateFormat('EEE, d MMM').format(_selectedDate)),
            _InfoRow(label: 'Time', value: slot.displayTime),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StylexyTheme.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: StylexyTheme.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Payment via Wallet: ${_selectedService!.priceDisplay}',
                    style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: StylexyTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pay & Book'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final user = AuthService.instance.currentUser!;
    final result = await BookingService.instance.bookSlot(
      userId: user.id,
      userName: user.name,
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      servicePrice: _selectedService!.price,
      slot: slot,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? StylexyTheme.successGreen : StylexyTheme.errorRed,
      ),
    );

    if (result.success) {
      _selectedService = widget.preSelectedService;
      _loadSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Slot')),
      body: Column(
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
                    _loadSlots();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? StylexyTheme.primaryGold : StylexyTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? null : Border.all(color: StylexyTheme.dividerColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: isSelected ? StylexyTheme.darkBg : StylexyTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? StylexyTheme.darkBg : StylexyTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Barber filter
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All Barbers',
                  isSelected: _selectedBarberId == null,
                  onTap: () => setState(() => _selectedBarberId = null),
                ),
                ...Barber.defaultBarbers.map((b) => _FilterChip(
                  label: b.name,
                  isSelected: _selectedBarberId == b.id,
                  onTap: () => setState(() => _selectedBarberId = b.id),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Slots grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
                : _filteredSlots.isEmpty
                    ? const Center(
                        child: Text(
                          'No available slots',
                          style: TextStyle(color: StylexyTheme.textMuted),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: _filteredSlots.length,
                        itemBuilder: (context, i) {
                          final slot = _filteredSlots[i];
                          return GestureDetector(
                            onTap: slot.isBooked ? null : () => _bookSlot(slot),
                            child: Container(
                              decoration: BoxDecoration(
                                color: slot.isBooked
                                    ? StylexyTheme.errorRed.withOpacity(0.1)
                                    : StylexyTheme.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: slot.isBooked
                                      ? StylexyTheme.errorRed.withOpacity(0.3)
                                      : StylexyTheme.successGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slot.startTime,
                                    style: TextStyle(
                                      color: slot.isBooked ? StylexyTheme.errorRed : StylexyTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slot.isBooked ? 'Booked' : slot.barberName,
                                    style: TextStyle(
                                      color: slot.isBooked ? StylexyTheme.errorRed.withOpacity(0.7) : StylexyTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? StylexyTheme.primaryGold : StylexyTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? StylexyTheme.darkBg : StylexyTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 14)),
          Text(value, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
