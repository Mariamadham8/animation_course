import 'package:flutter/material.dart';

class AnimationBuilder extends StatefulWidget {
  const AnimationBuilder({super.key});

  @override
  State<AnimationBuilder> createState() => _AnimationBuilderState();
}

class _AnimationBuilderState extends State<AnimationBuilder>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> animation;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          containerWidget(),
          SizedBox(height: 20),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              contolButtonWidget(() {
                controller.forward();
              }, 'Forward'),
              SizedBox(height: 10),
              contolButtonWidget(() {
                controller.reverse();
              }, 'Reverse'),
              SizedBox(height: 10),
              contolButtonWidget(() {
                controller.stop();
              }, 'Stop'),
            ],
          ),
        ],
      ),
    );
  }

  Widget containerWidget() {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 100,
          height: 100,
          color: animation.value,
          child: Align(alignment: Alignment.center, child: getChildWidget()),
        );
      },
    );
  }

  Widget getChildWidget() {
    return FittedBox(
      child: Text('Hello, World!', style: TextStyle(color: Colors.white)),
    );
  }

  Widget contolButtonWidget(VoidCallback onPressed, String buttonText) {
    return ElevatedButton(onPressed: onPressed, child: Text(buttonText));
  }
}
