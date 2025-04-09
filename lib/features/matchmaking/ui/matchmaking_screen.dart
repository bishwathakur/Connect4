import 'package:connect4_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/connect_four_logo.dart';
import '../../game/bloc/game_bloc.dart';
import '../../game/ui/game_screen.dart';
import '../bloc/matchmaking_bloc.dart';
import '../widgets/action_button_widget.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchmakingBloc(Supabase.instance.client),
      child: BlocConsumer<MatchmakingBloc, MatchmakingState>(
          listener: (context, state) {
            final bloc = context.read<MatchmakingBloc>();

            debugPrint('🔁 MatchmakingBloc listener triggered with state: $state');

            if (state is MatchmakingError) {
              debugPrint('❌ MatchmakingError: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is MatchFound) {
              debugPrint('✅ MatchFound: Navigating to GameScreen with gameId: ${state.gameId}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) => GameBloc(
                      supabase: Supabase.instance.client,
                      userId: Supabase.instance.client.auth.currentUser!.id,
                    )..add(GameStarted(state.gameId)),
                    child: GameScreen(gameId: state.gameId),
                  ),
                ),
              );
            } else if (state is RoomCreated) {
              debugPrint('🆕 RoomCreated: gameId=${state.gameId}, code=${state.roomCode}');
              bloc.add(SubscribeToGameUpdates(state.gameId));

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: const Text("Room Created"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Share this room code with your friend:"),
                      const SizedBox(height: 12),
                      SelectableText(
                        state.roomCode,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('🟡 Continue tapped on dialog');
                        Navigator.of(context).pop();
                      },
                      child: const Text("Continue"),
                    )
                  ],
                ),
              );
            }
          },
        builder: (context, state) {
          final bloc = context.read<MatchmakingBloc>();

          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              title: Row(
                children: [
                  const ConnectFourLogo(size: 36),
                  const SizedBox(width: 12),
                  Text(
                    'CONNECT 4',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person, color: AppColors.primaryText),
                  onPressed: () {}, // Profile
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.primaryText),
                  onPressed: () {
                    debugPrint('🔒 Logout button pressed');
                    final authBloc = context.read<AuthBloc>();
                    authBloc.add((AuthLogoutRequested()));
                    debugPrint('🔒 Dispatching AuthLogoutRequested');
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }, // Logout
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'FIND A GAME',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to play',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 40),

                    ActionButtonWidget(
                      icon: Icons.shuffle,
                      title: 'FIND RANDOM OPPONENT',
                      subtitle: 'Quick match with a random player',
                      color: AppColors.primary,
                      onPressed: () {
                        bloc.add(FindRandomGameRequested());
                      },
                    ),
                    const SizedBox(height: 20),

                    ActionButtonWidget(
                      icon: Icons.add_circle_outline,
                      title: 'CREATE PRIVATE ROOM',
                      subtitle: 'Play with a friend using a room code',
                      color: AppColors.chipRed,
                      onPressed: () {
                        bloc.add(CreatePrivateRoomRequested());
                      },

                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.chipYellow.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.input, color: AppColors.chipYellow, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'JOIN PRIVATE ROOM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter a room code to join a friend',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _roomCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter room code',
                                    hintStyle: TextStyle(color: AppColors.secondaryText),
                                    filled: true,
                                    fillColor: AppColors.backgroundDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  style: TextStyle(color: AppColors.primaryText),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  final code = _roomCodeController.text.trim();
                                  if (code.isNotEmpty) {
                                    bloc.add(JoinRoomRequested(code));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.chipYellow,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('JOIN'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 200),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '243 Players Online',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state is MatchmakingLoading)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
