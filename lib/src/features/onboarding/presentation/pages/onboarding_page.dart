import 'package:dukoavote/src/core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../onboarding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Données temporaires pour la page de profil supprimées

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const OnboardingIntroPage(),
      const OnboardingWhyPage(),
      const OnboardingPrivacyPage(),
      const OnboardingReadyPage(),
      OnboardingProfilePage(
        onValidate: (gender, birthDate) {
          _finishOnboarding(gender!, birthDate!, );
        },
      ),
    ];
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // On ne doit plus appeler _finishOnboarding ici
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  Future<void> _finishOnboarding(String gender, DateTime birthDate) async {
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().month < birthDate.month ||
        (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
      age--;
    }
    await OnboardingLocalStorage.markOnboardingCompleted();
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      await container.read(authProvider.notifier).signInAnon(
        gender, birthDate.toIso8601String(), age.toString());
      if (!mounted) return;
      widget.onFinish?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la connexion anonyme. Veuillez réessayer.\n$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 65, left: 15, right: 15, bottom: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Text("${_currentPage + 1}/${_pages.length}", style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                ),
                if (_currentPage < 4)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    onPressed: () {
                      _controller.jumpToPage(4); // Aller à la page profil
                    },
                    child: Text("Passer", style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),),
                  ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
            if (_currentPage < 4)
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        side: _currentPage == 0 ? null : const BorderSide(
                          color: AppColors.primary
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _currentPage == 0 ? null : _prevPage,
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: _currentPage == 0 ? null : AppColors.primary,
                      ),
                      label: Text(
                        "Précédent",
                        style: GoogleFonts.poppins(
                          color: _currentPage == 0 ? null : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _nextPage,
                      icon: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                      iconAlignment: IconAlignment.end,
                      label: Text(
                        _currentPage == 3 ? "Terminer" : "Suivant",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
