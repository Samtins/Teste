package com.pz.mobileinput;

import android.view.MotionEvent;
import android.view.ViewConfiguration;

public class MouseMapper {
    public static final int CHANNEL_MOUSE = 1;

    private boolean leftPressed = false;
    private boolean rightPressed = false;
    private float lastX = 0f;
    private float lastY = 0f;

    public boolean onGenericMotionEvent(MotionEvent e, TouchInjector injector) {
        if ((e.getSource() & MotionEvent.SOURCE_MOUSE) == 0) return false;

        final int action = e.getActionMasked();
        switch (action) {
            case MotionEvent.ACTION_HOVER_MOVE: {
                lastX = e.getX();
                lastY = e.getY();
                if (leftPressed) {
                    injector.setPointer(CHANNEL_MOUSE, true, lastX, lastY);
                    return true;
                }
                return false;
            }
            case MotionEvent.ACTION_BUTTON_PRESS: {
                int buttons = e.getButtonState();
                lastX = e.getX();
                lastY = e.getY();
                if ((buttons & MotionEvent.BUTTON_PRIMARY) != 0) {
                    leftPressed = true;
                    injector.setPointer(CHANNEL_MOUSE, true, lastX, lastY);
                    return true;
                }
                if ((buttons & MotionEvent.BUTTON_SECONDARY) != 0) {
                    rightPressed = true;
                    // Map right-click to long-press at cursor
                    // Long-press duration heuristic
                    long longPressTimeout = ViewConfiguration.getLongPressTimeout();
                    injector.setPointer(CHANNEL_MOUSE, true, lastX, lastY);
                    // Release after long-press timeout to simulate context
                    new Thread(() -> {
                        try { Thread.sleep(longPressTimeout); } catch (InterruptedException ignored) {}
                        injector.setPointer(CHANNEL_MOUSE, false, lastX, lastY);
                    }).start();
                    return true;
                }
                return false;
            }
            case MotionEvent.ACTION_BUTTON_RELEASE: {
                int buttons = e.getButtonState();
                lastX = e.getX();
                lastY = e.getY();
                if (!leftPressed && !rightPressed) return false;
                if (leftPressed && (buttons & MotionEvent.BUTTON_PRIMARY) == 0) {
                    leftPressed = false;
                    injector.setPointer(CHANNEL_MOUSE, false, lastX, lastY);
                    return true;
                }
                if (rightPressed && (buttons & MotionEvent.BUTTON_SECONDARY) == 0) {
                    rightPressed = false;
                    injector.setPointer(CHANNEL_MOUSE, false, lastX, lastY);
                    return true;
                }
                return false;
            }
            case MotionEvent.ACTION_SCROLL: {
                // Could map to pinch/zoom or inventory scroll; leave unconsumed by default
                return false;
            }
            case MotionEvent.ACTION_MOVE: {
                lastX = e.getX();
                lastY = e.getY();
                if (leftPressed) {
                    injector.setPointer(CHANNEL_MOUSE, true, lastX, lastY);
                    return true;
                }
                return false;
            }
        }

        return false;
    }
}
