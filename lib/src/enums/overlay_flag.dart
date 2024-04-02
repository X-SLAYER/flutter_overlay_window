enum OverlayFlag {
  /// Window flag: this window can never receive touch events.
  /// Usefull if you want to display click-through overlay
  @Deprecated('Use "clickThrough" instead.')
  flagNotTouchable,

  /// Window flag: this window won't ever get key input focus
  /// so the user can not send key or other button events to it.
  @Deprecated('Use "defaultFlag" instead.')
  flagNotFocusable,

  /// Window flag: allow any pointer events outside of the window to be sent to the windows behind it.
  /// Usefull when you want to use fields that show keyboards.
  @Deprecated('Use "focusPointer" instead.')
  flagNotTouchModal,

  /// Window flag: this window can never receive touch events.
  /// Usefull if you want to display click-through overlay
  clickThrough,

  /// Window flag: this window won't ever get key input focus
  /// so the user can not send key or other button events to it.
  defaultFlag,

  /// Window flag: allow any pointer events outside of the window to be sent to the windows behind it.
  /// Usefull when you want to use fields that show keyboards.
  focusPointer,
}
