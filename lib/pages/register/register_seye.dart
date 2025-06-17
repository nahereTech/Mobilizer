import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/models/countries/countries_response.dart';
import 'package:mobilizer/models/countries/lgas_response.dart';
import 'package:mobilizer/models/countries/states_response.dart';
import 'package:mobilizer/models/countries/wards_response.dart';
import 'package:mobilizer/models/register/register_request.dart';
import 'package:mobilizer/models/term/term_response.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = 'register_screen';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  //final _controllerUsername = TextEditingController();
  // final _controllerFirstName = TextEditingController();
  // final _controllerLastName = TextEditingController();
  final _controllerEmail = TextEditingController();
  // final _controllerPhone = TextEditingController();
  // final _controllerCountry = TextEditingController();
  // final _controllerState = TextEditingController();
  // final _controllerLocalArea = TextEditingController();
  // final _controllerWard = TextEditingController();
  final _controllerPass = TextEditingController();
  final _controllerConfirmPass = TextEditingController();
  PanelController _pc = new PanelController();
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

  // List<CountriesData> countriesData = [];
  // List<StatesData> statesData = [];
  // List<LgaData> lgasData = [];
  // List<WardData> wardsData = [];

  bool loading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<AuthBloc>(context).add(GetTermsEvent());
      BlocProvider.of<AuthBloc>(context).add(GetPrivacyEvent());
    });
    // Future.delayed(Duration.zero, () {
    //   BlocProvider.of<AuthBloc>(context).add(GetCountriesEvent());
    // });
    super.initState();
  }

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
        panel: _showPanel == "term"
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: size.width - 50,
                              height: 20.0,
                              child: IconButton(
                                  alignment: Alignment.topRight,
                                  icon: Icon(Icons.close, color: Colors.grey),
                                  iconSize: 20.0,
                                  onPressed: () {
                                    _pc.close();
                                  }),
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
                                          fontSize: 15),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 0.5,
                                    color: Colors.black,
                                  ),
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
                                        ? Center(child: Text("No Result"))
                                        : Center(
                                            child: Container(
                                              width: 80.0,
                                              height: 80.0,
                                              child: SpinKitCircle(
                                                color: Colors.blue,
                                                size: 50.0,
                                              ),
                                            ),
                                          )
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        physics: PageScrollPhysics(),
                                        child: HtmlWidget(termData),
                                      ),
                              ),
                            ),
                          ],
                        )
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
                            Column(
                              children: [
                                Container(
                                  width: size.width - 50,
                                  height: 20.0,
                                  child: IconButton(
                                      alignment: Alignment.topRight,
                                      icon:
                                          Icon(Icons.close, color: Colors.grey),
                                      iconSize: 20.0,
                                      onPressed: () {
                                        _pc.close();
                                      }),
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
                                              fontSize: 15),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 0.5,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 10, 20, 0),
                                  child: Container(
                                    height: size.height - 280,
                                    width: size.width - 70,
                                    child: _privacyLoading
                                        ? _privacyNoResult
                                            ? Center(child: Text("No Result"))
                                            : Center(
                                                child: Container(
                                                  width: 80.0,
                                                  height: 80.0,
                                                  child: SpinKitCircle(
                                                    color: Colors.blue,
                                                    size: 50.0,
                                                  ),
                                                ),
                                              )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            physics: PageScrollPhysics(),
                                            child: HtmlWidget(privacyData),
                                          ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
        body: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoadingState) {
                loading = true;
              }

              // if (state is CountriesState) {
              //   loading = false;
              //   print(state.countriesResponse.message);
              //   print(state.countriesResponse.status);
              //   countriesData = state.countriesResponse.data;
              // }

              // if (state is StatesState) {
              //   loading = false;
              //   print(state.statesResponse.message);
              //   print(state.statesResponse.status);
              //   statesData = state.statesResponse.data;
              // }

              // if (state is LgasState) {
              //   loading = false;
              //   print(state.lgasResponse.message);
              //   print(state.lgasResponse.status);
              //   lgasData = state.lgasResponse.data;
              // }

              // if (state is WardsState) {
              //   loading = false;
              //   print(state.wardsResponse.message);
              //   print(state.wardsResponse.status);
              //   wardsData = state.wardsResponse.data;
              // }

              if (state is RegisteredState) {
                loading = false;
                print(state.registerResponse.msg);
                print(state.registerResponse.status);
                final snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('OTP sent to your email address.'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BlocProvider(
                    create: (context) => AuthBloc(),
                    child: RegisterOtpScreen(email: _controllerEmail.text),
                  );
                }));
              }
              if (state is TermState) {
                loading = false;
                setState(() {
                  termData = state.termResponse.data!.terms;
                  _termLoading = false;
                });
                //print(state.termResponse.data!.terms);
              }

              if (state is TermErrorState) {
                setState(() {
                  _termLoading = false;
                });
              }
              if (state is TermNoResultState) {
                setState(() {
                  _termNoResult = true;
                });
              }
              if (state is PrivacyState) {
                loading = false;
                setState(() {
                  privacyData = state.privacyResponse.data!.privacy;
                  _privacyLoading = false;
                });
                //print(state.termResponse.data!.privacy);
                print("Pri: " + privacyData);
              }
              if (state is PrivacyErrorState) {
                setState(() {
                  _privacyLoading = false;
                });
              }
              if (state is PrivacyNoResultState) {
                setState(() {
                  _privacyNoResult = true;
                });
              }
              if (state is ErrorState) {
                loading = false;
                print(state.message);
                final snackBar = SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      state.message.toString(),
                    ));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 36.0, bottom: 16.0, left: 33, right: 33),
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 30.0,
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
                        Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(16.0),
                            //   child: TextFormField(
                            //     keyboardType: TextInputType.text,
                            //     decoration: InputDecoration(
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(15.0)),
                            //         labelText: 'UserName',
                            //         hintText: 'Enter UserName'),
                            //     controller: _controllerUsername,
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please Enter UserName';
                            //       }
                            //       return null;
                            //     },
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(16.0),
                            //   child: TextFormField(
                            //     keyboardType: TextInputType.text,
                            //     decoration: InputDecoration(
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(15.0)),
                            //         labelText: 'First Name',
                            //         hintText: 'Enter First Name'),
                            //     controller: _controllerFirstName,
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please Enter First Name';
                            //       }
                            //       return null;
                            //     },
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(16.0),
                            //   child: TextFormField(
                            //     keyboardType: TextInputType.text,
                            //     decoration: InputDecoration(
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(15.0)),
                            //         labelText: 'Last Name',
                            //         hintText: 'Enter Last Name'),
                            //     controller: _controllerLastName,
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please Enter Last Name';
                            //       }
                            //       return null;
                            //     },
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Email',
                                    hintText: 'Enter Email'),
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
                            // Padding(
                            //   padding: const EdgeInsets.all(16.0),
                            //   child: TextFormField(
                            //     keyboardType: TextInputType.phone,
                            //     decoration: InputDecoration(
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(15.0)),
                            //         labelText: 'Phone',
                            //         hintText: 'Enter Phone'),
                            //     controller: _controllerPhone,
                            //     // validator: (value) {
                            //     //   if (value == null || value.isEmpty) {
                            //     //     return 'Please Enter Phone';
                            //     //   }
                            //     //   if (value.length > 11) {
                            //     //     return 'Enter a valid Phone number';
                            //     //   }
                            //     //   return null;
                            //     // },
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Password',
                                    hintText: 'Enter Password'),
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
                              padding: const EdgeInsets.all(16.0),
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
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Confirm Password',
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
                            
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 16.0, bottom: 16, left: 25, right: 30),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      text:
                                          "By registering you agree to Townhall "),
                                  TextSpan(
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                      text: "Terms of Service",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _showPanel = 'term';
                                          });
                                          _pc.open();
                                        }),
                                  TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      text: " & "),
                                  TextSpan(
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                      text: "Privacy Policy",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _showPanel = 'privacy';
                                          });
                                          _pc.open();
                                        }),
                                ]),
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
                                    ])
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF00AFEF),
                                            // onPrimary: Colors.white,
                                            // backgr: Color(0xFF00AFEF),
                                            minimumSize: Size(80, 50),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              

                                              BlocProvider.of<AuthBloc>(context)
                                                  .add(
                                                RegisterUserEvent(
                                                  registerRequest: RegisterRequest(
                                                      // firstname:
                                                      //     _controllerFirstName.text,
                                                      // lastname: _controllerLastName.text,
                                                      email: _controllerEmail.text,
                                                      // phone: _controllerPhone.text,
                                                      password: _controllerPass.text,
                                                      app_name: 'townhall'
                                                      // username: _controllerUsername.text,
                                                      // country: countryId,
                                                      // state: stateId,
                                                      // lga: lgaId,
                                                      //ward: wardId
                                                      ),
                                                ),
                                              );
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
                              //Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()), // Directly navigate to LoginScreen
                                (Route<dynamic> route) => false, // This removes all previous routes
                              );
                            },
                            child: const Text(
                              'Already have an account? Sign In',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 19,
                              ),
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
      ),
    );
  }
}
