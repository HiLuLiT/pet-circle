# Architecture Decision Records

Architectural decisions for the Pet Circle Flutter app, recorded as they were made. See [template.md](template.md) for creating new ADRs.

## Technology Choices

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-flutter-cross-platform.md) | Flutter as cross-platform framework | accepted | 2026-01-15 |
| [0002](0002-firebase-backend.md) | Firebase as backend (Auth + Firestore) | accepted | 2026-01-20 |
| [0006](0006-instrument-sans-font.md) | Instrument Sans typography | accepted | 2026-03-20 |
| [0009](0009-multi-provider-auth.md) | Multi-provider auth (Email + Google + Apple) | accepted | 2026-01-20 |
| [0016](0016-app-links-deep-linking.md) | app_links for native deep links | accepted | 2026-03-15 |
| [0021](0021-fl-chart.md) | fl_chart for SRR trends (not Syncfusion) | accepted | 2026-01-20 |
| [0023](0023-firebase-analytics.md) | Firebase Analytics with GoRouter observer | accepted | 2026-03-25 |
| [0027](0027-ui-avatars-fallback.md) | UI Avatars API for avatar fallback | accepted | 2026-02-15 |
| [0034](0034-flutter-lints.md) | flutter_lints default ruleset | accepted | 2026-01-15 |

## Architecture

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0003](0003-changenotifier-stores.md) | ChangeNotifier global singleton stores | accepted | 2026-03-01 |
| [0004](0004-gorouter-navigation.md) | GoRouter declarative URL-based navigation | accepted | 2026-03-15 |
| [0005](0005-design-token-architecture.md) | 3-layer design token architecture | accepted | 2026-03-20 |
| [0010](0010-auth-route-state-machine.md) | 6-state auth route machine | accepted | 2026-04-01 |
| [0011](0011-immutable-models.md) | Immutable models with copyWith | accepted | 2026-03-01 |
| [0014](0014-token-based-invitations.md) | Token-based deep link invitation system | accepted | 2026-03-15 |
| [0015](0015-abstract-reminder-service.md) | Abstract service pattern for platform abstraction | accepted | 2026-03-15 |
| [0017](0017-flutter-localizations-arb.md) | flutter_localizations with ARB (EN + HE, RTL) | accepted | 2026-02-15 |
| [0018](0018-valuenotifier-dark-mode.md) | ValueNotifier dark mode | accepted | 2026-02-20 |
| [0019](0019-responsive-navigation.md) | Responsive nav (BottomNavBar vs. NavigationRail) | accepted | 2026-03-20 |
| [0020](0020-five-tab-shell.md) | 5-tab IndexedStack navigation shell | accepted | 2026-03-20 |
| [0022](0022-centralized-error-handler.md) | Centralized AppErrorHandler with Crashlytics | accepted | 2026-03-25 |
| [0024](0024-kenablefirebase-feature-flag.md) | kEnableFirebase compile-time feature flag | accepted | 2026-02-01 |
| [0028](0028-firestore-notifications.md) | Firestore in-app notifications (FCM deferred) | accepted | 2026-03-20 |
| [0029](0029-optimistic-updates.md) | Optimistic updates with rollback | accepted | 2026-03-25 |
| [0032](0032-platform-capabilities.md) | PlatformCapabilities abstraction | accepted | 2026-03-20 |
| [0035](0035-two-tier-role-system.md) | Two-tier role system (app-level + per-pet) | accepted | 2026-03-10 |

## Design

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0007](0007-purple-brand-color.md) | Purple brand color (#6B4EFF) | accepted | 2026-03-20 |
| [0008](0008-flat-shadows.md) | Flat shadows replacing neumorphism | accepted | 2026-03-20 |

## Data & Security

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0012](0012-firestore-care-circle-schema.md) | Firestore care circle schema (Map + memberUids) | accepted | 2026-03-10 |
| [0013](0013-firestore-security-rules.md) | Security rules-enforced access control | accepted | 2026-03-10 |
| [0025](0025-static-breed-list.md) | Static breed list (no API dependency) | accepted | 2026-01-17 |
| [0026](0026-url-based-pet-photos.md) | URL-based pet photos (Storage deferred) | accepted | 2026-01-20 |

## Testing & Quality

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0030](0030-testing-infrastructure.md) | flutter_test with shared helpers (80% target) | accepted | 2026-03-15 |
| [0031](0031-accessibility-semantics.md) | Explicit semantics labels + RTL alignment | accepted | 2026-03-25 |

## Platform

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0033](0033-macos-minimum-window.md) | macOS minimum window size (800x600) | accepted | 2026-03-20 |
