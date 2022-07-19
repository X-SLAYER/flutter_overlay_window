import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
  }

  double convertKwhToAED() {
    const first = 460.00;
    const seconds = 560.00;
    const third = 640.00;
    const total = first + seconds + third;

    double kwh = 1800;
    double result = 0;
    if (kwh >= 6001) {
      result = ((kwh - 6000) * 0.38) + total;
    } else if (kwh >= 2001 && kwh <= 4000) {
      result = ((kwh - 2000) * 0.28) + first;
    } else if (kwh >= 0 && kwh <= 2000) {
      result = kwh * 0.23;
    }
    return result * 0.05;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () async {
          await FlutterOverlayWindow.closeOverlay();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.5), shape: BoxShape.rectangle),
          child: const Center(
            child: FlutterLogo(),
          ),
        ),
      ),
    );
  }
}
