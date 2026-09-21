import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/rating_service.dart';

class RateBarberScreen extends StatefulWidget {
  final Booking booking;
  const RateBarberScreen({super.key, required this.booking});

  @override
  State<RateBarberScreen> createState() => _RateBarberScreenState();
}

class _RateBarberScreenState extends State<RateBarberScreen> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating'), backgroundColor: StylexyTheme.errorRed),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = AuthService.instance.currentUser!;
    final result = await RatingService.instance.submitRating(
      bookingId: widget.booking.id,
      userId: user.id,
      userName: user.name,
      barberId: widget.booking.barberId,
      barberName: widget.booking.barberName,
      serviceId: widget.booking.serviceId,
      serviceName: widget.booking.serviceName,
      stars: _rating,
      comment: _commentController.text,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? StylexyTheme.successGreen : StylexyTheme.errorRed,
      ),
    );

    if (result.success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Barber info
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: StylexyTheme.primaryGold.withOpacity(0.15),
                child: Text(
                  widget.booking.barberName[0],
                  style: const TextStyle(
                    color: StylexyTheme.primaryGold,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.booking.barberName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: StylexyTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              widget.booking.serviceName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: StylexyTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 36),

            // Star Rating
            const Text(
              'How was your experience?',
              textAlign: TextAlign.center,
              style: TextStyle(color: StylexyTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Center(
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 48,
                unratedColor: StylexyTheme.cardBgLight,
                itemPadding: const EdgeInsets.symmetric(horizontal: 6),
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: StylexyTheme.primaryGold),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _rating == 0
                  ? 'Tap to rate'
                  : _rating <= 2
                      ? 'We\'ll do better next time'
                      : _rating <= 3
                          ? 'Good'
                          : _rating <= 4
                              ? 'Great!'
                              : 'Excellent! 🎉',
              textAlign: TextAlign.center,
              style: const TextStyle(color: StylexyTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 28),

            // Optional comment
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              style: const TextStyle(color: StylexyTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Add a comment (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: StylexyTheme.darkBg, strokeWidth: 2.5))
                    : const Text('SUBMIT RATING'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
