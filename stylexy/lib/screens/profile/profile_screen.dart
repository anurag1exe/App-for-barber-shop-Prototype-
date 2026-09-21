import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser!;
    _nameController.text = user.name;
    _phoneController.text = user.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 80);
    if (picked == null) return;
    await AuthService.instance.updateProfile(photoPath: picked.path);
    if (mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    final nameErr = Validators.name(_nameController.text);
    if (nameErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameErr), backgroundColor: StylexyTheme.errorRed),
      );
      return;
    }

    await AuthService.instance.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: StylexyTheme.successGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: StylexyTheme.primaryGold.withOpacity(0.15),
                    backgroundImage: user.photoPath != null ? FileImage(File(user.photoPath!)) : null,
                    child: user.photoPath == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: StylexyTheme.primaryGold),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: StylexyTheme.primaryGold,
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: StylexyTheme.darkBg),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile fields
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              style: const TextStyle(color: StylexyTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, color: StylexyTheme.primaryGold),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              enabled: false, // Phone can't be changed
              style: const TextStyle(color: StylexyTheme.textSecondary),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone, color: StylexyTheme.primaryGold),
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: user.referralCode,
              enabled: false,
              style: const TextStyle(color: StylexyTheme.textSecondary),
              decoration: const InputDecoration(
                labelText: 'Referral Code',
                prefixIcon: Icon(Icons.confirmation_number_outlined, color: StylexyTheme.primaryGold),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: user.role.toUpperCase(),
              enabled: false,
              style: const TextStyle(color: StylexyTheme.textSecondary),
              decoration: const InputDecoration(
                labelText: 'Account Type',
                prefixIcon: Icon(Icons.shield_outlined, color: StylexyTheme.primaryGold),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _nameController.text = user.name;
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
