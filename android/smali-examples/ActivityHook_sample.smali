# Example: Hook methods inside the game's main Activity to route input to our bridge
# Replace "Lcom/game/pkg/MainActivity;" with the real activity smali class name

.class public Lcom/game/pkg/MainActivity;
.super Landroid/app/Activity;

# Add field to hold the bridge instance
.field private kmBridge:Lcom/pz/mobileinput/KeyboardMouseBridge;

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 1

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # After your setContentView(...), install the bridge
    invoke-static {p0}, Lcom/pz/mobileinput/KeyboardMouseBridge;->installOn(Landroid/app/Activity;)Lcom/pz/mobileinput/KeyboardMouseBridge;
    move-result-object v0
    iput-object v0, p0, Lcom/game/pkg/MainActivity;->kmBridge:Lcom/pz/mobileinput/KeyboardMouseBridge;

    return-void
.end method

.method public dispatchKeyEvent(Landroid/view/KeyEvent;)Z
    .locals 2

    iget-object v0, p0, Lcom/game/pkg/MainActivity;->kmBridge:Lcom/pz/mobileinput/KeyboardMouseBridge;
    if-eqz v0, :super_call

    invoke-virtual {v0, p1}, Lcom/pz/mobileinput/KeyboardMouseBridge;->handleKeyEvent(Landroid/view/KeyEvent;)Z
    move-result v1
    if-eqz v1, :super_call
    const/4 v1, 0x1
    return v1

  :super_call
    invoke-super {p0, p1}, Landroid/app/Activity;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z
    move-result v1
    return v1
.end method

.method public dispatchGenericMotionEvent(Landroid/view/MotionEvent;)Z
    .locals 2

    iget-object v0, p0, Lcom/game/pkg/MainActivity;->kmBridge:Lcom/pz/mobileinput/KeyboardMouseBridge;
    if-eqz v0, :super_call_g

    invoke-virtual {v0, p1}, Lcom/pz/mobileinput/KeyboardMouseBridge;->handleGenericMotionEvent(Landroid/view/MotionEvent;)Z
    move-result v1
    if-eqz v1, :super_call_g
    const/4 v1, 0x1
    return v1

  :super_call_g
    invoke-super {p0, p1}, Landroid/app/Activity;->dispatchGenericMotionEvent(Landroid/view/MotionEvent;)Z
    move-result v1
    return v1
.end method
