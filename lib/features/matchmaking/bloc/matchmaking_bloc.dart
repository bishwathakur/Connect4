import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'matchmaking_event.dart';
part 'matchmaking_state.dart';

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final SupabaseClient _supabase;

  MatchmakingBloc(this._supabase) : super(MatchmakingInitial()) {
    on<CreatePrivateRoomRequested>(_onCreateRoom);
    on<JoinRoomRequested>(_onJoinRoom);
    on<FindRandomGameRequested>(_onFindRandomGame);
    on<SubscribeToGameUpdates>(_onSubscribeToGame);
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

      print("Room created with code: $roomCode");
      emit(RoomCreated(roomCode, response['id']));
    } catch (e) {
      emit(MatchmakingError('Failed to create room: $e'));
    }
  }

  Future<void> _onJoinRoom(JoinRoomRequested event, Emitter<MatchmakingState> emit) async {
    emit(MatchmakingLoading());
    try {
      final uid = _supabase.auth.currentUser!.id;
      final code = event.roomCode;

      // Update the game row and return the updated row
      final response = await _supabase
          .from('games')
          .update({
        'player2_id': uid,
        'status': 'active',
      })
          .eq('room_code', code)
          .eq('status', 'waiting')
          .filter('player2_id', 'is', null)
          .select('id')
          .maybeSingle();

      if (response == null) {
        emit(MatchmakingError('Invalid or full room code.'));
        return;
      }

      final gameId = response['id'];
      emit(RoomJoined(gameId));
      emit(MatchFound(gameId));
    } catch (e) {
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
              .select()
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
              .update({'player2_id': uid, 'status': 'active'})
              .eq('id', response['id'])
              .select()
              .single();

      emit(MatchFound(updated['id']));
    } catch (e) {
      emit(MatchmakingError('Failed to find game: $e'));
    }
  }

  Future<void> _onSubscribeToGame(SubscribeToGameUpdates event, Emitter<MatchmakingState> emit) async {
    final channel = _supabase.channel('game:${event.gameId}');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'games',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: event.gameId),
          callback: (payload) {
            final newStatus = payload.newRecord['status'];
            if (newStatus == 'active') {
              final gameId = payload.newRecord['id'] as String;
              emit(MatchFound(gameId));
            }
          },
        )
        .subscribe();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
