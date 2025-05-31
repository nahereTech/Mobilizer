import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/organization/organization_interest_response.dart';
import 'package:mobilizer/models/organization/organization_response.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:mobilizer/models/search/leave_organization_response.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';

import 'package:mobilizer/models/suggestion/suggestion_response.dart';
import 'package:mobilizer/services/api_service.dart';

import '../../models/Follow/follow_response.dart';

part 'suggestion_event.dart';
part 'suggestion_state.dart';

class SuggestionBloc extends Bloc<SuggestionEvent, SuggestionState> {
  SuggestionBloc() : super(SuggestionInitial()) {
    on<GetSuggestionEvent>(_onGetSuggestionEvent);
    on<GetInterestEvent>(_onGetInterestEvent);
    on<SearchOrganizationEvent>(_onSearchOrganizationEvent);
    on<FollowEvent>(_onFollowEvent);
    on<UnFollowEvent>(_onUnFollowEvent);
    on<GetOrganizationEvent>(_onGetOrganizationEvent);

    on<JoinEvent>(_onJoinEvent);
    on<LeaveEvent>(_onLeaveEvent);
  }
  Future<void> _onGetSuggestionEvent(
      GetSuggestionEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      //print(token);
      Map<String, dynamic> map = {'limit': 50};
      SuggestionResponse responseData =
          await ApiService().getSuggestion(token!, map);
      if (responseData.status == 200) {
        emit(GetSuggestionState(getSuggestionResponse: responseData));
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

  Future<void> _onGetInterestEvent(
      GetInterestEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      //print(token);
      OrganizationInterestResponse responseData =
          await ApiService().getInterest(token!);
      if (responseData.status == 200) {
        emit(GetInterestState(getInterestResponse: responseData));
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

  Future<void> _onSearchOrganizationEvent(
      SearchOrganizationEvent event, Emitter<SuggestionState> emit) async {
    try {
      //emit(OrganizationLoadingState());
      var token = await getToken();
      //print(token);

      SearchOrganizationResponse responseData = await ApiService()
          .getOrganizationSearch(token!, event.term, event.interest_id);

      if (responseData.status == 200) {
        if (responseData.data!.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(SearchOrganizationState(
              searchOrganizationResponse: responseData));
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else if (responseData.status == 401) {
        emit(NoReturnState(message: responseData.msg));
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

  Future<void> _onJoinEvent(
      JoinEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      JoinOrganizationResponse responseData =
          await ApiService().joinOrganization(token!, map);

      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(JoinState(status: responseData.status, message: responseData.msg));
        print("joined");
      } else if (responseData.status == 400) {
        emit(AlreadyMemberState(message: responseData.msg));
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

  Future<void> _onLeaveEvent(
      LeaveEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      LeaveOrganizationResponse responseData =
          await ApiService().leaveOrganization(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(
            LeaveState(status: responseData.status, message: responseData.msg));
        print("left");
      } else if (responseData.status == 400) {
        emit(AlreadyMemberState(message: responseData.msg));
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

  Future<void> _onGetOrganizationEvent(
      GetOrganizationEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      //print(token);
      OrganizationResponse responseData =
          await ApiService().getOrganizationSuggestion(token!);

      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(GetOrganizationState(getOrganizationResponse: responseData));
          print('Result Found');
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
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

  Future<void> _onFollowEvent(
      FollowEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      FollowResponse responseData = await ApiService().follow(token!, map);
      if (responseData.status == "200") {
        emit(FollowState(follow: responseData));
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

  Future<void> _onUnFollowEvent(
      UnFollowEvent event, Emitter<SuggestionState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["followee"] = event.followee;
      FollowResponse responseData = await ApiService().unfollow(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == "200") {
        emit(UnFollowState(follow: responseData));
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

//
  Future<String?> getToken() async {
    return await AppSharedPreferences.getValue(key: 'token');
  }
}
