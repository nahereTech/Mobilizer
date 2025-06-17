import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as post;
import 'package:mobilizer/bloc/search/organization_bloc.dart' as org;
import 'package:mobilizer/bloc/search/people_bloc.dart' as people;
import 'package:mobilizer/bloc/search/polling_bloc.dart' as po;
import 'package:mobilizer/common/common/colors.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/countries/countries_response.dart';
import 'package:mobilizer/models/countries/lgas_response.dart';
import 'package:mobilizer/models/countries/states_response.dart';
import 'package:mobilizer/models/countries/wards_response.dart';
import 'package:mobilizer/models/professions/professions_response.dart';
// import 'package:mobilizer/models/parties/parties_response.dart';
import 'package:mobilizer/models/profile/get_profile_response.dart';
import 'package:mobilizer/models/profile/profile_update_request.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobilizer/models/qualifications/qualifications_response.dart';
import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/models/social/social_groups_response.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shimmer/shimmer.dart';

class Profile extends StatefulWidget {
  static String routeName = 'profile';

  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  bool _showBackIcon = false;
  bool _disableUsername = false;
  bool _showPollingUnit = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerUserName = TextEditingController();
  final _controllerFirstName = TextEditingController();
  final _controllerLastName = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerAbout = TextEditingController();
  //final _controllerOtherNames = TextEditingController();
  final _controllerGender = TextEditingController();

  final _controllerUserQualification = TextEditingController();
  final _controllerUserProfessionCategory = TextEditingController();
  final _controllerUserProfession = TextEditingController();
  final _controllerCountry = TextEditingController();
  final _controllerSupportGroup = TextEditingController();
  final _controllerState = TextEditingController();
  final _controllerStateOrigin = TextEditingController();
  final _controllerLocalArea = TextEditingController();
  final _controllerWard = TextEditingController();
  final _controllerParty = TextEditingController();
  final _controllerPolling = TextEditingController();
  final picker = ImagePicker();
  String supportGroupID = "";
  String countryID = "";
  String stateID = "";
  String stateOriginID = '';
  String wardID = "";
  String lgaID = "";
  String professionCategoryID = "";
  String qualificationID = "";
  // String partyID = "";
  String pollingID = "";
  //ProfileData? profileData;
  String profileImage =
      "https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid";
  File? _image;
  bool loading = false;
  bool _showUploadLoader = false;
  bool _isYFocused = false;
  bool _isMFocused = false;
  bool _isDFocused = false;
  String showLoaderFor = '';
  bool noResult = false;
  bool isProfileComplete = false;
  bool _showShimmer = true;

  List<CountriesData> countriesData = [];
  List<StatesData> statesData = [];
  List<StatesData> statesOriginData = [];
  List<LgaData> lgasData = [];
  List<WardData> wardsData = [];
  // List<PartyData> partyData = [];
  List<PollingData> pollingData = [];
  List<ProfessionData> professionData = [];
  List<QualificationData> qualificationData = [];
  List<SocialData> groupData = [];
  List<dynamic> yList = [];
  List<dynamic> mList = [];
  List<dynamic> dList = [];

  CompulsoryData? compulsory;
  VisibleData? visible;
  String selectedY = 'Year';
  String selectedM = 'Month';
  String selectedD = 'Day';

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _setProfilePic();
    Future.delayed(Duration.zero, () {
      BlocProvider.of<AuthBloc>(context).add(GetProfileEvent());
      BlocProvider.of<AuthBloc>(context).add(GetCountriesEvent());
      BlocProvider.of<AuthBloc>(context).add(GetQualificationsEvent());
      BlocProvider.of<AuthBloc>(context).add(GetProfessionsEvent());
      BlocProvider.of<AuthBloc>(context).add(GetSocialGroupsEvent(org_id: '5'));
      showLoaderFor = '';
    });
    _focusNode1.addListener(() {
      setState(() {
        _isYFocused = _focusNode1.hasFocus;
      });
    });
    _focusNode2.addListener(() {
      setState(() {
        _isMFocused = _focusNode2.hasFocus;
      });
    });
    _focusNode3.addListener(() {
      setState(() {
        _isDFocused = _focusNode3.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return _showBackIcon;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: _showBackIcon,
          iconTheme: IconTheme.of(context),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'My Profile',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoadingState) {
                if (showLoaderFor == '') {
                  loading = true;
                }
              }
              if (state is GetSocialGroupsState) {
                loading = false;
                showLoaderFor = '';
                noResult = false;
                groupData = state.getGroupsResponse.data;
                print(countriesData);
              }

              if (state is CountriesState) {
                loading = false;
                showLoaderFor = '';
                noResult = false;
                print(state.countriesResponse.message);
                print(state.countriesResponse.status);
                countriesData = state.countriesResponse.data;
                print(countriesData);
              }

              if (state is StatesState) {
                loading = false;
                showLoaderFor = '';
                noResult = false;
                print(state.statesResponse.message);
                print(state.statesResponse.status);
                statesData = state.statesResponse.data;
                statesOriginData = state.statesResponse.data;
              }

              if (state is LgasState) {
                loading = false;
                showLoaderFor = '';
                noResult = false;
                print(state.lgasResponse.message);
                print(state.lgasResponse.status);
                lgasData = state.lgasResponse.data;
              }

              if (state is WardsState) {
                loading = false;
                showLoaderFor = '';
                noResult = false;
                print(state.wardsResponse.message);
                print(state.wardsResponse.status);
                wardsData = state.wardsResponse.data;
              }
              if (state is LoadedPollingState) {
                pollingData = state.getPollingResponse.data;
                loading = false;
                showLoaderFor = '';
              }
              if (state is NoResultState) {
                loading = false;
                showLoaderFor = '';
              }
              if (state is QualificationState) {
                loading = false;
                showLoaderFor = '';
                qualificationData = state.qualificationResponse.data;
              }
              if (state is ProfessionState) {
                loading = false;
                showLoaderFor = '';
                professionData = state.professionResponse.data;
              }
              if (state is IncompleteProfileState) {
                setState(() {
                  _showBackIcon = state.getProfileResponse.data!.can_opt_out ==
                              null ||
                          state.getProfileResponse.data!.can_opt_out == "" ||
                          state.getProfileResponse.data!.can_opt_out == "yes"
                      ? true
                      : false;
                  isProfileComplete = false;
                  visible = state.getProfileResponse.visible;
                  compulsory = state.getProfileResponse.compulsory;
                  _showShimmer = false;
                  loading = false;
                  showLoaderFor = '';
                  _controllerEmail.text = state.email;
                });
              }
              // if (state is PartyState) {
              //   loading = false;
              //   noResult = false;
              //   print(state.partyResponse.msg);
              //   print(state.partyResponse.status);
              //   // partyData = state.partyResponse.data;
              //   print("am here");
              // }
              if (state is NoResultState) {
                loading = false;
                showLoaderFor = '';
                noResult = true;
              }
              if (state is NoPartyState) {
                loading = false;
                showLoaderFor = '';
                noResult = true;
              }

              if (state is ProfileState) {
                _showShimmer = false;
                loading = false;
                showLoaderFor = '';
                print(state.profileUpdateResponse.msg);
                print(state.profileUpdateResponse.status);
                // final snackBar = SnackBar(backgroundColor:Colors.green,
                //     content: Text(state.profileUpdateResponse.msg.toString()));
                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                // Navigation.intentWithClearAllRoutes(
                //     context, HomeScreen.routeName);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (contextA) => people.PeopleBloc(),
                      ),
                      BlocProvider(
                        create: (context) => post.PostsBloc(),
                      ),
                      BlocProvider(create: (context) => org.OrganizationBloc()),
                    ],
                    child: Feed(),
                  );
                }));
              }
              if (state is ProfileImageState) {
                loading = false;
                _showUploadLoader = false;
                _showShimmer = false;
                showLoaderFor = '';
                print(state.profileImageResponse.msg);
                print(state.profileImageResponse.status);
                AppSharedPreferences.setValue(
                    key: 'profilePic',
                    value: state.profileImageResponse.data.photo_path_mid);
                final snackBar = SnackBar(
                    content: Text(state.profileImageResponse.msg.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              if (state is GetProfileState) {
                setState(() {
                  _showShimmer = false;
                  _showBackIcon = state.getProfileResponse.data!.can_opt_out ==
                              null ||
                          state.getProfileResponse.data!.can_opt_out == "" ||
                          state.getProfileResponse.data!.can_opt_out == "yes"
                      ? true
                      : false;
                  isProfileComplete = true;
                  visible = state.getProfileResponse.visible;
                  compulsory = state.getProfileResponse.compulsory;
                });

                print(state.getProfileResponse.data);
                print(
                    "Support Group: ${state.getProfileResponse.data!.support_group_id}");
                countryID =
                    state.getProfileResponse.data!.country_id.toString();
                supportGroupID =
                    state.getProfileResponse.data!.support_group_id.toString();
                stateID = state.getProfileResponse.data!.state_id.toString();
                stateOriginID =
                    state.getProfileResponse.data!.state_origin_id.toString();
                lgaID = state.getProfileResponse.data!.lga_id.toString();
                wardID = state.getProfileResponse.data!.ward_id.toString();
                pollingID = state.getProfileResponse.data!.pu_id.toString();
                qualificationID =
                    state.getProfileResponse.data!.edu_level_id.toString();
                professionCategoryID = state
                    .getProfileResponse.data!.profession_category
                    .toString();
                loading = false;
                //PaintingBinding.instance.imageCache.clear();
                String? username =
                    state.getProfileResponse.data!.username != null
                        ? state.getProfileResponse.data!.username
                        : "";
                _disableUsername = username == "" ? false : true;

                _controllerUserName.text = username != null
                    ? state.getProfileResponse.data!.username
                    : "";

                _controllerAbout.text =
                    state.getProfileResponse.data!.about_me != null
                        ? state.getProfileResponse.data!.about_me
                        : "";
                _controllerFirstName.text =
                    state.getProfileResponse.data!.firstname != null
                        ? state.getProfileResponse.data!.firstname
                        : "";
                _controllerEmail.text =
                    state.getProfileResponse.data!.email != null
                        ? state.getProfileResponse.data!.email
                        : null;
                _controllerLastName.text =
                    state.getProfileResponse.data!.lastname != null
                        ? state.getProfileResponse.data!.lastname
                        : "";
                _controllerPhone.text =
                    state.getProfileResponse.data!.phone != null
                        ? state.getProfileResponse.data!.phone
                        : "";
                // _controllerOtherNames.text =
                //     state.getProfileResponse.data.data.othernames;
                _controllerGender.text =
                    state.getProfileResponse.data!.gender != null
                        ? state.getProfileResponse.data!.gender
                        : "";
                _showPollingUnit =
                    state.getProfileResponse.data!.show_polling_unit == "yes"
                        ? true
                        : false;
                if (state.getProfileResponse.data!.dob != null ||
                    state.getProfileResponse.data!.dob != '') {
                  var dob =
                      state.getProfileResponse.data!.dob.toString().split('-');
                  selectedY = dob[0] == "0000" ? "Year" : dob[0];
                  selectedM = dob[1] == "00" ? "Month" : dob[1];
                  selectedD = dob[2] == "00" ? "Day" : dob[2];
                }
                _controllerUserQualification.text =
                    state.getProfileResponse.data!.edu_level_txt != null
                        ? state.getProfileResponse.data!.edu_level_txt
                        : "";

                _controllerUserProfessionCategory.text =
                    state.getProfileResponse.data!.profession_category_txt !=
                            null
                        ? state.getProfileResponse.data!.profession_category_txt
                        : "";

                _controllerUserProfession.text =
                    state.getProfileResponse.data!.profession != null
                        ? state.getProfileResponse.data!.profession
                        : "";
                // profileImage = state.getProfileResponse.data!.photo_path_mid;
                _controllerCountry.text =
                    state.getProfileResponse.data!.country_name != null
                        ? state.getProfileResponse.data!.country_name
                        : "";
                _controllerSupportGroup.text =
                    state.getProfileResponse.data!.support_group_name != null
                        ? state.getProfileResponse.data!.support_group_name
                        : "";
                BlocProvider.of<AuthBloc>(context).add(GetStatesEvent(
                    countryId: state.getProfileResponse.data!.country_id));
                _controllerState.text =
                    state.getProfileResponse.data!.state_name != null
                        ? state.getProfileResponse.data!.state_name
                        : "";
                _controllerStateOrigin.text =
                    state.getProfileResponse.data!.state_origin_name != null
                        ? state.getProfileResponse.data!.state_origin_name
                        : "";
                BlocProvider.of<AuthBloc>(context).add(GetLgasEvent(
                    stateId: state.getProfileResponse.data!.state_id));
                _controllerLocalArea.text =
                    state.getProfileResponse.data!.lga_name;

                BlocProvider.of<AuthBloc>(context).add(GetWardsEvent(
                    lgaId: state.getProfileResponse.data!.lga_id));
                _controllerWard.text = state.getProfileResponse.data!.ward_name;
                // BlocProvider.of<AuthBloc>(context).add(GetPartyEvent(
                //     countryID:
                //         state.getProfileResponse.data!.country_id.toString(),
                //     forResult: 'yes'));
                // _controllerParty.text =
                //     state.getProfileResponse.data!.party_accronym;
                BlocProvider.of<AuthBloc>(context).add(GetPollingEvent(
                    ward_id:
                        state.getProfileResponse.data!.ward_id.toString()));
                _controllerPolling.text =
                    state.getProfileResponse.data!.pu_name;
                print(
                    "Polling Unit: ${state.getProfileResponse.data!.pu_name}");
              }
              if (state is UpdateProfileFailedState) {
                loading = false;
                _showShimmer = false;
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              if (state is ErrorState) {
                _showShimmer = false;
                loading = false;
                _showUploadLoader = false;
                print("PRINT: ${state.message}");
                if (state.message != "Error fetching profile data") {
                  final snackBar =
                      SnackBar(content: Text(state.message.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
              if (state is NetworkState) {
                _showShimmer = false;
                loading = false;
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                if (_image != null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Opacity(
                                      opacity: _showUploadLoader ? 0.5 : 1.0,
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.grey,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(80),
                                          child: CircleAvatar(
                                            radius: 70,
                                            backgroundColor: Colors.black45,
                                            backgroundImage: FileImage(_image!),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_image == null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 52,
                                      backgroundColor: Colors.grey,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(80),
                                        child: Image.network(
                                          profileImage,
                                          //"https://placeimg.com/640/480/any",
                                          //"https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/ef9c4590-3f96-42f3-0c29-be62c3d5c100/mid",
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: MaterialButton(
                                    shape: CircleBorder(
                                      side: BorderSide(
                                        width: 2,
                                        color: Colors.white,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 20.0,
                                    ),
                                    color: Colors.white,
                                    textColor: Colors.green,
                                    onPressed: () {
                                      //selectImageSource();
                                      getImage(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              visible != null && visible!.username
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-zA-Z0-9_]')),
                                        ],
                                        onChanged: (value) {
                                          //_formatString(value);
                                          _controllerUserName.value =
                                              TextEditingValue(
                                                  text: value
                                                      .toLowerCase()
                                                      .trim(),
                                                  selection: _controllerUserName
                                                      .selection);
                                        },
                                        readOnly: _disableUsername,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'User Name',
                                            hintText: 'Enter UserName'),
                                        controller: _controllerUserName,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.username == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the organization username';
                                            } else if (!RegExp(
                                                    r'^[a-zA-Z0-9_]+$')
                                                .hasMatch(value)) {
                                              return 'Username can only contain letters, numbers, and underscores, with no spaces';
                                            } else if (value.length > 15) {
                                              return 'Username cannot exceed 30 characters';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.firstname
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'First Name',
                                            hintText: 'Enter First Name'),
                                        controller: _controllerFirstName,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.firstname == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter First Name';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.lastname
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Last Name',
                                            hintText: 'Enter Last Name'),
                                        controller: _controllerLastName,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.lastname == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Last Name';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.phone
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        maxLength: 11,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Phone',
                                            hintText: 'Enter Phone'),
                                        controller: _controllerPhone,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.phone == true) {
                                            // if (value == null || value.isEmpty) {
                                            //   return 'Please Enter Phone';
                                            // }
                                            if (validateMobile(
                                                    value.toString()) ==
                                                false) {
                                              return 'Please Enter Valid Phone';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: TextFormField(
                              //     decoration: InputDecoration(
                              //         border: OutlineInputBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(15.0)),
                              //         labelText: 'Other Names',
                              //         hintText: 'Enter Other Names'),
                              //     controller: _controllerOtherNames,
                              //     validator: (value) {
                              //       if (value == null || value.isEmpty) {
                              //         return 'Please Enter Other Names';
                              //       }
                              //       return null;
                              //     },
                              //   ),
                              // ),
                              visible != null && visible!.about
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        maxLength: 300,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'About Me',
                                            hintText: 'Enter About Me'),
                                        controller: _controllerAbout,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.about == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter About Me';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.gender
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        onTap: () async {
                                          List<String> values = [
                                            'Male',
                                            'Female',
                                            'Others'
                                          ];
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SimpleDialog(
                                                title: Text("Select Gender"),
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return SimpleDialogOption(
                                                          onPressed: () {
                                                            _controllerGender
                                                                    .text =
                                                                values[index];
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              values[index]),
                                                        );
                                                      },
                                                      itemCount: values.length,
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Gender',
                                            hintText: 'Enter Gender'),
                                        controller: _controllerGender,
                                        readOnly: true,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.gender == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Select Your Gender';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.dob
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: size.width / 4.0,
                                                height: 58,
                                                child: DropdownButtonFormField(
                                                  focusNode: _focusNode1,
                                                  focusColor: _isYFocused
                                                      ? Colors.red
                                                      : Colors.black,
                                                  padding: EdgeInsets.only(
                                                      top: 0, bottom: 0),
                                                  onChanged: (String? yValue) {
                                                    setState(() {
                                                      selectedY = yValue!;
                                                    });
                                                  },
                                                  value: selectedY,
                                                  itemHeight: 55.0,
                                                  menuMaxHeight: 350.0,
                                                  hint: Text(
                                                    'Year',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Year',
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  items: getYears(1924)
                                                      .map((String val) {
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              _isYFocused && selectedY == "Year"
                                                  ? Text(
                                                      "Year required",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                                          SizedBox(width: 7),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: size.width / 4.0,
                                                height: 58,
                                                child: DropdownButtonFormField(
                                                  focusNode: _focusNode2,
                                                  focusColor: _isMFocused
                                                      ? Colors.red
                                                      : Colors.black,
                                                  menuMaxHeight: 350.0,
                                                  hint: Text(
                                                    'Month',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black26,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  value: selectedM,
                                                  onChanged: (String? mValue) {
                                                    setState(() {
                                                      selectedM = mValue!;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value == 'Month') {
                                                      //print("Error ${selectedM}");
                                                      return 'Month of birth is required';
                                                    }
                                                    return null;
                                                  },
                                                  items: getMonths()
                                                      .map((String val) {
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              _isMFocused &&
                                                      selectedM == "Month"
                                                  ? Text(
                                                      "Month required",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                                          SizedBox(width: 7),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: size.width / 4.0,
                                                height: 58,
                                                child: DropdownButtonFormField(
                                                  focusNode: _focusNode3,
                                                  focusColor: _isDFocused
                                                      ? Colors.red
                                                      : Colors.black,
                                                  menuMaxHeight: 350.0,
                                                  hint: Text(
                                                    'Day',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  // validator: (value) {
                                                  //   if (value == null ||
                                                  //       value == 'Day') {
                                                  //     // setState(() {
                                                  //     //   selectedD = 'Day';
                                                  //     // });
                                                  //     print("${selectedD}");
                                                  //     //return 'Day of birth is required';
                                                  //   }
                                                  //   try {
                                                  //     if (selectedY == 'Year' ||
                                                  //         selectedM == 'Month' ||
                                                  //         selectedD == 'Day') {
                                                  //       return 'Complete date is required';
                                                  //     }
                                                  //     int year =
                                                  //         int.parse(selectedY);
                                                  //     int month =
                                                  //         int.parse(selectedM);
                                                  //     int day =
                                                  //         int.parse(selectedD);
                                                  //     if (!isDateValid(
                                                  //         year, month, day)) {
                                                  //       return 'Invalid date was passed';
                                                  //     }
                                                  //   } catch (e) {
                                                  //     return 'Invalid numeric values';
                                                  //   }
                                                  //   return null;
                                                  // },
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black26,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  value: selectedD,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      selectedD = newValue!;
                                                    });
                                                  },
                                                  items: getDays()
                                                      .map((String val) {
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              _isDFocused && selectedD == "Day"
                                                  ? Text(
                                                      "Day required",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : SizedBox()
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.edu
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext contextTwo) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: Text(
                                                    'Educational Qualification'),
                                                content: Container(
                                                  height: 200.0,
                                                  width: 400.0,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: qualificationData
                                                        .length,
                                                    itemBuilder: (BuildContext
                                                            contextOne,
                                                        int index) {
                                                      return ListTile(
                                                        title: Text(
                                                            qualificationData[
                                                                    index]
                                                                .name!),
                                                        onTap: () {
                                                          qualificationID =
                                                              qualificationData[
                                                                      index]
                                                                  .id!
                                                                  .toString();
                                                          _controllerUserQualification
                                                                  .text =
                                                              qualificationData[
                                                                      index]
                                                                  .name!;

                                                          Navigator.of(
                                                                  contextTwo,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText:
                                                'Educational Qualification',
                                            hintText: 'Enter Qualification'),
                                        controller:
                                            _controllerUserQualification,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.edu == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select Educational Qualification from the list';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              visible != null && visible!.prof_cat
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext contextTwo) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: Text('Category'),
                                                content: Container(
                                                  height: 200.0,
                                                  width: 400.0,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        professionData.length,
                                                    itemBuilder: (BuildContext
                                                            contextOne,
                                                        int index) {
                                                      return ListTile(
                                                        title: Text(
                                                            professionData[
                                                                    index]
                                                                .name!),
                                                        onTap: () {
                                                          professionCategoryID =
                                                              professionData[
                                                                      index]
                                                                  .id!
                                                                  .toString();
                                                          _controllerUserProfessionCategory
                                                                  .text =
                                                              professionData[
                                                                      index]
                                                                  .name!;
                                                          _controllerUserProfession
                                                              .text = '';

                                                          Navigator.of(
                                                                  contextTwo,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText:
                                                'Profession Category (compulsory)',
                                            hintText:
                                                'Enter Profession Category'),
                                        controller:
                                            _controllerUserProfessionCategory,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.prof_cat == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select profession category from the list';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              visible != null && visible!.prof_desc
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText:
                                                'Describe Your Profession (optional)',
                                            hintText: 'Enter User Profession'),
                                        controller: _controllerUserProfession,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.prof_desc == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter User Profession';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              visible != null && visible!.email
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Email',
                                            hintText: 'Email'),
                                        controller: _controllerEmail,
                                        // validator: (value) {
                                        //   // if (value == null || value.isEmpty) {
                                        //   //   return 'Please Enter User Profession';
                                        //   // }
                                        //   //return null;
                                        // },
                                      ),
                                    )
                                  : SizedBox(),

                              visible != null && visible!.supportg
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext contextTwo) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: Text('Support Group'),
                                                content: Container(
                                                  height: 200.0,
                                                  width: 400.0,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: groupData.length,
                                                    itemBuilder: (BuildContext
                                                            contextOne,
                                                        int index) {
                                                      return ListTile(
                                                        title: Text(
                                                            groupData[index]
                                                                .name),
                                                        onTap: () {
                                                          _controllerSupportGroup
                                                                  .text =
                                                              groupData[index]
                                                                  .name;
                                                          supportGroupID =
                                                              groupData[index]
                                                                  .id;
                                                          Navigator.of(
                                                                  contextTwo,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Support Group',
                                            hintText: 'Enter Support Group'),
                                        controller: _controllerSupportGroup,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.supportg == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Support Group';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              visible != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 80,
                                          left: 80),
                                      child: Divider(
                                        color: Colors.black,
                                      ),
                                    )
                                  : SizedBox(),
                              visible != null && visible!.country
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          right: 33,
                                          left: 33),
                                      child: TextFormField(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext contextTwo) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: Text(
                                                    'Country Of Residence'),
                                                content: Container(
                                                  height: 200.0,
                                                  width: 400.0,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        countriesData.length,
                                                    itemBuilder: (BuildContext
                                                            contextOne,
                                                        int index) {
                                                      return ListTile(
                                                        title: Text(
                                                            countriesData[index]
                                                                .country_name),
                                                        onTap: () {
                                                          showLoaderFor =
                                                              'state';
                                                          BlocProvider.of<
                                                                      AuthBloc>(
                                                                  context)
                                                              .add(GetStatesEvent(
                                                                  countryId: countriesData[
                                                                          index]
                                                                      .country_id));
                                                          _controllerState
                                                              .text = '';
                                                          _controllerLocalArea
                                                              .text = '';
                                                          _controllerWard.text =
                                                              '';
                                                          _controllerPolling
                                                              .text = '';
                                                          //_controllerParty.text = '';
                                                          countryID =
                                                              countriesData[
                                                                      index]
                                                                  .country_id
                                                                  .toString();
                                                          _controllerCountry
                                                                  .text =
                                                              countriesData[
                                                                      index]
                                                                  .country_name;
                                                          _controllerState
                                                              .text = '';
                                                          stateID = '';
                                                          stateOriginID = '';
                                                          pollingID = '';
                                                          //partyID = '';

                                                          lgasData = [];
                                                          statesData = [];
                                                          wardsData = [];
                                                          //partyData = [];
                                                          pollingData = [];

                                                          //_controllerParty.text = '';
                                                          Navigator.of(
                                                                  contextTwo,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'Country of Residence',
                                            hintText: 'Enter Country'),
                                        controller: _controllerCountry,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.country == true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Country';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              showLoaderFor == "state"
                                  ? Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    )
                                  : visible != null && visible!.state
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 8.0,
                                              right: 33,
                                              left: 33),
                                          child: TextFormField(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext contextTwo) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: Text(
                                                        'State of Residence'),
                                                    content: Container(
                                                      height: 200.0,
                                                      width: 400.0,
                                                      child:
                                                          statesData.length < 1
                                                              ? SizedBox(
                                                                  child: noResult
                                                                      ? Text('No result')
                                                                      : Center(
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                80.0,
                                                                            height:
                                                                                80.0,
                                                                            child:
                                                                                SpinKitCircle(
                                                                              color: Colors.blue,
                                                                              size: 50.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                )
                                                              : ListView
                                                                  .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      statesData
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              contextOne,
                                                                          int index) {
                                                                    return ListTile(
                                                                      title: Text(
                                                                          statesData[index]
                                                                              .state_name),
                                                                      onTap:
                                                                          () {
                                                                        showLoaderFor =
                                                                            'lga';
                                                                        BlocProvider.of<AuthBloc>(context).add(GetLgasEvent(
                                                                            stateId:
                                                                                statesData[index].state_id));
                                                                        _controllerState
                                                                            .text = statesData[
                                                                                index]
                                                                            .state_name;

                                                                        _controllerLocalArea.text =
                                                                            '';
                                                                        _controllerWard.text =
                                                                            '';
                                                                        _controllerPolling.text =
                                                                            '';
                                                                        wardsData =
                                                                            [];
                                                                        lgasData =
                                                                            [];
                                                                        pollingData =
                                                                            [];
                                                                        stateID = statesData[index]
                                                                            .state_id
                                                                            .toString();
                                                                        lgaID =
                                                                            '';
                                                                        Navigator.of(contextTwo,
                                                                                rootNavigator: true)
                                                                            .pop();
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                labelText: 'State of Residence',
                                                hintText: 'State of Residence'),
                                            controller: _controllerState,
                                            validator: (value) {
                                              if (compulsory != null &&
                                                  compulsory!.state == true) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please Enter State';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : SizedBox(),

                              showLoaderFor == "lga"
                                  ? Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    )
                                  : visible != null && visible!.lga
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 8.0,
                                              right: 33,
                                              left: 33),
                                          child: TextFormField(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext contextTwo) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: Text(
                                                        'LGA of Residence'),
                                                    content: Container(
                                                      height: 200.0,
                                                      width: 400.0,
                                                      child: lgasData.length < 1
                                                          ? SizedBox()
                                                          : ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  lgasData
                                                                      .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          contextOne,
                                                                      int index) {
                                                                return ListTile(
                                                                  title: Text(lgasData[
                                                                          index]
                                                                      .lga_name),
                                                                  onTap: () {
                                                                    showLoaderFor =
                                                                        'ward';
                                                                    BlocProvider.of<AuthBloc>(
                                                                            context)
                                                                        .add(GetWardsEvent(
                                                                            lgaId:
                                                                                lgasData[index].lga_id));
                                                                    _controllerLocalArea
                                                                        .text = lgasData[
                                                                            index]
                                                                        .lga_name;
                                                                    _controllerWard
                                                                        .text = '';
                                                                    _controllerPolling
                                                                        .text = '';
                                                                    lgaID = lgasData[
                                                                            index]
                                                                        .lga_id
                                                                        .toString();
                                                                    wardsData =
                                                                        [];
                                                                    pollingData =
                                                                        [];
                                                                    wardID = '';
                                                                    pollingID =
                                                                        '';
                                                                    Navigator.of(
                                                                            contextTwo,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                labelText: 'LGA of Residence',
                                                hintText: 'LGA of Residence'),
                                            controller: _controllerLocalArea,
                                            validator: (value) {
                                              if (compulsory != null &&
                                                  compulsory!.lga == true) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please Enter Local Government Area';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                              showLoaderFor == "ward"
                                  ? Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    )
                                  : visible != null && visible!.ward
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 8.0,
                                              right: 33,
                                              left: 33),
                                          child: TextFormField(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext contextTwo) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: Text(
                                                        'Ward of Residence'),
                                                    content: Container(
                                                      height: 200.0,
                                                      width: 400.0,
                                                      child:
                                                          wardsData.length < 1
                                                              ? SizedBox()
                                                              : ListView
                                                                  .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      wardsData
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              contextOne,
                                                                          int index) {
                                                                    return ListTile(
                                                                      title: Text(
                                                                          wardsData[index]
                                                                              .ward_name),
                                                                      onTap:
                                                                          () {
                                                                        showLoaderFor =
                                                                            'polling';
                                                                        _controllerWard
                                                                            .text = wardsData[
                                                                                index]
                                                                            .ward_name;
                                                                        wardID = wardsData[index]
                                                                            .id
                                                                            .toString();
                                                                        print(
                                                                            "WardID: ${wardsData[index].id.toString()}");
                                                                        pollingData =
                                                                            [];
                                                                        BlocProvider.of<AuthBloc>(context).add(GetPollingEvent(
                                                                            ward_id:
                                                                                wardsData[index].id.toString()));
                                                                        _controllerPolling.text =
                                                                            '';

                                                                        Navigator.of(contextTwo,
                                                                                rootNavigator: true)
                                                                            .pop();
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                labelText: 'Ward of Residence',
                                                hintText: 'Ward of Residence'),
                                            controller: _controllerWard,
                                            validator: (value) {
                                              if (compulsory != null &&
                                                  compulsory!.ward == true) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please Enter Ward';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                              showLoaderFor == "polling"
                                  ? Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    )
                                  : visible != null &&
                                          visible!.pu &&
                                          _showPollingUnit
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 8.0,
                                              right: 33,
                                              left: 33),
                                          child: TextFormField(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext contextTwo) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title:
                                                        Text('My Polling unit'),
                                                    content: Container(
                                                      height: 200.0,
                                                      width: 400.0,
                                                      child: pollingData
                                                                  .length <
                                                              1
                                                          ? SizedBox()
                                                          : ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  pollingData
                                                                      .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          contextOne,
                                                                      int index) {
                                                                return ListTile(
                                                                  title: Text(pollingData[
                                                                          index]
                                                                      .pu_name!),
                                                                  onTap: () {
                                                                    pollingID =
                                                                        pollingData[index]
                                                                            .id
                                                                            .toString();

                                                                    _controllerPolling
                                                                        .text = pollingData[
                                                                            index]
                                                                        .pu_name;

                                                                    Navigator.of(
                                                                            contextTwo,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                labelText: 'My Polling unit',
                                                hintText:
                                                    'Select Polling unit'),
                                            controller: _controllerPolling,
                                            validator: (value) {
                                              if (compulsory != null &&
                                                  compulsory!.pu == true) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select polling unit';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                              SizedBox(
                                height: 10,
                              ),

                              visible != null && visible!.state_origin
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext contextTwo) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: Text('State of Origin'),
                                                content: Container(
                                                  height: 200.0,
                                                  width: 400.0,
                                                  child: statesData.length < 1
                                                      ? SizedBox(
                                                          child: noResult
                                                              ? Text(
                                                                  'No result')
                                                              : Center(
                                                                  child:
                                                                      Container(
                                                                    width: 80.0,
                                                                    height:
                                                                        80.0,
                                                                    child:
                                                                        SpinKitCircle(
                                                                      color: Colors
                                                                          .blue,
                                                                      size:
                                                                          50.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              statesOriginData
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      contextOne,
                                                                  int index) {
                                                            return ListTile(
                                                              title: Text(
                                                                  statesOriginData[
                                                                          index]
                                                                      .state_name),
                                                              onTap: () {
                                                                _controllerStateOrigin
                                                                        .text =
                                                                    statesOriginData[
                                                                            index]
                                                                        .state_name;

                                                                stateOriginID =
                                                                    statesOriginData[
                                                                            index]
                                                                        .state_id
                                                                        .toString();

                                                                Navigator.of(
                                                                        contextTwo,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              },
                                                            );
                                                          },
                                                        ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            labelText: 'State of Origin',
                                            hintText: 'State of Origin'),
                                        controller: _controllerStateOrigin,
                                        validator: (value) {
                                          if (compulsory != null &&
                                              compulsory!.state_origin ==
                                                  true) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter State Of Origin';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),

                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: TextFormField(
                              //     onTap: () {
                              //       showDialog(
                              //         context: context,
                              //         builder: (BuildContext contextTwo) {
                              //           return AlertDialog(
                              //             scrollable: true,
                              //             title: Text('My Party'),
                              //             content: Container(
                              //               height: 200.0,
                              //               width: 400.0,
                              //               child: partyData.length < 1
                              //                   ? SizedBox()
                              //                   : ListView.builder(
                              //                       shrinkWrap: true,
                              //                       itemCount: partyData.length,
                              //                       itemBuilder:
                              //                           (BuildContext contextOne,
                              //                               int index) {
                              //                         return ListTile(
                              //                           title: Text(
                              //                               partyData[index].name!),
                              //                           onTap: () {
                              //                             // partyID =
                              //                             //     partyData[index].id!;
                              //                             _controllerParty.text =
                              //                                 partyData[index]
                              //                                     .name!;
                              //                             Navigator.of(contextTwo,
                              //                                     rootNavigator:
                              //                                         true)
                              //                                 .pop();
                              //                           },
                              //                         );
                              //                       },
                              //                     ),
                              //             ),
                              //           );
                              //         },
                              //       );
                              //     },
                              //     readOnly: true,
                              //     decoration: InputDecoration(
                              //         border: OutlineInputBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(15.0)),
                              //         labelText: 'My Party',
                              //         hintText: 'Select Party'),
                              //     controller: _controllerParty,
                              //     // validator: (value) {
                              //     //   if (value == null || value.isEmpty) {
                              //     //     return 'Please Enter Local Government Area';
                              //     //   }
                              //     //   return null;
                              //     // },
                              //   ),
                              // ),
                            ],
                          ),
                          if (_showShimmer) _buildShimmerLoader(),
                          visible != null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8.0,
                                            right: 33,
                                            left: 33),
                                        child: ElevatedButton(
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
                                          onPressed: loading
                                              ? null
                                              : () async {
                                                  if (selectedY == "Year") {
                                                    _focusNode1.requestFocus();
                                                  } else if (selectedM ==
                                                      "Month") {
                                                    _focusNode2.requestFocus();
                                                  } else if (selectedD ==
                                                      "Day") {
                                                    _focusNode3.requestFocus();
                                                  } else if (_formKey
                                                      .currentState!
                                                      .validate()) {
                                                    BlocProvider.of<AuthBloc>(
                                                            context)
                                                        .add(
                                                      UpdateProfileEvent(
                                                        profileUpdateRequest:
                                                            ProfileUpdateRequest(
                                                          username:
                                                              _controllerUserName
                                                                  .text,
                                                          about:
                                                              _controllerAbout
                                                                  .text,
                                                          firstname:
                                                              _controllerFirstName
                                                                  .text,
                                                          lastname:
                                                              _controllerLastName
                                                                  .text,
                                                          phone:
                                                              _controllerPhone
                                                                  .text,
                                                          // othernames:
                                                          //     _controllerOtherNames.text,
                                                          gender:
                                                              _controllerGender
                                                                  .text,
                                                          dob: selectedY +
                                                              '-' +
                                                              selectedM +
                                                              '-' +
                                                              selectedD,
                                                          edu_level_id:
                                                              qualificationID,
                                                          profession_category:
                                                              professionCategoryID,
                                                          user_profession:
                                                              _controllerUserProfession
                                                                  .text,
                                                          support_group_id:
                                                              supportGroupID,
                                                          country: countryID,
                                                          state: stateID,
                                                          state_origin:
                                                              stateOriginID,
                                                          lga: lgaID,
                                                          ward: wardID,
                                                          pu: pollingID,
                                                          //party: partyID,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (loading)
                                                SizedBox(
                                                  // Show loader when loading state is true
                                                  width: 20,
                                                  height: 20,
                                                  child: SpinKitWave(
                                                    color: Colors.white,
                                                    size: 15.0,
                                                  ),
                                                ),
                                              if (loading == false)
                                                Text(
                                                  'Update',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 20.0),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
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

  List<String> getYears(int year) {
    //int currentYear = DateTime.now().year;
    List<String> yearsTilPresent = [];

    while (year < 2023) {
      yearsTilPresent.add(year.toString());
      year++;
    }
    return ['Year', ...yearsTilPresent.reversed];
  }

  List<String> getMonths() {
    List<String> months = ['Month'];
    for (var i = 1; i < 13; i++) {
      var m = i < 10 ? '0${i}' : i.toString();
      months.add(m.toString());
    }
    return months;
  }

  List<String> getDays() {
    List<String> days = ['Day'];
    for (var i = 1; i < 32; i++) {
      var d = i < 10 ? '0${i}' : i.toString();
      days.add(d.toString());
    }
    return days;
  }

  void _setProfilePic() async {
    var picture = await _getProfilePic();
    setState(() {
      profileImage = picture!;
    });
  }

  Future<String?> _getProfilePic() async {
    return await AppSharedPreferences.getValue(key: 'profilePic');
  }

  //image with cropper
  Future getImage(context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // maxHeight: 50.0,
      // maxWidth: 50.0,
    );
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image Editor',
              toolbarColor: Colors.blue,
              activeControlsWidgetColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Image Editor',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        // Convert CroppedFile to File
        final File convertedFile = File(croppedFile.path);
        updateProfileImage(
            convertedFile); // Pass the converted File to the function
      }
    }
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width / 1.2,
                height: 63,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.black, // Black border color
                    width: 2.0, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "Firstname",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
  // Future getImageFromCamera() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.camera);

  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       updateProfileImage();
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  // Future getImageFromGallery() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       updateProfileImage();
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  void updateProfileImage(File? image) async {
    print("Print: ${image!.path} ${image}");
    // List<int> imageBytesOne = File(image!.path).readAsBytesSync();
    // String photoBase64One = base64Encode(imageBytesOne);
    // print(photoBase64One);
    BlocProvider.of<AuthBloc>(context)
        .add(UpdateProfileImageEvent(image: image));
    setState(() {
      _image = image;
      _showUploadLoader = true;
    });
  }

  bool validateMobile(String value) {
    //String pattern = r'(^(?:[+0]9)?[0-9]{10,11}$)';
    String pattern = r'(^(?:[+0]9)?[0-9]{11}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length != 0 && regExp.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  bool validateUsername(String value) {
    String pattern = r'(^[A-Za-z][A-Za-z0-9_]{3,29}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length != 0 && regExp.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getToken() async {
    return await AppSharedPreferences.getValue(key: 'token');
  }

  bool isDateValid(int year, int month, int day) {
    try {
      // Attempt to create a DateTime object with the given year, month, and day
      if (year == "Year" || month == "Month" || day == "Day") {
        return false;
      } else {
        DateTime date = DateTime(year, month, day);

        // Check if the created date matches the input values
        return date.year == year && date.month == month && date.day == day;
      }
    } catch (e) {
      // If an exception is thrown, it means the date is invalid
      return false;
    }
  }
}
