import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';

import '../services/action_log.dart';

/// Shows whether the overlay permission is granted and whether an overlay is
/// currently active. Refreshes after every logged action.
class StatusCard extends StatefulWidget {
  const StatusCard({Key? key}) : super(key: key);

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> with WidgetsBindingObserver {
  ActionLog? _log;
  bool? _permissionGranted;
  bool? _overlayActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final log = context.read<ActionLog>();
    if (log != _log) {
      _log?.removeListener(_refresh);
      _log = log..addListener(_refresh);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the permission settings screen.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _log?.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _refresh() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    final active = await FlutterOverlayWindow.isActive();
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      _overlayActive = active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _StatusChip(
                    label: 'Permission',
                    value: _permissionGranted,
                    onText: 'granted',
                    offText: 'missing',
                  ),
                  _StatusChip(
                    label: 'Overlay',
                    value: _overlayActive,
                    onText: 'active',
                    offText: 'inactive',
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh status',
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    Key? key,
    required this.label,
    required this.value,
    required this.onText,
    required this.offText,
  }) : super(key: key);

  final String label;
  final bool? value;
  final String onText;
  final String offText;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    if (value == null) {
      color = Colors.grey;
      text = '…';
    } else if (value!) {
      color = Colors.green;
      text = onText;
    } else {
      color = Colors.orange;
      text = offText;
    }
    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text('$label: $text'),
      visualDensity: VisualDensity.compact,
    );
  }
}
