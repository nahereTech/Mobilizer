import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Import this for TimeoutException
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/common/common/constants.dart';
import '../pages/login/login.dart';
import '../pages/register_otp/registerotp.dart';
import '../pages/profile/profile.dart';
import '../pages/onboarding/onboarding_world_townhalls.dart';
import '../pages/onboarding/onboarding_join_orgs.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() {
    return _instance;
  }

  ProfileService._internal();

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;
  bool _isUserOnboarded = false;
  bool get isUserOnboarded => _isUserOnboarded;

  // Function to check if the user is logged in by validating the token
  Future<bool> checkUserLoggedIn() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? loginToken = prefs.getString('token');

      // If no token exists, user is not logged in
      if (loginToken == null) {
        return false;
      }

      print("asdf " + loginToken);

      final String apiUrl = '${base_url}user/is_token_valid';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': loginToken,
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      // Check if the response status code is 200 and the status is true
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // If the status is not true, return false
        if (responseData['status'] == true) {
          print('valid login token');
          return true;
        } else {
          print('invalid login token');
          return false;
        }
      } else {
        // If the status code isn't 200, return false
        print('issue');
        return false;
      }
    } catch (e) {
      print('Token validation error: $e');
      return false; // If any error occurs, return false
    }
  }

  // Function to check if user has been onboarded
  Future<bool> checkUserOnboarding(BuildContext context, {String? deviceToken}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? loginToken = prefs.getString('token');
      final String? currentOrg = prefs.getString('current_org');

      if (loginToken == null) {
        // No token found, clear shared preferences and redirect to LoginScreen
        await prefs.clear();
        _isUserOnboarded = false;

        // Navigate to LoginScreen and clear the navigation stack
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
        });
        return false;
      }

      // Construct the API URL with query parameters for device_token and current_org if provided
      final String baseApiUrl = '${base_url}townhall/is_user_onboarded';
      final Map<String, String> queryParams = {};
      if (deviceToken != null) {
        queryParams['device_token'] = deviceToken;
      }
      if (currentOrg != null) {
        queryParams['current_org'] = "182"; //currentOrg;
      }
      final String apiUrl = queryParams.isEmpty
          ? baseApiUrl
          : '$baseApiUrl?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': loginToken,
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check the response status and tag
        if (responseData['status'] == true && responseData['tag'] == 'onboarded') {
          print("it is true");
          _isUserOnboarded = true;
          return true;
        } else {
          _isUserOnboarded = false;

          print("it is not true");

          // Handle different failure cases and redirect accordingly
          switch (responseData['tag']) {
            case 'not_logged_in':
              // Clear shared preferences and redirect to LoginScreen
              await prefs.clear();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              });
              break;

            case 'user_unconfirmed':
              // Retrieve the user's email from the endpoint response
              String? userEmail = responseData['email'];
              // Redirect to RegisterOtpScreen with the email (even if it's null)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterOtpScreen(email: userEmail ?? ''),
                  ),
                  (Route<dynamic> route) => false,
                );
              });
              break;

            case 'profile_incomplete':
              // Redirect to Profile screen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                  (Route<dynamic> route) => false,
                );
              });
              break;

            case 'not_following_org':
              // Redirect to OnboardingWorldTownhalls screen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingWorldTownhalls()),
                  (Route<dynamic> route) => false,
                );
              });
              break;

            default:
              _showErrorDialog(context, responseData['msg'] ?? 'Unknown error occurred.');
          }
          return false;
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Onboarding check error: $e');
      _showErrorDialog(context, 'Failed to check onboarding status: $e');
      return false;
    }
  }

  // Handle error dialog display
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Existing methods...
  bool needsProfileCompletion() {
    return !_isProfileComplete;
  }
}