import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../services/overlay_messenger.dart';
import '../widgets/demo_section.dart';

class MessagingSection extends StatelessWidget {
  const MessagingSection({Key? key, required this.messenger}) : super(key: key);

  final OverlayMessenger messenger;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '5. Messaging',
      description: 'Tap the chat head to expand it, then reply from it',
      icon: Icons.forum_outlined,
      actions: [
        DemoAction(
          title: 'Send via isolate port',
          description: 'IsolateNameServer → overlay',
          icon: Icons.send_outlined,
          run: (_) async {
            final sent =
                messenger.sendToOverlay('Hello from app: ${DateTime.now()}');
            return sent ? 'Sent' : 'Overlay port not found, is it running?';
          },
        ),
        DemoAction(
          title: 'Send via shareData',
          description: 'FlutterOverlayWindow.shareData()',
          icon: Icons.share_outlined,
          run: (_) async {
            await FlutterOverlayWindow.shareData(
              'shareData at ${DateTime.now()}',
            );
            return 'Shared';
          },
        ),
      ],
    );
  }
}
