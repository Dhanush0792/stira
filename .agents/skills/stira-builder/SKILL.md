# Stira Build Optimizer Skill

This skill automates the remediation of common Android build failures for the Stira application, specifically targeting AAPT2 resource conflicts and dependency mismatches.

## 🎯 Primary Functions
1. **Environment Sanitation**: Force-terminates hanging `dart`, `flutter`, `java`, and `gradlew` processes that often lock the `build` directory.
2. **Asset Integrity Check**: Verifies that all `mipmap` icons are valid 192x192 PNGs and matches their file signatures (headers) to their extensions.
3. **Dependency Sync**: Ensures `compileSdk` and `targetSdk` are locked at 36 and `flutter_native_splash` is properly categorized as a primary dependency.
4. **Optimized Build**: Executes `gradlew assembleRelease` with optimized JVM settings for lower-memory environments.

## 🛠 Usage
Whenever asked to "Build for Stira" or "Fix Stira Build", follow these steps:

### 1. Sanitize Environment
Run these commands to clear locks:
```powershell
Stop-Process -Name "java", "dart", "flutter", "gradlew" -ErrorAction SilentlyContinue
```

### 2. Verify Assets
Run the `scripts/optimize_assets.ps1` script (included in this skill) to check for corrupted icon headers or resolution mismatches.

### 3. Build Command
Use the optimized Gradle command:
```powershell
flutter clean; flutter pub get; cd android; gradlew assembleRelease --no-daemon
```

## 📂 Artifact Management
- Final APKs should be moved to the `stira_versions/` folder.
- The latest stable version should always be symlinked or copied to the project root as `STIRA_PRODUCTION.apk`.
