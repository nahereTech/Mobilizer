import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:http/http.dart' as http;

class RegisterOtpScreen extends StatefulWidget {
  static String routeName = 'register_otp_screen';
  final String email;
  const RegisterOtpScreen({required this.email, Key? key}) : super(key: key);

  @override
  _RegisterOtpScreenState createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _controllerCode = TextEditingController();
  bool loading = false;
  bool loadingOTP = false;

  Future<void> _verifyOtp(String email, String code) async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${base_url}user/confirm_email_then_log_user_in'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        final String? newToken = responseData['data']['token'];

        // Get existing token using the required `key` parameter
        final String? existingToken = await AppSharedPreferences.getValue(key: 'token');

        // Hold on to whichever token is available
        final String tempToken = existingToken ?? newToken ?? '';

        // Directly use SharedPreferences to clear all
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Restore token if it exists
        if (tempToken.isNotEmpty) {
          await prefs.setString('token', tempToken);
        }

        // Store profile picture using your wrapper method
        await AppSharedPreferences.setValue(
          key: 'profilePic',
          value: responseData['data']['photo_path'] ??
              'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid',
        );

        // Navigate to profile onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
          (Route<dynamic> route) => false,
        );
      } else {
        final snackBar = SnackBar(
          content: Text(responseData['msg'] ?? 'An error occurred'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }



  Future<void> _requestOtp(String email) async {
    setState(() {
      loadingOTP = true;
    });

    try {
      // Add your endpoint for requesting OTP if available
      // For now, I'll assume it's a similar endpoint
      final response = await http.post(
        Uri.parse('${base_url}user/request_otp_endpoint'), // Replace with actual endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        final snackBar = SnackBar(
          content: Text('OTP was successfully sent'),
          backgroundColor: Colors.green.shade300,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
          content: Text(responseData['msg'] ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        loadingOTP = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldkey,
        body: Form(
          key: _formKey,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "images/icon_blue.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Text(
                          'Please input the code sent to your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                      ),
                    ),
                    if (loading)
                      Container(
                        width: 80.0,
                        height: 80.0,
                        child: SpinKitCircle(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 50, right: 50, top: 16, bottom: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          hintText: 'Enter code',
                        ),
                        controller: _controllerCode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Code';
                          }
                          var codeValid = RegExp(r"^[a-zA-Z0-9]+").hasMatch(value);
                          if (!codeValid) {
                            return 'Please Enter Valid Code';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: loadingOTP
                            ? SpinKitWave(
                                color: Colors.grey,
                                size: 15.0,
                              )
                            : GestureDetector(
                                onTap: () => _requestOtp(widget.email),
                                child: Text(
                                  "Didn't receive a code?",
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: ElevatedButton(
                        onPressed: loading || loadingOTP
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _verifyOtp(widget.email, _controllerCode.text);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00AFEF),
                          minimumSize: Size(80, 50),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            loading
                                ? SpinKitWave(
                                    color: Colors.grey,
                                    size: 15.0,
                                  )
                                : Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text(
                          "Back To Login",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}