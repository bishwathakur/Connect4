import 'package:connect4_flutter/core/widgets/connect_four_logo.dart';
import 'package:connect4_flutter/core/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLogin = true;

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (_isLogin) {
      context.read<AuthBloc>().add(AuthLoginRequested(email, password));
    } else {
      context.read<AuthBloc>().add(AuthSignUpRequested(email, password, username));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo and title
              Column(
                children: [
                  ConnectFourLogo(),
                  const SizedBox(height: 16),
                  Text(
                    'CONNECT 4',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Login to continue' : 'Create your account',
                    style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              // Form fields
              if (!_isLogin) TextFieldWidget(controller: _usernameController, label: 'Username', icon: Icons.person),
              const SizedBox(height: 16),
              TextFieldWidget(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFieldWidget(controller: _passwordController, label: 'Password', icon: Icons.lock, isPassword: true),
              const SizedBox(height: 40),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: Text(
                    _isLogin ? 'LOGIN' : 'SIGN UP',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Toggle login/signup
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                  style: TextStyle(color: AppColors.accent, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Error messages and loading indicator
              BlocBuilder<AuthBloc, AuthBlocState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return CircularProgressIndicator(color: AppColors.accent);
                  } else if (state is AuthError) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is Unauthenticated && state.message != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.message!,
                        style: const TextStyle(color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
