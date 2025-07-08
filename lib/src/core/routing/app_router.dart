import 'package:go_router/go_router.dart';
import 'package:dukoavote/src/features/home/presentation/pages/home_page.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_checker.dart';
import 'package:dukoavote/src/core/routing/route_names.dart';
import 'package:dukoavote/src/app.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.onboarding,
  routes: [
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingChecker(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteNames.main,
      builder: (context, state) => const MainApp(),
    ),
    // Ajoute ici d'autres routes (onboarding, profil, etc.)
  ],
); 