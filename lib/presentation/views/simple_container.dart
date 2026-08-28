import 'package:flutter/material.dart';

class AnimatedfooScreen extends StatefulWidget {

  const AnimatedfooScreen({super.key});

  @override
  State<AnimatedfooScreen> createState() => _AnimatedfooScreenState();
}

class _AnimatedfooScreenState extends State<AnimatedfooScreen> {
  bool flag=true;
  @override
  Widget build(BuildContext context) {
     
    return  Scaffold(
      body: Column(
        children:[
            Center(child: ContainerWidget(flag?200:100, flag? 200 :100)),
            Spacer() ,
            ElevatedButton(
              onPressed: (){
                  setState(() { 
                    flag =!flag;
                  });  
              },
              child: Text("animate"),
            ), 
        ]
      ),
    );
  }
}

Widget ContainerWidget(double hieght, double width) {
  return AnimatedContainer(
     decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
              shape: BoxShape.rectangle,
             ),
      height: hieght,
      width: width, duration: Duration(milliseconds: 200),

  );
}