package com.pz.mobileinput;

import android.app.Activity;
import android.graphics.Rect;
import android.os.Build;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;

public class KeyboardMouseBridge {
    private final Activity activity;
    private View targetView;
    private final TouchInjector injector;
    private final KeyMapper keyMapper = new KeyMapper();
    private final MouseMapper mouseMapper = new MouseMapper();

    private boolean passThroughMouse = false; // if true, also let app consume mouse events

    private KeyboardMouseBridge(Activity activity, View targetView) {
        this.activity = activity;
        this.targetView = targetView;
        this.injector = new TouchInjector(targetView);
        watchViewportChanges(targetView);
        if (Build.VERSION.SDK_INT >= 26) {
            try {
                targetView.requestPointerCapture();
            } catch (Throwable ignored) { }
        }
    }

    public static KeyboardMouseBridge installOn(Activity activity) {
        View content = activity.findViewById(android.R.id.content);
        View target = content != null ? content : activity.getWindow().getDecorView();
        KeyboardMouseBridge bridge = new KeyboardMouseBridge(activity, target);
        return bridge;
    }

    public void setPassThroughMouse(boolean passThrough) {
        this.passThroughMouse = passThrough;
    }

    public void setAnchors(float anchorXPct, float anchorYPct, float radiusPct) {
        keyMapper.setAnchors(anchorXPct, anchorYPct, radiusPct);
    }

    public void setActionButton(float xPct, float yPct) {
        keyMapper.setActionButton(xPct, yPct);
    }

    public boolean handleKeyEvent(KeyEvent e) {
        keyMapper.onKeyEvent(e);

        KeyMapper.MovementState m = keyMapper.getMovement();
        if (m.active) {
            injector.setPointer(KeyMapper.CHANNEL_KEYBOARD, true, m.x, m.y);
        } else if (injector.isPointerActive(KeyMapper.CHANNEL_KEYBOARD)) {
            injector.setPointer(KeyMapper.CHANNEL_KEYBOARD, false, 0, 0);
        }

        KeyMapper.TapAction tap = keyMapper.getSpaceTapIfAny();
        if (tap.requested && !injector.isPointerActive(KeyMapper.CHANNEL_KEYBOARD) && !injector.isPointerActive(MouseMapper.CHANNEL_MOUSE)) {
            injector.tapSingle(tap.x, tap.y);
            return true;
        }

        return m.active || tap.requested;
    }

    public boolean handleGenericMotionEvent(MotionEvent e) {
        boolean consumed = mouseMapper.onGenericMotionEvent(e, injector);
        return consumed && !passThroughMouse;
    }

    private void watchViewportChanges(View view) {
        ViewTreeObserver vto = view.getViewTreeObserver();
        vto.addOnGlobalLayoutListener(() -> updateViewport());
        view.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> updateViewport());
        updateViewport();
    }

    private void updateViewport() {
        Rect r = new Rect();
        targetView.getWindowVisibleDisplayFrame(r);
        int w = Math.max(1, r.width());
        int h = Math.max(1, r.height());
        keyMapper.setViewport(w, h);
    }
}
