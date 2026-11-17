import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4F8),
      appBar: AppBar(
        title: const Text('BalayNimo'),
        backgroundColor: const Color(0xFFEEF4F8),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => ref.read(authServiceProvider).logout(),
          ),
        ],
      ),
      body: Center(
        child: appUser.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (user) {
            if (user == null) return const CircularProgressIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, ${user.name}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Role: ${user.role}'),
                Text('Status: ${user.verificationStatus}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
