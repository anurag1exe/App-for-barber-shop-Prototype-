import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/ai_hairstyle_service.dart';

class HairstyleGallery extends StatelessWidget {
  final List<HairstylePreview> previews;
  final String? photoPath;
  final ValueChanged<HairstylePreview>? onSelectStyle;

  const HairstyleGallery({
    super.key,
    required this.previews,
    this.photoPath,
    this.onSelectStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (previews.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 270,
      child: PageView.builder(
        itemCount: previews.length,
        controller: PageController(viewportFraction: 0.82),
        itemBuilder: (context, index) {
          final preview = previews[index];
          return GestureDetector(
            onTap: () => _showStyleDetails(context, preview),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: StylexyTheme.cardBg,
                border: Border.all(
                  color: StylexyTheme.primaryGold.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image or Pattern
                    if (preview.imageBytes != null)
                      Image.memory(
                        preview.imageBytes!,
                        fit: BoxFit.cover,
                      )
                    else if (preview.imageUrl != null && preview.imageUrl!.isNotEmpty)
                      Image.network(
                        preview.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: StylexyTheme.cardBg,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: StylexyTheme.primaryGold,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                preview.previewColor,
                                StylexyTheme.cardBg,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.content_cut,
                              size: 48,
                              color: StylexyTheme.primaryGold,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              preview.previewColor,
                              StylexyTheme.darkBg,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.content_cut,
                            size: 48,
                            color: StylexyTheme.primaryGold,
                          ),
                        ),
                      ),

                    // Gradient overlay for contrast
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.65),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Top Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: StylexyTheme.primaryGold.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: StylexyTheme.primaryGold,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              preview.isGenerated ? 'AI Matched' : 'Trending Style',
                              style: const TextStyle(
                                color: StylexyTheme.primaryGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Content
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            preview.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preview.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (preview.reason.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 13,
                                  color: StylexyTheme.successGreen,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    preview.reason,
                                    style: const TextStyle(
                                      color: StylexyTheme.successGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStyleDetails(BuildContext context, HairstylePreview preview) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StylexyTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: StylexyTheme.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: StylexyTheme.primaryGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preview.name,
                          style: const TextStyle(
                            color: StylexyTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'AI Hairstyle Recommendation',
                          style: TextStyle(
                            color: StylexyTheme.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                preview.description,
                style: const TextStyle(
                  color: StylexyTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (preview.reason.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StylexyTheme.darkBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StylexyTheme.successGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.face,
                        color: StylexyTheme.successGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Face Match: ${preview.reason}',
                          style: const TextStyle(
                            color: StylexyTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (preview.stylingTip.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StylexyTheme.darkBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StylexyTheme.primaryGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.tips_and_updates_outlined,
                        color: StylexyTheme.primaryGold,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Styling Tip: ${preview.stylingTip}',
                          style: const TextStyle(
                            color: StylexyTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Book An Appointment For This Style'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StylexyTheme.primaryGold,
                    foregroundColor: StylexyTheme.darkBg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onSelectStyle != null) {
                      onSelectStyle!(preview);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
