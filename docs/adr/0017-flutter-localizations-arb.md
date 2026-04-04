# ADR-0017: flutter_localizations with ARB Files (EN + HE, RTL)

**Date**: 2026-02-15
**Status**: accepted
**Deciders**: Project team

## Context

The app targets both English and Hebrew-speaking users. Hebrew is a right-to-left (RTL) language, requiring proper bidirectional layout support. All user-visible strings must be translatable.

## Decision

Use Flutter's built-in `flutter_localizations` + `intl` + ARB file workflow. Code generated via `flutter gen-l10n`. Support English and Hebrew with full RTL layout.

## Alternatives Considered

### Alternative 1: easy_localization package
- **Pros**: Hot reload for translations, JSON/YAML support, simpler setup
- **Cons**: Third-party dependency, different API than Flutter's standard
- **Why not**: Flutter's built-in pipeline is officially maintained and generates type-safe classes

### Alternative 2: Hardcoded strings with runtime switching
- **Pros**: No tooling needed
- **Cons**: No type safety, easy to miss strings, no ARB format for translators
- **Why not**: Completely unmaintainable at scale

## Consequences

### Positive
- Type-safe `AppLocalizations` with compile-time string validation
- RTL layout handled automatically by Flutter's `Directionality`
- `flutter gen-l10n` generates code from ARB files
- Locale switched at runtime via `ValueNotifier<Locale>` without app restart

### Negative
- Every new user-visible string requires entries in both `app_en.arb` and `app_he.arb`
- `flutter gen-l10n` must be run after ARB changes (easy to forget)
- ARB format is less human-friendly than JSON/YAML

### Risks
- Missing translations in one locale (mitigated by CLAUDE.md rule requiring both ARB entries)
