package flutter.overlay.window.flutter_overlay_window;

import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

public abstract class CachedMessageChannels {
    @Nullable
    public static MethodChannel mainAppMessageChannel;
    @Nullable
    public static MethodChannel overlayMessageChannel;
}
