import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';

import 'sections/control_section.dart';
import 'sections/layout_section.dart';
import 'sections/messaging_section.dart';
import 'sections/notification_section.dart';
import 'sections/permission_section.dart';
import 'sections/show_overlay_section.dart';
import 'services/action_log.dart';
import 'services/overlay_messenger.dart';
import 'widgets/log_panel.dart';
import 'widgets/status_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _log = ActionLog();
  final _messenger = OverlayMessenger();

  @override
  void initState() {
    super.initState();
    _messenger.listen(
      (message) => _log.add('From overlay', '$message', LogLevel.incoming),
    );
    FlutterOverlayWindow.overlayListener.listen(
      (data) => _log.add('shareData', '$data', LogLevel.incoming),
    );
  }

  @override
  void dispose() {
    _messenger.dispose();
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _log,
      child: Scaffold(
        appBar: AppBar(title: const Text('Overlay Window Example')),
        body: Column(
          children: [
            const StatusCard(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  const PermissionSection(),
                  const ShowOverlaySection(),
                  const ControlSection(),
                  const LayoutSection(),
                  MessagingSection(messenger: _messenger),
                  const NotificationSection(),
                ],
              ),
            ),
            const LogPanel(),
          ],
        ),
      ),
    );
  }
}
