import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/ui/auth_screen.dart';
import 'features/matchmaking/ui/matchmaking_screen.dart';
// import 'features/auth/view/auth_screen.dart';
// import 'features/matchmaking/view/matchmaking_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect4 Online',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const MatchmakingScreen();
          } else if (state is Unauthenticated ||
              state is AuthError ||
              state is AuthInitial ||
              state is AuthLoading) {
            return const AuthScreen();
          }
          return const Scaffold(
            body: Center(child: Text("Unexpected Auth State")),
          );
        },
      ),
    );
  }
}



