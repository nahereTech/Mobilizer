import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/Follow/follow_response.dart';
import 'package:mobilizer/models/Result/post_result_response.dart';
import 'package:mobilizer/models/comments/comments_of_post_response.dart';
import 'package:mobilizer/models/comments/comments_response.dart';
import 'package:mobilizer/models/comments/create_comments_request.dart';
import 'package:mobilizer/models/comments/create_comments_response.dart';
import 'package:mobilizer/models/comments/delete_comment_response.dart';
import 'package:mobilizer/models/comments/new_create_comment_response.dart';
import 'package:mobilizer/models/createpost/createpost_response.dart';
import 'package:mobilizer/models/election/election_types_response.dart';
import 'package:mobilizer/models/feed/delete_feed_response.dart';
import 'package:mobilizer/models/feed/feed_details_response.dart';
import 'package:mobilizer/models/feed/feed_request.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/feed/report_abuse_response.dart';
import 'package:mobilizer/models/feed/topfeed_response.dart';
import 'package:mobilizer/models/feed/feed_details_response.dart' as fd;
import 'package:mobilizer/models/like/like_details_response.dart';
import 'package:mobilizer/models/login/is_user_onboarded_response.dart';
import 'package:mobilizer/models/login/landing_group_response.dart';
import 'package:mobilizer/models/notifications/notice_board_response.dart';
import 'package:mobilizer/models/parties/parties_response.dart';
import 'package:mobilizer/models/poll/poll_cast_response.dart';
import 'package:mobilizer/models/professions/professions_response.dart';
import 'package:mobilizer/models/profile/block_user_response.dart';
import 'package:mobilizer/models/profile/get_profile_complete_response.dart';
import 'package:mobilizer/models/social/followee_response.dart';
import 'package:mobilizer/models/like/like_response.dart';
import 'package:mobilizer/models/notifications/notifications_response.dart';
import 'package:mobilizer/models/register/register_response.dart';
import 'package:mobilizer/models/profile/get_profile_response.dart';
import 'package:mobilizer/models/social/like_list_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:mobilizer/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../social/social_bloc.dart';
part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  List<FeedData> feedData = [];
  bool _isConnectionSuccessful = false;
  TopFeedResponse? responseTopData;
  final _progressController = StreamController<double>();
  Stream<double> get progressStream => _progressController.stream;
  // check for internet connection
  PostsBloc() : super(PostsInitial()) {
    on<CreatePostEvent>(_onCreatePostEvent);
    on<FeedEvent>(_onFeedEvent);
    on<TopFeedEvent>(_onTopFeedEvent);
    on<OnboardingEvent>(_onOnboardingEvent);
    on<LandingGroupEvent>(_onLandingGroupEvent);
    on<LikePostEvent>(_onLikePostEvent);
    on<UnLikePostEvent>(_onUnLikePostEvent);
    on<LikeCommentEvent>(_onLikeCommentEvent);
    on<UnLikeCommentEvent>(_onUnLikeCommentEvent);
    on<AddCommentEvent>(_onAddCommentEvent);
    on<DeleteCommentEvent>(_onDeleteCommentEvent);
    on<DeleteFeedEvent>(_onDeleteFeedEvent);
    on<GetCommentEvent>(_onGetCommentEvent);
    on<GetPostDetailsEvent>(_onGetPostDetailsEvent);
    on<GetLikeDetailsEvent>(_onGetLikeDetailsEvent);
    on<GetNotificationsEvent>(_onGetNotificationsEvent);
    on<ReportAbuseEvent>(_onReportAbuseEvent);
    on<GetTownhallInfoEvent>(_onGetTownhallInfoEvent);
    on<BlockUserEvent>(_onBlockUserEvent);
    on<FollowEvent>(_onFollowEvent);
    on<UnFollowEvent>(_onUnFollowEvent);
    on<GetLikesEvent>(_onGetLikesEvent);
    on<GetPartyEvent>(_onGetPartyEvent);
    on<PostResultEvent>(_onPostResultEvent);
    on<GetElectionTypesEvent>(_onGetElectionTypesEvent);
    on<ShowNoticeBoardEvent>(_onShowNoticeBoardEvent);
    on<PollCastEvent>(_onPollCastEvent);
    on<GetPostCommentsEvent>(_onGetPostCommentsEvent);
  }
  Future<void> _onPollCastEvent(
      PollCastEvent event, Emitter<PostsState> emit) async {
    try {
      print("Am here 1cvcvcv");
      //emit(LoadingState());
      var token = await getToken();

      Map<String, dynamic> map = Map();
      map["post_id"] = event.postID;
      map["option_id"] = event.optionID;

      PollCastResponse responseData = await ApiService().pollCast(token!, map);
      if (responseData.status == 200) {
        emit(CastedState(
            message: responseData.msg,
            status: responseData.status,
            postID: event.postID,
            userOption: responseData.data.user_option));
        print(responseData.msg);
      } else if (responseData.status == 400 || responseData.status == 401) {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      } else {
        print("Am here and1");
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
        print(responseData.msg);
      }
    } on SocketException {
      print("Am here 1z");
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Am here 1");
      debugPrint("${e.source}");
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      print("Am here 2");
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Am here 3");
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onBlockUserEvent(
      BlockUserEvent event, Emitter<PostsState> emit) async {
    try {
      //emit(LoadingState());
      var token = await getToken();

      Map<String, dynamic> map = Map();
      map["person_to_block"] = event.subjectID;
      map["req_type"] = event.req_type;
      print(
          "req_type: ${event.req_type}   person to block: ${event.subjectID}");

      BlockUserResponse responseData =
          await ApiService().blockUser(token!, map);
      if (responseData.status == 200) {
        emit(BlockUserState(
            message: responseData.msg, status: responseData.status));
        print(responseData.msg);
      } else if (responseData.status == 400 || responseData.status == 401) {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
        print(responseData.msg);
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetTownhallInfoEvent(
      GetTownhallInfoEvent event, Emitter<PostsState> emit) async {
    try {
      emit(TownhallInfoLoadingState());
      var token = await getToken();
      TownhallInfoResponse responseData = await ApiService().getTownhallInfo(
          token!, event.orgID, event.townhallID, event.isThisAMore);

      if (responseData.status == 200) {
        print("TownhallInfo Bloc state");

        emit(TownhallInfoState(townhallResponse: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg!,
            status: responseData.status,
            errorFor: ''));
        print(responseData.msg);
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onReportAbuseEvent(
      ReportAbuseEvent event, Emitter<PostsState> emit) async {
    try {
      emit(AbuseLoadingState());
      var token = await getToken();

      Map<String, dynamic> map = Map();
      map["post_id"] = event.post_id;
      map["reported"] = event.reported;
      map["comment"] = event.comment;
      ReportAbuseResponse responseData =
          await ApiService().reportAbuse(token!, map);
      if (responseData.status == 200) {
        emit(AbuseReportState(
            message: responseData.msg, status: responseData.status));
        print(responseData.msg);
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
        print(responseData.msg);
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onCreatePostEvent(
      CreatePostEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      print("MakeP ${event.message}");
      print("Events: ${event.posted_as_a_leader}");
      CreatePostResponse responseData = await ApiService().createPost(
        token!,
        event.file,
        event.message,
        event.org_id,
        event.group,
        event.posted_as_a_leader,
        event.pollOptions,
        event.poll_end,
        event.poll,
      );

      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(CreatePostState(createPostResponse: responseData));
      } else {
        print("Error1");
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onPostResultEvent(
      PostResultEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      final multipartFiles = <MultipartFile>[];

      // for (final file in event.images) {
      //   final fileBytes = await file.readAsBytes();
      //   final multipartFile = MultipartFile.fromBytes(
      //     fileBytes,
      //     filename: file.path.split('/').last,
      //     //contentType: MediaType('application', 'octet-stream'),
      //   );
      //   multipartFiles.add(multipartFile);
      // }

      PostResultResponse responseData =
          await ApiService().postResult(token!, event.postResultRequest);
      print("Is a posting as a leader: ${event.postResultRequest}");
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(PostResultState(postResultResponse: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetPartyEvent(
      GetPartyEvent event, Emitter<PostsState> emit) async {
    try {
      //emit(LoadingState());
      var token = await getToken();
      Map<String, dynamic> map = {
        'country_id': event.countryID,
        'for_result': 'yes',
        'the_election': event.theElection,
      };
      PartyResponse responseData = await ApiService().getParties(token!, map);
      //print("status ${responseData.status}");
      if (responseData.status == "200") {
        print("Am inside 200");
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(PartyState(partyResponse: responseData));
        }
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: int.parse(responseData.status),
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onOnboardingEvent(
      OnboardingEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      var deviceToken = await getDeviceToken();
      final userID = await AppSharedPreferences.getValue(key: 'user_id');
      feedData.clear();
      UserOnboardedResponse onboardedResponse =
          await ApiService().getUserOnboarded(token!, deviceToken.toString());
      if (await _userExist(userID.toString()) == false) {
        //create user
        Map<String, dynamic> userData = {
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp()
        };
        _createFirestoreUser(userID.toString(), userData);
      }
      if (onboardedResponse.status == 409) {
        clearCache();
        emit(InvalidTokenState());
        //invalid token or token not sent
      }
      if (onboardedResponse.status == 200) {
        print("Build no: ${onboardedResponse.data!.build_number}");
        //check orgID is empty
        var prefOrgID = await getOrg();
        var prefGroupID = await AppSharedPreferences.getBool(key: 'groupID');

        if (prefOrgID == null || prefOrgID == "") {
          emit(
              LandingGroupState(buildNo: onboardedResponse.data!.build_number));
        } else {
          emit(FullyOnboardedState(
              buildNo: onboardedResponse.data!.build_number));
        }
      } else {
        if (onboardedResponse.data!.action == "not_following_user") {
          emit(GoToSuggestionState(
              status: 200, message: "successful")); //Goto suggestion route
        } else if (onboardedResponse.data!.action == "not_following_org") {
          emit(GoToOrganizationState()); //emit GoToOrganoationState
        } else if (onboardedResponse.data!.action == "profile_incomplete") {
          print("Am here");
          emit(GoToProfileState(status: 400, message: 'Go to profile'));
        } else if (onboardedResponse.data!.action == "log_user_out") {
          emit(GoToLogoutState(message: 'Go to logout'));
        } else if (onboardedResponse.data!.action == "user_unconfirmed") {
          emit(GoToConfirmState(
              email: onboardedResponse.data!
                  .email)); //user should be logout and taken to confirm page
        } else {}
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onLandingGroupEvent(
      LandingGroupEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      LandingGroupResponse landingResponse =
          await ApiService().getLandingGroup(token!);
      if (landingResponse.status == 200) {
        print('Landing Org: ${landingResponse.data!.org_id.toString()}');
        //update sharepref
        await AppSharedPreferences.setValue(
            key: 'groupID',
            value: landingResponse.data!.townhall_id.toString());
        await AppSharedPreferences.setValue(
            key: 'orgID', value: landingResponse.data!.org_id.toString());

        await AppSharedPreferences.setValue(
            key: 'orgName', value: landingResponse.data!.org_name);
        emit(LoadedLandingGroupState(responseData: landingResponse.data!));
      } else {
        emit(ErrorState(
            message: landingResponse.msg,
            status: landingResponse.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Error Landing: " + e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onFeedEvent(FeedEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print("token: ${token}");
      var deviceToken = await getDeviceToken();
      var prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
      FeedResponse responseData = await ApiService().feed(
          token.toString(),
          prefOrgID.toString(),
          event.groupID,
          event.page,
          event.limit,
          event.olderOrNewer,
          event.pageOwner,
          deviceToken.toString());

      if (responseData.status == 200) {
        print("Am here now1");
        if (event.olderOrNewer == "newer") {
          feedData.insertAll(0, responseData.data!);
          emit(
            LoadedFeedState(
                feedResponse: feedData,
                olderOrNewer: 'newer',
                requestFeedLength: responseData.data!.length),
          );
        } else if (event.olderOrNewer == "older") {
          feedData.addAll(responseData.data!);
          emit(
            LoadedFeedState(
                feedResponse: feedData,
                olderOrNewer: 'older',
                requestFeedLength: responseData.data!.length),
          );
        } else {
          feedData.clear();
          feedData.addAll(responseData.data!);
          emit(LoadedFeedState(
              feedResponse: feedData,
              olderOrNewer: '',
              requestFeedLength: responseData.data!.length));
        }
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Error: " + e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onTopFeedEvent(
      TopFeedEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      TopFeedResponse responseData =
          await ApiService().topFeed(token.toString(), event.orgID.toString());
      print("Tag2: ${responseData.tag}");
      if (responseData.status.toString() == "200") {
        // var prefTownhallID =
        //     await AppSharedPreferences.getValue(key: 'groupID');
        // var prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
        // var prefOrgName = await AppSharedPreferences.getValue(key: 'orgName');

        emit(LoadedTopFeedState(
            topFeedResponse: responseData,
            showTownhallsOnTop: responseData.show_townhalls_on_top
            // townhallID: prefTownhallID.toString(),
            // orgID: prefOrgID.toString(),
            // orgName: prefOrgName.toString(),
            ));
      } else {
        print("${responseData.tag} II");
        if (responseData.tag == "pending") {
          emit(TopFeedPendingState(message: responseData.msg));
        }
        if (responseData.tag == "blocked") {
          emit(TopFeedBlockedState(message: responseData.msg));
        }
        if (responseData.tag == "update_townhalls") {
          print("Update now");
          emit(TopFeedUpdateTownhallState(message: responseData.msg));
        }
        if (responseData.tag == "no_permission") {
          emit(TopFeedNoPermissionState(message: responseData.msg));
        }
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Am new here pppppppp");
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  // Future<void> _onFeedEvent(FeedEvent event, Emitter<PostsState> emit) async {
  //   try {
  //     var token = await getToken();
  //     var device_token = await getDeviceToken();
  //     dynamic buildNumber = 0;
  //     var orgName = '';

  //     print("TokenX: " + token.toString());
  //     if (event.feedRequest.townhall_tap == false) {
  //       /*
  //       Check if user is fully onboarded
  //       */
  //       //if (event.feedRequest.skipOnboarding == false) {
  //       // UserOnboardedResponse onboardedResponse =
  //       //     await client.getUserOnboarded(token!);
  //       UserOnboardedResponse onboardedResponse =
  //           await ApiService().getUserOnboarded(token!);
  //       //print();
  //       buildNumber = onboardedResponse.data!.build_number;
  //       // if (onboardedResponse.data!.action != "") {
  //       //   emit(GoToSuggestionState(status: 200, message: "successful"));
  //       // }
  //       print("Am here ${onboardedResponse.data!.action} ${buildNumber}");
  //       if (onboardedResponse.data!.action == "not_following_user") {
  //         print("Am here1");
  //         emit(GoToSuggestionState(
  //             status: 200, message: "successful")); //Goto suggestion route
  //       } else if (onboardedResponse.data!.action == "not_following_org") {
  //         print("Am here2");
  //         emit(GoToOrganizationState()); //emit GoToOrganoationState
  //       } else if (onboardedResponse.data!.action == "profile_incomplete") {
  //         print("Am here3");
  //         emit(GoToProfileState(status: 400, message: 'Go to profile'));
  //       } else if (onboardedResponse.data!.action == "log_user_out") {
  //         print("Am here4");
  //         emit(GoToLogoutState(message: 'Go to logout'));
  //       } else if (onboardedResponse.data!.action == "user_unconfirmed") {
  //         print("Am here5");
  //         emit(GoToConfirmState(
  //             email: onboardedResponse.data!
  //                 .email)); //user should be logout and taken to confirm page
  //       }
  //     }
  //     //please break this else into a function that can be use in this bloc
  //     else {
  //       print("Am here else");
  //       //USER PASSED ALL ONBOARDING AT THIS POINT
  //       var profileImage = '';
  //       var orgID = await getOrg();
  //       var prefOrgName = await getOrgName();
  //       //print("My orgID ${orgID}");

  //       //Check if user has already entered an organization, otherwise fetch last visited.
  //       if (orgID == null ||
  //           orgID == "" ||
  //           prefOrgName == null ||
  //           prefOrgName == "") {
  //         LandingGroupResponse responseCompleteData =
  //             await ApiService().getLandingGroup(token.toString());

  //         // print("isLeader: ${responseCompleteData.data!.is_leader}");
  //         //set org ID
  //         orgID = responseCompleteData.data!.org_id;
  //         // print("Am here" + orgID);
  //         orgName = responseCompleteData.data!.org_name;
  //         //print("Group name: ${orgName}");
  //         prefOrgName = orgName;

  //         await AppSharedPreferences.setValue(
  //             key: 'orgID', value: responseCompleteData.data!.org_id);
  //         await AppSharedPreferences.setValue(
  //             key: 'isLeader', value: responseCompleteData.data!.is_leader);

  //         //  print("Org ID Block ${orgID}");
  //         await AppSharedPreferences.setValue(
  //             key: 'orgName', value: responseCompleteData.data!.org_name);
  //         print(
  //             "orgID: ${responseCompleteData.data!.org_id} leaderID: ${responseCompleteData.data!.is_leader}");
  //         print("My orgName ${responseCompleteData.data!.org_name}");
  //       }

  //       //get groups or topfeed
  //       if (event.feedRequest.skipTopFeed == false) {
  //         // Map<String, dynamic> map = {
  //         //   'org_id': orgID.toString(),
  //         // };
  //         responseTopData =
  //             await ApiService().topFeed(token.toString(), orgID.toString());
  //         //print("Yes here");
  //         //print("Yes here ${responseTopData}");
  //       }
  //       if (responseTopData!.status == 406) {
  //         //the person hasn't joined townhall
  //         emit(JoinedOrganizationState());
  //       }

  //       //print(responseTopData);
  //       // var nw = await getTownhallView();
  //       String groupId = '';
  //       // print("RESPONSE: ${responseTopData!.status}");
  //       // print("My limit: ${event.feedRequest.limit}");

  //       //If feeds page was loaded entirely
  //       if (event.feedRequest.group_id.toString().isEmpty) {
  //         final SharedPrefGroupID = await getGroupID();
  //         print("This  my shareP $SharedPrefGroupID");

  //         if (responseTopData!.data!.length > 0) {
  //           groupId = SharedPrefGroupID != null
  //               ? SharedPrefGroupID
  //               : responseTopData!.data![0].townhall_id.toString();

  //           print("This my group ID ${groupId}");

  //           //get last clicked groupid and set the is_townhall_leader to correct value
  //           // var contain = responseTopData!.data!
  //           //     .where((element) => element.townhall_id == groupId);

  //           //print("Contain: ${contain.first}");
  //           if (SharedPrefGroupID == null) {
  //             await AppSharedPreferences.setValue(
  //                 key: 'groupName',
  //                 value: responseTopData!.data![0].townhall_display_name);
  //             await AppSharedPreferences.setValue(
  //                 key: 'groupFullName',
  //                 value: responseTopData!.data![0].townhall_full_name);

  //             await AppSharedPreferences.setValue(
  //                 key: 'groupID', value: responseTopData!.data![0].townhall_id);
  //           }
  //         }
  //       } else {
  //         //if feeds was was not loaded for the first time, meaning a townhall was clicked on, more feeds or hits top.
  //         groupId = event.feedRequest.group_id;
  //         print("I was here");
  //       }
  //       print("Grp: ${groupId}");
  //       // Map<String, dynamic> map = {
  //       //   'org_id': orgID.toString(),
  //       //   'group_id': groupId,
  //       //   'post_id': event.feedRequest.post_id,
  //       //   'limit': event.feedRequest.limit,
  //       //   'last_post_id': event.feedRequest.last_post_id,
  //       //   'older_or_newer': event.feedRequest.older_or_newer,
  //       //   'page_owner': event.feedRequest.page_owner,
  //       //   'device_token': device_token.toString(),
  //       // };
  //       FeedResponse responseData = await ApiService().feed(
  //           token.toString(),
  //           orgID.toString(),
  //           groupId,
  //           event.feedRequest.page,
  //           event.feedRequest.limit,
  //           event.feedRequest.older_or_newer,
  //           event.feedRequest.page_owner,
  //           device_token.toString());
  //       print("org ${orgID} GRP ${groupId} POST ${event.feedRequest.page}");

  //       if (responseData.status == 409) {
  //         emit(UnauthorizedState()); //Unauthorized
  //       } else if (responseData.status == 200) {
  //         if (event.feedRequest.isFirstFeedRequest) {
  //           feedData = [];
  //         }
  //         if (responseData.data!.length > 0) {
  //           if (event.feedRequest.older_or_newer == "newer") {
  //             feedData.insertAll(0, responseData.data!);

  //             emit(
  //               FeedState(
  //                   feedResponse: feedData,
  //                   topFeedResponse: responseTopData!,
  //                   //inputedData: responseData.inputed_data!,
  //                   orgName: prefOrgName,
  //                   orgID: orgID,
  //                   build_number: buildNumber),
  //             );
  //           } else if (event.feedRequest.older_or_newer == "older") {
  //             feedData.addAll(responseData.data!);

  //             emit(
  //               FeedState(
  //                   feedResponse: feedData,
  //                   topFeedResponse: responseTopData!,
  //                   // inputedData: responseData.inputed_data!,
  //                   orgID: orgID,
  //                   orgName: prefOrgName,
  //                   build_number: buildNumber),
  //             );
  //           } else {
  //             feedData.clear();
  //             feedData.addAll(responseData.data!);
  //             emit(FeedState(
  //                 feedResponse: feedData,
  //                 topFeedResponse: responseTopData!,
  //                 // inputedData: responseData.inputed_data!,
  //                 orgID: orgID,
  //                 orgName: prefOrgName,
  //                 build_number: buildNumber));
  //           }
  //         } else {
  //           //feedData.clear();
  //           if (event.feedRequest.older_or_newer == "") {
  //             emit(FeedState(
  //                 feedResponse: feedData,
  //                 topFeedResponse: responseTopData!,
  //                 //inputedData: responseData.inputed_data!,
  //                 orgID: orgID,
  //                 orgName: prefOrgName,
  //                 build_number: buildNumber));
  //             feedData.clear();
  //           } else {
  //             emit(NoResultState(message: responseData.msg));
  //           }
  //         }
  //       } else {
  //         // print("error state");
  //         //emit(ErrorState(message: 'Please try again later'));
  //       }
  //     }
  //   } on SocketException catch (e) {
  //     debugPrint(e.message.toString());
  //     emit(NetworkState(message: socketException));
  //   } on FormatException catch (e) {
  //     emit(NetworkState(message: formatException));
  //   } on TimeoutException {
  //     emit(NetworkState(message: timeoutException));
  //   } catch (e) {
  //     print(e.toString());
  //     emit(NetworkState(message: unknown));
  //   }
  // }

//   Future<void> _onFeedEvent(FeedEvent event, Emitter<PostsState> emit) async {
//     try {
//       var token = await getToken();
//       var device_token = await getDeviceToken();
//       dynamic buildNumber = 0;
//       var orgName = '';

//       print("TokenX: " + token.toString());
//       if (event.feedRequest.townhall_tap == false) {
//         /*
//       Check if user is fully onboarded
//       */
//         UserOnboardedResponse onboardedResponse =
//             await ApiService().getUserOnboarded(token!);

//         buildNumber = onboardedResponse.data!.build_number;

//         if (onboardedResponse.data!.action == "not_following_user") {
//           print("Am here1");
//           emit(GoToSuggestionState(
//               status: 200, message: "successful")); //Goto suggestion route
//         } else if (onboardedResponse.data!.action == "not_following_org") {
//           print("Am here2");
//           emit(GoToOrganizationState()); //emit GoToOrganoationState
//         } else if (onboardedResponse.data!.action == "profile_incomplete") {
//           print("Am here3");
//           emit(GoToProfileState(status: 400, message: 'Go to profile'));
//         } else if (onboardedResponse.data!.action == "log_user_out") {
//           print("Am here4");
//           emit(GoToLogoutState(message: 'Go to logout'));
//         } else if (onboardedResponse.data!.action == "user_unconfirmed") {
//           print("Am here5");
//           emit(GoToConfirmState(
//               email: onboardedResponse.data!
//                   .email)); //user should be logout and taken to confirm page
//         } else {
//           await _handleOnboardingComplete(event, emit, token, device_token);
//         }
//       } else {
//         await _handleOnboardingComplete(event, emit, token, device_token);
//       }
//     } on SocketException catch (e) {
//       debugPrint(e.message.toString());
//       emit(NetworkState(message: socketException));
//     } on FormatException catch (e) {
//       emit(NetworkState(message: formatException));
//     } on TimeoutException {
//       emit(NetworkState(message: timeoutException));
//     } catch (e) {
//       print(e.toString());
//       emit(NetworkState(message: unknown));
//     }
//   }

//   Future<void> _handleOnboardingComplete(FeedEvent event,
//       Emitter<PostsState> emit, String? token, String? deviceToken) async {
//     print("Am here else");
//     //USER PASSED ALL ONBOARDING AT THIS POINT
//     var profileImage = '';
//     var orgID = await getOrg();
//     var prefOrgName = await getOrgName();

//     if (await _checkOrgInfo(token, event, orgID, prefOrgName)) {
//       //check and update share preference if org ID hasn't been set
//       print("Am 1");
//       // If user's org information is complete
//       await _getTopFeed(event, token.toString(), orgID.toString());
//       String groupId = await _getGroupId(event, orgID.toString());
//       await _getFeedData(token, orgID.toString(), groupId, event, emit,
//           prefOrgName.toString(), '', deviceToken);
//     } else {
//       print("Am 2");
//       await _getFeedData(
//           token,
//           event.orgID,
//           event.groupID,
//           event,
//           emit,
//           prefOrgName.toString(),
//           '',
//           deviceToken);

//     }
//   }

//   Future<bool> _checkOrgInfo(
//       token, FeedEvent event, String? orgID, String? orgName) async {
//     if (orgID == null || orgID == "" || orgName == null || orgName == null) {
//       LandingGroupResponse responseCompleteData =
//           await ApiService().getLandingGroup(token.toString());
//       orgID = responseCompleteData.data!.org_id;
//       var orgName = responseCompleteData.data!.org_name;

//       await AppSharedPreferences.setValue(
//           key: 'orgID', value: responseCompleteData.data!.org_id);
//       await AppSharedPreferences.setValue(
//           key: 'isLeader', value: responseCompleteData.data!.is_leader);
//       await AppSharedPreferences.setValue(
//           key: 'orgName', value: responseCompleteData.data!.org_name);

//       print(
//           "orgID: ${responseCompleteData.data!.org_id} Isleader: ${responseCompleteData.data!.is_leader}");
//       print("My orgName ${responseCompleteData.data!.org_name}");
//       return true;
//     }
//     return false;
//   }

//   Future<void> _getTopFeed(FeedEvent event, String token, String orgID) async {

//     if (event.feedRequest.skipTopFeed == false) {
//       responseTopData =
//           await ApiService().topFeed(token.toString(), orgID.toString());
//     }

//   }

//   Future<String> _getGroupId(FeedEvent event, String orgID) async {
//     String groupId = '';
//     if (event.feedRequest.group_id == "") {
//       //final sharedPrefGroupID = await getGroupID();
//       //print("sharePref ${sharedPrefGroupID}");
//       print("Am here 3 ${responseTopData!}");
//       if (responseTopData!.data!.length > 0) {
//         //print(sharedPrefGroupID.toString());

//         // groupId = sharedPrefGroupID.toString() == ""
//         //     ? responseTopData!.data![0].townhall_id.toString()
//         //     : sharedPrefGroupID.toString();
//         // final sD = await getGroupID();
//         // print("new ${sD}");
//         // if (sharedPrefGroupID == null) {
//         await AppSharedPreferences.setValue(
//             key: 'groupName',
//             value: responseTopData!.data![0].townhall_display_name);
//         await AppSharedPreferences.setValue(
//             key: 'groupFullName',
//             value: responseTopData!.data![0].townhall_full_name);
//         await AppSharedPreferences.setValue(
//             key: 'groupID', value: responseTopData!.data![0].townhall_id);
//         //}
//       }
//     } else {
//       groupId = event.groupID;
//     }
//     print("Grp: ${groupId}");
//     return groupId;
//   }

  Future<void> _getFeedData(
      String? token,
      String orgID,
      String groupId,
      FeedEvent event,
      Emitter<PostsState> emit,
      String prefOrgName,
      dynamic buildNumber,
      String? deviceToken) async {
    FeedResponse responseData = await ApiService().feed(
        token.toString(),
        orgID.toString(),
        groupId,
        event.page,
        event.limit,
        event.olderOrNewer,
        event.pageOwner,
        deviceToken.toString());
    print("org ${orgID} GRP ${groupId} POST ${event.page}");
    final tok = await getToken();
    print(tok);
    if (responseData.status == 409) {
      emit(UnauthorizedState()); //Unauthorized
    } else if (responseData.status == 200) {
      if (responseData.data!.length > 0) {
        if (event.olderOrNewer == "newer") {
          feedData.insertAll(0, responseData.data!);
          emit(
            FeedState(
                feedResponse: feedData,
                topFeedResponse: responseTopData!,
                orgName: prefOrgName,
                orgID: orgID,
                build_number: buildNumber),
          );
        } else if (event.olderOrNewer == "older") {
          feedData.addAll(responseData.data!);
          emit(
            LoadedFeedState(
                feedResponse: feedData,
                olderOrNewer: 'older',
                requestFeedLength: responseData.data!.length),
          );
        } else {
          feedData.clear();
          feedData.addAll(responseData.data!);
          emit(LoadedFeedState(
              feedResponse: feedData,
              olderOrNewer: '',
              requestFeedLength: responseData.data!.length));
        }
      } else {
        //feedData.clear();
        if (event.olderOrNewer == "") {
          emit(LoadedFeedState(
              feedResponse: [],
              olderOrNewer: '',
              requestFeedLength: responseData.data!.length));
          feedData.clear();
        } else {
          print("no result 2");
          emit(NoResultState(message: responseData.msg));
        }
      }
    } else {
      // print("error state");
      //emit(ErrorState(message: 'Please try again later'));
    }
  }

  Future<void> _onLikePostEvent(
      LikePostEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      print("PostID: " + event.post_id);
      Map<String, dynamic> map = Map();
      map["post_id"] = event.post_id.toString();
      LikeResponse responseData = await ApiService().likePost(token!, map);
      print("status  ${responseData.status} ${responseData.msg}");
      if (responseData.status == 200) {
        print("PostID result");
        emit(LikeState(like: responseData));
      } else {
        print("Error state");
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: 'like'));
      }
    } on SocketException catch (e) {
      debugPrint(e.message);
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      debugPrint(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUnLikePostEvent(
      UnLikePostEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["post_id"] = event.post_id;
      LikeResponse responseData = await ApiService().unlikePost(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(UnLikeState(unlike: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: 'unlike'));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onLikeCommentEvent(
      LikeCommentEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      print("commentID: " + event.comment_id);
      Map<String, dynamic> map = Map();
      map["comment_id"] = event.comment_id;
      LikeResponse responseData = await ApiService().likeComment(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(LikeState(like: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: 'like'));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUnLikeCommentEvent(
      UnLikeCommentEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["comment_id"] = event.comment_id;
      print(event.comment_id);
      LikeResponse responseData = await ApiService().unLikeComment(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(UnLikeState(unlike: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: 'unlike'));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(event.createCommentsRequest.toJson());

      NewCreateCommentsResponse responseData = await ApiService()
          .createComments(token!, event.createCommentsRequest.toJson());

      //print("status  ${responseData.status}");
      print(responseData.msg);
      if (responseData.status == 200) {
        emit(CreateCommentState(createCommentsResponse: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: 'comment'));
      }
    } on SocketException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      debugPrint("What: " + e.toString());
      emit(NetworkState(message: unknown));
    } finally {
      emit(CompletedState());
    }
  }

  Future<void> _onDeleteCommentEvent(
      DeleteCommentEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["comment_id"] = event.comment_id;
      map["commented_by"] = event.commented_by;
      DeleteCommentResponse responseData =
          await ApiService().deleteComment(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(DeleteCommentState(deleteCommentResponse: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onDeleteFeedEvent(
      DeleteFeedEvent event, Emitter<PostsState> emit) async {
    try {
      //emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["post_id"] = event.post_id;
      map["posted_by"] = event.posted_by;
      DeleteFeedResponse responseData =
          await ApiService().deleteFeed(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        print("Am here 1");
        emit(DeleteFeedState(deleteFeedResponse: responseData));
      } else {
        print("Am here 2");
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Am here 3");
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Am herex 4 ${e.message}");
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      print("Am here 5");
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Am here 6");
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetPostCommentsEvent(
      GetPostCommentsEvent event, Emitter<PostsState> emit) async {
    try {
      // emit(LoadingState());
      var token = await getToken();
      print(token);

      FeedResponse responseData = await ApiService().getPostComments(
        token!,
        event.postID,
        event.limit.toString(),
        event.orderBy,
        event.page.toString(),
        event.multidimensional,
      );
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.status == 400) {
          print("print 1");
          emit(NoResultState(message: 'Please try again later'));
        } else {
          print("print 2");
          emit(LoadedCommentsState(
              commentsResponse: responseData.data,
              requestFeedLength: responseData.data!.length));
        }
      } else if (responseData.data!.length == 0) {
        print("print 3");
        emit(NoResultState(message: 'No result'));
      }
    } on SocketException catch (e) {
      print("print 4");
      debugPrint(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("print 5");
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print("print 6");
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("print 7");
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetCommentEvent(
      GetCommentEvent event, Emitter<PostsState> emit) async {
    try {
      // emit(LoadingState());
      var token = await getToken();
      print(token);

      CommentsResponse responseData = await ApiService().comments(
          token!, event.post_id, event.limit.toString(), event.direction);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'Please try again later'));
        } else {
          emit(CommentsState(commentsResponse: responseData));
        }
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetPostDetailsEvent(
      GetPostDetailsEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'post_id': event.post_id,
        'the_comment_id': event.the_comment_id,
      };
      FeedDetailsResponse responseData = await ApiService().getPostDetails(
        token!,
        map,
      );
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(PostDetailsState(postResponse: responseData));
        }
      } else {
        emit(ErrorState(
            message: responseData.msg!,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetLikeDetailsEvent(
      GetLikeDetailsEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'like_id': event.like_id,
      };
      LikeDetailsResponse responseData =
          await ApiService().getLikeDetails(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(LikeDetailsState(postResponse: responseData));
        }
      } else {
        emit(ErrorState(
            message: responseData.msg!,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetNotificationsEvent(
      GetNotificationsEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);

      NotificationsResponse responseData = await ApiService()
          .notifications(token!, event.last_row_id, event.limit);
      print("status  ${responseData.status}");
      if (responseData.status == '200') {
        if (responseData.data != null) {
          print(responseData.data!.length.toString());
        }

        if (responseData.data == null) {
          emit(NoResultState(message: 'No result'));
        } else {
          AppSharedPreferences.setValue(key: 'notification_counts', value: '0');
          emit(NotificationsState(notificationsResponse: responseData));
        }
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: int.parse(responseData.status),
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print('Error: ' + e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onShowNoticeBoardEvent(
      ShowNoticeBoardEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();

      NoticeBoardResponse responseData =
          await ApiService().showNoticeBoard(token!);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(ShowNoticeBoardState(
            status: responseData.status,
            msg: responseData.msg,
            htmlMessage: responseData.data.message));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetElectionTypesEvent(
      GetElectionTypesEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      ElectionTypesResponse responseData =
          await ApiService().getElectionTypes(token!);

      if (responseData.status == 200) {
        emit(GetElectionTypesState(getElectionTypesResponse: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onFollowEvent(
      FollowEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      print(event.followee);
      FollowResponse responseData = await ApiService().follow(token!, map);
      print("status  ${responseData.status}");

      if (responseData.status == "200") {
        emit(FollowState(
            status: responseData.status.toString(), message: responseData.msg));
        print("followed");
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: int.parse(responseData.status.toString()),
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetLikesEvent(
      GetLikesEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {'post_id': event.post_id};

      LikeListResponse responseData = await ApiService().getLikes(token!, map);

      if (responseData.status == 200) {
        emit(LikeListState(likeResponse: responseData));
        print("status1  ${responseData.status}");
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: responseData.status,
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUnFollowEvent(
      UnFollowEvent event, Emitter<PostsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      FollowResponse responseData = await ApiService().unfollow(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == "200") {
        emit(UnFollowState(follow: responseData));
      } else {
        emit(ErrorState(
            message: responseData.msg,
            status: int.parse(responseData.status.toString()),
            errorFor: ''));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }

    void updateProgress(double progress) {
      _progressController.sink.add(progress);
    }

    void dispose() {
      _progressController.close();
    }
  }

  Future<String?> getToken() async {
    return await AppSharedPreferences.getValue(key: 'token');
  }

  Future<String?> getTownhallView() async {
    return await AppSharedPreferences.getValue(key: 'townhallView');
  }

  Future<String?> getGroupID() async {
    return await AppSharedPreferences.getValue(key: 'groupID');
  }

  Future<String?> getOrg() async {
    return await AppSharedPreferences.getValue(key: 'orgID');
  }

  Future<String?> getOrgName() async {
    return await AppSharedPreferences.getValue(key: 'orgName');
  }

  void clearCache() async {
    // await AppSharedPreferences.removeValue(key: 'token');
    // await AppSharedPreferences.removeValue(key: 'townhallView');
    // await AppSharedPreferences.removeValue(key: 'groupID');
    // await AppSharedPreferences.removeValue(key: 'orgID');
    // await AppSharedPreferences.removeValue(key: 'orgName');
    // await AppSharedPreferences.removeValue(key: 'isLeader');
    // await AppSharedPreferences.removeValue(key: 'login');
    // await AppSharedPreferences.removeValue(key: 'page_message');
    // await AppSharedPreferences.removeValue(key: 'page_notification');
    // await AppSharedPreferences.removeValue(key: 'page_chat');
    // await AppSharedPreferences.removeValue(key: 'page_event');
    // await AppSharedPreferences.removeValue(key: 'page_organization');
    // await AppSharedPreferences.removeValue(key: 'page_search_people');
    // await AppSharedPreferences.removeValue(key: 'page_search_organization');

    // var dismissedVersion = await _getDismissedVersion();
    var deviceToken = await getDeviceToken();
    await AppSharedPreferences.clearCache();
    // AppSharedPreferences.setValue(
    //     key: 'dismissedVersion', value: dismissedVersion.toString());
    await AppSharedPreferences.setValue(
        key: 'deviceToken', value: deviceToken.toString());
    print("Clear cache was called");
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }

  Future<bool> _userExist(userID) async {
    bool exists = await checkIfDocumentExists(userID);
    if (exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfDocumentExists(String docId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();
      return documentSnapshot.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _createFirestoreUser(
      String docId, Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .set(userData);
      print('User created with ID: $docId');
    } catch (e) {
      print('Error creating user: $e');
    }
  }
}
