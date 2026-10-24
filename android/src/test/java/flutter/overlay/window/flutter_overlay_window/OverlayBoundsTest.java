package flutter.overlay.window.flutter_overlay_window;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class OverlayBoundsTest {
    @Test
    public void matchParentUsesAvailableSizeInsteadOfStaleMeasurement() {
        assertEquals(900, OverlayBounds.resolveSize(-1, 100, 900));
    }

    @Test
    public void explicitAndWrapContentSizesAreLimitedToAvailableSpace() {
        assertEquals(900, OverlayBounds.resolveSize(1200, 100, 900));
        assertEquals(100, OverlayBounds.resolveSize(-2, 100, 900));
    }

    @Test
    public void topAlignedFullHeightStartsBelowStatusBar() {
        int height = OverlayBounds.resolveSize(-1, 100, 900);
        assertEquals(24, OverlayBounds.constrainPosition(800, height, 1000, 24, 924, -1));
    }

    @Test
    public void bottomAlignedWindowLeavesNavigationBarVisible() {
        assertEquals(76, OverlayBounds.constrainPosition(0, 100, 1000, 24, 924, 1));
        assertEquals(876, OverlayBounds.constrainPosition(1000, 100, 1000, 24, 924, 1));
    }

    @Test
    public void centeredWindowHonorsBothInsets() {
        assertEquals(-426, OverlayBounds.constrainPosition(-1000, 100, 1000, 24, 924, 0));
        assertEquals(374, OverlayBounds.constrainPosition(1000, 100, 1000, 24, 924, 0));
    }

    @Test
    public void fullCoverCanStillUseEntireScreen() {
        int height = OverlayBounds.resolveSize(-1, 100, 1000);
        assertEquals(1000, height);
        assertEquals(0, OverlayBounds.constrainPosition(100, height, 1000, 0, 1000, -1));
    }
}
