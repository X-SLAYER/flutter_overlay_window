import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class ClickableOverlay extends StatefulWidget {
  const ClickableOverlay({Key? key}) : super(key: key);

  @override
  State<ClickableOverlay> createState() => _ClickableOverlayState();
}

class _ClickableOverlayState extends State<ClickableOverlay> {
  Color color = const Color(0xFFD69132);

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log('$event');
      switch (event.toString().toLowerCase()) {
        case 'share':
          FlutterOverlayWindow.updateFlag(OverlayFlag.clickThrough);
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: color.withOpacity(0.25),
      ),
    );
  }
}
