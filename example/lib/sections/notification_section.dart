import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../widgets/demo_section.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '6. Notification',
      description: 'Update the foreground service notification',
      icon: Icons.notifications_outlined,
      actions: [
        DemoAction(
          title: 'Update title, content & icon',
          description: 'icon: "ic_stat_alt"',
          icon: Icons.edit_notifications_outlined,
          run: (context) {
            final time = TimeOfDay.now().format(context);
            return FlutterOverlayWindow.updateNotification(
              title: 'Notification updated',
              content: 'Updated at $time',
              // res/drawable/ic_stat_alt.xml
              icon: 'ic_stat_alt',
            );
          },
        ),
        DemoAction(
          title: 'Update with missing icon',
          description: 'Should fall back to the launcher icon',
          icon: Icons.broken_image_outlined,
          run: (_) => FlutterOverlayWindow.updateNotification(
            content: 'Missing icon falls back to default',
            icon: 'does_not_exist',
          ),
        ),
      ],
    );
  }
}
