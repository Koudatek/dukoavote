import 'package:dukoavote/src/src.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final Failure? failure;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.failure,
  });

  const AuthState.loading() : this(isLoading: true);
  const AuthState.authenticated(User user) : this(user: user);
  const AuthState.error(Failure failure) : this(failure: failure);

  AuthState copyWith({
    User? user,
    bool? isLoading,
    Failure? failure,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, failure];
}