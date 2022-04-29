package flutter.overlay.window.flutter_overlay_window;

import android.graphics.PixelFormat;
import android.util.Log;
import android.view.Gravity;
import android.view.WindowManager;

import io.flutter.plugin.common.BasicMessageChannel;

public abstract class WindowSetup {

    static int height = WindowManager.LayoutParams.MATCH_PARENT;
    static int width = WindowManager.LayoutParams.MATCH_PARENT;
    static int flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
    static int gravity = Gravity.CENTER;
    static BasicMessageChannel messenger = null;
    static String overlayMessage = "Overlay is activated";
    static boolean enableDrag = false;


    static void setFlag(String name) {
        if (name.equalsIgnoreCase("flagNotFocusable")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        }
        if (name.equalsIgnoreCase("flagNotTouchable")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE;
        }
        if (name.equalsIgnoreCase("flagNotTouchModal")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;
        }
    }

    static void setGravityFromAlignment(String alignment) {
        if (alignment.equalsIgnoreCase("topLeft")) {
            gravity = Gravity.TOP | Gravity.LEFT;
            return;
        }
        if (alignment.equalsIgnoreCase("topCenter")) {
            gravity = Gravity.TOP;
        }
        if (alignment.equalsIgnoreCase("topRight")) {
            gravity = Gravity.TOP | Gravity.RIGHT;
            return;
        }

        if (alignment.equalsIgnoreCase("centerLeft")) {
            gravity = Gravity.CENTER | Gravity.LEFT;
            return;
        }
        if (alignment.equalsIgnoreCase("center")) {
            gravity = Gravity.CENTER;
        }
        if (alignment.equalsIgnoreCase("centerRight")) {
            gravity = Gravity.CENTER | Gravity.RIGHT;
            return;
        }

        if (alignment.equalsIgnoreCase("bottomLeft")) {
            gravity = Gravity.BOTTOM | Gravity.LEFT;
            return;
        }
        if (alignment.equalsIgnoreCase("bottomCenter")) {
            gravity = Gravity.BOTTOM;
        }
        if (alignment.equalsIgnoreCase("bottomRight")) {
            gravity = Gravity.BOTTOM | Gravity.RIGHT;
            return;
        }

    }
}
