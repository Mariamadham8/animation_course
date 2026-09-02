// ============================================================================
// record_button_demo.dart
// ----------------------------------------------------------------------------
// Real use case: a "hold to record" mic button (WhatsApp / Instagram style).
//
// While the user holds the button, a ring pulses around the mic icon. When
// they release, we want the pulse to stop at a CLEAN point (end of a
// breathing cycle), not freeze mid-scale — that looks broken.
//
// This is exactly why AnimationStatus matters here:
//   - We do NOT use controller.repeat() + controller.stop(), because
//     stop() can cut the animation at any random frame.
//   - Instead we manually chain forward() -> reverse() -> forward() ...
//     ourselves, and after EVERY leg finishes (status == completed or
//     status == dismissed) we check "are we still recording?":
//       * yes -> start the next leg (keep pulsing)
//       * no  -> do nothing (animation naturally stops at 0.0 or 1.0,
//                a clean resting position instead of a random one)
// ============================================================================

import 'package:flutter/material.dart';

class RecordButtonDemo extends StatefulWidget {
  const RecordButtonDemo({super.key});

  @override
  State<RecordButtonDemo> createState() => _RecordButtonDemoState();
}

class _RecordButtonDemoState extends State<RecordButtonDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // The pulse ring grows and fades out as it expands outward.
    _ringScale = Tween<double>(
      begin: 1.0,
      end: 1.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      // A "leg" just finished (either the forward 0->1 leg, or the
      // reverse 1->0 leg). Decide whether to keep pulsing.
      final legJustFinished =
          status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed;

      if (legJustFinished && _isRecording) {
        // Still holding the button -> play the opposite direction to
        // start the next pulse cycle.
        status == AnimationStatus.completed
            ? _controller.reverse()
            : _controller.forward();
      }
      // If not recording anymore, we simply don't start the next leg —
      // the animation rests at 0.0 or 1.0, never mid-pulse.
    });
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _controller.forward(); // kicks off the first pulse leg
  }

  void _stopRecording() {
    // Note: we don't touch the controller here at all. The status
    // listener above will let the current leg finish on its own, then
    // see _isRecording == false and simply stop chaining more legs.
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Button')),
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopRecording(),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ring — only meaningful while recording, but we
                // leave it wired to the controller's current value always.
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _ringOpacity.value,
                      child: Transform.scale(
                        scale: _ringScale.value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // The mic button itself — turns red while recording.
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.blueGrey,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/////
