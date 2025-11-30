# Deep Link Configuration Guide

This guide explains how to configure deep links for OAuth2 authentication in the Flutter app.

## Overview

The OAuth2 flow requires deep link configuration so the app can receive the redirect from the server after successful authentication.

**Deep Link Scheme**: `myapp://oauth2/redirect`

## Android Configuration

### 1. Update `android/app/src/main/AndroidManifest.xml`

Add the following intent filter inside the `<activity>` tag for `MainActivity`:

```xml
<activity
    android:name=".MainActivity"
    ...>
    
    <!-- Existing intent filters -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Add this for OAuth2 deep links -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="myapp"
            android:host="oauth2"
            android:pathPrefix="/redirect" />
    </intent-filter>
</activity>
```

## iOS Configuration

### 1. Update `ios/Runner/Info.plist`

Add the following inside the `<dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.today.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

## Server Configuration

### Update `application.yml`

Ensure the OAuth2 redirect URI in the server matches the deep link:

```yaml
app:
  oauth2:
    authorized-redirect-uri: myapp://oauth2/redirect
```

## Client Configuration

### Update OAuth2Service Base URL

In `lib/features/auth/data/services/oauth2_service.dart`, update the base URL:

```dart
static const String _baseUrl = 'http://YOUR_SERVER_IP:8080';
// For local testing: 'http://10.0.2.2:8080' (Android Emulator)
// For local testing: 'http://localhost:8080' (iOS Simulator)
```

## Testing

1. Run `flutter pub get` to install new dependencies
2. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate code
3. Build and run the app
4. Click "Sign in with Google" or "Sign in with Kakao"
5. Browser should open for authentication
6. After successful login, app should receive tokens via deep link

## Troubleshooting

### Deep Link Not Working
- Verify the scheme matches exactly: `myapp://oauth2/redirect`
- Check Android/iOS configuration files are correct
- Rebuild the app after configuration changes

### Server Not Redirecting
- Check server's `authorized-redirect-uri` matches the deep link
- Verify OAuth2 provider (Google/Kakao) has the correct redirect URI registered

### Tokens Not Received
- Check `OAuth2Service._extractTokens()` is parsing the URL correctly
- Verify server is sending tokens as query parameters
