import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWindow extends StatefulWidget {
  const OverlayWindow({Key? key}) : super(key: key);

  @override
  State<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindow> {
  Color color = const Color(0xFFFFD580);

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("Current Event: $event");
      setState(() {
        color = Colors.red;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: color.withOpacity(0.10),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hello am an overlay"),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      await FlutterOverlayWindow.closeOverlay();
                    },
                    child: const Text("Close Me"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await FlutterOverlayWindow.shareData(
                          "Hello from the other side");
                    },
                    child: const Text("Send data"),
                  ),
                  const TextField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
