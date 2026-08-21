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
/// Two deliberate departures from the design preview:
///  * The preview's `scale(1.75)` and `translateY(8px)` only sized the artwork
///    to fill its 640x360 preview stage, so they are dropped — here the hero
///    renders at its natural [heroWidth] x [heroHeight].
///  * The preview loops authored time over the 4.2s scene, which snaps the
///    6.2s drift mid-cycle. This runs time continuously instead (see
///    [_loopSeconds]), so the drift stays smooth forever.
class PoundingHeartHero extends StatefulWidget {
  const PoundingHeartHero({
    super.key,
    this.pulseStrength = 0.11,
    this.tempo = 1.0,
  });

  /// How far the heart swells on each beat. The design exposes this as a
  /// 0.03-0.25 range with 0.11 as the default.
  final double pulseStrength;

  /// Heartbeat speed multiplier. Design range 0.5-1.8, default 1.
  final double tempo;

  /// Natural size of the composition, from the Figma "Object" layer and
  /// matching the source artwork's 195x174.
  static const double heroWidth = 195;
  static const double heroHeight = 174;

  @override
  State<PoundingHeartHero> createState() => _PoundingHeartHeroState();
}

class _PoundingHeartHeroState extends State<PoundingHeartHero>
    with SingleTickerProviderStateMixin {
  // ── Timing, all from heart-scene.jsx ──────────────────────────────────────

  /// One heartbeat cycle.
  static const double _period = 1.4;

  /// Slow vertical float of the whole picture.
  static const double _driftPeriod = 6.2;
  static const double _driftAmp = 2.2;

  /// The dog's breathing — a barely-there swell.
  static const double _breathPeriod = 4.2;
  static const double _breathAmp = 0.004;

  /// Lowest common multiple of the three periods above (1.4 = 7/5,
  /// 6.2 = 31/5, 4.2 = 21/5, so lcm(7,31,21)/5 = 651/5). Looping the ticker
  /// over exactly this span makes every oscillator seamless at the wrap.
  static const double _loopSeconds = 130.2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130200), // _loopSeconds
  );

  /// Platform reduce-motion. Read here rather than in [build] so the ticker
  /// can actually be stopped — leaving it running would keep scheduling
  /// frames for an animation nobody sees.
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
          ? _frame(0)
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _frame(_controller.value * _loopSeconds),
            ),
    );
  }

  Widget _frame(double t) {
    final p = ((t * widget.tempo) % _period) / _period;

    // Lub-dub: a full thump, then a half-strength one just behind it.
    final beat = _thump(p, 0, 0.16, 1) + _thump(p, 0.2, 0.2, 0.5);

    final scale = 1 + widget.pulseStrength * beat;
    final lift = -5 * beat;
    final glow = 0.1 + 0.28 * beat;
    final drift = _breathe(t, _driftPeriod, _driftAmp);
    final dogBreath = 1 + _breathe(t, _breathPeriod, _breathAmp);

    return Transform.translate(
      offset: Offset(0, drift * 0.3),
      child: Stack(
        // The heart sits 2px above the box and lifts further on each beat, so
        // it must be free to paint outside these bounds.
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
            left: 125,
            top: -2,
            width: _heartSize,
            height: _heartSize,
            child: Transform.translate(
              offset: Offset(0, lift + drift),
              child: Transform.scale(
                // transformOrigin: 50% 55% in the source.
                scale: scale,
                alignment: const Alignment(0, 0.1),
                child: _Heart(beat: beat, glow: glow),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const double _heartSize = 43;
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
