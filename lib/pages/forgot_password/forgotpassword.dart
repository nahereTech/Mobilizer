import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/forgot_password_otp/forgotpasswordotp.dart';
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  static String routeName = 'forgot_pass_screen';
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  bool loading = false;
  String? backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    // Fetch the background image URL from SharedPreferences
    String? imageUrl = await AppSharedPreferences.getValue(key: 'presentation_org_bg');
    print("Background image URL: $imageUrl");
    setState(() {
      backgroundImageUrl = imageUrl ??
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/6980fb4b-1bc4-4be4-eb06-93b39e6fb000/public';
    });
  }

  // Function to handle the forgot password API call
  Future<void> _resetPassword(String email) async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${base_url}user/forgot_password'), // Replace with actual API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email_address': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 200 || data['status'] == "200") {
          // Success: Navigate to OTP screen
          print(data['msg']);
          Navigator.pushReplacementNamed(
            context,
            ForgotPasswordOtp.routeName,
            arguments: email,
          );
        } else {
          // Error from API
          _showErrorSnackBar(data['msg'] ?? 'Failed to send reset request');
        }
      } else {
        // HTTP error
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Network or other error
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Helper function to show error SnackBar
  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to set system UI overlay style based on theme
  void _setSystemUIOverlayStyle(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Set the system UI overlay style based on the theme
    _setSystemUIOverlayStyle(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image with tint
          if (backgroundImageUrl != null)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(backgroundImageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // Apply tint
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          // Main content
          Form(
            key: _formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 200.0),
                    Center(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: TextFormField(
                            controller: _controllerEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              labelText: 'Email',
                              hintText: 'Please Enter Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Email';
                              }
                              var emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'Please Enter Valid Email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                      child: loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80.0,
                                  height: 80.0,
                                  child: const SpinKitCircle(
                                    color: Colors.blue,
                                    size: 50.0,
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00AFEF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _resetPassword(_controllerEmail.text);
                                }
                              },
                              child: const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigation.back(context);
                        },
                        child: const Text(
                          "I now remember my password",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    super.dispose();
  }
}