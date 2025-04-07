import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meta/meta.dart';

import 'auth_bloc.dart'; // For @immutable

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final GoTrueClient _auth;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthBloc(this._auth) : super(AuthInitial()) {
    // Handle events
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<_AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStreamErrorOccurred>(_onStreamErrorOccurred);

  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  void _onStreamErrorOccurred(
      AuthStreamErrorOccurred event, Emitter<AuthBlocState> emit) {
    emit(AuthError(event.message));
  }


  // Event Handler: Start listening to Supabase auth state changes
  void _onSubscriptionRequested(
      AuthSubscriptionRequested event, Emitter<AuthBlocState> emit) {
    emit(AuthLoading());
    _authStateSubscription?.cancel();

    _authStateSubscription = _auth.onAuthStateChange.listen(
          (authState) {
        add(_AuthStatusChanged(authState));
      },
      onError: (error) {
        print('Auth Stream Error: $error');
        add(const AuthStreamErrorOccurred('Error listening to authentication changes.'));
      },
    );

  }


  // Event Handler: Process auth state changes received from Supabase
  void _onAuthStatusChanged(_AuthStatusChanged event, Emitter<AuthBlocState> emit) {
    final session = event.authState.session;
    if (session != null) {
      // User is logged in
      emit(Authenticated(session.user));
    } else {
      // User is logged out or session expired
      emit(Unauthenticated());
    }
  }

  // Event Handler: Handle login requests
  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthBlocState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      // Auth status change will be picked up by the stream listener
      // No need to emit Authenticated directly here if stream is working
      if (response.user == null) {
        emit(const AuthError('Login failed. Please check your credentials.'));
      }
    } on AuthException catch (e) {
      print('Login AuthException: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('Login Exception: $e');
      emit(const AuthError('An unexpected error occurred during login.'));
    }
  }

  // Event Handler: Handle sign-up requests
  Future<void> _onSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthBlocState> emit) async {
    emit(AuthLoading());
    try {
      // Include username in user metadata for the trigger function
      final response = await _auth.signUp(
        email: event.email,
        password: event.password,
        data: {'username': event.username}, // Pass username here
      );

      // Check if signup requires email confirmation
      if (response.user != null && response.user!.identities?.isEmpty == false) {
        // Usually means confirmation email sent, user not fully authenticated yet
        // Stay in Unauthenticated or emit a specific state like AuthConfirmationRequired
        emit(Unauthenticated(message: 'Please check your email to confirm your account.'));
      } else if (response.user != null) {
        // Auto-confirmed or already logged in (depends on Supabase settings)
        // Stream listener should pick this up, but can emit directly if needed
        // emit(Authenticated(response.user!));
      } else {
        emit(const AuthError('Signup failed. Please try again.'));
      }

    } on AuthException catch (e) {
      print('SignUp AuthException: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('SignUp Exception: $e');
      emit(const AuthError('An unexpected error occurred during sign up.'));
    }
  }

  // Event Handler: Handle logout requests
  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthBlocState> emit) async {
    emit(AuthLoading()); // Optional: show loading during logout
    try {
      await _auth.signOut();
      // Auth status change will be picked up by the stream listener
      // emit(Unauthenticated()); // Stream listener handles this
    } on AuthException catch (e) {
      print('Logout AuthException: ${e.message}');
      emit(AuthError(e.message)); // Revert to previous state or show error
    } catch (e) {
      print('Logout Exception: $e');
      emit(const AuthError('An unexpected error occurred during logout.'));
    }
  }
}