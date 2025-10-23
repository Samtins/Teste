package com.pz.mobileinput;

import android.os.SystemClock;
import android.view.MotionEvent;
import android.view.View;

import java.util.Arrays;

public class TouchInjector {
    private final View targetView;

    // We support up to two concurrent pointers: 0 = keyboard(virtual stick), 1 = mouse(left button)
    private static final int MAX_POINTERS = 2;

    private final boolean[] pointerActive = new boolean[MAX_POINTERS];
    private final float[] pointerX = new float[MAX_POINTERS];
    private final float[] pointerY = new float[MAX_POINTERS];

    private long downTimeMs = 0L; // Time of first pointer down in current gesture

    public TouchInjector(View targetView) {
        this.targetView = targetView;
    }

    public boolean isPointerActive(int pointerId) {
        if (!isValid(pointerId)) return false;
        return pointerActive[pointerId];
    }

    public void tapSingle(float x, float y) {
        // Simple single-pointer tap using pointer 1 (mouse channel) if free, else pointer 0
        int pid = !pointerActive[1] ? 1 : 0;
        long t = SystemClock.uptimeMillis();
        MotionEvent down = MotionEvent.obtain(
                t, t,
                MotionEvent.ACTION_DOWN,
                x, y, 0
        );
        targetView.dispatchTouchEvent(down);
        down.recycle();

        long t2 = t + 20;
        MotionEvent up = MotionEvent.obtain(
                t, t2,
                MotionEvent.ACTION_UP,
                x, y, 0
        );
        targetView.dispatchTouchEvent(up);
        up.recycle();
    }

    public void setPointer(int pointerId, boolean active, float x, float y) {
        if (!isValid(pointerId)) return;

        int activeBefore = activeCount();
        boolean wasActive = pointerActive[pointerId];

        pointerX[pointerId] = x;
        pointerY[pointerId] = y;

        if (active && !wasActive) {
            // pointer goes DOWN
            pointerActive[pointerId] = true;
            onPointerDown(pointerId);
            return;
        }

        if (!active && wasActive) {
            // pointer goes UP
            onPointerUp(pointerId);
            pointerActive[pointerId] = false;
            if (activeCount() == 0) {
                downTimeMs = 0L;
            }
            return;
        }

        if (active && wasActive) {
            // MOVE
            if (activeBefore >= 1) {
                emitMove();
            }
        }
    }

    private void onPointerDown(int pointerId) {
        long eventTime = SystemClock.uptimeMillis();
        if (activeCount() == 0) {
            downTimeMs = eventTime;
        }

        int count = activeCount();
        if (count == 1) {
            // This is the very first pointer
            MotionEvent ev = MotionEvent.obtain(
                    downTimeMs, eventTime,
                    MotionEvent.ACTION_DOWN,
                    pointerX[pointerId], pointerY[pointerId], 0
            );
            targetView.dispatchTouchEvent(ev);
            ev.recycle();
            return;
        }

        // Second pointer: ACTION_POINTER_DOWN
        MotionEvent.PointerProperties[] props = buildProps();
        MotionEvent.PointerCoords[] coords = buildCoords();

        int actionIndex = indexOf(pointerId);
        int action = MotionEvent.ACTION_POINTER_DOWN | (actionIndex << MotionEvent.ACTION_POINTER_INDEX_SHIFT);

        MotionEvent ev = MotionEvent.obtain(
                downTimeMs, eventTime, action,
                count, props, coords, 0, 0, 1f, 1f, 0, 0, 0, 0
        );
        targetView.dispatchTouchEvent(ev);
        ev.recycle();
    }

    private void onPointerUp(int pointerId) {
        long eventTime = SystemClock.uptimeMillis();
        int count = activeCount();
        if (count == 1) {
            // This is the last pointer
            MotionEvent ev = MotionEvent.obtain(
                    downTimeMs, eventTime,
                    MotionEvent.ACTION_UP,
                    pointerX[pointerId], pointerY[pointerId], 0
            );
            targetView.dispatchTouchEvent(ev);
            ev.recycle();
            return;
        }

        // More than one pointer active: ACTION_POINTER_UP
        MotionEvent.PointerProperties[] props = buildProps();
        MotionEvent.PointerCoords[] coords = buildCoords();

        int actionIndex = indexOf(pointerId);
        int action = MotionEvent.ACTION_POINTER_UP | (actionIndex << MotionEvent.ACTION_POINTER_INDEX_SHIFT);

        MotionEvent ev = MotionEvent.obtain(
                downTimeMs, eventTime, action,
                count, props, coords, 0, 0, 1f, 1f, 0, 0, 0, 0
        );
        targetView.dispatchTouchEvent(ev);
        ev.recycle();

        emitMove(); // keep remaining pointer position consistent
    }

    private void emitMove() {
        long eventTime = SystemClock.uptimeMillis();
        MotionEvent.PointerProperties[] props = buildProps();
        MotionEvent.PointerCoords[] coords = buildCoords();
        int count = activeCount();

        MotionEvent ev = MotionEvent.obtain(
                downTimeMs == 0 ? eventTime : downTimeMs,
                eventTime,
                MotionEvent.ACTION_MOVE,
                count, props, coords, 0, 0, 1f, 1f, 0, 0, 0, 0
        );
        targetView.dispatchTouchEvent(ev);
        ev.recycle();
    }

    private MotionEvent.PointerProperties[] buildProps() {
        int count = activeCount();
        MotionEvent.PointerProperties[] props = new MotionEvent.PointerProperties[count];
        int outIdx = 0;
        for (int pid = 0; pid < MAX_POINTERS; pid++) {
            if (!pointerActive[pid]) continue;
            MotionEvent.PointerProperties p = new MotionEvent.PointerProperties();
            p.id = pid;
            p.toolType = MotionEvent.TOOL_TYPE_FINGER;
            props[outIdx++] = p;
        }
        return props;
    }

    private MotionEvent.PointerCoords[] buildCoords() {
        int count = activeCount();
        MotionEvent.PointerCoords[] coords = new MotionEvent.PointerCoords[count];
        int outIdx = 0;
        for (int pid = 0; pid < MAX_POINTERS; pid++) {
            if (!pointerActive[pid]) continue;
            MotionEvent.PointerCoords c = new MotionEvent.PointerCoords();
            c.x = pointerX[pid];
            c.y = pointerY[pid];
            c.pressure = 1f;
            c.size = 1f;
            coords[outIdx++] = c;
        }
        return coords;
    }

    private int indexOf(int pointerId) {
        int outIdx = 0;
        for (int pid = 0; pid < MAX_POINTERS; pid++) {
            if (!pointerActive[pid]) continue;
            if (pid == pointerId) return outIdx;
            outIdx++;
        }
        return 0; // should not happen if caller checks
    }

    private int activeCount() {
        int c = 0;
        for (boolean b : pointerActive) if (b) c++;
        return c;
    }

    private boolean isValid(int pointerId) {
        return pointerId >= 0 && pointerId < MAX_POINTERS;
    }

    @Override
    public String toString() {
        return "TouchInjector{" +
                "active=" + Arrays.toString(pointerActive) +
                ", x=" + Arrays.toString(pointerX) +
                ", y=" + Arrays.toString(pointerY) +
                '}';
    }
}
