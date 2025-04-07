// --- Events ---
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Event to start listening to auth changes
class AuthSubscriptionRequested extends AuthEvent {}

// Internal event triggered by the Supabase auth stream
class _AuthStatusChanged extends AuthEvent {
  final AuthState authState;
  const _AuthStatusChanged(this.authState);
  @override
  List<Object?> get props => [authState];
}

// Event for user login attempt
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// Event for user sign-up attempt
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthSignUpRequested(this.email, this.password, this.username);

  @override
  List<Object?> get props => [email, password, username];
}

class AuthStreamErrorOccurred extends AuthEvent {
  final String message;
  const AuthStreamErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}


// Event to log the user out
class AuthLogoutRequested extends AuthEvent {}