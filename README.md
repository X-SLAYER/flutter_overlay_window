# flutter_overlay_window

Flutter plugin for displaying your flutter app over other apps on the screen


## Preview

|TrueCaller overlay exemple	| clickable overlay exemple|
|:------------:|:------------:|
|![truecaller](https://user-images.githubusercontent.com/22800380/165636217-8957396b-dc54-4e6d-aa50-e8bfdb9383cf.gif)|![clickable](https://user-images.githubusercontent.com/22800380/165636120-dcd9ee13-5fca-4f8a-a562-b2f53c0b5e24.gif)|


## Installation

Add package to your pubspec:

```yaml
dependencies:
  flutter_overlay_window: any # or the latest version on Pub
```

### Android

You'll need to add the `SYSTEM_ALERT_WINDOW` permission and `OverlayService` to your Android Manifest.

```XML
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

    <application>
        ...
        <service android:name="flutter.overlay.window.flutter_overlay_window.OverlayService" android:exported="false" />
    </application>
```

### Entry point

Inside `main.dart` create an entry point for your Overlay widget;

```dart

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(child: Text("My overlay"))
  ));
}

```

### USAGE

```dart
 /// check if overlay permission is granted
 final bool status = await FlutterOverlayWindow.isPermissionGranted();

 /// request overlay permission
 /// it will open the overlay settings page and return `true` once the permission granted.
 final bool status = await FlutterOverlayWindow.requestPermission();

 /// Open overLay content
 ///
 /// - Optional arguments:
 /// `height` the overlay height and default is [overlaySizeFill]
 /// `width` the overlay width and default is [overlaySizeFill]
 /// `OverlayAlignment` the alignment postion on screen and default is [OverlayAlignment.center]
 /// `OverlayFlag` the overlay flag and default is [OverlayFlag.clickThrough]
 /// `overlayTitle` the notification message and default is "overlay activated"
 /// `overlayContent` the notification message
 /// `enableDrag` to enable/disable dragging the overlay over the screen and default is "false"
 await FlutterOverlayWindow.showOverlay();

 /// closes overlay if open
 await FlutterOverlayWindow.closeOverlay();

 /// broadcast data to and from overlay app
 await FlutterOverlayWindow.shareData("Hello from the other side");

 /// streams message shared between overlay and main app
  FlutterOverlayWindow.overlayListener.listen((event) {
      log("Current Event: $event");
    });

 /// use [OverlayFlag.focusPointer] when you want to use fields that show keyboards
 await FlutterOverlayWindow.showOverlay(flag: OverlayFlag.focusPointer);

```

## Credits
this plugin is optimized version from [flutter_overlay_apps](https://pub.dev/packages/flutter_overlay_apps)



