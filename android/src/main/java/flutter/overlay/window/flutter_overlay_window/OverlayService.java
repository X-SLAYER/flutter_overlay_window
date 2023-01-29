package flutter.overlay.window.flutter_overlay_window;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.ClipData;
import android.content.ClipDescription;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.app.PendingIntent;
import android.graphics.Point;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.view.DragEvent;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.example.flutter_overlay_window.R;

import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodChannel;

public class OverlayService extends Service implements View.OnTouchListener {

    public static final String INTENT_EXTRA_IS_CLOSE_WINDOW = "IsCloseWindow";
    public static final String TAG = "Overlay Service";
    private WindowManager windowManager = null;
    public static boolean isRunning = false;
    private FlutterView flutterView;
    private MethodChannel flutterChannel = new MethodChannel(FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG).getDartExecutor(), OverlayConstants.OVERLAY_TAG);
    private BasicMessageChannel<Object> overlayMessageChannel = new BasicMessageChannel(FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG).getDartExecutor(), OverlayConstants.MESSENGER_TAG, JSONMessageCodec.INSTANCE);
    private int clickableFlag = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN;

    private Handler mAnimationHandler = new Handler();
    private float lastX, lastY;
    private int lastYPosition;
    private boolean dragging;
    private static final float MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER = 0.8f;
    private Point szWindow = new Point();
    private Timer mTrayAnimationTimer;
    private TrayAnimationTimerTask mTrayTimerTask;


    private Animation animMoveToTop;
    private View removeFloatingWidgetView;
    private ImageView imageIcon;
    private LinearLayout closeSection;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onDestroy() {
        Log.d("OverLay", "Destroying the overlay window service");
        isRunning = false;
        NotificationManager notificationManager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(OverlayConstants.NOTIFICATION_ID);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        boolean isCloseWindow = intent.getBooleanExtra(INTENT_EXTRA_IS_CLOSE_WINDOW, false);
        if (isCloseWindow) {
            if (windowManager != null) {
                windowManager.removeView(flutterView);
                windowManager.removeView(removeFloatingWidgetView);
                windowManager = null;
                stopSelf();
            }
            isRunning = false;
            return START_STICKY;
        }
        if (windowManager != null) {
            windowManager.removeView(flutterView);
            windowManager.removeView(removeFloatingWidgetView);
            windowManager = null;
            stopSelf();
        }
        isRunning = true;
        Log.d("onStartCommand", "Service started");
        FlutterEngine engine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG);
        engine.getLifecycleChannel().appIsResumed();
        flutterView = new FlutterView(getApplicationContext(), new FlutterTextureView(getApplicationContext()));
        flutterView.attachToFlutterEngine(FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG));
        flutterView.setFitsSystemWindows(true);
        flutterView.setFocusable(true);
        flutterView.setFocusableInTouchMode(true);
        flutterView.setBackgroundColor(Color.TRANSPARENT);
        flutterChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("updateFlag")) {
                String flag = call.argument("flag").toString();
                updateOverlayFlag(result, flag);
            } else if (call.method.equals("resizeOverlay")) {
                int width = call.argument("width");
                int height = call.argument("height");
                resizeOverlay(width, height, result);
            }
        });
        overlayMessageChannel.setMessageHandler((message, reply) -> {
            WindowSetup.messenger.send(message);
        });
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        int LAYOUT_TYPE;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            LAYOUT_TYPE = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            LAYOUT_TYPE = WindowManager.LayoutParams.TYPE_PHONE;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            windowManager.getDefaultDisplay().getSize(szWindow);
        } else {
            int w = windowManager.getDefaultDisplay().getWidth();
            int h = windowManager.getDefaultDisplay().getHeight();
            szWindow.set(w, h);
        }
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                100,
                100,
                LAYOUT_TYPE,
                WindowSetup.flag | WindowManager.LayoutParams.FLAG_SECURE | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
        );

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && WindowSetup.flag == clickableFlag) {
            params.alpha = MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER;
        }


        flutterView.setTag(OverlayConstants.Flutter_VIEW_TAG);

        params.gravity = WindowSetup.gravity;
        flutterView.setOnTouchListener(this);



        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);

        removeFloatingWidgetView = inflater.inflate(R.layout.close_section, null);


        imageIcon = (ImageView) removeFloatingWidgetView.findViewById(R.id.imageView);

        closeSection = (LinearLayout) removeFloatingWidgetView.findViewById(R.id.close_section);

        imageIcon.setTag(OverlayConstants.CLOSE_BUTTON_TAG);


        // load the animation
        animMoveToTop = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.close_animation);

        // set animation listener
        animMoveToTop.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                if (animation == animMoveToTop) {
                    Toast.makeText(getApplicationContext(), "Animation Stopped", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });


        //Add the view to the window.
        WindowManager.LayoutParams paramRemove = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                200,
                LAYOUT_TYPE,
                WindowSetup.flag | WindowManager.LayoutParams.FLAG_SECURE | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT);

        //Specify the view position
        paramRemove.gravity = Gravity.BOTTOM;

        removeFloatingWidgetView.setVisibility(View.GONE);


        windowManager.addView(removeFloatingWidgetView, paramRemove);
        windowManager.addView(flutterView, params);

        imageIcon.setOnDragListener(new View.OnDragListener() {
            @Override
            public boolean onDrag(View v, DragEvent event) {
                switch (event.getAction()) {
                    case DragEvent.ACTION_DRAG_STARTED:

                        Log.i(TAG, "Action is DragEvent.ACTION_DRAG_STARTED");

                        // Do nothing
                        break;

                    case DragEvent.ACTION_DRAG_ENTERED:
                        Log.i(TAG, "Action is DragEvent.ACTION_DRAG_ENTERED");
                        int x_cord = (int) event.getX();
                        int y_cord = (int) event.getY();
                        break;

                    case DragEvent.ACTION_DRAG_EXITED:
                        Log.i(TAG, "Action is DragEvent.ACTION_DRAG_EXITED");
                        x_cord = (int) event.getX();
                        y_cord = (int) event.getY();

                        break;

                    case DragEvent.ACTION_DRAG_LOCATION:
                        Log.i(TAG, "Action is DragEvent.ACTION_DRAG_LOCATION");
                        x_cord = (int) event.getX();
                        y_cord = (int) event.getY();
                        break;

                    case DragEvent.ACTION_DRAG_ENDED:
                        Log.i(TAG, "Action is DragEvent.ACTION_DRAG_ENDED");

                        // Do nothing
                        break;

                    case DragEvent.ACTION_DROP:
                        Log.i(TAG, "ACTION_DROP event");

                        // Do nothing
                        break;
                    default:
                        break;
                }
                return true;
            }
        });


        return START_STICKY;
    }

    private void updateOverlayFlag(MethodChannel.Result result, String flag) {
        if (windowManager != null) {
            WindowSetup.setFlag(flag);
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            params.flags = WindowSetup.flag;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && WindowSetup.flag == clickableFlag) {
                params.alpha = MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER;
            }
            windowManager.updateViewLayout(flutterView, params);
            result.success(true);
        } else {
            result.success(false);
        }
    }

    private void resizeOverlay(int width, int height, MethodChannel.Result result) {
        if (windowManager != null) {
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            params.width = width;
            params.height = height;

                params.x = 0;

            windowManager.updateViewLayout(flutterView, params);
            result.success(true);
        } else {
            result.success(false);
        }
    }
//
//    private void setDraggingOverlay(boolean value, MethodChannel.Result result) {
//        if (windowManager != null) {
//            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
//            params.x = width;
//            params.height = height;
//            windowManager.updateViewLayout(flutterView, params);
//            result.success(true);
//        } else {
//            result.success(false);
//        }
//    }

    @Override
    public void onCreate() {
        createNotificationChannel();
        Intent notificationIntent = new Intent(this, FlutterOverlayWindowPlugin.class);
        int pendingFlags;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            pendingFlags = PendingIntent.FLAG_IMMUTABLE;
        } else {
            pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        }
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, pendingFlags);
        final int notifyIcon = getDrawableResourceId("mipmap", "launcher");
        Notification notification = new NotificationCompat.Builder(this, OverlayConstants.CHANNEL_ID)
                .setContentTitle(WindowSetup.overlayTitle)
                .setContentText(WindowSetup.overlayContent)
                .setSmallIcon(notifyIcon == 0 ? R.drawable.notification_icon : notifyIcon)
                .setContentIntent(pendingIntent)
                .setVisibility(WindowSetup.notificationVisibility)
                .build();
        startForeground(OverlayConstants.NOTIFICATION_ID, notification);
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
        return getApplicationContext().getResources().getIdentifier(String.format("ic_%s", name), resType, getApplicationContext().getPackageName());
    }


    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public boolean onTouch(View view, MotionEvent event) {
        if (windowManager != null && WindowSetup.enableDrag) {


            double w = Resources.getSystem().getDisplayMetrics().widthPixels;
            double h = Resources.getSystem().getDisplayMetrics().heightPixels;
            WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();
            Log.i(TAG, "onTouch: event.getAction(): " + event.getAction() + " Screen : (" + w + ", " + h);


            switch (event.getAction()) {


                case MotionEvent.ACTION_DOWN:
                    dragging = false;
                    lastX = event.getRawX();
                    lastY = event.getRawY();


                    closeSection.setVisibility(View.VISIBLE);
                    // start the animation
//                    imageIcon.startAnimation(animMoveToTop);


//                    ClipData.Item item = new ClipData.Item((CharSequence)view.getTag());
//                    String[] mimeTypes = {ClipDescription.MIMETYPE_TEXT_PLAIN};
//
//                    ClipData dragData = new ClipData(view.getTag().toString(),mimeTypes, item);
//                    View.DragShadowBuilder myShadow = new View.DragShadowBuilder(flutterView);
//
//                    view.startDrag(dragData,myShadow,null,0);


                    break;
                case MotionEvent.ACTION_MOVE:
                    float dx = event.getRawX() - lastX;
                    float dy = event.getRawY() - lastY;
                    if (!dragging && dx * dx + dy * dy < 25) {
                        return false;
                    }
                    lastX = event.getRawX();
                    lastY = event.getRawY();
                    int xx = params.x + (int) dx;
                    int yy = params.y + (int) dy;

                    Log.i(TAG, "onTouch: last : ( " + lastX + "," + lastY + "  ) flutterView: ( " + xx + "," + yy + " )");
                    params.x = xx;
                    params.y = yy;
                    windowManager.updateViewLayout(flutterView, params);
                    dragging = true;
                    break;
                case MotionEvent.ACTION_UP:


                    // start the animation
//                    imageIcon.startAnimation(animMoveToTop);

                case MotionEvent.ACTION_CANCEL:
                    lastYPosition = params.y;

                    closeSection.setVisibility(View.GONE);


                    if (lastY <= h && lastY >= (h - 200) && ((w/2) - 100) < lastX && ((w/2) + 100) > lastX  ) {

                        if (OverlayService.isRunning) {
                            Log.i(TAG, "onTouch:ACTION_UP (" + lastX + " , " + lastY + ")");
                            final Intent i = new Intent(getApplicationContext(), OverlayService.class);
                            i.putExtra(OverlayService.INTENT_EXTRA_IS_CLOSE_WINDOW, true);
                            getApplicationContext().startService(i);

                        }
                    } else {
                        if (OverlayService.isRunning && WindowSetup.positionGravity != "none") {
                            windowManager.updateViewLayout(flutterView, params);
                            mTrayTimerTask = new TrayAnimationTimerTask();
                            mTrayAnimationTimer = new Timer();
                            mTrayAnimationTimer.schedule(mTrayTimerTask, 0, 25);
                        }
                    }

//
                    return dragging;
                default:
                    return false;
            }
            return false;
        }
        return false;
    }

    private class TrayAnimationTimerTask extends TimerTask {
        int mDestX;
        int mDestY;
        WindowManager.LayoutParams params = (WindowManager.LayoutParams) flutterView.getLayoutParams();

        public TrayAnimationTimerTask() {
            super();
            mDestY = lastYPosition;
            switch (WindowSetup.positionGravity) {
                case "auto":
                    mDestX =
                            (params.x + (flutterView.getWidth() / 2)) <= szWindow.x / 2 ? 0 : szWindow.x - flutterView.getWidth();
                    return;
                case "left":
                    mDestX = 0;
                    return;
                case "right":
                    mDestX = szWindow.x - flutterView.getWidth();
                    return;
                default:
                    mDestX = params.x;
                    mDestY = params.y;
                    return;
            }
        }

        @Override
        public void run() {
            mAnimationHandler.post(() -> {
                params.x = (2 * (params.x - mDestX)) / 3 + mDestX;
                params.y = (2 * (params.y - mDestY)) / 3 + mDestY;
                try {
                    windowManager.updateViewLayout(flutterView, params);
                    if (Math.abs(params.x - mDestX) < 2 && Math.abs(params.y - mDestY) < 2) {
                        TrayAnimationTimerTask.this.cancel();
                        mTrayAnimationTimer.cancel();
                    }
                } catch (Error e) {
                    e.printStackTrace();
                }
            });
        }
    }


}