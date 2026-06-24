import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:z_txt_editor/states/settings.dart';
import 'package:z_txt_editor/widgets/cached_duck_image.dart';
import 'package:z_txt_editor/widgets/color_picker.dart';
import 'package:z_txt_editor/widgets/z_app_bar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _settings = AppSettings();
  bool _fetchingDuck = false;

  Future<void> _fetchNewDuck() async {
    setState(() => _fetchingDuck = true);
    try {
      final response = await Dio().get('https://random-d.uk/api/quack');
      if (response.statusCode == 200) {
        final url = (response.data as Map<String, dynamic>)['url'] as String?;
        if (url != null && mounted) {
          await _settings.setDuckUrl(url);
          await _settings.setDuckMode(DuckOverlayMode.fixedRandom);
        }
      }
    } on DioException catch (e) {
      if (mounted) _snack('Failed to fetch duck: ${e.message}');
    } finally {
      if (mounted) setState(() => _fetchingDuck = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const ZAppBar(title: 'Settings'),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Background Color',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdvancedColorPicker(
                color: _settings.backgroundColor,
                onColorChanged: _settings.setBackgroundColor,
              ),
              const Divider(height: 32),
              Text(
                'Duck Overlay',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DuckOverlayMode>(
                initialValue: _settings.duckMode,
                decoration: const InputDecoration(
                  labelText: 'Mode',
                  border: OutlineInputBorder(),
                ),
                onChanged: (mode) => _settings.setDuckMode(mode!),
                items: const [
                  DropdownMenuItem(
                    value: DuckOverlayMode.fullRandom,
                    child: Text('Full Random (changes on navigation)'),
                  ),
                  DropdownMenuItem(
                    value: DuckOverlayMode.fixedRandom,
                    child: Text('Fixed (stays until changed)'),
                  ),
                  DropdownMenuItem(
                    value: DuckOverlayMode.disabled,
                    child: Text('Disabled'),
                  ),
                ],
              ),
              if (_settings.duckMode != DuckOverlayMode.disabled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Opacity'),
                    Expanded(
                      child: Slider(
                        value: _settings.duckOpacity,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '${_settings.duckOpacity.toInt()}%',
                        onChanged: _settings.setDuckOpacity,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${_settings.duckOpacity.toInt()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              if (_settings.duckMode == DuckOverlayMode.fixedRandom) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 160,
                    child: CachedDuckImage(
                      imageUrl: _settings.duckUrl,
                      opacity: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _fetchingDuck ? null : _fetchNewDuck,
                  icon: _fetchingDuck
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Get New Duck'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
