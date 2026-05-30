import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/widgets.dart' show Locale;

/// Set to true when Firebase is fully configured.
const bool kEnableFirebase = true;

/// Set to true to surface the (not-yet-shipped) VisionRR camera-based
/// measurement mode in the UI. Kept behind a flag so the underlying model,
/// store, and l10n plumbing stay in place for a future release.
const bool kEnableVisionRR = false;

/// Global locale notifier -- updated from Settings language switcher.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

/// Global dark-mode notifier -- updated from Settings dark mode toggle.
final ValueNotifier<bool> appDarkMode = ValueNotifier(false);
