import 'package:flutter/material.dart';
import 'package:z_txt_editor/states/settings.dart';
import 'package:z_txt_editor/widgets/duck_overlay.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  const AppLayout({required this.child, super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        if (!_settings.isLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Container(
          color: _settings.backgroundColor,
          child: Stack(
            children: [
              const Positioned.fill(child: DuckOverlay()),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
