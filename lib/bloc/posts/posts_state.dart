part of 'posts_bloc.dart';

@immutable
abstract class PostsState {}

class PostsInitial extends PostsState {}

class LoadingState extends PostsState {
  @override
  List<Object?> get props => [];
}

class CompletedState extends PostsState {}

class TownhallInfoLoadingState extends PostsState {
  @override
  List<Object?> get props => [];
}

class CastedState extends PostsState {
  final int? status;
  final String? message;
  final String? postID;
  final String? userOption;

  CastedState({this.status, this.message, this.postID, this.userOption});

  @override
  List<Object?> get props => [status, message, postID, userOption];
}

class AbuseLoadingState extends PostsState {
  @override
  List<Object?> get props => [];
}

class GoToSuggestionState extends PostsState {
  final int? status;
  final String? message;

  GoToSuggestionState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class GoToProfileState extends PostsState {
  final int? status;
  final String? message;

  GoToProfileState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class GoToConfirmState extends PostsState {
  final String email;
  GoToConfirmState({required this.email});
  @override
  List<Object> get props => [email];
}

class GoToLogoutState extends PostsState {
  final String message;
  GoToLogoutState({required this.message});
  @override
  List<Object> get props => [message];
}

class FollowState extends PostsState {
  // final FollowResponse follow;
  final String? status;
  final String? message;

  FollowState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class UnFollowState extends PostsState {
  final FollowResponse follow;

  UnFollowState({required this.follow});
  @override
  List<Object?> get props => [follow];
}

class LikeListState extends PostsState {
  final LikeListResponse likeResponse;

  LikeListState({required this.likeResponse});
  @override
  List<Object?> get props => [likeResponse];
}

class GoToOrganizationState extends PostsState {
  @override
  List<Object> get props => [];
}

class FullyOnboardedState extends PostsState {
  final int buildNo;
  FullyOnboardedState({required this.buildNo});
  @override
  List<Object> get props => [buildNo];
}

class ErrorState extends PostsState {
  final int status;
  final String message;
  final String errorFor;

  ErrorState(
      {required this.status, required this.message, required this.errorFor});

  @override
  List<Object> get props => [status, message, errorFor];
}

class NetworkState extends PostsState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class NoPartyState extends PostsState {
  final int? status;
  final String? message;

  NoPartyState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class NoResultState extends PostsState {
  final String? message;

  NoResultState({this.message});

  @override
  List<Object> get props => [];
}

class CreatePostState extends PostsState {
  final CreatePostResponse createPostResponse;

  CreatePostState({required this.createPostResponse});

  @override
  List<Object?> get props => [createPostResponse];
}

class PostResultState extends PostsState {
  final PostResultResponse postResultResponse;

  PostResultState({required this.postResultResponse});

  @override
  List<Object?> get props => [postResultResponse];
}

class FeedState extends PostsState {
  final List<dynamic> feedResponse;
  final TopFeedResponse topFeedResponse;
  //final InputedData inputedData;

  final String orgName;
  final dynamic build_number;
  final dynamic orgID;

  FeedState(
      {required this.feedResponse,
      required this.topFeedResponse,
      //required this.inputedData,
      required this.orgName,
      this.orgID,
      required this.build_number});

  @override
  List<Object?> get props => [
        feedResponse,
        topFeedResponse,
        // inputedData,
        orgName,
        orgID,
        build_number
      ];
}

class TownhallInfoState extends PostsState {
  final TownhallInfoResponse townhallResponse;
  TownhallInfoState({required this.townhallResponse});
  @override
  List<Object?> get props => [townhallResponse];
}

class PartyState extends PostsState {
  final PartyResponse partyResponse;
  PartyState({required this.partyResponse});

  @override
  List<Object?> get props => [partyResponse];
}

class LikeState extends PostsState {
  final LikeResponse like;

  LikeState({required this.like});

  @override
  List<Object?> get props => [like];
}

class UnLikeState extends PostsState {
  final LikeResponse unlike;

  UnLikeState({required this.unlike});

  @override
  List<Object?> get props => [unlike];
}

class CreateCommentState extends PostsState {
  final NewCreateCommentsResponse createCommentsResponse;

  CreateCommentState({required this.createCommentsResponse});

  @override
  List<Object?> get props => [createCommentsResponse];
}

class DeleteCommentState extends PostsState {
  final DeleteCommentResponse deleteCommentResponse;

  DeleteCommentState({required this.deleteCommentResponse});

  @override
  List<Object?> get props => [deleteCommentResponse];
}

class DeleteFeedState extends PostsState {
  final DeleteFeedResponse deleteFeedResponse;

  DeleteFeedState({required this.deleteFeedResponse});

  @override
  List<Object?> get props => [deleteFeedResponse];
}

class CommentsState extends PostsState {
  final CommentsResponse commentsResponse;

  CommentsState({required this.commentsResponse});

  @override
  List<Object?> get props => [commentsResponse];
}

class LoadedCommentsState extends PostsState {
  final List<FeedData>? commentsResponse;
  final int requestFeedLength;

  LoadedCommentsState(
      {required this.commentsResponse, required this.requestFeedLength});

  @override
  List<Object?> get props => [commentsResponse, requestFeedLength];
}

class PostDetailsState extends PostsState {
  final FeedDetailsResponse postResponse;

  PostDetailsState({required this.postResponse});

  @override
  List<Object?> get props => [postResponse];
}

class NotificationsState extends PostsState {
  final NotificationsResponse notificationsResponse;

  NotificationsState({required this.notificationsResponse});

  @override
  List<Object?> get props => [notificationsResponse];
}

class AbuseReportState extends PostsState {
  final int? status;
  final String? message;

  AbuseReportState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class BlockUserState extends PostsState {
  final int? status;
  final String? message;

  BlockUserState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class UnauthorizedState extends PostsState {
  @override
  List<Object?> get props => [];
}

class JoinedOrganizationState extends PostsState {
  @override
  List<Object?> get props => [];
}

class GetElectionTypesState extends PostsState {
  final ElectionTypesResponse getElectionTypesResponse;

  GetElectionTypesState({required this.getElectionTypesResponse});
  @override
  List<Object?> get props => [getElectionTypesResponse];
}

class LikeDetailsState extends PostsState {
  final LikeDetailsResponse postResponse;

  LikeDetailsState({required this.postResponse});

  @override
  List<Object?> get props => [postResponse];
}

class ShowNoticeBoardState extends PostsState {
  final int? status;
  final String? msg;
  final String htmlMessage;

  ShowNoticeBoardState({this.status, this.msg, required this.htmlMessage});

  @override
  List<Object?> get props => [status, msg, htmlMessage];
}

class UploadInProgressState extends PostsState {
  final double progress;
  UploadInProgressState(this.progress);
}

class UploadCompletedState extends PostsState {}

class TopFeedPendingState extends PostsState {
  final String message;
  TopFeedPendingState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class TopFeedBlockedState extends PostsState {
  //the state will be called by top townhall
  final String message;
  TopFeedBlockedState({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class TopFeedUpdateTownhallState extends PostsState {
  //the state will be called by top townhall
  final String message;
  TopFeedUpdateTownhallState({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class TopFeedNoPermissionState extends PostsState {
  //the state will be called by top townhall
  final String message;
  TopFeedNoPermissionState({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class LoadedTopFeedState extends PostsState {
  final TopFeedResponse topFeedResponse;
  final bool showTownhallsOnTop;
  // final String orgID;
  // final String townhallID;
  // final String orgName;
  LoadedTopFeedState({
    required this.topFeedResponse,
    required this.showTownhallsOnTop, // to determine to show or not show townhall list
    // required this.orgID,
    // required this.townhallID,
    // required this.orgName
  });
  @override
  List<Object?> get props => [topFeedResponse, showTownhallsOnTop];
}

class LoadedFeedState extends PostsState {
  final List<dynamic> feedResponse;
  final String olderOrNewer;
  final int requestFeedLength;
  LoadedFeedState(
      {required this.feedResponse,
      required this.olderOrNewer,
      required this.requestFeedLength});
  @override
  List<Object?> get props => [feedResponse, olderOrNewer, requestFeedLength];
}

class OnboardingState extends PostsState {
  final String response;
  OnboardingState({required this.response});
  @override
  List<Object?> get props => [response];
}

class InvalidTokenState extends PostsState {
  @override
  List<Object?> get props => [];
}

class LandingGroupState extends PostsState {
  final int buildNo;
  LandingGroupState({required this.buildNo});
  @override
  List<Object?> get props => [buildNo];
}

class LoadedLandingGroupState extends PostsState {
  LandingData responseData;
  LoadedLandingGroupState({required this.responseData});
  @override
  List<Object?> get props => [responseData];
}
