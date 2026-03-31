import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';

/// Wraps a widget in MaterialApp with theme + localization for testing.
///
/// Use this instead of per-file `_wrap()` helpers to get consistent
/// theme, locale, and scaffold setup across all widget tests.
Widget testApp(
  Widget child, {
  bool darkMode = false,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    theme: darkMode ? buildDarkTheme() : buildAppTheme(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
