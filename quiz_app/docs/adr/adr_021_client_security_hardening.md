# ADR 021: Client Security Hardening (Phase A)

## 1. Context
As the Quiz App prepares for a global production launch with enterprise requirements, we must elevate the security posture of the client application. Specifically, we need to address two primary threat vectors:
1. **Device Integrity**: Malicious actors using rooted/jailbroken devices or emulators to scrape APIs, farm points, or reverse-engineer the application logic.
2. **Offline Data Security**: With the introduction of the `SyncQueueService` for connectivity resilience (ADR 009/015), game events and answers are temporarily stored on the device. Storing this in plain text allows local tampering before it syncs to the server.
3. **Data Privacy (GDPR/CCPA)**: We need a reliable mechanism for users to delete their accounts and scrub Personally Identifiable Information (PII) without corrupting historical game analytics.

## 2. Decisions

### 2.1 Device Integrity Checks
We will implement runtime device integrity checks using the `flutter_jailbreak_detection` package.
*   **Behavior**: Upon application startup, `DeviceIntegrityService` will verify the environment.
*   **Action**: If a compromised environment is detected (e.g., rooted Android, jailbroken iOS, or running on an emulator in release mode), the app will refuse to proceed to authenticated routes, log the event locally via `AppLogger`, and enforce a logout state.

### 2.2 Local Encryption for Offline Sync
We will upgrade the in-memory `SyncQueueService` to persist pending actions to local storage, encrypted symmetrically.
*   **Key Generation**: A cryptographically secure 256-bit AES key will be generated on first launch.
*   **Key Storage**: The AES key will be stored in the device's secure enclave/keystore using `flutter_secure_storage`.
*   **Data Storage**: The pending action queue will be serialized to JSON and encrypted using the AES key (via the `encrypt` package) before being written to the device's local file system.

### 2.3 Account Deletion Strategy (Right to be Forgotten)
We will implement a hard-delete strategy for PII while maintaining referential integrity for game data.
*   **RPC Method**: A custom PostgreSQL function `delete_user_account()` will be created.
*   **Process**:
    1.  Delete the user's identity from `auth.users` (revoking all tokens).
    2.  Anonymize the user's record in the public `users` table by setting `name` to 'Deleted User', `email` to null, and `avatar_url` to null.
    3.  Leave the `id` intact. This ensures that `game_answers` and `game_sessions` linked to this user are not orphaned or deleted through cascades, preserving historical analytics.

## 3. Consequences

### Positive
*   **Tamper Resistance**: Offline queue manipulation is significantly harder due to symmetric AES encryption.
*   **API Protection**: Root detection raises the bar against automated scraping and cheating tools.
*   **Compliance**: Full GDPR/CCPA "Right to be Forgotten" compliance without destroying game balance or corrupted dashboards.

### Negative
*   **Performance Hit**: Encryption/Decryption of the sync queue adds a minor computational cost to disk I/O.
*   **False Positives**: Some legitimate users on custom ROMs or modified devices will be blocked from accessing the application. 
*   **Maintenance**: Key rotation and secure storage edge cases (e.g., Android Backup/Restore) will require ongoing monitoring.
