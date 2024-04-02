package flutter.overlay.window.flutter_overlay_window;


import android.view.Gravity;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import io.flutter.plugin.common.BasicMessageChannel;

public class WindowSetup {

    private static WindowSetup instance;
    private int height;
    private int width;
    private int flag;
    private int gravity;
    private BasicMessageChannel<Object> messenger;
    private String overlayTitle;
    private String overlayContent;
    private String positionGravity;
    private int notificationVisibility;
    private boolean enableDrag;

    private WindowSetup() {
        height = WindowManager.LayoutParams.MATCH_PARENT;
        width = WindowManager.LayoutParams.MATCH_PARENT;
        flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        gravity = Gravity.CENTER;
        messenger = null;
        overlayTitle = "Overlay is activated";
        overlayContent = "Tap to edit settings or disable";
        positionGravity = "none";
        notificationVisibility = NotificationCompat.VISIBILITY_PRIVATE;
        enableDrag = false;
    }

    public static synchronized WindowSetup getInstance() {
        if (instance == null) {
            instance = new WindowSetup();
        }
        return instance;
    }


    void setNotificationVisibility(String name) {
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

    void setFlag(String name) {
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

    void setGravityFromAlignment(String alignment) {
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

    public BasicMessageChannel<Object> getMessenger() {
        return messenger;
    }

    public void setMessenger(BasicMessageChannel<Object> messenger, @Nullable final BasicMessageChannel.MessageHandler<Object> handler) {
        this.messenger = messenger;
        this.messenger.setMessageHandler(handler);
    }

    public void setMessageHandler(@Nullable final BasicMessageChannel.MessageHandler<Object> handler) {
        this.messenger.setMessageHandler(handler);
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

    public void setGravity(int gravity) {
        this.gravity = gravity;
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

    public void setNotificationVisibility(int notificationVisibility) {
        this.notificationVisibility = notificationVisibility;
    }

    public boolean isEnableDrag() {
        return enableDrag;
    }

    public void setEnableDrag(boolean enableDrag) {
        this.enableDrag = enableDrag;
    }

    public String getOverlayTitle() {
        return overlayTitle;
    }

    public void setOverlayTitle(String overlayTitle) {
        this.overlayTitle = overlayTitle;
    }
}
