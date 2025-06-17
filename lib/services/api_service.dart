import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/comments/comments_of_post_response.dart';
import 'package:mobilizer/models/comments/new_create_comment_response.dart';
import 'package:mobilizer/models/organization/organization_details_visitor_response.dart';
import 'package:mobilizer/models/privacy/privacy_response.dart';
import 'package:mobilizer/models/register/confirm_password_response.dart';
import 'package:mobilizer/models/register/delete_account_response.dart';
import 'package:mobilizer/models/register/disable_account_response.dart';
import 'package:retry/retry.dart';
import 'package:mobilizer/models/Follow/follow_response.dart';
import 'package:mobilizer/models/Follow/followees_response.dart';
import 'package:mobilizer/models/Follow/followers_response.dart';
import 'package:mobilizer/models/Follow/verify_following_response.dart';
import 'package:mobilizer/models/Result/post_result_response.dart';
import 'package:mobilizer/models/accounts/account_deactivation_response.dart';
import 'package:mobilizer/models/comments/comments_response.dart';
import 'package:mobilizer/models/comments/create_comments_response.dart';
import 'package:mobilizer/models/comments/delete_comment_response.dart';
import 'package:mobilizer/models/countries/countries_response.dart';
import 'package:mobilizer/models/countries/lgas_response.dart';
import 'package:mobilizer/models/countries/states_response.dart';
import 'package:mobilizer/models/countries/wards_response.dart';
import 'package:mobilizer/models/createpost/createpost_response.dart';
import 'package:mobilizer/models/election/election_types_response.dart';
import 'package:mobilizer/models/events/event_create_response.dart';
import 'package:mobilizer/models/events/event_delete_response.dart';
import 'package:mobilizer/models/events/event_types_response.dart';
import 'package:mobilizer/models/events/events_response.dart';
import 'package:mobilizer/models/feed/delete_feed_response.dart';
import 'package:mobilizer/models/feed/feed_details_response.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/feed/report_abuse_response.dart';
import 'package:mobilizer/models/feed/topfeed_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_otp_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_response.dart';
import 'package:mobilizer/models/forgotpassword/forgot_password_update_response.dart';
import 'package:mobilizer/models/like/like_details_response.dart';
import 'package:mobilizer/models/like/like_response.dart';
import 'package:mobilizer/models/login/is_user_onboarded_response.dart';
import 'package:mobilizer/models/login/landing_group_response.dart';
import 'package:mobilizer/models/login/login_response.dart';
import 'package:mobilizer/models/login/logout_response.dart';
import 'package:mobilizer/models/login/password_verification_response.dart';
import 'package:mobilizer/models/messages/bulb_notifications_response.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart';
import 'package:mobilizer/models/messages/delete_chat_history_response.dart';
import 'package:mobilizer/models/messages/delete_message_response.dart';
import 'package:mobilizer/models/messages/messages_response.dart';
import 'package:mobilizer/models/messages/post_chat_response.dart';
import 'package:mobilizer/models/notifications/notice_board_response.dart';
import 'package:mobilizer/models/notifications/notifications_response.dart';
import 'package:mobilizer/models/organization/create_custom_organization_child_response.dart';
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
import 'package:mobilizer/models/organization/organization_response.dart';
import 'package:mobilizer/models/organization/organization_tree_response.dart';
import 'package:mobilizer/models/organization/pin_response.dart';
import 'package:mobilizer/models/organization/rename_custom_organization_response.dart';
import 'package:mobilizer/models/organization/unpin_response.dart';
import 'package:mobilizer/models/organization/update_organization_banner_response.dart';
import 'package:mobilizer/models/organization/update_organization_logo_response.dart';
import 'package:mobilizer/models/organization/update_organization_response.dart';
import 'package:mobilizer/models/parties/parties_response.dart';
import 'package:mobilizer/models/poll/poll_cast_response.dart';
import 'package:mobilizer/models/professions/professions_response.dart';
import 'package:mobilizer/models/profile/block_user_response.dart';
import 'package:mobilizer/models/profile/get_profile_complete_response.dart';
import 'package:mobilizer/models/profile/get_profile_response.dart';
import 'package:mobilizer/models/profile/get_subject_profile_response.dart';
import 'package:mobilizer/models/profile/profile_image_response.dart';
import 'package:mobilizer/models/profile/profile_update_response.dart';
import 'package:mobilizer/models/qualifications/qualifications_response.dart';
import 'package:mobilizer/models/register/register_otp_response.dart';
import 'package:mobilizer/models/register/register_response.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/models/register/request_otp_response.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:mobilizer/models/organization/join_organization_response.dart'
    as deepLink;
import 'package:mobilizer/models/search/join_polling_unit_response.dart';
import 'package:mobilizer/models/search/leave_organization_response.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';
import 'package:mobilizer/models/search/search_people_response.dart';
import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/models/social/followee_response.dart';
import 'package:mobilizer/models/social/followers_count_response.dart';
import 'package:mobilizer/models/social/following_count_response.dart';
import 'package:mobilizer/models/social/like_list_response.dart';
import 'package:mobilizer/models/social/social_groups_response.dart';
import 'package:mobilizer/models/suggestion/suggestion_response.dart';
import 'package:mobilizer/models/term/term_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:mobilizer/models/townhall/townhalls_user_is_leader_in_response.dart';
import 'package:mobilizer/models/townhall/update_users_townhalls_response.dart';

class ApiService {
  late PostsBloc postBloc;

  int maxRetries = 1;
  late final http.Client _client;
  // // ApiService._internal() {
  // //   // _client = http.Client();
  // // }
  // static final ApiService _instance = ApiService._internal();
  // factory ApiService() => _instance;
  String baseUrl = "${domainName}/api/";

  Future<RegisterResponse> registration(Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/user_registration2'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(
          Duration(seconds: 60),
          // onTimeout: () {
          //   // Time has run out, do what you wanted to do.
          //   return http.Response(
          //       'Error', 408); // Request Timeout response status code
          // },
        );
    print(response.body);
    return RegisterResponse.fromJson(jsonDecode(response.body));
  }

  Future<RegisterOTPResponse> registrationOTP(Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/confirm_email_then_login'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return RegisterOTPResponse.fromJson(jsonDecode(response.body));
  }

  Future<ConfirmPasswordResponse> confirmPassword(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/confirm_password'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    debugPrint(response.body);
    return ConfirmPasswordResponse.fromJson(jsonDecode(response.body));
  }

  Future<DisableAccountResponse> disableAccount(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/disable_account'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    debugPrint(response.reasonPhrase);
    return DisableAccountResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteAccountResponse> deleteAccount(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/delete_account'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return DeleteAccountResponse.fromJson(jsonDecode(response.body));
  }

  Future<RequestOTPResponse> reqOTP(Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/resend_registration_code'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Content-Transfer-Encoding': 'application/x-www-form-urlencoded'
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return RequestOTPResponse.fromJson(jsonDecode(response.body));
  }

  Future<ForgotPasswordResponse> forgotPassword(
      Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/forgot_password'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return ForgotPasswordResponse.fromJson(jsonDecode(response.body));
  }

  Future<PasswordVerificationResponse> verifyPassword(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/forgot_password'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return PasswordVerificationResponse.fromJson(jsonDecode(response.body));
  }

  Future<ForgotPasswordOTPResponse> forgotPasswordOTP(
      Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/validate_password_recovery_code'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return ForgotPasswordOTPResponse.fromJson(jsonDecode(response.body));
  }

  Future<ForgotPasswordUpdateResponse> forgotPasswordUpdate(
      Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/update_password'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return ForgotPasswordUpdateResponse.fromJson(jsonDecode(response.body));
  }

  Future<LoginResponse> login(Map<String, dynamic> post) async {
    print("BaseUrl ${baseUrl}");
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/login/'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return LoginResponse.fromJson(jsonDecode(response.body));
  }

  Future<LogoutResponse> logout(String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'user/logout'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return LogoutResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreatePostResponse> createPost(
      String token,
      List<File> images,
      String message,
      String org_id,
      String group,
      String posted_as_a_leader,
      List<dynamic> pollOptions,
      String poll_end,
      String poll) async {
    var totalBytesSent = 0;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + 'townhall/createPost/'),
    );
    request.headers['Authorization'] = '$token';
    print(
        "message ${message} group ${group} Media ${images} ORG ${org_id} Post leader ${posted_as_a_leader} Poll option ${pollOptions}");
    // Add files to the request
    if (images.length > 0) {
      for (int i = 0; i < images.length; i++) {
        var file = images[i];
        var multipartFile = await http.MultipartFile.fromPath(
          'files[$i]',
          file.path,
        );
        request.files.add(multipartFile);
      }
    }
    // Add pollOptions to the request
    if (pollOptions.length > 0) {
      for (int i = 0; i < pollOptions.length; i++) {
        request.fields['poll_options[$i]'] = pollOptions[i].toString();
      }
      request.fields['poll_end'] = poll_end;
      request.fields['poll'] = poll;
    }
    // Set form fields
    request.fields['message'] = message;
    request.fields['org_id'] = org_id;
    request.fields['group'] = group;
    request.fields['posted_as_a_leader'] = posted_as_a_leader;
    print("---- Request Details ----");
    print("MakeP Fields: ${request.fields}"); // Form fields
    print("MakeP Headers: ${request.headers}");
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print(response.statusCode);
    print("Resp: " + response.body);
    return CreatePostResponse.fromJson(jsonDecode(response.body));
  }

  Future<GetProfileCompleteResponse> getProfileComplete(
      String token, app) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'profile/is_profile_complete?app=$app'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return GetProfileCompleteResponse.fromJson(jsonDecode(response.body));
  }

  Future<ElectionTypesResponse> getElectionTypes(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/list_of_election_types'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return ElectionTypesResponse.fromJson(jsonDecode(response.body));
  }

  Future<PostResultResponse> postResult(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/submit_election_result/'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return PostResultResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeResponse> likePost(String token, Map<String, dynamic> post) async {
    print("Request: ${post}");
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/like_it'),
          headers: <String, String>{
            'Accept': 'application/json',
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));
    print("Res: ${response.body}");
    return LikeResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeResponse> likeComment(
      String token, Map<String, dynamic> post) async {
    print("Comment: ${post}");
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/like_a_comment'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    print("like: " + response.body);
    return LikeResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeResponse> unLikeComment(
      String token, Map<String, dynamic> post) async {
    // var response = await http
    //     .post(
    //       Uri.parse(baseUrl + 'townhall/unlike_a_comment'),
    //       headers: <String, String>{
    //         'Accept': 'application/json',
    //         'Content-Type': 'application/json; charset=UTF-8',
    //         'Authorization': token
    //       },
    //       body: jsonEncode(post),
    //     )
    //     .timeout(Duration(seconds: 60));
    // print("unlike: " + response.body);
    // return LikeResponse.fromJson(jsonDecode(response.body));

    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/unlike_a_comment'),
          headers: <String, String>{
            'Accept': 'application/json',
            //'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));
    print("unlike: " + response.body);
    return LikeResponse.fromJson(jsonDecode(response.body));
  }

  Future<StatesResponse> getStates(String id) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'locations/states/${id}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return StatesResponse.fromJson(jsonDecode(response.body));
  }

  Future<FolloweeResponse> getFollowee(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/should_show_suggestions'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return FolloweeResponse.fromJson(jsonDecode(response.body));
  }

  Future<EventsResponse> getEvents(String token, int page, int limit) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_events?page=${page}&limit=${limit}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return EventsResponse.fromJson(jsonDecode(response.body));
  }

  Future<SuggestionResponse> getSuggestion(String token, limit) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'social/friendSuggestionList?limit=$limit'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return SuggestionResponse.fromJson(jsonDecode(response.body));
  }

  Future<SearchPeopleResponse> getPeople(String token, term) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/findPeople?term=$term'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return SearchPeopleResponse.fromJson(jsonDecode(response.body));
  }

  Future<FollowingResponseCount> counts(String token, subjectID) async {
    var response = await http.get(
      Uri.parse(
          baseUrl + 'townhall/count_users_followings?subjects_id=$subjectID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return FollowingResponseCount.fromJson(jsonDecode(response.body));
  }

  Future<FollowersResponseCount> total(String token, subjectID) async {
    var response = await http.get(
      Uri.parse(
          baseUrl + 'townhall/count_users_followings?subject_id=$subjectID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return FollowersResponseCount.fromJson(jsonDecode(response.body));
  }

  Future<FollowResponse> follow(String token, Map<String, dynamic> post) async {
    print("FollowR1");
    // var encodedFormData = post.entries
    //     .map((e) =>
    //         '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    //     .join('&');

    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    print("FollowR3 $encodedFormData");
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/createConnection'),
          headers: <String, String>{
            'Accept': 'application/json',
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));
    print("FollowR2");
    return FollowResponse.fromJson(jsonDecode(response.body));
  }

  Future<GetVerifyFollowingResponse> verifyFollowing(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'social/verifyFollowing'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return GetVerifyFollowingResponse.fromJson(jsonDecode(response.body));
  }

  Future<FollowResponse> unfollow(
      String token, Map<String, dynamic> post) async {
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/removeConnection'),
          headers: <String, String>{
            'Accept': 'application/json',
            //'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));
    return FollowResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeResponse> unlikePost(
      String token, Map<String, dynamic> post) async {
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/unlike_it'),
          headers: <String, String>{
            'Accept': 'application/json',
            //'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));
    return LikeResponse.fromJson(jsonDecode(response.body));
  }

  Future<NewCreateCommentsResponse> createComments(
      String token, Map<String, dynamic> post) async {
    print("This is comment ${post}");
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/createPost'),
          headers: <String, String>{
            'Accept': 'application/json',
            //'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    return NewCreateCommentsResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteCommentResponse> deleteComment(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/removeComment/'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return DeleteCommentResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteFeedResponse> deleteFeed(
      String token, Map<String, dynamic> post) async {
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(
          Uri.parse(baseUrl + 'townhall/removePost/'),
          headers: <String, String>{
            'Accept': 'application/json',
            //'Content-Type': 'application/json; charset=UTF-8',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': token
          },
          body: encodedFormData,
        )
        .timeout(Duration(seconds: 60));

    debugPrint(response.reasonPhrase);
    return DeleteFeedResponse.fromJson(jsonDecode(response.body));
  }

  Future<ProfileUpdateResponse> updateProfile(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'profile/update_profile/'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return ProfileUpdateResponse.fromJson(jsonDecode(response.body));
  }

  Future<ProfileImageResponse> updateProfileImage(token, File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + 'townhall/update_profile_picture_2'),
    );
    request.headers['Authorization'] = '$token';
    var multipartFile = await http.MultipartFile.fromPath(
      'files[0]',
      image.path,
    );
    request.files.add(multipartFile);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse)
        .timeout(Duration(seconds: 60));
    print(response.body);
    return ProfileImageResponse.fromJson(jsonDecode(response.body));
  }

  Future<FeedResponse> feed(String token, orgID, groupID, page, limit,
      olderOrNewer, pageOwner, deviceToken) async {
    print(
        "rGroup: Org:${orgID} group:${groupID}  limit:${limit} page:${page}  ${olderOrNewer} ${pageOwner} ${deviceToken} ");
    var response = await http.get(
      Uri.parse(baseUrl +
          'townhall/fetch_posts?org_id=$orgID&group_id=$groupID&page=$page&limit=$limit&older_or_newer=$olderOrNewer&page_owner=$pageOwner&device_token=$deviceToken'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    debugPrint("Res " + response.body);
    return FeedResponse.fromJson(jsonDecode(response.body));
  }

  Future<TopFeedResponse> topFeed(String token, orgID) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/myGroups2?org_id=${orgID}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
    ).timeout(Duration(seconds: 60));

    return TopFeedResponse.fromJson(jsonDecode(response.body));
  }

  Future<TownhallInfoResponse> getTownhallInfo(
      String token, orgID, townhallID, isThisMore) async {
    print("Just called");
    var response = await http.get(
      Uri.parse(baseUrl +
          'townhall/fetch_townhall_info?org_id=$orgID&townhall_id=$townhallID&is_this_a_more=$isThisMore'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    print(response.body);
    return TownhallInfoResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreateCustomOrganizationTempResponse> getCustomTempOrg(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/create_temp_org'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return CreateCustomOrganizationTempResponse.fromJson(
        jsonDecode(response.body));
  }

  // deep link organization details
  Future<OrganizationDetailsResponse> deepLinkOrgDetails(keyword) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'visitor/org_details?keyword=$keyword'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return OrganizationDetailsResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreateCustomOrganizationChildResponse> createTownhallChild(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/create_townhall_child'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    debugPrint(response.body);
    return CreateCustomOrganizationChildResponse.fromJson(
        jsonDecode(response.body));
  }

  Future<DeleteCustomOrganizationResponse> deleteCustomTownhall(
      String token, Map<String, dynamic> post) async {
    print("new Post  $post");
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/delete_townhall'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return DeleteCustomOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<RenameCustomOrganizationResponse> renameCustomTownhall(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/rename_townhall'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return RenameCustomOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationResponse> getMyJoinedOrganization(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/orgs_user_joined'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return OrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationPlanResponse> getOrganizationPlan(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/org_plans'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return OrganizationPlanResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationTreeResponse> getOrganizationTree(
      String token, orgID, tree) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/org_tree?org_id=$orgID&tree=$tree'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return OrganizationTreeResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationCCFResponse> getCCF(String token, townhallID) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/get_children_for_ccf?townhall_id=$townhallID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return OrganizationCCFResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateUsersTownhallsResponse> updateUsersTownhalls(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/update_users_townhalls'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return UpdateUsersTownhallsResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationInterestResponse> getInterest(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_interests'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return OrganizationInterestResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateOrganizationBannerResponse> updateOrgBanner(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/update_banner_image'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return UpdateOrganizationBannerResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateOrganizationLogoResponse> updateOrgLogo(
      String token, Map<String, dynamic> post) async {
    print(post);
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/update_logo_image'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return UpdateOrganizationLogoResponse.fromJson(jsonDecode(response.body));
  }

  Future<MyOrganizationResponse> myOrganizations(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/orgs_user_manages'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return MyOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteOrganizationResponse> deleteOrg(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/delete_org'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return DeleteOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<OrganizationResponse> getOrganizationSuggestion(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/onboarding_suggested_orgs'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return OrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<SearchOrganizationResponse> getOrganizationSearch(
      String token, term, interestID) async {
    var response = await http.get(
      Uri.parse(
          baseUrl + 'townhall/search_orgs?term=$term&interest_id=$interestID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return SearchOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreateOrganizationResponse> createOrganization_old(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/create_org'),
          headers: <String, String>{
            //'Accept': 'application/json',
            // 'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    debugPrint("${response.body}");
    return CreateOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreateOrganizationResponse> createOrganization(
      String token, Map<String, dynamic> post) async {
    final response = await http.post(
      Uri.parse('${baseUrl}orgs/create_org'),
      headers: {
        'Authorization': token,
        'Content-Type':
            'application/json', // Ensure the content type is set to JSON
        // 'Apitoken': token,
        // Add other headers if needed
      },
      body: jsonEncode(post), // Encode the post body to JSON
    );
    debugPrint(response.body);
    if (response.statusCode == 200) {
      return CreateOrganizationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create organization');
    }
  }

  Future<DefaultAvailableTWHResponse> defaultAvailableTWH(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/default_available_twh'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return DefaultAvailableTWHResponse.fromJson(jsonDecode(response.body));
  }

  Future<DefaultPostableTWHResponse> defaultPostableTWH(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'orgs/default_postable_twh'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return DefaultPostableTWHResponse.fromJson(jsonDecode(response.body));
  }

  Future<UpdateOrganizationResponse> updateOrganization(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(
          Uri.parse(baseUrl + 'orgs/update_org'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token
          },
          body: jsonEncode(post),
        )
        .timeout(Duration(seconds: 60));
    return UpdateOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<CountriesResponse> getCountries() async {
    print("Am here");
    var response = await http.get(
      Uri.parse(baseUrl + 'locations/countries'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        //'Authorization': token
      },
    );
    debugPrint(response.body);
    return CountriesResponse.fromJson(jsonDecode(response.body));
  }

  Future<LgasResponse> getLgas(String id) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'locations/lga/${id}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        //'Authorization': token
      },
    );
    return LgasResponse.fromJson(jsonDecode(response.body));
  }

  Future<WardsResponse> getWards(String id) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'locations/wards/${id}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        //'Authorization': token
      },
    );
    return WardsResponse.fromJson(jsonDecode(response.body));
  }

  Future<GetProfileResponse> getProfile(String token) async {
    print("Am inside the profile api");
    var response = await http.get(
      Uri.parse(baseUrl + 'profile/fetch_user_profile'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    debugPrint(response.body);
    return GetProfileResponse.fromJson(jsonDecode(response.body));
  }

  Future<GetSubjectProfileResponse> getSubjectProfile(
      String token, subJectID) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'profile/get_profile?subjects_id=$subJectID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return GetSubjectProfileResponse.fromJson(jsonDecode(response.body));
  }

  Future<NotificationsResponse> notifications(
      String token, last_row_id, limit) async {
    var response = await http.get(
      Uri.parse(baseUrl +
              'townhall/fetch_notifications?last_row_id=${last_row_id}&limit=${limit}')
          .replace(),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    print(jsonDecode(response.body));
    return NotificationsResponse.fromJson(jsonDecode(response.body));
  }

  Future<NoticeBoardResponse> showNoticeBoard(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/noticeboard_details'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return NoticeBoardResponse.fromJson(jsonDecode(response.body));
  }

  Future<CommentsResponse> comments(
      String token, String post_id, String limit, String direction) async {
    var response = await http.get(
      Uri.parse(baseUrl +
          'townhall/myComments?post_id=${post_id}&limit=${limit}&direction=${direction}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    print(response.body);
    return CommentsResponse.fromJson(jsonDecode(response.body));
  }

  Future<FeedResponse> getPostComments(
      String token,
      String post_id,
      String limit,
      String orderBy,
      String page,
      String multidimensional) async {
    //'townhall/fetch_posts?org_id=$orgID&group_id=$groupID&page=$page&limit=$limit&older_or_newer=$olderOrNewer&page_owner=$pageOwner&device_token=$deviceToken'
    final orgID = await AppSharedPreferences.getValue(key: 'orgID');
    final groupID = await AppSharedPreferences.getValue(key: 'groupID');
    print(
        "post_idz: ${post_id} limit: ${limit} orderBy: ${orderBy} page: ${page} multi: ${multidimensional}");
    var response = await http.get(
      Uri.parse(baseUrl +
          'townhall/fetch_posts?parent_id=${post_id}&limit=${limit}&group_id=$groupID&org_id=$orgID'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    print("post_idz: " + response.body);
    return FeedResponse.fromJson(jsonDecode(response.body));
  }

  Future<ProfessionResponse> getProfessions(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'profile/list_of_professions'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return ProfessionResponse.fromJson(jsonDecode(response.body));
  }

  Future<QualificationResponse> getQualifications(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'profile/edu_levels'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return QualificationResponse.fromJson(jsonDecode(response.body));
  }

  Future<FeedDetailsResponse> getPostDetails(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/post_details')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    debugPrint("Post Details: ${response.body}");
    return FeedDetailsResponse.fromJson(jsonDecode(response.body));
  }

  Future<TermResponse> getTerms() async {
    print("Starting Live");
    _client = http.Client();
    final response = await retry(
      () => _client.get(
        Uri.parse(baseUrl + 'user/fetch_terms_and_conditions'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Cache-Control': 'no-cache'
        },
      ).timeout(Duration(seconds: 30)),
      maxAttempts: maxRetries,
      retryIf: (e) => e is SocketException || e is TimeoutException,
      delayFactor: Duration(seconds: 0),
    );
    print("Live: ${response.body.substring(1, 20)}");
    _client.close();
    return TermResponse.fromJson(jsonDecode(response.body));
  }

  Future<PrivacyResponse> getPrivacy() async {
    _client = http.Client();
    final response = await retry(
      () => _client.get(
        Uri.parse(baseUrl + 'user/privacy_policy'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Cache-Control': 'no-cache'
        },
      ).timeout(Duration(seconds: 30)),
      maxAttempts: maxRetries,
      retryIf: (e) => e is SocketException || e is TimeoutException,
      delayFactor: Duration(seconds: 0),
    );
    _client.close();

    return PrivacyResponse.fromJson(jsonDecode(response.body));
  }

  // Future<void> getProducts() async {
  //   print("Starting Ext");
  //   _client = http.Client();
  //   final response = await retry(
  //     () => _client.get(
  //       Uri.parse('https://dummyjson.com/carts'),
  //       headers: <String, String>{
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Cache-Control': 'no-cache'
  //       },
  //     ).timeout(Duration(seconds: 30)),
  //     maxAttempts: maxRetries,
  //     retryIf: (e) => e is SocketException || e is TimeoutException,
  //     delayFactor: Duration(seconds: 0),
  //   );
  //   print("EXT: ${response.body.substring(1, 20)}");
  //   _client.close();
  // }

  // Future<void> getTerms2() async {
  //   print("Starting Empl");
  //   _client = http.Client();
  //   final response = await retry(
  //     () => _client.get(
  //       Uri.parse(
  //           'https://townhall.empl-dev.site/user/fetch_terms_and_conditions'),
  //       headers: <String, String>{
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Cache-Control': 'no-cache'
  //       },
  //     ).timeout(Duration(seconds: 30)),
  //     maxAttempts: maxRetries,
  //     retryIf: (e) => e is SocketException || e is TimeoutException,
  //     delayFactor: Duration(seconds: 0),
  //   );
  //   _client.close();
  //   print("EMPL: ${response.body.substring(1, 20)}");
  // }

  Future<EventsResponse> fetchEvent() async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_events'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        //'Authorization': token
      },
    );
    return EventsResponse.fromJson(jsonDecode(response.body));
  }

  Future<ReportAbuseResponse> reportAbuse(
      String token, Map<String, dynamic> post) async {
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/report_abuse'),
            headers: <String, String>{
              'Accept': 'application/json',
              //'Content-Type': 'application/json; charset=UTF-8',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token
            },
            body: encodedFormData)
        .timeout(Duration(seconds: 60));
    print("Report: ${response.body}");
    return ReportAbuseResponse.fromJson(jsonDecode(response.body));
  }

  Future<BlockUserResponse> blockUser(
      String token, Map<String, dynamic> post) async {
    print("Block am inside block");
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/block_unblock_user'),
            headers: <String, String>{
              'Accept': 'application/json',
              //'Content-Type': 'application/json; charset=UTF-8',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token
            },
            body: encodedFormData)
        .timeout(Duration(seconds: 60));
    print("Block ${response.body}");
    return BlockUserResponse.fromJson(jsonDecode(response.body));
  }

  Future<PartyResponse> getParties(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_political_parties')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return PartyResponse.fromJson(jsonDecode(response.body));
  }

  Future<SearchPollingUnitResponse> getPollingUnites(
      String token, int id) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'locations/polling_units/${id}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return SearchPollingUnitResponse.fromJson(jsonDecode(response.body));
  }

  Future<PollCastResponse> pollCast(
      String token, Map<String, dynamic> post) async {
    var encodedFormData = post.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/castvote'),
            headers: <String, String>{
              'Accept': 'application/json',
              // 'Content-Type': 'application/json; charset=UTF-8',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token
            },
            body: encodedFormData)
        .timeout(Duration(seconds: 60));
    return PollCastResponse.fromJson(jsonDecode(response.body));
  }

  Future<JoinOrganizationResponse> joinOrganization(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/join_org'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    print(response.body);
    return JoinOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<PinResponse> pinToTop(String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/pin_to_top'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return PinResponse.fromJson(jsonDecode(response.body));
  }

  Future<UnpinResponse> unPinToTop(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/unpin_from_top'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return UnpinResponse.fromJson(jsonDecode(response.body));
  }

  Future<LeaveOrganizationResponse> leaveOrganization(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/leave_org'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return LeaveOrganizationResponse.fromJson(jsonDecode(response.body));
  }

  Future<JoinPollingUnitResponse> addPolling(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/update_pu'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return JoinPollingUnitResponse.fromJson(jsonDecode(response.body));
  }

  Future<CreateEventResponse> createEvent(
      String token, Map<String, dynamic> post) async {
    // var response = await http
    //     .post(Uri.parse(baseUrl + 'townhall/create_event'),
    //         headers: <String, String>{
    //           'Accept': 'application/json',
    //           'Content-Type': 'application/json; charset=UTF-8',
    //           'Authorization': token
    //         },
    //         body: jsonEncode(post))
    //     .timeout(Duration(seconds: 60));
    // return CreateEventResponse.fromJson(jsonDecode(response.body));

    var totalBytesSent = 0;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + 'townhall/create_event'),
    );
    request.headers['Authorization'] = '$token';
    print("message ${post['files'].length}");
    // Add files to the request
    if (post['files'].length > 0) {
      for (int i = 0; i < post['files'].length; i++) {
        var file = post['files'][i];
        var multipartFile = await http.MultipartFile.fromPath(
          'files[$i]',
          file.path,
        );
        request.files.add(multipartFile);
      }
    }
    // Set form fields

    request.fields['event_type'] = post['event_type'];
    request.fields['title'] = post['title'];
    request.fields['desc'] = post['desc'];
    request.fields['meeting_point'] = post['meeting_point'];
    request.fields['event_date'] = post['event_date'];
    request.fields['event_time'] = post['event_time'];
    request.fields['org_id'] = post['org_id'];
    request.fields['townhall_id'] = post['townhall_id'];

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print(response.statusCode);
    print(response.body);
    return CreateEventResponse.fromJson(jsonDecode(response.body));
  }

  Future<EventTypesResponse> getEventTypes(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_event_types'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return EventTypesResponse.fromJson(jsonDecode(response.body));
  }

  Future<AccountDeactivationResponse> deactivateAccount(String token) async {
    var response = await http.post(
      Uri.parse(baseUrl + 'townhall/deactivate_townhall_account'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    ).timeout(Duration(seconds: 60));
    return AccountDeactivationResponse.fromJson(jsonDecode(response.body));
  }

  Future<LandingGroupResponse> getLandingGroup(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/landing_org_and_group'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    print("LandingOrg: " + response.body);
    return LandingGroupResponse.fromJson(jsonDecode(response.body));
  }

  Future<EventDeleteResponse> deleteEvent(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/delete_event'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return EventDeleteResponse.fromJson(jsonDecode(response.body));
  }

  Future<UserOnboardedResponse> getUserOnboarded(
      String token, String deviceToken) async {
    var response = await http.get(
      Uri.parse(
          baseUrl + 'townhall/is_user_onboarded?device_token=${deviceToken}'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    debugPrint(response.body);
    return UserOnboardedResponse.fromJson(jsonDecode(response.body));
  }

  Future<PostChatResponse> postChat(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/send_message'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return PostChatResponse.fromJson(jsonDecode(response.body));
  }

  Future<MessagesResponse> getInboxMessages(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_inbox')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return MessagesResponse.fromJson(jsonDecode(response.body));
  }

  Future<BulbNotificationsResponse> getbulbNotifications(String token) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/bulb_notifications'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return BulbNotificationsResponse.fromJson(jsonDecode(response.body));
  }

  Future<TownhallsLeaderIsResponse> getTownhallsUserIsLeaderIn(
    String token,
  ) async {
    var response = await http.get(
      Uri.parse(
          baseUrl + 'townhall/townhalls_user_is_leader_in?&include_mf=yes'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return TownhallsLeaderIsResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteMessageResponse> deleteMessage(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/delete_message'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return DeleteMessageResponse.fromJson(jsonDecode(response.body));
  }

  Future<DeleteChatHistoryResponse> deleteChatHistory(
      String token, Map<String, dynamic> post) async {
    var response = await http
        .post(Uri.parse(baseUrl + 'townhall/delete_chat_history'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token
            },
            body: jsonEncode(post))
        .timeout(Duration(seconds: 60));
    return DeleteChatHistoryResponse.fromJson(jsonDecode(response.body));
  }

  Future<ChatHistoryResponse> getChatHistories(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/fetch_chat_history')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return ChatHistoryResponse.fromJson(jsonDecode(response.body));
  }

  Future<SocialGroupsResponse> getSocialGroups(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'professions/fetch_social_groups')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return SocialGroupsResponse.fromJson(jsonDecode(response.body));
  }

  Future<FollowersResponse> getFollowers(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/followers')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return FollowersResponse.fromJson(jsonDecode(response.body));
  }

  Future<FolloweesResponse> getFollowees(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/followees')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return FolloweesResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeDetailsResponse> getLikeDetails(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'townhall/like_details')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return LikeDetailsResponse.fromJson(jsonDecode(response.body));
  }

  Future<LikeListResponse> getLikes(
      String token, Map<String, dynamic> params) async {
    var response = await http.get(
      Uri.parse(baseUrl + 'ownhall/list_of_likes')
          .replace(queryParameters: params),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      },
    );
    return LikeListResponse.fromJson(jsonDecode(response.body));
  }
  // @override
  // void dispose() {
  //   _client.close();
  //
  // }
}
