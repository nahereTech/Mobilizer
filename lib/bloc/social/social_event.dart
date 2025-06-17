part of 'social_bloc.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();
}

class GetFolloweeEvent extends SocialEvent {
  GetFolloweeEvent();
  @override
  List<Object> get props => [];
}

class GetSuggestionEvent extends SocialEvent {
  GetSuggestionEvent();
  @override
  List<Object> get props => [];
}
