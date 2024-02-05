package flutter.overlay.window.flutter_overlay_window;

import androidx.annotation.Nullable;
import io.flutter.plugin.common.BasicMessageChannel;

public abstract class CachedMessageChannels {
    @Nullable
    public static BasicMessageChannel<Object> mainAppMessageChannel;
    @Nullable
    public static BasicMessageChannel<Object> overlayMessageChannel;
}
