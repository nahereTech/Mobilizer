import 'dart:async';
//import 'dart:html';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/messages/bulb_notifications_response.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart' as chat;
import 'package:mobilizer/models/messages/delete_chat_history_response.dart';
import 'package:mobilizer/models/messages/delete_message_response.dart';
import 'package:mobilizer/models/messages/messages_response.dart';
import 'package:mobilizer/models/messages/post_chat_response.dart';
import 'package:mobilizer/models/messages/bulb_notifications_response.dart';
import 'package:equatable/equatable.dart';
import 'package:mobilizer/services/api_service.dart';
part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessageInitial()) {
    on<GetInboxMessages>(_onGetInboxMessages);
    on<GetChatHistory>(_onGetChatHistory);
    on<PostChatEvent>(_onPostChatEvent);
    on<DeleteMessageEvent>(_onDeleteMessageEvent);
    on<DeleteChatHistoryEvent>(_onDeleteChatHistoryEvent);
    on<GetBulbNotifications>(_onGetBulbNotifications);
  }
  List<chat.ChatData> chatData = [];
  int append = 0;
  Future<void> _onPostChatEvent(
      PostChatEvent event, Emitter<MessagesState> emit) async {
    try {
      var token = await getToken();
      print(token);

      PostChatResponse responseData =
          await ApiService().postChat(token!, event.createPostRequest);
      print("Is a posting as a leader: ${event.createPostRequest}");
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(PostChatState(chatResponse: responseData));
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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

  Future<void> _onGetInboxMessages(
      GetInboxMessages event, Emitter<MessagesState> emit) async {
    try {
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'keyword': event.keyword,
        'message_category': event.message_category
      };
      MessagesResponse responseData =
          await ApiService().getInboxMessages(token!, map);

      if (responseData.status == 200) {
        if (responseData.data != null && responseData.data.length > 0) {
          print(responseData.data.length);
          AppSharedPreferences.setValue(key: 'message_counts', value: '0');
          emit(MessageListState(messageResponse: responseData));
        } else {
          emit(NoResultState(message: "No result found"));
        }
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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

  Future<void> _onGetChatHistory(
      GetChatHistory event, Emitter<MessagesState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = {
        'co_chatter': event.co_chatter,
        'direction': event.direction,
        'last_shown_id': event.last_shown_id,
        'limit': event.last_shown_id
      };
      chat.ChatHistoryResponse responseData =
          await ApiService().getChatHistories(token!, map);

      if (responseData.status == 200) {
        if (responseData.data.length > 0) {
          if (chatData.length > 0) {
            chatData.insertAll(chatData.length, responseData.data);
          } else {
            chatData.clear();
            chatData.addAll(responseData.data);
          }
          emit(ChatListState(chatResponse: chatData));
        } else {
          emit(NoResultState(message: "No result found"));
        }
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
        print("Error exist");
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

  Future<void> _onGetBulbNotifications(
      GetBulbNotifications event, Emitter<MessagesState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      BulbNotificationsResponse responseData =
          await ApiService().getbulbNotifications(token!);

      if (responseData.status == 200) {
        await AppSharedPreferences.setValue(
            key: 'message_counts',
            value: responseData.data!.messages.toString());
        await AppSharedPreferences.setValue(
            key: 'event_counts', value: responseData.data!.events.toString());
        await AppSharedPreferences.setValue(
            key: 'notification_counts',
            value: responseData.data!.notifications.toString());

        emit(BulbState(bulbResponse: responseData));
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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

  Future<void> _onDeleteMessageEvent(
      DeleteMessageEvent event, Emitter<MessagesState> emit) async {
    try {
      var token = await getToken();
      Map<String, dynamic> map = Map();
      map["message_id"] = event.messageID;
      DeleteMessageResponse responseData =
          await ApiService().deleteMessage(token!, map);

      if (responseData.status == 200) {
        emit(DeleteState(
            message: responseData.msg, status: responseData.status.toString()));
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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

  Future<void> _onDeleteChatHistoryEvent(
      DeleteChatHistoryEvent event, Emitter<MessagesState> emit) async {
    try {
      var token = await getToken();
      Map<String, dynamic> map = Map();
      map["co_chatter"] = event.coChatter;
      DeleteChatHistoryResponse responseData =
          await ApiService().deleteChatHistory(token!, map);

      if (responseData.status == 200) {
        emit(DeleteState(
            message: responseData.msg, status: responseData.status.toString()));
      } else {
        emit(
            ErrorState(status: responseData.status, message: responseData.msg));
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
