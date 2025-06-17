import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/events/event_create_response.dart';
import 'package:mobilizer/models/events/event_delete_response.dart';
import 'package:mobilizer/models/events/event_types_response.dart';
import 'package:mobilizer/models/events/events_response.dart';
import 'package:mobilizer/models/townhall/townhalls_user_is_leader_in_response.dart';
import 'package:equatable/equatable.dart';
import 'package:mobilizer/services/api_service.dart';
part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsInitial()) {
    on<GetEventsEvent>(_onGetEventsEvent);
    on<GetEventTypesEvent>(_onGetEventTypesEvent);
    on<CreateEventEvent>(_onCreateEventEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<GetTownhallsUserIsLeaderInEvent>(_onGetTownhallsUserIsLeaderInEvent);
  }
  Future<void> _onDeleteEvent(
      DeleteEvent event, Emitter<EventsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["event_id"] = event.eventID;
      print("EventID: ${event.eventID}");
      EventDeleteResponse responseData =
          await ApiService().deleteEvent(token!, map);

      if (responseData.status == 200) {
        emit(DeleteEventState(
            message: responseData.msg, status: responseData.status.toString()));
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

  Future<void> _onCreateEventEvent(
      CreateEventEvent event, Emitter<EventsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);

      CreateEventResponse responseData =
          await ApiService().createEvent(token!, event.createEventRequest);
      print(event.createEventRequest);
      if (responseData.status == 200) {
        print(responseData.data!.event_id);
        emit(CreateEventState(createEventResponse: responseData));
      } else {
        emit(ErrorState(message: responseData.msg));
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
      debugPrint("Catch message: " + e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetEventsEvent(
      GetEventsEvent event, Emitter<EventsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      EventsResponse responseData =
          await ApiService().getEvents(token!, event.page, event.limit);

      if (responseData.status == 200) {
        if (responseData.data != null) {
          AppSharedPreferences.setValue(key: 'event_counts', value: '0');
          emit(EventListState(eventsResponse: responseData));
        } else {
          emit(ErrorState(message: responseData.msg));
        }
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

  Future<void> _onGetTownhallsUserIsLeaderInEvent(
      GetTownhallsUserIsLeaderInEvent event, Emitter<EventsState> emit) async {
    try {
      var token = await getToken();
      print(token);
      TownhallsLeaderIsResponse responseData =
          await ApiService().getTownhallsUserIsLeaderIn(token!);

      if (responseData.status == 200) {
        if (responseData.data != null) {
          emit(GetTownhallsUserIsLeaderInState(
              townhallList: responseData, status: true));
          print("Townhall: " + responseData.data[0].org_name);
        } else {
          emit(ErrorState(message: responseData.msg));
        }
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

  Future<void> _onGetEventTypesEvent(
      GetEventTypesEvent event, Emitter<EventsState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      EventTypesResponse responseData =
          await ApiService().getEventTypes(token!);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(EventTypesState(typeResponse: responseData));
        }
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
