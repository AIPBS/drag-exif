/*
DragExif - EXIF metadata viewer
Copyright (C) 2026 Allen
Project homepage: https://github.com/AIPEAC/drag-exif


This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/settings_service.dart';
import 'utils/locale_notifier.dart';

class DragExifApp extends StatefulWidget {
  const DragExifApp({super.key});

  @override
  State<DragExifApp> createState() => _DragExifAppState();
}

class _DragExifAppState extends State<DragExifApp> {
  final _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'DragExif',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          locale: locale ?? _locale,
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: FlexThemeData.light(
            scheme: FlexScheme.blueWhale,
            useMaterial3: true,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              inputDecoratorRadius: 8,
              cardRadius: 10,
              popupMenuRadius: 8,
              popupMenuElevation: 3,
            ),
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.blueWhale,
            useMaterial3: true,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              inputDecoratorRadius: 8,
              cardRadius: 10,
              popupMenuRadius: 8,
              popupMenuElevation: 3,
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }

  ThemeMode get _themeMode {
    switch (_settings.themeMode) {
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Locale? get _locale {
    if (_settings.locale.isEmpty) return null;
    return Locale(_settings.locale);
  }
}
