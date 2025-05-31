part of 'people_bloc.dart';

@immutable
abstract class PeopleState {}

class PeopleInitial extends PeopleState {}

class PeopleLoadingState extends PeopleState {
  @override
  List<Object?> get props => [];
}

class NetworkState extends PeopleState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class SearchLoadingState extends PeopleState {
  @override
  List<Object?> get props => [];
}

class NoReturnState extends PeopleState {
  final String? message;

  NoReturnState({this.message});

  @override
  List<Object> get props => [];
}

class PeopleErrorState extends PeopleState {
  final int? status;
  final String? message;

  PeopleErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class ErrorState extends PeopleState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [status.toString(), message!];
}

class GetPeopleState extends PeopleState {
  final SearchPeopleResponse getPeopleResponse;

  GetPeopleState({required this.getPeopleResponse});

  @override
  List<Object?> get props => [getPeopleResponse];
}

class GetSearchResultState extends PeopleState {
  final SearchPeopleResponse getPeopleResponse;

  GetSearchResultState({required this.getPeopleResponse});

  @override
  List<Object?> get props => [getPeopleResponse];
}

class FollowState extends PeopleState {
  // final FollowResponse follow;
  final String? status;
  final String? message;

  FollowState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class UnFollowState extends PeopleState {
  final FollowResponse follow;

  UnFollowState({required this.follow});
  @override
  List<Object?> get props => [follow];
}

class GetPeoplePostsState extends PeopleState {
  // final FeedResponse feedResponse;
  final GetSubjectProfileResponse profileResponse;
  // final GetVerifyFollowingResponse followingResponse;
  // final FollowingResponseCount totalFollowing;
  // final FollowersResponseCount totalFollowers;

  GetPeoplePostsState({
    //required this.feedResponse,
    required this.profileResponse,
    // required this.followingResponse,
    // required this.totalFollowers,
    // required this.totalFollowing
  });

  @override
  List<Object?> get props => [
        //feedResponse,
        profileResponse,
      ];
}

class BlockUserState extends PeopleState {
  final int? status;
  final String? message;

  BlockUserState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class GetFollowersState extends PeopleState {
  final FollowersResponse getFollowersResponse;

  GetFollowersState({required this.getFollowersResponse});

  @override
  List<Object?> get props => [getFollowersResponse];
}

class GetFolloweesState extends PeopleState {
  final FolloweesResponse getFolloweesResponse;

  GetFolloweesState({required this.getFolloweesResponse});

  @override
  List<Object?> get props => [getFolloweesResponse];
}

class TestState extends PeopleState {
  @override
  List<Object?> get props => [];
}
