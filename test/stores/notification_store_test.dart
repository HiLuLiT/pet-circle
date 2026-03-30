import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/stores/notification_store.dart';

AppNotification _makeNotification({
  String id = 'n-1',
  bool isRead = false,
  String title = 'Measurement Alert',
}) {
  return AppNotification(
    id: id,
    title: title,
    body: 'SRR elevated for Princess',
    type: NotificationType.measurement,
    createdAt: DateTime(2025, 3, 1),
    isRead: isRead,
  );
}

void main() {
  late NotificationStore store;

  setUp(() {
    store = NotificationStore();
  });

  group('NotificationStore seed', () {
    test('seed() populates notifications', () {
      store.seed([
        _makeNotification(),
        _makeNotification(id: 'n-2', title: 'Medication Due'),
      ]);

      expect(store.all.length, 2);
    });

    test('seed() notifies listeners', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed([_makeNotification()]);
      expect(callCount, 1);
    });
  });

  group('NotificationStore unreadCount', () {
    test('unread count is correct', () {
      store.seed([
        _makeNotification(id: 'n-1', isRead: false),
        _makeNotification(id: 'n-2', isRead: true),
        _makeNotification(id: 'n-3', isRead: false),
      ]);

      expect(store.unreadCount, 2);
    });

    test('unread count is zero when all read', () {
      store.seed([
        _makeNotification(id: 'n-1', isRead: true),
        _makeNotification(id: 'n-2', isRead: true),
      ]);

      expect(store.unreadCount, 0);
    });

    test('unread getter returns only unread notifications', () {
      store.seed([
        _makeNotification(id: 'n-1', isRead: false),
        _makeNotification(id: 'n-2', isRead: true),
      ]);

      expect(store.unread.length, 1);
      expect(store.unread.first.id, 'n-1');
    });
  });

  group('NotificationStore markRead', () {
    test('marking a notification as read decreases unread count', () async {
      store.seed([
        _makeNotification(id: 'n-1', isRead: false),
        _makeNotification(id: 'n-2', isRead: false),
      ]);

      expect(store.unreadCount, 2);

      // markRead calls Firebase when kEnableFirebase is true, but userStore
      // has no currentUserUid so the Firebase path is skipped.
      await store.markRead('n-1');

      expect(store.unreadCount, 1);
      expect(store.all.firstWhere((n) => n.id == 'n-1').isRead, isTrue);
    });

    test('marking already-read notification does not change count', () async {
      store.seed([
        _makeNotification(id: 'n-1', isRead: true),
      ]);

      await store.markRead('n-1');
      expect(store.unreadCount, 0);
    });
  });

  group('NotificationStore markAllRead', () {
    test('markAllRead marks all notifications as read', () async {
      store.seed([
        _makeNotification(id: 'n-1', isRead: false),
        _makeNotification(id: 'n-2', isRead: false),
      ]);

      await store.markAllRead();

      expect(store.unreadCount, 0);
      expect(store.all.every((n) => n.isRead), isTrue);
    });
  });

  group('NotificationStore reset', () {
    test('reset clears all notifications', () {
      store.seed([_makeNotification()]);
      expect(store.all.length, 1);

      store.reset();
      expect(store.all, isEmpty);
    });
  });
}
