part of 'social_bloc.dart';

@immutable
abstract class SocialState {}

class SocialInitial extends SocialState {}

class LoadingState extends SocialState {
  @override
  List<Object?> get props => [];
}

class ErrorState extends SocialState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class NetworkState extends SocialState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class GetFolloweeState extends SocialState {
  final FolloweeResponse getFolloweeResponse;

  GetFolloweeState({required this.getFolloweeResponse});

  @override
  List<Object?> get props => [getFolloweeResponse];
}

class GetSuggestionState extends SocialState {
  final SuggestionResponse getSuggestionResponse;

  GetSuggestionState({required this.getSuggestionResponse});

  @override
  List<Object?> get props => [getSuggestionResponse];
}
