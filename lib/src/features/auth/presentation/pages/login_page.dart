import 'package:dukoavote/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dukoavote/src/core/routing/route_names.dart';
import 'package:dukoavote/src/features/onboarding/data/onboarding_local_storage.dart';

/// Page de connexion intégrée dans l'onboarding
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUp = false;
  bool _hasCompletedOnboarding = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingLocalStorage.isOnboardingCompleted();
    setState(() {
      _hasCompletedOnboarding = isCompleted;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(authProvider.notifier).clearError();
    
    final result = await ref.read(authProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
              content: Text('Connexion réussie !'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to home after successful login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(RouteNames.home);
            }
          });
        },
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(authProvider.notifier).clearError();
    
    // Récupérer les données de l'onboarding non synchronisées
    final onboardingData = await OnboardingLocalStorage.getUnsyncedOnboardingData();
    
    final profileData = <String, dynamic>{
      'username': onboardingData?['username'] ?? _usernameController.text.trim(),
      'birth_date': onboardingData?['birthDate']?.toString() ?? '',
      'gender': onboardingData?['gender'] ?? '',
      'country': onboardingData?['country'] ?? '',
      'age': onboardingData?['age'] ?? 0,
    };
    
    final result = await ref.read(authProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
      (_) async {
        // Marquer les données d'onboarding comme synchronisées
        await OnboardingLocalStorage.markOnboardingAsSynced();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    ref.read(authProvider.notifier).clearError();
    
    final result = await ref.read(authProvider.notifier).signInWithGoogleOAuth();
    
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
            content: Text('Connexion Google réussie !'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

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
                    const SizedBox(height: 40),
                    
                    // Logo et titre
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
                              Icons.how_to_vote,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'DukoaVote',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSignUp ? 'Créez votre compte' : 'Connectez-vous',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.onboardingSubtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Error display
                    if (error != null) ...[
                      AppErrorWidget(
                        failure: error,
                        onRetry: () => ref.read(authProvider.notifier).retry(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Username field (only for sign up)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isSignUp && (value == null || value.trim().isEmpty)) {
                            return 'Le nom d\'utilisateur est requis';
                          }
                          if (_isSignUp && value != null && value.trim().length < 3) {
                            return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'email est requis';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est requis';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm password field (only for sign up)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (_isSignUp && (value == null || value.isEmpty)) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (_isSignUp && value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Main action button
                    ElevatedButton(
                      onPressed: isLoading ? null : (_isSignUp ? _handleSignUp : _handleLogin),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isSignUp ? 'Créer un compte' : 'Se connecter',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),
                    
                    // OAuth buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _handleGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Google'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connexion Apple en cours...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.apple),
                            label: const Text('Apple'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Toggle between login and signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isSignUp ? 'Vous avez déjà un compte ?' : 'Vous n\'avez pas de compte ?'),
                        TextButton(
                          onPressed: () {
                            if (_isSignUp) {
                              setState(() {
                                _isSignUp = false;
                                _emailController.clear();
                                _passwordController.clear();
                                _usernameController.clear();
                                _confirmPasswordController.clear();
                              });
                            } else {
                              context.go(RouteNames.signup);
                            }
                          },
                          child: Text(_isSignUp ? 'Se connecter' : 'S\'inscrire'),
                        ),
                      ],
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