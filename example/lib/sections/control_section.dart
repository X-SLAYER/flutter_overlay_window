import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../widgets/demo_section.dart';

class ControlSection extends StatelessWidget {
  const ControlSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '3. Visibility & lifecycle',
      description: 'Hide, show or close the running overlay',
      icon: Icons.visibility_outlined,
      actions: [
        DemoAction(
          title: 'Is active?',
          description: 'isActive()',
          icon: Icons.help_outline,
          run: (_) => FlutterOverlayWindow.isActive(),
        ),
        DemoAction(
          title: 'Hide overlay',
          description: 'setOverlayVisible(visible: false), service keeps running',
          icon: Icons.visibility_off_outlined,
          run: (_) => FlutterOverlayWindow.setOverlayVisible(visible: false),
        ),
        DemoAction(
          title: 'Show overlay again',
          description: 'setOverlayVisible(visible: true)',
          icon: Icons.visibility_outlined,
          run: (_) => FlutterOverlayWindow.setOverlayVisible(visible: true),
        ),
        DemoAction(
          title: 'Close overlay',
          description: 'closeOverlay() stops the service',
          icon: Icons.close,
          run: (_) => FlutterOverlayWindow.closeOverlay(),
        ),
      ],
    );
  }
}
