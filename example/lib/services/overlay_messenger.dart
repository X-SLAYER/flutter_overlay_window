import 'dart:isolate';
import 'dart:ui';

/// Port names shared by the main app and the overlay isolate.
class OverlayPorts {
  OverlayPorts._();

  static const String overlay = 'OVERLAY';
  static const String home = 'UI';
}

/// Registers the main app's receive port so the overlay can send messages
/// back, and looks up the overlay's port to send messages to it.
class OverlayMessenger {
  final ReceivePort _receivePort = ReceivePort();

  void listen(void Function(dynamic message) onMessage) {
    IsolateNameServer.removePortNameMapping(OverlayPorts.home);
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      OverlayPorts.home,
    );
    _receivePort.listen(onMessage);
  }

  /// Returns `false` when the overlay isolate is not running.
  bool sendToOverlay(Object message) {
    final port = IsolateNameServer.lookupPortByName(OverlayPorts.overlay);
    if (port == null) return false;
    port.send(message);
    return true;
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping(OverlayPorts.home);
    _receivePort.close();
  }
}
