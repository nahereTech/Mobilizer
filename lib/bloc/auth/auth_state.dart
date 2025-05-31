part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class TermState extends AuthState {
  final TermResponse termResponse;

  TermState({required this.termResponse});

  @override
  List<Object?> get props => [termResponse];
}

class PrivacyState extends AuthState {
  final PrivacyResponse privacyResponse;

  PrivacyState({required this.privacyResponse});

  @override
  List<Object?> get props => [privacyResponse];
}

class NetworkState extends AuthState {
  final String? message;
  NetworkState({this.message});
  @override
  List<Object> get props => [];
}

class LoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

class TermLoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

class PrivacyLoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

class TermNoResultState extends AuthState {
  @override
  List<Object?> get props => [];
}

class PrivacyNoResultState extends AuthState {
  @override
  List<Object?> get props => [];
}

class ErrorState extends AuthState {
  final int? status;
  final String? message;

  ErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class DeleteState extends AuthState {
  // for delete account
  final int status;
  final String message;

  DeleteState({required this.status, required this.message});

  @override
  List<Object> get props => [status, message];
}

class DisableState extends AuthState {
  // for disabling account
  final int status;
  final String message;

  DisableState({required this.status, required this.message});

  @override
  List<Object> get props => [status, message];
}

class ConfirmPasswordState extends AuthState {
  // for delete account
  final int status;
  final String message;
  final String tag;
  final String purpose; //purpose for confirming password Ex: Delete,Disable

  ConfirmPasswordState(
      {required this.status,
      required this.message,
      required this.tag,
      required this.purpose});

  @override
  List<Object> get props => [status, message, tag, purpose];
}

class UpdateProfileFailedState extends AuthState {
  final int? status;
  final String? message;
  UpdateProfileFailedState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class NoResultState extends AuthState {
  final String? message;
  NoResultState({this.message});
  @override
  List<Object> get props => [];
}

class TermErrorState extends AuthState {
  final int? status;
  final String? message;

  TermErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class PrivacyErrorState extends AuthState {
  final int? status;
  final String? message;

  PrivacyErrorState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class RegisteredState extends AuthState {
  final RegisterResponse registerResponse;

  RegisteredState({required this.registerResponse});

  @override
  List<Object?> get props => [registerResponse];
}

class ProfessionState extends AuthState {
  final ProfessionResponse professionResponse;
  ProfessionState({required this.professionResponse});
  @override
  List<Object?> get props => [professionResponse];
}

class QualificationState extends AuthState {
  final QualificationResponse qualificationResponse;
  QualificationState({required this.qualificationResponse});
  @override
  List<Object?> get props => [qualificationResponse];
}

class LoginState extends AuthState {
  final LoginResponse loginResponse;

  LoginState({required this.loginResponse});

  @override
  List<Object?> get props => [loginResponse];
}

class LogoutState extends AuthState {
  final int? status;
  final String? message;

  LogoutState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class GetProfileState extends AuthState {
  final GetProfileResponse getProfileResponse;

  GetProfileState({required this.getProfileResponse});

  @override
  List<Object?> get props => [getProfileResponse];
}

class LoadedPollingState extends AuthState {
  final SearchPollingUnitResponse getPollingResponse;

  LoadedPollingState({required this.getPollingResponse});
  @override
  List<Object?> get props => [getPollingResponse];
}

class GetSocialGroupsState extends AuthState {
  final SocialGroupsResponse getGroupsResponse;

  GetSocialGroupsState({required this.getGroupsResponse});
  @override
  List<Object?> get props => [getGroupsResponse];
}

class ProfileState extends AuthState {
  final ProfileUpdateResponse profileUpdateResponse;

  ProfileState({required this.profileUpdateResponse});

  @override
  List<Object?> get props => [profileUpdateResponse];
}

class ProfileImageState extends AuthState {
  final ProfileImageResponse profileImageResponse;

  ProfileImageState({required this.profileImageResponse});

  @override
  List<Object?> get props => [profileImageResponse];
}

class RegisterOTPState extends AuthState {
  final RegisterOTPResponse registerOTPResponse;

  RegisterOTPState({required this.registerOTPResponse});

  @override
  List<Object?> get props => [registerOTPResponse];
}

class RegisterOTPFailState extends AuthState {
  final message;

  RegisterOTPFailState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordState extends AuthState {
  final ForgotPasswordResponse forgotPasswordResponse;

  ForgotPasswordState({required this.forgotPasswordResponse});

  @override
  List<Object?> get props => [forgotPasswordResponse];
}

class ForgotPasswordOTPState extends AuthState {
  final ForgotPasswordOTPResponse forgotPasswordOTPResponse;

  ForgotPasswordOTPState({required this.forgotPasswordOTPResponse});

  @override
  List<Object?> get props => [forgotPasswordOTPResponse];
}

class ForgotPasswordUpdateState extends AuthState {
  final ForgotPasswordUpdateResponse forgotPasswordUpdateResponse;

  ForgotPasswordUpdateState({required this.forgotPasswordUpdateResponse});

  @override
  List<Object?> get props => [forgotPasswordUpdateResponse];
}

class CountriesState extends AuthState {
  final CountriesResponse countriesResponse;

  CountriesState({required this.countriesResponse});

  @override
  List<Object?> get props => [countriesResponse];
}

class StatesState extends AuthState {
  final StatesResponse statesResponse;

  StatesState({required this.statesResponse});

  @override
  List<Object?> get props => [statesResponse];
}

class LgasState extends AuthState {
  final LgasResponse lgasResponse;

  LgasState({required this.lgasResponse});

  @override
  List<Object?> get props => [lgasResponse];
}

class PartyState extends AuthState {
  final PartyResponse partyResponse;
  PartyState({required this.partyResponse});

  @override
  List<Object?> get props => [partyResponse];
}

class NoPartyState extends AuthState {
  @override
  List<Object?> get props => [];
}

class WardsState extends AuthState {
  final WardsResponse wardsResponse;

  WardsState({required this.wardsResponse});

  @override
  List<Object?> get props => [wardsResponse];
}

class GoToOTPState extends AuthState {
  final int? status;
  final String? message;

  GoToOTPState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class GoToProfileState extends AuthState {
  final String? status;
  final String? message;

  GoToProfileState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class DeactivationState extends AuthState {
  final AccountDeactivationResponse deactivationResponse;

  DeactivationState({required this.deactivationResponse});

  @override
  List<Object?> get props => [deactivationResponse];
}

class IncompleteProfileState extends AuthState {
  final GetProfileResponse getProfileResponse;
  final String email;
  IncompleteProfileState(
      {required this.getProfileResponse, required this.email});
  @override
  List<Object?> get props => [getProfileResponse, email];
}

class ReqOTPState extends AuthState {
  final String? status;
  final String? message;

  ReqOTPState({this.status, this.message});
  @override
  List<Object> get props => [];
}

class LoadedOrgDetailsState extends AuthState {
  final OrganizationDetailsResponse orgResponse;
  final bool hasToken;
  LoadedOrgDetailsState({required this.orgResponse, required this.hasToken});
  @override
  List<Object?> get props => [orgResponse, hasToken];
}

class JoinState extends AuthState {
  final int status;
  final String message;
  JoinState({required this.status, required this.message});
  @override
  List<Object> get props => [];
}

class JoinFailedState extends AuthState {
  final int? status;
  final String? message;
  JoinFailedState({this.status, this.message});

  @override
  List<Object> get props => [];
}

class AlreadyMemberState extends AuthState {
  final String? message;

  AlreadyMemberState({this.message});

  @override
  List<Object?> get props => [message];
}
