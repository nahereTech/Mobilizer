part of 'polling_bloc.dart';

@immutable
abstract class PollingEvent {
  const PollingEvent();
}

class GetPollingEvent extends PollingEvent {
  final String ward_id;
  GetPollingEvent({required this.ward_id});
  @override
  List<Object> get props => [ward_id];
}

class JoinEvent extends PollingEvent {
  final String pu_id;

  JoinEvent({required this.pu_id});

  @override
  List<Object> get props => [pu_id];
}
