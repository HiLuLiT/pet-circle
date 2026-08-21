import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/widgets/app_image.dart';

/// The animated welcome hero: a heart thumping above the dog while the whole
/// picture drifts softly.
///
/// Ported from the Claude Design project "Heart animation for dog"
/// (`Pounding Heart.dc.html` -> `heart-scene.jsx`). The three motion helpers,
/// the layer geometry and every magic number below come from that source, so
/// keep them in sync with it rather than tuning them here.
///
/// To re-sync: `DesignSync get_file` with
/// `projectId: 195022dd-b437-4918-bb96-c2fec727e012`, `path: heart-scene.jsx`,
/// then diff its constants against the ones below. The project does *not*
/// appear in `list_projects` — that method only returns writable design-system
/// projects — so it must be addressed by this ID directly.
///
/// Motion changes are a numbers diff and safe to port. Artwork changes are not:
/// the design exports at 1x, and image bytes cannot round-trip through an
/// agent's context without corruption, so prefer the higher-resolution copy
/// already committed here. See BUG-045.
///
/// Two deliberate departures from the design preview:
///  * The preview's `scale(1.75)` and `translateY(8px)` only sized the artwork
///    to fill its 640x360 preview stage, so they are dropped — here the hero
///    renders at its natural [heroWidth] x [heroHeight].
///  * The preview restarts every 4.2s (`OM_SCENES` declares one 4.2s
///    "Heartbeat" section, `OM_PLAYBACK` is `{"mode":"loop"}`). Restarting a
///    shared clock cannot be seamless here, because the beat, the drift and
///    the dog's breath have periods that share no useful common multiple once
///    [tempo] scales the beat — so each is driven by its own repeating
///    controller instead. See [_beatCycle] and [_slowLoopSeconds].
class PoundingHeartHero extends StatefulWidget {
  const PoundingHeartHero({
    super.key,
    this.pulseStrength = 0.08,
    this.tempo = 0.7,
  });

  /// How far the heart swells on each beat. Range 0.03-0.25.
  ///
  /// The default tracks the `data-props` default in `Pounding Heart.dc.html`,
  /// which is the tuned composition. Note that `heart-scene.jsx`'s own `??`
  /// fallback and the `standalone-src` variant both still say 0.11 — the
  /// authored value lives in the .dc.html's `data-props`, so read it there.
  final double pulseStrength;

  /// Heartbeat speed multiplier. Range 0.5-1.8. Also from the .dc.html
  /// `data-props` default, not the .jsx fallback.
  final double tempo;

  /// Natural size of the composition, from the Figma "Object" layer and
  /// matching the source artwork's 195x174.
  static const double heroWidth = 195;
  static const double heroHeight = 174;

  @override
  State<PoundingHeartHero> createState() => _PoundingHeartHeroState();
}

class _PoundingHeartHeroState extends State<PoundingHeartHero>
    with TickerProviderStateMixin {
  // ── Timing, all from heart-scene.jsx ──────────────────────────────────────

  /// One heartbeat cycle.
  static const double _period = 1.4;

  /// Slow vertical float of the whole picture.
  static const double _driftPeriod = 6.2;
  static const double _driftAmp = 2.2;

  /// The dog's breathing — a barely-there swell.
  static const double _breathPeriod = 4.2;
  static const double _breathAmp = 0.004;

  /// Loop length for the slow motion: the LCM of the drift and breath periods,
  /// so both complete a whole number of cycles (21 and 31) and the wrap is
  /// exact rather than merely small.
  static const double _slowLoopSeconds = 130.2;

  /// One heartbeat in wall-clock seconds. [PoundingHeartHero.tempo] scales the
  /// beat and nothing else, so it belongs in this clock's period rather than
  /// inside the phase maths — that way the controller wraps exactly on a beat
  /// boundary at any tempo.
  Duration get _beatCycle =>
      Duration(microseconds: (_period / widget.tempo * 1e6).round());

  /// Drives the heartbeat. Wraps at phase 1.0, where both thumps have long
  /// since ended (they finish at 0.4), so the heart is at rest across the cut.
  ///
  /// This used to be one 4.2s controller for everything, on the reasoning that
  /// 4.2s is exactly three 1.4s beats. That holds only at `tempo == 1`. At the
  /// authored tempo of 0.7 a beat lasts 2.0s, so 4.2s is 2.1 beats and the
  /// wrap landed at phase 0.0995 — 89% up the first thump, snapping the heart
  /// from +7% swell and -4.4px of lift straight back to rest. See BUG-047.
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: _beatCycle,
  );

  /// Drives the drift and the dog's breath, which [PoundingHeartHero.tempo]
  /// does not affect.
  late final AnimationController _slow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130200), // _slowLoopSeconds
  );

  /// Platform reduce-motion. Read here rather than in [build] so the ticker
  /// can actually be stopped — leaving it running would keep scheduling
  /// frames for an animation nobody sees.
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    for (final c in [_beat, _slow]) {
      if (_reduceMotion) {
        c.stop();
      } else if (!c.isAnimating) {
        c.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(PoundingHeartHero old) {
    super.didUpdateWidget(old);
    if (widget.tempo == old.tempo) return;
    // Re-period the beat in place: `repeat()` reads `duration` when it starts,
    // so a running controller would otherwise keep the old tempo forever.
    _beat.duration = _beatCycle;
    if (!_reduceMotion) _beat.repeat();
  }

  @override
  void dispose() {
    _beat.dispose();
    _slow.dispose();
    super.dispose();
  }

  // ── The three motion helpers, ported verbatim ─────────────────────────────

  /// A single asymmetric thump over [dur], starting at phase [start].
  static double _thump(double p, double start, double dur, double amp) {
    if (p < start || p > start + dur) return 0;
    final u = (p - start) / dur;
    return amp * math.pow(math.sin(math.pi * u), 1.6).toDouble();
  }

  static double _breathe(double t, double period, double amp) =>
      amp * math.sin((t / period) * math.pi * 2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PoundingHeartHero.heroWidth,
      height: PoundingHeartHero.heroHeight,
      // Under reduce-motion, hold the resting frame — which is exactly what
      // t = 0 produces.
      child: _reduceMotion
          ? _frame(beatPhase: 0, slowTime: 0)
          : AnimatedBuilder(
              animation: Listenable.merge([_beat, _slow]),
              builder: (context, _) => _frame(
                beatPhase: _beat.value,
                slowTime: _slow.value * _slowLoopSeconds,
              ),
            ),
    );
  }

  /// [beatPhase] is 0..1 through one heartbeat; [slowTime] is seconds through
  /// the slow loop. They advance on separate clocks — see [_beat] and [_slow].
  Widget _frame({required double beatPhase, required double slowTime}) {
    // Lub-dub: a full thump, then a half-strength one just behind it.
    final beat =
        _thump(beatPhase, 0, 0.16, 1) + _thump(beatPhase, 0.2, 0.2, 0.5);

    final scale = 1 + widget.pulseStrength * beat;
    final lift = -5 * beat;
    final glow = 0.1 + 0.28 * beat;
    final drift = _breathe(slowTime, _driftPeriod, _driftAmp);
    final dogBreath = 1 + _breathe(slowTime, _breathPeriod, _breathAmp);

    return Transform.translate(
      offset: Offset(0, drift * 0.3),
      child: Stack(
        // The heart's glow is a blurred copy that spreads well past the
        // layer's own bounds, so it must be free to paint outside these.
        clipBehavior: Clip.none,
        children: [
          Transform.scale(
            scale: dogBreath,
            alignment: Alignment.bottomCenter,
            child: AppImage.asset(
              AppAssets.welcomeDogLayer,
              width: PoundingHeartHero.heroWidth,
              height: PoundingHeartHero.heroHeight,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 131,
            top: 6,
            width: _heartSize,
            height: _heartSize,
            child: Transform.translate(
              offset: Offset(0, lift + drift),
              child: Transform.scale(
                // transformOrigin: 50% 58% in the source. Flutter's Alignment
                // y maps as 2 * fraction - 1, so 0.58 -> 0.16.
                scale: scale,
                alignment: const Alignment(0, 0.16),
                child: _Heart(beat: beat, glow: glow),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rendered size of the heart layer, from `heart-scene.jsx`.
  ///
  /// `welcome_heart.png` is the matching 29x29 export, so this paints 1:1.
  ///
  /// The earlier 43x43 asset was NOT merely a larger version of this one — it
  /// was a different drawing (49% opaque coverage and a pale #E5A1A3 average,
  /// versus 65% and a saturated #D8696C here). Keeping it "for the extra
  /// density" silently shipped the wrong artwork. Compare pixels, not
  /// dimensions, before deciding an asset is redundant.
  ///
  /// This does mean the heart is 1x. A 2x/3x export from the design project is
  /// the outstanding fix; do not substitute an older asset for it.
  static const double _heartSize = 29;
}

/// The heart plus its pulsing glow.
///
/// The design uses `drop-shadow(0 0 Npx rgba(...))`, which follows the
/// artwork's alpha rather than its bounding box — so this paints a blurred,
/// tinted copy of the heart behind the heart itself instead of a [BoxShadow].
class _Heart extends StatelessWidget {
  const _Heart({required this.beat, required this.glow});

  final double beat;
  final double glow;

  @override
  Widget build(BuildContext context) {
    // CSS blur radius r corresponds to a Gaussian sigma of r / 2.
    final sigma = (5 + 7 * beat) / 2;

    const heart = AppImage.asset(
      AppAssets.welcomeHeartLayer,
      width: _PoundingHeartHeroState._heartSize,
      height: _PoundingHeartHeroState._heartSize,
      fit: BoxFit.contain,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppPrimitives.pcHeartGlow.withValues(alpha: glow),
              BlendMode.srcATop,
            ),
            child: heart,
          ),
        ),
        heart,
      ],
    );
  }
}
