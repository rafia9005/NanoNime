import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nanonime/providers/auth_provider.dart';
import 'package:nanonime/core/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Tambahkan menu lain di sini jika perlu
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              AppRouter.toLogin(context, replace: true);
            },
          ),
        ],
      ),
    );
  }
}
