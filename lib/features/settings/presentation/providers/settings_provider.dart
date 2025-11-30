import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

// Theme Mode Provider
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeModeEnum build() {
    _loadThemeMode();
    return ThemeModeEnum.system;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    state = ThemeModeEnum.values.firstWhere(
      (e) => e.name == themeModeString,
      orElse: () => ThemeModeEnum.system,
    );
  }

  Future<void> setThemeMode(ThemeModeEnum mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    state = mode;
  }
}

enum ThemeModeEnum {
  light,
  dark,
  system,
}

extension ThemeModeEnumX on ThemeModeEnum {
  ThemeMode toMaterialThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }
}

// Notification Settings Provider
@riverpod
class NotificationSettings extends _$NotificationSettings {
  @override
  bool build() {
    _loadSettings();
    return true;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', !state);
    state = !state;
  }
}

// User Preferences Model
@riverpod
class UserPreferences extends _$UserPreferences {
  @override
  UserPreferencesModel build() {
    _loadPreferences();
    return const UserPreferencesModel();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserPreferencesModel(
      defaultScheduleDuration: prefs.getInt('default_duration') ?? 60,
      showWeekNumbers: prefs.getBool('show_week_numbers') ?? false,
      firstDayOfWeek: prefs.getInt('first_day_of_week') ?? 1, // Monday
    );
  }

  Future<void> updateDefaultDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_duration', minutes);
    state = state.copyWith(defaultScheduleDuration: minutes);
  }

  Future<void> toggleWeekNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_week_numbers', !state.showWeekNumbers);
    state = state.copyWith(showWeekNumbers: !state.showWeekNumbers);
  }

  Future<void> setFirstDayOfWeek(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('first_day_of_week', day);
    state = state.copyWith(firstDayOfWeek: day);
  }
}

class UserPreferencesModel {
  final int defaultScheduleDuration; // in minutes
  final bool showWeekNumbers;
  final int firstDayOfWeek; // 1 = Monday, 7 = Sunday

  const UserPreferencesModel({
    this.defaultScheduleDuration = 60,
    this.showWeekNumbers = false,
    this.firstDayOfWeek = 1,
  });

  UserPreferencesModel copyWith({
    int? defaultScheduleDuration,
    bool? showWeekNumbers,
    int? firstDayOfWeek,
  }) {
    return UserPreferencesModel(
      defaultScheduleDuration: defaultScheduleDuration ?? this.defaultScheduleDuration,
      showWeekNumbers: showWeekNumbers ?? this.showWeekNumbers,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }
}
