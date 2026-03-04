import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_features/quiz_features.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.path == '/login';
      final isWelcome = state.uri.path == '/welcome';
      final isRoot = state.uri.path == '/';

      if (!isLoggedIn) {
        if (!isLoggingIn && !isWelcome) {
          return '/welcome';
        }
        if (isRoot) {
          return '/welcome';
        }
      } else {
        final user = authState.value!;

        // RBAC: Protect Host/Admin routes
        final isHostRoute =
            state.uri.path.startsWith('/host') ||
            state.uri.path.startsWith('/analytics') ||
            state.uri.path.startsWith('/editor');

        if (isHostRoute && !user.role.isHost) {
          debugPrint(
            '⚠️ Unauthorized access attempt to ${state.uri.path} by ${user.role.name}',
          );
          return '/dashboard';
        }

        // Privacy: Enforce Consent
        final hasAccepted = await ref
            .read(legalRepositoryProvider)
            .hasAcceptedTerms();
        final isConsentScreen = state.uri.path == '/consent';

        if (!hasAccepted) {
          if (!isConsentScreen) return '/consent';
          return null;
        } else {
          if (isConsentScreen) return '/dashboard';
        }

        if (isLoggingIn || isWelcome || isRoot) {
          return '/dashboard';
        }
      }
      return null;
    },
    refreshListenable: AuthStateListenable(ref),
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(
                      CurveTween(curve: Curves.easeOutCubic).animate(animation),
                    ),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/consent',
        name: 'consent',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ConsentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: DashboardScreen(initialIndex: args['initialIndex'] ?? 0),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/join',
        name: 'join',
        pageBuilder: (context, state) {
          final pin = state.extra as String? ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: JoinGameScreen(gamePin: pin),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/lobby/:pin',
        name: 'lobby',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LobbyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: QuestionScreen(
              engine: args['engine'],
              gamePin: args['gamePin'],
              initialQuestionData: args['initialQuestionData'],
              isChallenge: args['isChallenge'] ?? false,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResultsScreen(
              players: args['players'],
              teams: args['teams'],
              isTeamMode: args['isTeamMode'] ?? false,
              correctAnswerIndex: args['correctAnswerIndex'],
              questionData: args['questionData'],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/scoreboard',
        name: 'scoreboard',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: FinalScoreboardScreen(
              players: args['players'],
              teams: args['teams'],
              isTeamMode: args['isTeamMode'] ?? false,
              quizId: args['quizId'],
              sessionId: args['sessionId'],
              isHost: args['isHost'] ?? false,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/game_report/:sessionId',
        name: 'game_report',
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final args = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: GameReportScreen(
              sessionId: sessionId,
              finalResultsFallback: args,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/editor/:id',
        name: 'editor',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: QuizEditorPage(quizId: id == 'new' ? null : id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/browse',
        name: 'browse',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BrowseScreen(
            onHostGame: (quizId, quizTitle) => context.pushNamed(
              'host',
              pathParameters: {'quizId': quizId},
              queryParameters: {'title': quizTitle},
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/workshop',
        name: 'workshop',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: WorkshopScreen(
            onHostGame: (quizId, quizTitle) => context.pushNamed(
              'host',
              pathParameters: {'quizId': quizId},
              queryParameters: {'title': quizTitle},
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: ChallengeLoadingScreen(
              challengeId: args['challengeId'],
              quizId: args['quizId'],
              quizTitle: args['quizTitle'],
              opponentTeam: args['opponentTeam'],
              isLeaderboardChallenge: args['isLeaderboardChallenge'] ?? false,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
      GoRoute(
        path: '/host/:quizId',
        name: 'host',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(
            quizId: state.pathParameters['quizId']!,
            quizTitle: state.uri.queryParameters['title'] ?? 'Quiz',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HostAnalyticsDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              _buildIosTransition(animation, child),
        ),
        routes: [
          GoRoute(
            path: 'quiz/:id',
            name: 'quiz_analytics',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: QuizAnalyticsView(quizId: state.pathParameters['id']!),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      _buildIosTransition(animation, child),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/organization/:orgId',
        name: 'admin_organization',
        pageBuilder: (context, state) {
          final orgId = state.pathParameters['orgId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminDashboardScreen(organizationId: orgId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    _buildIosTransition(animation, child),
          );
        },
      ),
    ],
  );
});

Widget _buildIosTransition(Animation<double> animation, Widget child) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
      child: child,
    ),
  );
}

class AuthStateListenable extends ChangeNotifier {
  final Ref ref;
  AuthStateListenable(this.ref) {
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
