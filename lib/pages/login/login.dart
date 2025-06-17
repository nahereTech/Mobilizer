import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/models/login/login_request.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'package:mobilizer/pages/forgot_password/forgotpassword.dart';
import 'package:mobilizer/pages/register/register.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/services/profile_service.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';

class LoginScreen extends StatefulWidget {
  final String? showSnack;

  const LoginScreen({Key? key, this.showSnack}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  String? deviceToken;
  String? deviceType;
  String? backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
    _getDeviceInfo().then((_) {
      setState(() {}); // Ensure UI updates after device info is fetched
    }).catchError((e) {
      print("Error fetching device info: $e");
      setState(() {
        deviceType = 'web';
        deviceToken = 'web_token_${DateTime.now().millisecondsSinceEpoch}';
      });
    });

    // Fetch and display current_org in a SnackBar
    // _showCurrentOrgSnackBar();
  }

  Future<void> _showCurrentOrgSnackBar() async {
    String? currentOrg = await AppSharedPreferences.getValue(key: 'current_org');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentOrg != null
                ? 'Current Organization: $currentOrg'
                : 'No Current Organization Set',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  Future<void> _loadBackgroundImage() async {
    // Fetch the background image URL from SharedPreferences
    String? imageUrl = await AppSharedPreferences.getValue(key: 'presentation_org_bg');
    print("sadf: ${imageUrl}");
    setState(() {
      backgroundImageUrl = imageUrl ??
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/6980fb4b-1bc4-4be4-eb06-93b39e6fb000/public';
    });
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceType = 'android';
        deviceToken = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceType = 'ios';
        deviceToken = iosInfo.identifierForVendor;
      } else {
        deviceType = 'web';
        deviceToken = 'web_token_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print("Error in _getDeviceInfo: $e");
      deviceType = 'web';
      deviceToken = 'web_token_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _login() async {
    await _getDeviceInfo();
    if (_formKey.currentState!.validate() && deviceType != null && deviceToken != null) {
      setState(() {
        loading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${base_url}user/login'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'email': _controllerEmail.text,
            'password': _controllerPass.text,
            'device_type': deviceType!,
            'device_token': deviceToken!,
          },
        );

        setState(() {
          loading = false;
        });

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['status'] == true) {
            await AppSharedPreferences.setValue(
                key: 'user_id', value: responseData['data']['user_id'].toString());
            await AppSharedPreferences.setValue(
              key: 'firstname',
              value: responseData['data']['firstname'] ?? ''
            );
            await AppSharedPreferences.setValue(
              key: 'lastname',
              value: responseData['data']['lastname'] ?? ''
            );
            await AppSharedPreferences.setValue(
              key: 'username',
              value: responseData['data']['username'] ?? ''
            );
            await AppSharedPreferences.setValue(
                key: 'profile_photo', value: responseData['data']['photo_path']);
            await AppSharedPreferences.setValue(
                key: 'token', value: responseData['data']['token']);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FeedOutsidePage()),
            );
          } else {
            if (responseData['tag'] == 'confirm_email') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterOtpScreen(email: _controllerEmail.text),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    responseData['msg'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          throw Exception('Failed to login');
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to determine device information.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                            'Login',
                            style: TextStyle(
                              fontSize: 24, // Adjust size as needed
                              fontWeight: FontWeight.bold, // Optional
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, top: 16, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background for input
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                labelText: 'Email',
                                hintText: 'Enter email',
                              ),
                              controller: _controllerEmail,
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
                          Padding(
                            padding: EdgeInsets.only(
                                left: 30, right: 30, top: 16, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background for input
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: _obscurePassword
                                      ? Icon(Icons.visibility_off, color: Colors.grey)
                                      : Icon(Icons.visibility, color: Colors.grey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                labelText: 'Password',
                                hintText: 'Enter Password',
                              ),
                              controller: _controllerPass,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Password';
                                }
                                return null;
                              },
                              obscureText: _obscurePassword,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 30, right: 30, top: 16, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(''),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 18, right: 18, top: 16, bottom: 16),
                        child: loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.blue,
                                    strokeWidth: 5.0,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton(
                                        onPressed: _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00AFEF),
                                          minimumSize: Size(80, 50),
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 16),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.all(Radius.circular(10)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Sign In',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()));
                            },
                            child: const Text(
                              'Don\'t have an account? Sign Up.',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.white),
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
      ),
    );
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPass.dispose();
    super.dispose();
  }
}