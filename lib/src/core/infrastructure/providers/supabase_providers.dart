import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

/// Provider pour le client Supabase
/// Placé dans la couche infrastructure pour respecter la Clean Architecture
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});

/// Provider pour l'utilisateur courant Supabase
final supabaseCurrentUserProvider = Provider<User?>((ref) {
  return SupabaseConfig.currentUser;
});

/// Provider pour vérifier si l'utilisateur est authentifié
final supabaseIsAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseConfig.isAuthenticated;
}); 