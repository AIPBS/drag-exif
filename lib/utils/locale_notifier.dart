import 'package:flutter/material.dart';

/// Global notifier to rebuild the app when the user changes language in Settings.
final localeNotifier = ValueNotifier<Locale?>(null);

/// Global notifier to rebuild the app when the user changes theme in Settings.
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
