import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TextFieldOverlay extends StatefulWidget {
  const TextFieldOverlay({Key? key}) : super(key: key);

  @override
  State<TextFieldOverlay> createState() => _TextFieldOverlayState();
}

class _TextFieldOverlayState extends State<TextFieldOverlay> {
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
          await FlutterOverlayWindow.updateFlag(OverlayFlag.focusPointer);
        } else {
          await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
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
