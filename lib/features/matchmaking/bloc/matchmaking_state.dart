part of 'matchmaking_bloc.dart';

sealed class MatchmakingState extends Equatable {
  const MatchmakingState();
}

final class MatchmakingInitial extends MatchmakingState {
  @override
  List<Object> get props => [];
}
