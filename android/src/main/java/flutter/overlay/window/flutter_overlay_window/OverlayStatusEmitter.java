package flutter.overlay.window.flutter_overlay_window;

public abstract class OverlayStatusEmitter {
    static private final String methodName = "isShowingOverlay";
    static private boolean lastEmittedStatus;
    
    static void emitIsShowing(boolean isShowing) {
        if(isShowing == lastEmittedStatus) return;
        lastEmittedStatus = isShowing;
        if(CachedMessageChannels.mainAppMessageChannel != null) {
            CachedMessageChannels.mainAppMessageChannel.invokeMethod(methodName, isShowing);
        }
        if(CachedMessageChannels.overlayMessageChannel != null) {
            CachedMessageChannels.overlayMessageChannel.invokeMethod(methodName, isShowing);
        }
    }
}
