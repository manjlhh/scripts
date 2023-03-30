#!/usr/bin/env sh

pkgs=(
    "com.android.bookmarkprovider"
    "com.android.egg"
    "com.android.providers.partnerbookmarks"
    "com.android.wallpaper.livepicker"
    "com.facebook.appmanager"
    "com.facebook.services"
    "com.facebook.system"
    "com.google.android.apps.photos"
    "com.google.android.apps.tachyon"
    "com.google.android.apps.youtube.music"
    "com.google.android.feedback"
    "com.google.android.marvin.talkback"
    "com.google.android.projection.gearhead"
    "com.google.android.safetycore"
    "com.google.android.videos"
    "com.mi.globalbrowser"
    "com.mi.globalminusscreen"
    "com.miui.analytics"
    "com.miui.bugreport"
    "com.miui.daemon"
    "com.miui.miservice"
    "com.miui.msa.global"
    "com.miui.player"
    "com.miui.videoplayer"
    "com.miui.yellowpage"
    "com.xiaomi.glgm"
    "com.xiaomi.mipicks"
    "com.xiaomi.payment"
    "com.xiaomi.xmsfkeeper"
)

for pkg in "${pkgs[@]}"; do
    adb shell pm uninstall --user 0 "$pkg"
done

exit
# reinstall package
for pkg in "${pkgs[@]}"; do
    adb shell cmd package install-existing "$pkg"
done
