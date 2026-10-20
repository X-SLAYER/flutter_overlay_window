package flutter.overlay.window.flutter_overlay_window;

import java.util.Map;

/** Drag-to-dismiss options, mirrored from OverlayDismissConfig on the Dart side. Sizes are in dp. */
public final class DismissConfig {

    public static final String SHAPE_CIRCLE = "circle";
    public static final String SHAPE_RECTANGLE = "rectangle";

    public String icon = null;
    public float size = 56f;
    public float bottomMargin = 40f;
    public String shape = SHAPE_CIRCLE;
    public float borderRadius = 12f;
    public int backgroundColor = 0xCC333333;
    public int iconColor = 0xFFFFFFFF;
    public float iconSize = 22f;
    public float iconStrokeWidth = 4f;
    public float borderWidth = 0f;
    public int borderColor = 0x00000000;
    public int activeBackgroundColor = backgroundColor;
    public int activeIconColor = iconColor;
    public int activeBorderColor = borderColor;
    public float activeScale = 1.2f;
    public boolean hapticFeedback = true;

    public static DismissConfig fromMap(Map<String, Object> map) {
        DismissConfig config = new DismissConfig();
        if (map == null) return config;
        config.icon = map.get("icon") instanceof String ? (String) map.get("icon") : null;
        config.size = getFloat(map, "size", config.size);
        config.bottomMargin = getFloat(map, "bottomMargin", config.bottomMargin);
        if (map.get("shape") instanceof String) config.shape = (String) map.get("shape");
        config.borderRadius = getFloat(map, "borderRadius", config.borderRadius);
        config.backgroundColor = getInt(map, "backgroundColor", config.backgroundColor);
        config.iconColor = getInt(map, "iconColor", config.iconColor);
        config.iconSize = getFloat(map, "iconSize", config.iconSize);
        config.iconStrokeWidth = getFloat(map, "iconStrokeWidth", config.iconStrokeWidth);
        config.borderWidth = getFloat(map, "borderWidth", config.borderWidth);
        config.borderColor = getInt(map, "borderColor", config.borderColor);
        config.activeBackgroundColor = getInt(map, "activeBackgroundColor", config.backgroundColor);
        config.activeIconColor = getInt(map, "activeIconColor", config.iconColor);
        config.activeBorderColor = getInt(map, "activeBorderColor", config.borderColor);
        config.activeScale = Math.max(1f, getFloat(map, "activeScale", config.activeScale));
        if (map.get("hapticFeedback") instanceof Boolean) config.hapticFeedback = (Boolean) map.get("hapticFeedback");
        return config;
    }

    private static float getFloat(Map<String, Object> map, String key, float fallback) {
        Object value = map.get(key);
        return value instanceof Number ? ((Number) value).floatValue() : fallback;
    }

    private static int getInt(Map<String, Object> map, String key, int fallback) {
        Object value = map.get(key);
        return value instanceof Number ? ((Number) value).intValue() : fallback;
    }
}
