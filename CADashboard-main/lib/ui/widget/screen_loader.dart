import 'package:cadashboard/core/common/common_loader.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class ScreenLoader extends StatefulWidget {
  final bool loading;
  final Widget child;
  const ScreenLoader({super.key, required this.loading, required this.child});

  @override
  State<ScreenLoader> createState() => _ScreenLoaderState();
}

class _ScreenLoaderState extends State<ScreenLoader> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if(widget.loading == true)Center(
          child: Container(
            height: height,
            alignment: Alignment.center,
            color: Colors.black.withValues(alpha: 0.08),
            child: Container(
              height: 50, width: 50,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle
              ),
              child: CommonLoader(),
            ),
          ),
        ),
      ],
    );
  }
}
