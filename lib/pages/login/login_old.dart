import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as post;
import 'package:mobilizer/bloc/search/organization_bloc.dart' as org;
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/login/login_request.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/forgot_password/forgotpassword.dart';
import 'package:mobilizer/pages/joinorg/joinorg_page.dart';
//import 'package:mobilizer/pages/register2/register2.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_snackbar/timer_snackbar.dart';
import '../profile/profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = 'login_screen';
  final String? showSnack;

  const LoginScreen({Key? key, @required this.showSnack}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  // ConnectivityResult _connectionStatus = ConnectivityResult.none;
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  // @override
  // void initState() {
  //   if (widget.showSnack != null) {
  //     timerSnackbar(
  //       context: context,
  //       contentText: "A snackbar with live timer.",
  //       // buttonPrefixWidget: Image.asset(
  //       //   'assets/undo.png',
  //       //   width: 17.0,
  //       //   height: 15.0,
  //       //   alignment: Alignment.topCenter,
  //       //   color: Colors.blue[100],
  //       // ),
  //       afterTimeExecute: () => print("Operation Execute."),
  //       second: 5,
  //     );
  //   } // TODO: implement initState
  //   super.initState();
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initConnectivity();

    // // _connectivitySubscription =
    // //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // _connectivitySubscription = _connectivity.onConnectivityChanged
    //     .cast<ConnectivityResult>()
    //     .listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    // _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initConnectivity() async {
  //   //late ConnectivityResult result;
  //   var result = await _connectivity.checkConnectivity();
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     print("Couldn\'t check connectivity status: ${e}");
  //     return;
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) {
  //     return Future.value(null);
  //   }

  //   return _updateConnectionStatus(result.first);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   setState(() {
  //     _connectionStatus = result;
  //   });

  //   print("Connection: ${_connectionStatus.name}");
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Make status bar white
      statusBarIconBrightness: Brightness.dark, // Dark icons on the status bar
      systemNavigationBarColor:
          Colors.white, // Make bottom navigation bar white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Dark icons on the bottom navigation bar
    ));
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LoadingState) {
              loading = true;
            }

            if (state is LoginState) {
              loading = false;
              print(state.loginResponse.msg);
              print(state.loginResponse.status);
              // Navigation.intentWithClearAllRoutes(context, HomeScreen.routeName);
              //Navigation.intentWithClearAllRoutes(context, Feed.routeName);

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MultiBlocProvider(providers: [
                  BlocProvider(
                    create: (context) => post.PostsBloc(),
                  ),
                  BlocProvider(
                    create: (context) => org.OrganizationBloc(),
                  ),
                ], child: Feed());
              }));
            }
            if (state is GoToOTPState) {
              loading = false;
              Navigator.pushReplacementNamed(
                  context, RegisterOtpScreen.routeName,
                  arguments: _controllerEmail.text);
            }
            if (state is GoToProfileState) {
              loading = false;
              print('Am inside profile page');
              Navigation.intentWithClearAllRoutes(context, Profile.routeName);
            }
            if (state is ErrorState) {
              print(state.message);
              loading = false;
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is NetworkState) {
              loading = false;
              print(state.message);
              loading = false;
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 150.0,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center, // This is needed
                        child: Image.asset(
                          "images/icon_blue.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // if (loading)
                      //   Container(
                      //     width: 80.0,
                      //     height: 80.0,
                      //     child: SpinKitCircle(
                      //       color: Colors.blue,
                      //       size: 50.0,
                      //     ),
                      //   ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, top: 16, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Email',
                                  hintText: 'Enter email'),
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
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: _obscurePassword
                                        ? Icon(
                                            Icons.visibility_off,
                                            color: Colors.grey,
                                          )
                                        : Icon(
                                            Icons.visibility,
                                            color: Colors.grey,
                                          ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Password',
                                  hintText: 'Enter Password'),
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
                                    Navigator.pushNamed(context,
                                        ForgotPasswordScreen.routeName);
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 18, right: 18, top: 16, bottom: 16),
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
                                  ])
                            : Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          if (_formKey.currentState!
                                              .validate()) {
                                            var deviceType = '';
                                            if (Platform.isAndroid) {
                                              deviceType = 'android';
                                            } else if (Platform.isIOS) {
                                              deviceType = 'ios';
                                            } else if (Platform.isLinux) {
                                              deviceType = 'linux';
                                            } else if (Platform.isMacOS) {
                                              deviceType = 'macOS';
                                            } else if (Platform.isWindows) {
                                              deviceType = 'windows';
                                            }

                                            var deviceToken =
                                                await getDeviceToken();
                                            print("Test Device ${deviceToken}");

                                            BlocProvider.of<AuthBloc>(context)
                                                .add(
                                              LoginUserEvent(
                                                loginRequest: LoginRequest(
                                                    email:
                                                        _controllerEmail.text,
                                                    password:
                                                        _controllerPass.text,
                                                    device_type: deviceType,
                                                    app_name: 'townhall',
                                                    device_token: deviceToken),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          // onPrimary: Colors.white,
                                          // primary: Color(0xFF00AFEF),
                                          backgroundColor: Color(0xFF00AFEF),
                                          minimumSize: Size(80, 50),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
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
                            // Navigator.pushNamed(
                            //     context, RegisterScreen.routeName);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => AuthBloc(),
                                  ),
                                ],
                                child: RegisterScreen(),
                              );
                            }));
                          },
                          child: const Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16.0,
                                fontFamily: 'Roboto'),
                          ),
                        )),
                      ),
                      // Center(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text(
                      //       'Term & Conditions',
                      //       style: TextStyle(
                      //         decoration: TextDecoration.underline,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }
}
