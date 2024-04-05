package flutter.overlay.window.flutter_overlay_window.utils;

import android.os.Build;
import android.view.WindowManager;

public class Utils {
    public static int getOverlayFlag() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY : WindowManager.LayoutParams.TYPE_PHONE;
    }
}
