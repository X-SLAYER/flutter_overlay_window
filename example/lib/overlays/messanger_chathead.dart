import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);
  BoxShape shape = BoxShape.rectangle;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event == 'HEY') {
        // setState(() {
        //  Update Timer
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          if (shape == BoxShape.circle) {
            await FlutterOverlayWindow.resizeOverlay(matchParent, matchParent);
            setState(() {
              shape = BoxShape.rectangle;
            });
          } else {
            await FlutterOverlayWindow.resizeOverlay(150, 150);
            setState(() {
              shape = BoxShape.circle;
            });
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: color, shape: shape),
          child: const Center(
            child: FlutterLogo(),
          ),
        ),
      ),
    );
  }
}
