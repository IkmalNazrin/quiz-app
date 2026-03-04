import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/game/presentation/providers/game_session_provider.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final List<Color> _teamColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.success,
    Colors.pink,
  ];

  final List<int?> _timerOptions = [null, 5, 10, 15, 20, 30, 45, 60, 90, 120];

  void _cycleTimer(bool next) {
    final current = ref.read(gameSessionProvider).timerOverride;
    // Handle case where current might not be in options (though unlikely if initialized with null)
    int currentIndex = _timerOptions.indexOf(current);
    if (currentIndex == -1) currentIndex = 0; // Default to null if not found

    int newIndex;
    if (next) {
      newIndex = (currentIndex + 1) % _timerOptions.length;
    } else {
      newIndex = (currentIndex - 1);
      if (newIndex < 0) newIndex = _timerOptions.length - 1;
    }

    ref
        .read(gameSessionProvider.notifier)
        .setTimerOverride(_timerOptions[newIndex]);
    HapticService.selection();
  }

  void _showQRDialog() {
    final gamePin = ref.read(gameSessionProvider).gamePin;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Scan QR',
      pageBuilder: (context, anim1, anim2) => Center(
        child: AppCard(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan to Join', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.sm),
              Text('Ask players to scan this code',
                  style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xl),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: QrImageView(
                  data: gamePin,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(gamePin,
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Close',
                onPressed: () => context.pop(),
                type: AppButtonType.ghost,
              ),
            ],
          ),
        ),
      ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
    );
  }

  void _handleLeaveLobby() {
    _showExitConfirmationDialog();
  }

  void _showExitConfirmationDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Exit',
      pageBuilder: (context, anim1, anim2) => Center(
        child: AppCard(
          margin: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Leave Lobby?', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.md),
              const Text('Are you sure you want to leave the game session?',
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                      child: AppButton(
                          label: 'Stay',
                          type: AppButtonType.ghost,
                          onPressed: () => context.pop())),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Leave',
                      type: AppButtonType.primary,
                      onPressed: () {
                        context.pop();
                        ref.read(gameSessionProvider.notifier).disconnect();
                        context.goNamed('dashboard');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
    );
  }

  void _startGame() {
    ref.read(gameSessionProvider.notifier).startGame(null);
  }

  void _toggleTeamMode(bool value) {
    ref.read(gameSessionProvider.notifier).toggleTeamMode(value);
    HapticService.selection();
  }

  void _setTeamLimit(int limit) {
    if (limit < 0) return;
    ref.read(gameSessionProvider.notifier).setTeamLimit(limit);
    HapticService.light();
  }

  void _addTeam() {
    ref.read(gameSessionProvider.notifier).addTeam();
    HapticService.light();
  }

  void _removeTeam() {
    ref.read(gameSessionProvider.notifier).removeTeam();
    HapticService.light();
  }

  void _randomizeTeams() {
    ref.read(gameSessionProvider.notifier).randomizeTeams();
    HapticService.medium();
  }

  void _showRenameTeamDialog(String oldName) {
    final controller = TextEditingController(text: oldName);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rename',
      pageBuilder: (context, anim1, anim2) => Center(
        child: AppCard(
          margin: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rename Team', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: controller,
                label: 'Team Name',
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                      child: AppButton(
                          label: 'Cancel',
                          type: AppButtonType.ghost,
                          onPressed: () => context.pop())),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Rename',
                      onPressed: () {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty && newName != oldName) {
                          ref
                              .read(gameSessionProvider.notifier)
                              .renameTeam(oldName, newName);
                        }
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
    );
  }

  void _playerAssignTeam(String teamName) {
    ref.read(gameSessionProvider.notifier).playerAssignTeam(teamName);
    HapticService.selection();
  }

  void _assignTeam(String playerId, String teamName) {
    ref.read(gameSessionProvider.notifier).assignTeam(playerId, teamName);
    HapticService.light();
  }

  void _kickPlayer(String userId, String nickname) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Moderate',
      pageBuilder: (context, anim1, anim2) => Center(
        child: AppCard(
          margin: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Moderate Player', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Text('Action for $nickname', textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Kick',
                      type: AppButtonType.outline,
                      color: AppColors.warning,
                      onPressed: () {
                        ref
                            .read(gameSessionProvider.notifier)
                            .kickPlayer(userId);
                        context.pop();
                        HapticService.error();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Ban',
                      type: AppButtonType.primary,
                      color: AppColors.error,
                      onPressed: () {
                        ref
                            .read(gameSessionProvider.notifier)
                            .banPlayer(userId);
                        context.pop();
                        HapticService.heavy();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Cancel',
                onPressed: () => context.pop(),
                type: AppButtonType.ghost,
              ),
            ],
          ),
        ),
      ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameSessionProvider);
    final myUserId = ref.read(authStateProvider).value?.id;
    final isHost = myUserId == gameState.hostId;

    ref.listen(gameSessionProvider, (previous, next) {
      if (next.status == 'playing' && (previous?.status != 'playing')) {
        context.pushNamed('game');
      } else if (next.status == 'disconnected') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disconnected from game.')));
        context.goNamed('dashboard');
      } else if (next.status == 'kicked' || next.status == 'banned') {
        final isBan = next.status == 'banned';
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          pageBuilder: (context, a1, a2) => Center(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isBan ? Icons.gavel_rounded : Icons.block,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: AppSpacing.lg),
                  Text(isBan ? 'BANNED' : 'REMOVED',
                      style: AppTypography.h2.copyWith(color: AppColors.error)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                      isBan
                          ? 'The host has banned you from this session.'
                          : 'The host has removed you from the lobby.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Return Home',
                    onPressed: () {
                      context.goNamed('dashboard');
                    },
                  )
                ],
              ),
            ),
          ),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleLeaveLobby();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient Background
            Positioned.fill(
              child: Stack(
                children: [
                  // Blob 1
                  Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 100,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.5, 1.5),
                            duration: 4.seconds)
                        .moveY(begin: 0, end: 50, duration: 5.seconds),
                  ),
                  // Blob 2
                  Positioned(
                    bottom: 100,
                    left: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.05),
                            blurRadius: 120,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(1.0, 1.0),
                            duration: 6.seconds)
                        .moveX(begin: 0, end: 30, duration: 7.seconds),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, // Allow ambient blobs to show through
                    AppColors.background.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                      height:
                          AppSpacing.getHeaderHeight(context)), // Header height
                  Expanded(
                    child: Column(
                      children: [
                        if (isHost)
                          _buildHostControls(gameState)
                              .animate()
                              .fadeIn()
                              .slideY(begin: -0.1),
                        _buildParticipantsHeader(gameState),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: AppAnimations.normal,
                            child: gameState.isTeamMode
                                ? _buildTeamView(gameState, isHost)
                                : _buildIndividualView(gameState, isHost),
                          ),
                        ),
                        if (isHost)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: AppButton(
                              label: 'Launch Arena',
                              onPressed:
                                  gameState.players.isEmpty ? null : _startGame,
                              type: AppButtonType.premium,
                              icon: const Icon(Icons.rocket_launch_rounded),
                              height: 60,
                            )
                                .animate(
                                    target:
                                        gameState.players.isNotEmpty ? 1 : 0)
                                .scale(
                                    duration: 300.ms,
                                    curve: Curves.easeOutBack),
                          ),
                        if (!isHost)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: AppCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('WAITING FOR HOST',
                                            style: AppTypography.label.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1)),
                                        Text('The game will start soon...',
                                            style: AppTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .shimmer(
                                    duration: 2.seconds, color: Colors.white24)
                                .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.02, 1.02),
                                    duration: 1.seconds),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassHeader(
                leading: isHost
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: _handleLeaveLobby,
                      )
                    : null,
                actions: [
                  if (isHost)
                    IconButton(
                      icon: const Icon(Icons.qr_code_2_rounded,
                          color: AppColors.primary),
                      onPressed: _showQRDialog,
                    ),
                ],
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GAME PIN',
                        style: AppTypography.label.copyWith(
                            letterSpacing: 2,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    Text(gameState.gamePin,
                        style: AppTypography.h2.copyWith(
                          letterSpacing: 4,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsHeader(GameEntity gameState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Icon(
              gameState.isTeamMode
                  ? Icons.groups_rounded
                  : Icons.person_rounded,
              size: 20,
              color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(gameState.isTeamMode ? 'Teams' : 'Players',
              style: AppTypography.h3),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 6),
                Text('${gameState.players.length} Joined',
                    style: AppTypography.label.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          )
              .animate(key: ValueKey(gameState.players.length))
              .scale(duration: 200.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildHostControls(GameEntity state) {
    final bool canAddTeam = state.teams.length < state.players.length;
    final int teamMemberLimit = state.teamMemberLimit;

    return AppCard(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          _buildControlRow(
            'Question Timer',
            state.timerOverride == null ? 'Default' : '${state.timerOverride}s',
            onAdd: () => _cycleTimer(true),
            onRemove: () => _cycleTimer(false),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          SwitchListTile(
            title: Text('Team Mode',
                style: AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            subtitle:
                Text('Group players into teams', style: AppTypography.label),
            activeThumbColor: AppColors.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            value: state.isTeamMode,
            onChanged: _toggleTeamMode,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    children: [
                      _buildControlRow(
                        'Max Players / Team',
                        teamMemberLimit == 0 ? 'Any' : '$teamMemberLimit',
                        onAdd: () => _setTeamLimit(teamMemberLimit + 1),
                        onRemove: () => _setTeamLimit(teamMemberLimit - 1),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildControlRow(
                        'Total Teams',
                        '${state.teams.length}',
                        onAdd: canAddTeam ? _addTeam : null,
                        onRemove: _removeTeam,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Randomize Teams',
                        onPressed:
                            state.players.isEmpty ? null : _randomizeTeams,
                        type: AppButtonType.outline,
                        icon: const Icon(Icons.shuffle_rounded,
                            size: 18, color: AppColors.primary),
                        height: 48,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: state.isTeamMode
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: 300.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow(String label, String value,
      {VoidCallback? onAdd, VoidCallback? onRemove}) {
    return Row(
      children: [
        Text(label,
            style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const Spacer(),
        _buildCircleButton(Icons.remove, onRemove),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(value,
              style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        _buildCircleButton(Icons.add, onAdd),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.surface : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
            color: onPressed == null ? Colors.transparent : AppColors.border),
      ),
      child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon,
              color: onPressed == null
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textPrimary,
              size: 18),
          onPressed: onPressed),
    );
  }

  Widget _buildIndividualView(GameEntity state, bool isHost) {
    if (state.players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  size: 48, color: AppColors.primary),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds),
            const SizedBox(height: AppSpacing.lg),
            Text('Waiting for players...', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text('Share the Game PIN to join', style: AppTypography.bodySmall),
          ],
        ),
      ).animate().fadeIn();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      itemCount: state.players.length,
      itemBuilder: (context, index) {
        final player = state.players[index];
        final isPlayerHost = player['id'] == state.hostId;
        final isRegistered = player['isRegistered'] == true;

        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              _buildAvatar(player['nickname'],
                  isPlayerHost ? AppColors.accent : AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player['nickname'],
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600)),
                    if (isPlayerHost)
                      Text('GAME HOST',
                          style: AppTypography.label.copyWith(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (isRegistered) ...[
                const Icon(Icons.verified, color: AppColors.primary, size: 20)
                    .animate()
                    .scale(curve: Curves.elasticOut),
              ],
              if (isHost && !isPlayerHost) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.person_remove_rounded,
                      color: AppColors.error, size: 20),
                  onPressed: () => _kickPlayer(
                      player['user_id'] ?? player['id'], player['nickname']),
                  tooltip: 'Kick Player',
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).scale(
            begin: const Offset(0.5, 0.5),
            duration: 400.ms,
            curve: Curves.elasticOut); // UPDATED ANIMATION
      },
    );
  }

  Widget _buildAvatar(String name, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildTeamView(GameEntity state, bool isHost) {
    final List<Map<String, dynamic>> unassignedPlayers = state.players
        .where((p) {
          return !state.teams
              .any((team) => team.members.any((m) => m.userId == p['user_id']));
        })
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          ...state.teams.asMap().entries.map((entry) {
            final int index = entry.key;
            final team = entry.value;
            return _buildTeamCard(
                    team.name,
                    team.members.map((m) => m.userId).toList(),
                    index,
                    state,
                    isHost)
                .animate(key: ValueKey(team.name))
                .fadeIn(delay: (index * 100).ms)
                .slideY(begin: 0.1);
          }),
          if (unassignedPlayers.isNotEmpty)
            _buildUnassignedCard(unassignedPlayers, state, isHost)
                .animate()
                .fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String teamName, List<dynamic> playerIds, int teamIndex,
      GameEntity state, bool isHost) {
    final myUserId = ref.read(authStateProvider).value?.id;
    final isPlayerOnThisTeam = playerIds.contains(myUserId);
    final isTeamFull =
        state.teamMemberLimit > 0 && playerIds.length >= state.teamMemberLimit;
    final teamColor = _teamColors[teamIndex % _teamColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: teamColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: teamColor.withValues(alpha: 0.15),
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_rounded, color: teamColor, size: 20)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .shimmer(
                                duration: 2.seconds, color: Colors.white30),
                        const SizedBox(width: AppSpacing.sm),
                        Text(teamName,
                            style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5)),
                        if (isHost)
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded,
                                size: 20, color: AppColors.textSecondary),
                            onPressed: () => _showRenameTeamDialog(teamName),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ).animate().scale(curve: Curves.elasticOut),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                              color: teamColor.withValues(alpha: 0.3),
                              blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        state.teamMemberLimit > 0
                            ? '${playerIds.length}/${state.teamMemberLimit}'
                            : '${playerIds.length}',
                        style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w900, color: teamColor),
                      ),
                    )
                        .animate(key: ValueKey(playerIds.length))
                        .scale(curve: Curves.elasticOut, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
          if (playerIds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.group_add_rounded,
                      size: 32, color: teamColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 4),
                  Text('Team is empty',
                      style: AppTypography.label
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: playerIds.map((playerId) {
                  final player = state.players.firstWhere(
                      (p) => p['user_id'] == playerId,
                      orElse: () => {});
                  if (player.isEmpty) return const SizedBox.shrink();
                  final isPlayerHost = playerId == state.hostId;

                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: _buildAvatar(
                        player['nickname'],
                        isPlayerHost
                            ? AppColors.accent
                            : AppColors.textSecondary),
                    title: Text(player['nickname'],
                        style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                    trailing: player['isRegistered'] == true
                        ? const Icon(Icons.verified,
                                color: AppColors.primary, size: 16)
                            .animate()
                            .scale(curve: Curves.elasticOut)
                        : null,
                  )
                      .animate()
                      .slideX(
                          begin: -0.2,
                          duration: 400.ms,
                          curve: Curves.easeOutBack)
                      .fadeIn();
                }).toList(),
              ),
            ),
          if (!isHost)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: isPlayerOnThisTeam
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.success.withValues(alpha: 0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('YOU ARE ON THIS TEAM',
                              style: AppTypography.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    )
                      .animate()
                      .scale(curve: Curves.elasticOut, duration: 600.ms)
                      .shimmer(duration: 2.seconds, color: Colors.white24)
                  : AppButton(
                      label: isTeamFull ? 'Team Full' : 'Join Team',
                      onPressed:
                          isTeamFull ? null : () => _playerAssignTeam(teamName),
                      type: AppButtonType.secondary,
                      height: 40,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnassignedCard(List<Map<String, dynamic>> unassignedPlayers,
      GameEntity state, bool isHost) {
    return AppCard(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_search_rounded,
                    color: AppColors.textSecondary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Unassigned Players (${unassignedPlayers.length})',
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...unassignedPlayers.map((player) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading:
                  _buildAvatar(player['nickname'], AppColors.textSecondary),
              title: Text(player['nickname'],
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              trailing: isHost
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: state.teams.map((team) {
                          final index = state.teams.indexOf(team);
                          final teamName = team.name;
                          final color = _teamColors[index % _teamColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: InkWell(
                              onTap: () =>
                                  _assignTeam(player['user_id'], teamName),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Team ${index + 1}',
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }
}
