import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window/overlay_config.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);
  BoxShape _currentShape = BoxShape.rectangle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          if (_currentShape == BoxShape.rectangle) {
            await FlutterOverlayWindow.resizeOverlay(50, 100);
            setState(() {
              _currentShape = BoxShape.circle;
            });
          } else {
            await FlutterOverlayWindow.resizeOverlay(
              WindowSize.fullCover,
              WindowSize.fullCover,
            );
            setState(() {
              _currentShape = BoxShape.rectangle;
            });
          }
        },
        child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
              shape: _currentShape,
            ),
            child: const Center(
              child: FlutterLogo(),
            )),
      ),
    );
  }
}
