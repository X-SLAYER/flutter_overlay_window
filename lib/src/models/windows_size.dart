class WindowSize {
  WindowSize._();

  /// default size when the overlay match the parent size
  /// basically it will take the full screen width and height
  static const int matchParent = -1;

  /// make the overlay cover the fullscreen
  /// even the statusbar and the navigationbar
  static const int fullCover = -1999;
}
