import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window_example/overlay.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void showOverlay() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWindow(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  final status =
                      await FlutterOverlayWindow.isPermissionGranted();
                  log("Is Permission Granted: $status");
                },
                child: const Text("Check Permission"),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () async {
                  final bool? res =
                      await FlutterOverlayWindow.requestPermession();
                  log("status: $res");
                },
                child: const Text("Request Permission"),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () async {
                  await FlutterOverlayWindow.showOverlay();
                },
                child: const Text("Show Overlay"),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
