import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/settings/settings_widgets.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

import '../../helpers/helpers.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ---------------------------------------------------------------------------
  // SettingsCard
  // ---------------------------------------------------------------------------
  group('SettingsCard', () {
    testWidgets('renders title and subtitle', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsCard(
          title: 'My Title',
          subtitle: 'My Subtitle',
          child: Text('content'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('My Subtitle'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsCard(
          title: 'Title',
          subtitle: 'Sub',
          trailing: Icon(Icons.add, key: Key('trailing')),
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('does not render trailing widget when null', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsCard(
          title: 'Title',
          subtitle: 'Sub',
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      // No trailing — just verify the card still renders
      expect(find.text('Title'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // SettingsToggleRow
  // ---------------------------------------------------------------------------
  group('SettingsToggleRow', () {
    testWidgets('renders label', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsToggleRow(
          label: 'Dark mode',
          isOn: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dark mode'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsToggleRow(
          label: 'Push notifications',
          description: 'Enable push notifications',
          isOn: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Enable push notifications'), findsOneWidget);
    });

    testWidgets('renders TogglePill', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const SettingsToggleRow(
          label: 'Toggle',
          isOn: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TogglePill), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      suppressOverflowErrors();
      var changed = false;
      await tester.pumpWidget(testApp(
        SettingsToggleRow(
          label: 'Toggle',
          isOn: false,
          onChanged: () => changed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).last);
      expect(changed, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // LanguageRow
  // ---------------------------------------------------------------------------
  group('LanguageRow', () {
    testWidgets('renders language label', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(const LanguageRow()));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('shows English as current language in en locale', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(
        testApp(const LanguageRow(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('English'), findsWidgets);
    });

    testWidgets('opens language picker bottom sheet on tap', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(const LanguageRow()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Bottom sheet should show English and Hebrew options
      expect(find.text('Hebrew'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // ActionRow
  // ---------------------------------------------------------------------------
  group('ActionRow', () {
    testWidgets('renders title and description', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        ActionRow(
          iconAsset: settingsDownAsset,
          title: 'Export All Data',
          description: 'Download complete records',
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Export All Data'), findsOneWidget);
      expect(find.text('Download complete records'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      suppressOverflowErrors();
      var tapped = false;
      await tester.pumpWidget(testApp(
        ActionRow(
          iconAsset: settingsDownAsset,
          title: 'Export',
          description: 'Export data',
          onTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('renders with null onTap without error', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        const ActionRow(
          iconAsset: settingsShareAsset,
          title: 'Share',
          description: 'Share with vet',
          onTap: null,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Share'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // SimpleRow
  // ---------------------------------------------------------------------------
  group('SimpleRow', () {
    testWidgets('renders label', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        SimpleRow(label: 'Terms of Service', onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      suppressOverflowErrors();
      var tapped = false;
      await tester.pumpWidget(testApp(
        SimpleRow(label: 'Privacy Policy', onTap: () => tapped = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy Policy'));
      expect(tapped, isTrue);
    });
  });
}
