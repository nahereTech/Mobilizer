part of 'organization_bloc.dart';

@immutable
abstract class OrganizationEvent {
  const OrganizationEvent();
}

class CreateOrganizationEvent extends OrganizationEvent {
  final Map<String, dynamic> createOrganizationRequest;
  CreateOrganizationEvent({required this.createOrganizationRequest});

  @override
  List<Object> get props => [createOrganizationRequest];
}

class UpdateOrganizationEvent extends OrganizationEvent {
  final Map<String, dynamic> updateOrganizationRequest;
  UpdateOrganizationEvent({required this.updateOrganizationRequest});

  @override
  List<Object> get props => [updateOrganizationRequest];
}

class GetOrganizationEvent extends OrganizationEvent {
  //final String term;
  GetOrganizationEvent();
  @override
  List<Object> get props => [];
}

class GetOrganizationPlanEvent extends OrganizationEvent {
  GetOrganizationPlanEvent();
  @override
  List<Object> get props => [];
}

class MyOrganizationsEvent extends OrganizationEvent {
  //Get list of Organizations i created
  MyOrganizationsEvent();
  @override
  List<Object> get props => [];
}

class SearchOrganizationEvent extends OrganizationEvent {
  final String term;
  final String interest_id;
  SearchOrganizationEvent({required this.term, required this.interest_id});
  @override
  List<Object> get props => [term, interest_id];
}

class GetOrganizationTreeEvent extends OrganizationEvent {
  final String tree;
  final String org_id;
  GetOrganizationTreeEvent({required this.tree, required this.org_id});
  @override
  List<Object> get props => [tree, org_id];
}

class JoinEvent extends OrganizationEvent {
  final String org_id;

  JoinEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class LeaveEvent extends OrganizationEvent {
  final String org_id;

  LeaveEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class DeleteEvent extends OrganizationEvent {
  final String org_id;

  DeleteEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class UpdateOrgBannerEvent extends OrganizationEvent {
  final String org_id;
  final String pic;

  UpdateOrgBannerEvent({required this.org_id, required this.pic});

  @override
  List<Object> get props => [org_id, pic];
}

class UpdateOrgLogoEvent extends OrganizationEvent {
  final String org_id;
  final String pic;

  UpdateOrgLogoEvent({required this.org_id, required this.pic});

  @override
  List<Object> get props => [org_id, pic];
}

class VerifyPasswordEvent extends OrganizationEvent {
  final String password;
  VerifyPasswordEvent({required this.password});
  @override
  List<Object> get props => [password];
}

class PinToTopEvent extends OrganizationEvent {
  final String org_id;

  PinToTopEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class UnpinFromTopEvent extends OrganizationEvent {
  final String org_id;

  UnpinFromTopEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class GetInterestEvent extends OrganizationEvent {
  //final String term;
  GetInterestEvent();
  @override
  List<Object> get props => [];
}

class DefaultAvailableTWHEvent extends OrganizationEvent {
  DefaultAvailableTWHEvent();
  @override
  List<Object> get props => [];
}

class DefaultPostableTWHEvent extends OrganizationEvent {
  DefaultPostableTWHEvent();
  @override
  List<Object> get props => [];
}

class GetCustomOrganizationIDEvent extends OrganizationEvent {
  final Map<String, dynamic> customOrganizationIDRequest;
  GetCustomOrganizationIDEvent({required this.customOrganizationIDRequest});
  @override
  List<Object> get props => [customOrganizationIDRequest];
}

class CreateCustomTownhallEvent extends OrganizationEvent {
  final Map<String, dynamic> createCustomTownhallRequest;
  CreateCustomTownhallEvent({required this.createCustomTownhallRequest});

  @override
  List<Object> get props => [createCustomTownhallRequest];
}

class RenameCustomTownhallEvent extends OrganizationEvent {
  final Map<String, dynamic> renameCustomTownhallRequest;
  RenameCustomTownhallEvent({required this.renameCustomTownhallRequest});

  @override
  List<Object> get props => [renameCustomTownhallRequest];
}

class DeleteCustomTownhallEvent extends OrganizationEvent {
  final Map<String, dynamic> deleteCustomTownhallRequest;
  DeleteCustomTownhallEvent({required this.deleteCustomTownhallRequest});

  @override
  List<Object> get props => [deleteCustomTownhallRequest];
}

class GetCCFEvent extends OrganizationEvent {
  final String townhall_id;
  GetCCFEvent({required this.townhall_id});
  @override
  List<Object> get props => [townhall_id];
}

class UpdateUsersTownhallsEvent extends OrganizationEvent {
  final Map<String, dynamic> updateUsersTownhallsRequest;
  UpdateUsersTownhallsEvent({required this.updateUsersTownhallsRequest});

  @override
  List<Object> get props => [updateUsersTownhallsRequest];
}
// class UpdateUsersTownhallsEvent extends OrganizationEvent {
//   final String org_id;
//   final List<dynamic> townhall_ids;

//   UpdateUsersTownhallsEvent({required this.org_id,required this.townhall_ids});

//   @override
//   List<Object> get props => [org_id,townhall_ids];
// }
