import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/level_avatar.dart';
import '../widgets/rank_badge.dart';
import '../widgets/stat_item.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';
import '../widgets/history_view.dart';
import '../../../privacy/presentation/providers/privacy_provider.dart';
import 'dart:convert';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isNested;
  const ProfileScreen({super.key, this.isNested = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      ref.read(profileProvider.notifier).fetchProfile(user.id);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile(ProfileEntity currentProfile) async {
    final updatedProfile = currentProfile.copyWith(
      username: _usernameController.text,
      fullName: _fullNameController.text,
      bio: _bioController.text,
    );
    await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text('Logout?', style: AppTypography.h3),
          content: Text(
            'Are you sure you want to end your session?',
            style: AppTypography.bodySmall,
          ),
          actions: [
            TextButton(
              child:
                  Text('Stay', style: TextStyle(color: AppColors.textPrimary)),
              onPressed: () => context.pop(),
            ),
            TextButton(
              onPressed: _handleLogout,
              child: Text('Logout',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    context.pop(); // Close dialog
    await ref.read(authStateProvider.notifier).signOut();
    if (mounted) {
      context.goNamed('login');
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text('Delete Account',
              style: AppTypography.h3.copyWith(color: AppColors.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This action is permanent. Your personal details will be anonymized according to GDPR standards.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Your game scores will remain as "Deleted User" to preserve global leaderboard integrity.',
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textPrimary)),
              onPressed: () => context.pop(),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = context;
                try {
                  await ref.read(privacyStateProvider.notifier).deleteAccount();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  nav.goNamed('login');
                } catch (e) {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  unawaited(messenger
                      .showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      )
                      .closed);
                }
              },
              child: Text('Confirm Deletion',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDataExport() async {
    final data = await ref.read(privacyStateProvider.notifier).exportData();
    if (data != null && mounted) {
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Your Data Export'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => context.pop(), child: const Text('Close')),
          ],
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    final content = profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const SliverFillRemaining(
              child: Center(child: Text('No profile found.')));
        }
        return _buildSliverContent(profile);
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: const SliverToBoxAdapter(child: ProfileSkeleton()),
      ),
      error: (err, _) =>
          SliverFillRemaining(child: Center(child: Text('Error: $err'))),
    );

    return Stack(
      children: [
        // Background Decoration
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, -0.6),
                radius: 1.2,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                  height: AppSpacing.getHeaderHeight(context) +
                      AppSpacing.md), // Respect the GlassHeader height
            ),
            content,
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Text("Recent Activity", style: AppTypography.h3),
                    const Spacer(),
                    Icon(Icons.history_edu_rounded,
                        color: AppColors.primary.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            const SliverHistoryList(),
            const SliverPadding(
                padding:
                    EdgeInsets.only(bottom: AppSpacing.bottomNavBarPadding)),
          ],
        ),

        if (!widget.isNested)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              title: const Text('My Profile'),
              actions: [
                profileAsync.maybeWhen(
                  data: (profile) => profile != null
                      ? IconButton(
                          icon: Icon(
                              _isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_rounded,
                              color: AppColors.primary),
                          onPressed: () {
                            if (!_isEditing) {
                              _usernameController.text = profile.username;
                              _fullNameController.text = profile.fullName ?? '';
                              _bioController.text = profile.bio ?? '';
                            }
                            setState(() => _isEditing = !_isEditing);
                          },
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSliverContent(ProfileEntity profile) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Center(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                LevelAvatar(
                  avatarUrl: profile.avatarUrl,
                  totalXP: profile.totalPoints,
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: AppSpacing.lg),
                RankBadge(level: LevelCalculator.getLevel(profile.totalPoints))
                    .animate(delay: 200.ms)
                    .fadeIn()
                    .slideY(begin: 0.5),
                const SizedBox(height: AppSpacing.lg),
                if (!_isEditing) ...[
                  Text(profile.fullName ?? profile.username,
                      style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text('@${profile.username}',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600)),

                  const SizedBox(height: AppSpacing.lg),

                  // Explicit Edit Button
                  AppButton(
                    label: 'Edit Profile',
                    type: AppButtonType.ghost,
                    onPressed: () {
                      _usernameController.text = profile.username;
                      _fullNameController.text = profile.fullName ?? '';
                      _bioController.text = profile.bio ?? '';
                      setState(() => _isEditing = true);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                  ).animate(delay: 300.ms).fadeIn(),

                  const SizedBox(height: AppSpacing.xl),

                  if (profile.bio != null && profile.bio!.isNotEmpty)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      color: AppColors.surface.withValues(alpha: 0.5),
                      child: Text(profile.bio!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSpacing.xl),
                  _buildStatsGrid(profile),
                  const SizedBox(height: AppSpacing.xl),
                  _buildArenaStats(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Centralized Logout Button
                  AppButton(
                    label: 'Logout',
                    type: AppButtonType.outline,
                    color: AppColors.error,
                    onPressed: _showLogoutConfirmation,
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 18),
                  ).animate(delay: 900.ms).fadeIn(),

                  // Compliance Tools
                  AppButton(
                    label: 'Export My Data (JSON)',
                    type: AppButtonType.ghost,
                    onPressed: _handleDataExport,
                    icon: const Icon(Icons.download_for_offline_rounded,
                        size: 18),
                  ).animate(delay: 950.ms).fadeIn(),

                  const SizedBox(height: AppSpacing.md),

                  // Delete Account Button (GDPR Compliance)
                  TextButton(
                    onPressed: _showDeleteAccountConfirmation,
                    child: Text(
                      'Delete Account',
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ).animate(delay: 1000.ms).fadeIn(),

                  const SizedBox(height: AppSpacing.xxl),
                ] else ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display Name',
                            style: AppTypography.label
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide.none),
                            )),
                        const SizedBox(height: AppSpacing.md),
                        Text('Username',
                            style: AppTypography.label
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Enter username',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide.none),
                            )),
                        const SizedBox(height: AppSpacing.md),
                        Text('Bio',
                            style: AppTypography.label
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tell us about yourself',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Cancel',
                                type: AppButtonType.ghost,
                                onPressed: () =>
                                    setState(() => _isEditing = false),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppButton(
                                label: 'Save Changes',
                                type: AppButtonType.premium,
                                onPressed: () => _saveProfile(profile),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatsGrid(ProfileEntity profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.82,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        StatItem(
          label: 'Total XP',
          value: profile.totalPoints,
          icon: Icons.stars_rounded,
          color: Colors.amber,
        ).animate(delay: 500.ms).fadeIn().scale(),
        StatItem(
          label: 'Streak',
          value: profile.currentStreak,
          icon: Icons.local_fire_department_rounded,
          color: AppColors.streakFire,
          suffix: 'd',
        ).animate(delay: 600.ms).fadeIn().scale(),
        StatItem(
          label: 'Record',
          value: profile.highestStreak,
          icon: Icons.emoji_events_rounded,
          color: AppColors.accent,
          suffix: 'd',
        ).animate(delay: 700.ms).fadeIn().scale(),
      ],
    );
  }

  Widget _buildArenaStats() {
    final challengesAsync = ref.watch(myChallengesProvider);
    final userId = ref.watch(authStateProvider).value?.id;

    return challengesAsync.maybeWhen(
      data: (challenges) {
        final completed =
            challenges.where((c) => c.status == 'completed').toList();
        if (completed.isEmpty) return const SizedBox.shrink();

        int wins = 0;
        for (final c in completed) {
          final amIChallenger = c.challengerId == userId;
          final myScore = amIChallenger ? c.challengerScore : c.opponentScore;
          final theirScore =
              amIChallenger ? c.opponentScore : c.challengerScore;
          if (myScore > theirScore) wins++;
        }

        final winRate = (wins / completed.length * 100).toStringAsFixed(0);

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Arena Combat Record', style: AppTypography.h3),
                  Icon(Icons.military_tech_rounded,
                      color: AppColors.primary.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildArenaStatCol(
                      'Matches', '${completed.length}', AppColors.textPrimary),
                  _buildArenaStatCol('Wins', '$wins', AppColors.success),
                  _buildArenaStatCol(
                      'Win Rate', '$winRate%', AppColors.primary),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildArenaStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.h2.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.label.copyWith(fontSize: 10)),
      ],
    );
  }
}
