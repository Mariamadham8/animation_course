// ============================================================================
// premium_animations_demo.dart
// ----------------------------------------------------------------------------
// 3 famous animations used in "premium" apps, all built on the same idea:
//   a single AnimationController gives us a "time pulse" (0.0 -> 1.0),
//   then we wrap that value with a Tween to turn it into something meaningful
//   (scale / opacity / color), and wrap it with a Curve so the motion isn't
//   linear and feels more natural.
//
// This is the exact same principle we used for AlignTransition, but here we
// use:
//   - ScaleTransition   (instead of AlignTransition) for scaling up/down
//   - FadeTransition    for a gradual appear/disappear
//   - PageRouteBuilder   for a custom animation when navigating between pages
//
// -----------------------------------------------------------------------
// 1) LikeButtonPage — the "Like" animation (like Instagram/Twitter)
// -----------------------------------------------------------------------
// Dynamics: we have a very short AnimationController (300ms). On tap, we
// call controller.forward(from: 0), which drives a TweenSequence<double>
// that scales from 1.0 (normal) -> 1.4 (bump) -> back to 1.0, using
// Curves.easeOut then Curves.elasticIn to get that familiar "pop/bounce"
// feel. The heart color flips between grey/red instantly based on
// isLiked — no Tween needed there since the color change isn't gradual.
//
// -----------------------------------------------------------------------
// 2) SplashPage — the splash screen animation
// -----------------------------------------------------------------------
// Dynamics: a slightly longer AnimationController (1200ms) that starts
// automatically in initState() as soon as the page is built. From it we
// derive two Tween<double>s:
//   - one for opacity (0 -> 1) used in FadeTransition
//   - one for scale (0.7 -> 1) used in ScaleTransition
// Both move together because they're driven by the same controller, so
// there's no need to sync them manually.
//
// -----------------------------------------------------------------------
// 3) Custom Page Transition — the page navigation animation
// -----------------------------------------------------------------------
// Dynamics: instead of the default Navigator.push (which just does a
// plain slide), we use PageRouteBuilder and provide our own
// transitionsBuilder. Flutter hands us a ready-made Animation<double>
// called "animation" (0 -> 1 as the transition plays), and we simply
// wrap it with FadeTransition + SlideTransition. There's no manual
// AnimationController here because the Navigator manages one for us
// under the hood.
// ============================================================================

import 'package:flutter/material.dart';

// ----------------------------------------------------------------------------
// Entry widget: opens the different demos using the custom page transition
// ----------------------------------------------------------------------------
class AnimDemoHub extends StatelessWidget {
  const AnimDemoHub({super.key});

  // Shared helper that opens any page with a simple fade + slide instead
  // of the default transition
  void _openWithFadeSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(fade);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Animations Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () =>
                  _openWithFadeSlide(context, const LikeButtonPage()),
              child: const Text('Like Button Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openWithFadeSlide(context, const SplashPage()),
              child: const Text('Splash Screen Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// 1) Like Button — bounce + color change
// ----------------------------------------------------------------------------
class LikeButtonPage extends StatefulWidget {
  const LikeButtonPage({super.key});

  @override
  State<LikeButtonPage> createState() => _LikeButtonPageState();
}

class _LikeButtonPageState extends State<LikeButtonPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 1.0 (normal size) -> 1.4 (bump) -> back to 1.0, with a "bouncy" curve
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  void _handleTap() {
    setState(() => _isLiked = !_isLiked);
    _controller.forward(from: 0); // replay the bounce on every tap
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Like Button')),
      body: Center(
        child: GestureDetector(
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scale,
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// 2) Splash Screen — fade + scale for the logo
// ----------------------------------------------------------------------------
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(); // starts automatically as soon as the page opens
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'MyApp',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _controller.forward(from: 0),
        label: const Text('Replay'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
