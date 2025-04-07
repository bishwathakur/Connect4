// --- States ---
part of 'auth_bloc.dart';

@immutable
abstract class AuthBlocState extends Equatable {
  const AuthBlocState();

  @override
  List<Object?> get props => [];
}

// Initial state before checking auth status
class AuthInitial extends AuthBlocState {}

// State while performing an auth operation (login, signup, checking)
class AuthLoading extends AuthBlocState {}

// State when the user is successfully authenticated
class Authenticated extends AuthBlocState {
  final User user; // Supabase User object

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// State when the user is not authenticated
class Unauthenticated extends AuthBlocState {
  final String? message; // Optional message (e.g., for email confirmation)
  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

// State when an authentication error occurs
class AuthError extends AuthBlocState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}