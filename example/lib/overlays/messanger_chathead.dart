import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {

  BoxShape shape = BoxShape.rectangle;

  bool isExpanded  = false;

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
      child: Scaffold(
        body: GestureDetector(
          onTap: () async {
            if (shape == BoxShape.circle) {
              await FlutterOverlayWindow.resizeOverlay(720, 1200);
              setState(() {
                shape = BoxShape.rectangle;
                isExpanded = !isExpanded;
              });
            } else {
              await FlutterOverlayWindow.resizeOverlay(100, 100);
              setState(() {
                shape = BoxShape.circle;  isExpanded = !isExpanded;
              });
            }
          },
          child:isExpanded? Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Color(0xFF1E1E1E),

                shape: shape),
            child: const Center(
              child: FlutterLogo(),
            ),
          ):Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(shape: shape,color: Color(0xFF1E1E1E)),
            child: const Center(
              child: FlutterLogo(),
            ),
          ),
        ),
      ),
    );
  }
}
