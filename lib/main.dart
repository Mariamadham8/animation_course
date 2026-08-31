import 'package:animation_corse/presentation/tween_animation_screen.dart';
import 'package:animation_corse/presentation/views/foo_transition_basics.dart';
import 'package:animation_corse/presentation/views/simple_container.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animation',
      debugShowCheckedModeBanner: false,
      home: const FooTransitionBasics(),
      //const CounterAnimation(),
      //const AnimatedfooScreen(),
    );
  }
}
