package flutter.overlay.window.flutter_overlay_window;

final class OverlayBounds {
    private OverlayBounds() {}

    static int resolveSize(int requested, int measured, int available) {
        if (requested == -1) return available;
        return Math.min(requested > 0 ? requested : measured, available);
    }

    // alignment: -1 = start, 0 = center, 1 = end.
    static int constrainPosition(int position, int size, int screenSize,
                                 int start, int end, int alignment) {
        int min;
        int max;
        if (alignment < 0) {
            min = start;
            max = end - size;
        } else if (alignment > 0) {
            min = screenSize - end;
            max = screenSize - start - size;
        } else {
            min = start - (screenSize - size) / 2;
            max = end - (screenSize + size) / 2;
        }
        return Math.max(min, Math.min(position, max));
    }
}
