import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/messages/messages_screen.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/stores/notification_store.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('MessagesScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const MessagesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MessagesScreen), findsOneWidget);
    });

    testWidgets('shows notifications title', (tester) async {
      await tester.pumpWidget(testApp(const MessagesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows unread count text', (tester) async {
      await tester.pumpWidget(testApp(const MessagesScreen()));
      await tester.pumpAndSettle();

      // With empty notification store, unread count is 0
      expect(find.textContaining('unread'), findsOneWidget);
    });

    testWidgets('displays notification cards when notifications exist',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Seed a notification via seed() to avoid Firebase dependency
      notificationStore.seed([
        AppNotification(
          id: 'test-notif-1',
          title: 'Test Notification',
          body: 'This is a test notification body',
          type: NotificationType.measurement,
          createdAt: DateTime.now(),
          petName: 'Princess',
        ),
      ]);

      await tester.pumpWidget(testApp(const MessagesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Test Notification'), findsOneWidget);
      expect(
          find.text('This is a test notification body'), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (tester) async {
      await tester.pumpWidget(testApp(const MessagesScreen()));
      await tester.pumpAndSettle();

      // No notification cards should be present
      expect(find.byIcon(Icons.medication), findsNothing);
      expect(find.byIcon(Icons.monitor_heart), findsNothing);
    });
  });
}
