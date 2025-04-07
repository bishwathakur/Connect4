// features/matchmaking/ui/matchmaking_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';

class MatchmakingScreen extends StatelessWidget {
  const MatchmakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement Matchmaking UI (Find Random, Create Room, Join Room)
    // This screen will likely interact with a MatchmakingBloc
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect4 - Find Game'),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
          // TODO: Add button to navigate to Profile Screen
        ],
      ),
      body: const Center(
        child: Text('Matchmaking Screen Placeholder - Implement Game Modes Here'),
      ),
    );
  }
}