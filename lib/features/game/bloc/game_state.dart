part of 'game_bloc.dart';

// States
abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object> get props => [];
}

class GameLoading extends GameState {}

class GameMatched extends GameState {} // New state for "matched"

class GameActive extends GameState {
  final List<List<int>> board; // 0 = empty, 1 = P1, 2 = P2
  final int currentTurn;
  final int turnCount;
  final bool isCurrentPlayerTurn;
  final bool isPlayer1;
  final Map<String,int>? lastMove;
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;

  const GameActive({
    required this.board,
    required this.currentTurn,
    required this.turnCount,
    required this.isCurrentPlayerTurn,
    required this.isPlayer1,
    required this.lastMove,
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
  });

  @override
  List<Object> get props => [
    board,
    currentTurn,
    turnCount,
    isCurrentPlayerTurn,
    isPlayer1,
    lastMove ?? [],
    player1Name,
    player2Name,
    player1Score,
    player2Score,
  ];
}

class GameOver extends GameState {
  final bool isWinner;
  final String message;

  const GameOver({required this.isWinner, required this.message});

  @override
  List<Object> get props => [isWinner, message];
}

class GameError extends GameState {
  final String message;
  const GameError(this.message);

  @override
  List<Object> get props => [message];
}