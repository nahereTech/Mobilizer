part of 'polling_bloc.dart';

@immutable
abstract class PollingState {}

class PollingInitial extends PollingState {}

class PollingLoadingState extends PollingState {
  @override
  List<Object?> get props => [];
}

class NetworkState extends PollingState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class SearchLoadingState extends PollingState {
  @override
  List<Object?> get props => [];
}

class NoReturnState extends PollingState {
  final String? message;

  NoReturnState({this.message});

  @override
  List<Object> get props => [];
}

class PollingErrorState extends PollingState {
  final int? status;
  final String? message;

  PollingErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class GetPollingState extends PollingState {
  final SearchPollingUnitResponse getPollingResponse;

  GetPollingState({required this.getPollingResponse});
  @override
  List<Object?> get props => [getPollingResponse];
}

class JoinState extends PollingState {
  final int? status;
  final String? message;
  JoinState({this.status, this.message});

  @override
  List<Object?> get props => [];
}

// class LeaveState extends PollingState {
//   final int? status;
//   final String? message;
//   LeaveState({this.status, this.message});

//   @override
//   List<Object?> get props => [];
// }
