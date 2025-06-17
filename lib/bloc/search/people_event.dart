part of 'people_bloc.dart';

@immutable
abstract class PeopleEvent {
  const PeopleEvent();
}

class GetPeopleEvent extends PeopleEvent {
  final String term;
  GetPeopleEvent({required this.term});
  @override
  List<Object> get props => [term];
}

class SearchPeopleEvent extends PeopleEvent {
  final String term;
  SearchPeopleEvent({required this.term});
  @override
  List<Object> get props => [term];
}

class BlockUserEvent extends PeopleEvent {
  final String subjectID;
  final String req_type;

  BlockUserEvent({required this.subjectID, required this.req_type});

  @override
  List<Object> get props => [subjectID, req_type];
}

class FollowEvent extends PeopleEvent {
  final int followee;

  FollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class UnFollowEvent extends PeopleEvent {
  final int followee;

  UnFollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class GetPeoplePostsEvent extends PeopleEvent {
  final String clickedUserID;

  GetPeoplePostsEvent({required this.clickedUserID});

  @override
  List<Object> get props => [clickedUserID];
}

class GetFollowersEvent extends PeopleEvent {
  final String subjectID;
  final String limit;
  final String page;

  GetFollowersEvent({required this.subjectID,required this.limit,required this.page});

  @override
  List<Object> get props => [subjectID,limit,page];
}
class GetFolloweesEvent extends PeopleEvent {
  final String subjectID;
  final String limit;
  final String page;

  GetFolloweesEvent({required this.subjectID,required this.limit,required this.page});

  @override
  List<Object> get props => [subjectID,limit,page];
}
