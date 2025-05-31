part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class GetTermsEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class GetPrivacyEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class RegisterUserEvent extends AuthEvent {
  final RegisterRequest registerRequest;

  RegisterUserEvent({required this.registerRequest});

  @override
  List<Object> get props => [registerRequest];
}

class LoginUserEvent extends AuthEvent {
  final LoginRequest loginRequest;

  LoginUserEvent({required this.loginRequest});

  @override
  List<Object> get props => [loginRequest];
}

class LogoutEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends AuthEvent {
  final ProfileUpdateRequest profileUpdateRequest;

  UpdateProfileEvent({required this.profileUpdateRequest});

  @override
  List<Object> get props => [profileUpdateRequest];
}

class GetProfileEvent extends AuthEvent {
  GetProfileEvent();

  @override
  List<Object> get props => [];
}

class GetSocialGroupsEvent extends AuthEvent {
  final String org_id;
  GetSocialGroupsEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}

class GetProfessionsEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class GetQualificationsEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class GetPollingEvent extends AuthEvent {
  final String ward_id;
  GetPollingEvent({required this.ward_id});
  @override
  List<Object> get props => [ward_id];
}

class UpdateProfileImageEvent extends AuthEvent {
  final File image;

  UpdateProfileImageEvent({required this.image});

  @override
  List<Object> get props => [image];
}

class RegisterOTPEvent extends AuthEvent {
  final RegisterOTPRequest registerOTPRequest;

  RegisterOTPEvent({required this.registerOTPRequest});

  @override
  List<Object> get props => [registerOTPRequest];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email_address;

  ForgotPasswordEvent({required this.email_address});

  @override
  List<Object> get props => [email_address];
}

class ForgotPasswordOTPEvent extends AuthEvent {
  final String sort_code;
  final String email;

  ForgotPasswordOTPEvent({required this.sort_code, required this.email});

  @override
  List<Object> get props => [sort_code, email];
}

class UpdatePasswordEvent extends AuthEvent {
  final String v_code;
  final String password;
  final String email;

  UpdatePasswordEvent(
      {required this.v_code, required this.password, required this.email});

  @override
  List<Object> get props => [v_code, password, email];
}

class GetCountriesEvent extends AuthEvent {
  GetCountriesEvent();

  @override
  List<Object> get props => [];
}

class GetStatesEvent extends AuthEvent {
  final int countryId;

  GetStatesEvent({required this.countryId});

  @override
  List<Object> get props => [countryId];
}

class GetLgasEvent extends AuthEvent {
  final int stateId;

  GetLgasEvent({required this.stateId});

  @override
  List<Object> get props => [stateId];
}

class GetPartyEvent extends AuthEvent {
  final String countryID;
  final String forResult;

  GetPartyEvent({required this.countryID, required this.forResult});

  @override
  List<Object> get props => [countryID, forResult];
}

class GetWardsEvent extends AuthEvent {
  final int lgaId;

  GetWardsEvent({required this.lgaId});

  @override
  List<Object> get props => [lgaId];
}

class DeleteEvent extends AuthEvent {
  //for deleting account
  final String password;

  DeleteEvent({required this.password});

  @override
  List<Object> get props => [password];
}

class DisableEvent extends AuthEvent {
  //for deleting account
  final String password;

  DisableEvent({required this.password});

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordEvent extends AuthEvent {
  //for deleting account
  final String password;
  final String purpose; //purpose for confirming password Ex: Delete,Disable
  ConfirmPasswordEvent({required this.password, required this.purpose});

  @override
  List<Object> get props => [password, purpose];
}

class DeactivateEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class ReqOTPEvent extends AuthEvent {
  final String email;

  ReqOTPEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class GetOrgDetailsEvent extends AuthEvent {
  final String keyword;
  GetOrgDetailsEvent({required this.keyword});

  @override
  List<Object> get props => [keyword];
}

class JoinOrgEvent extends AuthEvent {
  final Map<String, dynamic> joinRequest;
  JoinOrgEvent({required this.joinRequest});
  @override
  List<Object> get props => [joinRequest];
}

class JoinEvent extends AuthEvent {
  final String org_id;

  JoinEvent({required this.org_id});

  @override
  List<Object> get props => [org_id];
}
