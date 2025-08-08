import 'package:dukoavote/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Page de complétion de profil après connexion
class ProfileCompletionPage extends ConsumerStatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  ConsumerState<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends ConsumerState<ProfileCompletionPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedCity;
  DateTime? _selectedDate;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> _genders = ['Homme', 'Femme', 'Autre', 'Préfère ne pas dire'];
  final List<String> _countries = [
    'France', 'Belgique', 'Suisse', 'Canada', 'Maroc', 'Algérie', 'Tunisie',
    'Sénégal', 'Côte d\'Ivoire', 'Mali', 'Burkina Faso', 'Niger', 'Tchad',
    'Cameroun', 'Gabon', 'Congo', 'RDC', 'Rwanda', 'Burundi', 'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 ans
      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 ans
      lastDate: DateTime.now().subtract(const Duration(days: 3650)), // 10 ans
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
/*
  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(authProvider.notifier).clearError();
    
    final profileData = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'gender': _selectedGender,
      'country': _selectedCountry,
      'city': _selectedCity,
      if (_selectedDate != null) 'birth_date': _selectedDate!.toIso8601String(),
    };
    
    final result = await ref.read(authProvider.notifier).updateUserProfile(
      data: profileData,
    );
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil complété avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home
        context.go(RouteNames.home);
      },
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final error = ref.watch(authProvider).failure;

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                                                     Text(
                             'Complétez votre profil',
                             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                               fontWeight: FontWeight.bold,
                               color: AppColors.onboardingText,
                             ),
                             textAlign: TextAlign.center,
                           ),
                           const SizedBox(height: 8),
                           Text(
                             'Ces informations nous aident à personnaliser votre expérience',
                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                               color: AppColors.onboardingSubtext,
                             ),
                             textAlign: TextAlign.center,
                           ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    /*
                    // Error display
                    if (error != null) ...[
                      AppErrorWidget(
                        failure: error,
                        onRetry: () => ref.read(authProvider.notifier).retry(),
                      ),
                      const SizedBox(height: 24),
                    ],*/
                    
                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom d\'utilisateur *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un nom d\'utilisateur';
                        }
                        if (value.trim().length < 3) {
                          return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Gender dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Country dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Pays',
                        prefixIcon: Icon(Icons.public),
                        border: OutlineInputBorder(),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                          _selectedCity = null; // Reset city when country changes
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City field
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Birth date field
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                          prefixIcon: Icon(Icons.cake),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    //TODO : ........A faire........
                   /* 
                    // Complete profile button
                    ElevatedButton(
                      onPressed: isLoading ? null : _completeProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Compléter le profil',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    */
                    const SizedBox(height: 16),
                    
                                         // Skip button
                     OutlinedButton(
                       onPressed: isLoading ? null : () {
                         context.go(RouteNames.home);
                       },
                       child: const Text('Compléter plus tard'),
                     ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 