import 'package:get_it/get_it.dart';
import 'bloc/search/organization_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/posts/posts_bloc.dart';
import 'bloc/search/people_bloc.dart';
import 'bloc/suggestion/suggestion_bloc.dart';
import 'bloc/events/events_bloc.dart';
import 'bloc/messages/messages_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerFactory(() => AuthBloc());
  getIt.registerFactory(() => PostsBloc());
  getIt.registerFactory(() => SuggestionBloc());
  getIt.registerFactory(() => PeopleBloc());
  getIt.registerFactory(() => OrganizationBloc());
  getIt.registerFactory(() => EventsBloc());
  getIt.registerFactory(() => MessagesBloc());
}
