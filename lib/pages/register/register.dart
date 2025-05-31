import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/common/common/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mobilizer/common/common/sharepreference.dart'; // Import SharedPreferences
import 'package:mobilizer/common/common/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = 'register_screen';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  final _controllerConfirmPass = TextEditingController();
  PanelController _pc = PanelController();
  bool _hasAgreed = false;
  bool _termLoading = true;
  bool _privacyLoading = true;
  bool _termNoResult = false;
  bool _privacyNoResult = false;
  String termData = "";
  String _showPanel = "";
  String privacyData = "";
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool loading = false;
  String? backgroundImageUrl; // Add variable for background image

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage(); // Load background image
    Future.delayed(Duration.zero, () {
      _fetchTerms();
      _fetchPrivacy();
    });
  }

  Future<void> _loadBackgroundImage() async {
    // Fetch the background image URL from SharedPreferences
    String? imageUrl = await AppSharedPreferences.getValue(key: 'presentation_org_bg');
    print("Background Image URL: $imageUrl");
    setState(() {
      backgroundImageUrl = imageUrl ??
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/6980fb4b-1bc4-4be4-eb06-93b39e6fb000/public';
    });
  }

  Future<void> _fetchTerms() async {
    setState(() {
      _termLoading = true;
    });
    try {
      final uri = Uri.parse('${base_url}user/fetch_terms_and_conditions');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "200") {
          setState(() {
            termData = jsonData['data']['terms'];
            _termLoading = false;
          });
        } else {
          throw Exception('Failed to load terms: ${jsonData['msg']}');
        }
      } else {
        throw Exception('Failed to load terms: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _termLoading = false;
        _termNoResult = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to load terms: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _fetchPrivacy() async {
    setState(() {
      _privacyLoading = true;
    });
    try {
      final uri = Uri.parse('${base_url}user/privacy_policy');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          setState(() {
            privacyData = jsonData['data']['privacy'];
            _privacyLoading = false;
          });
        } else {
          throw Exception('Failed to load privacy policy: ${jsonData['msg']}');
        }
      } else {
        throw Exception('Failed to load privacy policy: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _privacyLoading = false;
        _privacyNoResult = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to load privacy policy: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _registerUser() async {
    setState(() {
      loading = true;
    });

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final uri = Uri.parse('${base_url}user/register');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: {
          'email': _controllerEmail.text,
          'password': _controllerPass.text,
        },
      );

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('OTP sent to your email address.'),
            ),
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterOtpScreen(email: _controllerEmail.text),
            ),
          );
        } else {
          final errorMessage = jsonData['msg'] ?? 'Registration failed';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(errorMessage),
            ),
          );
        }
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Registration failed: ${e.toString()}'),
        ),
      );
    }
  }

  // Method to set system UI overlay style based on theme
  void _setSystemUIOverlayStyle(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Apply the system UI overlay style dynamically
    _setSystemUIOverlayStyle(context);

    Size size = MediaQuery.of(context).size;
    return Material(
      child: SlidingUpPanel(
        minHeight: 0.0,
        maxHeight: size.height - 150,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        controller: _pc,
        backdropEnabled: true,
        panel: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor, // Use theme's background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: _showPanel == "term"
              ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
                      child: Column(
                        children: [
                          Container(
                            width: size.width - 50,
                            height: 20.0,
                            child: IconButton(
                              alignment: Alignment.topRight,
                              icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                              iconSize: 20.0,
                              onPressed: () => _pc.close(),
                            ),
                          ),
                          Container(
                            width: size.width - 50,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Theme.of(context).textTheme.bodyLarge!.color, // Theme-based text color
                                    ),
                                  ),
                                ),
                                Divider(thickness: 0.5, color: Theme.of(context).dividerColor), // Theme-based divider color
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 20, 0),
                            child: Container(
                              height: size.height - 280,
                              width: size.width - 70,
                              child: _termLoading
                                  ? _termNoResult
                                      ? Center(
                                          child: Text(
                                            "No Result",
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.bodyLarge!.color, // Theme-based text color
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Container(
                                            width: 80.0,
                                            height: 80.0,
                                            child: SpinKitCircle(
                                              color: Theme.of(context).primaryColor, // Theme-based spinner color
                                              size: 50.0,
                                            ),
                                          ),
                                        )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      physics: PageScrollPhysics(),
                                      child: HtmlWidget(
                                        termData,
                                        textStyle: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge!.color, // Use theme's text color
                                          fontSize: 16.0,
                                        ),
                                        customStylesBuilder: (element) {
                                          return {
                                            'color': Theme.of(context).textTheme.bodyLarge!.color!.value.toRadixString(16).substring(2), // Convert to hex
                                          };
                                        },
                                        onErrorBuilder: (context, element, error) => Text(
                                          'Error loading content',
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _showPanel == "privacy"
                  ? Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
                          child: Column(
                            children: [
                              Container(
                                width: size.width - 50,
                                height: 20.0,
                                child: IconButton(
                                  alignment: Alignment.topRight,
                                  icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                                  iconSize: 20.0,
                                  onPressed: () => _pc.close(),
                                ),
                              ),
                              Container(
                                width: size.width - 50,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context).textTheme.bodyLarge!.color, // Theme-based text color
                                        ),
                                      ),
                                    ),
                                    Divider(thickness: 0.5, color: Theme.of(context).dividerColor), // Theme-based divider color
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 10, 20, 0),
                                child: Container(
                                  height: size.height - 280,
                                  width: size.width - 70,
                                  child: _privacyLoading
                                      ? _privacyNoResult
                                          ? Center(
                                              child: Text(
                                                "No Result",
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyLarge!.color, // Theme-based text color
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Container(
                                                width: 80.0,
                                                height: 80.0,
                                                child: SpinKitCircle(
                                                  color: Theme.of(context).primaryColor, // Theme-based spinner color
                                                  size: 50.0,
                                                ),
                                              ),
                                            )
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          physics: PageScrollPhysics(),
                                          child: HtmlWidget(
                                            privacyData,
                                            textStyle: TextStyle(
                                              color: Theme.of(context).textTheme.bodyLarge!.color, // Use theme's text color
                                              fontSize: 16.0,
                                            ),
                                            customStylesBuilder: (element) {
                                              return {
                                                'color': Theme.of(context).textTheme.bodyLarge!.color!.value.toRadixString(16).substring(2), // Convert to hex
                                              };
                                            },
                                            onErrorBuilder: (context, element, error) => Text(
                                              'Error loading content',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
        ),
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
            Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent, // Make Scaffold transparent to show background
              body: Form(
                key: _formKey,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 36.0, bottom: 16.0, left: 33, right: 33),
                    child: ListView(
                      children: [
                        const SizedBox(height: 50.0), // Adjusted spacing for logo
                        // Container(
                        //   height: 50,
                        //   width: 50,
                        //   alignment: Alignment.center,
                        //   child: Image.asset(
                        //     "images/icon_blue.png",
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                        const SizedBox(height: 30.0),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  labelText: 'Email',
                                  hintText: 'Enter Email',
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
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background
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
                                  if (value.length < 5) {
                                    return 'Password length should be more than 5';
                                  }
                                  return null;
                                },
                                obscureText: _obscurePassword,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8), // Semi-transparent background
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePasswordConfirm = !_obscurePasswordConfirm;
                                      });
                                    },
                                    icon: _obscurePasswordConfirm
                                        ? Icon(Icons.visibility_off, color: Colors.grey)
                                        : Icon(Icons.visibility, color: Colors.grey),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  labelText: 'Confirm Password',
                                  hintText: 'Enter Confirm Password',
                                ),
                                controller: _controllerConfirmPass,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Confirm Password';
                                  }
                                  if (value.length < 5) {
                                    return 'Password length should be more than 5';
                                  }
                                  if (value != _controllerPass.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                obscureText: _obscurePasswordConfirm,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16, left: 25, right: 30),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white, // Changed to white for visibility on tinted background
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "By registering you agree to Townhall ",
                                    ),
                                    TextSpan(
                                      text: "Terms of Service",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _showPanel = 'term';
                                          });
                                          _pc.open();
                                        },
                                    ),
                                    TextSpan(
                                      text: " & ",
                                    ),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _showPanel = 'privacy';
                                          });
                                          _pc.open();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: loading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF00AFEF),
                                            minimumSize: Size(80, 50),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              _registerUser();
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text(
                                'Already have an account? Sign In',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 19,
                                  color: Colors.white, // Changed to white for visibility
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    _controllerConfirmPass.dispose();
    super.dispose();
  }
}