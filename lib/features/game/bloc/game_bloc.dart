import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SupabaseClient supabase;
  final String userId;

  GameBloc({required this.supabase, required this.userId}) : super(GameLoading()) {
    on<GameStarted>(_onGameStarted);
    on<ChipDropped>(_onChipDropped);
    on<GameForfeited>(_onGameForfeited);
    on<RematchRequested>(_onRematchRequested);
  }

  Future<void> _onGameStarted(GameStarted event, Emitter<GameState> emit) async {
    emit(GameLoading());
    try {
      final game = await supabase.from('games').select().eq('id', event.gameId).single();
      final isPlayer1 = game['player1_id'] == userId;
      final board = List<List<int>>.from(game['board_state'].map((row) => List<int>.from(row)));
      final currentTurn = game['current_turn_id'] == game['player1_id'] ? 1 : 2;

      emit(GameActive(
        board: board,
        currentTurn: currentTurn,
        turnCount: game['turn_count'] ?? 0,
        isCurrentPlayerTurn: game['current_turn_id'] == userId,
        isPlayer1: isPlayer1,
        lastMove: game['last_move'] != null
            ? Map<String, int>.from(game['last_move'])
            : null,
        player1Name: game['player1_name'] ?? 'Player 1',
        player2Name: game['player2_name'] ?? 'Player 2',
        player1Score: game['player1_score'] ?? 0,
        player2Score: game['player2_score'] ?? 0,
      ));
    } catch (e) {
      emit(GameError('Failed to start game: $e'));
    }
  }

  Future<void> _onChipDropped(ChipDropped event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GameActive) return;

    try {
      // Logic to update board in Supabase (add chip to column)
      final updatedGame = await supabase.rpc('drop_chip', params: {
        'game_id': 'your-game-id',
        'player_id': userId,
        'column': event.column,
      }).select().single();

      add(GameStarted(updatedGame['id']));
    } catch (e) {
      emit(GameError('Invalid move: $e'));
    }
  }

  Future<void> _onGameForfeited(GameForfeited event, Emitter<GameState> emit) async {
    try {
      await supabase.from('games').update({
        'status': 'forfeited',
        'winner_id': userId == 'player1_id' ? 'player2_id' : 'player1_id',
      }).eq('id', 'game-id');

      emit(const GameOver(isWinner: false, message: 'You forfeited the game.'));
    } catch (e) {
      emit(GameError('Failed to forfeit: $e'));
    }
  }

  Future<void> _onRematchRequested(RematchRequested event, Emitter<GameState> emit) async {
    try {
      // Optionally call a Supabase function to create a new game with same players
      emit(GameLoading());
      final rematchGame = await supabase.rpc('request_rematch', params: {
        'player_id': userId,
      }).select().single();

      add(GameStarted(rematchGame['id']));
    } catch (e) {
      emit(GameError('Rematch failed: $e'));
    }
  }
}

