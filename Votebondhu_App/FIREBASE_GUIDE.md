# Firebase Integration Guide for VoteBondhu

## 1. Setup Firebase Project
1.  Go to [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add Project** and name it `VoteBondhu`.
3.  Disable Google Analytics for getting started quickly (optional).
4.  Click **Create Project**.

## 2. Add Android App
1.  In the Firebase Project Overview, click the **Android** icon (robot).
2.  **Package Name**: Enter `com.example.test_app` (Verify this in your `android/app/build.gradle.kts` under `applicationId`).
3.  **App Nickname**: VoteBondhu (Optional).
4.  Click **Register App**.
5.  **Download config file**: Download `google-services.json`.
6.  **Move File**: Place this file in `android/app/` folder of your project.

## 3. Add iOS App (Optional for Mac/iOS)
1.  Click **Add App** -> **iOS**.
2.  **Bundle ID**: `com.example.testApp` (Check Xcode runner project).
3.  Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

## 4. Enable Authentication
1.  In Firebase Console, go to **Build** -> **Authentication**.
2.  Click **Get Started**.
3.  Select **Email/Password**.
4.  Toggle **Enable**.
5.  Click **Save**.

## 5. Re-enable Firebase in Code
You previously reverted the changes. To enable them again:
1.  Uncomment `id("com.google.gms.google-services")` in `android/app/build.gradle.kts`.
2.  Uncomment `id("com.google.gms.google-services") version "4.4.2" apply false` in `android/settings.gradle.kts`.
3.  In `lib/main.dart`, uncomment `await Firebase.initializeApp();`.
4.  In `lib/controllers/auth_controller.dart`, swap logic back to use `FirebaseAuth`.

## 6. Run the App
Run `flutter run`. If you added `google-services.json` correctly, it will work.
