import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_domain/quiz_domain.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      const clientId =
          '550421245571-rlqquem056b4ob4ore7o6i97dob1frb8.apps.googleusercontent.com';
      await (_googleSignIn as dynamic).initialize(
        clientId: clientId,
        serverClientId: clientId,
      );
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _handleSignIn() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      return;
    }

    try {
      final dynamic googleUser =
          await (_googleSignIn as dynamic).authenticate(scopeHint: ['email']);
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final authz = await (googleUser as dynamic)
          .authorizationClient
          .authorizationForScopes(['email']);
      final String? accessToken = authz?.accessToken;

      if (idToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not get ID token from Google')));
        return;
      }

      await ref
          .read(authStateProvider.notifier)
          .signIn(idToken, accessToken ?? '');
    } catch (error) {
      if (!mounted) return;

      final errorStr = error.toString();
      if (errorStr.contains('canceled')) {
        // User canceled, show a gentle notice or stay silent
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign-in was cancelled',
              style: AppTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Authentication failed: $error'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ));
    }
  }

  Future<void> _handleSSOSignIn() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Enterprise SSO',
            style: AppTypography.h3.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your work email or organization domain.',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. acme.com',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          AppButton(
            label: 'Continue',
            onPressed: () => context.pop(controller.text.trim()),
            width: 120,
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(authStateProvider.notifier).signInWithSSO(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.goNamed('dashboard');
          }
        },
        error: (err, stack) {
          final errorStr = err.toString();
          if (errorStr.contains('canceled') || errorStr.contains('cancelled'))
            return;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorStr),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ));
        },
        loading: () {},
      );
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Color(0xFF1E1B4B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          _buildBackgroundParticles(),

          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                    tooltip: 'Go Back',
                    padding: EdgeInsets
                        .zero, // Remove default padding for better centering
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBrand(),
                    const SizedBox(height: AppSpacing.xxl),

                    // Glass Login Card
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Text('Sign In', style: AppTypography.h2),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Login to save your progress and create quizzes',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: 'Sign in with Google',
                            isLoading: isLoading,
                            onPressed: _handleSignIn,
                            type: AppButtonType.premium,
                            icon: const Icon(Icons.login_rounded, size: 20),
                          ).animate().shimmer(
                              duration: 2.seconds, color: Colors.white24),
                          const SizedBox(height: AppSpacing.md),
                          TextButton.icon(
                            onPressed: isLoading ? null : _handleSSOSignIn,
                            icon: const Icon(Icons.business_rounded,
                                size: 16, color: AppColors.secondary),
                            label: Text('Enterprise SSO',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                              'By continuing, you agree to join the global leaderboard.',
                              textAlign: TextAlign.center,
                              style: AppTypography.label.copyWith(
                                  fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        curve: AppAnimations.springCurve),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child:
              const Icon(Icons.psychology, size: 72, color: AppColors.primary),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2.seconds,
                curve: Curves.easeInOut)
            .shimmer(duration: 4.seconds, color: Colors.white24),
        const SizedBox(height: AppSpacing.lg),
        Text('QUIZ ARENA',
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              letterSpacing: 8,
              shadows: [Shadow(color: AppColors.primary, blurRadius: 20)],
            )),
        const SizedBox(height: AppSpacing.xs),
        Text('CHALLENGE YOUR INTELLIGENCE',
            style: AppTypography.label
                .copyWith(color: AppColors.secondary, letterSpacing: 2)),
      ],
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: -0.1, curve: AppAnimations.springCurve);
  }

  Widget _buildBackgroundParticles() {
    return Stack(
      children: List.generate(12, (index) {
        final size = 4.0 + (index % 4) * 2;
        return Positioned(
          top: 100.0 * (index % 8),
          left: (index * 50.0) % 400,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .moveY(
                  begin: 0,
                  end: -100,
                  duration: (3 + (index % 5)).seconds,
                  curve: Curves.linear)
              .fadeIn(duration: 500.ms)
              .then(delay: (2 + (index % 3)).seconds)
              .fadeOut(duration: 500.ms),
        );
      }),
    );
  }
}
