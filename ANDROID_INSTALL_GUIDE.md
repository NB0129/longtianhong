# Android Install Guide

This project currently has a debug APK for real-device testing at:

```powershell
C:\Users\hskst\work\longtianhong\build\longtianhong-debug.apk
```

ADB is available at:

```powershell
C:\Users\hskst\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

## Install To Connected Device

1. Connect the Android phone by USB.
2. Enable USB debugging on the phone.
3. If the phone asks whether to allow USB debugging, allow it.
4. Run:

```powershell
& 'C:\Users\hskst\AppData\Local\Android\Sdk\platform-tools\adb.exe' devices -l
& 'C:\Users\hskst\AppData\Local\Android\Sdk\platform-tools\adb.exe' install -r 'C:\Users\hskst\work\longtianhong\build\longtianhong-debug.apk'
```

If the device appears as `unauthorized`, unlock the phone and approve the USB debugging prompt, then run the commands again.

## Launch After Install

```powershell
& 'C:\Users\hskst\AppData\Local\Android\Sdk\platform-tools\adb.exe' shell monkey -p com.nb0129.longtianhong -c android.intent.category.LAUNCHER 1
```
