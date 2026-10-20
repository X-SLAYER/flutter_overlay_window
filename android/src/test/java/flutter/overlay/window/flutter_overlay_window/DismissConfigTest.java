package flutter.overlay.window.flutter_overlay_window;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

public class DismissConfigTest {

    private static final float DELTA = 0.0001f;

    @Test
    public void nullMapUsesDefaults() {
        DismissConfig config = DismissConfig.fromMap(null);

        assertNull(config.icon);
        assertEquals(56f, config.size, DELTA);
        assertEquals(40f, config.bottomMargin, DELTA);
        assertEquals(DismissConfig.SHAPE_CIRCLE, config.shape);
        assertEquals(12f, config.borderRadius, DELTA);
        assertEquals(0xCC333333, config.backgroundColor);
        assertEquals(0xFFFFFFFF, config.iconColor);
        assertEquals(22f, config.iconSize, DELTA);
        assertEquals(4f, config.iconStrokeWidth, DELTA);
        assertEquals(0f, config.borderWidth, DELTA);
        assertEquals(0x00000000, config.borderColor);
        assertEquals(config.backgroundColor, config.activeBackgroundColor);
        assertEquals(config.iconColor, config.activeIconColor);
        assertEquals(config.borderColor, config.activeBorderColor);
        assertEquals(1.2f, config.activeScale, DELTA);
        assertTrue(config.hapticFeedback);
    }

    @Test
    public void parsesValuesAsSentByDart() {
        // Mirrors OverlayDismissConfig.toMap(): doubles arrive as Double, colors as signed Integer.
        Map<String, Object> map = new HashMap<>();
        map.put("icon", "ic_dismiss");
        map.put("size", 64.0);
        map.put("bottomMargin", 48.0);
        map.put("shape", "rectangle");
        map.put("borderRadius", 16.0);
        map.put("backgroundColor", 0xFFE53935);
        map.put("iconColor", -1);
        map.put("iconSize", 24.0);
        map.put("iconStrokeWidth", 3.0);
        map.put("borderWidth", 2.0);
        map.put("borderColor", 0x3DFFFFFF);
        map.put("activeBackgroundColor", 0xFFF44336);
        map.put("activeIconColor", 0xFF000000);
        map.put("activeBorderColor", 0xFFFFFFFF);
        map.put("activeScale", 1.5);
        map.put("hapticFeedback", false);

        DismissConfig config = DismissConfig.fromMap(map);

        assertEquals("ic_dismiss", config.icon);
        assertEquals(64f, config.size, DELTA);
        assertEquals(48f, config.bottomMargin, DELTA);
        assertEquals(DismissConfig.SHAPE_RECTANGLE, config.shape);
        assertEquals(16f, config.borderRadius, DELTA);
        assertEquals(0xFFE53935, config.backgroundColor);
        assertEquals(0xFFFFFFFF, config.iconColor);
        assertEquals(24f, config.iconSize, DELTA);
        assertEquals(3f, config.iconStrokeWidth, DELTA);
        assertEquals(2f, config.borderWidth, DELTA);
        assertEquals(0x3DFFFFFF, config.borderColor);
        assertEquals(0xFFF44336, config.activeBackgroundColor);
        assertEquals(0xFF000000, config.activeIconColor);
        assertEquals(0xFFFFFFFF, config.activeBorderColor);
        assertEquals(1.5f, config.activeScale, DELTA);
        assertFalse(config.hapticFeedback);
    }

    @Test
    public void acceptsIntegerAndLongNumbers() {
        Map<String, Object> map = new HashMap<>();
        map.put("size", 60);
        map.put("backgroundColor", 0xFF112233L);

        DismissConfig config = DismissConfig.fromMap(map);

        assertEquals(60f, config.size, DELTA);
        assertEquals(0xFF112233, config.backgroundColor);
    }

    @Test
    public void activeColorsFallBackToParsedNormalColors() {
        Map<String, Object> map = new HashMap<>();
        map.put("backgroundColor", 0xFF0000FF);
        map.put("iconColor", 0xFF00FF00);
        map.put("borderColor", 0xFFFF0000);

        DismissConfig config = DismissConfig.fromMap(map);

        assertEquals(0xFF0000FF, config.activeBackgroundColor);
        assertEquals(0xFF00FF00, config.activeIconColor);
        assertEquals(0xFFFF0000, config.activeBorderColor);
    }

    @Test
    public void ignoresMissingAndWrongTypes() {
        Map<String, Object> map = new HashMap<>();
        map.put("icon", 42);
        map.put("size", "big");
        map.put("shape", null);
        map.put("hapticFeedback", "yes");

        DismissConfig config = DismissConfig.fromMap(map);

        assertNull(config.icon);
        assertEquals(56f, config.size, DELTA);
        assertEquals(DismissConfig.SHAPE_CIRCLE, config.shape);
        assertTrue(config.hapticFeedback);
    }

    @Test
    public void activeScaleIsClampedToAtLeastOne() {
        Map<String, Object> map = new HashMap<>();
        map.put("activeScale", 0.5);

        assertEquals(1f, DismissConfig.fromMap(map).activeScale, DELTA);
    }
}
