import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../widgets/demo_section.dart';

class LayoutSection extends StatelessWidget {
  const LayoutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '4. Size, position & flags',
      description: 'Move, resize and change touch behaviour',
      icon: Icons.open_with,
      actions: [
        DemoAction(
          title: 'Get overlay position',
          description: 'getOverlayPosition()',
          icon: Icons.my_location,
          run: (_) => FlutterOverlayWindow.getOverlayPosition(),
        ),
        DemoAction(
          title: 'Get screen size',
          description: 'getScreenSize() in dp',
          icon: Icons.aspect_ratio,
          run: (_) => FlutterOverlayWindow.getScreenSize(),
        ),
        DemoAction(
          title: 'Move to (0, 0)',
          description: 'moveOverlay()',
          icon: Icons.control_camera,
          run: (_) => FlutterOverlayWindow.moveOverlay(
            const OverlayPosition(0, 0),
          ),
        ),
        DemoAction(
          title: 'Resize to 150 × 150',
          description: 'resizeOverlay(), drag enabled',
          icon: Icons.photo_size_select_small,
          run: (_) => FlutterOverlayWindow.resizeOverlay(150, 150, true),
        ),
        DemoAction(
          title: 'Resize to full width',
          description: 'resizeOverlay(matchParent, 400), drag disabled',
          icon: Icons.width_full_outlined,
          run: (_) => FlutterOverlayWindow.resizeOverlay(
            WindowSize.matchParent,
            400,
            false,
          ),
        ),
        DemoAction(
          title: 'Move + resize at once',
          description: 'updateOverlay() to (0, 0), 200 × 200, no flicker',
          icon: Icons.transform,
          run: (_) => FlutterOverlayWindow.updateOverlay(
            x: 0,
            y: 0,
            width: 200,
            height: 200,
            enableDrag: true,
          ),
        ),
        DemoAction(
          title: 'Flag: click-through',
          description: 'updateFlag(clickThrough), touches pass through',
          icon: Icons.touch_app_outlined,
          run: (_) => FlutterOverlayWindow.updateFlag(OverlayFlag.clickThrough),
        ),
        DemoAction(
          title: 'Flag: focus pointer',
          description: 'updateFlag(focusPointer), allows keyboard input',
          icon: Icons.keyboard_outlined,
          run: (_) => FlutterOverlayWindow.updateFlag(OverlayFlag.focusPointer),
        ),
        DemoAction(
          title: 'Flag: default',
          description: 'updateFlag(defaultFlag)',
          icon: Icons.restart_alt,
          run: (_) => FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag),
        ),
      ],
    );
  }
}
