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
  BoxShape containerShape = BoxShape.rectangle;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log('$event');
      switch (event.toString().toLowerCase()) {
        case 'update':
          FlutterOverlayWindow.updateFlag(OverlayFlag.clickThrough);
          break;
        default:
      }
    });
  }

  Future<void> autoResize() async {
    if (containerShape == BoxShape.rectangle) {
      await FlutterOverlayWindow.resizeOverlay(
          (MediaQuery.of(context).size.width * .45).toInt(),
          (MediaQuery.of(context).size.height * .45).toInt());
      setState(() {
        containerShape = BoxShape.circle;
      });
    } else {
      await FlutterOverlayWindow.resizeOverlay(matchParent, matchParent);
      setState(() {
        containerShape = BoxShape.rectangle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          // await autoResize();
          FlutterOverlayWindow.closeOverlay();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: color.withOpacity(0.25), shape: containerShape),
        ),
      ),
    );
  }
}
