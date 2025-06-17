import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add dependency for loading indicator
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'dart:async';

import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/townhall/users_townhalls_response.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:shimmer/shimmer.dart';

class ListOfOrgMembers extends StatefulWidget {
  final String orgID;
  @override
  _ListOfOrgMembersState createState() => _ListOfOrgMembersState();
  ListOfOrgMembers({required this.orgID});
}

class _ListOfOrgMembersState extends State<ListOfOrgMembers> {
  // final String apiUrl =
  //     'https://townhall.empl-dev.com.ng/api/townhall/fetch_list_of_members';
  // final String blockUrl =
  //     'https://townhall.empl-dev.com.ng/api/orgs/block_and_unblock_member';
  final int limit = 20;
  int page = 1;

  bool isLoading = false;
  bool _isBlocking = false;
  bool _isRemoving = false;

  bool hasMore = true;
  List<dynamic> members = [];
  List<DataList> userTownhallList = []; //townhall list for login user

  final ScrollController _scrollController = ScrollController();

  String keyword = '';
  String townhallID = '';
  String _selectedID = '';
  String _userID = '';

  bool isAdmin = false; // Add this line to store the is_admin value
  bool isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _setUserID();
    if (widget.orgID != '2') //if the organization is not followers & followings
    {
      _fetchUserTownhalls();
      _fetchMembers();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _loadMore();
        }
      });
    }
  }

  void _onSearchChanged(String value) {
    print("Am here ${_debounce?.isActive}");
    //if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        hasMore = true;
        keyword = value;
        page = 1;
        members.clear();
      });
      _fetchMembers();
    });
  }

  Future<void> _fetchMembers() async {
    print("Request made");
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    var des = "${isLoading} ${hasMore}";
    print("Status $des");
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });
    print(
        "Limit: ${limit} townhallID ${townhallID} OrgID: ${widget.orgID} Page: ${page} Keyword: ${keyword}");
    try {
      print("Request made4");
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/townhall/fetch_list_of_members?limit=$limit&page=$page&keyword=$keyword&org_id=${widget.orgID}&townhall_id=$townhallID'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      print("Fields: ${response.headers}"); // Form fields
      //print("Headers: ${response.headers}"); // Headers including Authorization

      if (response.statusCode == 200) {
        print("Request made1");
        final data = json.decode(response.body);
        isAdmin = data['is_admin'] ?? false;

        final List<dynamic> newMembers =
            data['data'] is List ? List<dynamic>.from(data['data']) : [];

        setState(() {
          page++;
          isLoading = false;
          hasMore = newMembers.length == limit;
          //hasMore = true;
          members.addAll(newMembers);
        });
      } else {
        print("Request made2");
        _showSnackBar(
            'Failed to load members. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
          hasMore = false;
        });
      }
    } catch (e) {
      print("Request made3");
      _showSnackBar('An error occurred: $e');
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  void _fetchUserTownhalls() async {
    //fetch townhalls the login person belongs
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    print("print am here");
    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/orgs/fetch_users_townhalls?user_id=$userID&org_id=${widget.orgID}'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
      );
      print("Print: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData.containsKey('data')) {
          final dataList = jsonData['data'];
          if (dataList is List) {
            // setState(() {
            userTownhallList.addAll(
                dataList.map((json) => DataList.fromJson(json)).toList());
            //  });
            debugPrint("Townhalls: ${userTownhallList[0].name}");
          } else {
            _showSnackBar('An error occurred');
          }
        }
      } else {}
    } on FormatException catch (e) {
      _showSnackBar('An error occurred: $e');
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  void _loadMore() {
    if (!isLoading && hasMore) {
      _fetchMembers();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Display the snackbar with the appropriate color
    final color = isError ? Colors.red : Colors.green;
    // Code to show the snackbar, e.g., using ScaffoldMessenger
  }

  Future<void> _blockUser(String status, String userId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('${domainName}/api/orgs/block_and_unblock_member'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'status': status,
          'org_id': widget.orgID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isBlocking = false;
        });
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          print("Successfully blocked ${data['msg']}");
          final index = indexOf(_selectedID);

          if (index != -1) {
            setState(() {
              members[index]['member_status'] =
                  status == "block" ? 'blocked' : 'active';
            });
          }
          _showSnackBar('User successfully blocked');
        } else {
          _showSnackBar('Error: ${data['msg']}', isError: true);
        }
      } else {
        _showSnackBar(
            'Failed to block user. Status code: ${response.statusCode}',
            isError: true);
      }
    } on FormatException catch (e) {
      setState(() {
        _isBlocking = false;
      });
      debugPrint(e.source);
    } catch (e) {
      setState(() {
        _isBlocking = false;
      });
      _showSnackBar('${e.toString()}');
    }
  }

  Future<void> _showConfirmationDialog(String status, String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm ${status.capitalizeFirst} User'),
          content: Text('Are you sure you want to block this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                setState(() {
                  _selectedID = userId.toString();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('${status.capitalizeFirst}'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isBlocking = true;
                  _selectedID = userId.toString();
                });
                _blockUser(status, userId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialogForRemoval(
      String townhallID, String orgID, String subjectID) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content:
              Text('Are you sure you want to remove this person as a leader?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                setState(() {
                  _selectedID = '';
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedID = subjectID;
                  _isRemoving = true;
                });
                _removeUserFromLeadership(townhallID, orgID, subjectID);
              },
            ),
          ],
        );
      },
    );
  }

  void _showMakeLeaderBottomSheet(String orgID, String subjectID) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)), // Rounded corners
      ),
      builder: (BuildContext context) {
        final TextEditingController designationController =
            TextEditingController();

        return AssignLeader(
            hasSubmitted: _hasSubmitted, orgID: orgID, subjectID: subjectID);
        //return AssignLeader(orgID: '187508', subjectID: '117');
      },
    );
  }

  Future<void> _removeUserFromLeadership(
      String townhallID, String orgID, String subjectID) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('${domainName}/api/orgs/remove_from_leadership'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'the_user': subjectID,
          'org_id': orgID,
          'townhall_id': townhallID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isRemoving = false;
        });
        final data = json.decode(response.body);
        print("Am here ${data['msg']}");
        if (data['status'] == 200) {
          print("Successfully removed");
          final index = indexOf(_selectedID);
          if (index != -1) {
            setState(() {
              members[index]['is_townhall_leader'] = false;
              _selectedID = '';
            });
          }
          _showSnackBar('User successfully removed');
        } else {
          setState(() {
            _selectedID = '';
            _isRemoving = false;
          });
          _showSnackBar('Error: ${data['msg']}', isError: true);
        }
      } else {
        setState(() {
          _isRemoving = false;
          _selectedID = '';
        });
        _showSnackBar('Failed to remove user', isError: true);
      }
    } on FormatException catch (e) {
      setState(() {
        _isRemoving = false;
        _selectedID = '';
      });
      debugPrint(e.source);
    } catch (e) {
      setState(() {
        _isRemoving = false;
        _selectedID = '';
      });
      _showSnackBar('${e.toString()}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.orgID == '2'
        ? ListOfFollowersFollowings(orgID: widget.orgID)
        : OverlayLoaderWithAppIcon(
            isLoading: _isBlocking || _isRemoving ? true : false,
            overlayBackgroundColor: Colors.grey,
            circularProgressColor: Colors.blue,
            appIconSize: 25,
            appIcon: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                'images/icon_blue.png',
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Members'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearchVisible = !isSearchVisible;
                        if (!isSearchVisible) {
                          _searchController.clear();
                          keyword = '';
                          page = 1;
                          members.clear();
                          _fetchMembers();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list), // Filter icon
                    onPressed: () {
                      _showPopupMenu(context); // Show the popup menu
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  if (isSearchVisible)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search members...',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 15),
                      itemCount: members.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == members.length) {
                          return Center(
                            child: isLoading
                                ? Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: SpinKitCircle(
                                      color: Colors.blue,
                                      size: 30.0,
                                    ),
                                  )
                                : SizedBox.shrink(),
                          );
                        }

                        final member = members[index];
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: 15, left: 18, right: 18),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            padding: EdgeInsets.only(
                                left: 0, right: 0, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: member['member_status'] == "blocked"
                                  ? Colors.red[100]
                                  : Color.fromARGB(255, 230, 230, 230),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.only(right: 3, left: 10),
                              leading: InkWell(
                                onTap: () async {
                                  final userID =
                                      await AppSharedPreferences.getValue(
                                          key: 'user_id');
                                  Map<String, dynamic> mapData = {
                                    'subjectID': member['user_id'].toString(),
                                    'picture': member['profile_photo'],
                                    'post_update_by': member['firstname'] +
                                        ' ' +
                                        member['lastname'],
                                    'username': member['username'],
                                  };
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (contextA) => PeopleBloc(),
                                        ),
                                        BlocProvider(
                                          create: (context) => PostsBloc(),
                                        ),
                                      ],
                                      child: PeopleProfile(mapData: mapData),
                                    );
                                  }));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 221, 221, 221),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(member['profile_photo']),
                                    radius: 30,
                                  ),
                                ),
                              ),
                              title: InkWell(
                                onTap: () async {
                                  final userID =
                                      await AppSharedPreferences.getValue(
                                          key: 'user_id');
                                  Map<String, dynamic> mapData = {
                                    'subjectID': member['user_id'].toString(),
                                    'picture': member['profile_photo'],
                                    'post_update_by': member['firstname'] +
                                        ' ' +
                                        member['lastname'],
                                    'username': member['username'],
                                  };
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (contextA) => PeopleBloc(),
                                        ),
                                        BlocProvider(
                                          create: (context) => PostsBloc(),
                                        ),
                                      ],
                                      child: PeopleProfile(mapData: mapData),
                                    );
                                  }));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${member['firstname']} ${member['lastname']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '@${member['username']}${member['designation'] != null ? "\n${member['designation']}" : ""}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: isAdmin
                                  ? PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert,
                                          color: Colors.grey),
                                      onSelected: (String value) {
                                        if (value == 'block' ||
                                            value == 'unblock') {
                                          _showConfirmationDialog(
                                              value,
                                              member['user_id']
                                                  .toString()); // Assume member['id'] holds the user ID
                                        } else if (value == 'make_leader') {
                                          _showMakeLeaderBottomSheet(
                                              widget.orgID,
                                              member['user_id']
                                                  .toString()); // Call the bottom sheet with the user ID
                                        } else if (value == 'remove_leader') {
                                          //show confirmation dialogue
                                          _showConfirmationDialogForRemoval(
                                              townhallID,
                                              widget.orgID,
                                              member['user_id'].toString());
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        if (member['user_id'].toString() !=
                                                _userID &&
                                            isAdmin)
                                          PopupMenuItem<String>(
                                            value: member['member_status'] ==
                                                    "blocked"
                                                ? 'unblock'
                                                : 'block',
                                            child: Text(
                                                member['member_status'] ==
                                                        "blocked"
                                                    ? 'Unblock User'
                                                    : 'Block User'),
                                          ),
                                        if (member['user_id'].toString() !=
                                                _userID &&
                                            isAdmin)
                                          const PopupMenuDivider(),
                                        if (isAdmin)
                                          PopupMenuItem<String>(
                                            value:
                                                '${member['is_townhall_leader'] ? 'remove_leader' : 'make_leader'}',
                                            child: Text(
                                                '${member['is_townhall_leader'] ? 'Remove as townhall leader' : 'Make townhall leader'}'),
                                          ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  int indexOf(String selectedID) {
    int index = members
        .indexWhere((element) => element['user_id'].toString() == selectedID);
    return index;
  }

  void _showPopupMenu(BuildContext context) {
    if (userTownhallList.isEmpty) {
      _fetchUserTownhalls(); // Ensure townhalls are fetched before showing the popup
      return;
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60,
        AppBar().preferredSize.height,
        0.0,
        0.0,
      ),
      items: userTownhallList.map((townhall) {
        return PopupMenuItem(
          child: Text(townhall.name), // Display townhall name
          value: townhall.id.toString(), // Use townhall ID as value
        );
      }).toList(),
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        setState(() {
          townhallID = value.toString();
          page = 1; // Reset page to 1
          hasMore = true; // Reset hasMore flag
          members.clear(); // Clear existing members before fetching new ones
        });
        _fetchMembers(); // Fetch members based on the new townhallId
      }
    });
  }

  _setUserID() async {
    var userID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = userID.toString();
    });
  }

  _hasSubmitted(String subjectID, String designation) {
    final index = indexOf(subjectID);
    if (index != -1) {
      setState(() {
        members[index]['designation'] = designation;
      });
    }
    //
  }
}

class AssignLeader extends StatefulWidget {
  final Function(String, String) hasSubmitted;
  final String orgID;
  final String subjectID;
  const AssignLeader({
    required this.hasSubmitted,
    required this.orgID,
    required this.subjectID,
  });

  @override
  State<AssignLeader> createState() => _AssignLeaderState();
}

class _AssignLeaderState extends State<AssignLeader> {
  final TextEditingController designationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoadingTownhalls = true;
  bool isAssigning = false;

  List<DataList> townhallList = [];

  String selectedTownhall = '';
  @override
  void initState() {
    super.initState();
    _fetchTownhalls(widget.orgID, widget.subjectID);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to start
          children: [
            Text(
              'Make Townhall Leader',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Divider(
                thickness: 1,
                color: Colors.grey[300]), // Divider for separation
            SizedBox(height: 10),
            DropdownButtonFormField<DataList>(
              // value: selectedTownhall,
              decoration: InputDecoration(
                labelText:
                    isLoadingTownhalls ? 'Loading...' : 'Leadership Townhall',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: 10), // Padding for dropdown
              ),
              items: townhallList
                  .map<DropdownMenuItem<DataList>>((DataList value) {
                return DropdownMenuItem<DataList>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (DataList? newValue) {
                setState(() {
                  selectedTownhall = newValue!.id.toString();
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a townhall' : null,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: designationController,
              decoration: InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ), // Padding for text field
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a designation' : null,
            ),
            SizedBox(height: 10),
            Text(
              'This user will be able to make leadership posts in this townhall. '
              'If this townhall is not open for posting by members, this user will be able to post.',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16), // Adjust color and size
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // Makes the button full width
                child: ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () {
                          print(
                              "Is empty ${selectedTownhall} ${designationController.text}");
                          if (selectedTownhall == "" ||
                              designationController.text == "") {
                            Fluttertoast.showToast(
                              msg: "Empty field",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP, // Display at the top
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            _makeLeader(widget.orgID, widget.subjectID,
                                selectedTownhall!, designationController.text);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 15), // Button padding
                    backgroundColor: Colors.blue, // Blue background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  child: isAssigning
                      ? Container(
                          width: 45,
                          height: 45,
                          child: SpinKitCircle(
                            color: Colors.white,
                            size: 45.0,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, // White text color
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _fetchTownhalls(String orgID, String subjectID) async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    print("print am here");
    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/orgs/fetch_users_townhalls?user_id=$subjectID&org_id=$orgID'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
      );
      print("Print: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          isLoadingTownhalls = false;
        });
        if (jsonData is Map && jsonData.containsKey('data')) {
          final dataList = jsonData['data'];
          if (dataList is List) {
            setState(() {
              townhallList.addAll(
                  dataList.map((json) => DataList.fromJson(json)).toList());
            });
            print("Print Townhall: ${orgID} ${subjectID} ${dataList}");
          } else {
            _showSnackBar('An error occurred');
          }
        }
      } else {
        setState(() {
          isLoadingTownhalls = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingTownhalls = false;
      });
      _showSnackBar('An error occurred: $e');
    }
  }

  Future<void> _makeLeader(
      String orgID, String userId, String townhall, String designation) async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          isAssigning = true;
        });
      }
      try {
        final response = await http.post(
          Uri.parse('${domainName}/api/orgs/make_user_a_leader'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': authToken.toString(),
          },
          body: jsonEncode({
            'the_user': userId,
            'org_id': widget.orgID,
            'townhall_id': selectedTownhall,
            'designation': designationController.text
          }),
        );
        final resp = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (resp['status'] == 200) {
            widget.hasSubmitted(designationController.text, userId);
            debugPrint("Resp2: ${response.body}");
            if (mounted) {
              setState(() {
                isAssigning = false;
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'User promoted to leader successfully',
                  style: TextStyle(color: Colors.white),
                )));
            Navigator.of(context).pop(); // Close the bottom sheet
          } else {
            if (mounted) {
              setState(() {
                isAssigning = false;
              });
            }

            Fluttertoast.showToast(
              msg: "${resp['msg']}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP, // Display at the top
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              isAssigning = false;
            });
          }

          Fluttertoast.showToast(
            msg: "${resp['msg']}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP, // Display at the top
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isAssigning = false;
          });
        }

        Fluttertoast.showToast(
          msg: "${e}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP, // Display at the top
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
    // Placeholder success message
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Display the snackbar with the appropriate color
    final color = isError ? Colors.red : Colors.green;
    // Code to show the snackbar, e.g., using ScaffoldMessenger
  }
}

class ListOfFollowersFollowings extends StatefulWidget {
  String orgID;
  ListOfFollowersFollowings({required this.orgID, super.key});

  @override
  State<ListOfFollowersFollowings> createState() =>
      _ListOfFollowersFollowingsState();
}

class _ListOfFollowersFollowingsState extends State<ListOfFollowersFollowings> {
  final controller = TextEditingController();
  late ScrollController _scrollController;
  FocusNode _focus = FocusNode();

  final styleActive = TextStyle(color: Colors.black);
  final styleHint = TextStyle(color: Colors.black54);
  final style = TextStyle(color: Colors.black54);

  int _tabIndex = 0;
  int _selectedIndex = -1;
  int _limit = 25;
  int _currentPage = 1;
  int _totalFollowers = 0;
  int _totalFollowings = 0;

  String hintText = 'Search Followers';
  String _keyword = '';

  bool _isLoadingFollowers = true;
  bool _isLoadingFollowings = false;
  bool _isLoadingMore = false;

  List<dynamic> followings = [];
  List<dynamic> followers = [];

  void initState() {
    _scrollController = ScrollController();
    _focus.addListener(_onFocusChange);
    Future.delayed(Duration.zero, () {
      _fetchFollowings();
      _fetchFollowers();
    });
    super.initState();
  }

  @override
  void _onFocusChange() {
    // setState(() {
    //   refresh = true;
    // });
  }
  final debouncer = Debouncer(milliseconds: 1000);
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        statusBarColor: Theme.of(context).primaryColor,
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: DefaultTabController(
        length: 2,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.white, // Set status bar color to white
            ),
            child: Scaffold(
              body: WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 130,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            margin: EdgeInsets.only(
                                left: 15, right: 15, bottom: 25),
                            padding: EdgeInsets.only(
                              top: 20.0,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                height: 45,
                                margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.blue,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: TextField(
                                    controller: controller,
                                    focusNode: _focus,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.search,
                                          color: style.color),
                                      suffixIcon: controller.text.isNotEmpty
                                          ? GestureDetector(
                                              child: Icon(Icons.close,
                                                  color: style.color),
                                              onTap: () {
                                                controller.clear();
                                                if (_tabIndex == 0) {
                                                  setState(() {
                                                    followers = [];
                                                    _keyword = '';
                                                    _currentPage = 1;
                                                    _isLoadingFollowers = true;
                                                  });
                                                  _fetchFollowers();
                                                } else {
                                                  setState(() {
                                                    followings = [];
                                                    _keyword = '';
                                                    _currentPage = 1;
                                                    _isLoadingFollowings = true;
                                                  });
                                                  _fetchFollowings();
                                                }
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                              },
                                            )
                                          : null,
                                      hintText: hintText,
                                      hintStyle: style,
                                      border: InputBorder.none,
                                    ),
                                    style: style,
                                    onChanged: (val) {
                                      debouncer.run(() {
                                        if (_tabIndex == 0) {
                                          setState(() {
                                            _keyword = val;
                                            _currentPage = 1;
                                            _isLoadingFollowers = true;
                                          });
                                          _fetchFollowers();
                                        } else {
                                          setState(() {
                                            _keyword = val;
                                            _currentPage = 1;
                                            _isLoadingFollowings = true;
                                          });
                                          _fetchFollowings();
                                        }
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ),
                        bottom: TabBar(
                          onTap: (value) {
                            _tabIndex = value;
                            controller.clear();
                            if (_tabIndex == 0) {
                              if (followers.isEmpty) {
                                setState(() {
                                  hintText = 'Search Followers';
                                  _currentPage = 1;
                                });
                                _fetchFollowers();
                              } else {
                                setState(() {
                                  hintText = 'Search Followers';
                                  _currentPage =
                                      (followers.length / _limit).ceil();
                                });
                              }
                            } else {
                              if (followings.isEmpty) {
                                setState(() {
                                  hintText = 'Search Followings';
                                  _currentPage = 1;
                                });
                                _fetchFollowings();
                              } else {
                                setState(() {
                                  hintText = 'Search Followings';
                                  _currentPage =
                                      (followings.length / _limit).ceil();
                                });
                              }
                            }
                          },
                          indicatorWeight: 3,
                          indicatorColor: Colors.blueAccent,
                          tabs: [
                            Tab(
                              child: Text(
                                'Followers${_totalFollowers > 0 ? '($_totalFollowers)' : ''}',
                                style: TextStyle(
                                    color: _tabIndex == 0
                                        ? Colors.blue
                                        : Colors.black,
                                    fontWeight: _tabIndex == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Followings${_totalFollowings > 0 ? '($_totalFollowings)' : ''}',
                                style: TextStyle(
                                    color: _tabIndex == 1
                                        ? Colors.blue
                                        : Colors.black,
                                    fontWeight: _tabIndex == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      )
                    ];
                  },
                  body: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      // Check if the scroll is vertical
                      if (notification.metrics.axis == Axis.vertical) {
                        if (notification.scrollDelta! > 0) {
                          // Scrolling down
                          // if (mounted) {
                          //   setState(() {
                          //     _showBottomMenu = false;
                          //   });
                          // }
                        } else if (notification.scrollDelta! < 0) {
                          // Scrolling up
                          // if (mounted) {
                          //   setState(() {
                          //     _showBottomMenu = true;
                          //   });
                          // }
                        }

                        // Check if the scroll is within the desired Container
                        if (notification.context
                                ?.findAncestorWidgetOfExactType<Container>() !=
                            null) {
                          if (notification.metrics.extentAfter == 0) {
                            if (_tabIndex == 0) {
                              _fetchMoreFollowers();
                            } else {
                              _fetchMoreFollowings();
                            }
                            print(
                                "Bottom At bottom: ${notification.metrics.extentAfter}");
                          }
                        }
                      }
                      // Return true to continue receiving notifications
                      return true;
                    },
                    child: TabBarView(children: [
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 15, left: 18, right: 18),
                        child: _isLoadingFollowers
                            ? _buildShimmerLoader2()
                            : ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: followers.length +
                                    (_isLoadingMore && _tabIndex == 0 ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= followers.length) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 70,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      padding: EdgeInsets.only(
                                          left: 0, right: 0, top: 5, bottom: 5),
                                      decoration: BoxDecoration(
                                        color: followers[index]
                                                    ['member_status'] ==
                                                "blocked"
                                            ? Colors.red[100]
                                            : Color.fromARGB(
                                                255, 230, 230, 230),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.only(
                                            right: 12, left: 10),
                                        leading: InkWell(
                                          onTap: () async {
                                            final userID =
                                                await AppSharedPreferences
                                                    .getValue(key: 'user_id');
                                            Map<String, dynamic> mapData = {
                                              'subjectID': followers[index]
                                                      ['user_id']
                                                  .toString(),
                                              'picture': followers[index]
                                                  ['profile_photo'],
                                              'post_update_by': followers[index]
                                                      ['firstname'] +
                                                  ' ' +
                                                  followers[index]['lastname'],
                                              'username': followers[index]
                                                  ['username'],
                                            };
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (contextA) =>
                                                        PeopleBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        PostsBloc(),
                                                  ),
                                                ],
                                                child: PeopleProfile(
                                                    mapData: mapData),
                                              );
                                            }));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 221, 221, 221),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  followers[index]
                                                      ['profile_pic']),
                                              radius: 30,
                                            ),
                                          ),
                                        ),
                                        title: InkWell(
                                          onTap: () async {
                                            final userID =
                                                await AppSharedPreferences
                                                    .getValue(key: 'user_id');
                                            Map<String, dynamic> mapData = {
                                              'subjectID': followers[index]
                                                      ['user_id']
                                                  .toString(),
                                              'picture': followers[index]
                                                  ['profile_photo'],
                                              'post_update_by': followers[index]
                                                      ['firstname'] +
                                                  ' ' +
                                                  followers[index]['lastname'],
                                              'username': followers[index]
                                                  ['username'],
                                            };
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (contextA) =>
                                                        PeopleBloc(),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        PostsBloc(),
                                                  ),
                                                ],
                                                child: PeopleProfile(
                                                    mapData: mapData),
                                              );
                                            }));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${followers[index]['firstname']} ${followers[index]['lastname']}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '@${followers[index]['username']}${followers[index]['designation'] != null ? "\n${followers[index]['designation']}" : ""}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: _peopleBuildButtons(
                                            context,
                                            _tabIndex,
                                            index,
                                            followers[index]['user_id'],
                                            followers[index]
                                                ['you_are_following']),
                                      ));
                                }),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 15, left: 18, right: 18),
                        child: _isLoadingFollowings
                            ? _buildShimmerLoader2()
                            : ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: followers.length +
                                    (_isLoadingMore && _tabIndex == 1 ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= followings.length) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 70,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.only(
                                        left: 0, right: 0, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                      color: followings[index]
                                                  ['member_status'] ==
                                              "blocked"
                                          ? Colors.red[100]
                                          : Color.fromARGB(255, 230, 230, 230),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.only(right: 12, left: 10),
                                      leading: InkWell(
                                        onTap: () async {
                                          final userID =
                                              await AppSharedPreferences
                                                  .getValue(key: 'user_id');
                                          Map<String, dynamic> mapData = {
                                            'subjectID': followings[index]
                                                    ['user_id']
                                                .toString(),
                                            'picture': followings[index]
                                                ['profile_photo'],
                                            'post_update_by': followings[index]
                                                    ['firstname'] +
                                                ' ' +
                                                followings[index]['lastname'],
                                            'username': followings[index]
                                                ['username'],
                                          };
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (contextA) =>
                                                      PeopleBloc(),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      PostsBloc(),
                                                ),
                                              ],
                                              child: PeopleProfile(
                                                  mapData: mapData),
                                            );
                                          }));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 221, 221, 221),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                followings[index]
                                                    ['profile_pic']),
                                            radius: 30,
                                          ),
                                        ),
                                      ),
                                      title: InkWell(
                                        onTap: () async {
                                          final userID =
                                              await AppSharedPreferences
                                                  .getValue(key: 'user_id');
                                          Map<String, dynamic> mapData = {
                                            'subjectID': followings[index]
                                                    ['user_id']
                                                .toString(),
                                            'picture': followings[index]
                                                ['profile_photo'],
                                            'post_update_by': followings[index]
                                                    ['firstname'] +
                                                ' ' +
                                                followings[index]['lastname'],
                                            'username': followings[index]
                                                ['username'],
                                          };
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (contextA) =>
                                                      PeopleBloc(),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      PostsBloc(),
                                                ),
                                              ],
                                              child: PeopleProfile(
                                                  mapData: mapData),
                                            );
                                          }));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${followings[index]['firstname']} ${followers[index]['lastname']}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '@${followings[index]['username']}${followers[index]['designation'] != null ? "\n${followers[index]['designation']}" : ""}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: _peopleBuildButtons(
                                          context,
                                          _tabIndex,
                                          index,
                                          followings[index]['user_id'],
                                          true),
                                    ),
                                  );
                                }),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchFollowings() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final userID = await AppSharedPreferences.getValue(key: 'user_id');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/followings_of_viewed_user?viewed_user=$userID&limit=$_limit&page=$_currentPage&keyword=$_keyword'),
        headers: {
          'Authorization': authToken!,
        },
      );
      print("Field: ${response.request}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          debugPrint("Followings: " + data.toString());
          setState(() {
            _totalFollowings = data['total_followings'] ?? 0;
            followings.addAll(data['data']); // Append new events
            _isLoadingFollowings = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _isLoadingMore = false;
            _isLoadingFollowings = false;
          });
        }
      } else {
        setState(() {
          _isLoadingMore = false;
          _isLoadingFollowings = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _isLoadingFollowings = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('Please check your internet connection');
    } on FormatException catch (e) {
      setState(() {
        _isLoadingFollowings = false;
        _isLoadingMore = false;
      });
      debugPrint(e.source);
    } catch (e) {
      print("i am here now");
      debugPrint('${e}');
      setState(() {
        _isLoadingFollowings = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('$e');
    } finally {
      setState(() {
        _isLoadingFollowings = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchFollowers() async {
    try {
      print("am here");
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final userID = await AppSharedPreferences.getValue(key: 'user_id');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/followers_of_viewed_user?viewed_user=$userID&limit=$_limit&page=$_currentPage&keyword=$_keyword'),
        headers: {
          'Authorization': authToken!,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          print("am here2");
          setState(() {
            debugPrint("Followers: " + data.toString());
            _totalFollowers = data['total_followers'] ?? 0;
            followers.addAll(data['data']); // Append new events
            _isLoadingFollowers = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _isLoadingFollowers = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingFollowers = false;
          _isLoadingMore = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _isLoadingFollowers = false;
        _isLoadingMore = false;
      });
      //_showErrorDialog('Please check your internet connection');
    } on FormatException catch (e) {
      setState(() {
        _isLoadingFollowers = false;
        _isLoadingMore = false;
      });
      debugPrint(e.source);
    } catch (e) {
      print("i am here now");
      debugPrint('${e}');
      setState(() {
        _isLoadingFollowers = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('$e');
    } finally {
      setState(() {
        _isLoadingFollowers = false;
        _isLoadingMore = false;
      });
    }
  }

  // Fetch more followers for pagination
  Future<void> _fetchMoreFollowers() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchFollowers();
  }

  // Fetch more followings for pagination
  Future<void> _fetchMoreFollowings() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchFollowings();
  }

  Future<void> _follow(String subjectID) async {
    try {
      print("subjectID $subjectID");
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('${domainName}/api/townhall/createConnection'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'followee': subjectID,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "200") {
          setState(() {
            followers[_selectedIndex]['you_are_following'] = true;
            _selectedIndex = -1;
          });
        } else {
          _showErrorDialog(data['msg']);
        }
      } else {
        _showErrorDialog("http protocol error");
      }
    } on FormatException catch (e) {
      setState(() {
        _selectedIndex = -1;
      });
      debugPrint(e.source);
    } catch (e) {
      setState(() {
        _selectedIndex = -1;
      });
      _showErrorDialog('${e.toString()}');
    } finally {
      setState(() {
        _selectedIndex = -1;
      });
    }
  }

  Future<void> _unfollow(String subjectID) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('${domainName}/api/townhall/removeConnection'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'followee': subjectID,
        }),
      );
      print("here1");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['status'] == "200") {
          print("here2");
          if (_tabIndex == 1) {
            if (followings[_selectedIndex]['is_following_you']) {
              //add to list of followers
              setState(() {
                followers.add({
                  'user_id': followings[_selectedIndex]['user_id'],
                  'firstname': followings[_selectedIndex]['firstname'],
                  'lastname': followings[_selectedIndex]['lastname'],
                  'username': followings[_selectedIndex]['username'],
                  'you_are_following': false,
                  'profile_pic': followings[_selectedIndex]['profile_pic'],
                });
                _totalFollowers++;
              });
            }
            setState(() {
              followings.removeAt(_selectedIndex);
              _tabIndex = 1;
              _selectedIndex = -1;
            });
            _showErrorDialog("Successfully unfollowed");
          } else {
            setState(() {
              followers[_selectedIndex]['you_are_following'] = false;
              _selectedIndex = -1;
            });
          }
        } else {
          print("here3");
          _showErrorDialog(data['msg']);
        }
      } else {
        print("here4");
        setState(() {
          _selectedIndex = -1;
        });
        _showErrorDialog("http protocol error");
      }
    } on FormatException catch (e) {
      print("here5");
      setState(() {
        _selectedIndex = -1;
      });
      _showErrorDialog(e.source);
    } catch (e) {
      print("here6");
      setState(() {
        _selectedIndex = -1;
      });
      _showErrorDialog('${e.toString()}');
    } finally {
      print("here7");
      setState(() {
        _selectedIndex = -1;
      });
    }
  }

  Widget _peopleBuildButtons(BuildContext context, int tabIndex, int index,
      int subjectID, bool status) {
    return _tabIndex == tabIndex && _selectedIndex == index
        ? Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 50.0,
              height: 50.0,
              child: SpinKitCircle(
                color: Colors.blue,
                size: 30.0,
              ),
            ),
          )
        : GFButton(
            onPressed: () {
              setState(() {
                _selectedIndex = index;
              });
              if (_tabIndex == 0) {
                if (followers[index]['you_are_following']) {
                  //unfollow
                  _unfollow(subjectID.toString());
                } else {
                  _follow(subjectID.toString());
                }
              } else {
                _unfollow(subjectID.toString());
              }
            },
            //text: ("${_isFollowList[index] == true ? "Unfollow" : "Follow"}"),
            text: _tabIndex == 0 && status == false ? "Follow" : "Unfollow",
            shape: GFButtonShape.pills,
            // color:
            //     followers[index]['is_following'] == true ? Colors.red : Colors.blue,
            color: _tabIndex == 0 && status == false ? Colors.blue : Colors.red,
          );
  }

  Widget _buildShimmerLoader2() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 15),
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              height: 70,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
