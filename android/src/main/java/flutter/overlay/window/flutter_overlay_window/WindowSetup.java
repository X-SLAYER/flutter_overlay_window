package flutter.overlay.window.flutter_overlay_window;


import android.view.Gravity;
import android.view.WindowManager;

import androidx.core.app.NotificationCompat;

import io.flutter.plugin.common.BasicMessageChannel;

public final class WindowSetup {

    private int height = WindowManager.LayoutParams.MATCH_PARENT;
    private int width = WindowManager.LayoutParams.MATCH_PARENT;
    private int flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
    private int gravity = Gravity.CENTER;
    private BasicMessageChannel<Object> messenger = null;
    private String overlayTitle = "Overlay is activated";
    private String overlayContent = "Tap to edit settings or disable";
    private String positionGravity = "none";
    private int notificationVisibility = NotificationCompat.VISIBILITY_PRIVATE;
    private boolean enableDrag = false;
    private String notificationIcon = null;

    private WindowSetup() {
    }

    private static final class Holder {
        private static final WindowSetup INSTANCE = new WindowSetup();
    }

    public static WindowSetup getInstance() {
        return Holder.INSTANCE;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public int getFlag() {
        return flag;
    }

    public int getGravity() {
        return gravity;
    }

    public BasicMessageChannel<Object> getMessenger() {
        return messenger;
    }

    public void setMessenger(BasicMessageChannel<Object> messenger) {
        this.messenger = messenger;
    }

    public String getOverlayTitle() {
        return overlayTitle;
    }

    public void setOverlayTitle(String overlayTitle) {
        this.overlayTitle = overlayTitle;
    }

    public String getOverlayContent() {
        return overlayContent;
    }

    public void setOverlayContent(String overlayContent) {
        this.overlayContent = overlayContent;
    }

    public String getPositionGravity() {
        return positionGravity;
    }

    public void setPositionGravity(String positionGravity) {
        this.positionGravity = positionGravity;
    }

    public int getNotificationVisibility() {
        return notificationVisibility;
    }

    public boolean isEnableDrag() {
        return enableDrag;
    }

    public void setEnableDrag(boolean enableDrag) {
        this.enableDrag = enableDrag;
    }

    public String getNotificationIcon() {
        return notificationIcon;
    }

    public void setNotificationIcon(String notificationIcon) {
        this.notificationIcon = notificationIcon;
    }

    public void setNotificationVisibility(String name) {
        if (name.equalsIgnoreCase("visibilityPublic")) {
            notificationVisibility = NotificationCompat.VISIBILITY_PUBLIC;
        }
        if (name.equalsIgnoreCase("visibilitySecret")) {
            notificationVisibility = NotificationCompat.VISIBILITY_SECRET;
        }
        if (name.equalsIgnoreCase("visibilityPrivate")) {
            notificationVisibility = NotificationCompat.VISIBILITY_PRIVATE;
        }
    }

    public void setFlag(String name) {
        if (name.equalsIgnoreCase("flagNotFocusable") || name.equalsIgnoreCase("defaultFlag")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        }
        if (name.equalsIgnoreCase("flagNotTouchable") || name.equalsIgnoreCase("clickThrough")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN;
        }
        if (name.equalsIgnoreCase("flagNotTouchModal") || name.equalsIgnoreCase("focusPointer")) {
            flag = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;
        }
    }

    public void setGravityFromAlignment(String alignment) {
        if (alignment.equalsIgnoreCase("topLeft")) {
            gravity = Gravity.TOP | Gravity.LEFT;
        } else if (alignment.equalsIgnoreCase("topCenter")) {
            gravity = Gravity.TOP;
        } else if (alignment.equalsIgnoreCase("topRight")) {
            gravity = Gravity.TOP | Gravity.RIGHT;
        } else if (alignment.equalsIgnoreCase("centerLeft")) {
            gravity = Gravity.CENTER | Gravity.LEFT;
        } else if (alignment.equalsIgnoreCase("center")) {
            gravity = Gravity.CENTER;
        } else if (alignment.equalsIgnoreCase("centerRight")) {
            gravity = Gravity.CENTER | Gravity.RIGHT;
        } else if (alignment.equalsIgnoreCase("bottomLeft")) {
            gravity = Gravity.BOTTOM | Gravity.LEFT;
        } else if (alignment.equalsIgnoreCase("bottomCenter")) {
            gravity = Gravity.BOTTOM;
        } else if (alignment.equalsIgnoreCase("bottomRight")) {
            gravity = Gravity.BOTTOM | Gravity.RIGHT;
        }
    }
}
