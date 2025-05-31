part of 'events_bloc.dart';

@immutable
abstract class EventsState {}

class EventsInitial extends EventsState {}

class LoadingState extends EventsState {
  @override
  List<Object?> get props => [];
}

class CreateEventState extends EventsState {
  final CreateEventResponse createEventResponse;
  CreateEventState({required this.createEventResponse});

  @override
  List<Object?> get props => [createEventResponse];
}

class NetworkState extends EventsState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [message!];
}

class DeleteEventState extends EventsState {
  final String message;
  final String status;
  DeleteEventState({required this.message, required this.status});
  @override
  List<Object> get props => [message, status];
}

class EventListState extends EventsState {
  final EventsResponse eventsResponse;

  EventListState({required this.eventsResponse});

  @override
  List<Object> get props => [eventsResponse];
}

class EventTypesState extends EventsState {
  final EventTypesResponse typeResponse;

  EventTypesState({required this.typeResponse});

  @override
  List<Object?> get props => [typeResponse];
}

class ErrorState extends EventsState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [status!, message!];
}

class NoResultState extends EventsState {
  final String? message;
  NoResultState({this.message});
  @override
  List<Object> get props => [];
}

class GetTownhallsUserIsLeaderInState extends EventsState {
  final TownhallsLeaderIsResponse townhallList;
  final bool status;
  GetTownhallsUserIsLeaderInState(
      {required this.townhallList, required this.status});

  @override
  List<Object?> get props => [townhallList, status];
}
