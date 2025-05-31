import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
// import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/login/password_verification_response.dart';
import 'package:mobilizer/models/organization/create_custom_organization_child_response.dart';
import 'package:mobilizer/models/organization/create_custom_organization_response.dart';
import 'package:mobilizer/models/organization/create_custom_organization_temp_response.dart';
import 'package:mobilizer/models/organization/create_organization_response.dart';
import 'package:mobilizer/models/organization/default_available_twh_response.dart';
import 'package:mobilizer/models/organization/default_postable_twh_response.dart';
import 'package:mobilizer/models/organization/delete_custom_organization_response.dart';
import 'package:mobilizer/models/organization/delete_organization_response.dart';
import 'package:mobilizer/models/organization/my_organization_response.dart';
import 'package:mobilizer/models/organization/organization_ccf_response.dart';
import 'package:mobilizer/models/organization/organization_interest_response.dart';
import 'package:mobilizer/models/organization/organization_plan_response.dart';
import 'package:mobilizer/models/organization/organization_tree_response.dart';
import 'package:mobilizer/models/organization/pin_response.dart';
import 'package:mobilizer/models/organization/rename_custom_organization_response.dart';
import 'package:mobilizer/models/organization/unpin_response.dart';
import 'package:mobilizer/models/organization/update_organization_banner_response.dart';
import 'package:mobilizer/models/organization/update_organization_logo_response.dart';
import 'package:mobilizer/models/organization/update_organization_response.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:mobilizer/models/search/leave_organization_response.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';
import 'package:mobilizer/models/townhall/update_users_townhalls_response.dart';
import 'package:mobilizer/models/organization/organization_response.dart';
import 'package:mobilizer/services/api_service.dart';

part 'organization_event.dart';
part 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  OrganizationBloc() : super(OrganizationInitial()) {
    // on<SearchPeopleEvent>(_onSearchPeopleEvent);
    on<DefaultAvailableTWHEvent>(_onDefaultAvailableTWHEvent);
    on<DefaultPostableTWHEvent>(_onDefaultPostableTWHEvent);
    on<CreateOrganizationEvent>(_onCreateOrganizationEvent);
    on<GetInterestEvent>(_onGetInterestEvent);
    on<GetOrganizationEvent>(_onGetOrganizationEvent);
    on<UpdateOrganizationEvent>(_onUpdateOrganizationEvent);
    on<UpdateOrgBannerEvent>(_onUpdateOrgBannerEvent);
    on<UpdateOrgLogoEvent>(_onUpdateOrgLogoEvent);
    on<GetOrganizationPlanEvent>(_onGetOrganizationPlanEvent);
    on<MyOrganizationsEvent>(_onMyOrganizationsEvent);
    on<SearchOrganizationEvent>(_onSearchOrganizationEvent);
    on<JoinEvent>(_onJoinEvent);
    on<LeaveEvent>(_onLeaveEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<PinToTopEvent>(_onPinToTopEvent);
    on<UnpinFromTopEvent>(_onUnpinFromTopEvent);
    on<VerifyPasswordEvent>(_onVerifyPasswordEvent);
    on<GetCustomOrganizationIDEvent>(_onGetCustomOrganizationIDEvent);
    on<CreateCustomTownhallEvent>(_onCreateCustomTownhallEvent);
    on<RenameCustomTownhallEvent>(_onRenameCustomTownhallEvent);
    on<DeleteCustomTownhallEvent>(_onDeleteCustomTownhallEvent);
    on<GetOrganizationTreeEvent>(_onGetOrganizationTreeEvent);
    on<GetCCFEvent>(_onGetCCFEvent);
    on<UpdateUsersTownhallsEvent>(_onUpdateUsersTownhallsEvent);
  }

  Future<void> _onGetOrganizationEvent(
      GetOrganizationEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      OrganizationResponse responseData =
          await ApiService().getMyJoinedOrganization(token!);

      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoReturnState(message: 'No Result'));

          print('No Result');
        } else {
          emit(GetOrganizationState(getOrganizationResponse: responseData));
          print('Result Found');
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onDefaultAvailableTWHEvent(
      DefaultAvailableTWHEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      DefaultAvailableTWHResponse responseData =
          await ApiService().defaultAvailableTWH(token!);
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(DefaultAvailableTWHState(
              defaultAvailableTWHResponse: responseData));
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onDefaultPostableTWHEvent(
      DefaultPostableTWHEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      DefaultPostableTWHResponse responseData =
          await ApiService().defaultPostableTWH(token!);
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(DefaultPostableTWHState(
              defaultPostableTWHResponse: responseData));
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onGetOrganizationPlanEvent(
      GetOrganizationPlanEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      //print(token);
      OrganizationPlanResponse responseData =
          await ApiService().getOrganizationPlan(token!);

      if (responseData.status != null && responseData.status == 200) {
        if (responseData.data!.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(GetOrganizationPlanState(
              getOrganizationPlanResponse: responseData));
          print('Result Found');
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onMyOrganizationsEvent(
      MyOrganizationsEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      //print(token);
      MyOrganizationResponse responseData =
          await ApiService().myOrganizations(token!);

      if (responseData.status == 200) {
        emit(MyOrganizationsState(getOrganizationsResponse: responseData));
        print('Result Found');
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(PlanErrorState(message: responseData.msg));
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

  Future<void> _onGetCCFEvent(
      GetCCFEvent event, Emitter<OrganizationState> emit) async {
    try {
      //emit(OrganizationLoadingState());
      var token = await getToken();
      //print(token);

      OrganizationCCFResponse responseData =
          await ApiService().getCCF(token!, event.townhall_id);
      if (responseData.status == 200) {
        if (responseData.data!.length < 1) {
          emit(NoCCFState());
          print("No children");
        } else {
          emit(CCFState(CCFResponse: responseData));
          print('Result Found');
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(PlanErrorState(message: responseData.msg));
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

  Future<void> _onUpdateUsersTownhallsEvent(
      UpdateUsersTownhallsEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      print(token);

      UpdateUsersTownhallsResponse responseData = await ApiService()
          .updateUsersTownhalls(token!, event.updateUsersTownhallsRequest);
      //  UpdateUsersTownhallsResponse responseData = await client
      // .updateUsersTownhalls(token!,event.townhall_ids, event.org_id,);
      print(responseData.status);
      if (responseData.status == 200) {
        emit(UpdateUsersTownhallsState(
            status: responseData.status, message: responseData.msg));
      } else {
        emit(OrganizationErrorState(
            status: responseData.status, message: responseData.msg));
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

  Future<void> _onCreateOrganizationEvent(
      CreateOrganizationEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      print(token);

      CreateOrganizationResponse responseData = await ApiService()
          .createOrganization(token!, event.createOrganizationRequest);
      print("Is a posting as a leader: ${event.createOrganizationRequest}");
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(CreateOrganizationState(createOrganizationResponse: responseData));
      } else {
        emit(OrganizationErrorState(
            status: responseData.status, message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint("Org Error2x:  ${e.message}");
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint("ORG Error: ${e.message}");
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print("ORG ERROR: " + e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      print(event.org_id);
      DeleteOrganizationResponse responseData =
          await ApiService().deleteOrg(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(DeleteOrganizationState(
            status: responseData.status, message: responseData.msg));
        print("deleted");
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onVerifyPasswordEvent(
      VerifyPasswordEvent event, Emitter<OrganizationState> emit) async {
    try {
      // emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["password"] = event.password;
      PasswordVerificationResponse responseData =
          await ApiService().verifyPassword(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(VerifyPasswordState(
            status: responseData.status, message: responseData.msg));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onUpdateOrganizationEvent(
      UpdateOrganizationEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      print(token);

      UpdateOrganizationResponse responseData = await ApiService()
          .updateOrganization(token!, event.updateOrganizationRequest);

      if (responseData.status == 200) {
        emit(UpdateOrganizationState(updateOrganizationResponse: responseData));
      } else {
        emit(OrganizationErrorState(
            status: responseData.status, message: responseData.msg));
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

  Future<void> _onUpdateOrgBannerEvent(
      UpdateOrgBannerEvent event, Emitter<OrganizationState> emit) async {
    try {
      //emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      map["banner_img"] = event.pic;
      UpdateOrganizationBannerResponse responseData =
          await ApiService().updateOrgBanner(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(UpdateOrgBannerState(
            status: responseData.status,
            message: responseData.msg,
            image: responseData.data!.bgimage));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onUpdateOrgLogoEvent(
      UpdateOrgLogoEvent event, Emitter<OrganizationState> emit) async {
    try {
      //emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      map["logo_img"] = event.pic;
      UpdateOrganizationLogoResponse responseData =
          await ApiService().updateOrgLogo(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(UpdateOrgLogoState(
            status: responseData.status,
            message: responseData.msg,
            image: responseData.data!.logoimage));
        print("updated");
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onSearchOrganizationEvent(
      SearchOrganizationEvent event, Emitter<OrganizationState> emit) async {
    try {
      //emit(OrganizationLoadingState());
      var token = await getToken();
      print("TOKEN: " + token.toString());
      print("Term: " + event.term + "INTEREST: " + event.interest_id);

      SearchOrganizationResponse responseData = await ApiService()
          .getOrganizationSearch(token!, event.term, event.interest_id);

      if (responseData.status == 200) {
        if (responseData.data!.length < 1) {
          emit(NoReturnState(message: 'No Result'));
          print('No Result');
        } else {
          emit(SearchOrganizationState(
              searchOrganizationResponse: responseData));
        }
      } else if (responseData.status == 400) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else if (responseData.status == 401) {
        emit(NoReturnState(message: responseData.msg)); //no result
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onGetCustomOrganizationIDEvent(
      GetCustomOrganizationIDEvent event,
      Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      print(token);
      CreateCustomOrganizationTempResponse responseData = await ApiService()
          .getCustomTempOrg(token!, event.customOrganizationIDRequest);
      print(responseData.status.toString());
      if (responseData.status == 200) {
        emit(GetCustomOrganizationIDState(
            customOrganizationIDResponse: responseData));
      } else if (responseData.status == 400) {
        emit(ErrorCustomOrganizationIDState(
            status: responseData.status, message: responseData.msg));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onGetOrganizationTreeEvent(
      GetOrganizationTreeEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();

      OrganizationTreeResponse responseData = await ApiService()
          .getOrganizationTree(token!, event.org_id, event.tree);
      print("${event.org_id} ${event.tree}");
      if (responseData.status == 200) {
        emit(GetOrganizationTreeState(
            getOrganizationTreeResponse: responseData));
      } else {
        emit(OrganizationErrorState(message: 'No result'));
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

  Future<void> _onCreateCustomTownhallEvent(
      CreateCustomTownhallEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      print(event.createCustomTownhallRequest);
      CreateCustomOrganizationChildResponse responseData = await ApiService()
          .createTownhallChild(token!, event.createCustomTownhallRequest);

      if (responseData.status == 200) {
        print(responseData);
        emit(CreateCustomTownhallState(
            createCustomTownhallResponse: responseData));
      } else if (responseData.status == 400) {
        emit(DuplicateErrorState(message: responseData.msg));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onRenameCustomTownhallEvent(
      RenameCustomTownhallEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();

      RenameCustomOrganizationResponse responseData = await ApiService()
          .renameCustomTownhall(token!, event.renameCustomTownhallRequest);

      if (responseData.status == 200) {
        emit(RenameCustomTownhallState(
            renameCustomTownhallResponse: responseData));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onDeleteCustomTownhallEvent(
      DeleteCustomTownhallEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();

      DeleteCustomOrganizationResponse responseData = await ApiService()
          .deleteCustomTownhall(token!, event.deleteCustomTownhallRequest);

      if (responseData.status == 200) {
        emit(DeleteCustomTownhallState(
            deleteCustomTownhallResponse: responseData));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onGetInterestEvent(
      GetInterestEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();
      //print(token);
      OrganizationInterestResponse responseData =
          await ApiService().getInterest(token!);
      if (responseData.status == 200) {
        emit(GetInterestState(getInterestResponse: responseData));
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

  Future<void> _onJoinEvent(
      JoinEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      JoinOrganizationResponse responseData =
          await ApiService().joinOrganization(token!, map);
      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(JoinState(status: responseData.status, message: responseData.msg));
        print("joined");
      } else if (responseData.status == 400) {
        if (responseData.tag == "join_townhalls") {
          emit(ShowBottomSheetState(
              tag: responseData.tag!, getDropDownList: responseData.dropdown!));
        } else {
          emit(AlreadyMemberState(message: responseData.msg));
        }
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onPinToTopEvent(
      PinToTopEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();

      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      PinResponse responseData = await ApiService().pinToTop(token!, map);

      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(PinState(status: responseData.status, message: responseData.msg));
        print("pinned");
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onUnpinFromTopEvent(
      UnpinFromTopEvent event, Emitter<OrganizationState> emit) async {
    try {
      var token = await getToken();

      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      UnpinResponse responseData = await ApiService().unPinToTop(token!, map);

      print("status  ${responseData.status}");
      if (responseData.status == 200) {
        emit(
            UnpinState(status: responseData.status, message: responseData.msg));
        print("Unpinned");
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
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

  Future<void> _onLeaveEvent(
      LeaveEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(OrganizationLoadingState());
      var token = await getToken();
      print(token);
      Map<String, dynamic> map = Map();
      map["org_id"] = event.org_id;
      LeaveOrganizationResponse responseData =
          await ApiService().leaveOrganization(token!, map);
      print("status  ${responseData.msg}");
      if (responseData.status == 200) {
        emit(
            LeaveState(status: responseData.status, message: responseData.msg));
        print("left");
      } else if (responseData.status == 400) {
        emit(AlreadyMemberState(message: responseData.msg));
      } else {
        emit(OrganizationErrorState(message: responseData.msg));
      }
    } on SocketException catch (e) {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
      debugPrint(e.message);
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
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
