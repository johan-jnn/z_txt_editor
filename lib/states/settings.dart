import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DuckOverlayMode { fullRandom, fixedRandom, disabled }

class AppSettings extends ChangeNotifier {
  static const _bgColorKey = 'bg-color';
  static const _duckModeKey = 'duck-mode';
  static const _duckUrlKey = 'duck-url';
  static const _duckOpacityKey = 'duck-opacity';

  bool isLoaded = false;
  Color backgroundColor = const Color(0xFF1E1E1E);
  DuckOverlayMode duckMode = DuckOverlayMode.fullRandom;
  String duckUrl = 'https://random-d.uk/api/randomimg?type=JPG';
  double duckOpacity = 20.0;

  bool get duckImageEnabled => duckMode != DuckOverlayMode.disabled && duckOpacity > 0;

  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  Future<void> load() async {
    if (isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final bgVal = prefs.getInt(_bgColorKey);
    if (bgVal != null) backgroundColor = Color(bgVal);
    final modeIdx = prefs.getInt(_duckModeKey);
    if (modeIdx != null) duckMode = DuckOverlayMode.values[modeIdx];
    duckUrl = prefs.getString(_duckUrlKey) ?? 'https://random-d.uk/api/randomimg?type=JPG';
    duckOpacity = prefs.getDouble(_duckOpacityKey) ?? 20.0;
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bgColorKey, backgroundColor.toARGB32());
    await prefs.setInt(_duckModeKey, duckMode.index);
    await prefs.setString(_duckUrlKey, duckUrl);
    await prefs.setDouble(_duckOpacityKey, duckOpacity);
    notifyListeners();
  }

  Future<void> setBackgroundColor(Color color) async {
    backgroundColor = color;
    await _save();
  }

  Future<void> setDuckMode(DuckOverlayMode mode) async {
    duckMode = mode;
    await _save();
  }

  Future<void> setDuckUrl(String url) async {
    duckUrl = url;
    await _save();
  }

  Future<void> setDuckOpacity(double opacity) async {
    duckOpacity = opacity;
    await _save();
  }
}
