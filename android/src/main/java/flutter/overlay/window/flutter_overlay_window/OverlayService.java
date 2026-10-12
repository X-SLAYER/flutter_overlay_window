package flutter.overlay.window.flutter_overlay_window;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.app.PendingIntent;
import android.graphics.Point;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.FlutterView;
import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.FlutterEngineGroup;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodChannel;

public class OverlayService extends Service implements View.OnTouchListener {
    private final int DEFAULT_NAV_BAR_HEIGHT_DP = 48;
    private final int DEFAULT_STATUS_BAR_HEIGHT_DP = 25;
    private int mScreenHeight = -1;
    private float mDensity = -1;
    private Integer mStatusBarHeight = -1;
    private Integer mNavigationBarHeight = -1;
    private Resources mResources;
    public static final String INTENT_EXTRA_IS_CLOSE_WINDOW = "IsCloseWindow";
    private static OverlayService instance;
    public static boolean isRunning = false;
    private WindowManager windowManager = null;
    private FlutterView flutterView;
    private MethodChannel flutterChannel;
    private BasicMessageChannel<Object> overlayMessageChannel;
    private final WindowSetup windowSetup = WindowSetup.getInstance();
    private int clickableFlag = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN;

    private Handler mAnimationHandler = new Handler();
    private float lastX, lastY;
    private int lastYPosition;
    private boolean dragging;
    private int dragSlopSquared = 576; // (24px)^2, overwritten by system touch slop in onStartCommand
    private static final float MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER = 0.8f;
    private Point szWindow = new Point();
    private Timer mTrayAnimationTimer;
    private TrayAnimationTimerTask mTrayTimerTask;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onDestroy() {
        Log.d("OverLay", "Destroying the overlay window service");
        if (mTrayAnimationTimer != null) {
            mTrayAnimationTimer.cancel();
            mTrayAnimationTimer = null;
        }
        if (mTrayTimerTask != null) {
            mTrayTimerTask.cancel();
            mTrayTimerTask = null;
        }
        if (windowManager != null) {
            windowManager.removeView(flutterView);
            windowManager = null;
            flutterView.detachFromFlutterEngine();
            flutterView = null;
        }
        isRunning = false;
        NotificationManager notificationManager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(OverlayConstants.NOTIFICATION_ID);
        instance = null;
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mResources = getApplicationContext().getResources();

        boolean isCloseWindow = intent.getBooleanExtra(INTENT_EXTRA_IS_CLOSE_WINDOW, false);
        if (isCloseWindow) {
            cleanupAndStopSelf();
            return START_STICKY;
        }

        if (windowManager != null) {
            cleanupAndStopSelf();
        }

        int startX = intent.getIntExtra("startX", OverlayConstants.DEFAULT_XY);
        int startY = intent.getIntExtra("startY", OverlayConstants.DEFAULT_XY);

        isRunning = true;
        Log.d("onStartCommand", "Service started");
        FlutterEngine engine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG);
        assert engine != null;
        engine.getLifecycleChannel().appIsResumed();
        flutterView = new FlutterView(getApplicationContext(), new FlutterTextureView(getApplicationContext()));
        flutterView.attachToFlutterEngine(FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG));
        flutterView.setFitsSystemWindows(true);
        flutterView.setFocusable(true);
        flutterView.setFocusableInTouchMode(true);
        flutterView.setBackgroundColor(Color.TRANSPARENT);
        flutterChannel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "updateFlag":
                    String flag = call.argument("flag");
                    updateOverlayFlag(result, flag);
                    break;
                case "updateOverlayPosition":
                    int x = call.<Integer>argument("x");
                    int y = call.<Integer>argument("y");
                    moveOverlay(x, y, result);
                    break;
                case "resizeOverlay":
                    int width = call.argument("width");
                    int height = call.argument("height");
                    boolean enableDrag = call.argument("enableDrag");
                    resizeOverlay(width, height, enableDrag, result);
                    break;
            }
        });
        overlayMessageChannel.setMessageHandler((message, reply) -> {
            windowSetup.getMessenger().send(message);
        });
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);

        // Get real screen dimensions (including system bars)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            Display display = windowManager.getDefaultDisplay();
            DisplayMetrics dm = new DisplayMetrics();
            display.getRealMetrics(dm);
            szWindow.set(dm.widthPixels, dm.heightPixels);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            windowManager.getDefaultDisplay().getSize(szWindow);
        } else {
            DisplayMetrics displaymetrics = new DisplayMetrics();
            windowManager.getDefaultDisplay().getMetrics(displaymetrics);
            int w = displaymetrics.widthPixels;
            int h = displaymetrics.heightPixels;
            szWindow.set(w, h);
        }
        int dx = startX == OverlayConstants.DEFAULT_XY ? 0 : startX;
        int dy = startY == OverlayConstants.DEFAULT_XY ? -statusBarHeightPx() : startY;
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                windowSetup.getWidth() == -1999 ? -1 : windowSetup.getWidth(),
                windowSetup.getHeight() != -1999 ? windowSetup.getHeight() : screenHeight(),
                0,
                -statusBarHeightPx(),
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY : WindowManager.LayoutParams.TYPE_PHONE,
                windowSetup.getFlag() | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                        | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                        | WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR
                        | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                PixelFormat.TRANSLUCENT
        );
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && windowSetup.getFlag() == clickableFlag) {
            params.alpha = MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER;
        }
        params.gravity = windowSetup.getGravity();
        flutterView.setOnTouchListener(this);
        windowManager.addView(flutterView, params);
        moveOverlay(dx, dy, null);
        return START_STICKY;
    }


    private void cleanupAndStopSelf() {
        if (windowManager != null) {
            windowManager.removeView(flutterView);
            flutterView.detachFromFlutterEngine();
            windowManager = null;
            flutterView = null;
        }
        isRunning = false;
        stopSelf();
    }


    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private int screenHeight() {
        if (mScreenHeight == -1) {
            Display display = windowManager.getDefaultDisplay();
            DisplayMetrics dm = new DisplayMetrics();
            display.getRealMetrics(dm);
            mScreenHeight = inPortrait() ?
                    dm.heightPixels + statusBarHeightPx() + navigationBarHeightPx()
                    :
                    dm.heightPixels + statusBarHeightPx();
        }
        return mScreenHeight;
    }

    private int statusBarHeightPx() {
        if (mStatusBarHeight == -1) {
            int statusBarHeightId = mResources.getIdentifier("status_bar_height", "dimen", "android");

            if (statusBarHeightId > 0) {
                mStatusBarHeight = mResources.getDimensionPixelSize(statusBarHeightId);
            } else {
                mStatusBarHeight = dpToPx(DEFAULT_STATUS_BAR_HEIGHT_DP);
            }
        }

        return mStatusBarHeight;
    }

    int navigationBarHeightPx() {
        if (mNavigationBarHeight == -1) {
            int navBarHeightId = mResources.getIdentifier("navigation_bar_height", "dimen", "android");

            if (navBarHeightId > 0) {
                mNavigationBarHeight = mResources.getDimensionPixelSize(navBarHeightId);
            } else {
                mNavigationBarHeight = dpToPx(DEFAULT_NAV_BAR_HEIGHT_DP);
            }
        }

        return mNavigationBarHeight;
    }
    
    /**
     * Get safe boundaries for overlay positioning that respect system bars
     */
    private int[] getSafeBoundaries() {
        int screenWidth = szWindow.x;
        int screenHeight = szWindow.y;
        int statusBarHeight = statusBarHeightPx();
        int navigationBarHeight = inPortrait() ? navigationBarHeightPx() : 0;
        
        // Calculate usable area boundaries
        int leftBound = 0;
        int rightBound = screenWidth;
        int topBound = statusBarHeight; // Account for status bar
        int bottomBound = screenHeight - navigationBarHeight; // Account for navigation bar
        
        
        return new int[]{leftBound, topBound, rightBound, bottomBound};
    }
    
    /**
     * Apply soft boundary constraints during dragging - allows more freedom while keeping overlay visible
     */
    private void applySoftBoundaryConstraints(WindowManager.LayoutParams params, int overlayWidth, int overlayHeight) {
        int[] bounds = getSafeBoundaries();
        int leftBound = bounds[0];
        int topBound = bounds[1]; 
        int rightBound = bounds[2];
        int bottomBound = bounds[3];
        
        // During dragging, allow the overlay to go partially off-screen but keep at least 20% visible
        int minVisibleWidth = Math.max(overlayWidth / 5, 20); // At least 20% or 20px visible
        int minVisibleHeight = Math.max(overlayHeight / 5, 20); // At least 20% or 20px visible
        
        if ((windowSetup.getGravity() & Gravity.RIGHT) == Gravity.RIGHT) {
            // Right-based coordinate system - allow going off left edge but keep right edge visible
            int maxLeftOffset = rightBound - minVisibleWidth;
            int originalX = params.x;
            params.x = Math.max(maxLeftOffset, params.x);
            if (originalX != params.x) {
                Log.d("OverlayService", "SOFT RIGHT gravity: X constrained from " + originalX + " to " + params.x);
            }
        } else if ((windowSetup.getGravity() & Gravity.LEFT) == Gravity.LEFT) {
            // Left-based coordinate system - allow going off right edge but keep left edge visible
            int maxRightOffset = leftBound + overlayWidth - minVisibleWidth;
            int originalX = params.x;
            params.x = Math.min(maxRightOffset, params.x);
            if (originalX != params.x) {
                Log.d("OverlayService", "SOFT LEFT gravity: X constrained from " + originalX + " to " + params.x);
            }
        } else {
            // Center-based coordinate system - allow going off edges but keep center visible
            int maxLeftOffset = leftBound - (szWindow.x / 2) + minVisibleWidth;
            int maxRightOffset = rightBound - (szWindow.x / 2) - (overlayWidth - minVisibleWidth);
            int originalX = params.x;
            params.x = Math.max(maxLeftOffset, Math.min(params.x, maxRightOffset));
            if (originalX != params.x) {
                Log.d("OverlayService", "SOFT CENTER gravity: X constrained from " + originalX + " to " + params.x);
            }
        }
        
        if ((windowSetup.getGravity() & Gravity.BOTTOM) == Gravity.BOTTOM) {
            // Bottom-based coordinate system - allow going off top edge but keep bottom edge visible
            int maxTopOffset = bottomBound - minVisibleHeight;
            int originalY = params.y;
            params.y = Math.max(maxTopOffset, params.y);
            if (originalY != params.y) {
                Log.d("OverlayService", "SOFT BOTTOM gravity: Y constrained from " + originalY + " to " + params.y);
            }
        } else if ((windowSetup.getGravity() & Gravity.TOP) == Gravity.TOP) {
            // Top-based coordinate system - allow going off bottom edge but keep top edge visible
            int maxBottomOffset = topBound + overlayHeight - minVisibleHeight;
            int originalY = params.y;
            params.y = Math.min(maxBottomOffset, params.y);
            if (originalY != params.y) {
                Log.d("OverlayService", "SOFT TOP gravity: Y constrained from " + originalY + " to " + params.y);
            }
        } else {
            // Center-based coordinate system - allow going off edges but keep center visible
            int maxTopOffset = topBound - (szWindow.y / 2) + minVisibleHeight;
            int maxBottomOffset = bottomBound - (szWindow.y / 2) - (overlayHeight - minVisibleHeight);
            int originalY = params.y;
            params.y = Math.max(maxTopOffset, Math.min(params.y, maxBottomOffset));
            if (originalY != params.y) {
                Log.d("OverlayService", "SOFT CENTER gravity: Y constrained from " + originalY + " to " + params.y);
            }
        }
    }
    
    /**
     * Apply safe boundary constraints to position based on gravity
     */
    private void constrainToSafeBoundaries(WindowManager.LayoutParams params, int overlayWidth, int overlayHeight) {
        int[] bounds = getSafeBoundaries();
        int leftBound = bounds[0];
        int topBound = bounds[1]; 
        int rightBound = bounds[2];
        int bottomBound = bounds[3];
        
        if ((windowSetup.getGravity() & Gravity.RIGHT) == Gravity.RIGHT) {
            // Right-based coordinate system
            // params.x is offset from right edge, 0 = right edge, positive = left of right edge
            int originalX = params.x;
            params.x = Math.max(0, Math.min(params.x, rightBound - overlayWidth));
            if (originalX != params.x) {
                Log.d("OverlayService", "RIGHT gravity: X constrained from " + originalX + " to " + params.x);
            }
        } else if ((windowSetup.getGravity() & Gravity.LEFT) == Gravity.LEFT) {
            // Left-based coordinate system  
            // params.x is offset from left edge, 0 = left edge, positive = right of left edge
            int originalX = params.x;
            params.x = Math.max(leftBound, Math.min(params.x, rightBound - overlayWidth));
            if (originalX != params.x) {
                Log.d("OverlayService", "LEFT gravity: X constrained from " + originalX + " to " + params.x);
            }
        } else {
            // Center-based coordinate system
            // params.x is offset of window's center from screen's center
            // Ensure window's left edge >= leftBound and right edge <= rightBound
            int originalX = params.x;
            int minX_center_offset = leftBound - (szWindow.x / 2) + (overlayWidth / 2);
            int maxX_center_offset = rightBound - (szWindow.x / 2) - (overlayWidth / 2);
            params.x = Math.max(minX_center_offset, Math.min(params.x, maxX_center_offset));
            if (originalX != params.x) {
                Log.d("OverlayService", "CENTER gravity: X constrained from " + originalX + " to " + params.x + 
                      " (min: " + minX_center_offset + ", max: " + maxX_center_offset + ")");
            }
        }
        
        if ((windowSetup.getGravity() & Gravity.BOTTOM) == Gravity.BOTTOM) {
            // Bottom-based coordinate system
            // params.y is offset from bottom edge, 0 = bottom edge, positive = above bottom edge
            int originalY = params.y;
            params.y = Math.max(0, Math.min(params.y, bottomBound - overlayHeight));
            if (originalY != params.y) {
                Log.d("OverlayService", "BOTTOM gravity: Y constrained from " + originalY + " to " + params.y);
            }
        } else if ((windowSetup.getGravity() & Gravity.TOP) == Gravity.TOP) {
            // Top-based coordinate system
            // params.y is offset from top edge, 0 = top edge, positive = below top edge
            int originalY = params.y;
            params.y = Math.max(topBound, Math.min(params.y, bottomBound - overlayHeight));
            if (originalY != params.y) {
                Log.d("OverlayService", "TOP gravity: Y constrained from " + originalY + " to " + params.y);
            }
        } else {
            // Center-based coordinate system  
            // params.y is offset of window's center from screen's center
            // Ensure window's top edge >= topBound and bottom edge <= bottomBound
            int originalY = params.y;
            int minY_center_offset = topBound - (szWindow.y / 2) + (overlayHeight / 2);
            int maxY_center_offset = bottomBound - (szWindow.y / 2) - (overlayHeight / 2);
            params.y = Math.max(minY_center_offset, Math.min(params.y, maxY_center_offset));
            if (originalY != params.y) {
                Log.d("OverlayService", "CENTER gravity: Y constrained from " + originalY + " to " + params.y + 
                      " (min: " + minY_center_offset + ", max: " + maxY_center_offset + ")");
            }
        }
    }


    private void updateOverlayFlag(MethodChannel.Result result, String flag) {
        if (windowManager != null) {
            windowSetup.setFlag(flag);
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            params.flags = windowSetup.getFlag() | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS |
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
                    WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && windowSetup.getFlag() == clickableFlag) {
                params.alpha = MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER;
            } else {
                params.alpha = 1;
            }
            windowManager.updateViewLayout(flutterView, params);
            result.success(true);
        } else {
            result.success(false);
        }
    }

    private void resizeOverlay(int width, int height, boolean enableDrag, MethodChannel.Result result) {
        if (windowManager != null) {
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            params.width = (width == -1999 || width == -1) ? -1 : dpToPx(width);
            params.height = (height != 1999 || height != -1) ? dpToPx(height) : height;
            windowSetup.setEnableDrag(enableDrag);
            windowManager.updateViewLayout(flutterView, params);
            result.success(true);
        } else {
            result.success(false);
        }
    }

    private void moveOverlay(int x, int y, MethodChannel.Result result) {
        if (windowManager != null) {
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            params.x = (x == -1999 || x == -1) ? -1 : dpToPx(x);
            params.y = dpToPx(y);
            windowManager.updateViewLayout(flutterView, params);
            if (result != null)
                result.success(true);
        } else {
            if (result != null)
                result.success(false);
        }
    }


    public static Map<String, Double> getCurrentPosition() {
        if (instance != null && instance.flutterView != null) {
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) instance.flutterView.getLayoutParams();
            Map<String, Double> position = new HashMap<>();
            position.put("x", instance.pxToDp(params.x));
            position.put("y", instance.pxToDp(params.y));
            return position;
        }
        return null;
    }

    public static boolean moveOverlay(int x, int y) {
        if (instance != null && instance.flutterView != null) {
            if (instance.windowManager != null) {
                WindowManager.LayoutParams params = (WindowManager.LayoutParams) instance.flutterView.getLayoutParams();
                params.x = (x == -1999 || x == -1) ? -1 : instance.dpToPx(x);
                params.y = instance.dpToPx(y);
                instance.windowManager.updateViewLayout(instance.flutterView, params);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }


    @Override
    public void onCreate() {
        int slop = android.view.ViewConfiguration.get(this).getScaledTouchSlop();
        dragSlopSquared = slop * slop;

        // Get the cached FlutterEngine
        FlutterEngine flutterEngine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG);

        if (flutterEngine == null) {
            // Handle the error if engine is not found
            Log.e("OverlayService", "Flutter engine not found, hence creating new flutter engine");
            FlutterEngineGroup engineGroup = new FlutterEngineGroup(this);
            DartExecutor.DartEntrypoint entryPoint = new DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "overlayMain"
            );  // "overlayMain" is custom entry point

            flutterEngine = engineGroup.createAndRunEngine(this, entryPoint);

            // Cache the created FlutterEngine for future use
            FlutterEngineCache.getInstance().put(OverlayConstants.CACHED_TAG, flutterEngine);
        }

        
        // Create the MethodChannel with the properly initialized FlutterEngine
        if (flutterEngine != null) {
            flutterChannel = new MethodChannel(flutterEngine.getDartExecutor(), OverlayConstants.OVERLAY_TAG);
            overlayMessageChannel = new BasicMessageChannel(flutterEngine.getDartExecutor(), OverlayConstants.MESSENGER_TAG, JSONMessageCodec.INSTANCE);
        }

        createNotificationChannel();
        startForeground(OverlayConstants.NOTIFICATION_ID, buildNotification());
        instance = this;
    }

    public static boolean updateNotification() {
        if (instance == null) {
            return false;
        }
        NotificationManager manager = (NotificationManager) instance.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.notify(OverlayConstants.NOTIFICATION_ID, instance.buildNotification());
        return true;
    }

    private Notification buildNotification() {
        Intent notificationIntent = new Intent(this, FlutterOverlayWindowPlugin.class);
        int pendingFlags = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ?
                PendingIntent.FLAG_IMMUTABLE : PendingIntent.FLAG_UPDATE_CURRENT;
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, pendingFlags);

        return new NotificationCompat.Builder(this, OverlayConstants.CHANNEL_ID)
                .setContentTitle(windowSetup.getOverlayTitle())
                .setContentText(windowSetup.getOverlayContent())
                .setSmallIcon(resolveNotificationIcon())
                .setContentIntent(pendingIntent)
                .setVisibility(windowSetup.getNotificationVisibility())
                .setOnlyAlertOnce(true)
                .build();
    }

    private int resolveNotificationIcon() {
        String custom = windowSetup.getNotificationIcon();
        if (custom != null && !custom.isEmpty()) {
            int id = getDrawableResourceId("drawable", custom);
            if (id == 0) {
                id = getDrawableResourceId("mipmap", custom);
            }
            if (id != 0) {
                return id;
            }
            Log.w("OverlayService", "Notification icon '" + custom + "' not found in drawable or mipmap, using default");
        }
        int id = getDrawableResourceId("mipmap", "ic_launcher");
        return id != 0 ? id : R.drawable.notification_icon;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    OverlayConstants.CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            assert manager != null;
            manager.createNotificationChannel(serviceChannel);
        }
    }

    private int getDrawableResourceId(String resType, String name) {
        return getApplicationContext().getResources().getIdentifier(name, resType, getApplicationContext().getPackageName());
    }

    private int dpToPx(int dp) {
        if (mDensity == -1) {
            mDensity = mResources.getDisplayMetrics().density;
        }
        return Math.round(dp * mDensity);
    }

    private double pxToDp(int px) {
        if (mDensity == -1) {
            mDensity = mResources.getDisplayMetrics().density;
        }
        return (double) px / mDensity;
    }

    private boolean inPortrait() {
        return mResources.getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouch(View view, MotionEvent event) {
        if (windowManager == null || !windowSetup.isEnableDrag()) {
            return false;
        }
        WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                // Cancel any ongoing tray animation to prevent interference
                if (mTrayAnimationTimer != null) {
                    mTrayAnimationTimer.cancel();
                    mTrayAnimationTimer = null;
                }
                if (mTrayTimerTask != null) {
                    mTrayTimerTask.cancel();
                    mTrayTimerTask = null;
                }
                
                dragging = false;
                lastX = event.getRawX();
                lastY = event.getRawY();
                return false;
            case MotionEvent.ACTION_MOVE:
                float dx = event.getRawX() - lastX;
                float dy = event.getRawY() - lastY;
                if (!dragging && dx * dx + dy * dy < dragSlopSquared) {
                    return false;
                }
                updateOverlayPosition(params, dx, dy);
                lastX = event.getRawX();
                lastY = event.getRawY();
                dragging = true;
                return true;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                lastYPosition = params.y;
                boolean wasDragging = dragging;
                dragging = false;  // Reset dragging state for next touch sequence
                
                if (windowSetup.getPositionGravity().equals("none")) {
                    return wasDragging;
                }

                if (windowManager != null) {
                    startTrayAnimation(params);
                }
                return wasDragging;
        }
        return false;
    }

    private void updateOverlayPosition(WindowManager.LayoutParams params, float dx, float dy) {
        // During dragging, allow free movement but constrain to safe boundaries
        boolean invertX = windowSetup.getGravity() == (Gravity.TOP | Gravity.RIGHT)
                || windowSetup.getGravity() == (Gravity.CENTER | Gravity.RIGHT)
                || windowSetup.getGravity() == (Gravity.BOTTOM | Gravity.RIGHT);
        boolean invertY = windowSetup.getGravity() == (Gravity.BOTTOM | Gravity.LEFT)
                || windowSetup.getGravity() == Gravity.BOTTOM
                || windowSetup.getGravity() == (Gravity.BOTTOM | Gravity.RIGHT);

        // Log initial position before movement
        Log.d("OverlayService", "Drag movement - dx: " + dx + ", dy: " + dy + 
              ", gravity: " + windowSetup.getGravity() + ", invertX: " + invertX + ", invertY: " + invertY);

        // Apply movement
        int oldX = params.x;
        int oldY = params.y;
        params.x += ((int) dx * (invertX ? -1 : 1));
        params.y += ((int) dy * (invertY ? -1 : 1));
        
        Log.d("OverlayService", "Position after movement - X: " + oldX + " -> " + params.x + 
              ", Y: " + oldY + " -> " + params.y);
        
        // During dragging, only apply soft constraints to prevent going completely off-screen
        // This allows free movement while keeping the overlay partially visible
        applySoftBoundaryConstraints(params, flutterView.getWidth(), flutterView.getHeight());
        
        Log.d("OverlayService", "Position after soft constraints - X: " + params.x + ", Y: " + params.y);

        if (windowManager != null) {
            windowManager.updateViewLayout(flutterView, params);
        }
    }

    private void startTrayAnimation(WindowManager.LayoutParams params) {
        windowManager.updateViewLayout(flutterView, params);

        if (mTrayAnimationTimer != null) {
            mTrayAnimationTimer.cancel();
            mTrayAnimationTimer = null;
        }

        mTrayTimerTask = new TrayAnimationTimerTask();
        mTrayAnimationTimer = new Timer();
        mTrayAnimationTimer.schedule(mTrayTimerTask, 0, 25);
    }

    private class TrayAnimationTimerTask extends TimerTask {
        int mDestX;
        int mDestY;
        float mAnimationSpeed = 3.0f; // Configurable animation speed
        float mStopThreshold = 2.0f;  // When to stop the animation
        WindowManager.LayoutParams params;

        public TrayAnimationTimerTask() {
            super();
            params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            mDestY = lastYPosition;

            calculateDestinationX();
        }

        private void calculateDestinationX() {
            // Calculate destination X based on position gravity using safe boundaries
            int leftEdgeX, rightEdgeX;
            int[] bounds = getSafeBoundaries();
            int leftBound = bounds[0];
            int rightBound = bounds[2];
            int overlayWidth = flutterView.getWidth();
            
            // Calculate safe edge positions based on window gravity coordinate system
            if ((windowSetup.getGravity() & Gravity.RIGHT) == Gravity.RIGHT) {
                // Right-based coordinate system: x=0 is right edge of screen
                rightEdgeX = 0;                          // Right edge
                leftEdgeX = rightBound - overlayWidth;   // Left edge (within safe bounds)
            } else if ((windowSetup.getGravity() & Gravity.LEFT) == Gravity.LEFT) {
                // Left-based coordinate system: x=0 is left edge of screen
                leftEdgeX = leftBound;                   // Left edge (respecting safe area)
                rightEdgeX = rightBound - overlayWidth;  // Right edge (within safe bounds)
            } else {
                // Center-based coordinate system: x=0 is center of screen
                // Calculate positions within safe boundaries
                int screenCenterX = szWindow.x / 2;
                // For left edge: overlay's center should be at leftBound + overlayWidth/2
                leftEdgeX = (leftBound + overlayWidth / 2) - screenCenterX;
                // For right edge: overlay's center should be at rightBound - overlayWidth/2  
                rightEdgeX = (rightBound - overlayWidth / 2) - screenCenterX;
            }
            
            switch (windowSetup.getPositionGravity()) {
                case "auto":
                    // For auto, choose left or right based on current position
                    int currentAbsoluteX;
                    if ((windowSetup.getGravity() & Gravity.RIGHT) == Gravity.RIGHT) {
                        // In right-based system, convert to absolute position
                        currentAbsoluteX = rightBound - params.x - (overlayWidth / 2);
                    } else if ((windowSetup.getGravity() & Gravity.LEFT) == Gravity.LEFT) {
                        // In left-based system, convert to absolute position
                        currentAbsoluteX = params.x + (overlayWidth / 2);
                    } else {
                        // In center-based system, convert params.x (offset from screen center) to absolute position
                        int screenCenterX = szWindow.x / 2;
                        currentAbsoluteX = screenCenterX + params.x;
                    }
                    
                    // Choose left if overlay center is on left half of safe area, right otherwise
                    int safeAreaCenterX = (leftBound + rightBound) / 2;
                    boolean isOnLeftSide = currentAbsoluteX <= safeAreaCenterX;
                    mDestX = isOnLeftSide ? leftEdgeX : rightEdgeX;
                    
                    Log.d("OverlayService", "Auto positioning - currentAbsoluteX: " + currentAbsoluteX + 
                          ", safeAreaCenterX: " + safeAreaCenterX + ", isOnLeftSide: " + isOnLeftSide + 
                          ", leftEdgeX: " + leftEdgeX + ", rightEdgeX: " + rightEdgeX + ", destX: " + mDestX);
                    break;
                case "left":
                    mDestX = leftEdgeX;
                    break;
                case "right":
                    mDestX = rightEdgeX;
                    break;
                default:
                    mDestX = params.x;
                    mDestY = params.y;
                    break;
            }
        }

        @Override
        public void run() {
            mAnimationHandler.post(() -> {
                // Use improved easing function
                params.x = (int)((params.x - mDestX) / mAnimationSpeed) + mDestX;
                params.y = (int)((params.y - mDestY) / mAnimationSpeed) + mDestY;

                // Apply safe boundary constraints during animation to ensure final position is within bounds
                constrainToSafeBoundaries(params, flutterView.getWidth(), flutterView.getHeight());

                if (windowManager != null) {
                    windowManager.updateViewLayout(flutterView, params);
                }

                // Stop when close enough
                if (Math.abs(params.x - mDestX) < mStopThreshold &&
                        Math.abs(params.y - mDestY) < mStopThreshold) {
                    params.x = mDestX;
                    params.y = mDestY;
                    
                    // Final safe boundary check before setting final position
                    constrainToSafeBoundaries(params, flutterView.getWidth(), flutterView.getHeight());
                    
                    if (windowManager != null) {
                        windowManager.updateViewLayout(flutterView, params);
                    }
                    cancel();
                    if (mTrayAnimationTimer != null) {
                        mTrayAnimationTimer.cancel();
                        mTrayAnimationTimer = null;
                    }
                }
            });
        }
    }

}