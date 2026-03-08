import 'package:flutter/material.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

/// A dialog wrapper for the Cloudflare Turnstile CAPTCHA challenge.
///
/// Usage:
/// ```dart
/// final token = await showTurnstileDialog(context);
/// if (token != null) { /* proceed with auth */ }
/// ```
///
/// The site key is read from AppConfig.turnstileSiteKey (.env).
/// If the site key is not configured, the dialog is skipped (development mode).
///
/// ADR Reference: ADR-026 (Security Remediation) — CAPTCHA guard for anonymous auth.
class TurnstileCaptchaDialog extends StatefulWidget {
  const TurnstileCaptchaDialog({super.key});

  @override
  State<TurnstileCaptchaDialog> createState() => _TurnstileCaptchaDialogState();
}

class _TurnstileCaptchaDialogState extends State<TurnstileCaptchaDialog> {
  bool _hasCompleted = false;

  @override
  Widget build(BuildContext context) {
    final siteKey = AppConfig.turnstileSiteKey;

    // If no site key is configured (development), auto-pass immediately.
    if (siteKey.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop('__dev_bypass__');
      });
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: const Color(0xFF1E1B4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verify you\'re human',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Complete the security check to continue.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CloudflareTurnstile(
              siteKey: siteKey,
              options: const TurnstileOptions(
                theme: TurnstileTheme.dark,
                size: TurnstileSize.normal,
              ),
              onTokenReceived: (token) {
                if (_hasCompleted) return;
                _hasCompleted = true;
                Navigator.of(context).pop(token);
              },
              onTokenExpired: () {
                // Token expired before dialog was closed; reset to allow retry
                setState(() => _hasCompleted = false);
              },
              onError: (error) {
                if (mounted) {
                  Navigator.of(context).pop(null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'Cancel',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience function to show the Turnstile CAPTCHA dialog.
///
/// Returns the token string on success, or null if cancelled/failed.
Future<String?> showTurnstileDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const TurnstileCaptchaDialog(),
  );
}
