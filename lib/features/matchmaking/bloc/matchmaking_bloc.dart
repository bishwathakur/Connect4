import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'matchmaking_event.dart';
part 'matchmaking_state.dart';

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _gameChannel;


  MatchmakingBloc(this._supabase) : super(MatchmakingInitial()) {
    on<CreatePrivateRoomRequested>(_onCreateRoom);
    on<JoinRoomRequested>(_onJoinRoom);
    on<FindRandomGameRequested>(_onFindRandomGame);
    on<SubscribeToGameUpdates>(_onSubscribeToGame);
    on<InitializeGame>(_onInitializeGame);
    on<GameMatched>((event, emit) {
      emit(MatchFound(event.gameId));
    });

  }

  Future<void> _onCreateRoom(CreatePrivateRoomRequested event, Emitter<MatchmakingState> emit) async {
    emit(MatchmakingLoading());
    try {
      final uid = _supabase.auth.currentUser!.id;
      final roomCode = _generateRoomCode();

      final response =
      await _supabase
          .from('games')
          .insert({'player1_id': uid, 'status': 'waiting', 'room_code': roomCode})
          .select()
          .single();

      final gameId = response['id']; // Get the gameId
      print("Room created with code: $roomCode");
      emit(RoomCreated(roomCode, gameId));

      // Subscribe to game updates immediately after creating the room
      add(SubscribeToGameUpdates(gameId)); // Use add instead of bloc.add

    } catch (e) {
      emit(MatchmakingError('Failed to create room: $e'));
    }
  }

  Future<void> _onJoinRoom(JoinRoomRequested event, Emitter<MatchmakingState> emit) async {
    emit(MatchmakingLoading());
    try {
      final uid = _supabase.auth.currentUser!.id;
      final code = event.roomCode;

      print('Attempting to join room with code: $code, uid: $uid');

      // Fetch the game record *before* the update
      final gameBeforeUpdate = await _supabase
          .from('games')
          .select('status, player2_id')
          .eq('room_code', code)
          .maybeSingle();

      print('Game status before update: ${gameBeforeUpdate?['status']}');
      print('Player2_id before update: ${gameBeforeUpdate?['player2_id']}');

      // Update the game row and return the updated row
      final response = await _supabase
          .from('games')
          .update({
        'player2_id': uid,
        'status': 'matched',
      })
          .eq('room_code', code)
          .eq('status', 'waiting')
          .filter('player2_id', 'is', null)
          .select('id, player1_id, player2_id, status')
          .maybeSingle();

      print('Supabase response: $response');

      print('Game status after update: ${response?['status']}');
      print('Player2_id after update: ${response?['player2_id']}');

      if (response == null) {
        emit(MatchmakingError('Invalid or full room code.'));
        return;
      }

      final gameId = response['id'];
      emit(RoomJoined(gameId));
      print('Joined room with ID: $gameId');
      // Emit MatchFound with 'matched' status and opponent ID
      final opponentId = response['player1_id'];
      print('Opponent ID: $opponentId');
      emit(MatchFound(gameId));
    } catch (e) {
      print('Error joining room: $e');
      emit(MatchmakingError('Invalid or full room code.'));
    }
  }

  Future<void> _onFindRandomGame(FindRandomGameRequested event, Emitter<MatchmakingState> emit) async {
    emit(MatchmakingLoading());
    try {
      final uid = _supabase.auth.currentUser!.id;

      final response =
      await _supabase
          .from('games')
          .select('id, player1_id, player2_id, status') // Select more fields
          .eq('status', 'waiting')
          .filter('player2_id', 'is', 'null')
          .not('player1_id', 'eq', uid)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        emit(const MatchmakingError('No available games found.'));
        return;
      }

      final updated =
      await _supabase
          .from('games')
          .update({'player2_id': uid, 'status': 'matched'}) // Changed to 'matched'
          .eq('id', response['id'])
          .select('id, player1_id, player2_id, status') // Select more fields
          .single();

      // Emit MatchFound with 'matched' status and opponent ID
      final opponentId = updated['player1_id']; // Or player2_id, depending on who joined
      emit(MatchFound(updated['id']));
    } catch (e) {
      emit(MatchmakingError('Failed to find game: $e'));
    }
  }

  Future<void> _onSubscribeToGame(
      SubscribeToGameUpdates event,
      Emitter<MatchmakingState> emit,
      ) async {
    final gameId = event.gameId;

    print('📡 Subscribing to realtime updates for game: $gameId');

    // Store the channel so it stays alive
    _gameChannel = _supabase.channel('public:games:id=eq.$gameId');

    _gameChannel!
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'games',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: gameId,
      ),
      callback: (payload) {
        print('✅ Realtime update received!');
        final newStatus = payload.newRecord['status'];
        print('New status: $newStatus');

        if (newStatus == 'matched' || newStatus == 'active') {
          add(GameMatched(gameId)); // ✅ Correct usage inside Bloc
        }
      },
    );

    final status = await _gameChannel!.subscribe();
    print('📶 Subscription status: $status');
  }





  Future<void> _onInitializeGame(InitializeGame event, Emitter<MatchmakingState> emit) async {
    try {
      final uid = _supabase.auth.currentUser!.id;
      final gameId = event.gameId;

      // Initialize board state (example - empty board)
      final initialBoardState = List.generate(6, (_) => List.filled(7, 0));

      // Determine starting player (randomly)
      final random = Random();
      final startingPlayerId = random.nextBool() ? uid : null; // Could be null

      await _supabase.from('games').update({
        'status': 'active',
        'board_state': initialBoardState,
        'current_turn_id': startingPlayerId,
      }).eq('id', gameId);

      //  No need to emit a new state here, as the Realtime subscription
      //  in GameBloc will handle the status change and update the UI.
    } catch (e) {
      emit(MatchmakingError('Failed to initialize game: $e'));
    }
  }


  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
