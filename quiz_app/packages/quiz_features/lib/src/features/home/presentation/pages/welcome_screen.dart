import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// For HapticFeedback


import 'package:quiz_ui_core/quiz_ui_core.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _gamePinController = TextEditingController();

  void _scanQR() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AppQRScanner(
          onScan: (code) {
            // Assuming code contains the PIN directly.
            // If it's a URL, we might need to parse it.
            // For now, take the last 6 digits or the whole string if length <= 6
            String pin = code.trim();
            if (pin.length > 6) {
              // Try to extract 6 digit number
              final regex = RegExp(r'\d{6}');
              final match = regex.firstMatch(pin);
              if (match != null) {
                pin = match.group(0)!;
              }
            }

            setState(() {
              _gamePinController.text = pin;
            });
            Navigator.pop(context); // Close scanner

            if (pin.length == 6) {
              _joinGame(); // Auto-join if valid length
            }
          },
        ),
      ),
    );
  }

  void _joinGame() {
    final pin = _gamePinController.text;
    if (pin.length == 6) {
      context.pushNamed('join', extra: pin);
    } else {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pin.isEmpty
                ? 'Please enter a Game PIN'
                : 'Game PIN must be 6 digits',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _gamePinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic Background (Consistent with LoginPage)
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

          // Main Content Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBrand().animate().fadeIn(duration: 800.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        curve: AppAnimations.springCurve),

                    const SizedBox(height: AppSpacing.xl * 2),

                    // Glass Join Card
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter Game PIN',
                            textAlign: TextAlign.center,
                            style:
                                AppTypography.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            controller: _gamePinController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            style: AppTypography.h2.copyWith(
                                color: Colors.white, letterSpacing: 8),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: '000000',
                              hintStyle: AppTypography.h2.copyWith(
                                  color: Colors.white24, letterSpacing: 8),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                borderSide: const BorderSide(
                                    color: AppColors.secondary, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.qr_code_scanner_rounded,
                                    color: AppColors.secondary),
                                onPressed: _scanQR,
                                tooltip: 'Scan Game PIN',
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: 'Join Arena',
                            type: AppButtonType.premium,
                            onPressed: _joinGame,
                            icon: const Icon(Icons.bolt, color: Colors.white),
                          ).animate().shimmer(
                              duration: 2.seconds, color: Colors.white24),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, curve: AppAnimations.springCurve),

                    const SizedBox(height: AppSpacing.xl),

                    TextButton(
                      onPressed: () {
                        context.pushNamed('login');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodySmall
                              .copyWith(color: Colors.white70),
                          children: [
                            const TextSpan(text: 'Host or Create Quizzes? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),
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
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: const Icon(Icons.rocket_launch_rounded,
              size: 72, color: AppColors.secondary),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
                curve: Curves.easeInOut)
            .rotate(
                begin: -0.05,
                end: 0.05,
                duration: 4.seconds,
                curve: Curves.easeInOut),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'QUIZ ARENA',
          style: AppTypography.h1.copyWith(
            color: Colors.white,
            fontSize: 44,
            letterSpacing: 6,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: AppColors.secondary, blurRadius: 30),
              Shadow(
                  color: Colors.black45,
                  offset: const Offset(0, 5),
                  blurRadius: 10),
            ],
          ),
        ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.2),
        Text(
          'COMPETE • LEARN • WIN',
          style: AppTypography.label.copyWith(
            color: AppColors.secondary.withValues(alpha: 0.9),
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildBackgroundParticles() {
    return Stack(
      children: List.generate(10, (index) {
        final size = 3.0 + (index % 3) * 2;
        return Positioned(
          top: 120.0 * (index % 7),
          right: (index * 60.0) % 400,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .moveY(
                  begin: 0,
                  end: 80,
                  duration: (4 + (index % 4)).seconds,
                  curve: Curves.linear)
              .fadeIn(duration: 600.ms)
              .then(delay: (2 + (index % 2)).seconds)
              .fadeOut(duration: 600.ms),
        );
      }),
    );
  }
}
