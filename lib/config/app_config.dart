import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart' show Locale;

/// Set to true when Firebase is fully configured.
const bool kEnableFirebase = true;

/// Set to true to surface the (not-yet-shipped) VisionRR camera-based
/// measurement mode in the UI. Kept behind a flag so the underlying model,
/// store, and l10n plumbing stay in place for a future release.
const bool kEnableVisionRR = false;

/// Set to true to surface the Circle tab in the bottom navigation. Kept
/// behind a flag so the underlying screen and route plumbing stay in place
/// for a future release.
const bool kEnableCircleTab = false;

/// Global locale notifier -- updated from Settings language switcher.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

/// Global dark-mode notifier -- updated from Settings dark mode toggle.
/// Active theme mode. Widened from a `bool` so [ThemeMode.system] can follow
/// the OS — the previous bool could only ever mean "light unless toggled",
/// which is why a device set to dark still opened the app in light.
///
/// `settingsStore` owns persistence and keeps this notifier in sync; read it
/// through a `ValueListenableBuilder` rather than sampling `.value` in `build`.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);
