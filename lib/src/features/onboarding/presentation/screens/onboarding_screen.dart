import 'package:dukoavote/src/core/theme/app_colors.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_intro_page.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_why_page.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_privacy_page.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_ready_page.dart';
import 'package:dukoavote/src/features/onboarding/presentation/widgets/onboarding_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _profileCompleted = false;

  // Pour stocker les infos du profil minimal
  String? _gender;
  DateTime? _age;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OnboardingIntroPage(),
      OnboardingWhyPage(),
      OnboardingPrivacyPage(),
      OnboardingReadyPage(),
      OnboardingProfilePage(
        onValidate: (gender, age) {
          setState(() {
            _gender = gender;
            _age = age;
            _profileCompleted = true;
          });
          _finishOnboarding();
        },
      ),
    ];
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _goToProfile() {
    _controller.animateToPage(
      4,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      _currentPage = 4;
    });
  }

  void _finishOnboarding() {
    widget.onFinish?.call();
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
                  child: Text("${_currentPage + 1}/${_pages.length}"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  onPressed: _skipOnboarding,
                  child: const Text("Passer"),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        side: _currentPage == 0 ? null : const BorderSide(),
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
