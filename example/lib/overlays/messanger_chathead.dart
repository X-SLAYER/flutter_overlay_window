import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../services/overlay_messenger.dart';

/// Overlay entry widget. Tap the bubble to expand it into a panel that shows
/// messages from the app and can reply over both messaging channels.
class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  final _receivePort = ReceivePort();
  bool _expanded = false;
  String? _lastMessage;

  @override
  void initState() {
    super.initState();
    IsolateNameServer.removePortNameMapping(OverlayPorts.overlay);
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      OverlayPorts.overlay,
    );
    _receivePort.listen((message) {
      setState(() => _lastMessage = 'port: $message');
    });
    FlutterOverlayWindow.overlayListener.listen((data) {
      setState(() => _lastMessage = 'shareData: $data');
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(OverlayPorts.overlay);
    _receivePort.close();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_expanded) {
      await FlutterOverlayWindow.resizeOverlay(50, 100, true);
    } else {
      await FlutterOverlayWindow.resizeOverlay(
        WindowSize.matchParent,
        WindowSize.matchParent,
        false,
      );
    }
    setState(() => _expanded = !_expanded);
  }

  void _replyViaPort() {
    IsolateNameServer.lookupPortByName(OverlayPorts.home)
        ?.send('Port reply at ${DateTime.now()}');
  }

  void _replyViaShareData() {
    FlutterOverlayWindow.shareData('shareData reply at ${DateTime.now()}');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: _expanded ? BoxShape.rectangle : BoxShape.circle,
          ),
          child: Center(
            child: _expanded ? _buildPanel() : const FlutterLogo(),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FlutterLogo(size: 48),
          const SizedBox(height: 16),
          Text(
            _lastMessage ?? 'No message from the app yet',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _replyViaPort,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Reply via isolate port'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _replyViaShareData,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Reply via shareData'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap anywhere else to collapse',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
