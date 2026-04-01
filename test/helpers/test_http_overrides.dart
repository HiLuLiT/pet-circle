import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Transparent 1x1 PNG image bytes for mocking network image responses.
final Uint8List kTransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

/// HTTP overrides that intercept all network requests and return
/// a 1x1 transparent PNG. Prevents network image errors in widget tests.
///
/// Usage:
/// ```dart
/// setUpAll(() => HttpOverrides.global = MockHttpOverrides());
/// tearDownAll(() => HttpOverrides.global = null);
/// ```
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}

  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}

  @override
  set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Encoding encoding = utf8;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) => Future.value();

  @override
  Future<HttpClientResponse> close() => Future.value(_MockHttpClientResponse());

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<HttpClientResponse> get done => close();

  @override
  Future flush() => Future.value();

  @override
  String get method => 'GET';

  @override
  Uri get uri => Uri.parse('http://localhost');

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}

  @override
  bool get bufferOutput => true;

  @override
  set bufferOutput(bool value) {}

  @override
  int get contentLength => -1;

  @override
  set contentLength(int value) {}

  @override
  bool get followRedirects => true;

  @override
  set followRedirects(bool value) {}

  @override
  int get maxRedirects => 5;

  @override
  set maxRedirects(int value) {}

  @override
  bool get persistentConnection => true;

  @override
  set persistentConnection(bool value) {}

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  List<Cookie> get cookies => [];

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => [];

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  X509Certificate? get certificate => null;

  @override
  Future<HttpClientResponse> redirect(
      [String? method, Uri? url, bool? followLoops]) {
    return Future.value(this);
  }

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError('detachSocket');
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kTransparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void remove(String name, Object value) {}

  @override
  void removeAll(String name) {}

  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  void noFolding(String name) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
