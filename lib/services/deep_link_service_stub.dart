// Stub that replaces `app_links` on web where the package is not used.
// The conditional import in `deep_link_service.dart` selects this file on web.
// Since web deep links are handled by GoRouter via the browser URL, the
// AppLinks class is never instantiated — but the import must resolve.

import 'dart:async';

/// No-op stand-in for `package:app_links/app_links.dart` on web.
class AppLinks {
  Future<Uri?> getInitialLink() async => null;

  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}
