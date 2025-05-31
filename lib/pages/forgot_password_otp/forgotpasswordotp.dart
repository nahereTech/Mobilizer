import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/pages/set_password/setpassword.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordOtp extends StatefulWidget {
  static String routeName = 'forgot_pass_otp_screen';

  const ForgotPasswordOtp({Key? key}) : super(key: key);

  @override
  _ForgotPasswordOtpState createState() => _ForgotPasswordOtpState();
}

class _ForgotPasswordOtpState extends State<ForgotPasswordOtp> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: Colors.blue,
    ),
  );
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // Define a decoration for the PIN fields
    final defaultPinTheme = PinTheme(
      width: 60.0,
      height: 60.0,
      textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey),
      ),
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Make status bar white
      statusBarIconBrightness: Brightness.dark, // Dark icons on the status bar
      systemNavigationBarColor:
          Colors.white, // Make bottom navigation bar white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Dark icons on the bottom navigation bar
    ));
    final email = ModalRoute.of(context)!.settings.arguments as String?;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldkey,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LoadingState) {
              loading = true;
            }
            if (state is ForgotPasswordOTPState) {
              loading = false;
              print(state.forgotPasswordOTPResponse.msg);
              print(state.forgotPasswordOTPResponse.status);
              final snackBar =
                  SnackBar(content: Text('Verification Successful.'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Map<String, dynamic> map = Map();
              map["email"] = email;
              map["sort_code"] = _pinPutController.text;
              Navigator.pushReplacementNamed(
                  context, SetPasswordScreen.routeName,
                  arguments: map);
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
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        alignment: Alignment.center, // This is needed
                        child: Image.asset(
                          "images/icon_blue.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'We sent a password retrieval code to your email. Please enter below',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 26),
                          ),
                        ),
                      ),
                    ],
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Pinput(
                      length: 5, // Number of fields
                      focusNode: _pinPutFocusNode,
                      controller: _pinPutController,
                      defaultPinTheme: defaultPinTheme,
                      onCompleted: (pin) {
                        print(pin);
                        print(email);
                        // Trigger your BLoC event
                        BlocProvider.of<AuthBloc>(context).add(
                          ForgotPasswordOTPEvent(sort_code: pin, email: email!),
                        );
                      },
                    ),

                    // PinPut(
                    //   fieldsCount: 5,
                    //   textStyle:
                    //       const TextStyle(fontSize: 25.0, color: Colors.black),
                    //   eachFieldWidth: 60.0,
                    //   eachFieldHeight: 60.0,
                    //   focusNode: _pinPutFocusNode,
                    //   controller: _pinPutController,
                    //   submittedFieldDecoration: pinPutDecoration,
                    //   selectedFieldDecoration: pinPutDecoration,
                    //   followingFieldDecoration: pinPutDecoration,
                    //   pinAnimationType: PinAnimationType.fade,
                    //   onSubmit: (pin) async {
                    //     print(pin);
                    //     print(email);
                    //     BlocProvider.of<AuthBloc>(context).add(
                    //       ForgotPasswordOTPEvent(sort_code: pin, email: email!),
                    //     );
                    //   },
                    // ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
