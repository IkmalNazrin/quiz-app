import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';
import '../../../../features/challenge/presentation/providers/challenge_provider.dart';
import '../../../quiz/presentation/pages/browse_screen.dart';
import '../../../../features/profile/presentation/pages/profile_screen.dart';
import '../../../../features/challenge/presentation/pages/arena_page.dart';
import '../../../quiz/presentation/pages/workshop_screen.dart';
import 'package:quiz_features/quiz_features.dart';

// For HapticFeedback

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();

  void _scanQR() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AppQRScanner(
          onScan: (code) {
            String pin = code.trim();
            if (pin.length > 6) {
              final regex = RegExp(r'\d{6}');
              final match = regex.firstMatch(pin);
              if (match != null) {
                pin = match.group(0)!;
              }
            }

            setState(() {
              _pinController.text = pin;
            });
            Navigator.pop(context);

            if (pin.length == 6) {
              _joinGame();
            }
          },
        ),
      ),
    );
  }

  String? _username;
  String? _userId;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshData();
    });
  }

  // --- Private Logic ---

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final user = ref.read(authStateProvider).value;
    if (!mounted) throw Exception('Widget is no longer mounted');

    if (user == null) {
      _logout(context);
      throw Exception('Not authenticated');
    }

    if (mounted) {
      setState(() {
        _userId = user.id;
        _username = user.name ?? 'User';
      });
    }

    ref.invalidate(myQuizzesProvider);
    ref.invalidate(myChallengesProvider);

    return {'currentUserId': user.id};
  }

  Future<void> _refreshData() async {
    final newFuture = _fetchDashboardData();
    if (mounted) {
      try {
        await newFuture;
      } catch (e) {
        AppLogger.e("Data fetch failed: $e", category: LogCategory.ui);
      }
    }
  }

  void _logout(BuildContext context) async {
    await ref.read(authStateProvider.notifier).signOut();
    if (context.mounted) {
      context.goNamed('login');
    }
  }

  // Unused method removed to clean up lint warnings
  // void _navigateToProfile() {
  //   Navigator.push(context, CupertinoPageRoute(builder: (_) => const ProfileScreen()));
  // }

  void _startChallenge(String challengeId) async {
    await context.pushNamed('challenge', extra: {'challengeId': challengeId});
    if (mounted) await _refreshData();
  }

  void _navigateToHostGame(String quizId, String quizTitle) async {
    await context.pushNamed(
      'host',
      pathParameters: {'quizId': quizId},
      queryParameters: {'title': quizTitle},
    );
    if (mounted) await _refreshData();
  }

  void _joinGame() {
    final gamePin = _pinController.text.trim();
    if (gamePin.length == 6) {
      context.pushNamed('join', extra: gamePin);
      _pinController.clear();
    } else {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gamePin.isEmpty
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
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(myChallengesProvider).when(
          data: (challenges) => _buildScaffold(challenges),
          loading: () => _buildLoadingScaffold(),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text('Error: $err'))),
        );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: StarryBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.getHeaderHeight(context) + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.bottomNavBarPadding),
          child: Column(
            children:
                List.generate(5, (index) => const ChallengeCardSkeleton()),
          ),
        ),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GamifiedNavBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
          Positioned(
            top: -18,
            child: PlayActionButton(
              isActive: _selectedIndex == 2,
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold(List<ChallengeEntity> challenges) {
    final pageTitles = ['Discover', 'Arena', 'Play', 'Workshop', 'Profile'];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: StarryBackground(
        child: Stack(
          children: [
            // Content Area
            AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: IndexedStack(
                key: ValueKey(_selectedIndex),
                index: _selectedIndex,
                children: [
                  BrowseScreen(onHostGame: _navigateToHostGame),
                  ArenaPage(
                    challenges: challenges,
                    currentUserId: _userId ?? '',
                    onStartChallenge: _startChallenge,
                  ),
                  _buildPlaySection(),
                  WorkshopScreen(onHostGame: _navigateToHostGame),
                  const ProfileScreen(isNested: true),
                ],
              ),
            ),

            // Global Glass Header
            if (_selectedIndex != 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GlassHeader(
                  title: Text(pageTitles[_selectedIndex]),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.primary, size: 22),
                      onPressed: () => _refreshData(),
                    ),
                    const SizedBox(width: 8),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GamifiedNavBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
          Positioned(
            top: -18,
            child: PlayActionButton(
              isActive: _selectedIndex == 2,
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaySection() {
    final headerHeight = AppSpacing.getHeaderHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, headerHeight + AppSpacing.lg,
          AppSpacing.xl, AppSpacing.bottomNavBarPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkspaceSwitcher(),
          const SizedBox(height: AppSpacing.lg),
          Text('Welcome back,', style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(_username ?? 'Explorer', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.primaryGlow,
                      ),
                      child: const Icon(Icons.qr_code_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Join Live Game', style: AppTypography.h3),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.h2
                      .copyWith(letterSpacing: 8, color: AppColors.secondary),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit PIN',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                        letterSpacing: 0,
                        color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.primary),
                      onPressed: _scanQR,
                      tooltip: 'Scan Game PIN',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Join Arena',
                  onPressed: _joinGame,
                  icon: const Icon(Icons.bolt_rounded),
                  color: AppColors.primary,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
