import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../bloc/game_bloc.dart';
import '../widgets/connect_four_board.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/player_avatar.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _dropAnimationController;

  @override
  void initState() {
    super.initState();
    _dropAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize game and subscribe to updates
    context.read<GameBloc>().add(GameStarted(widget.gameId));
  }

  @override
  void dispose() {
    _dropAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.boardBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grid_4x4,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CONNECT 4',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGameRules(context),
            color: AppColors.primaryText,
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is GameActive) {
            return Column(
              children: [
                const SizedBox(height: 16),
                // Game info panel (turn indicator, timer, etc.)
                GameInfoPanel(
                  isPlayerTurn: state.isCurrentPlayerTurn,
                  turnNumber: state.turnCount,
                  currentPlayerColor: state.isCurrentPlayerTurn
                      ? (state.isPlayer1 ? AppColors.chipRed : AppColors.chipYellow)
                      : (state.isPlayer1 ? AppColors.chipYellow : AppColors.chipRed),
                ),
                const SizedBox(height: 16),
                // Players info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Player 1 (Red)
                      Expanded(
                        child: _buildPlayerInfo(
                          name: state.player1Name,
                          color: AppColors.chipRed,
                          isCurrentTurn: state.currentTurn == 1,
                          score: state.player1Score,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Player 2 (Yellow)
                      Expanded(
                        child: _buildPlayerInfo(
                          name: state.player2Name,
                          color: AppColors.chipYellow,
                          isCurrentTurn: state.currentTurn == 2,
                          score: state.player2Score,
                          alignment: CrossAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Game board
                Expanded(
                  child: ConnectFourBoard(
                    board: state.board,
                    lastMove: state.lastMove,
                    isPlayerTurn: state.isCurrentPlayerTurn,
                    dropAnimationController: _dropAnimationController,
                    onColumnTapped: (column) {
                      if (state.isCurrentPlayerTurn) {
                        context.read<GameBloc>().add(ChipDropped(column));
                        _dropAnimationController.forward(from: 0);
                      }
                    },
                  ),
                ),
                // Game controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        context,
                        Icons.chat_bubble_outline,
                        'Chat',
                            () {
                          // Show chat overlay
                        },
                      ),
                      _buildControlButton(
                        context,
                        Icons.flag_outlined,
                        'Forfeit',
                            () {
                          _showForfeitDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is GameOver) {
            return _buildGameOverScreen(context, state);
          }

          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerInfo({
    required String name,
    required Color color,
    required bool isCurrentTurn,
    required int score,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppColors.backgroundLight
            : AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.start
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (alignment == CrossAxisAlignment.start)
                PlayerAvatar(color: color, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (alignment == CrossAxisAlignment.end) ...[
                const SizedBox(width: 8),
                PlayerAvatar(color: color, size: 24),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.start
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Text(
                isCurrentTurn ? "Your turn" : "Waiting...",
                style: TextStyle(
                  color: isCurrentTurn
                      ? color
                      : AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Wins: $score',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameOver state) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: state.isWinner ? AppColors.accent : AppColors.backgroundDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.isWinner ? 'You Won!' : 'You Lost',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('HOME'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: BorderSide(color: AppColors.primaryText.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Request rematch
                    context.read<GameBloc>().add(RematchRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('REMATCH'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'How to Play',
          style: TextStyle(color: AppColors.primaryText),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect 4 chips of your color in a row - horizontally, vertically, or diagonally to win!',
              style: TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.chipRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Player 1',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.chipYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Player 2',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  void _showForfeitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Forfeit Game',
          style: TextStyle(color: AppColors.primaryText),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Are you sure you want to forfeit? You will lose this game.',
          style: TextStyle(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameBloc>().add(GameForfeited());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('FORFEIT'),
          ),
        ],
      ),
    );
  }
}
