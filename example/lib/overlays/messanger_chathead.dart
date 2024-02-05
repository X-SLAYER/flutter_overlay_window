import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  StreamSubscription<dynamic>? _overlaySubscription;
  Color color = const Color(0xFFFFFFFF);
  BoxShape _currentShape = BoxShape.circle;
  String? messageFromOverlay;

  @override
  void initState() {
    super.initState();
    _overlaySubscription = FlutterOverlayWindow.overlayListener.listen((message) {
      if(!mounted) return;
      setState(() {
        messageFromOverlay = 'message from UI: $message';
      });
    });
  }

  @override
  void dispose() {
    _overlaySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          if (_currentShape == BoxShape.rectangle) {
            await FlutterOverlayWindow.resizeOverlay(50, 100, true);
            setState(() {
              _currentShape = BoxShape.circle;
            });
          } else {
            await FlutterOverlayWindow.resizeOverlay(
              WindowSize.matchParent,
              WindowSize.matchParent,
              false,
            );
            setState(() {
              _currentShape = BoxShape.rectangle;
            });
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: _currentShape,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _currentShape == BoxShape.rectangle
                    ? SizedBox(
                        width: 200.0,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            FlutterOverlayWindow.shareData('Date: ${DateTime.now()}');
                          },
                          child: const Text("Send message to UI"),
                        ),
                      )
                    : const SizedBox.shrink(),
                _currentShape == BoxShape.rectangle
                    ? messageFromOverlay == null
                        ? const FlutterLogo()
                        : Text(messageFromOverlay ?? '')
                    : const FlutterLogo()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
