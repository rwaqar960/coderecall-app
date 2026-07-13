import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings persisted locally. Notifies listeners on theme changes so the
/// MaterialApp can rebuild.
class SettingsController extends ChangeNotifier {
  SettingsController._(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'themeMode';
  static const _onboardingKey = 'onboardingSeen';

  static Future<SettingsController> load() async =>
      SettingsController._(await SharedPreferences.getInstance());

  ThemeMode get themeMode => switch (_prefs.getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  bool get onboardingSeen => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> completeOnboarding() => _prefs.setBool(_onboardingKey, true);
}
