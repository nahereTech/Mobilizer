import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart' as auth;
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart' as search;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/bloc/search/polling_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/countries/countries_response.dart';
import 'package:mobilizer/models/countries/lgas_response.dart';
import 'package:mobilizer/models/countries/states_response.dart';
import 'package:mobilizer/models/countries/wards_response.dart';
import 'package:mobilizer/models/login/login_request.dart';
import 'package:mobilizer/models/organization/organization_details_visitor_response.dart';
import 'package:mobilizer/models/profile/profile_update_request.dart';
import 'package:mobilizer/models/register/register_otp_request.dart';
import 'package:mobilizer/models/register/register_request.dart';
import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/home/home.dart';

// Define the JoinOrgPage widget
class JoinOrgScreen extends StatefulWidget {
  static String routeName = 'joinorg_screen';
  final String orgName;
  const JoinOrgScreen({required this.orgName, super.key});

  @override
  _JoinOrgScreenState createState() => _JoinOrgScreenState();
}

class _JoinOrgScreenState extends State<JoinOrgScreen> {
  String? _userType;
  OrgData? orgData;
  int _step = 0;

  final _controllerPhone = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerCode = TextEditingController();
  final _controllerFirstName = TextEditingController();
  final _controllerLastName = TextEditingController();
  final _controllerUsername = TextEditingController();
  final _controllerGender = TextEditingController();

  bool _isLoading = true;
  bool _hasToken = false;
  bool _isJoining = false;
  bool _isLoadingCountry = false;
  bool _isLoadingState = false;
  bool _isLoadingLGA = false;
  bool _isLoadingWard = false;
  bool _isLoadingPolling = false;
  bool _obscurePassword = true;
  bool _showJoinButton = true;

  List<CountriesData> countriesData = [];
  List<StatesData> statesData = [];

  List<LgaData> lgasData = [];
  List<WardData> wardsData = [];
  List<PollingData> pollingData = [];

  String _selectedGender = '';
  String _selectedStateID = '';
  String _selectedCountryID = '';
  String _selectedLGAID = '';
  String _selectedWardID = '';
  String _selectedPollingID = '';
  String deviceType = '';
  String deviceToken = '';
  int _selectedYear = 0000;
  int _selectedMonth = 00;
  int _selectedDay = 00;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<auth.AuthBloc>(context)
          .add(auth.GetOrgDetailsEvent(keyword: widget.orgName));
      BlocProvider.of<auth.AuthBloc>(context).add(auth.GetCountriesEvent());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get current date
    DateTime now = DateTime.now();
    int currentYear = now.year;

    // Generate lists of days, months, and years
    List<int> days = List.generate(31, (index) => index + 1);
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    List<int> years = List.generate(100, (index) => currentYear - index);

    // Return the scaffold with the image and form
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: BlocConsumer<auth.AuthBloc, auth.AuthState>(
            buildWhen: (previousState, state) {
          return true;
        }, listener: (contextA, state) {
          if (state is auth.RegisteredState) {
            _isJoining = false;
            _step = 1;
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Center(
                  child: Text('Alert'),
                ),
                content: Text(
                  'A code has been sent to ${_controllerEmail.text}. Please enter the code into the box that has been provided at the bottom of the page.',
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // You can add functionality here for the OK button
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (state is auth.RegisterOTPState) {
            _step = 2;
            BlocProvider.of<auth.AuthBloc>(context).add(
              auth.UpdateProfileEvent(
                profileUpdateRequest: ProfileUpdateRequest(
                  username: _controllerUsername.text,
                  about: '',
                  firstname: _controllerFirstName.text,
                  lastname: _controllerLastName.text,
                  phone: '',
                  gender: _selectedGender,
                  dob: _selectedYear.toString() +
                      '-' +
                      _selectedMonth.toString() +
                      '-' +
                      _selectedDay.toString(),
                  edu_level_id: '',
                  profession_category: '',
                  user_profession: '',
                  support_group_id: '',
                  country: _selectedCountryID,
                  state: _selectedStateID,
                  state_origin: _selectedStateID,
                  lga: _selectedLGAID,
                  ward: _selectedWardID,
                  pu: _selectedPollingID,
                  //party: partyID,
                ),
              ),
            );
            AppSharedPreferences.setValue(
                key: 'profilePic',
                value:
                    'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid');
          }

          if (state is auth.RegisterOTPFailState) {
            _isJoining = false;
            _step = 1;
            final snackBar = SnackBar(
                backgroundColor: Colors.red, content: Text("Invalid OTP Code"));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          //verify otp
          if (state is auth.ProfileState) {
            //call join event
            _step = 3;
            BlocProvider.of<auth.AuthBloc>(context)
                .add(auth.JoinEvent(org_id: orgData!.id.toString()));
          }
          if (state is auth.UpdateProfileFailedState) {
            _step = 2;
            _isJoining = false;
            final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is auth.JoinState) {
            setState(() {
              _isJoining = false;
              _showJoinButton = false;
              _step = 4;
            });
            final snackBar = SnackBar(
                duration: Duration(seconds: 5),
                backgroundColor: Colors.green,
                content: Text("Successfully joined"));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            AppSharedPreferences.setValue(
                key: 'orgID', value: orgData!.id.toString());
            AppSharedPreferences.setValue(key: 'orgName', value: orgData!.name);
            AppSharedPreferences.setValue(key: 'groupID', value: '');
            AppSharedPreferences.setValue(key: 'groupName', value: '');
            AppSharedPreferences.setValue(key: 'pageID', value: '0');
            AppSharedPreferences.setValue(key: 'deepLink', value: 'null');
            Future.delayed(Duration(seconds: 5), () async {
              await AppSharedPreferences.setValue(
                  key: 'currentViewedPage', value: 'feed');
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (contextA) => PeopleBloc(),
                    ),
                    BlocProvider(
                      create: (context) => PostsBloc(),
                    ),
                    BlocProvider(create: (context) => OrganizationBloc()),
                  ],
                  child: Feed(),
                );
              }));
            });
          }
          if (state is auth.JoinFailedState) {
            _step = 3;
            _isJoining = false;
            final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: Text("Processing error. Please try again"));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is auth.LoadedOrgDetailsState) {
            print("Org Data: ${state.orgResponse.data}");
            orgData = state.orgResponse.data;
            _isLoading = false;
            _hasToken = state.hasToken;
            _userType = _hasToken == false ? 'new_user' : '';
          }
          if (state is auth.CountriesState) {
            _isLoadingCountry = false;
            countriesData = state.countriesResponse.data;
            print("Country: " + countriesData[0].country_name);
          }
          if (state is auth.StatesState) {
            _isLoadingState = false;
            statesData = state.statesResponse.data;
          }
          if (state is auth.LgasState) {
            _isLoadingLGA = false;
            lgasData = state.lgasResponse.data;
          }
          if (state is auth.WardsState) {
            _isLoadingWard = false;
            wardsData = state.wardsResponse.data;
          }
          if (state is auth.LoadedPollingState) {
            _isLoadingPolling = false;
            pollingData = state.getPollingResponse.data;
          }
          if (state is auth.NetworkState) {
            _isLoading = false;
            _isJoining = false;
            _isLoadingCountry = false;
            _isLoadingState = false;
            _isLoadingLGA = false;
            _isLoadingWard = false;
            _isLoadingPolling = false;
            final snackBar = SnackBar(
                duration: Duration(seconds: 10),
                backgroundColor: Colors.red,
                content: Text('${state.message}'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is auth.GoToOTPState) {
            setState(() {
              _userType = "new_user";
              _step = 1;
              _isJoining = false;
            });
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Center(
                  child: Text('Alert'),
                ),
                content: Text(
                  'A code has been sent to ${_controllerEmail.text}. Please enter the code into the box that has been provided at the bottom of the page.',
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // You can add functionality here for the OK button
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (state is auth.ErrorState) {
            _isLoading = false;
            _isJoining = false;
            _isLoadingCountry = false;
            _isLoadingState = false;
            _isLoadingLGA = false;
            _isLoadingWard = false;
            _isLoadingPolling = false;
            if ((state.status != null && state.status == 401) ||
                (state.status != null && state.status == 400)) {
              final snackBar = SnackBar(
                  duration: Duration(seconds: 10),
                  backgroundColor: Colors.red,
                  content: Text('${state.message}'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }

            setState(() {
              _userType = "new_user";
              _step = 1;
              _isJoining = false;
            });
          }
          if (state is auth.LoginState) {
            //invoke the join endpoint and after joinning show snackbar before login the person
            setState(() {
              _hasToken = true;
            });
            BlocProvider.of<auth.AuthBloc>(context)
                .add(auth.JoinEvent(org_id: orgData!.id.toString()));
          }

          if (state is auth.AlreadyMemberState) {
            _isJoining = false;
            //check if message is contain 'already a member' else 'show the snackback'
            if (state.message == "Already a member") {
              AppSharedPreferences.setValue(
                  key: 'orgID', value: orgData!.id.toString());
              AppSharedPreferences.setValue(
                  key: 'orgName', value: orgData!.name);
              AppSharedPreferences.setValue(key: 'groupID', value: '');
              AppSharedPreferences.setValue(key: 'groupName', value: '');
              AppSharedPreferences.setValue(key: 'pageID', value: '0');
              AppSharedPreferences.setValue(key: 'deepLink', value: 'null');
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BlocProvider(
                  create: (context) => PostsBloc(),
                  child: Feed(),
                );
              })); //
            } else if (state.message == "Incomplete custom profile") {
              //That should open a bottom sheet
            } else {
              final snackBar = SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("You are already a member"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
        }, builder: (context, state) {
          return _isLoading && orgData == null
              ? Center(
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
                  child: Stack(
                    children: [
                      // Image from CDN
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          child: Image.network(
                            '${orgData!.banner}',
                            height: 200, // Adjust height as needed
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Circular box floating above the image
                      Positioned(
                        left: 35,
                        top: 150, // Adjust this value to position the circle
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                              bottomRight: Radius.circular(50.0),
                              topLeft: Radius.circular(50.0),
                              topRight: Radius.circular(50.0),
                            ),
                            child: Image.network(
                              '${orgData!.logo}',
                              // Adjust height as needed
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Padding containing the form fields
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 250, left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${orgData!.name}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '@${orgData!.username}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${orgData!.description}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: _hasToken == false ? 30 : 0),
                            if (_hasToken == false)
                              Text(
                                'Join Our Townhall',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: _hasToken == false ? 20 : 0),

                            // Radio button form
                            if (_hasToken == false)
                              Row(
                                children: [
                                  Radio(
                                    value: 'new_user',
                                    groupValue: _userType,
                                    onChanged: (value) {
                                      setState(() {
                                        _userType = value.toString();
                                      });
                                      print(_userType);
                                    },
                                  ),
                                  Text('New Townhall User'),
                                  const SizedBox(
                                      width: 16), // Add spacing between options
                                  Radio(
                                    value: 'existing_user',
                                    groupValue: _userType,
                                    onChanged: (value) async {
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
                                      var deviceToken = await getDeviceToken();
                                      print("Test Device ${deviceToken}");
                                      setState(() {
                                        _userType = value.toString();
                                        _step = 4;
                                      });
                                      print(_userType);
                                    },
                                  ),
                                  Flexible(child: Text('I have an account')),
                                ],
                              ),

                            SizedBox(height: _hasToken == false ? 15 : 0),
                            if (_hasToken == false)
                              // Form fields
                              TextFormField(
                                controller: _controllerEmail,
                                readOnly: _step >= 1 && _userType == "new_user"
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  enabledBorder: OutlineInputBorder(
                                    // Adding a default border
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(
                                            0.5)), // Faded grey border color
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust border radius as needed
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    // Adding focused border
                                    borderSide: const BorderSide(
                                        color: Colors
                                            .blue), // Highlighted border color
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust border radius as needed
                                  ),
                                ),
                              ),
                            SizedBox(height: _hasToken == false ? 15 : 0),
                            // Other form fields
                            if (_hasToken == false)
                              TextFormField(
                                controller: _controllerPassword,
                                readOnly: _step >= 1 && _userType == "new_user"
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Password',
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
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                              ),
                            const SizedBox(height: 15),
                            //display full form
                            if (_userType == "new_user")
                              Container(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _controllerFirstName,
                                      decoration: InputDecoration(
                                        labelText: 'First Name',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _controllerLastName,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),

                                    TextFormField(
                                      controller: _controllerUsername,
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: _controllerPhone,
                                      decoration: InputDecoration(
                                        labelText: 'Phone',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15), // Date of Birth
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Day field
                                        Flexible(
                                          child: DropdownButtonFormField<int>(
                                            decoration: InputDecoration(
                                              labelText: 'Day',
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            value: null,
                                            items: days.map((int day) {
                                              return DropdownMenuItem<int>(
                                                value: day,
                                                child: Text(day.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (int? value) {
                                              // Add functionality to handle value change
                                              _selectedDay = value!;
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Month field
                                        Flexible(
                                          child:
                                              DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: 'Month',
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            value: null,
                                            items: months.map((String month) {
                                              return DropdownMenuItem<String>(
                                                value: month,
                                                child: Text(month),
                                              );
                                            }).toList(),
                                            onChanged: (String? value) {
                                              _selectedMonth = months.indexOf(
                                                          value.toString()) ==
                                                      -1
                                                  ? 00
                                                  : months.indexOf(
                                                          value.toString()) +
                                                      1;
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Year field
                                        Flexible(
                                          child: DropdownButtonFormField<int>(
                                            decoration: InputDecoration(
                                              labelText: 'Year',
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            value: null,
                                            items: years.map((int year) {
                                              return DropdownMenuItem<int>(
                                                value: year,
                                                child: Text(year.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (int? value) {
                                              // Add functionality to handle value change
                                              setState(() {
                                                _selectedYear = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    // Gender dropdown
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Gender',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: <String>['Male', 'Female']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        // Add functionality to handle value change
                                        setState(() {
                                          _selectedGender = newValue!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15),

                                    // Country dropdown
                                    DropdownButtonFormField<CountriesData>(
                                      decoration: InputDecoration(
                                        labelText: _isLoadingCountry
                                            ? 'loading..'
                                            : 'Country',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: countriesData
                                          .map<DropdownMenuItem<CountriesData>>(
                                              (CountriesData value) {
                                        return DropdownMenuItem<CountriesData>(
                                          value: value,
                                          child: Text(value.country_name),
                                        );
                                      }).toList(),
                                      onChanged: (CountriesData? newValue) {
                                        // Add functionality to handle value change
                                        BlocProvider.of<auth.AuthBloc>(context)
                                            .add(auth.GetStatesEvent(
                                                countryId:
                                                    newValue!.country_id));
                                        setState(() {
                                          _selectedCountryID =
                                              newValue.country_id.toString();
                                          _isLoadingState = true;
                                          statesData = [];
                                          lgasData = [];
                                          wardsData = [];
                                          pollingData = [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15),

                                    // State dropdown
                                    DropdownButtonFormField<StatesData>(
                                      decoration: InputDecoration(
                                        labelText: _isLoadingState
                                            ? 'loading...'
                                            : 'State',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: statesData
                                          .map<DropdownMenuItem<StatesData>>(
                                              (StatesData value) {
                                        return DropdownMenuItem<StatesData>(
                                          value: value,
                                          child: Text(value.state_name),
                                        );
                                      }).toList(),
                                      onChanged: (StatesData? newValue) {
                                        // Add functionality to handle value change
                                        BlocProvider.of<auth.AuthBloc>(context)
                                            .add(auth.GetLgasEvent(
                                                stateId: newValue!.state_id));
                                        setState(() {
                                          _selectedStateID =
                                              newValue.state_id.toString();
                                          _isLoadingLGA = true;
                                          lgasData = [];
                                          wardsData = [];
                                          pollingData = [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15),

                                    // LGA dropdown
                                    DropdownButtonFormField<LgaData>(
                                      decoration: InputDecoration(
                                        labelText: _isLoadingLGA
                                            ? 'loading...'
                                            : 'LGA',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: lgasData
                                          .map<DropdownMenuItem<LgaData>>(
                                              (LgaData value) {
                                        return DropdownMenuItem<LgaData>(
                                          value: value,
                                          child: Text(value.lga_name),
                                        );
                                      }).toList(),
                                      onChanged: (LgaData? newValue) {
                                        // Add functionality to handle value change
                                        BlocProvider.of<auth.AuthBloc>(context)
                                            .add(auth.GetWardsEvent(
                                                lgaId: newValue!.lga_id));
                                        setState(() {
                                          _selectedLGAID =
                                              newValue.lga_id.toString();
                                          _isLoadingWard = true;
                                          wardsData = [];
                                          pollingData = [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15),

                                    // Ward dropdown
                                    DropdownButtonFormField<WardData>(
                                      decoration: InputDecoration(
                                        labelText: _isLoadingWard
                                            ? 'loading...'
                                            : 'Ward',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: wardsData
                                          .map<DropdownMenuItem<WardData>>(
                                              (WardData value) {
                                        return DropdownMenuItem<WardData>(
                                          value: value,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.3,
                                              child: Text(value.ward_name)),
                                        );
                                      }).toList(),
                                      onChanged: (WardData? newValue) {
                                        // Add functionality to handle value change
                                        BlocProvider.of<auth.AuthBloc>(context)
                                            .add(auth.GetPollingEvent(
                                                ward_id:
                                                    newValue!.id.toString()));
                                        setState(() {
                                          _selectedWardID =
                                              newValue.id.toString();
                                          _isLoadingPolling = true;
                                          pollingData = [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15),

                                    // Polling Unit dropdown
                                    DropdownButtonFormField<PollingData>(
                                      decoration: InputDecoration(
                                        labelText: _isLoadingPolling
                                            ? 'loading...'
                                            : 'Polling Unit',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      items: pollingData
                                          .map<DropdownMenuItem<PollingData>>(
                                              (PollingData value) {
                                        return DropdownMenuItem<PollingData>(
                                          value: value,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.3,
                                              child: Text(value.pu_name)),
                                        );
                                      }).toList(),
                                      onChanged: (PollingData? newValue) {
                                        // Add functionality to handle value change
                                        _selectedPollingID =
                                            newValue!.id.toString();
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    _step > 0
                                        ? TextFormField(
                                            controller: _controllerCode,
                                            readOnly: _step > 1 ? true : false,
                                            decoration: InputDecoration(
                                              labelText: 'Code',
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),

                                    SizedBox(height: _step > 0 ? 15 : 0),
                                  ],
                                ),
                              ),

                            // Submit button
                            _showJoinButton
                                ? ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.blue.withOpacity(
                                              0.5); // Change button color when pressed
                                        }
                                        return _isJoining
                                            ? Colors.blue.withOpacity(0.5)
                                            : Colors
                                                .blue; // Change button color based on loading state
                                      }),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Set border radius to 10
                                        ),
                                      ),
                                    ),
                                    onPressed: _isJoining
                                        ? null
                                        : () async {
                                            FocusScope.of(context).unfocus();
                                            print("Step ${_step}");
                                            if (_hasToken) {
                                              print("Step has ${_hasToken}");
                                              setState(() {
                                                _isJoining = true;
                                              });
                                              BlocProvider.of<auth.AuthBloc>(
                                                      context)
                                                  .add(auth.JoinEvent(
                                                      org_id: orgData!.id
                                                          .toString()));
                                            } else {
                                              //submit complete
                                              //Step 0 Login
                                              if (_step == 0) {
                                                setState(() {
                                                  _isJoining = true;
                                                });
                                                var emailValid = RegExp(
                                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(
                                                        _controllerEmail.text);
                                                if (_controllerEmail.text ==
                                                        "" ||
                                                    emailValid == false) {
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Invalid email address"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_controllerPassword
                                                        .text.length <
                                                    6) {
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Password must not be less than 6 characters"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_controllerPassword
                                                    .text.isEmpty) {
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Password can't be empty"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else {
                                                  setState(() {
                                                    _isJoining =
                                                        true; // Set loading state to true
                                                  });
                                                  BlocProvider.of<
                                                          auth
                                                          .AuthBloc>(context)
                                                      .add(
                                                    auth.RegisterUserEvent(
                                                      registerRequest:
                                                          RegisterRequest(
                                                              email:
                                                                  _controllerEmail
                                                                      .text,
                                                              password:
                                                                  _controllerPassword
                                                                      .text,
                                                              app_name:
                                                                  'townhall'),
                                                    ),
                                                  );
                                                }
                                              }
                                              // Step 1 confirm otp
                                              if (_step == 1) {
                                                setState(() {
                                                  _isJoining = true;
                                                });
                                                if (_controllerFirstName
                                                    .text.isEmpty) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Firstname can't be empty"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_controllerLastName
                                                    .text.isEmpty) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Lastname can't be empty"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_controllerUsername
                                                    .text.isEmpty) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Username can't be empty"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_controllerPhone
                                                    .text.isEmpty) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Phone can't be empty"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedDay == 00) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select a Day"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedMonth ==
                                                    00) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select a Month"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedYear ==
                                                    0000) {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select a Year"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedGender ==
                                                    '') {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select your Gender"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedCountryID ==
                                                    '') {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select your Country"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedStateID ==
                                                    '') {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select your State"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedLGAID ==
                                                    '') {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select your LGA"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (_selectedWardID ==
                                                    '') {
                                                  setState(() {
                                                    _isJoining = false;
                                                  });
                                                  final snackBar = SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          "Please select your Ward"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else {
                                                  setState(() {
                                                    _isJoining =
                                                        true; // Set loading state to true
                                                  });
                                                  if (_step == 1) {
                                                    BlocProvider.of<
                                                            auth
                                                            .AuthBloc>(context)
                                                        .add(
                                                      auth.RegisterOTPEvent(
                                                        registerOTPRequest:
                                                            RegisterOTPRequest(
                                                                email:
                                                                    _controllerEmail
                                                                        .text,
                                                                code:
                                                                    _controllerCode
                                                                        .text),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                              // Step 2 update profile
                                              if (_step == 2) {
                                                setState(() {
                                                  _isJoining = true;
                                                });
                                                BlocProvider.of<auth.AuthBloc>(
                                                        context)
                                                    .add(
                                                  auth.UpdateProfileEvent(
                                                    profileUpdateRequest:
                                                        ProfileUpdateRequest(
                                                      username:
                                                          _controllerUsername
                                                              .text,
                                                      about: '',
                                                      firstname:
                                                          _controllerFirstName
                                                              .text,
                                                      lastname:
                                                          _controllerLastName
                                                              .text,
                                                      phone: '',
                                                      gender: _selectedGender,
                                                      dob:
                                                          _selectedYear
                                                                  .toString() +
                                                              '-' +
                                                              _selectedMonth
                                                                  .toString() +
                                                              '-' +
                                                              _selectedDay
                                                                  .toString(),
                                                      edu_level_id: '',
                                                      profession_category: '',
                                                      user_profession: '',
                                                      support_group_id: '',
                                                      country:
                                                          _selectedCountryID,
                                                      state: _selectedStateID,
                                                      state_origin:
                                                          _selectedStateID,
                                                      lga: _selectedLGAID,
                                                      ward: _selectedWardID,
                                                      pu: _selectedPollingID,
                                                      //party: partyID,
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (_step == 3) {
                                                setState(() {
                                                  _isJoining = true;
                                                });
                                                BlocProvider.of<auth.AuthBloc>(
                                                        context)
                                                    .add(auth.JoinEvent(
                                                        org_id: orgData!.id
                                                            .toString()));
                                              }
                                              if (_step == 4) {
                                                setState(() {
                                                  _isJoining = true;
                                                });
                                                BlocProvider.of<auth.AuthBloc>(
                                                        context)
                                                    .add(
                                                  auth.LoginUserEvent(
                                                    loginRequest: LoginRequest(
                                                        email: _controllerEmail
                                                            .text,
                                                        password:
                                                            _controllerPassword
                                                                .text,
                                                        device_type: deviceType,
                                                        app_name: 'townhall',
                                                        device_token:
                                                            deviceToken),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          15.0), // Add padding around the text
                                      child: _isJoining
                                          ? const SizedBox(
                                              // Show loader when loading state is true
                                              width: 20,
                                              height: 20,
                                              child: SpinKitWave(
                                                color: Colors.white,
                                                size: 15.0,
                                              ),
                                            )
                                          : Text(
                                              'Join Townhall', // Change button text to "Join Townhall"
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ), // Set text color to white
                                            ), // Show text when loading state is false
                                    ),
                                  )
                                : SizedBox(),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }
}
