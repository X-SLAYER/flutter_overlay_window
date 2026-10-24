import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../widgets/demo_section.dart';

class PermissionSection extends StatelessWidget {
  const PermissionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '1. Permission',
      description: 'Grant "Display over other apps" first',
      icon: Icons.verified_user_outlined,
      initiallyExpanded: true,
      actions: [
        DemoAction(
          title: 'Check permission',
          description: 'isPermissionGranted()',
          icon: Icons.search,
          run: (_) => FlutterOverlayWindow.isPermissionGranted(),
        ),
        DemoAction(
          title: 'Request permission',
          description: 'requestPermission() opens system settings',
          icon: Icons.lock_open,
          run: (_) => FlutterOverlayWindow.requestPermission(),
        ),
      ],
    );
  }
}
