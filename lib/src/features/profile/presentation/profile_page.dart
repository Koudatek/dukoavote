import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:dukoavote/src/core/ui/feedback_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showAuthForm = false;
  bool _isSignUp = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAnonymous = user == null || user.email == null || user.email!.isEmpty && user.username == null;
    //AppLogger.i("L'email :${user?.email}, username : ${user?.username}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isAnonymous
              ? _showAuthForm ? _buildAuthFormWidget(context) : _buildAuthForm(context)
              : _buildProfile(context, user),
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.progressBackground,
          child: Icon(Icons.person_outline, size: AppSpacing.iconSizeXl, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bienvenue sur votre profil invité',
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Vous votez actuellement en mode invité. Pour augmenter la crédibilité de vos votes et accéder à plus de fonctionnalités, connectez-vous ou créez un compte.',
          style: AppTextStyles.bodyMediumSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.info, size: AppSpacing.iconSizeMedium),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Vos informations sont sécurisées et ne seront jamais affichées dans les résultats de votes.',
                      style: AppTextStyles.bodySmallInfo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Créer un compte / Se connecter'),
          style: AppButtonStyles.primary,
          onPressed: () {
            setState(() {
              _showAuthForm = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAuthFormWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAuthForm = false;
                    _emailController.clear();
                    _passwordController.clear();
                    _usernameController.clear();
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  _isSignUp ? 'Créer un compte' : 'Se connecter',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.xxl), // Pour centrer le titre
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: AppInputStyles.username,
                    validator: (value) {
                      if (_isSignUp && (value == null || value.trim().isEmpty)) {
                        return 'Le nom d\'utilisateur est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: AppInputStyles.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  decoration: AppInputStyles.password,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le mot de passe est requis';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: AppButtonStyles.primaryLarge,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isSignUp ? 'Créer un compte' : 'Se connecter',
                          style: AppTextStyles.buttonLarge,
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _emailController.clear();
                      _passwordController.clear();
                      _usernameController.clear();
                    });
                  },
                  style: AppButtonStyles.text,
                  child: Text(_isSignUp 
                      ? 'Déjà un compte ? Se connecter'
                      : 'Pas de compte ? Créer un compte'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _usernameController.text.trim(),
        );
      } else {
        await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      
      // Seulement si l'opération réussit, on ferme le formulaire
      if (mounted) {
        setState(() {
          _showAuthForm = false;
          _emailController.clear();
          _passwordController.clear();
          _usernameController.clear();
        });
        FeedbackService.showSuccess(context, _isSignUp ? 'Compte créé avec succès !' : 'Connexion réussie !');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Une erreur est survenue';
        
        if (e.toString().contains('email_address_invalid')) {
          errorMessage = 'L\'adresse email n\'est pas valide';
        } else if (e.toString().contains('User already registered')) {
          errorMessage = 'Un compte avec cet email existe déjà';
        } else if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Email ou mot de passe incorrect';
        } else if (e.toString().contains('weak_password')) {
          errorMessage = 'Le mot de passe est trop faible';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        
        FeedbackService.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfile(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom d\'utilisateur : ${user.username ?? "-"}',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        Text(
          'Email : ${user.email ?? "-"}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          'Rôle : ${user.role ?? "-"}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            setState(() { _isLoading = true; });
            try {
              await ref.read(authProvider.notifier).signOut();
              if (mounted) {
                FeedbackService.showSuccess(context, 'Déconnexion réussie');
                setState(() {
                  _showAuthForm = false;
                  _isSignUp = true;
                  _isLoading = false;
                });
              }
            } catch (e) {
              if (mounted) {
                FeedbackService.showError(context, 'Erreur lors de la déconnexion');
                setState(() { _isLoading = false; });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Se déconnecter'),
        ),
      ],
    );
  }
} 