import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'matchmaking_event.dart';
part 'matchmaking_state.dart';

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  MatchmakingBloc() : super(MatchmakingInitial()) {
    on<MatchmakingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
