/// The level of detail displayed in notifications on the lock screen.
enum NotificationVisibility {
  /// Show this notification in its entirety on all lockscreens.
  visibilityPublic,

  /// Do not reveal any part of this notification on a secure lockscreen.
  visibilitySecret,

  /// Show this notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.
  visibilityPrivate
}
