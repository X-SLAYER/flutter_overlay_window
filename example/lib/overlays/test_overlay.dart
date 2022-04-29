import 'package:flutter/material.dart';

class TestOverlay extends StatefulWidget {
  const TestOverlay({Key? key}) : super(key: key);

  @override
  State<TestOverlay> createState() => _TestOverlayState();
}

class _TestOverlayState extends State<TestOverlay> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: TextField(),
        ),
      ),
    );
  }
}
