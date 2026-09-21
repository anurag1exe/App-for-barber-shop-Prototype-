import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';

class HairstylePreview {
  final String name;
  final String description;
  final String reason;
  final String stylingTip;
  final Color previewColor;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final bool isGenerated;

  HairstylePreview({
    required this.name,
    required this.description,
    this.reason = '',
    this.stylingTip = '',
    required this.previewColor,
    this.imageUrl,
    this.imageBytes,
    required this.isGenerated,
  });
}

class AiHairstyleService {
  static final AiHairstyleService instance = AiHairstyleService._();
  AiHairstyleService._();

  static const Map<String, String> _styleImages = {
    'Classic Fade': 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&auto=format&fit=crop',
    'Pompadour': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&auto=format&fit=crop',
    'Buzz Cut': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=800&auto=format&fit=crop',
    'Undercut': 'https://images.unsplash.com/photo-1517832606589-7629c3397143?w=800&auto=format&fit=crop',
    'Crew Cut': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop',
    'Quiff': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800&auto=format&fit=crop',
    'Textured Crop': 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&auto=format&fit=crop',
    'Slick Back': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop',
  };

  static const List<Map<String, String>> fallbackStyles = [
    {
      'name': 'Classic Low Fade',
      'description': 'Clean tapered sides with natural texture on top',
      'reason': 'Balanced silhouette suited for almost all face profiles',
      'stylingTip': 'Use a matte clay for a natural, flexible hold',
      'imageUrl': 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&auto=format&fit=crop',
    },
    {
      'name': 'Modern Textured Crop',
      'description': 'Short textured crown with blunt or choppy fringe',
      'reason': 'Accentuates jawline and adds structured depth',
      'stylingTip': 'Towel dry and apply sea salt spray for extra texture',
      'imageUrl': 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&auto=format&fit=crop',
    },
    {
      'name': 'Voluminous Quiff',
      'description': 'Upward swept front with tapered clean edges',
      'reason': 'Creates height and elongation for rounder profiles',
      'stylingTip': 'Blow-dry upwards with a round brush and finish with pomade',
      'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800&auto=format&fit=crop',
    },
    {
      'name': 'Executive Side Part',
      'description': 'Timeless side-swept parting with sharp outline',
      'reason': 'Professional, clean, and highlights facial symmetry',
      'stylingTip': 'Comb damp hair with a light cream or medium-shine wax',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop',
    },
  ];

  /// Generate AI hairstyle recommendations with Google Gemini AI Studio
  Future<List<HairstylePreview>> generatePreviews(String? photoPath) async {
    final apiKey = AppSecrets.aiApiKey;

    if (apiKey.isEmpty || apiKey == 'YOUR_AI_API_KEY_HERE') {
      return _getFallbackPreviews(photoPath != null);
    }

    try {
      final url = Uri.parse(
        '${AppSecrets.aiApiBaseUrl}/models/${AppSecrets.aiModel}:generateContent?key=$apiKey',
      );

      final List<Map<String, dynamic>> parts = [];

      if (photoPath != null && File(photoPath).existsSync()) {
        final imageBytes = await File(photoPath).readAsBytes();
        final base64Image = base64Encode(imageBytes);

        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });

        parts.add({
          'text': '''You are an expert master barber and celebrity hair stylist.
Analyze the user's face shape (Oval, Round, Square, Heart, Diamond, or Oblong), forehead, jawline, and hair texture from the uploaded photo.
Recommend 4 to 6 specific, modern barbershop hairstyles tailored specifically to their facial structure.

Return ONLY a valid JSON array of objects (with no extra text or markdown code blocks if possible).
Each object must have:
- "name": String (name of the hairstyle, e.g. "Textured French Crop", "Low Skin Fade with Side Part")
- "description": String (brief 1-sentence visual description)
- "reason": String (why this style fits their specific face shape)
- "stylingTip": String (barber tip for daily maintenance)
- "imageUrl": String (optional matching Unsplash photo URL if relevant, or empty string)'''
        });
      } else {
        parts.add({
          'text': '''You are an expert master barber. Recommend the top 5 trending modern men's hairstyles for 2026.
Return ONLY a valid JSON array of objects with:
- "name": String
- "description": String
- "reason": String
- "stylingTip": String
- "imageUrl": String'''
        });
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': parts}
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topP': 0.9,
            'maxOutputTokens': 1024,
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'];
          final responseParts = content?['parts'] as List?;
          if (responseParts != null && responseParts.isNotEmpty) {
            String rawText = responseParts.first['text'] ?? '';
            // Clean markdown code blocks if present
            rawText = rawText.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
            rawText = rawText.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
            rawText = rawText.trim();

            final dynamic parsed = jsonDecode(rawText);
            if (parsed is List) {
              return parsed.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value as Map<String, dynamic>;
                final name = item['name']?.toString() ?? 'Styled Cut';
                final desc = item['description']?.toString() ?? 'Modern precision barber cut';
                final reason = item['reason']?.toString() ?? '';
                final tip = item['stylingTip']?.toString() ?? '';
                final remoteImg = item['imageUrl']?.toString();

                final resolvedImg = (remoteImg != null && remoteImg.startsWith('http'))
                    ? remoteImg
                    : (_matchCuratedImage(name) ?? fallbackStyles[idx % fallbackStyles.length]['imageUrl']!);

                return HairstylePreview(
                  name: name,
                  description: desc,
                  reason: reason,
                  stylingTip: tip,
                  previewColor: _getColorForIndex(idx),
                  imageUrl: resolvedImg,
                  isGenerated: true,
                );
              }).toList();
            }
          }
        }
      }
    } catch (_) {
      // Fallback gracefully on timeout, offline, or parsing error
    }

    return _getFallbackPreviews(photoPath != null);
  }

  String? _matchCuratedImage(String styleName) {
    final lower = styleName.toLowerCase();
    for (final entry in _styleImages.entries) {
      if (lower.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF18181B),
      Color(0xFF27272A),
      Color(0xFF1C1917),
      Color(0xFF262626),
    ];
    return colors[index % colors.length];
  }

  List<HairstylePreview> _getFallbackPreviews(bool isGenerated) {
    return fallbackStyles.asMap().entries.map((entry) {
      final idx = entry.key;
      final style = entry.value;
      return HairstylePreview(
        name: style['name']!,
        description: style['description']!,
        reason: style['reason']!,
        stylingTip: style['stylingTip']!,
        previewColor: _getColorForIndex(idx),
        imageUrl: style['imageUrl']!,
        isGenerated: isGenerated,
      );
    }).toList();
  }

  bool get isConfigured =>
      AppSecrets.aiApiKey != 'YOUR_AI_API_KEY_HERE' &&
      AppSecrets.aiApiKey.isNotEmpty;
}
