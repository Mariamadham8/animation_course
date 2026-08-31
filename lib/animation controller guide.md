# When to Use `AnimationController` in Flutter

`AnimationController` is needed whenever you want **manual control** over an animation: starting it, stopping it, reversing it, repeating it, or syncing it with gestures/state. If you just need a one-off simple animation, Flutter's implicit animation widgets (`AnimatedContainer`, `AnimatedOpacity`, etc.) are enough and you **don't** need a controller.

Below are the main cases where you *should* use `AnimationController`, numbered for reference.

---

## 1. You need to start/stop/reverse the animation manually

If the animation should react to a button tap, a gesture, or some app event (not just a state change), use a controller.

```dart
class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FadeTransition(
        opacity: _controller,
        child: const FlutterLogo(size: 100),
      ),
    );
  }
}
```

---

## 2. You need a looping / repeating animation

Loading spinners, pulsing icons, continuous rotations — anything that repeats forever needs `.repeat()`, which only a controller provides.

```dart
_controller = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 1),
)..repeat();
```

---

## 3. You need to combine multiple animations from one timeline

If several properties (size, color, rotation) should animate together, in sync, from a single source of truth, you drive them all from one controller using `Tween`s.

```dart
final Animation<double> _scale = Tween<double>(begin: 0.5, end: 1.0)
    .animate(_controller);
final Animation<double> _rotation = Tween<double>(begin: 0, end: 6.28)
    .animate(_controller);
```

---

## 4. You need custom curves or non-linear timing

`AnimationController` + `CurvedAnimation` lets you control *how* the animation progresses (easeIn, bounce, elasticOut...), not just the start/end values.

```dart
final Animation<double> _curved = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);
```

---

## 5. You need to sync animation with a gesture (drag, swipe)

Dismissible cards, drawer swipes, drag-to-reveal — the controller's `value` is updated manually as the user drags, then `.forward()`/`.reverse()`/`.fling()` finishes it.

```dart
onPanUpdate: (details) {
  _controller.value += details.delta.dx / context.size!.width;
},
onPanEnd: (details) {
  if (_controller.value > 0.5) {
    _controller.forward();
  } else {
    _controller.reverse();
  }
},
```

---

## 6. You need to listen to animation status (completed, dismissed...)

If other logic depends on knowing *when* the animation finishes (e.g., navigate after a fade-out), use `addStatusListener`.

```dart
_controller.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    Navigator.pop(context);
  }
});
```

---

## 7. You need a `StatefulWidget` with `TickerProvider` anyway (complex custom widgets)

Custom reusable animated widgets/packages almost always expose their own controller so the parent can control timing precisely — this is the standard pattern for building animation libraries.

---

## When you DON'T need `AnimationController`

| Situation | Use instead |
|---|---|
| Animate a value when state changes (one-shot) | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, etc. |
| Simple show/hide transition | `AnimatedSwitcher` |
| Animate between two widgets | `AnimatedCrossFade` |
| List item insert/remove animation | `AnimatedList` |

---

### Quick rule of thumb
> If the animation is **implicit** (triggered by rebuilding with a new value) → use `Animated*` widgets.
> If you need **explicit control** over play/pause/reverse/repeat/curves/gesture-sync → use `AnimationController`.