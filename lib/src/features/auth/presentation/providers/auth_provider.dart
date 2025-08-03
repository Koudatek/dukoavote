import 'package:dukoavote/src/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/upsert_user_profile.dart';
import '../../domain/usecases/check_username_availability.dart';

/// Represents the authentication state with proper error handling
class AuthState extends Equatable {
  final domain.User? user;
  final bool isLoading;
  final Failure? failure;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.failure,
    this.isAuthenticated = false,
  });

  /// Creates a loading state
  const AuthState.loading() : this(isLoading: true);

  /// Creates a success state with user data
  const AuthState.authenticated(domain.User user) 
    : this(user: user, isAuthenticated: true);

  /// Creates an error state
  const AuthState.error(Failure failure) : this(failure: failure);

  /// Creates an unauthenticated state
  const AuthState.unauthenticated() : this();

  AuthState copyWith({
    domain.User? user,
    bool? isLoading,
    Failure? failure,
    bool? isAuthenticated,
  }) {
    return AuthState(
        user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

  @override
  List<Object?> get props => [user, isLoading, failure, isAuthenticated];
}

/// Advanced authentication notifier with functional programming principles
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final UpdateProfile updateProfile;
  final HasCompleteProfile hasCompleteProfile;

  AuthNotifier({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.signOut,
    required this.getCurrentUser,
    required this.updateProfile,
    required this.hasCompleteProfile,
  }) : super(const AuthState.unauthenticated());

  /// Signs in a user with email and password
  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    final result = await signInWithEmail(
      email: email,
      password: password,
    );
    
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

  /// Signs up a new user with optional profile data
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    state = const AuthState.loading();
    
    final result = await signUpWithEmail(
      email: email,
      password: password,
      data: data,
    );
    
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

  /// Signs in with Google OAuth
  Future<Either<Failure, Unit>> signInWithGoogleOAuth({
    Map<String, dynamic>? data,
  }) async {
    state = const AuthState.loading();
    
    final result = await signInWithGoogle(data: data);
    
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

  /// Signs in with Apple OAuth
  Future<Either<Failure, Unit>> signInWithAppleOAuth({
    Map<String, dynamic>? data,
  }) async {
    state = const AuthState.loading();
    
    final result = await signInWithApple(data: data);
    
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

  /// Updates user profile information
  Future<Either<Failure, Unit>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    state = const AuthState.loading();
    
    final result = await updateProfile(data: data);
    
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

  /// Signs out the current user
  Future<Either<Failure, Unit>> signOutUser() async {
    state = const AuthState.loading();
    
    final result = await signOut();
    
    return result.fold(
      (failure) {
        state = AuthState.error(failure);
        return left(failure);
      },
      (_) {
        state = const AuthState.unauthenticated();
        return right(unit);
      },
    );
  }

  /// Loads the current authenticated user
  Future<Either<Failure, Unit>> loadCurrentUser() async {
    state = const AuthState.loading();
    
    final result = await getCurrentUser();
    
    return result.fold(
      (failure) {
        state = const AuthState.unauthenticated();
        return left(failure);
      },
      (user) {
        state = AuthState.authenticated(user);
        return right(unit);
      },
    );
  }

  /// Checks if user has complete profile
  Future<Either<Failure, bool>> checkCompleteProfile() async {
    return await hasCompleteProfile();
  }

  /// Clears any error state
  void clearError() {
    if (state.failure != null) {
      state = state.copyWith(failure: null);
    }
  }

  /// Retries the last operation (useful for network errors)
  Future<void> retry() async {
    if (state.failure is NetworkFailure) {
      await loadCurrentUser();
    }
  }
}

// Infrastructure providers
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDatasourceImpl(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

// Use case providers
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithEmail(repo);
});

final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignUpWithEmail(repo);
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repo);
});

final signInWithAppleProvider = Provider<SignInWithApple>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithApple(repo);
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return UpdateProfile(repo);
});

final hasCompleteProfileProvider = Provider<HasCompleteProfile>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return HasCompleteProfile(repo);
});

final checkUsernameAvailabilityProvider = Provider<CheckUsernameAvailability>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CheckUsernameAvailability(repo);
});

final signOutProvider = Provider<SignOut>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignOut(repo);
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repo);
});

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    signInWithGoogle: ref.watch(signInWithGoogleProvider),
    signInWithApple: ref.watch(signInWithAppleProvider),
    signOut: ref.watch(signOutProvider),
    getCurrentUser: ref.watch(getCurrentUserProvider),
    updateProfile: ref.watch(updateProfileProvider),
    hasCompleteProfile: ref.watch(hasCompleteProfileProvider),
  );
});


final authUserProvider = Provider<domain.User?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<Failure?>((ref) {
  return ref.watch(authProvider).failure;
});

final authIsAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Convenience providers
final authIsAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider);
  return user?.email == null || user?.email!.isEmpty == true;
});

final authHasCompleteProfileProvider = FutureProvider<bool>((ref) async {
  final hasCompleteProfile = ref.watch(hasCompleteProfileProvider);
  final result = await hasCompleteProfile();
  return result.fold(
    (failure) => false,
    (hasComplete) => hasComplete,
  );
}); 