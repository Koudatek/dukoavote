
import 'package:dukoavote/src/src.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';


// Provider pour AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.watch(supabaseClientProvider));
});

// Provider pour AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

// Providers pour les cas d'utilisation
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
});

final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) => 
SignInWithGoogle(ref.watch(authRepositoryProvider)));

final signInWithAppleProvider = Provider<SignInWithApple>((ref) => 
SignInWithApple(ref.watch(authRepositoryProvider)));

final checkUsernameAvailability = Provider<CheckUsernameAvailability>((ref) => 
CheckUsernameAvailability(ref.watch(authRepositoryProvider)));

// Provider pour AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    signOut: ref.watch(signOutProvider),
    getCurrentUser: ref.watch(getCurrentUserProvider),
    signInWithGoogle: ref.watch(signInWithGoogleProvider),
    signInWithApple: ref.watch(signInWithAppleProvider),
    checkUsernameAvailability: ref.watch(checkUsernameAvailability)
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;

  final CheckUsernameAvailability checkUsernameAvailability;

  AuthNotifier({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
    required this.signInWithGoogle,
    required this.signInWithApple, 
    required this.checkUsernameAvailability,
  }) : super(const AuthState());

  Future<Either<Failure, Unit>> _execute<T>(
    Future<Either<Failure, T>> Function() action,
    T Function(T) onSuccess,
  ) async {
    state = const AuthState.loading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AuthState.error(failure);
        return left(failure);
      },
      (value) {
        state = AuthState.authenticated(onSuccess(value) as User);
        return right(unit);
      },
    );
  }

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) async {
    return _execute(
      () => signInWithEmail(email: email, password: password),
      (user) => user,
    );
  }

  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return _execute(
      () => signUpWithEmail(email: email, password: password, data: data),
      (user) => user,
    );
  }

  Future<Either<Failure, Unit>> signOutUser() async {
    state = const AuthState.loading();
    final result = await signOut();
    return result.fold(
      (failure) {
        state = AuthState.error(failure);
        return left(failure);
      },
      (_) {
        state = const AuthState();
        return right(unit);
      },
    );
  }

  Future<Either<Failure, Unit>> loadCurrentUser() async {
    state = const AuthState.loading();
    final result = await getCurrentUser();
    return result.fold(
      (failure) {
        state = AuthState.error(failure);
        return left(failure);
      },
      (user) {
        state = AuthState.authenticated(user);
        return right(unit);
      },
    );
  }
}