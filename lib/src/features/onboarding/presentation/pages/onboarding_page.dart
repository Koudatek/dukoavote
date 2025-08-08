import 'package:dukoavote/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dukoavote/src/app/router/route_names.dart';
import 'package:dukoavote/src/core/theme/app_colors.dart';
import 'package:dukoavote/src/features/onboarding/data/services/location_service.dart';
import 'package:dukoavote/src/features/onboarding/data/onboarding_local_storage.dart';

/// Page d'onboarding avec design premium inspiré iOS
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _iconController;
  late AnimationController _indicatorController;
  
  int _currentPage = 0;
  final int _totalPages = 6;

  // Variables pour les données du formulaire
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedUsername;
  
  // Contrôleurs pour les champs texte
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Données des pages d'onboarding - Design numérique responsable
  final List<OnboardingPageConfig> _onboardingPages = [
    OnboardingPageConfig(
      message: "Bienvenue sur DukuaVote, votre communauté publique de sondages quotidiens.",
      icon: Icons.waving_hand_rounded,
      color: AppColors.primary,
      gradient: [AppColors.primary.withValues(alpha: .1), AppColors.primaryLight.withValues(alpha: .05)],
    ),
    OnboardingPageConfig(
      message: "Une question par jour, des milliers de réponses authentiques et anonymes.",
      icon: Icons.question_mark_rounded,
      color: AppColors.accent,
      gradient: [AppColors.accent.withValues(alpha: .1), AppColors.primary.withValues(alpha: .05)],
    ),
    OnboardingPageConfig(
      message: "Rejoins la conversation mondiale et découvre l'opinion collective.",
      icon: Icons.people_alt_rounded,
      color: AppColors.success,
      gradient: [AppColors.success.withValues(alpha: .1), AppColors.accent.withValues(alpha: .05)],
    ),
    OnboardingPageConfig(
      message: "Commençons par quelques informations personnelles.",
      icon: Icons.person_rounded,
      color: AppColors.warning,
      gradient: [AppColors.warning.withValues(alpha: .1), AppColors.success.withValues(alpha: .05)],
      isDataCollection: true,
      dataType: DataType.personal,
    ),
    OnboardingPageConfig(
      message: "Et maintenant, dans quel pays te trouves-tu ?",
      icon: Icons.location_on_rounded,
      color: AppColors.accent,
      gradient: [AppColors.accent.withValues(alpha: .1), AppColors.warning.withValues(alpha: .05)],
      isDataCollection: true,
      dataType: DataType.location,
    ),
    OnboardingPageConfig(
      message: "Choisis ton nom d'utilisateur public",
      icon: Icons.person_add_rounded,
      color: AppColors.primary,
      gradient: [AppColors.primary.withValues(alpha: .1), AppColors.accent.withValues(alpha: .05)],
      isDataCollection: true,
      dataType: DataType.username,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Démarrer les animations initiales
    _startAnimations();
  }

  void _startAnimations() {
    _backgroundController.forward();
    _contentController.forward();
    _iconController.forward();
    _indicatorController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _contentController.dispose();
    _iconController.dispose();
    _indicatorController.dispose();
    _countryController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validation des champs selon la page actuelle
    if (!_validateCurrentPage()) {
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _backgroundController.reverse().then((_) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        _backgroundController.forward();
        _contentController.reset();
        _contentController.forward();
        _iconController.reset();
        _iconController.forward();
        _indicatorController.reset();
        _indicatorController.forward();
        
        HapticFeedback.lightImpact();
      });
    } else {
      // Fin de l'onboarding, sauvegarder les données et aller à la page d'inscription
      _saveOnboardingData();
      context.go(RouteNames.signup);
    }
  }

  void _skipOnboarding() {
    // Passer l'onboarding et aller directement à la page de connexion
    context.go(RouteNames.login);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _backgroundController.reverse().then((_) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        _backgroundController.forward();
        _contentController.reset();
        _contentController.forward();
        _iconController.reset();
        _iconController.forward();
        _indicatorController.reset();
        _indicatorController.forward();
        
        HapticFeedback.lightImpact();
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Vérification en temps réel du nom d'utilisateur
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) return;
    
    final result = await ref.read(authProvider.notifier).checkUsernameAvailability.call(username);
    result.fold(
      (failure) {
        // En cas d'erreur, on considère que le nom d'utilisateur n'est pas disponible
        setState(() {
          _selectedUsername = null;
        });
      },
      (isAvailable) {
        if (isAvailable) {
          setState(() {
            _selectedUsername = username;
          });
        } else {
          setState(() {
            _selectedUsername = null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true, // Permet au contenu de passer sous la barre de statut
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Barre de statut transparente
          statusBarIconBrightness: Brightness.dark, // Icônes sombres
          statusBarBrightness: Brightness.light, // Pour iOS
        ),
        child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingPages[index]);
            },
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    child: const Text(''),
                  ),
                ),
                
                // Indicateur de progression centré
                Expanded(
                  child: _buildProgressIndicator(),
                ),
                
                // Bouton Passer
                SizedBox(
                  width: 60,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    ),
                    child: Text(
                      'Passer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 20,
            right: 20,
            child: _buildNavigationButtons(),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPageConfig data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradient,
        ),
      ),
      child: Column(
        children: [
          // Espace pour la barre de statut
          SizedBox(height: MediaQuery.of(context).padding.top),
          
          // Contenu principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_iconController.value * 0.2),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            data.color.withValues(alpha: .15),
                            data.color.withValues(alpha: .05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: data.color.withValues(alpha: .2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        size: 60,
                        color: data.color,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Contenu dynamique selon le type de page
              if (data.isDataCollection)
                _buildDataCollectionForm(data)
              else
                _buildMessageCard(data),
            ],
          ),
        ),
      ),
    ]
    )
    );
  }

  Widget _buildMessageCard(OnboardingPageConfig data) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentController.value)),
          child: Opacity(
            opacity: _contentController.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                data.message,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
  

  Widget _buildDataCollectionForm(OnboardingPageConfig data) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentController.value)),
          child: Opacity(
            opacity: _contentController.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.message,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildDataCollectionFields(data.dataType),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataCollectionFields(DataType dataType) {
    switch (dataType) {
      case DataType.personal:
        return _buildPersonalFields();
      case DataType.location:
        return _buildLocationFields();
      case DataType.username:
        return _buildUsernameFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalFields() {
    return Column(
      children: [
        // Date de naissance
        _buildDateField(
          label: "Date de naissance *",
          icon: Icons.cake_rounded,
        ),
        const SizedBox(height: 16),
        // Genre
        _buildDropdownField(
          label: "Genre *",
          options: ["Homme", "Femme"],
          icon: Icons.person_rounded,
          selectedValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        // Pays
        _buildSearchableDropdownField(
          label: "Pays *",
          hint: "Sélectionner un pays",
          icon: Icons.public_rounded,
          options: LocationService.countries,
          selectedValue: _selectedCountry,
          onChanged: (value) {
            setState(() {
              _selectedCountry = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUsernameFields() {
    return Column(
      children: [
        // Explication sur l'anonymat
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Votre identité reste anonyme",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Seul votre nom d'utilisateur sera visible publiquement. Vos informations personnelles restent privées.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accent.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Champ nom d'utilisateur
        _buildUsernameField(),
      ],
    );
  }

  Widget _buildUsernameField() {
    final hasMinLength = _usernameController.text.length >= 3;
    final isAvailable = hasMinLength && _selectedUsername != null && _selectedUsername!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Nom d\'utilisateur *',
            prefixIcon: const Icon(Icons.person_rounded),
            suffixIcon: hasMinLength
                ? Icon(
                    isAvailable ? Icons.check_circle : Icons.error,
                    color: isAvailable ? AppColors.success : AppColors.error,
                  )
                : null,
            border: const OutlineInputBorder(),
            helperText: hasMinLength
                ? (isAvailable 
                    ? "✅ Nom d'utilisateur disponible" 
                    : "❌ Nom d'utilisateur déjà pris")
                : "Minimum 3 caractères, lettres, chiffres, tirets et underscores",
          ),
          onChanged: (value) {
            if (value.length >= 3) {
              _checkUsernameAvailability(value);
            } else {
              setState(() {
                _selectedUsername = null;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        
        // Indicateur de disponibilité - seulement si 3+ caractères
        if (hasMinLength)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAvailable ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: isAvailable ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 3),
                Text(
                  isAvailable ? "Disponible" : "Déjà pris",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 6570)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: TextField(
          enabled: false,
          controller: TextEditingController(
            text: _selectedDate != null 
                ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                : "",
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: _selectedDate == null ? "Sélectionner une date" : null,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required IconData icon,
    String? selectedValue,
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: AppColors.textSecondary),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSearchableDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> options,
    String? selectedValue,
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: AppColors.textSecondary),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = index == _currentPage;
        final isCompleted = index < _currentPage;
        
        return AnimatedBuilder(
          animation: _indicatorController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.primary
                      : isCompleted 
                          ? AppColors.primary.withValues(alpha: .6)
                          : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    final isNextButtonEnabled = _isNextButtonEnabled();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bouton Précédent
        if (_currentPage > 0)
          _buildNavigationButton(
            onPressed: _previousPage,
            icon: Icons.arrow_back_ios_rounded,
            isPrimary: false,
          )
        else
          const SizedBox(width: 60),
        
        _buildNavigationButton(
          onPressed: isNextButtonEnabled ? _nextPage : null,
          icon: Icons.arrow_forward_ios_rounded,
          isPrimary: true,
          text: _currentPage == _totalPages - 1 ? "Commencer" : "Suivant",
          isEnabled: isNextButtonEnabled,
        ),
      ],
    );
  }

  bool _isNextButtonEnabled() {
    final currentData = _onboardingPages[_currentPage];
    
    switch (currentData.dataType) {
      case DataType.personal:
        return _selectedDate != null && 
               _selectedGender != null && 
               _selectedGender!.isNotEmpty;
      case DataType.location:
        return _selectedCountry != null && 
               _selectedCountry!.isNotEmpty;
      case DataType.username:
        return _selectedUsername != null && 
               _selectedUsername!.isNotEmpty &&
               _selectedUsername!.length >= 3;
      default:
        return true;
    }
  }

  Widget _buildNavigationButton({
    VoidCallback? onPressed,
    required IconData icon,
    required bool isPrimary,
    String? text,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isPrimary 
              ? (isEnabled ? null : AppColors.textTertiary)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isPrimary 
                ? (isEnabled ? AppColors.primary : AppColors.textTertiary)
                : AppColors.divider,
            width: 1,
          ),
          boxShadow: isPrimary && isEnabled ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (text != null) ...[
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary 
                      ? (isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.5))
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              icon,
              size: 20,
              color: isPrimary 
                  ? (isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.5))
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _saveOnboardingData() async {
    try {
      // Sauvegarder les données personnelles
      if (_selectedDate != null && _selectedGender != null) {
        await OnboardingLocalStorage.savePersonalData(
          birthDate: _selectedDate!,
          gender: _selectedGender!,
        );
      }

      // Sauvegarder les données de localisation
      if (_selectedCountry != null) {
        await OnboardingLocalStorage.saveLocationData(
          country: _selectedCountry!,
        );
      }

      // Sauvegarder le nom d'utilisateur
      if (_selectedUsername != null) {
        await OnboardingLocalStorage.saveUsernameData(
          username: _selectedUsername!,
        );
      }

      // Marquer l'onboarding comme terminé si toutes les données sont collectées
      if (_selectedDate != null && 
          _selectedGender != null && 
          _selectedCountry != null && 
          _selectedUsername != null) {
        await OnboardingLocalStorage.saveOnboardingData(
          birthDate: _selectedDate!,
          gender: _selectedGender!,
          country: _selectedCountry!,
          username: _selectedUsername!,
        );
      }
    } catch (e) {
      // En cas d'erreur, on continue quand même
      print('Erreur lors de la sauvegarde des données d\'onboarding: $e');
    }
  }

  bool _validateCurrentPage() {
    final currentData = _onboardingPages[_currentPage];
    
    switch (currentData.dataType) {
      case DataType.personal:
        return _validatePersonalFields();
      case DataType.location:
        return _validateLocationFields();
      case DataType.username:
        return _validateUsernameFields();
      default:
        return true; // Pas de validation pour les pages de présentation
    }
  }

  bool _validatePersonalFields() {
    if (_selectedDate == null) {
      _showValidationError("Veuillez sélectionner votre date de naissance");
      return false;
    }
    
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _showValidationError("Veuillez sélectionner votre genre");
      return false;
    }
    
    return true;
  }

  bool _validateLocationFields() {
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _showValidationError("Veuillez sélectionner votre pays");
      return false;
    }
    
    return true;
  }

  bool _validateUsernameFields() {
    if (_selectedUsername == null || _selectedUsername!.isEmpty) {
      _showValidationError("Veuillez choisir un nom d'utilisateur disponible");
      return false;
    }
    
    if (_selectedUsername!.length < 3) {
      _showValidationError("Le nom d'utilisateur doit contenir au moins 3 caractères");
      return false;
    }
    
    // Vérifier le format (lettres, chiffres, underscore, tiret)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(_selectedUsername!)) {
      _showValidationError("Le nom d'utilisateur ne peut contenir que des lettres, chiffres, tirets et underscores");
      return false;
    }
    
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Configuration pour chaque page d'onboarding
class OnboardingPageConfig {
  final String message;
  final Color color;
  final IconData icon;
  final List<Color> gradient;
  final bool isDataCollection;
  final DataType dataType;

  OnboardingPageConfig({
    required this.message,
    required this.color,
    required this.icon,
    required this.gradient,
    this.isDataCollection = false,
    this.dataType = DataType.message,
  });
}

enum DataType {
  message,
  personal,
  location,
  username,
}

