import 'package:flutter/material.dart';

class FooTransitionBasics extends StatefulWidget {
  const FooTransitionBasics({super.key});

  @override
  State<FooTransitionBasics> createState() => _FooTransitionBasicsState();
}

class _FooTransitionBasicsState extends State<FooTransitionBasics>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<AlignmentGeometry> _redAlignment;
  late final Animation<AlignmentGeometry> _blackAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _redAlignment = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(_controller);

    _blackAlignment = Tween<AlignmentGeometry>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Red ball gets the full screen height to travel through,
          // independent of the Column's other children.
          Positioned.fill(child: animatedBall(Colors.red, _redAlignment)),
          Column(
            children: [
              animatedBall(Colors.black, _blackAlignment),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionButton('Move', () => _controller.forward()),
                  const SizedBox(width: 10),
                  actionButton('Reset', () => _controller.reset()),
                  const SizedBox(width: 10),
                  actionButton('Forward', () => _controller.forward()),
                  const SizedBox(width: 10),
                  actionButton('Stop', () => _controller.stop()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionButton(
                    'Repeat/rev:F',
                    () => _controller.repeat(reverse: false),
                  ),
                  const SizedBox(width: 10),
                  actionButton(
                    'Repeat/rev:T',
                    () => _controller.repeat(reverse: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget animatedBall(Color color, Animation<AlignmentGeometry> alignment) {
  return AlignTransition(
    alignment: alignment,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}

Widget actionButton(String text, VoidCallback onPressed) {
  return FloatingActionButton(onPressed: onPressed, child: Text(text));
}
