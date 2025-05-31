part of 'messages_bloc.dart';

@immutable
abstract class MessagesState {}

class MessageInitial extends MessagesState {}

class LoadingState extends MessagesState {
  @override
  List<Object?> get props => [];
}

class NetworkState extends MessagesState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [message!];
}

class ErrorState extends MessagesState {
  final int status;
  final String message;

  ErrorState({required this.status, required this.message});

  @override
  List<Object> get props => [status, message];
}

class NoResultState extends MessagesState {
  final String message;
  NoResultState({required this.message});
  @override
  List<Object> get props => [message];
}

class MessageListState extends MessagesState {
  final MessagesResponse messageResponse;

  MessageListState({required this.messageResponse});

  @override
  List<Object> get props => [messageResponse];
}

class BulbState extends MessagesState {
  final BulbNotificationsResponse bulbResponse;

  BulbState({required this.bulbResponse});

  @override
  List<Object> get props => [bulbResponse];
}

class ChatListState extends MessagesState {
  //final ChatHistoryResponse chatResponse;
 List <dynamic> chatResponse;
  ChatListState({required this.chatResponse});

  @override
  List<Object> get props => [chatResponse];
}

class PostChatState extends MessagesState {
  final PostChatResponse chatResponse;

  PostChatState({required this.chatResponse});

  @override
  List<Object> get props => [chatResponse];
}

class DeleteState extends MessagesState {
  final String status;
  final String message;
  DeleteState({required this.status, required this.message});
  @override
  List<Object> get props => [status, message];
}

class DeleteConversationState extends MessagesState {
  final String status;
  final String message;
  DeleteConversationState({required this.status, required this.message});
  @override
  List<Object> get props => [status, message];
}
// class CreateEventState extends MessageState {
//   final CreateEventResponse createEventResponse;
//   CreateEventState({required this.createEventResponse});

//   @override
//   List<Object?> get props => [createEventResponse];
// }