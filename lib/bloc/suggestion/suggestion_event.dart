part of 'suggestion_bloc.dart';

@immutable
abstract class SuggestionEvent extends Equatable {
  const SuggestionEvent();
}

class GetSuggestionEvent extends SuggestionEvent {
  GetSuggestionEvent();
  @override
  List<Object> get props => [];
}

class GetOrganizationEvent extends SuggestionEvent {
  //final String term;
  GetOrganizationEvent();
  @override
  List<Object> get props => [];
}

class GetInterestEvent extends SuggestionEvent {
  //final String term;
  GetInterestEvent();
  @override
  List<Object> get props => [];
}

class FollowEvent extends SuggestionEvent {
  final int followee;

  FollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class UnFollowEvent extends SuggestionEvent {
  final int followee;

  UnFollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class JoinEvent extends SuggestionEvent {
  final String org_id;

  JoinEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class LeaveEvent extends SuggestionEvent {
  final String org_id;

  LeaveEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class SearchOrganizationEvent extends SuggestionEvent {
  final String term;
  final String interest_id;
  SearchOrganizationEvent({required this.term, required this.interest_id});
  @override
  List<Object> get props => [term, interest_id];
}
