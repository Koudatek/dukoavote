import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:dukoavote/src/features/onboarding/data/onboarding_local_storage.dart';
import 'route_names.dart';

/// Router principal de l'application avec guards d'authentification
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) async {
      // Ne pas rediriger si on est déjà sur une route valide
      if (state.matchedLocation == RouteNames.splash ||
          state.matchedLocation == RouteNames.onboarding ||
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.signup ||
          state.matchedLocation == RouteNames.profileCompletion ||
          state.matchedLocation == RouteNames.home ||
          state.matchedLocation == RouteNames.profile) {
        return null; // Pas de redirection
      }
      
      // Vérifier l'état de l'onboarding et de l'authentification
      final hasCompletedOnboarding = await OnboardingLocalStorage.isOnboardingCompleted();
      
      if (!hasCompletedOnboarding) {
        return RouteNames.onboarding;
      }
      
      // Si l'onboarding est terminé, rediriger vers login
      return RouteNames.login;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      // Profile completion
      GoRoute(
        path: RouteNames.profileCompletion,
        builder: (context, state) => const ProfileCompletionPage(),
      ),
      // Main app routes (protected)
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeWithNavigation(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}

/// Splash screen pour initialiser l'application
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
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
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
      final isAuthenticated = ref.read(authIsAuthenticatedProvider);
      final hasCompletedOnboarding = await OnboardingLocalStorage.isOnboardingCompleted();
      
      if (isAuthenticated) {
        // User is authenticated - go directly to home
        context.go(RouteNames.home);
      } else if (hasCompletedOnboarding) {
        // User not authenticated but has completed onboarding - go to login
        context.go(RouteNames.login);
      } else {
        // User not authenticated and hasn't completed onboarding - go to onboarding
        context.go(RouteNames.onboarding);
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
                // App logo
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.how_to_vote,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // App name
                Text(
                  'DukoaVote',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Votre voix compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Loading indicator
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