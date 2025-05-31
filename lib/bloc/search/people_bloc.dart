import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
// import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/Follow/follow_response.dart';
import 'package:mobilizer/models/Follow/followees_response.dart';
import 'package:mobilizer/models/Follow/followers_response.dart';
import 'package:mobilizer/models/Follow/verify_following_response.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/profile/block_user_response.dart';

import 'package:mobilizer/models/profile/get_subject_profile_response.dart';

import 'package:mobilizer/models/social/followers_count_response.dart';
import 'package:mobilizer/models/social/following_count_response.dart';
import 'package:mobilizer/models/search/search_people_response.dart';
import 'package:mobilizer/services/api_service.dart';

part 'people_event.dart';
part 'people_state.dart';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  PeopleBloc() : super(PeopleInitial()) {
    on<GetPeopleEvent>(_onGetPeopleEvent);
    on<FollowEvent>(_onFollowEvent);
    on<UnFollowEvent>(_onUnFollowEvent);
    on<GetPeoplePostsEvent>(_onGetPeoplePostsEvent);
    on<BlockUserEvent>(_onBlockUserEvent);
    on<GetFolloweesEvent>(_onGetFolloweesEvent);
    on<GetFollowersEvent>(_onGetFollowersEvent);
  }
  // List<SearchPeopleResponseData> people = [];

  Future<void> _onGetPeopleEvent(
      GetPeopleEvent event, Emitter<PeopleState> emit) async {
    try {
      emit(PeopleLoadingState());
      var token = await getToken();
      //print(token);

      SearchPeopleResponse responseData =
          await ApiService().getPeople(token!, event.term);

      if (responseData.status == 200) {
        // if (responseData.data == null) {
        //   emit(NoReturnState(message: 'No Result'));
        //   print('No Result');
        // } else {
        emit(GetPeopleState(getPeopleResponse: responseData));
        print('Result Found');
        //}
      } else if (responseData.status == 400) {
        print("400");
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        print("401");
        emit(NoReturnState(message: responseData.msg));
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

  Future<void> _onBlockUserEvent(
      BlockUserEvent event, Emitter<PeopleState> emit) async {
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
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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

  Future<void> _onFollowEvent(
      FollowEvent event, Emitter<PeopleState> emit) async {
    try {
      emit(PeopleLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      print(event.followee);
      FollowResponse responseData = await ApiService().follow(token!, map);
      print("statusRR  ${responseData.status}");

      if (responseData.status.toString() == "200") {
        emit(FollowState(
            status: responseData.status.toString(), message: responseData.msg));
        print("followed");
      } else {
        print("RRRR");
        emit(PeopleErrorState(message: responseData.msg));
      }
    } on SocketException catch (e) {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.toString());
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUnFollowEvent(
      UnFollowEvent event, Emitter<PeopleState> emit) async {
    try {
      emit(PeopleLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      FollowResponse responseData = await ApiService().unfollow(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status.toString() == "200") {
        emit(UnFollowState(follow: responseData));
      } else {
        emit(PeopleErrorState(message: responseData.msg));
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

  Future<void> _onGetPeoplePostsEvent(
      GetPeoplePostsEvent event, Emitter<PeopleState> emit) async {
    try {
      emit(PeopleLoadingState());
      var token = await getToken();
      var device_token = await getDeviceToken();
      var orgID = await getOrg();
      //print(token);
      String userID = event.clickedUserID;

      print("UserID: ${userID}");
      GetSubjectProfileResponse responseData =
          await ApiService().getSubjectProfile(token!, userID);
      //print(responseData);
      if (responseData.status == 200) {
        // Map<String, dynamic> map = Map();
        // map["clicked_user_id"] = event.clickedUserID;
        // FollowingResponseCount totalFollowingResponseData =
        //     await ApiService().counts(token, event.clickedUserID);

        // FollowersResponseCount totalFollowersResponseData =
        //     await ApiService().total(token, event.clickedUserID);
        // GetVerifyFollowingResponse followingResponseData =
        //     await ApiService().verifyFollowing(token, map);

        print("ORG ID: ${orgID.toString()} clicked: ${event.clickedUserID} ");
        FeedResponse feedResponseData = await ApiService().feed(token, '', 0, 1,
            50, '', event.clickedUserID, device_token.toString());

        emit(GetPeoplePostsState(
          profileResponse: responseData,
          //feedResponse: feedResponseData,
          // followingResponse: followingResponseData,
          // totalFollowers: totalFollowersResponseData,
          // totalFollowing: totalFollowingResponseData,
        ));
      } else {
        emit(PeopleErrorState(message: responseData.msg));
      }
    } on SocketException catch (e) {
      print("Err1: Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint("Err2: ${e.source}");
      emit(NetworkState(message: e.source));
    } on TimeoutException catch (e) {
      print("Err3: ${e.message}");
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("Err4: ${e.toString()}");
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetFolloweesEvent(
      GetFolloweesEvent event, Emitter<PeopleState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'subjects_id': event.subjectID,
        'limit': event.limit,
        'page': event.page,
      };
      FolloweesResponse responseData =
          await ApiService().getFollowees(token!, map);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        emit(GetFolloweesState(getFolloweesResponse: responseData));
      } else {
        emit(ErrorState(message: responseData.msg));
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

  Future<void> _onGetFollowersEvent(
      GetFollowersEvent event, Emitter<PeopleState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'subjects_id': event.subjectID,
        'limit': event.limit,
        'page': event.page,
      };
      FollowersResponse responseData =
          await ApiService().getFollowers(token!, map);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        emit(GetFollowersState(getFollowersResponse: responseData));
      } else {
        emit(ErrorState(message: responseData.msg));
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

  Future<String?> getToken() async {
    return await AppSharedPreferences.getValue(key: 'token');
  }

  Future<String?> getOrg() async {
    return await AppSharedPreferences.getValue(key: 'orgID');
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }
}
