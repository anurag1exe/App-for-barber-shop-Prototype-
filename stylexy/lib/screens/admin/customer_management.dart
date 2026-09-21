import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!AuthService.instance.isAdmin) return;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await BookingService.instance.getCustomerStats();
    if (mounted) {
      setState(() {
        _customers = data;
        _filtered = data;
        _loading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _filtered = _customers.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final phone = (c['phone'] as String).toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    });
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
      appBar: AppBar(title: const Text('Customers')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: StylexyTheme.primaryGold))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    style: const TextStyle(color: StylexyTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      prefixIcon: const Icon(Icons.search, color: StylexyTheme.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: StylexyTheme.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                _search('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${_filtered.length} customers',
                    style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('No customers found', style: TextStyle(color: StylexyTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final c = _filtered[i];
                            final visits = c['totalVisits'] as int? ?? 0;
                            final lastVisit = c['lastVisit'] as String?;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: StylexyTheme.cardBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: StylexyTheme.primaryGold.withOpacity(0.12),
                                    child: Text(
                                      (c['name'] as String)[0].toUpperCase(),
                                      style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c['name'] as String, style: const TextStyle(color: StylexyTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(height: 3),
                                        Text(c['phone'] as String, style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$visits visits', style: const TextStyle(color: StylexyTheme.primaryGold, fontWeight: FontWeight.w700, fontSize: 14)),
                                      if (lastVisit != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          'Last: ${DateFormat('d MMM').format(DateTime.parse(lastVisit))}',
                                          style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ],
                                  ),
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
