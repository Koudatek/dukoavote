import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
          child: user == null
              ? _buildAuthForm(context, ref)
              : _buildProfile(context, user),
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, WidgetRef ref) {
    // À compléter : formulaire d'inscription/connexion
    return Center(
      child: Text(
        'Veuillez vous connecter ou créer un compte.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildProfile(BuildContext context, dynamic user) {
    // À compléter : affichage/modification du profil
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nom d\'utilisateur : ${user.username ?? "-"}'),
        Text('Email : ${user.email ?? "-"}'),
        Text('Rôle : ${user.role ?? "-"}'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // TODO: Déconnexion
          },
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
} 