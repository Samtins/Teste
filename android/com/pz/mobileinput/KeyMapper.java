package com.pz.mobileinput;

import android.view.KeyEvent;

import java.util.HashSet;
import java.util.Set;

public class KeyMapper {
    public static final int CHANNEL_KEYBOARD = 0;

    private final Set<Integer> pressed = new HashSet<>();

    // Viewport dimensions in pixels (set by bridge)
    private int viewportW = 0;
    private int viewportH = 0;

    // Joystick anchor and radius as percentages of viewport
    private float anchorXPct = 0.15f; // 15% from left
    private float anchorYPct = 0.80f; // 80% from top
    private float radiusPct = 0.12f;  // 12% of min(width, height)

    // Action button position (for SPACE tap)
    private float actionXPct = 0.85f;
    private float actionYPct = 0.75f;

    public static class MovementState {
        public final boolean active;
        public final float x;
        public final float y;

        public MovementState(boolean active, float x, float y) {
            this.active = active;
            this.x = x;
            this.y = y;
        }
    }

    public static class TapAction {
        public final boolean requested;
        public final float x;
        public final float y;

        public TapAction(boolean requested, float x, float y) {
            this.requested = requested;
            this.x = x;
            this.y = y;
        }
    }

    public void setViewport(int w, int h) {
        viewportW = Math.max(1, w);
        viewportH = Math.max(1, h);
    }

    public void setAnchors(float anchorXPct, float anchorYPct, float radiusPct) {
        this.anchorXPct = clamp01(anchorXPct);
        this.anchorYPct = clamp01(anchorYPct);
        this.radiusPct = clamp01(radiusPct);
    }

    public void setActionButton(float xPct, float yPct) {
        this.actionXPct = clamp01(xPct);
        this.actionYPct = clamp01(yPct);
    }

    public boolean onKeyEvent(KeyEvent e) {
        int code = e.getKeyCode();
        int action = e.getAction();

        if (action == KeyEvent.ACTION_DOWN && !e.isRepeat()) {
            pressed.add(code);
        } else if (action == KeyEvent.ACTION_UP) {
            pressed.remove(code);
        }
        return true;
    }

    public MovementState getMovement() {
        boolean up = isPressed(KeyEvent.KEYCODE_W) || isPressed(KeyEvent.KEYCODE_DPAD_UP);
        boolean down = isPressed(KeyEvent.KEYCODE_S) || isPressed(KeyEvent.KEYCODE_DPAD_DOWN);
        boolean left = isPressed(KeyEvent.KEYCODE_A) || isPressed(KeyEvent.KEYCODE_DPAD_LEFT);
        boolean right = isPressed(KeyEvent.KEYCODE_D) || isPressed(KeyEvent.KEYCODE_DPAD_RIGHT);

        int vx = (right ? 1 : 0) - (left ? 1 : 0);
        int vy = (down ? 1 : 0) - (up ? 1 : 0);

        boolean active = (vx != 0) || (vy != 0);
        if (!active) return new MovementState(false, 0f, 0f);

        float ax = anchorXPct * viewportW;
        float ay = anchorYPct * viewportH;
        float r = radiusPct * Math.min(viewportW, viewportH);

        float nx = vx == 0 ? 0f : (vx > 0 ? 1f : -1f);
        float ny = vy == 0 ? 0f : (vy > 0 ? 1f : -1f);

        float x = ax + nx * r;
        float y = ay + ny * r;
        return new MovementState(true, x, y);
    }

    public TapAction getSpaceTapIfAny() {
        boolean space = isPressed(KeyEvent.KEYCODE_SPACE) || isPressed(KeyEvent.KEYCODE_BUTTON_A);
        if (!space) return new TapAction(false, 0f, 0f);
        float x = actionXPct * viewportW;
        float y = actionYPct * viewportH;
        return new TapAction(true, x, y);
    }

    private boolean isPressed(int keyCode) {
        return pressed.contains(keyCode);
    }

    private float clamp01(float v) {
        if (v < 0f) return 0f;
        if (v > 1f) return 1f;
        return v;
    }
}
