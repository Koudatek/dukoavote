import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page d'accueil avec navigation intégrée
class HomeWithNavigation extends ConsumerStatefulWidget {
  const HomeWithNavigation({super.key});

  @override
  ConsumerState<HomeWithNavigation> createState() => _HomeWithNavigationState();
}

class _HomeWithNavigationState extends ConsumerState<HomeWithNavigation> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildPage(currentIndex),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(currentIndex),
    );
  }

  /// Construit la page correspondant à l'index
  Widget _buildPage(int index) {
    final pages = [
      const HomePage(),
      const _StatsPage(),
      const ProfilePage(),
    ];
    
    return pages[index];
  }

  /// Construit la barre de navigation
  Widget _buildBottomNavigationBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
          _animationController.reset();
          _animationController.forward();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.home, selected: false),
            activeIcon: _NavIcon(icon: Icons.home, selected: true),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.bar_chart, selected: false),
            activeIcon: _NavIcon(icon: Icons.bar_chart, selected: true),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.person, selected: false),
            activeIcon: _NavIcon(icon: Icons.person, selected: true),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Page temporaire pour les statistiques
class _StatsPage extends StatelessWidget {
  const _StatsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bientôt disponible',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget custom pour l'icône du BottomNavigationBar
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  
  const _NavIcon({
    required this.icon,
    required this.selected,
  });

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

/// Provider pour gérer l'index de navigation
final navigationIndexProvider = StateProvider<int>((ref) => 0); 