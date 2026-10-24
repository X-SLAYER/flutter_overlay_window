import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../widgets/demo_section.dart';

class ShowOverlaySection extends StatelessWidget {
  const ShowOverlaySection({Key? key}) : super(key: key);

  /// Shows the overlay only when none is active, so each preset starts clean.
  static Future<String> _show(Future<void> Function() show) async {
    if (await FlutterOverlayWindow.isActive()) {
      return 'An overlay is already active, close it first';
    }
    await show();
    return 'Overlay shown';
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '2. Show overlay',
      description: 'Pick a preset to open the overlay',
      icon: Icons.layers_outlined,
      initiallyExpanded: true,
      actions: [
        DemoAction(
          title: 'Default chat head',
          description: 'Draggable, snaps to edges, circle dismiss target',
          icon: Icons.bubble_chart_outlined,
          run: (_) => _show(
            () => FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              overlayTitle: 'X-SLAYER',
              overlayContent: 'Overlay Enabled',
              flag: OverlayFlag.defaultFlag,
              visibility: NotificationVisibility.visibilityPublic,
              positionGravity: PositionGravity.auto,
              height: 250,
              width: 250,
              startPosition: const OverlayPosition(0, -259),
              dismissConfig: const OverlayDismissConfig(
                shape: OverlayDismissShape.circle,
                borderRadius: 16,
                backgroundColor: Color(0xCC333333),
                activeBackgroundColor: Colors.red,
                borderWidth: 2,
                borderColor: Colors.white24,
                activeBorderColor: Colors.white,
              ),
            ),
          ),
        ),
        DemoAction(
          title: 'Custom notification icon',
          description: 'notificationIcon: "ic_stat_overlay"',
          icon: Icons.notifications_active_outlined,
          run: (_) => _show(
            () => FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              overlayTitle: 'X-SLAYER',
              overlayContent: 'Overlay with custom icon',
              visibility: NotificationVisibility.visibilityPublic,
              positionGravity: PositionGravity.auto,
              height: 250,
              width: 250,
              // res/drawable/ic_stat_overlay.xml
              notificationIcon: 'ic_stat_overlay',
            ),
          ),
        ),
        DemoAction(
          title: 'Trash dismiss icon',
          description: 'Drag to the bottom to drop it on a trash icon',
          icon: Icons.delete_outline,
          run: (_) => _show(
            () => FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              overlayTitle: 'X-SLAYER',
              overlayContent: 'Overlay with trash dismiss icon',
              visibility: NotificationVisibility.visibilityPublic,
              positionGravity: PositionGravity.auto,
              height: 250,
              width: 250,
              // res/drawable/ic_dismiss_trash.xml
              dismissConfig: const OverlayDismissConfig(
                icon: 'ic_dismiss_trash',
                size: 64,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
