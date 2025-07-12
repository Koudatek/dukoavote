import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dukoavote/src/core/routing/app_router.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:dukoavote/src/features/profile/presentation/profile_page.dart';

class DukoaVoteApp extends ConsumerStatefulWidget {
  const DukoaVoteApp({super.key});

  @override
  ConsumerState<DukoaVoteApp> createState() => _DukoaVoteAppState();
}

class _DukoaVoteAppState extends ConsumerState<DukoaVoteApp> {
  @override
  void initState() {
    super.initState();
    // Charger l'utilisateur connecté au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DukoaVote',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Placeholder(), // Stats page (à créer)
    const ProfilePage(), // Profile page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.home,
              selected: _currentIndex == 0,
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.bar_chart,
              selected: _currentIndex == 1,
            ),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.person,
              selected: _currentIndex == 2,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Widget custom pour l'icône du BottomNavigationBar
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  const _NavIcon({required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Icon(icon);
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.12 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(
        icon,
        color: AppColors.primary,
      ),
    );
  }
}


