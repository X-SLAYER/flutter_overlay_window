import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);
  BoxShape containerShape = BoxShape.rectangle;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
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
      await FlutterOverlayWindow.resizeOverlay(130, 130);
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
          await autoResize();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: color, shape: containerShape),
          child: const Center(
            child: FlutterLogo(),
          ),
        ),
      ),
    );
  }
}
