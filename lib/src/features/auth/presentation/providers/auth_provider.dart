import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';

class AuthState {
  final domain.User? user;
  final bool loading;
  final String? error;

  AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({domain.User? user, bool? loading, String? error}) => AuthState(
        user: user ?? this.user,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInAnonymously signInAnonymously;
  final SignOut signOutUsecase;
  final GetCurrentUser getCurrentUser;

  AuthNotifier({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInAnonymously,
    required this.signOutUsecase,
    required this.getCurrentUser,
  }) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await signInWithEmail(email, password);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await signUpWithEmail(email, password);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signInAnon(String gender, String birthDate, String age) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await signInAnonymously(gender, birthDate, age);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await signOutUsecase();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadCurrentUser() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await getCurrentUser();
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDatasourceImpl(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

final signInWithEmailProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithEmail(repo);
});

final signUpWithEmailProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignUpWithEmail(repo);
});

final signInAnonymouslyProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInAnonymously(repo);
});

final signOutProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignOut(repo);
});

final getCurrentUserProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repo);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    signInAnonymously: ref.watch(signInAnonymouslyProvider),
    signOutUsecase: ref.watch(signOutProvider),
    getCurrentUser: ref.watch(getCurrentUserProvider),
  );
}); 