import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';

import 'package:mobilizer/models/social/followee_response.dart';
import 'package:mobilizer/models/suggestion/suggestion_response.dart';
import 'package:mobilizer/services/api_service.dart';

part 'social_event.dart';
part 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  SocialBloc() : super(SocialInitial()) {
    on<GetFolloweeEvent>(_onGetFolloweeEvent);
    on<GetSuggestionEvent>(_onGetSuggestionEvent);
  }

  Future<void> _onGetFolloweeEvent(
      GetFolloweeEvent event, Emitter<SocialState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      FolloweeResponse responseData = await ApiService().getFollowee(token!);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        emit(GetFolloweeState(getFolloweeResponse: responseData));
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

  Future<void> _onGetSuggestionEvent(
      GetSuggestionEvent event, Emitter<SocialState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {'limit': 50};
      SuggestionResponse responseData =
          await ApiService().getSuggestion(token!, map);
      print("status ${responseData.status}");
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

  Future<String?> getToken() async {
    return await AppSharedPreferences.getValue(key: 'token');
  }
}
