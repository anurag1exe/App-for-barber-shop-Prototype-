import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../models/service.dart';
import '../../services/auth_service.dart';
import '../../services/ai_hairstyle_service.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/wallet_icon.dart';
import '../../widgets/service_card.dart';
import '../../widgets/hairstyle_gallery.dart';
import '../wallet/wallet_screen.dart';
import '../booking/slots_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String? _photoPath;
  List<HairstylePreview>? _previews;
  bool _loadingPreviews = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadInitialPreviews();
  }

  Future<void> _loadInitialPreviews() async {
    setState(() => _loadingPreviews = true);
    final previews = await AiHairstyleService.instance.generatePreviews(null);
    if (mounted) {
      setState(() {
        _previews = previews;
        _loadingPreviews = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: StylexyTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Your Photo for AI Stylist',
                style: TextStyle(
                  color: StylexyTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StylexyTheme.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: StylexyTheme.primaryGold),
                ),
                title: const Text('Take a Selfie', style: TextStyle(color: StylexyTheme.textPrimary)),
                subtitle: const Text('Let AI analyze your face shape', style: TextStyle(color: StylexyTheme.textMuted)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StylexyTheme.accentTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: StylexyTheme.accentTeal),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(color: StylexyTheme.textPrimary)),
                subtitle: const Text('Select a clear portrait photo', style: TextStyle(color: StylexyTheme.textMuted)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _photoPath = picked.path;
      _loadingPreviews = true;
    });

    final previews = await AiHairstyleService.instance.generatePreviews(_photoPath);
    if (mounted) {
      setState(() {
        _previews = previews;
        _loadingPreviews = false;
      });
    }
  }

  void _bookService(BarberService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SlotsScreen(preSelectedService: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: StylexyTheme.primaryGold),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('STYLEXY'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: WalletIcon(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: StylexyTheme.primaryGold,
        onRefresh: () async {
          await _loadInitialPreviews();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: StylexyTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.name ?? 'Gentleman',
                        style: const TextStyle(
                          color: StylexyTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: StylexyTheme.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: StylexyTheme.primaryGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: StylexyTheme.primaryGold, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: StylexyTheme.primaryGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AI Hairstyle Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      StylexyTheme.cardBg,
                      StylexyTheme.cardBgLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: StylexyTheme.primaryGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
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
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Hairstyle Recommendation',
                                style: TextStyle(
                                  color: StylexyTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Powered by Google Gemini Vision',
                                style: TextStyle(
                                  color: StylexyTheme.primaryGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt, size: 15),
                          label: Text(_photoPath != null ? 'Retake' : 'Try-On'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StylexyTheme.primaryGold,
                            foregroundColor: StylexyTheme.darkBg,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_photoPath != null && !_loadingPreviews) ...[
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_photoPath!),
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Face shape analyzed! Here are your tailored hairstyles:',
                              style: TextStyle(
                                color: StylexyTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_loadingPreviews)
                      Container(
                        height: 180,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: StylexyTheme.primaryGold,
                              strokeWidth: 2.5,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Analyzing face profile & generating hairstyles...',
                              style: TextStyle(
                                color: StylexyTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_previews != null && _previews!.isNotEmpty)
                      HairstyleGallery(
                        previews: _previews!,
                        photoPath: _photoPath,
                        onSelectStyle: (preview) {
                          // Preselect haircut or combo service
                          final haircutService = BarberService.allServices.firstWhere(
                            (s) => s.id == 'haircut',
                            orElse: () => BarberService.allServices.first,
                          );
                          _bookService(haircutService);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Services Section
              const Text(
                'Our Services',
                style: TextStyle(
                  color: StylexyTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...BarberService.allServices.map(
                (service) => ServiceCard(
                  service: service,
                  onBook: () => _bookService(service),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
