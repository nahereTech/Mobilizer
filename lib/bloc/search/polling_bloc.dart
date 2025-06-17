import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';

import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/models/search/join_polling_unit_response.dart';
import 'package:mobilizer/services/api_service.dart';

part 'polling_event.dart';
part 'polling_state.dart';

class PollingBloc extends Bloc<PollingEvent, PollingState> {
  PollingBloc() : super(PollingInitial()) {
    on<GetPollingEvent>(_onGetPollingEvent);
    on<JoinEvent>(_onJoinEvent);
  }
  Future<void> _onGetPollingEvent(
      GetPollingEvent event, Emitter<PollingState> emit) async {
    try {
      emit(PollingLoadingState());
      var token = await getToken();
      //print(token);
      Map<String, dynamic> map = {'ward_id': event.ward_id};
      SearchPollingUnitResponse responseData =
          await ApiService().getPollingUnites(token!, int.parse(event.ward_id));
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(GetPollingState(getPollingResponse: responseData));
          print('Result Found');
        }
      } else {
        emit(PollingErrorState(message: responseData.message));
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

  Future<void> _onJoinEvent(JoinEvent event, Emitter<PollingState> emit) async {
    try {
      emit(PollingLoadingState());
      var token = await getToken();
      print(token);

      Map<String, dynamic> map = Map();
      map["pu_id"] = event.pu_id;

      JoinPollingUnitResponse responseData =
          await ApiService().addPolling(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(JoinState(message: responseData.msg, status: responseData.status));
        print("joined");
      } else {
        emit(PollingErrorState(message: responseData.msg));
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
