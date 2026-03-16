import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  final double size;
  const GreetingWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning!';
    } else if (hour < 18) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    return Text(
      greeting,
      style: TextStyle(
        fontSize:size,
      ),
    );
  }
}
