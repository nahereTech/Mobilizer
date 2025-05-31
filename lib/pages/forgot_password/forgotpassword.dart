import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/pages/forgot_password_otp/forgotpasswordotp.dart';

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
              if (state is ForgotPasswordState) {
                loading = false;
                print(state.forgotPasswordResponse.msg);
                print(state.forgotPasswordResponse.status);
                Navigator.pushReplacementNamed(
                    context, ForgotPasswordOtp.routeName,
                    arguments: _controllerEmail.text);
              }
              if (state is ErrorState) {
                loading = false;
                print(state.message);
                final snackBar =
                    SnackBar(content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        alignment: Alignment.center, // This is needed
                        child: Image.asset(
                          'images/icon_blue.png',
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: TextFormField(
                              controller: _controllerEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  labelText: 'Email',
                                  hintText: 'Please Enter Email'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: loading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  : ElevatedButton(
                                      style: raisedButtonStyleGreen,
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          BlocProvider.of<AuthBloc>(context)
                                              .add(
                                            ForgotPasswordEvent(
                                              email_address:
                                                  _controllerEmail.text,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20.0),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigation.back(context);
                          },
                          child: Text("I now remember my password"),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
