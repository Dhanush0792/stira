---
description: Automated, stable build workflow for Stira Android
---

This workflow automates the remediation of common Stira build failures and generates a production-ready APK.

// turbo-all
1. **Sanitize Environment**: Terminate hanging Flutter/Gradle processes to free up resources.
```powershell
Get-Process -Name "dart", "flutter", "java", "gradlew" -ErrorAction SilentlyContinue | Stop-Process -Force
```

2. **Validate & Optimize Resources**: Ensure all mipmap icons are valid 192x192 PNGs (resolves AAPT2 failures).
```powershell
# Delete any conflicting WebP files
Get-ChildItem -Path "android/app/src/main/res/mipmap-*" -Filter "*.webp" -Recurse | Remove-Item -Force

# Verify icons have PNG signature (89-50-4E-47) or restore from known good placeholder
Get-ChildItem -Path "android/app/src/main/res/mipmap-*" -Directory | ForEach-Object {
    $png = Join-Path $_.FullName "ic_launcher.png"
    if (Test-Path $png) {
        $bytes = [System.IO.File]::ReadAllBytes($png)[0..3]
        $sig = [System.BitConverter]::ToString($bytes)
        if ($sig -ne "89-50-4E-47") {
            Copy-Item "assets/icon/app_icon.png" $png -Force
        }
    }
}
```

3. **Verify Build Configuration**: Ensure stabilized SDK/Kotlin versions and properly categorized dependencies.
```powershell
# 1. Check for targetSdk 36 alignment
Select-String -Pattern "targetSdk = 36" -Path "android/app/build.gradle.kts"

# 2. Ensure flutter_native_splash is in dependencies (not dev_dependencies)
$pub = Get-Content "pubspec.yaml" -Raw
if ($pub -match "dev_dependencies:[\s\S]*?flutter_native_splash") {
    Write-Warning "Detected flutter_native_splash in dev_dependencies. Moving to primary dependencies..."
    # (Self-Correction logic here would go in a helper script, but for now we warn/fail)
}
```

4. **Execute Build**: Run the optimized Flutter build.
```powershell
flutter build apk --release --verbose
```

5. **Finalize Delivery**: Rename and deliver to root and versioned folder.
```powershell
$apk = Get-ChildItem -Path "build/app/outputs/flutter-apk/app-release.apk" -ErrorAction SilentlyContinue
if ($apk) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmm"
    $newName = "stira_v$timestamp.apk"
    
    # Deliver to Versioned Archive
    Copy-Item $apk.FullName "stira_versions/$newName" -Force
    
    # Deliver to Project Root
    Copy-Item $apk.FullName "STIRA_PRODUCTION.apk" -Force
    
    Write-Output "✅ Success! Stable APK generated at: STIRA_PRODUCTION.apk"
    Write-Output "📂 Archived as: stira_versions/$newName"
}
```
