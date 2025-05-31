part of 'events_bloc.dart';

@immutable
abstract class EventsEvent {}

class CreateEventEvent extends EventsEvent {
  final Map<String, dynamic> createEventRequest;

  CreateEventEvent({required this.createEventRequest});

  @override
  List<Object> get props => [createEventRequest];
}

class GetEventsEvent extends EventsEvent {
  final int page;
  final int limit;
  GetEventsEvent({required this.page, required this.limit});
  @override
  List<Object> get props => [page, limit];
}

class GetEventTypesEvent extends EventsEvent {
  GetEventTypesEvent();
  @override
  List<Object> get props => [];
}

class DeleteEvent extends EventsEvent {
  final String eventID;
  DeleteEvent({required this.eventID});
  @override
  List<Object> get props => [eventID];
}

class GetTownhallsUserIsLeaderInEvent extends EventsEvent {
  GetTownhallsUserIsLeaderInEvent();
  @override
  List<Object> get props => [];
}
