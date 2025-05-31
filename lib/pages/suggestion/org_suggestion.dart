//import 'dart:html';
// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as post;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
// import 'package:mobilizer/bloc/suggestion/suggestion_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as people;
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/organization/organization_interest_response.dart';
// import 'package:mobilizer/models/organization/organization_response.dart';
import 'package:mobilizer/models/search/search_organization_response.dart';
import 'package:mobilizer/pages/feed/feed.dart';

import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/widget/bottom_sheet_pick_townhalls.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../common/common/navigation.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hexcolor/hexcolor.dart';

class OrgSuggestionScreen extends StatefulWidget {
  static String routeName = 'org_suggestion_screen';

  const OrgSuggestionScreen({Key? key}) : super(key: key);

  @override
  _OrgSuggestionScreenState createState() => _OrgSuggestionScreenState();
}

class _OrgSuggestionScreenState extends State<OrgSuggestionScreen> {
  final controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final styleActive = TextStyle(color: Colors.black);
  final styleHint = TextStyle(color: Colors.black54);
  final style = TextStyle(
    color: Colors.black54,
  );
  List<OrganizationData> orgData = [];
  List<InterestData> interestData = [];
  List<dynamic> _isJoinList = [];
  bool refresh = false;
  bool isSuccessful = false; //Query is successful
  int _clickedID = 0; //org_id
  int _selectedInterest = -1;
  double _interestPadding = 26.0;
  int _maxFollow = 0;
  int count = 0;
  bool loading = true; //loader
  bool noResult = false;
  String showLoaderFor = "";
  String _selectedOrgID = "";
  int countFollowedGroups = 0;

  final String hintText = 'Search';

  // int selectedNumber = 1000;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<OrganizationBloc>(context).add(GetInterestEvent());
    });
    BlocProvider.of<OrganizationBloc>(context)
        .add(SearchOrganizationEvent(term: '', interest_id: ''));
    // Future.delayed(Duration.zero, () {
    //   BlocProvider.of<SuggestionBloc>(context).add(GetOrganizationEvent());
    // });
    _focus.addListener(_onFocusChange);
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        setState(() {
          _interestPadding = 26.0;
        });
      } else {
        setState(() {
          _interestPadding = 0.0;
        });
      }
    });
    super.initState();
  }

  FocusNode _focus = FocusNode();
  @override
  void _onFocusChange() {
    // setState(() {
    //   refresh = true;
    // });
  }
  final debouncer = Debouncer(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // return Text("Testing");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.white,
          title: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  'Find Organization',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 25),
                  child: Text(
                    'You need to join an Organization',
                    //${1 - countFollowedGroups} Organization',
                    style: TextStyle(color: Color(0xff00AFEF), fontSize: 15),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        body: BlocConsumer<OrganizationBloc, OrganizationState>(
          listener: (context, state) {
            // if (state is GetOrganizationState) {
            //   loading = false;
            //   isSuccessful = true;
            //   data = state.getOrganizationResponse.data;
            //   _maxFollow = state.getOrganizationResponse.max_follow == null
            //       ? 0
            //       : int.parse(state.getOrganizationResponse.max_follow);
            // }
            if (state is SearchOrganizationState) {
              setState(() {
                loading = false;
                isSuccessful = true;

                orgData = state.searchOrganizationResponse.data!;
              });
            }
            if (state is GetInterestState) {
              setState(() {
                loading = false;
                noResult = false;
                interestData = state.getInterestResponse.data;
              });
            }
            if (state is NoReturnState) {
              setState(() {
                loading = false;
                noResult = true;
                isSuccessful = true;
              });
            }
            if (state is NetworkState) {
              setState(() {
                loading = false;
              });
              isSuccessful = false;
              print(state.message);
              // loading = false;
              showLoaderFor = "";
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is LeaveState) {
              print("am inside leave");

              setState(() {
                if (countFollowedGroups > 0) {
                  countFollowedGroups = countFollowedGroups - 1;
                }
                showLoaderFor = "";
                loading = false;
                noResult = false;
                _isJoinList[_clickedID] = !_isJoinList[_clickedID];
              });
              print("Am inside leave view state");
              print("x new countFollowedGroup: ${countFollowedGroups}");
              isSuccessful = true;
              // BlocProvider.of<SuggestionBloc>(context)
              //     .add(GetOrganizationEvent());
            }
            if (state is JoinState) {
              setState(() {
                loading = false;
                showLoaderFor = "";
                _isJoinList[_clickedID] = !_isJoinList[_clickedID];
                countFollowedGroups = countFollowedGroups + 1;
              });
              print("Am inside join state now");
              isSuccessful = true;
              // BlocProvider.of<SuggestionBloc>(context)
              //     .add(GetOrganizationEvent());
              // if (countFollowedGroups >= _maxFollow) {
              //   Navigation.intentWithClearAllRoutes(
              //       context, HomeScreen.routeName);
              // }
            }
            if (state is ShowBottomSheetState) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return TownhallBottomSheet(
                      getDropDownList: state.getDropDownList,
                      orgID: _selectedOrgID,
                      hasJoined: _hasJoined);
                },
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Padding(
                //   padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                //   child: Container(
                //     height: 45,
                //     margin: const EdgeInsets.fromLTRB(10, 1, 10, 10),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(12),
                //       color: Colors.white,
                //       border: Border.all(
                //         color: Colors.blue,
                //       ),
                //     ),
                //     padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                //     child: TextField(
                //         textAlignVertical: TextAlignVertical.center,
                //         controller: controller,
                //         focusNode: _focus,
                //         decoration: InputDecoration(
                //           icon: Icon(Icons.search, color: style.color),
                //           prefixIcon: Icon(Icons.search),
                //           suffixIcon: controller.text.isNotEmpty
                //               ? GestureDetector(
                //                   child: Icon(Icons.close, color: style.color),
                //                   onTap: () {
                //                     setState(() {
                //                       _selectedInterest = 0;
                //                       _scrollController.jumpTo(0);
                //                       noResult = false;
                //                       loading = true;
                //                     });
                //                     controller.clear();

                //                     orgData = [];

                //                     BlocProvider.of<OrganizationBloc>(context)
                //                         .add(SearchOrganizationEvent(
                //                             term: '', interest_id: ''));

                //                     FocusScope.of(context)
                //                         .requestFocus(FocusNode());
                //                   },
                //                 )
                //               : null,
                //           hintText: hintText,
                //           hintStyle: style,
                //           border: InputBorder.none,
                //         ),
                //         style: style,
                //         onChanged: (val) {
                //           debouncer.run(() {
                //             setState(() {
                //               loading = true;
                //               _selectedInterest = 0;
                //               _scrollController.jumpTo(0);
                //               noResult = false;
                //               orgData = [];
                //               _isJoinList = [];
                //             });
                //             BlocProvider.of<OrganizationBloc>(context).add(
                //                 SearchOrganizationEvent(
                //                     term: val, interest_id: ''));
                //           });
                //         }),
                //   ),
                // ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.15,
                  child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: controller,
                      focusNode: _focus,
                      decoration: InputDecoration(
                        // labelText: 'Search',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        hintText: hintText,
                        hintStyle: style,

                        // border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: controller.text.isNotEmpty
                              ? Icon(Icons.close, color: style.color)
                              : SizedBox
                                  .shrink(), // Hide close icon when text is empty
                          onPressed: () {
                            setState(() {
                              _selectedInterest = 0;
                              //_scrollController.jumpTo(0);
                              noResult = false;
                              loading = true;
                            });
                            controller.clear();
                            orgData = [];
                            BlocProvider.of<OrganizationBloc>(context)
                                .add(SearchOrganizationEvent(
                              term: '',
                              interest_id: '',
                            ));
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                              style: BorderStyle.solid),
                        ),
                      ),
                      style: style,
                      onChanged: (val) {
                        debouncer.run(() {
                          setState(() {
                            loading = true;
                            _selectedInterest = 0;
                            //_scrollController.jumpTo(0);
                            noResult = false;
                            orgData = [];
                            _isJoinList = [];
                          });
                          BlocProvider.of<OrganizationBloc>(context).add(
                              SearchOrganizationEvent(
                                  term: val, interest_id: ''));
                        });
                      }),
                ),
                // SizedBox(height: 10),
                // Container(
                //   padding: EdgeInsets.only(left: _interestPadding),
                //   height: 50,
                //   width: double.infinity,
                //   child: Column(children: [
                //     Expanded(
                //       child: ListView.builder(
                //         controller: _scrollController,
                //         scrollDirection: Axis.horizontal,
                //         itemCount: interestData.length,
                //         itemBuilder: (context, index) {
                //           final interest = interestData[index];
                //           if (interest.id == 0 && _selectedInterest == -1) {
                //             _selectedInterest = index;
                //           }

                //           return Column(
                //             children: [
                //               SizedBox(
                //                 height: 10,
                //               ),
                //               GestureDetector(
                //                 onTap: () {
                //                   print("Interest ID: ${interest.id}");
                //                   setState(() {
                //                     _selectedInterest = index;
                //                     controller.text = "";
                //                     loading = true;
                //                     orgData = [];
                //                     noResult = false;
                //                     _isJoinList = [];
                //                   });

                //                   BlocProvider.of<OrganizationBloc>(context).add(
                //                       SearchOrganizationEvent(
                //                           term: '',
                //                           interest_id:
                //                               interestData[index].id.toString()));
                //                 },
                //                 child: Container(
                //                   alignment: Alignment.center,
                //                   height: 32,
                //                   padding: EdgeInsets.symmetric(horizontal: 10),
                //                   margin: EdgeInsets.only(right: 10),
                //                   decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.circular(12),
                //                     color: _selectedInterest == index
                //                         ? HexColor('#9EDCFF')
                //                         : Colors.white,
                //                     border: Border.all(
                //                       color: _selectedInterest == index
                //                           ? Colors.white
                //                           : HexColor('#00AFEF'),
                //                     ),
                //                   ),
                //                   child: Text(
                //                     "${interest.name}",
                //                     style: TextStyle(
                //                         fontSize: 14,
                //                         fontWeight: _selectedInterest == index
                //                             ? FontWeight.bold
                //                             : FontWeight.normal,
                //                         color: _selectedInterest == index
                //                             ? HexColor('#000000')
                //                             : HexColor('#000000')),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           );
                //         },
                //       ),
                //     )
                //   ]),
                // ),

                if (loading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4.0,
                      ),
                      Center(
                        child: Container(
                          width: 80.0,
                          height: 80.0,
                          child: SpinKitCircle(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (noResult && loading == false)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 6.0,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/no-org.png',
                              width: 150,
                              height: 150,
                            ),
                            Text("Search for Organization"),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Divider(height: 2),
                            ),
                        itemCount: orgData.length,
                        itemBuilder: (context, index) {
                          final organization = orgData[index];

                          final bool isMember =
                              organization.is_member == "yes" ? true : false;
                          _isJoinList.add(isMember);
                          if (_isJoinList[index] == false &&
                              organization.is_member == "yes") {
                            countFollowedGroups++;
                          }

                          return ListTile(
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: width / 2.6,
                                  child: Text(
                                    '${organization.org_name}',
                                    //'I have a dream a song to sing to help me cope with any thing if you see me wonder',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                organization.verified == "yes"
                                    ? SizedBox(
                                        child: Image.asset(
                                          'images/tag.png',
                                          //fit: BoxFit.contain,
                                          width: 22,
                                          height: 22,
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            subtitle: Text(
                              '${organization.org_about}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  '${organization.picture}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            trailing: showLoaderFor == index.toString()
                                ? Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: SpinKitCircle(
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                  )
                                : _isJoinList[index] == true
                                    ? Image.asset(
                                        'images/check.png',
                                        fit: BoxFit.contain,
                                      )
                                    : GFButton(
                                        onPressed:
                                            showLoaderFor != index.toString() &&
                                                    showLoaderFor != ""
                                                ? null
                                                : () {
                                                    _clickedID = index;
                                                    setState(() {
                                                      showLoaderFor =
                                                          index.toString();
                                                      _selectedOrgID =
                                                          organization.org_id
                                                              .toString();
                                                    });
                                                    print(
                                                        "Clicked ID:${_clickedID}");
                                                    if (organization
                                                            .requires_confirmation ==
                                                        "no") {
                                                      BlocProvider.of<
                                                                  OrganizationBloc>(
                                                              context)
                                                          .add(JoinEvent(
                                                              org_id: organization
                                                                  .org_id
                                                                  .toString()));
                                                    } else {
                                                      _loadEndPoint(
                                                          organization.org_id
                                                              .toString(),
                                                          context);
                                                    }
                                                  },
                                        text:
                                            ("${_isJoinList[index] == true ? 'Leave' : 'Join'}"),
                                        shape: GFButtonShape.pills,
                                        color: _isJoinList[index] == true
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                          );
                        }),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                child: SizedBox(
                  child: GestureDetector(
                    onTap: countFollowedGroups < 1
                        ? null
                        : () async {
                            PackageInfo packageInfo =
                                await PackageInfo.fromPlatform();

                            //clear orgID
                            await AppSharedPreferences.removeValue(
                                key: 'orgID');
                            await AppSharedPreferences.removeValue(
                                key: 'orgName');
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (contextA) => people.PeopleBloc(),
                                  ),
                                  BlocProvider(
                                    create: (context) => post.PostsBloc(),
                                  ),
                                  BlocProvider(
                                      create: (context) => OrganizationBloc()),
                                ],
                                child: Feed(),
                              );
                            }));
                          },
                    child: Container(
                      height: 60,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: countFollowedGroups < 1
                              ? Colors.black26
                              : Colors.green,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                            color: countFollowedGroups < 1
                                ? Colors.black26
                                : Colors.white),
                      ),
                    ),
                  ),
                  // GFButton(
                  //     shape: GFButtonShape.pills,
                  //     color:
                  //         countFollowedGroups < 1 ? Colors.black26 : Colors.green,
                  //     size: GFSize.MEDIUM,
                  //     textColor:
                  //         countFollowedGroups < 1 ? Colors.black26 : Colors.white,
                  //     text: 'Proceed',
                  //     onPressed: countFollowedGroups < 1
                  //         ? null
                  //         : () async {
                  //             PackageInfo packageInfo =
                  //                 await PackageInfo.fromPlatform();

                  //             Navigation.intentWithClearAllRoutes(
                  //                 context, HomeScreen.routeName);
                  //           }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String? _getButtonText(member) {
  //   if (member == "yes") {
  //     return "Leave";
  //   } else if (member == "no") {
  //     return "Join";
  //   } else {
  //     return "Pending";
  //   }
  // }

  // Color _getButtonColor(member) {
  //   Color color;
  //   if (member == "yes") {
  //     color = Colors.red;
  //   } else if (member == "no") {
  //     color = Colors.blue;
  //   } else {
  //     color = Colors.grey;
  //   }
  //   return color;
  // }

  void _loadEndPoint(String orgID, BuildContext cont) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: _isJoinList[_clickedID] == true
              ? Text(
                  "Are you sure you want to leave this organization? You will need to join and be approved to get back in")
              : Text(
                  "Are you sure you want to join? Your join request will be pending until approved by the organization"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _clickedID = 0;
                  showLoaderFor = '';
                });
              },
              child: Text(
                "No",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.black45),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_isJoinList[_clickedID] == true) {
                  print("Before leave: ${countFollowedGroups}");
                  BlocProvider.of<OrganizationBloc>(cont)
                      .add(LeaveEvent(org_id: orgID.toString()));
                } else {
                  BlocProvider.of<OrganizationBloc>(cont)
                      .add(JoinEvent(org_id: orgID.toString()));
                }
                Navigator.pop(context);
                setState(() {
                  showLoaderFor = _clickedID.toString();
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _hasJoined(bool status, String orgID) {
    if (status == true) {
      print("_hasJoined was called");
      setState(() {
        loading = false;
        showLoaderFor = "";
        _selectedOrgID = "";
        _isJoinList[_clickedID] = !_isJoinList[_clickedID];
        countFollowedGroups = countFollowedGroups + 1;
      });
    }
  }
}

class Debouncer {
  final int milliseconds;

  VoidCallback? action;
  Timer? _timer;
  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
