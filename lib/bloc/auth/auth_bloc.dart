import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/accounts/account_deactivation_response.dart';
import 'package:mobilizer/models/countries/countries_response.dart';
import 'package:mobilizer/models/countries/lgas_response.dart';
import 'package:mobilizer/models/countries/states_response.dart';
import 'package:mobilizer/models/countries/wards_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_otp_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_update_response.dart';
import 'package:mobilizer/models/login/login_request.dart';
import 'package:mobilizer/models/login/login_response.dart';
import 'package:mobilizer/models/organization/join_organization_response.dart'
    as deepJoin;
import 'package:mobilizer/models/organization/organization_details_visitor_response.dart';
import 'package:mobilizer/models/parties/parties_response.dart';
import 'package:mobilizer/models/profile/get_profile_response.dart';
import 'package:mobilizer/models/profile/profile_image_response.dart';
import 'package:mobilizer/models/profile/profile_update_request.dart';
import 'package:mobilizer/models/profile/profile_update_response.dart';
import 'package:mobilizer/models/qualifications/qualifications_response.dart';
import 'package:mobilizer/models/register/confirm_password_response.dart';
import 'package:mobilizer/models/register/delete_account_response.dart';
import 'package:mobilizer/models/register/disable_account_response.dart';
import 'package:mobilizer/models/register/register_otp_request.dart';
import 'package:mobilizer/models/register/register_otp_response.dart';
import 'package:mobilizer/models/register/register_request.dart';
import 'package:mobilizer/models/register/register_response.dart';
import 'package:mobilizer/models/register/request_otp_response.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:mobilizer/models/social/social_groups_response.dart';
import 'package:mobilizer/models/term/term_response.dart';
import 'package:mobilizer/models/privacy/privacy_response.dart';

import 'package:mobilizer/services/api_service.dart';
import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/login/logout_response.dart';
import '../../models/profile/get_profile_complete_response.dart';
import 'package:mobilizer/models/professions/professions_response.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<RegisterUserEvent>(_onRegisterUserEvent);
    on<ConfirmPasswordEvent>(_onConfirmPasswordEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<DisableEvent>(_onDisableEvent);
    on<LoginUserEvent>(_onLoginUserEvent);
    on<GetOrgDetailsEvent>(_onGetOrgDetailsEvent);
    on<JoinEvent>(_onJoinEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<GetProfileEvent>(_onGetProfileEvent);
    on<UpdateProfileImageEvent>(_onUpdateProfileImageEvent);
    on<RegisterOTPEvent>(_onRegisterOTPEvent);
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
    on<ForgotPasswordOTPEvent>(_onForgotPasswordOTPEvent);
    on<UpdatePasswordEvent>(_onUpdatePasswordEvent);
    on<GetCountriesEvent>(_onGetCountriesEvent);
    on<GetStatesEvent>(_onGetStatesEvent);
    on<GetLgasEvent>(_onGetLgasEvent);
    on<GetWardsEvent>(_onGetWardsEvent);
    on<GetTermsEvent>(_onGetTermsEvent);
    on<GetPrivacyEvent>(_onGetPrivacyEvent);
    on<GetPartyEvent>(_onGetPartyEvent);
    on<GetPollingEvent>(_onGetPollingEvent);
    on<GetProfessionsEvent>(_onGetProfessionsEvent);
    on<GetQualificationsEvent>(_onGetQualificationsEvent);
    on<DeactivateEvent>(_onDeactivateEvent);
    on<GetSocialGroupsEvent>(_onGetSocialGroupsEvent);
    on<ReqOTPEvent>(_onReqOTPEvent);
  }
  Future<void> _onGetOrgDetailsEvent(
      GetOrgDetailsEvent event, Emitter<AuthState> emit) async {
    try {
      var token = await getToken();
      OrganizationDetailsResponse responseData =
          await ApiService().deepLinkOrgDetails(event.keyword);

      if (responseData.status == 200) {
        if (responseData.data == null) {
          emit(NoResultState(message: 'No Result'));
        } else {
          print(responseData);
          // emit(LoadedOrgDetailsState(
          //     orgResponse: responseData,
          //     hasToken: token == null ? false : true));
          emit(LoadedOrgDetailsState(
              orgResponse: responseData,
              hasToken: token == null ? false : true));
        }
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  //join
  Future<void> _onJoinEvent(JoinEvent event, Emitter<AuthState> emit) async {
    try {
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
        emit(AlreadyMemberState(message: responseData.msg));
      } else {
        emit(JoinFailedState(message: responseData.msg));
        //emit(ErrorState(message: responseData.msg));
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

  Future<void> _onDeactivateEvent(
      DeactivateEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      AccountDeactivationResponse responseData =
          await ApiService().deactivateAccount(token!);
      //print("status  ${responseData.status}");

      if (responseData.status == 200) {
        await AppSharedPreferences.removeValue(key: 'token');
        await AppSharedPreferences.removeValue(key: 'townhallView');
        await AppSharedPreferences.removeValue(key: 'groupID');
        // await AppSharedPreferences.removeValue(key: 'orgID');
        // await AppSharedPreferences.removeValue(key: 'orgName');
        await AppSharedPreferences.removeValue(key: 'isLeader');
        await AppSharedPreferences.removeValue(key: 'login');
        await AppSharedPreferences.removeValue(key: 'dismissedVersion');
        emit(DeactivationState(deactivationResponse: responseData));
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

  Future<void> _onGetQualificationsEvent(
      GetQualificationsEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      QualificationResponse responseData =
          await ApiService().getQualifications(token!);
      //print("status  ${responseData.status}");

      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'No Result'));
        } else {
          print(responseData);
          emit(QualificationState(qualificationResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Error here 2");
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetSocialGroupsEvent(
      GetSocialGroupsEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      Map<String, dynamic> map = {'org_id': event.org_id};

      SocialGroupsResponse responseData =
          await ApiService().getSocialGroups(token!, map);
      //print("status  ${responseData.status}");

      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'No Result'));
        } else {
          print(responseData);
          emit(GetSocialGroupsState(getGroupsResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Error here 5");
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetProfessionsEvent(
      GetProfessionsEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      ProfessionResponse responseData =
          await ApiService().getProfessions(token!);
      //print("status  ${responseData.status}");

      if (responseData.status == 200) {
        if (responseData.status == 400) {
          emit(NoResultState(message: 'No Result'));
        } else {
          print(responseData);
          emit(ProfessionState(professionResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Error here 1");
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetTermsEvent(
      GetTermsEvent event, Emitter<AuthState> emit) async {
    try {
      emit(TermLoadingState());

      // await ApiService().getTerms(); //live
      // await ApiService().getTerms2(); //empl
      // await ApiService().getProducts();
      // await ApiService().getTerms(); //live
      TermResponse responseData = await ApiService().getTerms();

      //print(responseData.data);
      if (responseData.status == "200") {
        print("Am here");
        emit(TermState(termResponse: responseData));
      } else {
        emit(TermErrorState(
            status: int.parse(responseData.status), message: responseData.msg));
      }
    } on SocketException catch (e) {
      debugPrint(e.osError.toString());
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

  Future<void> _onGetPrivacyEvent(
      GetPrivacyEvent event, Emitter<AuthState> emit) async {
    try {
      emit(PrivacyLoadingState());
      PrivacyResponse responseData = await ApiService().getPrivacy();
      if (responseData.status == 200) {
        emit(PrivacyState(privacyResponse: responseData));
      } else {
        emit(PrivacyErrorState(
            status: responseData.status, message: responseData.msg));
      }
    } on SocketException catch (e) {
      debugPrint(e.osError.toString());
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

  Future<void> _onRegisterUserEvent(
      RegisterUserEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());

    try {
      emit(LoadingState());
      print(event.registerRequest.toJson());
      // RegisterResponse responseData =
      //     await client.registration(event.registerRequest.toJson());

      Map<String, dynamic> map = Map();
      map["email"] = event.registerRequest.email;
      map["password"] = event.registerRequest.password;
      map["app_name"] = event.registerRequest.app_name;

      RegisterResponse responseData = await ApiService().registration(map);

      if (responseData.status.toString() == '200') {
        emit(RegisteredState(registerResponse: responseData));
      } else if (responseData.status.toString() == "401") {
        emit(ErrorState(
            message: responseData.msg, status: int.parse(responseData.status)));
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
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onLoginUserEvent(
      LoginUserEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      print("Device Token: ${event.loginRequest.device_token}");
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // LoginResponse responseData =
      //     await client.login(event.loginRequest.toJson());

      Map<String, dynamic> map = Map();
      Map<String, dynamic> map2 = Map();
      map["app_name"] = event.loginRequest.app_name;
      map["email"] = event.loginRequest.email;
      map["password"] = event.loginRequest.password;
      map["device_type"] = event.loginRequest.device_type;
      map["device_token"] = event.loginRequest.device_token;
      LoginResponse responseData = await ApiService().login(map);
      print("My " + responseData.status.toString());
      if (responseData.status == 200) {
        await AppSharedPreferences.setValue(
            key: 'user_id', value: responseData.data!.user_id);
        await AppSharedPreferences.setValue(
            key: 'token', value: responseData.data!.token);
        print("My Token:${responseData.data!.token}");
        await AppSharedPreferences.setValue(key: 'login', value: 'success');
        await AppSharedPreferences.setValue(
            key: 'profilePic', value: responseData.data!.photo_path_mid);
        await AppSharedPreferences.setValue(
            key: 'name',
            value: responseData.data!.firstname.toString() +
                " " +
                responseData.data!.lastname.toString());
        await AppSharedPreferences.setValue(
            key: 'username',
            value: responseData.data!.username.toString() == "null"
                ? ""
                : responseData.data!.username.toString());
        await AppSharedPreferences.setValue(
            key: 'townhallView', value: 'location');

        await AppSharedPreferences.setValue(key: 'orgID', value: '');
        await AppSharedPreferences.setValue(key: 'groupID', value: '');
        await AppSharedPreferences.setValue(key: 'groupName', value: '');
        print("State LocalVersion: ${packageInfo.version}");
        await AppSharedPreferences.setValue(
            key: 'dismissedVersion', value: packageInfo.version);
        await AppSharedPreferences.setValue(key: 'pageID', value: '0');

        GetProfileCompleteResponse responseCompleteData = await ApiService()
            .getProfileComplete(responseData.data!.token, 'townhall');

        if (responseCompleteData.status == "200") {
          print(
              "I have successfully login ${responseData.data!.user_id.toString()}  ${await _userExist(responseData.data!.user_id.toString())}");
          //check if user exist in firestore
          if (await _userExist(responseData.data!.user_id.toString()) ==
              false) {
            //create user
            Map<String, dynamic> userData = {
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp()
            };
            _createFirestoreUser(
                responseData.data!.user_id.toString(), userData);
          }
          emit(LoginState(loginResponse: responseData));
        }
        if (responseCompleteData.status == "400" ||
            responseCompleteData.status == "401") {
          if (await _userExist(responseData.data!.user_id.toString()) ==
              false) {
            //create user
            Map<String, dynamic> userData = {
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp()
            };
            _createFirestoreUser(
                responseData.data!.user_id.toString(), userData);
          }
          // to profile page
          emit(GoToProfileState(
              status: responseCompleteData.status,
              message: responseCompleteData.msg));
        }
      } else if (responseData.status == 401) {
        print("Am here");
        // if (await _userExist(responseData.data!.user_id.toString()) == false) {
        //   //create user
        //   Map<String, dynamic> userData = {
        //     'isOnline': true,
        //     'lastSeen': FieldValue.serverTimestamp()
        //   };
        //   _createFirestoreUser(responseData.data!.user_id.toString(), userData);
        // }
        emit(GoToOTPState(
            message: responseData.msg,
            status: responseData.status)); //to OTP page
      } else {
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onReqOTPEvent(
      ReqOTPEvent event, Emitter<AuthState> emit) async {
    try {
      Map<String, dynamic> map = Map();
      map["email"] = event.email;
      RequestOTPResponse responseData = await ApiService().reqOTP(map);
      if (responseData.status == "200") {
        emit(ReqOTPState(
            status: responseData.status.toString(), message: responseData.msg));
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

  Future<void> _onLogoutEvent(
      LogoutEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      emit(LoadingState());
      var token = await getToken();
      var deviceToken = await getDeviceToken();
      Map<String, dynamic> map = Map();
      map["device_token"] = deviceToken;
      LogoutResponse responseData = await ApiService().logout(token!, map);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        clearCache();
        await AppSharedPreferences.removeValue(key: 'token');
        // await AppSharedPreferences.removeValue(key: 'townhallView');
        // await AppSharedPreferences.removeValue(key: 'groupID');
        // await AppSharedPreferences.removeValue(key: 'orgID');
        // await AppSharedPreferences.removeValue(key: 'orgName');
        // await AppSharedPreferences.removeValue(key: 'isLeader');
        await AppSharedPreferences.removeValue(key: 'login');
        // await AppSharedPreferences.removeValue(key: 'dismissedVersion');
        emit(LogoutState(
            status: responseData.status, message: responseData.msg));
      } else {
        emit(LogoutState(
            status: responseData.status, message: responseData.msg));
      }
    } on SocketException catch (e) {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUpdateProfileEvent(
      UpdateProfileEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      print("status ${token}");
      Map<String, dynamic> map = {
        'username': event.profileUpdateRequest.username,
        'about': event.profileUpdateRequest.about,
        'firstname': event.profileUpdateRequest.firstname,
        'lastname': event.profileUpdateRequest.lastname,
        'phone': event.profileUpdateRequest.phone,
        //this.othernames,
        'gender': event.profileUpdateRequest.gender,
        'dob': event.profileUpdateRequest.dob,
        'edu_level_id': event.profileUpdateRequest.edu_level_id,
        'profession_category': event.profileUpdateRequest.profession_category,
        'user_profession': event.profileUpdateRequest.user_profession,
        'country': event.profileUpdateRequest.country,
        'state': event.profileUpdateRequest.state,
        'state_origin': event.profileUpdateRequest.state_origin,
        'lga': event.profileUpdateRequest.lga,
        'ward': event.profileUpdateRequest.ward,
        'pu': event.profileUpdateRequest.pu,
        'party': event.profileUpdateRequest.party,
        'support_group_id': event.profileUpdateRequest.support_group_id
      };
      print(event.profileUpdateRequest.toJson());
      ProfileUpdateResponse responseData =
          await ApiService().updateProfile(token!, map);
      print("Polling unit: ${event.profileUpdateRequest.pu}");
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        emit(ProfileState(profileUpdateResponse: responseData));
      } else {
        //failed profile
        emit(UpdateProfileFailedState(
            message: responseData.msg, status: responseData.status));
        // emit(
        //     ErrorState(message: responseData.msg, status: responseData.status));
      }
    } on SocketException catch (e) {
      print(e.message);
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

  Future<void> _onGetProfileEvent(
      GetProfileEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print("token ${token}");
      GetProfileResponse responseData = await ApiService().getProfile(token!);
      if (responseData.status == 200) {
        print("Am inside get profile state");
        emit(GetProfileState(getProfileResponse: responseData));
      } else if (responseData.status == 401) {
        print("Am inside incomplete profile state");
        emit(IncompleteProfileState(
            email: responseData.data!.email, getProfileResponse: responseData));
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetPollingEvent(
      GetPollingEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      //print(token);

      SearchPollingUnitResponse responseData =
          await ApiService().getPollingUnites('', int.parse(event.ward_id));
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
          print('No Result');
        } else {
          emit(LoadedPollingState(getPollingResponse: responseData));
          print('Result Found');
        }
      } else {
        emit(ErrorState(message: responseData.message));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onUpdateProfileImageEvent(
      UpdateProfileImageEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      print(token);
      ProfileImageResponse responseData =
          await ApiService().updateProfileImage(token!, event.image);
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        emit(ProfileImageState(profileImageResponse: responseData));
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

  Future<void> _onRegisterOTPEvent(
      RegisterOTPEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());

      //print(token);
      //print(event.registerOTPRequest.toJson());
      RegisterOTPResponse responseData =
          await ApiService().registrationOTP(event.registerOTPRequest.toJson());
      //print(responseData);
      if (responseData.status == '200') {
        await AppSharedPreferences.setValue(
            key: 'user_id', value: responseData.data!.user_id);
        await AppSharedPreferences.setValue(
            key: 'token', value: responseData.data!.token);
        emit(RegisterOTPState(registerOTPResponse: responseData));

        print(
            "PRINT OT AFTER LOG: ${responseData.data!.token} USERID: ${responseData.data!.user_id}");
        await AppSharedPreferences.setValue(key: 'login', value: 'success');
        await AppSharedPreferences.setValue(
            key: 'townhallView', value: 'location');
      }
      //  else if (responseData.status == '400') {
      //   print("invalid code");
      //   emit(RegisterOTPFailState(message: 'Invaid Code'));
      // }
      else {
        print("Am here");
        emit(ErrorState(
            message: responseData.msg, status: int.parse(responseData.status)));
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onConfirmPasswordEvent(
      ConfirmPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      var token = await getToken();
      Map<String, dynamic> map = {'password': event.password};
      ConfirmPasswordResponse responseData =
          await ApiService().confirmPassword(token.toString(), map);
      //print(responseData);
      if (responseData.status == 200) {
      } else if (responseData.status == 400) {
        print("invalid code");
        //emit(ErrorState(message: response));
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      } else {
        print("Am here");
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      Map<String, dynamic> map = {'password': event.password};
      DeleteAccountResponse responseData =
          await ApiService().deleteAccount(token.toString(), map);
      //print(responseData);
      if (responseData.status == 200) {
      } else if (responseData.status == 400) {
        print("invalid code");
        //emit(ErrorState(message: response));
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      } else {
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onDisableEvent(
      DisableEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      var token = await getToken();
      Map<String, dynamic> map = {'password': event.password};
      DisableAccountResponse responseData =
          await ApiService().disableAccount(token.toString(), map);
      //print(responseData);
      if (responseData.status == 200) {
      } else if (responseData.status == 400) {
        print("invalid code");
        //emit(ErrorState(message: response));
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      } else {
        emit(
            ErrorState(message: responseData.msg, status: responseData.status));
      }
    } on SocketException catch (e) {
      print(e.message);
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException catch (e) {
      print(e.message);
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onForgotPasswordEvent(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      Map<String, dynamic> map = Map();
      map["email_address"] = event.email_address;
      ForgotPasswordResponse responseData =
          await ApiService().forgotPassword(map);
      print("status ${responseData.status}");
      if (responseData.status == '200') {
        emit(ForgotPasswordState(forgotPasswordResponse: responseData));
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

  Future<void> _onForgotPasswordOTPEvent(
      ForgotPasswordOTPEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      Map<String, dynamic> map = Map();
      map["email"] = event.email;
      map["sort_code"] = event.sort_code;
      ForgotPasswordOTPResponse responseData =
          await ApiService().forgotPasswordOTP(map);
      print("status ${responseData.status}");
      if (responseData.status == '200') {
        emit(ForgotPasswordOTPState(forgotPasswordOTPResponse: responseData));
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

  Future<void> _onUpdatePasswordEvent(
      UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      Map<String, dynamic> map = Map();
      map["email"] = event.email;
      map["password"] = event.password;
      map["v_code"] = event.v_code;
      ForgotPasswordUpdateResponse responseData =
          await ApiService().forgotPasswordUpdate(map);
      print("status ${responseData.status}");
      if (responseData.status == '200') {
        emit(ForgotPasswordUpdateState(
            forgotPasswordUpdateResponse: responseData));
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

  Future<void> _onGetCountriesEvent(
      GetCountriesEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      CountriesResponse responseData = await ApiService().getCountries();
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        print("Cou");
        emit(CountriesState(countriesResponse: responseData));
      } else {
        emit(ErrorState(message: responseData.message));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Error here 3");
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetStatesEvent(
      GetStatesEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      StatesResponse responseData =
          await ApiService().getStates(event.countryId.toString());
      print("status ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(StatesState(statesResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.message));
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
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetLgasEvent(
      GetLgasEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      LgasResponse responseData =
          await ApiService().getLgas(event.stateId.toString());
      //print("status ${responseData.status}");
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(LgasState(lgasResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.message));
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

  Future<void> _onGetPartyEvent(
      GetPartyEvent event, Emitter<AuthState> emit) async {
    try {
      //emit(LoadingState());
      var token = await getToken();
      Map<String, dynamic> map = {
        'country_id': event.countryID,
        'for_result': 'yes',
        'the_election': ''
      };
      PartyResponse responseData = await ApiService().getParties(token!, map);
      //print("status ${responseData.status}");
      if (responseData.status == "200") {
        print("Am inside 200");
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(PartyState(partyResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.msg));
      }
    } on SocketException {
      print("Handle network/socket issue");
      emit(NetworkState(message: socketException));
    } on FormatException catch (e) {
      print("Error here 7");
      debugPrint(e.source);
      emit(NetworkState(message: formatException));
    } on TimeoutException {
      emit(NetworkState(message: timeoutException));
    } catch (e) {
      print(e.toString());
      emit(NetworkState(message: unknown));
    }
  }

  Future<void> _onGetWardsEvent(
      GetWardsEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingState());
      WardsResponse responseData =
          await ApiService().getWards(event.lgaId.toString());
      print("status ${responseData.status}");
      print(responseData.data);
      if (responseData.status == 200) {
        if (responseData.data.length < 1) {
          emit(NoResultState(message: 'No Result'));
        } else {
          emit(WardsState(wardsResponse: responseData));
        }
      } else {
        emit(ErrorState(message: responseData.message));
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

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }

  Future<bool> _userExist(userID) async {
    bool exists = await checkIfDocumentExists(userID);
    if (exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfDocumentExists(String docId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();
      return documentSnapshot.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _createFirestoreUser(
      String docId, Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .set(userData);
      print('User created with ID: $docId');
    } catch (e) {
      print('Error creating user: $e');
    }
  }
}
