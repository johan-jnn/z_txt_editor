import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:z_txt_editor/states/settings.dart';
import 'package:z_txt_editor/widgets/cached_duck_image.dart';

class DuckOverlay extends StatelessWidget {
  const DuckOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    final routePath = GoRouterState.of(context).uri.path;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        if (!settings.duckImageEnabled) return const SizedBox.shrink();

        final isRandom = settings.duckMode == DuckOverlayMode.fullRandom;
        final cacheKey = isRandom ? 'random_$routePath' : settings.duckUrl;

        return CachedDuckImage(
          key: ValueKey(cacheKey),
          imageUrl: isRandom
              ? 'https://random-d.uk/api/randomimg?type=JPG'
              : settings.duckUrl,
          opacity: settings.duckOpacity / 100,
        );
      },
    );
  }
}
