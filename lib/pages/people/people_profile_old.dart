import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as po;
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as pe;
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/profile/get_short_profile_info_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/message/messages.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/pages/search/search.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PeopleProfile extends StatefulWidget {
  static String routeName = 'people_profile';
  final Map<String, dynamic> mapData;
  PeopleProfile({
    required this.mapData,
    Key? key,
  }) : super(key: key);
  @override
  _PeopleProfileState createState() => _PeopleProfileState();
}

class _PeopleProfileState extends State<PeopleProfile> {
  static String routeName = 'people_profile';

  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _controllerComment = TextEditingController();
  ProfileData? toData;
  DateTime currentTime = DateTime.now();

  bool _showScrollToTopButton = false;
  bool _isFollowing = false;
  bool _isLoadingOrg = false;
  bool _isLoadingFollowings = false;
  bool _isLoadingPosts = true;
  bool _isLoadingFollowers = false;
  bool _isLoadingProfile = true;
  bool _isLoadingMore = false;
  bool _isBlocking = false; //when trying to block or unblocking
  bool _isBlocked = false; //This tell is the subject has been blocked
  bool _isProfileLoaded =
      false; //This tells if profile details has been fully loaded
  bool _isFeedCachedDataAvailable = false;
  bool _isReporting = false;
  bool _isDeleting = false;

  String _tag = "post";
  String _userID = '';
  String _clickedID = ''; //this hold clicked ID(postID)
  String _userAction =
      ''; //this will be set to 'block' if subject was blocked by user

  int _followers = 0;
  int _followings = 0;
  int _townhalls = 0;
  int _currentPage = 1; // Track the current page for all
  final int _limit = 25; // Limit for API calls

  List _toDeviceTokens = [];
  List<dynamic> data = [];
  List<dynamic> posts = [];
  List<dynamic> organizations = []; // List for all organizations
  List<dynamic> followings = [];
  List<dynamic> followers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initUserID();
    _fetchProfile(widget.mapData['subjectID']);
    _fetchPosts();
    // Future.delayed(Duration.zero, () {
    //   BlocProvider.of<pe.PeopleBloc>(context).add(
    //     pe.GetPeoplePostsEvent(clickedUserID: widget.mapData['subjectID']),
    //   );
    // });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingOrg &&
          !_isLoadingMore &&
          _tag == "org") {
        fetchMoreOrgs(); // Load more org when reaching the bottom
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingFollowers &&
          !_isLoadingMore &&
          _tag == "follower") {
        fetchMoreFollowers(); // Load more follower when reaching the bottom
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingFollowings &&
          !_isLoadingMore &&
          _tag == "following") {
        fetchMoreFollowings(); // Load more following when reaching the bottom
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingPosts &&
          !_isLoadingMore &&
          _tag == "post") {
        fetchMorePosts(); // Load more post when reaching the bottom
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 2 * MediaQuery.of(context).size.height) {
      setState(() {
        _showScrollToTopButton = true;
      });
    } else {
      setState(() {
        _showScrollToTopButton = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: OverlayLoaderWithAppIcon(
        isLoading: _isBlocking || _isDeleting ? true : false,
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: Container(
              margin: EdgeInsets.all(9),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'userAction': _userAction
                  }); // Navigates back to the previous page
                },
              ),
            ),
            title: Text(''),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (widget.mapData['subjectID'].toString() != _userID)
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: FittedBox(
                    child: IconButton(
                      icon: Icon(color: Colors.blue, Icons.message_outlined),
                      onPressed: () {
                        print("ToDevice: ${_toDeviceTokens}");
                        print("{}");
                        Map<String, dynamic> mapData = {
                          'from': _userID,
                          'fromPics': '',
                          'fromName': '',
                          'fromUsername': '',
                          'toName': widget.mapData['post_update_by'],
                          'toUsername': widget.mapData['username'],
                          'to': widget.mapData['subjectID'],
                          'toPics': widget.mapData['picture'],
                          'conversationID': '',
                          'toDeviceTokens': _toDeviceTokens,
                        };
                        // Handle message icon press
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Messages(mapData: mapData),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SizedBox(
                width: 10,
              ),
              // if (_isProfileLoaded &&
              //     widget.mapData['subjectID'].toString() != _userID)
              //   Container(
              //     width: 35,
              //     height: 35,
              //     decoration: BoxDecoration(
              //       color: Colors.black.withOpacity(0.5),
              //       shape: BoxShape.circle,
              //     ),
              //     child: FittedBox(
              //       child: PopupMenuButton(
              //         itemBuilder: (context) => [
              //           PopupMenuItem(
              //             child: Text(_isBlocked ? 'UnBlock' : 'Block'),
              //             onTap: () {
              //               setState(() {
              //                 _isBlocking = true;
              //               });
              //               BlocProvider.of<pe.PeopleBloc>(context).add(
              //                 pe.BlockUserEvent(
              //                     subjectID: widget.mapData['subjectID'],
              //                     req_type: _isBlocked ? 'unblock' : 'block'),
              //               );
              //             },
              //           ),
              //         ],
              //         icon: Icon(color: Colors.blue, Icons.more_vert),
              //       ),
              //     ),
              //   ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: MultiBlocListener(
              listeners: [
                BlocListener<pe.PeopleBloc, pe.PeopleState>(
                  listener: (context, state) async {
                    if (state is pe.BlockUserState) {
                      final msgBlck = _isBlocked ? 'unblocked' : 'blocked';
                      final snackBar = SnackBar(
                          backgroundColor: Color.fromARGB(255, 85, 207, 158),
                          content: Text('User was successfully $msgBlck'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        _isBlocking = false;
                        _isBlocked = !_isBlocked;
                      });
                      if (_isBlocked) {
                        await _getCachedFeedData();

                        _userAction = 'block';
                        if (_isFeedCachedDataAvailable) {
                          final currOrgID =
                              await AppSharedPreferences.getValue(key: 'orgID');
                          final currTownhallID =
                              await AppSharedPreferences.getValue(
                                  key: 'groupID');
                          //remove all feeds posted by the blocked user
                          int result = _removeBlockedUserPosts(
                              currOrgID.toString(),
                              currTownhallID.toString(),
                              widget.mapData['subjectID'].toString());
                          print("Result ${result}");
                        }
                      } else {
                        _userAction = 'unblock';
                      }
                    }
                    if (state is pe.GetFolloweesState) {}
                    if (state is pe.GetFollowersState) {}
                    // if (state is pe.GetPeoplePostsState) {}
                    if (state is pe.PeopleLoadingState) {}

                    if (state is pe.ErrorState) {
                      final snackBar = SnackBar(
                          backgroundColor: Color(0xFFcf5555),
                          content: Text('An error has occurred'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
                BlocListener<po.PostsBloc, po.PostsState>(
                  listener: (context, state) {
                    if (state is po.NoResultState) {}
                    // if (state is LoadingState && olderLoader == false) {
                    //   if (showLikeLoader == false) {
                    //     loading = true;
                    //   }
                    //   loading = false;
                    //   olderLoader = false;
                    //   newLoader = false;
                    //   reloadTop = false;
                    //   print("P1");
                    // }

                    // if (state is LoadingState) {
                    //   loading = true;
                    // }
                    if (state is po.LoadingState) {}

                    if (state is po.GoToSuggestionState) {}
                    //Go to profile page
                    if (state is po.GoToProfileState) {}
                    if (state is po.AbuseReportState) {
                      final snackBar = SnackBar(
                        content: Text('Post was successfully reported'),
                        backgroundColor: Colors.green.shade300,
                      );
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    if (state is po.NoPartyState) {}
                    if (state is po.LikeState) {
                      _clickedID = '';
                    }
                    if (state is po.DeleteFeedState) {
                      print("delete state");
                      int index = posts.indexWhere(
                          (posts) => posts['post_id'].toString() == _clickedID);
                      if (index != -1) {
                        posts.removeAt(index);
                        _clickedID = '';
                      }
                      setState(() {
                        _isDeleting = false;
                      });
                    }
                    if (state is po.UnLikeState) {
                      _clickedID = '';
                    }
                    if (state is po.ErrorState) {
                      if (state.errorFor == "like") {
                        int arrIndex = posts.indexWhere(
                            (items) => items['post_id'] == _clickedID);
                        if (arrIndex != -1) {
                          setState(() {
                            posts[arrIndex]['like_count'] =
                                posts[arrIndex]['like_count'] - 1;
                            posts[arrIndex]['is_liked'] = "no";
                          });
                        }
                      }
                      if (state.errorFor == "unlike") {
                        int arrIndex = posts.indexWhere(
                            (items) => items['post_id'] == _clickedID);
                        if (arrIndex != -1) {
                          setState(() {
                            posts[arrIndex]['like_count'] =
                                posts[arrIndex]['like_count'] + 1;
                            posts[arrIndex]['is_liked'] = "yes";
                          });
                        }
                      }
                    }
                    if (state is po.NetworkState) {}
                  },
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          '${widget.mapData['picture']}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            child: Container(
                              height: 30, // Adjust height as needed
                              color: Colors.white,
                              // Your content for the container inside "Row 1" goes here
                            ),
                          ),
                        ),
                        Center(child: Text('')), //Row 1
                      ],
                    ),
                  ),

                  // Row 2
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0, left: 20.0, right: 20.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 220,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.mapData['post_update_by']}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (widget.mapData['username'] != null)
                                        Text(
                                          '@${widget.mapData['username']}',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      if (widget.mapData['location'] != null)
                                        Text(
                                          '${widget.mapData['location']}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_isProfileLoaded &&
                                widget.mapData['subjectID'].toString() !=
                                    _userID)
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  color: Colors.white,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Follow button action
                                      if (_isFollowing) {
                                        //unfollow
                                        setState(() {
                                          _isFollowing = false;
                                        });
                                        BlocProvider.of<pe.PeopleBloc>(context)
                                            .add(pe.UnFollowEvent(
                                                followee: int.parse(widget
                                                    .mapData['subjectID']
                                                    .toString())));
                                      } else {
                                        //follow
                                        setState(() {
                                          _isFollowing = true;
                                        });
                                        BlocProvider.of<pe.PeopleBloc>(context)
                                            .add(pe.FollowEvent(
                                                followee: int.parse(widget
                                                    .mapData['subjectID']
                                                    .toString())));
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: _isFollowing
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.red)
                                          : MaterialStateProperty.all<Color>(
                                              Colors.blue),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                    child: Text(
                                        _isFollowing ? 'Unfollow' : 'Follow'),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        Divider(),

                        // Third row
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _tag = "post";
                                        _isLoadingPosts =
                                            posts.isEmpty ? true : false;
                                      });
                                      if (posts.isEmpty) {
                                        setState(() {
                                          _currentPage = 1;
                                        });
                                        _fetchPosts();
                                      } else {
                                        setState(() {
                                          _currentPage =
                                              (posts.length / _limit).ceil();
                                        });
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Public Posts',
                                          style: TextStyle(
                                              color: _tag == "post"
                                                  ? Colors.blue
                                                  : Colors.grey),
                                        ),
                                        Icon(
                                          Icons.article_outlined,
                                          size: 28,
                                          color: _tag == "post"
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // if (toData != null)
                                //   SizedBox(
                                //     width: 100,
                                //     child: InkWell(
                                //       onTap: () {
                                //         setState(() {
                                //           _tag = "about";
                                //           // _isLoadingAbout =
                                //           //     about.isEmpty ? true : false;
                                //         });
                                //       },
                                //       child: Column(
                                //         children: [
                                //           Text(
                                //             'About Me',
                                //             style: TextStyle(
                                //                 color: _tag == "about"
                                //                     ? Colors.blue
                                //                     : Colors.grey),
                                //           ),
                                //           Icon(
                                //             Icons.person_outline,
                                //             size: 28,
                                //             color: _tag == "about"
                                //                 ? Colors.blue
                                //                 : Colors.black,
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                SizedBox(
                                  width: 100,
                                  child: InkWell(
                                    onTap: _followers < 1
                                        ? null
                                        : () {
                                            setState(() {
                                              _tag = "follower";
                                              _isLoadingFollowers =
                                                  followers.isEmpty
                                                      ? true
                                                      : false;
                                            });
                                            if (followers.isEmpty) {
                                              setState(() {
                                                _currentPage = 1;
                                              });
                                              _fetchFollowers();
                                            } else {
                                              setState(() {
                                                _currentPage =
                                                    (followers.length / _limit)
                                                        .ceil();
                                              });
                                            }
                                          },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                              color: _tag == "follower"
                                                  ? Colors.blue
                                                  : Colors.grey),
                                        ),
                                        Text(
                                          '${NumberFormat.compact().format(_followers)}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: _tag == "follower"
                                                  ? Colors.blue
                                                  : null,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: InkWell(
                                    onTap: _followings < 1
                                        ? null
                                        : () {
                                            setState(() {
                                              _tag = "following";
                                              _isLoadingFollowings =
                                                  followings.isEmpty
                                                      ? true
                                                      : false;
                                            });
                                            if (followings.isEmpty) {
                                              setState(() {
                                                _currentPage = 1;
                                              });
                                              _fetchFollowings();
                                            } else {
                                              setState(() {
                                                _currentPage =
                                                    (followings.length / _limit)
                                                        .ceil();
                                              });
                                            }
                                          },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                              color: _tag == "following"
                                                  ? Colors.blue
                                                  : Colors.grey),
                                        ),
                                        Text(
                                          '${NumberFormat.compact().format(_followings)}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: _tag == "following"
                                                  ? Colors.blue
                                                  : null,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: InkWell(
                                    onTap: _townhalls < 1
                                        ? null
                                        : () async {
                                            setState(() {
                                              _tag = "org";
                                              _isLoadingOrg =
                                                  organizations.isEmpty
                                                      ? true
                                                      : false;
                                            });
                                            if (organizations.isEmpty) {
                                              setState(() {
                                                _currentPage = 1;
                                              });
                                              _fetchAllOrg();
                                            } else {
                                              setState(() {
                                                _currentPage =
                                                    (organizations.length /
                                                            _limit)
                                                        .ceil();
                                              });
                                            }
                                          },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Organizations',
                                          style: TextStyle(
                                              color: _tag == "org"
                                                  ? Colors.blue
                                                  : Colors.grey),
                                        ),
                                        Text(
                                          '${NumberFormat.compact().format(_townhalls)}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: _tag == "org"
                                                  ? Colors.blue
                                                  : null,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Divider(),
                        Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: _tag == "post"
                                ? _buildPost()
                                : _tag == "about"
                                    ? _buildAbout()
                                    : _tag == "org"
                                        ? _buildOrg()
                                        : _tag == "following"
                                            ? _buildFollowing()
                                            : _tag == "follower"
                                                ? _buildFollower()
                                                : SizedBox()),
                        // Second row
                        SizedBox()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _showScrollToTopButton
              ? FloatingActionButton(
                  onPressed: _scrollToTop,
                  child: Icon(Icons.arrow_upward),
                )
              : null,
        ),
      ),
    );
  }

  int _removeBlockedUserPosts(
      String orgID, String townhallID, String subjectID) {
    int cnt = 0;
    int initialLength = data.length;
    data.removeWhere((item) => item.posted_by.toString() == subjectID);
    int removedCount = initialLength - data.length;
    if (removedCount != initialLength) {
      AppSharedPreferences.setValue(
          key: "page_feed_${orgID}_${townhallID}", value: jsonEncode(data));
      cnt++;
    }
    return cnt;
  }

  _getCachedFeedData([String? townhallID]) async {
    final currOrgID = await AppSharedPreferences.getValue(key: 'orgID');
    final currTownhallID = await AppSharedPreferences.getValue(key: 'groupID');
    print('rGroup page_feed_${currOrgID}_${currOrgID}');
    var pageData =
        await getPageData('page_feed_${currOrgID}_${currTownhallID}');
    print(pageData);
    if (pageData != null && pageData != "") {
      print(
          "Cached data was called Org ID: ${currOrgID} TowhnID: ${currTownhallID}");
      var json = jsonDecode(pageData);
      setState(() {
        _isFeedCachedDataAvailable = true;
        data = json.map<FeedData>((json) => FeedData.fromJson(json)).toList();
      });
    } else {
      setState(() {
        _isFeedCachedDataAvailable = false;
      });
      print("Cached Statuc:${_isFeedCachedDataAvailable}");
    }
  }

  Widget _buildPost() {
    return _tag == "post" && posts.length < 1 && _isLoadingPosts == false
        ? Column(
            children: [
              Center(
                child: Text("No data"),
              ),
            ],
          )
        : _isLoadingPosts
            ? _buildShimmerLoader1()
            : ListView.builder(
                padding: EdgeInsets.only(top: 1),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: posts.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  int days = 0; //days left for polls to end
                  String poll_end_desc = '';
                  DateTime? pollEndTime;
                  bool hasPollEnded = false;
                  bool hasVoted = false;

                  List<dynamic> optionList = posts[index]['poll_details'] ?? [];
                  if (posts[index]['poll'] == "yes") {
                    hasVoted = posts[index]['user_voted'];
                    pollEndTime = DateTime.parse(posts[index]['poll_end']);
                    hasPollEnded = currentTime.isAfter(pollEndTime);
                    days = DateTime(
                      DateTime.parse(posts[index]['poll_end']).year,
                      DateTime.parse(posts[index]['poll_end']).month,
                      DateTime.parse(posts[index]['poll_end']).day,
                    )
                        .difference(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ))
                        .inDays;
                    poll_end_desc = days < 1
                        ? 'ended'
                        : days < 7 && days > 0
                            ? '$days days left'
                            : days > 6 && days < 30
                                ? '${daysToWeeks(days)} week${daysToWeeks(days) > 1 ? 's' : ''} left'
                                : days > 30
                                    ? '${daysToMonths(days)} month${daysToMonths(days) > 1 ? 's' : ''} left'
                                    : days > 365
                                        ? '${daysToYears(days)}year${daysToYears(days) > 1 ? 's' : ''} left'
                                        : '';
                    print("poll Date: ${posts[index]['poll_end']}");
                  }
                  Duration difference = currentTime.difference(DateTime.parse(
                      posts[index]
                          ['post_updated_time'])); // Calculate the difference
                  // postDateDiff = currentTime.subtract(difference);
                  return _listTilePost(
                      index,
                      posts[index],
                      currentTime.subtract(difference),
                      optionList,
                      posts[index]['post_images'] ?? [],
                      hasPollEnded,
                      hasVoted,
                      pollEndTime,
                      poll_end_desc);
                },
              );
  }

  Widget _buildAbout() {
    return Card(
      //elevation: 1,
      color: Color.fromARGB(255, 183, 219, 253),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Profession:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      toData!.profession_category ?? '',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Description:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      toData!.profession ?? '',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrg() {
    return _tag == "org" && organizations.length < 1 && _isLoadingOrg == false
        ? Center(
            child: Text("No data"),
          )
        : _isLoadingOrg
            ? _buildShimmerLoader2()
            : ListView.builder(
                padding: EdgeInsets.only(top: 1),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: organizations.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= organizations.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  return _listTileOrg(organizations[index]);
                },
              );
  }

  Widget _buildFollower() {
    return _tag == "follower" &&
            followers.length < 1 &&
            _isLoadingFollowers == false
        ? Center(
            child: Text("No data"),
          )
        : _isLoadingFollowers
            ? _buildShimmerLoader2()
            : ListView.builder(
                padding: EdgeInsets.only(top: 1),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: followers.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= followers.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  return _listTileFollower(followers[index]);
                },
              );
  }

  Widget _buildFollowing() {
    return _tag == "following" &&
            followings.length < 1 &&
            _isLoadingFollowings == false
        ? Center(
            child: Text("No data"),
          )
        : _isLoadingFollowings
            ? _buildShimmerLoader2()
            : ListView.builder(
                padding: EdgeInsets.only(top: 1),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: followings.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= followings.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  return _listTileFollowing(followings[index]);
                },
              );
  }

  Widget _listTilePost(
      int postIndex,
      Map<String, dynamic> postData,
      DateTime postDateDiff,
      List optionList,
      List postImages,
      bool hasPollEnded,
      bool hasVoted,
      DateTime? pollEndTime,
      String poll_end_desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        //onTapDown: (details) => _getTapPosition(details),
        onTap: () async {
          Map<String, dynamic> mapData = {
            'id': postData['post_id'],
            'posted_by': postData['posted_by'].toString(),
            'post_message': postData['post_message'],
            'like_count': postData['like_count'],
            'comment_count': postData['comment_count'],
            'post_profile_pics': postData['post_profile_pics'],
            'post_update_by': postData['post_update_by'],
            'post_updated_time': postData['post_updated_time'],
            'username': postData['username'],
            'post_alignment': postData['post_alignment'],
            'is_comment_of_comment': false,
            'media': postImages,
          };
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => po.PostsBloc(),
                ),
              ],
              child: Comments(
                mapData: mapData,
              ),
            );
          }));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: postData['noticeboard_msg'] == "yes"
                ? Color(0xffCCE9FD)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        Map<String, dynamic> mapData = {
                          'subjectID': postData['posted_by'],
                          'picture': postData['post_profile_pics'],
                          'post_update_by': postData['post_update_by'],
                          'username': postData['username'],
                        };
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (contextA) => PeopleBloc(),
                              ),
                              BlocProvider(
                                create: (context) => po.PostsBloc(),
                              ),
                            ],
                            child: PeopleProfile(mapData: mapData),
                          );
                        })).then((result) async {
                          print("Am here");
                          if (result != null &&
                              result['userAction'] == "block") {
                            setState(() {
                              posts.removeWhere((item) =>
                                  item['posted_by'].toString() ==
                                  postData['posted_by']);
                            });
                            print("Action ${result['userAction']}");
                          }
                          if (result != null &&
                              result['userAction'] == "unblock") {
                            //reload feeds
                            data = [];

                            final prefGroupName =
                                await AppSharedPreferences.getValue(
                                    key: 'groupName');
                            final prefTownhallID =
                                await AppSharedPreferences.getValue(
                                    key: "groupID");
                            // _fetchTownhallFeeds(prefTownhallID.toString(),
                            //     prefGroupName.toString(), '', false);
                          }
                        });
                      },
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          '${postData['post_profile_pics']}',
                        ),
                        radius: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    Map<String, dynamic> mapData = {
                                      'subjectID': postData['posted_by'],
                                      'picture': postData['post_profile_pics'],
                                      'post_update_by':
                                          postData['post_update_by'],
                                      'username': postData['username'],
                                    };
                                    await Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (contextA) => PeopleBloc(),
                                          ),
                                          BlocProvider(
                                            create: (context) => po.PostsBloc(),
                                          ),
                                        ],
                                        child: PeopleProfile(mapData: mapData),
                                      );
                                    })).then((result) async {
                                      print("Am here");
                                      if (result != null &&
                                          result['userAction'] == "block") {
                                        setState(() {
                                          posts.removeWhere((item) =>
                                              item['posted_by'].toString() ==
                                              postData['posted_by']);
                                        });
                                        print("Action ${result['userAction']}");
                                      }
                                      if (result != null &&
                                          result['userAction'] == "unblock") {
                                        //reload feeds
                                        data = [];
                                        // setState(() {
                                        //   older_or_newer = "";
                                        //   _showBodyLoading = true;
                                        //   _isFeedRequestInProgress = true;
                                        //   _nextPage = 1;
                                        // });
                                        // final prefGroupName =
                                        //     await AppSharedPreferences
                                        //         .getValue(key: 'groupName');
                                        // final prefTownhallID =
                                        //     await AppSharedPreferences
                                        //         .getValue(key: "groupID");
                                        // _fetchTownhallFeeds(
                                        //     prefTownhallID.toString(),
                                        //     prefGroupName.toString(),
                                        //     '',
                                        //     false);
                                      }
                                    });
                                  },
                                  child: Text(
                                    _substring(postData['post_update_by'], 20),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Text(
                                '. ' + _getTimeAgo(postDateDiff!),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.0),
                          GestureDetector(
                            onTap: () async {
                              Map<String, dynamic> mapData = {
                                'subjectID': postData['posted_by'],
                                'picture': postData['post_profile_pics'],
                                'post_update_by': postData['post_update_by'],
                                'username': postData['username'],
                              };
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (contextA) => PeopleBloc(),
                                    ),
                                    BlocProvider(
                                      create: (context) => po.PostsBloc(),
                                    ),
                                  ],
                                  child: PeopleProfile(mapData: mapData),
                                );
                              })).then((result) async {
                                if (result != null &&
                                    result['userAction'] == "block") {
                                  setState(() {
                                    posts.removeWhere((item) =>
                                        item['posted_by'].toString() ==
                                        postData['posted_by']);
                                  });
                                  print("Action ${result['userAction']}");
                                }
                                if (result != null &&
                                    result['userAction'] == "unblock") {
                                  //reload feeds
                                  // data = [];
                                  // setState(() {
                                  //   older_or_newer = "";
                                  //   _showBodyLoading = true;
                                  //   _isFeedRequestInProgress = true;
                                  //   _nextPage = 1;
                                  // });
                                  // final prefGroupName =
                                  //     await AppSharedPreferences.getValue(
                                  //         key: 'groupName');
                                  // final prefTownhallID =
                                  //     await AppSharedPreferences.getValue(
                                  //         key: "groupID");
                                  // _fetchTownhallFeeds(
                                  //     prefTownhallID.toString(),
                                  //     prefGroupName.toString(),
                                  //     '',
                                  //     false);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                postData['designation'] != "" &&
                                        postData['designation'] != null
                                    ? Container(
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        child: Text(
                                          _substring(
                                              postData['designation'], 30),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(
                                  width: postData['designation'] != "" &&
                                          postData['designation'] != null
                                      ? 10
                                      : 0,
                                ),
                                Text(
                                  '@${postData['username'].toString().toLowerCase()}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                child: Align(
                  alignment: postData['post_alignment'] == "ltr" ||
                          postData['post_alignment'] == null ||
                          postData['post_alignment'] == ""
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: InkWell(
                    onLongPress: () {
                      FlutterClipboard.copy(postData['post_message']).then(
                        (value) => GFToast.showToast(
                          'Copied',
                          context,
                          toastPosition: GFToastPosition.BOTTOM,
                          textStyle:
                              TextStyle(fontSize: 15, color: GFColors.DARK),
                          backgroundColor: GFColors.LIGHT,
                          trailing: Icon(
                            Icons.notifications,
                            color: GFColors.SUCCESS,
                          ),
                        ),
                      );
                    },
                    onTap: () {
                      Map<String, dynamic> mapData = {
                        'id': postData['post_id'],
                        'posted_by': postData['posted_by'].toString(),
                        'post_message': postData['post_message'],
                        'like_count': postData['like_count'],
                        'comment_count': postData['comment_count'],
                        'post_profile_pics': postData['post_profile_pics'],
                        'post_update_by': postData['post_update_by'],
                        'post_updated_time': postData['post_updated_time'],
                        'username': postData['username'],
                        'post_alignment': postData['post_alignment'],
                        'is_comment_of_comment': false,
                        'media': postImages,
                      };
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (contextA) => po.PostsBloc(),
                            ),
                          ],
                          child: Comments(
                            mapData: mapData,
                          ),
                        );
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(04.0),
                      child: Linkify(
                        options: LinkifyOptions(humanize: false),
                        onOpen: _onOpen,
                        text: postData['post_message'],
                        style: TextStyle(fontSize: 15),
                        textAlign: postData['post_alignment'] == "rtl"
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),
              if (postData['poll'] == "yes")
                LayoutBuilder(builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FlutterPolls(
                      votedProgressColor: Color(0xff84D2F6),
                      leadingVotedProgessColor: Color(0xff84D2F6),
                      pollEnded: hasPollEnded,
                      heightBetweenTitleAndOptions: 0,
                      hasVoted: hasVoted,
                      userVotedOptionId: postData['user_option'].toString(),
                      votedPercentageTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      pollId: DateTime.now().toString(),
                      onVoted:
                          (PollOption pollOption, int newTotalVotes) async {
                        bool hasPollEnded = currentTime.isAfter(pollEndTime!);
                        print("poll $hasPollEnded");
                        if (hasPollEnded) {
                          setState(() {
                            hasPollEnded = true;
                          });
                          final snackBar = SnackBar(
                              backgroundColor: Color(0xFFcf5555),
                              content: Text("Poll has ended"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return false;
                        } else {
                          BlocProvider.of<po.PostsBloc>(context).add(
                            po.PollCastEvent(
                                postID: postData['post_id'].toString(),
                                optionID: pollOption.id.toString()),
                          );
                          final List<dynamic> pollDetails =
                              postData['poll_details'];
                          final optionIndex = pollDetails.indexWhere(
                              (pollDetails) =>
                                  pollDetails.option_id.toString() ==
                                  pollOption.id.toString());
                          print("optionID ${data[0]}");
                          setState(() {
                            hasVoted = true;
                            //update poll useroption
                            // if (optionIndex != -1) {
                            //   data[index]['poll_details'][optionIndex]
                            //           ['user_option'] =
                            //       int.parse(pollOption.id.toString());
                            //   data[index]['poll_details'][optionIndex]
                            //       ['user_voted'] = true;
                            // }
                          });
                          return true;
                        }
                      },
                      pollTitle: Text(''),
                      pollOptions: optionList.map(
                        (option) {
                          return PollOption(
                            id: option['option_id'].toString(),
                            title: Text(option['option_value']),
                            votes: option['votes'],
                          );
                        },
                      ).toList(),
                      metaWidget: Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            '$poll_end_desc',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              if (postImages.length > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                  child: ImageSwipe(imageList: postImages),
                ),
              const SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment_outlined,
                            color: Colors.grey, size: 18.0),
                        SizedBox(width: 4.0),
                        Text('${numberFormat(postData['comment_count'])}',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14.0)),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Icon(
                              postData['is_liked'] == "yes"
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: postData['is_liked'] == "yes"
                                  ? Colors.red
                                  : Colors.grey,
                              size: 18.0),
                          onTap: () {
                            setState(() {
                              //_clickedID = int.parse(postData['post_id']);
                            });

                            if (postData['is_liked'] == "yes") {
                              setState(() {
                                _clickedID = postData['post_id'];
                                posts[postIndex]['is_liked'] = "no";
                                posts[postIndex]['like_count'] =
                                    posts[postIndex]['like_count'] - 1;
                              });

                              BlocProvider.of<po.PostsBloc>(context).add(
                                po.UnLikePostEvent(
                                    post_id: postData['post_id']),
                              );
                              //_toggleLike(postData['is_liked']);
                            } else {
                              print("Am print like");
                              setState(() {
                                _clickedID = postData['post_id'];
                                posts[postIndex]['is_liked'] = "yes";
                                posts[postIndex]['like_count'] =
                                    posts[postIndex]['like_count'] + 1;
                              });
                              BlocProvider.of<po.PostsBloc>(context).add(
                                po.LikePostEvent(post_id: postData['post_id']),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 4.0),
                        Text('${numberFormat(postData['like_count'])}',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14.0)),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () async {
                    //         share(
                    //           feeds.sharelink,
                    //           '',
                    //         );

                    //         // Navigator.pushNamed(context,
                    //         //     postN.PostNotificationScreen.routeName,
                    //         //     arguments: {
                    //         //       'item_id': '54911',
                    //         //       'org_id': '5',
                    //         //       'org_name': 'OBidients',
                    //         //       'townhall_id': '160',
                    //         //       'n_type': 'post'
                    //         //     });
                    //       },
                    //       child: Icon(Icons.share_outlined,
                    //           color: Colors.grey, size: 18.0),
                    //     ),
                    //     SizedBox(width: 4.0),
                    //   ],
                    // ),
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == "report") {
                          showDialog(
                            context: context,
                            builder: (BuildContext contextTwo) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text('Report'),
                                content: Container(
                                  height: 175.0,
                                  width: 350.0,
                                  child: Column(
                                    children: [
                                      Container(
                                        child: SizedBox(
                                          child: TextFormField(
                                            maxLength: 300,
                                            maxLines: 3,
                                            minLines: 1,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                labelText: 'Comment',
                                                hintText: 'Enter Comment',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 20.0,
                                                        horizontal: 10.0)),
                                            controller: _controllerComment,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please Enter Comment';
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                      'Please Enter Comment'),
                                                  backgroundColor:
                                                      Colors.green.shade300,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.0,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          style: raisedButtonStyleGreen,
                                          onPressed: _isReporting
                                              ? null
                                              : () {
                                                  print("Am here");
                                                  setState(() {
                                                    _controllerComment.text =
                                                        "";
                                                    _isReporting = true;
                                                  });

                                                  BlocProvider.of<po.PostsBloc>(
                                                          context)
                                                      .add(
                                                    po.ReportAbuseEvent(
                                                        comment:
                                                            _controllerComment
                                                                .text,
                                                        post_id:
                                                            postData['post_id'],
                                                        reported: postData[
                                                            'posted_by']),
                                                  );
                                                  Navigator.pop(
                                                      contextTwo, false);
                                                  // }
                                                },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (value == 'delete') {
                          if (mounted)
                            _confirmDelete(postData['post_id'],
                                postData['posted_by'], context);
                        } else if (value == 'block') {
                          setState(() {
                            _isBlocking = true;
                          });
                          // BlocProvider.of<PostsBloc>(context).add(
                          //   BlockUserEvent(
                          //       subjectID: postData['posted_by'],
                          //       req_type: 'block'),
                          // );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        if (_userID != postData['posted_by'].toString())
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Report'),
                            ),
                          ),
                        if (_userID == postData['posted_by'].toString())
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Delete'),
                            ),
                          ),
                        // if (_userID != feeds.posted_by.toString())
                        //   const PopupMenuItem<String>(
                        //     value: 'block',
                        //     child: ListTile(
                        //       leading: Icon(Icons.person_off_sharp),
                        //       title: Text('Block'),
                        //     ),
                        //   ),
                      ],
                      child: const Row(
                        children: [
                          Icon(Icons.more_vert_outlined,
                              color: Colors.grey, size: 18.0),
                          SizedBox(width: 4.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTileOrg(Map<String, dynamic> orgData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          //onTapDown: (details) => _getTapPosition(details),
          onTap: () async {
            final mapData = {
              'org_id': orgData['org_id'],
              'org_bg': orgData['org_bg'],
              'org_about': orgData['org_about'],
              'org_name': orgData['name'],
              'org_member_count': orgData['member_count'].toString(),
              'join_status': orgData['join_status'] ?? '',
              'username': orgData['org_username'],
              'picture': orgData['org_icon'],
              'member': orgData['is_member'],
              'isLeader': '',
              'verified': orgData['verified'],
              'unread': 0,
              'pinned': "no"
            };
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (contextA) => OrganizationBloc()),
                ],
                child: OrganizationDetails(mapData: mapData),
              );
            }));
          },
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 15, right: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(255, 221, 221, 221),
                  width: 1.0,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(orgData['org_icon']),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orgData['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "@" +
                      orgData['org_username'].toString().toLowerCase() +
                      "    " +
                      orgData['member_count'].toString() +
                      " member${orgData['member_count'] > 1 ? 's' : ''}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    // fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            //trailing:
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     orgData['member_count'] == 0
            //         ? SizedBox()
            //         : NotificationBadge(
            //             count: int.parse(orgData['member_count'].toString()),
            //           ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }

  Widget _listTileFollower(Map<String, dynamic> followData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          //onTapDown: (details) => _getTapPosition(details),
          onTap: () async {
            Map<String, dynamic> mapData = {
              'subjectID': followData['user_id'].toString(),
              'picture': followData['profile_pic'],
              'post_update_by':
                  followData['firstname'].toString().capitalizeFirst! +
                      " " +
                      followData['lastname'].toString().capitalizeFirst!,
              'username': followData['username'],
            };
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (contextA) => PeopleBloc(),
                  ),
                  BlocProvider(
                    create: (context) => po.PostsBloc(),
                  ),
                ],
                child: PeopleProfile(mapData: mapData),
              );
            }));
          },
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 15, right: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(255, 221, 221, 221),
                  width: 1.0,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(followData['profile_pic']),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followData['firstname'] + " " + followData['lastname'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${followData['username'] != "" ? '@${followData['username'].toString().toLowerCase()}' : ''}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listTileFollowing(Map<String, dynamic> followingData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          //onTapDown: (details) => _getTapPosition(details),
          onTap: () async {
            Map<String, dynamic> mapData = {
              'subjectID': followingData['user_id'].toString(),
              'picture': followingData['profile_pic'],
              'post_update_by':
                  followingData['firstname'].toString().capitalizeFirst! +
                      " " +
                      followingData['lastname'].toString().capitalizeFirst!,
              'username': followingData['username'],
            };
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (contextA) => PeopleBloc(),
                  ),
                  BlocProvider(
                    create: (context) => po.PostsBloc(),
                  ),
                ],
                child: PeopleProfile(mapData: mapData),
              );
            }));
          },
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 15, right: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(255, 221, 221, 221),
                  width: 1.0,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(followingData['profile_pic']),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followingData['firstname'] + " " + followingData['lastname'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${followingData['username'] != "" ? '@${followingData['username'].toString().toLowerCase()}' : ''}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader1() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 0, left: 2, right: 2),
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
              ),
              title: Container(
                height: 16,
                color: Colors.grey[300],
              ),
              subtitle: Container(
                height: 12,
                color: Colors.grey[300],
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: Colors.grey[300],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoader2() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 1),
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
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

  void _confirmDelete(String postID, String postedBy, BuildContext contextA) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text('Are you sure want to delete this post?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                // You can add navigation to another page here if needed
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _clickedID = postID;
                  _isDeleting = true;
                });
                BlocProvider.of<PostsBloc>(contextA).add(
                  DeleteFeedEvent(post_id: postID, posted_by: postedBy),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchProfile(String subjectID) async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");

    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/get_user_profile_pickcolumn?subjects_id=$subjectID&params="firstname,lastname,picture,device_tokens,username,email,profession,profession_category,followers,followings,organizations"'),
        headers: {
          'Authorization': token!,
        },
      );
      print("Field: ${response.request}");
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          setState(() {
            toData = ProfileData.fromJson(responseData['data']);

            _followers = toData!.followers ?? 0;
            _followings = toData!.followings ?? 0;
            _townhalls = toData!.townhalls ?? 0;
            _isBlocked = toData!.blocked_or_not == "not_blocked" ? false : true;
            _isFollowing = toData!.is_following == "yes" ? true : false;
            _isProfileLoaded = true;
          });
          print(
              "toData: ${toData!.profession_category} ${responseData['data']} ");
          if (toData != null &&
              toData!.device_tokens != null &&
              toData!.device_tokens!.isNotEmpty) {
            for (DeviceTokensData token in toData!.device_tokens!) {
              setState(() {
                _toDeviceTokens.add(token.device_token);
              });
            }
            print("Devices: ${_toDeviceTokens}");
          } else {
            print("No device tokens available");
          }
        } else {
          throw Exception('Invalid response format: data field is missing');
        }
      } else {
        debugPrint("Response code: " + response.statusCode.toString());
        print("am here");
      }
    } on SocketException catch (e) {
      print("Err1: Handle network/socket issue");
    } on FormatException catch (e) {
      debugPrint("Err2: ${e.source}");
    } on TimeoutException catch (e) {
      debugPrint("Err3 ${e.message}");
    } catch (e) {
      debugPrint("Err3 ${e.toString()}");
    } finally {
      debugPrint("Completed");
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/townhall/fetch_posts?org_id=&group_id=&page_owner=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage&older_or_newer=&last_post_id='),
        headers: {
          'Authorization': authToken!,
        },
      );
      print("Request: " + response.request.toString());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("M: ${data}");
        if (data['status'] == 200) {
          setState(() {
            posts.addAll(data['data']); // Append new events
            _isLoadingPosts = false;
            _isLoadingMore = false;
          });
          print("Request: Am here");
        } else {
          setState(() {
            _isLoadingPosts = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingPosts = false;
          _isLoadingMore = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _isLoadingPosts = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('Please check your internet connection');
    } on FormatException catch (e) {
      setState(() {
        _isLoadingPosts = false;
        _isLoadingMore = false;
      });
      debugPrint(e.source);
    } catch (e) {
      print("i am here now");
      debugPrint('${e}');
      setState(() {
        _isLoadingPosts = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchAllOrg() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/list_of_user_joined_orgs?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {
          'Authorization': authToken!,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            organizations.addAll(data['data']); // Append new events
            _isLoadingOrg = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _isLoadingOrg = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingOrg = false;
          _isLoadingMore = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _isLoadingOrg = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('Please check your internet connection');
    } on FormatException catch (e) {
      setState(() {
        _isLoadingOrg = false;
        _isLoadingMore = false;
      });
      debugPrint(e.source);
    } catch (e) {
      print("i am here now");
      debugPrint('${e}');
      setState(() {
        _isLoadingOrg = false;
        _isLoadingMore = false;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchFollowings() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');

      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/followings_of_viewed_user?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {
          'Authorization': authToken!,
        },
      );
      print("Field: ${response.request}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            followings.addAll(data['data']); // Append new events
            _isLoadingFollowings = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _isLoadingOrg = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingOrg = false;
          _isLoadingMore = false;
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
    }
  }

  Future<void> _fetchFollowers() async {
    try {
      print("am here");
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/followers_of_viewed_user?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {
          'Authorization': authToken!,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          print("am here2");
          setState(() {
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
      _showErrorDialog('Please check your internet connection');
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
    }
  }

  int daysToWeeks(int days) {
    const daysInWeek = 7;
    return (days / daysInWeek).floor();
  }

  int daysToMonths(int days) {
    const daysInMonth = 30.44; // Average number of days in a month
    return (days / daysInMonth).ceil();
  }

  int daysToYears(int days) {
    const daysInYear =
        365.25; // Average number of days in a year, considering leap years
    return (days / daysInYear).floor();
  }

  // Fetch more orgs for pagination
  Future<void> fetchMoreOrgs() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _fetchAllOrg();
  }

  Future<void> fetchMoreFollowings() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _fetchFollowings();
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchPosts();
  }

  Future<void> fetchMoreFollowers() async {
    if (_isLoadingMore) return; // Prevent multiple calls
    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _fetchFollowers();
  }

  Future<void> _initUserID() async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = userID.toString();
    });
    print(_userID);
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  String _getTimeAgo(DateTime dt) {
    String timeAgo = timeago.format(dt, locale: 'en_short');
    return timeAgo; // Return the formatted time ago string
  }

  String numberFormat(int n) {
    String num = n.toString();
    int len = num.length;

    if (n >= 1000 && n < 1000000) {
      return num.substring(0, len - 3) +
          '.' +
          num.substring(len - 3, 1 + (len - 3)) +
          'k';
    } else if (n >= 1000000 && n < 1000000000) {
      return num.substring(0, len - 6) +
          '.' +
          num.substring(len - 6, 1 + (len - 6)) +
          'm';
    } else if (n > 1000000000) {
      return num.substring(0, len - 9) +
          '.' +
          num.substring(len - 9, 1 + (len - 9)) +
          'b';
    } else {
      return num.toString();
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await launch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> share(String text, String title) async {
    final box = context.findRenderObject() as RenderBox?;
    // final imageUrl = "https://empl-dev.site/image1.jpg";
    // final url = Uri.parse(imageUrl);
    // final response = await http.get(url);
    // final bytes = response.bodyBytes;
    // final temp = await getTemporaryDirectory();
    // final path = '${temp.path}/image.jpg';
    // File(path).writeAsBytesSync(bytes);
    // if (imageList.length > 0) {
    //   await Share.shareFiles([path],
    //       text: text,
    //       //subject: title,
    //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    // } else {
    await Share.share(text,
        subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    //}
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

class NotificationBadge extends StatelessWidget {
  final int count;

  NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
