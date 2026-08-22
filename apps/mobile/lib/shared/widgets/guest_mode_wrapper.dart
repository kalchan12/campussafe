import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';

class GuestModeWrapper extends StatelessWidget {
  const GuestModeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusSafe - Guest Mode'),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
      body: IndexedStack(
        index: 0,
        children: [
          HomePage(
            isGuest: true,
            onLoginPressed: () => context.go('/login'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new'),
        icon: const Icon(Icons.warning_amber),
        label: const Text('Report Issue'),
      ),
    );
  }
}
