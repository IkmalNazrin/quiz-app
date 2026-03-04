# Final Steps to Fix Google Sign-In & Build Errors

We've made great progress! Here is how to resolve the remaining issues based on the logs you provided.

## 1. Fix "oauth_client: []" in `google-services.json`
The file you pasted is still missing the OAuth configuration. This is why sign-in "cancels" or fails immediately.

**How to fix:**
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Go to **Project Settings** (gear icon) > **General**.
3. Scroll down to your Android app.
4. Ensure the **SHA-1 fingerprint** you found earlier (`12:14:30:4b:3f:50:7d:fa:31:3a:f4:cc:d2:9a:84:bc:83:85:31:91`) is added and saved.
5. Go to **Authentication** > **Sign-in method**.
6. Enable **Google** as a provider.
7. **CRITICAL**: Go back to Project Settings and download the `google-services.json` **AGAIN**. It should now contain entries inside `"oauth_client"`.

## 2. Fix "Building with plugins requires symlink support"
This is a Windows environment issue. Flutter needs permission to create symlinks to build plugins.

**How to fix:**
- **Option A (Recommended)**: Enable **Developer Mode** in Windows. 
  - Open Windows Settings > Update & Security > For developers.
  - Turn **Developer Mode** to **On**.
- **Option B**: Run your terminal (PowerShell or CMD) as **Administrator** before running `flutter run`.

## 3. Current Code Status
I have already refactored `LoginPage.dart` to use the standard API. Once you have the correct `google-services.json` and fix the symlink issue, the app will build and authenticate correctly.

### Next Steps
1. Enable Developer Mode or use an Admin terminal.
2. Replace the JSON with the one that contains `oauth_client`.
3. Run:
   ```powershell
   flutter clean
   flutter run
   ```
