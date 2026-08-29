//TWeen is a generic class
//The object of the Tween class is to define a range of values between a beginning and an end value. It is used in animations to interpolate between these two values over time. The Tween class takes two parameters: begin and end, which represent the starting and ending values of the animation. The lerp method is used to calculate the interpolated value based on a given t value, which ranges from 0.0 to 1.0. When t is 0.0, the result will be the begin value, and when t is 1.0, the result will be the end value. For values of t between 0.0 and 1.0, the result will be a value that is proportionally between begin and end.
/*
how it works :

class Tween<T> {
  final T begin;
  final T end;

  Tween({required this.begin, required this.end});

  T lerp(double t) {
    // Interpolate between begin and end based on t (0.0 to 1.0)
    return begin + (end - begin) * t;
  }
}
*/

//Note
//we get to use the subclass of Tween like IntTween,ColorTween if the value matched an existed class if not use the generic class Tween<T> to create a custom tween for your specific type.

import 'package:flutter/material.dart';

class CounterAnimation extends StatefulWidget {
  const CounterAnimation({super.key});

  @override
  State<CounterAnimation> createState() => _CounterAnimationState();
}

class _CounterAnimationState extends State<CounterAnimation> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        //We can use TweenAnimationBuilder to animate the value of a counter from 0 to 100 over a duration of 2 seconds.sence we dont have animatedText widget we can use TweenAnimationBuilder to animate the value of a counter from 0 to 100 over a duration of 2 seconds. 
        child: TweenAnimationBuilder( 
          tween: IntTween(begin:0 ,end: 100), 
          duration: const Duration(seconds:2),

          //NOTE :Widget Child Rebuilds Issue!!!!!!!!
          // child:Container child ,
          //when the tween rebuild the returned widget the child also rebuild
          //so we can use atrubite child in the TweenAnimation to be the child of the returned widget and it will not rebuild when the tween rebuilds 


           builder: (context, value, child) {
            
            return Text(value.toString(), style: const TextStyle(fontWeight:FontWeight.bold ,fontSize: 100),);
            //say we have container widget and it gets a child we dont need to rebuilf it each time the container rebuilds simply takes the copy in tween child
           } 
        ),
      ),
    );
  }
}