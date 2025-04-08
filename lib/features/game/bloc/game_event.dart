part of 'game_bloc.dart';

// Events
@immutable
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class GameStarted extends GameEvent {
  final String gameId;
  const GameStarted(this.gameId);
}

class ChipDropped extends GameEvent {
  final int column;
  const ChipDropped(this.column);
}

class GameForfeited extends GameEvent {}

class RematchRequested extends GameEvent {}