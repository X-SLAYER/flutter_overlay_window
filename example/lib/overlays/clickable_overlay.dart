import 'package:flutter/material.dart';

class ClickableOverlay extends StatefulWidget {
  const ClickableOverlay({Key? key}) : super(key: key);

  @override
  State<ClickableOverlay> createState() => _ClickableOverlayState();
}

class _ClickableOverlayState extends State<ClickableOverlay> {
  Color color = const Color(0xFFFFD580);

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
