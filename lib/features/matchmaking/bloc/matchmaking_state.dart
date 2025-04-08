part of 'matchmaking_bloc.dart';

@immutable
abstract class MatchmakingState extends Equatable {
  const MatchmakingState();

  @override
  List<Object?> get props => [];
}

class MatchmakingInitial extends MatchmakingState {}

class MatchmakingLoading extends MatchmakingState {}

class RoomCreated extends MatchmakingState {
  final String roomCode;
  final String gameId;
  const RoomCreated(this.roomCode, this.gameId);

  @override
  List<Object?> get props => [roomCode, gameId];
}

class RoomJoined extends MatchmakingState {
  final String gameId;
  const RoomJoined(this.gameId);

  @override
  List<Object?> get props => [gameId];
}

class MatchFound extends MatchmakingState {
  final String gameId;
  const MatchFound(this.gameId);

  @override
  List<Object?> get props => [gameId];
}

class MatchmakingError extends MatchmakingState {
  final String message;
  const MatchmakingError(this.message);

  @override
  List<Object?> get props => [message];
}
