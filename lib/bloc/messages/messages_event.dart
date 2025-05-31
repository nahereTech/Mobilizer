part of 'messages_bloc.dart';

@immutable
abstract class MessagesEvent {}

class GetInboxMessages extends MessagesEvent {
  final String keyword;
  final String message_category;
  GetInboxMessages({required this.keyword, required this.message_category});
  @override
  List<Object> get props => [keyword, message_category];
}

class GetChatHistory extends MessagesEvent {
  final String co_chatter;
  final String direction;
  final String last_shown_id;
  final int limit;
  GetChatHistory(
      {required this.co_chatter,
      required this.direction,
      required this.last_shown_id,
      required this.limit});
  @override
  List<Object> get props => [co_chatter, direction, last_shown_id, limit];
}

class GetBulbNotifications extends MessagesEvent {
  @override
  List<Object> get props => [];
}

class DeleteMessageEvent extends MessagesEvent {
  final String messageID;
  DeleteMessageEvent({required this.messageID});
  List<Object> get props => [messageID];
}

class DeleteChatHistoryEvent extends MessagesEvent {
  final String coChatter;
  DeleteChatHistoryEvent({required this.coChatter});
  List<Object> get props => [coChatter];
}

class PostChatEvent extends MessagesEvent {
  final Map<String, dynamic> createPostRequest;

  PostChatEvent({required this.createPostRequest});

  @override
  List<Object> get props => [createPostRequest];
}
