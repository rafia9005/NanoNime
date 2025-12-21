import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: const Center(
        child: Text(
          'Daftar anime favoritmu akan tampil di sini.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
