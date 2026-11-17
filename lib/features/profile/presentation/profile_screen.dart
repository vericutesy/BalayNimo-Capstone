import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_service.dart';

const _bgColor = Color(0xFFEEF4F8);
const _cardColor = Color(0xFFF7FAFC);
const _primaryBlue = Color(0xFF2563EB);
const _textColor = Color(0xFF1E293B);
const _subtitleColor = Color(0xFF64748B);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).updateName(_nameController.text);
      if (!mounted) return;
      _showMessage('Profile updated.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not update profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final service = ref.read(authServiceProvider);
    Navigator.of(context).popUntil((route) => route.isFirst);
    await service.logout();
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: _bgColor,
      ),
      body: SafeArea(
        child: appUser.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!_loaded) {
              _nameController.text = user.name;
              _loaded = true;
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _card(
                      child: TextFormField(
                        controller: _nameController,
                        style:
                            const TextStyle(fontSize: 14, color: _textColor),
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: _subtitleColor, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoTile(Icons.email_outlined, 'Email', user.email),
                    const SizedBox(height: 16),
                    _infoTile(Icons.badge_outlined, 'Role', user.role),
                    const SizedBox(height: 16),
                    _infoTile(Icons.verified_user_outlined,
                        'Verification status', user.verificationStatus),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.6),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return _card(
      child: ListTile(
        leading: Icon(icon, color: _subtitleColor, size: 20),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: _subtitleColor),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, color: _textColor),
        ),
      ),
    );
  }
}