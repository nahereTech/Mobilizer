part of 'posts_bloc.dart';

@immutable
abstract class PostsEvent {}

class CreatePostEvent extends PostsEvent {
  final String message;
  final String with_file;
  final String org_id;
  final String group;
  final String posted_as_a_leader;
  List<File> file;
  List<dynamic> pollOptions;
  String poll;
  String poll_end;
  CreatePostEvent({
    required this.message,
    required this.with_file,
    required this.org_id,
    required this.group,
    required this.posted_as_a_leader,
    required this.file,
    required this.pollOptions,
    required this.poll,
    required this.poll_end,
  });

  @override
  List<Object> get props => [
        message,
        with_file,
        org_id,
        group,
        posted_as_a_leader,
        file,
        pollOptions,
        poll,
        poll_end
      ];
}

class PostResultEvent extends PostsEvent {
  final Map<String, dynamic> postResultRequest;
  //final List postResultRequest;
  //final List<File> images;

  PostResultEvent({required this.postResultRequest});

  @override
  List<Object> get props => [postResultRequest];
}

class GetElectionTypesEvent extends PostsEvent {
  GetElectionTypesEvent();
  @override
  List<Object> get props => [];
}

// class FeedEvent extends PostsEvent {
//   final FeedRequest feedRequest;

//   FeedEvent({required this.feedRequest});

//   @override
//   List<Object> get props => [feedRequest];
// }

class GetPartyEvent extends PostsEvent {
  final String countryID;
  final String forResult;
  final String theElection;

  GetPartyEvent(
      {required this.countryID,
      required this.forResult,
      required this.theElection});

  @override
  List<Object> get props => [countryID, forResult];
}

class BlockUserEvent extends PostsEvent {
  final String subjectID;
  final String req_type;

  BlockUserEvent({required this.subjectID, required this.req_type});

  @override
  List<Object> get props => [subjectID, req_type];
}

class LikePostEvent extends PostsEvent {
  final String post_id;

  LikePostEvent({required this.post_id});

  @override
  List<Object> get props => [post_id];
}

class UnLikePostEvent extends PostsEvent {
  final String post_id;

  UnLikePostEvent({required this.post_id});

  @override
  List<Object> get props => [post_id];
}

class LikeCommentEvent extends PostsEvent {
  final String comment_id;

  LikeCommentEvent({required this.comment_id});

  @override
  List<Object> get props => [comment_id];
}

class UnLikeCommentEvent extends PostsEvent {
  final String comment_id;

  UnLikeCommentEvent({required this.comment_id});

  @override
  List<Object> get props => [comment_id];
}

class AddCommentEvent extends PostsEvent {
  final CreateCommentsRequest createCommentsRequest;

  AddCommentEvent({required this.createCommentsRequest});

  @override
  List<Object> get props => [createCommentsRequest];
}

class DeleteCommentEvent extends PostsEvent {
  final String comment_id;
  final String commented_by;

  DeleteCommentEvent({required this.comment_id, required this.commented_by});

  @override
  List<Object> get props => [comment_id, commented_by];
}

class GetTownhallInfoEvent extends PostsEvent {
  final String townhallID;
  final String orgID;
  final String isThisAMore;

  GetTownhallInfoEvent(
      {required this.townhallID,
      required this.orgID,
      required this.isThisAMore});

  @override
  List<Object> get props => [townhallID, orgID, isThisAMore];
}

class ReportAbuseEvent extends PostsEvent {
  final String reported;
  final String post_id;
  final String comment;

  ReportAbuseEvent(
      {required this.reported, required this.post_id, required this.comment});

  @override
  List<Object> get props => [reported, post_id, comment];
}

class DeleteFeedEvent extends PostsEvent {
  final String post_id;
  final String posted_by;

  DeleteFeedEvent({required this.post_id, required this.posted_by});

  @override
  List<Object> get props => [post_id, posted_by];
}

class GetCommentEvent extends PostsEvent {
  final String post_id;
  final int limit;
  final String direction;

  GetCommentEvent(
      {required this.post_id, required this.limit, required this.direction});

  @override
  List<Object> get props => [post_id, limit, direction];
}

class GetPostCommentsEvent extends PostsEvent {
  final String postID;
  final int limit;
  final String orderBy;
  final int page;
  final String multidimensional;

  GetPostCommentsEvent({
    required this.postID,
    required this.limit,
    required this.orderBy,
    required this.page,
    required this.multidimensional,
  });

  @override
  List<Object> get props => [postID, limit, orderBy, page, multidimensional];
}

class FollowEvent extends PostsEvent {
  final int followee;

  FollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class GetLikesEvent extends PostsEvent {
  final String post_id;
  GetLikesEvent({required this.post_id});
  @override
  List<Object> get props => [post_id];
}

class UnFollowEvent extends PostsEvent {
  final int followee;

  UnFollowEvent({required this.followee});

  @override
  List<Object> get props => [followee];
}

class GetPostDetailsEvent extends PostsEvent {
  final String post_id;
  final String the_comment_id;

  GetPostDetailsEvent({required this.post_id, required this.the_comment_id});

  @override
  List<Object> get props => [post_id, the_comment_id];
}

class GetLikeDetailsEvent extends PostsEvent {
  final String like_id;

  GetLikeDetailsEvent({required this.like_id});

  @override
  List<Object> get props => [like_id];
}

class GetNotificationsEvent extends PostsEvent {
  final String last_row_id;
  final int limit;

  GetNotificationsEvent({required this.last_row_id, required this.limit});

  @override
  List<Object> get props => [last_row_id, limit];
}

class GetNotifications2Event extends PostsEvent {
  GetNotifications2Event();
  @override
  List<Object> get props => [];
}

class ShowNoticeBoardEvent extends PostsEvent {
  ShowNoticeBoardEvent();
  @override
  List<Object> get props => [];
}

class PollCastEvent extends PostsEvent {
  final String optionID;
  final String postID;
  PollCastEvent({required this.postID, required this.optionID});

  @override
  List<Object> get props => [postID, optionID];
}

class UpdateProgress extends PostsEvent {
  double percentage;
  UpdateProgress({required this.percentage});

  @override
  List<Object> get props => [percentage];
}

class TopFeedEvent extends PostsEvent {
  final String orgID;
  TopFeedEvent({
    required this.orgID,
  });

  @override
  List<Object> get props => [orgID];
}

class FeedEvent extends PostsEvent {
  final String orgID;
  // final String token;
  final String groupID;
  final String page;
  final String limit;
  final String olderOrNewer;
  final String pageOwner;

  FeedEvent({
    required this.orgID,
    //required this.token,
    required this.groupID,
    required this.page,
    required this.limit,
    required this.olderOrNewer,
    required this.pageOwner,
  });

  @override
  List<Object> get props => [orgID, orgID, groupID, page, limit, pageOwner];
}

class OnboardingEvent extends PostsEvent {
  @override
  List<Object> get props => [];
}

class LandingGroupEvent extends PostsEvent {
  @override
  List<Object> get props => [];
}
