package flutter.overlay.window.flutter_overlay_window;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import android.service.notification.StatusBarNotification;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationManagerCompat;

import java.util.Objects;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.FlutterEngineGroup;
import io.flutter.embedding.engine.FlutterEngineGroupCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterOverlayWindowPlugin implements
        FlutterPlugin, ActivityAware, MethodCallHandler,
        PluginRegistry.ActivityResultListener {

    private MethodChannel channel;
    private Context context;
    private Activity mActivity;
    private Result pendingResult;
    final int REQUEST_CODE_FOR_OVERLAY_PERMISSION = 1248;
    @Nullable
    FlutterPluginBinding flutterBinding;
    @Nullable
    ActivityPluginBinding activityPluginBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterBinding = flutterPluginBinding;
        this.context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), OverlayConstants.CHANNEL_TAG);
        channel.setMethodCallHandler(this);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        pendingResult = result;
        if (call.method.equals("checkPermission")) {
            result.success(checkOverlayPermission());
        } else if (call.method.equals("requestPermission")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setData(Uri.parse("package:" + mActivity.getPackageName()));
                mActivity.startActivityForResult(intent, REQUEST_CODE_FOR_OVERLAY_PERMISSION);
            } else {
                result.success(true);
            }
        } else if (call.method.equals("showOverlay")) {
            if (!checkOverlayPermission()) {
                result.error("PERMISSION", "overlay permission is not enabled", null);
                return;
            }

            ensureEngineCreated();

            Integer height = call.argument("height");
            Integer width = call.argument("width");
            String alignment = call.argument("alignment");
            String flag = call.argument("flag");
            String overlayTitle = call.argument("overlayTitle");
            String overlayContent = call.argument("overlayContent");
            String notificationVisibility = call.argument("notificationVisibility");
            boolean enableDrag = call.argument("enableDrag");
            String positionGravity = call.argument("positionGravity");
            Map<String, Integer> startPosition = call.argument("startPosition");
            int startX = startPosition != null ? startPosition.getOrDefault("x", OverlayConstants.DEFAULT_XY) : OverlayConstants.DEFAULT_XY;
            int startY = startPosition != null ? startPosition.getOrDefault("y", OverlayConstants.DEFAULT_XY) : OverlayConstants.DEFAULT_XY;


            WindowSetup.width = width != null ? width : -1;
            WindowSetup.height = height != null ? height : -1;
            WindowSetup.enableDrag = enableDrag;
            WindowSetup.setGravityFromAlignment(alignment != null ? alignment : "center");
            WindowSetup.setFlag(flag != null ? flag : "flagNotFocusable");
            WindowSetup.overlayTitle = overlayTitle;
            WindowSetup.overlayContent = overlayContent == null ? "" : overlayContent;
            WindowSetup.positionGravity = positionGravity;
            WindowSetup.setNotificationVisibility(notificationVisibility);

            final Intent intent = new Intent(context, OverlayService.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            intent.putExtra("startX", startX);
            intent.putExtra("startY", startY);
            context.startService(intent);
            result.success(null);
        } else if (call.method.equals("isOverlayActive")) {
            result.success(OverlayService.isRunning);
            return;
        } else if (call.method.equals("isOverlayActive")) {
            result.success(OverlayService.isRunning);
            return;
        } else if (call.method.equals("moveOverlay")) {
            int x = call.argument("x");
            int y = call.argument("y");
            result.success(OverlayService.moveOverlay(x, y));
        } else if (call.method.equals("getOverlayPosition")) {
            result.success(OverlayService.getCurrentPosition());
        } else if (call.method.equals("closeOverlay")) {
            if (OverlayService.isRunning) {
                final Intent i = new Intent(context, OverlayService.class);
                context.stopService(i);
                result.success(true);
            }
            return;
        } else {
            result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        flutterBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        mActivity = binding.getActivity();

        ensureEngineGroupCreated();

        ensureEngineCreated();

        setupMainAppMessageChannel();

        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        Objects.requireNonNull(activityPluginBinding).removeActivityResultListener(this);
        activityPluginBinding = null;
        mActivity = null;
        FlutterEngineGroupCache.getInstance().remove(OverlayConstants.CACHED_TAG);
        if (CachedMessageChannels.mainAppMessageChannel != null) {
            CachedMessageChannels.mainAppMessageChannel.setMessageHandler(null);
            CachedMessageChannels.mainAppMessageChannel = null;
        }
    }

    private void setupMainAppMessageChannel() {
        FlutterEngineGroup enn = FlutterEngineGroupCache.getInstance().get(OverlayConstants.CACHED_TAG);

        boolean isMainAppEngineGroup =  Objects.requireNonNull(flutterBinding).getEngineGroup() != enn;

        if(isMainAppEngineGroup) {
            BasicMessageChannel<Object> mainAppMessageChannel = new BasicMessageChannel<>(flutterBinding.getBinaryMessenger(), OverlayConstants.MESSENGER_TAG, JSONMessageCodec.INSTANCE);
            mainAppMessageChannel.setMessageHandler((message, reply) -> {
                if (CachedMessageChannels.overlayMessageChannel == null) {
                    reply.reply(false);
                    return;
                }
                CachedMessageChannels.overlayMessageChannel.send(message);
                reply.reply(true);
            });
            CachedMessageChannels.mainAppMessageChannel = mainAppMessageChannel;
        }
    }

    private FlutterEngineGroup ensureEngineGroupCreated() {
        FlutterEngineGroup enn = FlutterEngineGroupCache.getInstance().get(OverlayConstants.CACHED_TAG);

        if(enn == null) {
            enn = new FlutterEngineGroup(context);
            FlutterEngineGroupCache.getInstance().put(OverlayConstants.CACHED_TAG, enn);
        }

        return enn;
    }
    private void ensureEngineCreated() {
        FlutterEngine engine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG);
        if(engine == null) {
            FlutterEngineGroup enn = ensureEngineGroupCreated();
            DartExecutor.DartEntrypoint dEntry = new DartExecutor.DartEntrypoint(
                    FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                    "overlayMain");
            engine = Objects.requireNonNull(enn).createAndRunEngine(context, dEntry);
            FlutterEngineCache.getInstance().put(OverlayConstants.CACHED_TAG, engine);
            engine.addEngineLifecycleListener(new  FlutterEngine.EngineLifecycleListener() {
                @Override
                public void onPreEngineRestart() {

                }
                @Override
                public void onEngineWillDestroy() {
                    FlutterEngineCache.getInstance().remove(OverlayConstants.CACHED_TAG);
                }
            });
        }
    }
    private boolean checkOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(context);
        }
        return true;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FOR_OVERLAY_PERMISSION) {
            pendingResult.success(checkOverlayPermission());
            return true;
        }
        return false;
    }

}
