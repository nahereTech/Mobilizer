part of 'suggestion_bloc.dart';

@immutable
abstract class SuggestionState {}

class SuggestionInitial extends SuggestionState {}

class LoadingState extends SuggestionState {
  @override
  List<Object?> get props => [];
}

class ErrorState extends SuggestionState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}
class NoReturnState extends SuggestionState {

  final String? message;

  NoReturnState({this.message});

  @override
  List<Object?> get props => [message];
}
class JoinState extends SuggestionState {
  final int? status;
  final String? message;
  JoinState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class LeaveState extends SuggestionState {
  final int? status;
  final String? message;
  LeaveState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class NetworkState extends SuggestionState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class GetSuggestionState extends SuggestionState {
  final SuggestionResponse getSuggestionResponse;

  GetSuggestionState({required this.getSuggestionResponse});

  @override
  List<Object?> get props => [getSuggestionResponse];
}

class FollowState extends SuggestionState {
  final FollowResponse follow;

  FollowState({required this.follow});

  @override
  List<Object?> get props => [follow];
}

class UnFollowState extends SuggestionState {
  final FollowResponse follow;

  UnFollowState({required this.follow});
  @override
  List<Object?> get props => [follow];
}
class AlreadyMemberState extends SuggestionState {
  final String? message;

  AlreadyMemberState({this.message});

  @override
  List<Object?> get props => [message];
}
class GetOrganizationState extends SuggestionState {
  final OrganizationResponse getOrganizationResponse;

  GetOrganizationState({required this.getOrganizationResponse});
  @override
  List<Object?> get props => [getOrganizationResponse];
}
class GetInterestState extends SuggestionState {
  final OrganizationInterestResponse getInterestResponse;

  GetInterestState({required this.getInterestResponse});
  @override
  List<Object?> get props => [getInterestResponse];
}
class SearchOrganizationState extends SuggestionState {
  final SearchOrganizationResponse searchOrganizationResponse;

  SearchOrganizationState({required this.searchOrganizationResponse});
  @override
  List<Object?> get props => [searchOrganizationResponse];
}
