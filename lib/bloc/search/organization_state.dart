part of 'organization_bloc.dart';

@immutable
abstract class OrganizationState {}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoadingState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class NetworkState extends OrganizationState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object?> get props => [message];
}

class PlanNetworkState extends OrganizationState {
  final String? message;
  PlanNetworkState({this.message});
  @override
  List<Object?> get props => [message];
}

class SearchLoadingState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class NoReturnState extends OrganizationState {
  final String? message;

  NoReturnState({this.message});

  @override
  List<Object?> get props => [message];
}

class OrganizationErrorState extends OrganizationState {
  final int? status;
  final String? message;

  OrganizationErrorState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class DuplicateErrorState extends OrganizationState {
  final int? status;
  final String? message;

  DuplicateErrorState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class PlanErrorState extends OrganizationState {
  final int? status;
  final String? message;

  PlanErrorState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class NoOrganizationState extends OrganizationState {
  final int? status;
  final String? message;

  NoOrganizationState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class GetOrganizationState extends OrganizationState {
  final OrganizationResponse getOrganizationResponse;

  GetOrganizationState({required this.getOrganizationResponse});
  @override
  List<Object?> get props => [getOrganizationResponse];
}

class GetOrganizationPlanState extends OrganizationState {
  final OrganizationPlanResponse getOrganizationPlanResponse;

  GetOrganizationPlanState({required this.getOrganizationPlanResponse});
  @override
  List<Object?> get props => [getOrganizationPlanResponse];
}

class GetOrganizationTreeState extends OrganizationState {
  final OrganizationTreeResponse getOrganizationTreeResponse;

  GetOrganizationTreeState({required this.getOrganizationTreeResponse});
  @override
  List<Object?> get props => [getOrganizationTreeResponse];
}

class MyOrganizationsState extends OrganizationState {
  final MyOrganizationResponse getOrganizationsResponse;

  MyOrganizationsState({required this.getOrganizationsResponse});
  @override
  List<Object?> get props => [getOrganizationsResponse];
}

class CreateOrganizationState extends OrganizationState {
  final CreateOrganizationResponse createOrganizationResponse;

  CreateOrganizationState({required this.createOrganizationResponse});

  @override
  List<Object?> get props => [createOrganizationResponse];
}

class UpdateOrganizationState extends OrganizationState {
  final UpdateOrganizationResponse updateOrganizationResponse;

  UpdateOrganizationState({required this.updateOrganizationResponse});

  @override
  List<Object?> get props => [updateOrganizationResponse];
}

class DeleteOrganizationState extends OrganizationState {
  final int? status;
  final String? message;

  DeleteOrganizationState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class SearchOrganizationState extends OrganizationState {
  final SearchOrganizationResponse searchOrganizationResponse;

  SearchOrganizationState({required this.searchOrganizationResponse});
  @override
  List<Object?> get props => [searchOrganizationResponse];
}

class JoinState extends OrganizationState {
  final int? status;
  final String? message;
  JoinState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class ShowBottomSheetState extends OrganizationState {
  final List<DropData> getDropDownList;
  final String tag;
  ShowBottomSheetState({required this.tag, required this.getDropDownList});

  @override
  List<Object?> get props => [tag, getDropDownList];
}

class LeaveState extends OrganizationState {
  final int? status;
  final String? message;
  LeaveState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class UpdateOrgBannerState extends OrganizationState {
  final int? status;
  final String? message;
  final String? image;
  UpdateOrgBannerState({this.status, this.message, this.image});

  @override
  List<Object?> get props => [status, message, image];
}

class UpdateOrgLogoState extends OrganizationState {
  final int? status;
  final String? message;
  final String? image;
  UpdateOrgLogoState({this.status, this.message, this.image});

  @override
  List<Object?> get props => [status, message, image];
}

class AlreadyMemberState extends OrganizationState {
  final String? message;

  AlreadyMemberState({this.message});

  @override
  List<Object?> get props => [message];
}

class PinState extends OrganizationState {
  final int? status;
  final String? message;
  PinState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class VerifyPasswordState extends OrganizationState {
  final int? status;
  final String? message;
  VerifyPasswordState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class UnpinState extends OrganizationState {
  final int? status;
  final String? message;
  UnpinState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class GetInterestState extends OrganizationState {
  final OrganizationInterestResponse getInterestResponse;

  GetInterestState({required this.getInterestResponse});
  @override
  List<Object?> get props => [getInterestResponse];
}

class ErrorState extends OrganizationState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class DefaultAvailableTWHState extends OrganizationState {
  final DefaultAvailableTWHResponse defaultAvailableTWHResponse;

  DefaultAvailableTWHState({required this.defaultAvailableTWHResponse});
  @override
  List<Object?> get props => [defaultAvailableTWHResponse];
}

class DefaultPostableTWHState extends OrganizationState {
  final DefaultPostableTWHResponse defaultPostableTWHResponse;

  DefaultPostableTWHState({required this.defaultPostableTWHResponse});
  @override
  List<Object?> get props => [defaultPostableTWHResponse];
}

class GetCustomOrganizationIDState extends OrganizationState {
  final CreateCustomOrganizationTempResponse customOrganizationIDResponse;

  GetCustomOrganizationIDState({required this.customOrganizationIDResponse});
  @override
  List<Object?> get props => [customOrganizationIDResponse];
}

class ErrorCustomOrganizationIDState extends OrganizationState {
  final int? status;
  final String? message;

  ErrorCustomOrganizationIDState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class CreateCustomTownhallState extends OrganizationState {
  final CreateCustomOrganizationChildResponse createCustomTownhallResponse;

  CreateCustomTownhallState({required this.createCustomTownhallResponse});
  @override
  List<Object?> get props => [createCustomTownhallResponse];
}

class RenameCustomTownhallState extends OrganizationState {
  final RenameCustomOrganizationResponse renameCustomTownhallResponse;

  RenameCustomTownhallState({required this.renameCustomTownhallResponse});
  @override
  List<Object?> get props => [renameCustomTownhallResponse];
}

class DeleteCustomTownhallState extends OrganizationState {
  final DeleteCustomOrganizationResponse deleteCustomTownhallResponse;

  DeleteCustomTownhallState({required this.deleteCustomTownhallResponse});
  @override
  List<Object?> get props => [deleteCustomTownhallResponse];
}

class AddCustomTownhallLoadingState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class RenameCustomTownhallLoadingState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class DeleteCustomTownhallLoadingState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class CCFState extends OrganizationState {
  final OrganizationCCFResponse CCFResponse;

  CCFState({required this.CCFResponse});
  @override
  List<Object?> get props => [CCFResponse];
}

class NoCCFState extends OrganizationState {
  @override
  List<Object?> get props => [];
}

class UpdateUsersTownhallsState extends OrganizationState {
  final int? status;
  final String? message;

  UpdateUsersTownhallsState({this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}
