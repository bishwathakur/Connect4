part of 'matchmaking_bloc.dart';

@immutable
abstract class MatchmakingEvent extends Equatable {
  const MatchmakingEvent();

  @override
  List<Object> get props => [];
}

// Create a game room
class CreatePrivateRoomRequested extends MatchmakingEvent {}

// Join a room with a code
class JoinRoomRequested extends MatchmakingEvent {
  final String roomCode;
  const JoinRoomRequested(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}

// Find any waiting game and try to join
class FindRandomGameRequested extends MatchmakingEvent {}

// Start listening to changes in a game
class SubscribeToGameUpdates extends MatchmakingEvent {
  final String gameId;
  const SubscribeToGameUpdates(this.gameId);

  @override
  List<Object> get props => [gameId];
}

class GameMatched extends MatchmakingEvent {
  final String gameId;

  const GameMatched(this.gameId);

  @override
  List<Object> get props => [gameId];
}


// Initialize the game with the current user
class InitializeGame extends MatchmakingEvent {
  final String gameId;
  const InitializeGame(this.gameId);

  @override
  List<Object> get props => [gameId];
}



