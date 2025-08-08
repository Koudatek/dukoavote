// lib/src/app/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) async {
      // Si on est sur une route publique, pas de redirection
      if (state.matchedLocation == RouteNames.splash ||
          state.matchedLocation == RouteNames.onboarding ||
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.signup ||
          state.matchedLocation == RouteNames.profileCompletion) {
        return null;
      }

      // Vérifier l'authentification via authStateProvider
      final ref = ProviderScope.containerOf(context);
      final authState = ref.read(authProvider);

      // Si erreur ou pas d'utilisateur, rediriger vers onboarding
      return authState.failure != null && authState.user == null
          ? RouteNames.onboarding
          : RouteNames.home;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: RouteNames.profileCompletion,
        builder: (context, state) => const ProfileCompletionPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeWithNavigation(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.requestQuestion,
        builder: (context, state) => const RequestQuestionPage(),
      ),
      GoRoute(
        path: RouteNames.results,
        builder: (context, state) {
          final pollId = state.uri.queryParameters['pollId'];
          final poll = state.extra as Poll?;
          final userId = state.uri.queryParameters['userId'] ?? '';

          if (poll != null) {
            return PollResultsPage(poll: poll, userId: userId);
          } else if (pollId != null) {
            return ResultsPage(pollId: pollId, userId: userId);
          } else {
            return const ResultsPage(pollId: '', userId: '');
          }
        },
      ),
    ],
  );
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animation
    _animationController.forward();

    // Wait for animation and check auth state
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.failure != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(authState.failure!.message)));
          context.go(RouteNames.onboarding);
        }
      }
      if (mounted) {
        if (authState.user != null) {
          context.go(RouteNames.home);
        } else {
          context.go(RouteNames.onboarding);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.how_to_vote, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text(
                  'DukoaVote',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre voix compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
