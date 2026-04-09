import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/widgets.dart' show Locale;

/// Set to true when Firebase is fully configured.
const bool kEnableFirebase = true;

/// Global locale notifier -- updated from Settings language switcher.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

/// Global dark-mode notifier -- updated from Settings dark mode toggle.
final ValueNotifier<bool> appDarkMode = ValueNotifier(false);
