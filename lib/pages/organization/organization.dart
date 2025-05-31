import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/add_organizations.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as p;
import 'package:mobilizer/pages/organization/list_of_org_members.dart';
import 'package:mobilizer/pages/organization/my_organizations.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/organization/organization_edit.dart';

import 'package:mobilizer/pages/organization/add_org_coming_soon.dart';


import 'package:mobilizer/widget/bottom_sheet_invite_user.dart';
import 'package:mobilizer/widget/bottom_sheet_pick_edit_townhalls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart'; // Add provider package
import 'package:mobilizer/common/common/theme_provider.dart'; // Import ThemeProvider

import '../../models/organization/organization_ccf_response.dart';

class OrganizationScreen extends StatefulWidget {
  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
  bool reload;
  OrganizationScreen({this.reload = false});

  static String routeName = 'search_organization';
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  List<Organization> _organizations = [];
  List<Organization> _filteredOrganizations = [];
  List<Data> ccfData = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int limit = 10;
  int page = 1;
  bool _isSearchVisible = false;
  bool _isLoading = true;
  bool _isFetching = false;
  bool _requestIsOngoing = true;

  @override
  void initState() {
    super.initState();
    if (widget.reload == false) {
      _getCachedData();
    }
    _fetchOrganizations('first_time');
    _scrollController.addListener(_scrollListener);
  }

  void _toggleSearchVisibility() {
    if (mounted) {
      setState(() {
        _isSearchVisible = !_isSearchVisible;
        if (!_isSearchVisible) {
          _searchController.clear();
          _filterOrganizations('');
        }
      });
    }
  }

  Offset _tapPosition = Offset.zero;
  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    if (mounted)
      setState(() {
        _tapPosition = referenceBox.globalToLocal(details.globalPosition);
      });
    debugPrint("Tap: ${_tapPosition}");
  }

  Future<void> _fetchOrganizations([String? firstLoad]) async {
    var i = 0;
    print("Request ${i}");
    print("This is first: ${firstLoad}");
    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");
    if (mounted)
      setState(() {
        _requestIsOngoing = true;
      });
    try {
      print(
          "Request Link: ${base_url}orgs/orgs_user_joined?limit=$limit&page=${page}");
      final response = await http.get(
        Uri.parse(
            '${base_url}orgs/orgs_user_joined?limit=$limit&page=${page}'),
        headers: {
          'Authorization': token!,
        },
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          final dataList = responseData['data'];
          if (dataList is List) {
            print("This dataList: ${dataList}");
            print("Request is fetching: ${_isFetching}");
            print("Request Limit: ${limit} Page: ${page}");
            if (mounted)
              setState(() {
                if (page == 1) {
                  print("Request R");
                  _organizations = [];
                } else {
                  print("Request R else");
                }
                _organizations.addAll(dataList
                    .map((json) => Organization.fromJson(json))
                    .toList());
                _filteredOrganizations = _organizations;
                if (page == 1) {
                  List<Map<String, dynamic>> orgsToJson =
                      _organizations.map((org) => org.toJson()).toList();
                  AppSharedPreferences.setValue(
                      key: 'page_organization', value: jsonEncode(orgsToJson));
                }
                _isLoading = false;
                page++;
                _isFetching = false;
              });
            if (mounted)
              setState(() {
                _requestIsOngoing = false;
              });
          } else {
            if (mounted)
              setState(() {
                _requestIsOngoing = false;
                _isFetching = false;
              });
            throw Exception('Invalid response format: data is not a list');
          }
        } else {
          if (mounted)
            setState(() {
              _requestIsOngoing = false;
              _isFetching = false;
            });
          throw Exception(
              'Invalid response format: data field is missing or not a list');
        }
      } else {
        if (mounted)
          setState(() {
            _requestIsOngoing = false;
            _isFetching = false;
          });
        print("This is response else: ${response.body}");
        throw Exception('Failed to load organizations: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _requestIsOngoing = false;
          _isFetching = false;
        });
      print('Error fetching organizations: $e');
    }
  }

  void _filterOrganizations(String query) {
    if (mounted)
      setState(() {
        _filteredOrganizations = _organizations
            .where((org) =>
                org.orgName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _requestIsOngoing == false) {
      print("Am here!");
      if (mounted)
        setState(() {
          _isFetching = true;
        });
      _fetchOrganizations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          // Trigger on right-to-left swipe (negative velocity)
          if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
            Navigator.pop(context); // Close the screen
          }
        },
        child: Scaffold(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            title: Text(
              'Joined Organizations',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 1,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: _toggleSearchVisibility,
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                      create: (context) => OrganizationBloc(),
                      child: AddOrganizationComingSoon(),
                    );
                  }));
                },
              ),
            ],
          ),
          body: _isLoading
              ? _buildShimmerList()
              : _buildOrganizationList(),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Shimmer.fromColors(
            baseColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrganizationList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        SizedBox(height: 25),
        AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: _isSearchVisible ? 1.0 : 0.0,
          child: _isSearchVisible
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey,
                      ),
                      color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      onChanged: _filterOrganizations,
                    ),
                  ),
                )
              : SizedBox(),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _filteredOrganizations.length + (_isFetching ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _filteredOrganizations.length) {
                final organization = _filteredOrganizations[index];
                final backgroundColor = organization.defaultTownhall
                    ? (themeProvider.isDarkMode
                        ? Color.fromARGB(255, 50, 100, 150)
                        : Color.fromARGB(255, 183, 219, 253))
                    : (themeProvider.isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Color.fromARGB(255, 230, 230, 230));

                return Padding(
                  padding: EdgeInsets.only(top: 15, left: 18, right: 18),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 3),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: organization.joinStatus == "pending"
                          ? Colors.amber.withOpacity(0.3)
                          : organization.joinStatus == "block"
                              ? Colors.red.withOpacity(0.3)
                              : backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) => _getTapPosition(details),
                      onTap: () async {
                        if (organization.joinStatus != "yes") {
                          _showSuccessDialog(organization.joinStatusMessage);
                        } else {
                          var pageData = await getPageData('page_organization');
                          if (pageData != null) {
                            var json = jsonDecode(pageData);
                          }
                          print("Clicked OrgName: ${organization.orgName}");
                          await AppSharedPreferences.setValue(
                              key: 'orgID', value: organization.orgID.toString());
                          await AppSharedPreferences.setValue(
                              key: 'orgName', value: organization.orgName.toString());
                          await AppSharedPreferences.setValue(key: 'groupID', value: '');
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          Set<String> keys = prefs.getKeys();
                          List<String> filteredKeys =
                              keys.where((key) => key.contains("page_feed_")).toList();
                          if (filteredKeys.isNotEmpty) {
                            for (var i = 0; i < filteredKeys.length; i++) {
                              await AppSharedPreferences.removeValue(
                                  key: filteredKeys[i]);
                            }
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (context) => p.PostsBloc()),
                                BlocProvider(create: (context) => OrganizationBloc()),
                              ],
                              child: FeedOutsidePage(),
                            );
                          }));
                        }
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 15, right: 15),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[700]!
                                  : Color.fromARGB(255, 221, 221, 221),
                              width: 1.0,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(organization.picture),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              organization.orgName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              organization.about,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            organization.unread == 0
                                ? SizedBox()
                                : NotificationBadge(count: int.parse(organization.unread.toString())),
                            SizedBox(width: 20),
                            Builder(
                              builder: (context) {
                                return InkWell(
                                  splashColor: Colors.black.withOpacity(0.2),
                                  onTapDown: (TapDownDetails details) {
                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final Offset offset =
                                        renderBox.localToGlobal(details.localPosition);
                                    showMenu<String>(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        offset.dx,
                                        offset.dy,
                                        offset.dx + 1,
                                        offset.dy + 1,
                                      ),
                                      items: [
                                        PopupMenuItem<String>(
                                          height: 40.0,
                                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                          value: 'Details',
                                          child: Text(
                                            'Details',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                        if (organization.canUpdateTownhalls &&
                                            organization.joinStatus == "yes")
                                          PopupMenuItem<String>(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            value: 'Update',
                                            child: Text(
                                              'Update My Townhalls',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        if (organization.canUpdateTownhalls &&
                                            organization.joinStatus == "yes")
                                          const PopupMenuDivider(),
                                        if (organization.canEditOrganization &&
                                            organization.joinStatus == "yes")
                                          PopupMenuItem<String>(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            value: 'Edit',
                                            child: Text(
                                              'Edit Organization',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        if (organization.canEditOrganization &&
                                            organization.joinStatus == "yes")
                                          const PopupMenuDivider(),
                                        if (organization.joinStatus == "yes")
                                          PopupMenuItem<String>(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            value: 'Manage',
                                            child: Text(
                                              'Members',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        if (organization.showInviteTab) const PopupMenuDivider(),
                                        if (organization.showInviteTab)
                                          PopupMenuItem<String>(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            value: 'Join',
                                            child: Text(
                                              'Invite to Join',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                      ],
                                      color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                    ).then((value) {
                                      if (value != null) {
                                        final mapData = {
                                          'org_id': organization.orgID,
                                          'org_bg': organization.orgBG,
                                          'org_about': organization.about,
                                          'org_name': organization.orgName,
                                          'org_member_count': organization.orgMemberCount,
                                          'join_status': organization.joinStatus,
                                          'username': organization.orgUsername,
                                          'picture': organization.picture,
                                          'member': '',
                                          'isLeader': organization.isLeader,
                                          'verified': organization.verified == true ? "yes" : "no",
                                          'unread': organization.unread,
                                          'pinned': organization.pinned == true ? "yes" : "no"
                                        };
                                        if (value == 'Details') {
                                          print("Join Status: ${organization.joinStatus}");
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (contextA) => OrganizationBloc()),
                                              ],
                                              child: OrganizationDetails(mapData: mapData),
                                            );
                                          }));
                                        } else if (value == 'Manage') {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (contextA) => OrganizationBloc()),
                                              ],
                                              child: ListOfOrgMembers(orgID: organization.orgID),
                                            );
                                          }));
                                        } // Inside _buildOrganizationList, replace the showMenu logic for the 'Edit' option
                                          else if (value == 'Edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                              return MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(create: (context) => OrganizationBloc()),
                                                  BlocProvider(create: (context) => p.PostsBloc()),
                                                ],
                                                child: OrganizationEdit(
                                                  orgId: organization.orgID,
                                                  picture: organization.picture,
                                                  orgBg: organization.orgBG,
                                                  orgName: organization.orgName,
                                                  username: organization.orgUsername,
                                                  orgAbout: organization.about,
                                                  onSuccess: () {
                                                    // Handle successful update or deletion
                                                    setState(() {
                                                      _isLoading = true; // Show loading while refreshing
                                                    });
                                                    _fetchOrganizations('first_time'); // Refresh organization list
                                                    Navigator.pop(context); // Return to OrganizationScreen
                                                  },
                                                  onError: (message) {
                                                    // Handle error
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(message),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }));
                                          } else if (value == 'Join') {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (BuildContext context) {
                                                return InviteBottomSheet(
                                                    orgID: organization.orgID,
                                                    orgName: organization.orgName);
                                              });
                                        } else if (value == 'Update') {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return TownhallBottomSheetEdit(
                                                orgID: organization.orgID,
                                                hasUpdated: _hasUpdated,
                                              );
                                            },
                                          );
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 30,
                                    child: Icon(
                                      organization.isAdmin ? Icons.more_horiz : Icons.more_vert,
                                      color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return _buildLoader();
              }
            },
          ),
        ),
      ],
    );
  }

  void _hasUpdated(bool status) {
    if (status) {
      _isLoading = false;
    }
  }

  void _showSuccessDialog(String msg) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Notification',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            '$msg',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            themeProvider.isDarkMode ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _openOrganizationScreen(BuildContext context, int indexID) async {
    Navigator.pushNamed(context, OrganizationDetails.routeName,
        arguments: _organizations[indexID]);
  }

  void _getCachedData() async {
    var pageData = await getPageData('page_organization');
    if (pageData != null) {
      print("Cache data available");
      var json = jsonDecode(pageData);
      if (mounted) {
        setState(() {
          _organizations =
              json.map<Organization>((json) => Organization.fromJson(json)).toList();
          _filteredOrganizations =
              json.map<Organization>((json) => Organization.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;

  NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// The Organization class remains unchanged unless you want to adjust its properties for theming
class Organization {
  String orgID;
  String? townhallID;
  String orgName;
  String orgBG;
  String orgMemberCount;
  String joinStatus;
  String joinStatusMessage;
  String orgUsername;
  String about;
  bool missingCustomOrgTownhalls;
  String picture;
  bool verified;
  bool isLeader;
  bool member;
  bool isAdmin;
  int unread;
  bool pinned;
  bool canUpdateTownhalls;
  bool canEditOrganization;
  bool showMembersList;
  bool canInvite;
  bool defaultTownhall;
  bool showInviteTab;

  Organization({
    required this.orgID,
    this.townhallID,
    required this.orgName,
    required this.orgBG,
    required this.orgMemberCount,
    required this.joinStatus,
    required this.joinStatusMessage,
    required this.orgUsername,
    required this.about,
    required this.missingCustomOrgTownhalls,
    required this.picture,
    required this.verified,
    required this.isLeader,
    required this.member,
    required this.isAdmin,
    required this.unread,
    required this.pinned,
    required this.canUpdateTownhalls,
    required this.canEditOrganization,
    required this.showMembersList,
    required this.canInvite,
    required this.defaultTownhall,
    required this.showInviteTab,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    print('JSON Data: $json');
    return Organization(
        orgID: json['org_id'].toString(),
        townhallID: json['townhall_id'],
        orgName: json['org_name'] ?? '',
        orgBG: json['org_bg'] ?? '',
        orgMemberCount: json['org_member_count'] ?? '',
        joinStatus: json['join_status'] ?? '',
        joinStatusMessage: json['join_status_message'] ?? '',
        orgUsername: json['org_username'] ?? '',
        about: json['org_about'] ?? '',
        missingCustomOrgTownhalls: json['missing_custom_org_townhalls'] ?? false,
        picture: json['picture'] ?? '',
        verified: json['verified'] == "yes" ? true : false,
        isLeader: json['is_leader'] == "yes" ? true : false,
        member: json['member'] == "yes" ? true : false,
        isAdmin: json['is_admin'],
        unread: json['unread'] is int
            ? json['unread']
            : int.tryParse(json['unread'].toString()) ?? 0,
        pinned: json['pinned'] == "yes" ? true : false,
        canUpdateTownhalls: json['can_update_subtownhalls'] ?? false,
        canEditOrganization: json['can_edit_org'] ?? false,
        showMembersList: json['show_members_list'] ?? false,
        canInvite: json['can_invite'] ?? false,
        defaultTownhall: json['default_townhall'] ?? false,
        showInviteTab: json['show_invite_tab'] ?? false);
  }

  Map<String, dynamic> toJson() => {
        'org_id': orgID,
        'townhall_id': townhallID,
        'org_name': orgName,
        'org_bg': orgBG,
        'org_member_count': orgMemberCount,
        'join_status': joinStatus,
        'join_status_message': joinStatusMessage,
        'org_username': orgUsername,
        'org_about': about,
        'missing_custom_org_townhalls': missingCustomOrgTownhalls,
        'picture': picture,
        'verified': verified,
        'is_leader': isLeader,
        'member': member,
        'is_admin': isAdmin,
        'unread': unread,
        'pinned': pinned,
        'can_update_subtownhalls': canUpdateTownhalls,
        'can_edit_org': canEditOrganization,
        'show_members_list': showMembersList,
        'can_invite': canInvite,
        'default_townhall': defaultTownhall,
        'show_invite_tab': showInviteTab,
      };
}

class MyDialogu extends StatefulWidget {
  final String orgName;
  final String townhallID;
  final String orgID;

  const MyDialogu(
      {required this.orgName, required this.townhallID, required this.orgID});
  @override
  State<MyDialogu> createState() => _MyDialoguState();
}

class _MyDialoguState extends State<MyDialogu> {
  bool _showCCFLoader = true;
  bool _isSubmitting = false;
  bool _hasLevel = false;
  int reqCounts = 0;
  int _widgetPosition = -1;
  int initPosition = 0;
  var wid = 0;
  double boxHeight = 111.0;
  List<Data> ccfData = [];
  Data? selectedValue = null;
  List<Widget> addedWidgets = [];
  List selectedTownhalls = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<OrganizationBloc>(context)
          .add(GetCCFEvent(townhall_id: widget.townhallID));
    });
    super.initState();
  }

  void onChangAction(int dropdownID) {
    if (mounted)
      setState(() {
        initPosition = dropdownID;
        _widgetPosition = dropdownID;
      });
    print("New: " + _widgetPosition.toString());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      title: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            size: 20,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
          ),
        ),
      ),
      content: BlocConsumer<OrganizationBloc, OrganizationState>(
          buildWhen: (previousState, state) {
        return true;
      }, listener: (contextA, state) {
        print("Listener has been called");
        if (state is OrganizationLoadingState) {}
        if (state is CCFState) {
          if (mounted)
            setState(() {
              reqCounts++;
              ccfData = state.CCFResponse.data!;
              _showCCFLoader = false;
              _isSubmitting = false;
              boxHeight += 58.0;
              if (addedWidgets.length < 2) {
                _hasLevel = true;
              }
            });
          if (mounted)
            setState(() {
              _widgetPosition += 1;
            });
          addedWidgets.add(_buildDropDownMenu(
              ccfData, state.CCFResponse.another_one!, _widgetPosition));
        }
        if (state is NoCCFState) {
          if (mounted)
            setState(() {
              _showCCFLoader = false;
              _isSubmitting = false;
            });
        }
        if (state is UpdateUsersTownhallsState) {
          if (mounted)
            setState(() {
              reqCounts = 0;
              _showCCFLoader = false;
              Loader.hide();
            });
          AppSharedPreferences.setValue(
              key: 'orgName', value: widget.orgName.toString());
          AppSharedPreferences.setValue(
              key: 'orgID', value: widget.orgID.toString());
          Navigation.intentWithClearAllRoutes(context, HomeScreen.routeName);
        }
        if (state is OrganizationErrorState) {
          if (mounted)
            setState(() {
              _showCCFLoader = false;
              _isSubmitting = false;
              Loader.hide();
            });
          final snackBar = SnackBar(
            content: Text(state.message!),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }, builder: (_, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                widget.orgName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: double.maxFinite,
              height: boxHeight,
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: addedWidgets.length,
                    itemBuilder: (context, index) {
                      return addedWidgets[index];
                    },
                    shrinkWrap: true,
                  ),
                  if (_showCCFLoader)
                    SpinKitWave(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
                      size: 15.0,
                    ),
                  Container(
                    width: 370,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.only(left: 1.0, right: 1.0, top: 26.0),
                    child: ElevatedButton(
                      onPressed: _showCCFLoader || _hasLevel || _isSubmitting
                          ? null
                          : () {
                              Map<String, dynamic> map = Map();
                              map['org_id'] = widget.orgID;
                              List uniqueTownhallList = [];
                              if (selectedTownhalls.length > 0) {
                                selectedTownhalls.sort(
                                    (a, b) => a["position"].compareTo(b["position"]));
                                uniqueTownhallList = removeDuplicate(selectedTownhalls);
                                for (int i = 0; i < uniqueTownhallList.length; i++) {
                                  map["townhall_ids[" + i.toString() + "]"] =
                                      uniqueTownhallList[i];
                                }
                              }
                              if (mounted)
                                setState(() {
                                  _isSubmitting = true;
                                });
                              print(map);
                              BlocProvider.of<OrganizationBloc>(context).add(
                                UpdateUsersTownhallsEvent(
                                    updateUsersTownhallsRequest: map),
                              );
                            },
                      child: _isSubmitting
                          ? SpinKitWave(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
                              size: 15.0,
                            )
                          : Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 20,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.blueGrey[700]
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List removeDuplicate(List townhalls) {
    List uniqueList = [];
    townhalls.forEach((element) {
      if (uniqueList.contains(element['townhallID']) == false) {
        uniqueList.add(element['townhallID']);
      }
    });
    return uniqueList;
  }

  Widget _buildDropDownMenu(List<Data> items, String anotherOne, int widgetPosition) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    print('Position ${widgetPosition}');
    items.insertAll(0, [
      Data(townhall_id: -1, name: '-- Please Select --'),
    ]);
    selectedValue = items[0];
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: 390,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: DropdownButtonFormField<Data>(
        value: selectedValue,
        elevation: 16,
        style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
        icon: Icon(
          Icons.arrow_drop_down,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(border: InputBorder.none),
        iconSize: 26,
        hint: Text(
          "Please Select                                         ",
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
        ),
        onChanged: (Data? newValue) {
          onChangAction(widgetPosition);
          print("Latest Position: " + widgetPosition.toString());
          if (newValue!.townhall_id != -1) {
            if (mounted)
              setState(() {
                selectedValue = newValue;
                selectedTownhalls.add({
                  'position': widgetPosition,
                  'townhallID': newValue!.townhall_id
                });
                _showCCFLoader = true;
                _hasLevel = newValue!.children_count! > 0 ? true : false;
              });
            print("Selected ID: " +
                selectedValue!.townhall_id.toString() +
                " Selected Name: " +
                selectedValue!.name.toString());
            BlocProvider.of<OrganizationBloc>(context)
                .add(GetCCFEvent(townhall_id: newValue!.townhall_id.toString()));
          } else {
            int widgetLength = addedWidgets.length;
            for (initPosition; initPosition < widgetLength; initPosition++) {
              print("Loop counts:${initPosition} WidgetPos: ${widgetPosition} Total Arr: ${widgetLength}");
              if (initPosition > widgetPosition) {
                int toRemove = (addedWidgets.length - 1) - (2 - initPosition);
                print(initPosition.toString() +
                    " > " +
                    widgetPosition.toString() +
                    " To  remove " +
                    toRemove.toString());
                addedWidgets.removeAt(toRemove);
              }
              if (mounted)
                setState(() {
                  boxHeight -= 35;
                  _hasLevel = addedWidgets.length < 2 ? true : false;
                });
            }
          }
        },
        items: items.map<DropdownMenuItem<Data>>((Data value) {
          return DropdownMenuItem<Data>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    value.name.toString(),
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}