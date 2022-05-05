import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    log("Started listening");
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("$event");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isPermissionGranted();
                log("Is Permission Granted: $status");
              },
              child: const Text("Check Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                log("status: $res");
              },
              child: const Text("Request Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await FlutterOverlayWindow.showOverlay(
                  height: 500,
                  enableDrag: true,
                  overlayTitle: "X-SLAYER",
                  flag: OverlayFlag.flagNotTouchable,
                  alignment: OverlayAlignment.topCenter,
                );

                /// call this instead if you want to test clicks over the overlay

                // await FlutterOverlayWindow.showOverlay(
                //   overlayMessage: "Night vision activated",
                //   flag: OverlayFlag.flagNotTouchable,
                // );
              },
              child: const Text("Show Overlay"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                FlutterOverlayWindow.shareData(jsonEncode({"Hey": "Okay"}));
              },
              child: const Text("Share Data"),
            ),
          ],
        ),
      ),
    );
  }
}
