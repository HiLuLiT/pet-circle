import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_sections.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_widgets.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

import '../../helpers/helpers.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';

/// Standard test size for the pet detail section widgets.
void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Pet _testPet() => petStore.ownerPets.first;

Pet _testPetNoMeasurement() => Pet(
      name: 'Buddy',
      breedAndAge: 'Poodle • 3 years old',
      imageUrl: AppAssets.petPlaceholder,
      statusLabel: 'Normal',
      statusColorHex: AppPrimitives.blueBase.toARGB32(),
      latestMeasurement: Measurement(
        bpm: 0,
        recordedAt: DateTime.now(),
        recordedAtLabel: 'No measurements yet',
      ),
      careCircle: const [],
    );

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ---------------------------------------------------------------------------
  // PetInfoSection
  // ---------------------------------------------------------------------------
  group('PetInfoSection', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetInfoSection(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetInfoSection), findsOneWidget);
    });

    testWidgets('shows latest reading heading', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetInfoSection(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Latest Reading'), findsOneWidget);
    });

    testWidgets('shows BPM value when measurement exists', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      final pet = _testPet();
      await tester.pumpWidget(testApp(PetInfoSection(pet: pet)));
      await tester.pumpAndSettle();

      // The measurement store has seeded data for this pet; BPM should appear.
      expect(find.byType(InfoTile), findsNWidgets(2));
    });

    testWidgets('shows -- when no measurement available', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      final pet = _testPetNoMeasurement();
      await tester.pumpWidget(testApp(PetInfoSection(pet: pet)));
      await tester.pumpAndSettle();

      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('shows bpm label', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetInfoSection(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('BPM'), findsOneWidget);
    });

    testWidgets('shows last measured label', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetInfoSection(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Last Measured'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PetMeasurementHistory
  // ---------------------------------------------------------------------------
  group('PetMeasurementHistory', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetMeasurementHistory(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetMeasurementHistory), findsOneWidget);
    });

    testWidgets('shows measurement history heading', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetMeasurementHistory(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Measurement History'), findsOneWidget);
    });

    testWidgets('shows view graph button', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetMeasurementHistory(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('View Graph'), findsOneWidget);
    });

    testWidgets('shows bar chart visualization area', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetMeasurementHistory(pet: _testPet())));
      await tester.pumpAndSettle();

      // The chart is rendered inside a SizedBox with height 80.
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final chartBox = sizedBoxes.where((b) => b.height == 80.0);
      expect(chartBox, isNotEmpty);
    });

    testWidgets('renders gracefully when pet has no measurements', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      final pet = _testPetNoMeasurement();
      await tester.pumpWidget(testApp(PetMeasurementHistory(pet: pet)));
      await tester.pumpAndSettle();

      expect(find.byType(PetMeasurementHistory), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PetClinicalNotes
  // ---------------------------------------------------------------------------
  group('PetClinicalNotes', () {
    Widget buildNotes({VoidCallback? onAddNote}) {
      final controller = TextEditingController();
      return testApp(
        PetClinicalNotes(
          pet: _testPet(),
          noteController: controller,
          onAddNote: onAddNote ?? () {},
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(buildNotes());
      await tester.pumpAndSettle();

      expect(find.byType(PetClinicalNotes), findsOneWidget);
    });

    testWidgets('shows clinical notes heading', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(buildNotes());
      await tester.pumpAndSettle();

      expect(find.text('Clinical Notes'), findsOneWidget);
    });

    testWidgets('shows add note button', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(buildNotes());
      await tester.pumpAndSettle();

      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('shows seeded notes as NoteCard widgets', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(buildNotes());
      await tester.pumpAndSettle();

      // Mock data seeds 2 notes for Princess.
      expect(find.byType(NoteCard), findsWidgets);
    });

    testWidgets('shows empty state when no notes exist', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      // Use a pet without seeded notes.
      final pet = _testPetNoMeasurement();
      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        PetClinicalNotes(
          pet: pet,
          noteController: controller,
          onAddNote: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No clinical notes yet'), findsOneWidget);
    });

    testWidgets('calls onAddNote callback when button tapped', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      var called = false;
      await tester.pumpWidget(buildNotes(onAddNote: () => called = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Note'));
      await tester.pump();

      expect(called, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // PetCareCircle
  // ---------------------------------------------------------------------------
  group('PetCareCircle', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetCareCircle(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetCareCircle), findsOneWidget);
    });

    testWidgets('shows care circle heading', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(PetCareCircle(pet: _testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Care Circle'), findsOneWidget);
    });

    testWidgets('shows MemberTile for each care circle member', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      final pet = _testPet();
      await tester.pumpWidget(testApp(PetCareCircle(pet: pet)));
      await tester.pumpAndSettle();

      expect(find.byType(MemberTile), findsNWidgets(pet.careCircle.length));
    });

    testWidgets('shows member names', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      final pet = _testPet();
      await tester.pumpWidget(testApp(PetCareCircle(pet: pet)));
      await tester.pumpAndSettle();

      for (final member in pet.careCircle) {
        expect(find.text(member.name), findsOneWidget);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // NoteCard (from pet_detail_widgets.dart)
  // ---------------------------------------------------------------------------
  group('NoteCard', () {
    ClinicalNote _testNote() => ClinicalNote(
          id: 'test-note-1',
          authorName: 'Dr. Test',
          authorAvatarUrl: 'https://example.com/avatar.png',
          content: 'Patient doing well.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );

    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(NoteCard(note: _testNote())));
      await tester.pumpAndSettle();

      expect(find.byType(NoteCard), findsOneWidget);
    });

    testWidgets('shows author name', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(NoteCard(note: _testNote())));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Test'), findsOneWidget);
    });

    testWidgets('shows note content', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(NoteCard(note: _testNote())));
      await tester.pumpAndSettle();

      expect(find.text('Patient doing well.'), findsOneWidget);
    });

    testWidgets('shows time ago text', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(NoteCard(note: _testNote())));
      await tester.pumpAndSettle();

      expect(find.textContaining('hour'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MemberTile (from pet_detail_widgets.dart)
  // ---------------------------------------------------------------------------
  group('MemberTile', () {
    const _ownerMember = CareCircleMember(
      name: 'Alice',
      avatarUrl: 'https://example.com/alice.png',
      role: CareCircleRole.owner,
    );

    const _regularMember = CareCircleMember(
      name: 'Bob',
      avatarUrl: 'https://example.com/bob.png',
      role: CareCircleRole.member,
    );

    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(const MemberTile(member: _ownerMember)));
      await tester.pumpAndSettle();

      expect(find.byType(MemberTile), findsOneWidget);
    });

    testWidgets('shows member name', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(const MemberTile(member: _ownerMember)));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows Owner role badge for owner', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(const MemberTile(member: _ownerMember)));
      await tester.pumpAndSettle();

      expect(find.byType(RoleBadge), findsOneWidget);
      // 'Owner' appears in the role label column and in the badge — both OK.
      expect(find.text('Owner'), findsWidgets);
    });

    testWidgets('shows Member role badge for member', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(const MemberTile(member: _regularMember)));
      await tester.pumpAndSettle();

      expect(find.byType(RoleBadge), findsOneWidget);
      // 'Member' appears in the role label column and in the badge — both OK.
      expect(find.text('Member'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // InfoTile (from pet_detail_widgets.dart)
  // ---------------------------------------------------------------------------
  group('InfoTile', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(InfoTile(
        icon: Icons.favorite,
        iconColor: Colors.red,
        value: '22',
        label: 'BPM',
      )));
      await tester.pumpAndSettle();

      expect(find.byType(InfoTile), findsOneWidget);
    });

    testWidgets('shows value text', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(InfoTile(
        icon: Icons.favorite,
        iconColor: Colors.red,
        value: '22',
        label: 'BPM',
      )));
      await tester.pumpAndSettle();

      expect(find.text('22'), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(InfoTile(
        icon: Icons.favorite,
        iconColor: Colors.red,
        value: '22',
        label: 'BPM',
      )));
      await tester.pumpAndSettle();

      expect(find.text('BPM'), findsOneWidget);
    });

    testWidgets('shows icon', (tester) async {
      suppressOverflowErrors();
      _setPhoneSize(tester);

      await tester.pumpWidget(testApp(InfoTile(
        icon: Icons.favorite,
        iconColor: Colors.red,
        value: '22',
        label: 'BPM',
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
