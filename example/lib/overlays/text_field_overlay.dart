import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TestOverlay extends StatefulWidget {
  const TestOverlay({Key? key}) : super(key: key);

  @override
  State<TestOverlay> createState() => _TestOverlayState();
}

class _TestOverlayState extends State<TestOverlay> {
  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("$event");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) async {
        if (hasFocus) {
          await FlutterOverlayWindow.updateFlag(OverlayFlag.flagNotTouchModal);
        } else {
          await FlutterOverlayWindow.updateFlag(OverlayFlag.flagNotFocusable);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: const [
                TextField(
                  decoration: InputDecoration(hintText: "Write anything"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
