# ADR-0021: fl_chart for SRR Trends (Not Syncfusion)

**Date**: 2026-01-20
**Status**: accepted
**Deciders**: Project team

## Context

The app needs line charts for displaying Sleeping Respiratory Rate trends over time. The PRD mentioned Syncfusion Flutter Charts, but a charting library needed to be selected for the actual implementation.

## Decision

Use `fl_chart ^0.69.0` for the SRR trends line chart.

## Alternatives Considered

### Alternative 1: Syncfusion Flutter Charts
- **Pros**: Feature-rich, professional charts, good documentation
- **Cons**: Commercial license required for production use (community tier has restrictions)
- **Why not**: `fl_chart` is MIT-licensed with no per-app commercial licensing; the PRD reference to Syncfusion was an early plan that wasn't implemented

### Alternative 2: charts_flutter (Google)
- **Pros**: Google-maintained (originally)
- **Cons**: Now community-maintained, less active development
- **Why not**: `fl_chart` has more active maintenance and better customization options

### Alternative 3: Custom Canvas painting
- **Pros**: Full control, no dependencies
- **Cons**: Enormous effort for basic chart features (axes, legends, touch interactions)
- **Why not**: Not worth the development time for standard line charts

## Consequences

### Positive
- MIT license — no commercial restrictions
- Customizable line, bar, pie, scatter charts
- Good Flutter integration with gesture handling
- Active community maintenance

### Negative
- Less feature-rich than Syncfusion for advanced chart types
- CLAUDE.md still references Syncfusion (documentation lag)

### Risks
- None significant for the current charting needs
