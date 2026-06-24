import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:z_txt_editor/widgets/z_app_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const ZAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code, size: 80, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'ZTextEditor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A lightweight text editor for developers',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.goNamed('editor'),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open a file'),
            ),
          ],
        ),
      ),
    );
  }
}
