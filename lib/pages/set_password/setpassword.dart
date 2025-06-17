import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/pages/login/login.dart';

class SetPasswordScreen extends StatefulWidget {
  static String routeName = 'set_pass_screen';

  const SetPasswordScreen({Key? key}) : super(key: key);

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerPass = TextEditingController();
  final _controllerConfirmPass = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

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
    final map =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoadingState) {
                loading = true;
              }
              if (state is ForgotPasswordUpdateState) {
                loading = false;
                print(state.forgotPasswordUpdateResponse.msg);
                print(state.forgotPasswordUpdateResponse.status);
                final snackBar =
                    SnackBar(content: Text('Password Updated Successful.'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(showSnack: null)),
                  (Route<dynamic> route) => false,
                );
              }
              if (state is ErrorState) {
                print(state.message);
                loading = false;
                final snackBar =
                    SnackBar(content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      height: 50.0,
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
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30, right: 30, top: 16, bottom: 16),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
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
                                    borderRadius: BorderRadius.circular(15.0)),
                                labelText: 'New Password',
                                hintText: 'Choose Password'),
                            controller: _controllerPass,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              if (value.length < 5) {
                                return 'password length should be more than 5';
                              }
                              return null;
                            },
                            obscureText: _obscurePassword,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30, right: 30, top: 16, bottom: 16),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePasswordConfirm =
                                          !_obscurePasswordConfirm;
                                    });
                                  },
                                  icon: _obscurePasswordConfirm
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
                                    borderRadius: BorderRadius.circular(15.0)),
                                labelText: 'Repeat Password',
                                hintText: 'Enter Confirm Password'),
                            controller: _controllerConfirmPass,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Confirm Password';
                              }
                              if (value.length < 5) {
                                return 'password length should be more than 5';
                              }
                              if (value != _controllerPass.text) {
                                return 'Passwords Do not match';
                              }
                              return null;
                            },
                            obscureText: _obscurePasswordConfirm,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  // onPrimary: Colors.white,
                                  // primary: Color(0xFF00AFEF),
                                  backgroundColor: Color(0xFF00AFEF),
                                  minimumSize: Size(80, 50),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    BlocProvider.of<AuthBloc>(context).add(
                                      UpdatePasswordEvent(
                                          password: _controllerConfirmPass.text,
                                          email: map!['email'],
                                          v_code: map['sort_code']),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Update',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                            PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => const LoginScreen(),
                              transitionsBuilder: (c, anim, a2, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
