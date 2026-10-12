## 1.0.0

### Features
- Add `notificationIcon` to `showOverlay`: use any drawable or mipmap resource from your app as the notification icon (#173, #174)
- Add `updateNotification`: change the notification title, content or icon while the overlay is showing
- Overlay now respects the status and navigation bars and stays within the visible screen

### Fixes
- Fix `requestPermission()` never completing after the user grants permission (#187)
- Fix `requestPermission()` hanging after a screen rotation while the settings page is open
- Fix `requestPermission()` returning `true` without asking on Android 6 and 7
- `requestPermission()` now returns `true` immediately when permission is already granted
- `requestPermission()` returns a `NO_ACTIVITY` error instead of crashing when no activity is attached
- Fix other method calls overwriting a pending `requestPermission()` result
- Fix crash when the permission result arrives with no pending request
- Fix overlay drag issues and smoother snap animation
- Fix position calculation for centered overlays
- A missing notification icon falls back to the launcher icon instead of crashing the service

### Build
- Upgrade to Android Gradle Plugin 9 and Gradle 9.1
- Java 17 is now required

### Example
- Add buttons to test the custom notification icon and `updateNotification`

## 0.5.0
- Update gradle version
- Fix `NullPointerException` in OverlayService


## 0.4.5
- Added instructions for android 14 compatibility

## 0.4.4
- Fix overlay close crash  
- Add `startPosition`: start overlay in default position  
- Add `moveOverlay`: Update the overlay position in the screen  
- Add `getOverlayPosition`: Get the current overlay position

## 0.4.3
- Fix overlay height bug

## 0.4.2
- Fix touch freeze

## 0.4.1
- Remove secure flag  
- Detach view from engine after closing  
- Fix Example to show (Sending data between Main & overlay)

## 0.3.3
- Fix bugs related to android 12+  
- Some code optimizations  
- Fix overlay popup on top of status bar  
- Fix overlay closing

## 0.3.2
- Add the position gravity feature

## 0.3.1
- Fix the overlay permission on Android versions <= 6  
- Add the possibility to resize overlay while it's in action

## 0.2.9
- Fix closing overlay  
- Possibility to check if the overlay is active or not

## 0.2.8
- Change overlay flags names

## 0.2.7
- Fix overlay issue to target all SDK versions  
- Add `overlayTitle` and `overlayContent` arguments  
- Fix typo

## 0.2.2
- Add custom notification content text  
- Improve the `flagNotFocusable`  
- Update example

## 0.2.1
- Add flag update on runtime

## 0.0.2
- Fix keyboard not showing on TextFields

## 0.0.1
- Initial release
