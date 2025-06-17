import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/profile/get_short_profile_info_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/message/messages.dart';
import 'package:mobilizer/pages/organization/organization_details.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PeopleProfile extends StatefulWidget {
  static const String routeName = 'people_profile';
  final Map<String, dynamic> mapData;

  const PeopleProfile({
    required this.mapData,
    Key? key,
  }) : super(key: key);

  @override
  _PeopleProfileState createState() => _PeopleProfileState();
}

class _PeopleProfileState extends State<PeopleProfile> {
  static const String routeName = 'people_profile';

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerComment = TextEditingController();
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
  bool _isBlocking = false;
  bool _isBlocked = false;
  bool _isProfileLoaded = false;
  bool _isFeedCachedDataAvailable = false;
  bool _isReporting = false;
  bool _isDeleting = false;
  bool _hasErrorPosts = false; // Added for error handling
  bool _hasErrorOrg = false;
  bool _hasErrorFollowers = false;
  bool _hasErrorFollowings = false;

  String _tag = "post";
  String _userID = '';
  String _clickedID = '';
  String _userAction = '';

  int _followers = 0;
  int _followings = 0;
  int _townhalls = 0;
  int _currentPage = 1;
  final int _limit = 25;

  List<String> _toDeviceTokens = [];
  List<dynamic> data = [];
  List<dynamic> posts = [];
  List<dynamic> organizations = [];
  List<dynamic> followings = [];
  List<dynamic> followers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initUserID();
    _fetchProfile(widget.mapData['subjectID']);
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingOrg &&
          !_isLoadingMore &&
          _tag == "org") {
        fetchMoreOrgs();
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingFollowers &&
          !_isLoadingMore &&
          _tag == "follower") {
        fetchMoreFollowers();
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingFollowings &&
          !_isLoadingMore &&
          _tag == "following") {
        fetchMoreFollowings();
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - _limit &&
          !_isLoadingPosts &&
          !_isLoadingMore &&
          _tag == "post") {
        fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllerComment.dispose();
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return WillPopScope(
      onWillPop: () async => true,
      child: OverlayLoaderWithAppIcon(
        isLoading: _isBlocking || _isDeleting,
        overlayBackgroundColor: secondaryTextColor,
        circularProgressColor: Colors.blue,
        appIconSize: 25,
        appIcon: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Image(image: AssetImage('images/icon_blue.png')),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: Container(
              margin: const EdgeInsets.all(9),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back,
                  color: textColor, // Updated to use theme color
                ),
                onPressed: () {
                  Navigator.pop(context, {'userAction': _userAction});
                },
              ),
            ),
            title: const Text(''),
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
                  child: IconButton(
                    icon: Icon(Icons.message_outlined, color: textColor), // Updated to use theme color
                    onPressed: () {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Messages(mapData: mapData),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('${widget.mapData['picture']}'),
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          child: Container(
                            height: 30,
                            color: backgroundColor,
                          ),
                        ),
                      ),
                      const Center(child: Text('')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: _isLoadingProfile
                      ? Center(child: CircularProgressIndicator(color: Colors.blue))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 220,
                                    color: backgroundColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.mapData['full_name'] ?? 'Unknown User',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                                          ),
                                          Text(
                                            '@${widget.mapData['username']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                          Text(
                                            toData?.profession ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isProfileLoaded && widget.mapData['subjectID'].toString() != _userID)
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      color: backgroundColor,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (_isFollowing) {
                                            await _unfollowUser(widget.mapData['subjectID']);
                                            setState(() {
                                              _isFollowing = false;
                                            });
                                          } else {
                                            await _followUser(widget.mapData['subjectID']);
                                            setState(() {
                                              _isFollowing = true;
                                            });
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                            _isFollowing ? Colors.red : Colors.blue,
                                          ),
                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                        ),
                                        child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Divider(color: secondaryTextColor),
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
                                            _isLoadingPosts = posts.isEmpty ? true : false;
                                          });
                                          if (posts.isEmpty) {
                                            setState(() {
                                              _currentPage = 1;
                                            });
                                            _fetchPosts();
                                          } else {
                                            setState(() {
                                              _currentPage = (posts.length / _limit).ceil();
                                            });
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              'Public Posts',
                                              style: TextStyle(
                                                color: _tag == "post" ? Colors.blue : secondaryTextColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.article_outlined,
                                              size: 28,
                                              color: _tag == "post" ? Colors.blue : textColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: InkWell(
                                        onTap: _followers < 1
                                            ? null
                                            : () {
                                                setState(() {
                                                  _tag = "follower";
                                                  _isLoadingFollowers = followers.isEmpty ? true : false;
                                                });
                                                if (followers.isEmpty) {
                                                  setState(() {
                                                    _currentPage = 1;
                                                  });
                                                  _fetchFollowers();
                                                } else {
                                                  setState(() {
                                                    _currentPage = (followers.length / _limit).ceil();
                                                  });
                                                }
                                              },
                                        child: Column(
                                          children: [
                                            Text(
                                              'Followers',
                                              style: TextStyle(
                                                color: _tag == "follower" ? Colors.blue : secondaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              NumberFormat.compact().format(_followers),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: _tag == "follower" ? Colors.blue : textColor,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                  _isLoadingFollowings = followings.isEmpty ? true : false;
                                                });
                                                if (followings.isEmpty) {
                                                  setState(() {
                                                    _currentPage = 1;
                                                  });
                                                  _fetchFollowings();
                                                } else {
                                                  setState(() {
                                                    _currentPage = (followings.length / _limit).ceil();
                                                  });
                                                }
                                              },
                                        child: Column(
                                          children: [
                                            Text(
                                              'Following',
                                              style: TextStyle(
                                                color: _tag == "following" ? Colors.blue : secondaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              NumberFormat.compact().format(_followings),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: _tag == "following" ? Colors.blue : textColor,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                  _isLoadingOrg = organizations.isEmpty ? true : false;
                                                });
                                                if (organizations.isEmpty) {
                                                  setState(() {
                                                    _currentPage = 1;
                                                  });
                                                  _fetchAllOrg();
                                                } else {
                                                  setState(() {
                                                    _currentPage = (organizations.length / _limit).ceil();
                                                  });
                                                }
                                              },
                                        child: Column(
                                          children: [
                                            Text(
                                              'Organizations',
                                              style: TextStyle(
                                                color: _tag == "org" ? Colors.blue : secondaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              NumberFormat.compact().format(_townhalls),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: _tag == "org" ? Colors.blue : textColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _tag = "about";
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              'About',
                                              style: TextStyle(
                                                color: _tag == "about" ? Colors.blue : secondaryTextColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.info_outline,
                                              size: 28,
                                              color: _tag == "about" ? Colors.blue : textColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(color: secondaryTextColor),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _tag == "post"
                                  ? _buildPost(isDarkMode, textColor, secondaryTextColor)
                                  : _tag == "about"
                                      ? _buildAbout(isDarkMode, textColor)
                                      : _tag == "org"
                                          ? _buildOrg(isDarkMode, textColor, secondaryTextColor)
                                          : _tag == "following"
                                              ? _buildFollowing(isDarkMode, textColor, secondaryTextColor)
                                              : _tag == "follower"
                                                  ? _buildFollower(isDarkMode, textColor, secondaryTextColor)
                                                  : const SizedBox(),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: _showScrollToTopButton
              ? FloatingActionButton(
                  onPressed: _scrollToTop,
                  backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.blue,
                  child: Icon(Icons.arrow_upward, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPost(bool isDarkMode, Color textColor, Color secondaryTextColor) {
    if (_hasErrorPosts) {
      return Center(child: Text("Failed to load posts", style: TextStyle(color: textColor)));
    }
    if (_tag == "post" && posts.isEmpty && !_isLoadingPosts) {
      return Center(child: Text("No data", style: TextStyle(color: textColor)));
    }
    return _isLoadingPosts
        ? _buildShimmerLoader1(isDarkMode)
        : ListView.builder(
            padding: const EdgeInsets.only(top: 1),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: posts.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= posts.length) {
                return _buildShimmerLoader1(isDarkMode);
              }
              int days = 0;
              String pollEndDesc = '';
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
                pollEndDesc = days < 1
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
              }
              Duration difference = currentTime.difference(
                  DateTime.parse(posts[index]['post_updated_time']));
              return _listTilePost(
                index,
                posts[index],
                currentTime.subtract(difference),
                optionList,
                posts[index]['post_images'] ?? [],
                hasPollEnded,
                hasVoted,
                pollEndTime,
                pollEndDesc,
                isDarkMode,
                textColor,
                secondaryTextColor,
              );
            },
          );
  }

  Widget _buildAbout(bool isDarkMode, Color textColor) {
    return Card(
      color: isDarkMode ? Colors.grey[800]! : const Color.fromARGB(255, 183, 219, 253),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      toData?.profession_category ?? '',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16, color: textColor),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      toData?.profession ?? '',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16, color: textColor),
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

  Widget _buildOrg(bool isDarkMode, Color textColor, Color secondaryTextColor) {
    if (_hasErrorOrg) {
      return Center(child: Text("Failed to load organizations", style: TextStyle(color: textColor)));
    }
    if (_tag == "org" && organizations.isEmpty && !_isLoadingOrg) {
      return Center(child: Text("No data", style: TextStyle(color: textColor)));
    }
    return _isLoadingOrg
        ? _buildShimmerLoader2(isDarkMode)
        : ListView.builder(
            padding: const EdgeInsets.only(top: 1),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: organizations.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= organizations.length) {
                return _buildShimmerLoader2(isDarkMode);
              }
              return _listTileOrg(organizations[index], isDarkMode, textColor, secondaryTextColor);
            },
          );
  }

  Widget _buildFollower(bool isDarkMode, Color textColor, Color secondaryTextColor) {
    if (_hasErrorFollowers) {
      return Center(child: Text("Failed to load followers", style: TextStyle(color: textColor)));
    }
    if (_tag == "follower" && followers.isEmpty && !_isLoadingFollowers) {
      return Center(child: Text("No data", style: TextStyle(color: textColor)));
    }
    return _isLoadingFollowers
        ? _buildShimmerLoader2(isDarkMode)
        : ListView.builder(
            padding: const EdgeInsets.only(top: 1),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: followers.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= followers.length) {
                return _buildShimmerLoader2(isDarkMode);
              }
              return _listTileFollower(followers[index], isDarkMode, textColor, secondaryTextColor);
            },
          );
  }

  Widget _buildFollowing(bool isDarkMode, Color textColor, Color secondaryTextColor) {
    if (_hasErrorFollowings) {
      return Center(child: Text("Failed to load followings", style: TextStyle(color: textColor)));
    }
    if (_tag == "following" && followings.isEmpty && !_isLoadingFollowings) {
      return Center(child: Text("No data", style: TextStyle(color: textColor)));
    }
    return _isLoadingFollowings
        ? _buildShimmerLoader2(isDarkMode)
        : ListView.builder(
            padding: const EdgeInsets.only(top: 1),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: followings.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= followings.length) {
                return _buildShimmerLoader2(isDarkMode);
              }
              return _listTileFollowing(followings[index], isDarkMode, textColor, secondaryTextColor);
            },
          );
  }

  Widget _listTilePost(
    int postIndex,
    Map<String, dynamic> postData,
    DateTime postDateDiff,
    List<dynamic> optionList,
    List<dynamic> postImages,
    bool hasPollEnded,
    bool hasVoted,
    DateTime? pollEndTime,
    String pollEndDesc,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Comments(mapData: mapData),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: postData['noticeboard_msg'] == "yes"
                ? (isDarkMode ? Colors.blueGrey[700]! : Colors.blue[50]!)
                : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        Map<String, dynamic> mapData = {
                          'subjectID': postData['posted_by'],
                          'picture': postData['post_profile_pics'],
                          'post_update_by': postData['post_update_by'],
                          'username': postData['username'],
                        };
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeopleProfile(mapData: mapData),
                          ),
                        ).then((result) async {
                          if (result != null && result['userAction'] == "block") {
                            setState(() {
                              posts.removeWhere(
                                  (item) => item['posted_by'].toString() == postData['posted_by']);
                            });
                          }
                          if (result != null && result['userAction'] == "unblock") {
                            data = [];
                          }
                        });
                      },
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider('${postData['post_profile_pics']}'),
                        radius: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
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
                                      'post_update_by': postData['post_update_by'],
                                      'username': postData['username'],
                                    };
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PeopleProfile(mapData: mapData),
                                      ),
                                    ).then((result) async {
                                      if (result != null && result['userAction'] == "block") {
                                        setState(() {
                                          posts.removeWhere((item) =>
                                              item['posted_by'].toString() == postData['posted_by']);
                                        });
                                      }
                                      if (result != null && result['userAction'] == "unblock") {
                                        data = [];
                                      }
                                    });
                                  },
                                  child: Text(
                                    _substring(postData['post_update_by'], 20),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Text(
                                '. ${_getTimeAgo(postDateDiff)}',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1.0),
                          GestureDetector(
                            onTap: () async {
                              Map<String, dynamic> mapData = {
                                'subjectID': postData['posted_by'],
                                'picture': postData['post_profile_pics'],
                                'post_update_by': postData['post_update_by'],
                                'username': postData['username'],
                              };
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PeopleProfile(mapData: mapData),
                                ),
                              ).then((result) async {
                                if (result != null && result['userAction'] == "block") {
                                  setState(() {
                                    posts.removeWhere(
                                        (item) => item['posted_by'].toString() == postData['posted_by']);
                                  });
                                }
                                if (result != null && result['userAction'] == "unblock") {
                                  data = [];
                                }
                              });
                            },
                            child: Row(
                              children: [
                                if (postData['designation'] != "" && postData['designation'] != null)
                                  Container(
                                    padding: const EdgeInsets.only(left: 7, right: 7),
                                    decoration: const BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: 20,
                                    child: Text(
                                      _substring(postData['designation'], 30),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 12.0),
                                    ),
                                  ),
                                SizedBox(
                                  width: postData['designation'] != "" && postData['designation'] != null ? 10 : 0,
                                ),
                                Text(
                                  '@${postData['username'].toString().toLowerCase()}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: secondaryTextColor,
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
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
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
                          textStyle: TextStyle(fontSize: 15, color: textColor),
                          backgroundColor: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                          trailing: const Icon(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Comments(mapData: mapData),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Linkify(
                        options: const LinkifyOptions(humanize: false),
                        onOpen: _onOpen,
                        text: postData['post_message'],
                        style: TextStyle(fontSize: 15, color: textColor),
                        textAlign: postData['post_alignment'] == "rtl" ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),
              if (postData['poll'] == "yes")
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FlutterPolls(
                        votedProgressColor: Colors.blue[200]!,
                        leadingVotedProgessColor: Colors.blue[200]!,
                        pollEnded: hasPollEnded,
                        heightBetweenTitleAndOptions: 0,
                        hasVoted: hasVoted,
                        userVotedOptionId: postData['user_option'].toString(),
                        votedPercentageTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        pollId: DateTime.now().toString(),
                        onVoted: (PollOption pollOption, int newTotalVotes) async {
                          bool hasPollEnded = currentTime.isAfter(pollEndTime!);
                          if (hasPollEnded) {
                            setState(() {
                              hasPollEnded = true;
                            });
                            const snackBar =
                                SnackBar(backgroundColor: Color(0xFFcf5555), content: Text("Poll has ended"));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return false;
                          } else {
                            await _castPollVote(postData['post_id'].toString(), pollOption.id.toString());
                            setState(() {
                              hasVoted = true;
                            });
                            return true;
                          }
                        },
                        pollTitle: const Text(''),
                        pollOptions: optionList
                            .map(
                              (option) => PollOption(
                                id: option['option_id'].toString(),
                                title: Text(option['option_value'], style: TextStyle(color: textColor)),
                                votes: option['votes'],
                              ),
                            )
                            .toList(),
                        metaWidget: Row(
                          children: [
                            const SizedBox(width: 6),
                            Text(
                              '•',
                              style: TextStyle(fontSize: 15, color: secondaryTextColor),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pollEndDesc,
                              style: TextStyle(fontSize: 15, color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (postImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                  child: ImageSwipe(imageList: postImages),
                ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment_outlined, color: secondaryTextColor, size: 18.0),
                        const SizedBox(width: 4.0),
                        Text(
                          numberFormat(postData['comment_count']),
                          style: TextStyle(color: secondaryTextColor, fontSize: 14.0),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Icon(
                            postData['is_liked'] == "yes" ? Icons.favorite : Icons.favorite_border_outlined,
                            color: postData['is_liked'] == "yes" ? Colors.red : secondaryTextColor,
                            size: 18.0,
                          ),
                          onTap: () async {
                            if (postData['is_liked'] == "yes") {
                              await _unlikePost(postData['post_id']);
                              setState(() {
                                _clickedID = postData['post_id'];
                                posts[postIndex]['is_liked'] = "no";
                                posts[postIndex]['like_count'] = posts[postIndex]['like_count'] - 1;
                              });
                            } else {
                              await _likePost(postData['post_id']);
                              setState(() {
                                _clickedID = postData['post_id'];
                                posts[postIndex]['is_liked'] = "yes";
                                posts[postIndex]['like_count'] = posts[postIndex]['like_count'] + 1;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          numberFormat(postData['like_count']),
                          style: TextStyle(color: secondaryTextColor, fontSize: 14.0),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String value) async {
                        if (value == "report") {
                          showDialog(
                            context: context,
                            builder: (BuildContext contextTwo) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text('Report', style: TextStyle(color: textColor)),
                                backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.white,
                                content: Container(
                                  height: 175.0,
                                  width: 350.0,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        child: TextFormField(
                                          maxLength: 300,
                                          maxLines: 3,
                                          minLines: 1,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            labelText: 'Comment',
                                            hintText: 'Enter Comment',
                                            contentPadding:
                                                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                                            labelStyle: TextStyle(color: secondaryTextColor),
                                            hintStyle: TextStyle(color: secondaryTextColor),
                                          ),
                                          controller: _controllerComment,
                                          style: TextStyle(color: textColor),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please Enter Comment';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                          ),
                                          onPressed: _isReporting
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    _isReporting = true;
                                                  });
                                                  await _reportPost(postData['post_id'],
                                                      _controllerComment.text, postData['posted_by']);
                                                  setState(() {
                                                    _controllerComment.text = "";
                                                    _isReporting = false;
                                                  });
                                                  Navigator.pop(contextTwo, false);
                                                },
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Submit',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
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
                          _confirmDelete(postData['post_id'], postData['posted_by'], context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        if (_userID != postData['posted_by'].toString())
                          PopupMenuItem<String>(
                            value: 'report',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined, color: textColor),
                              title: Text('Report', style: TextStyle(color: textColor)),
                            ),
                          ),
                        if (_userID == postData['posted_by'].toString())
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline, color: textColor),
                              title: Text('Delete', style: TextStyle(color: textColor)),
                            ),
                          ),
                      ],
                      child: Row(
                        children: [
                          Icon(Icons.more_vert_outlined, color: secondaryTextColor, size: 18.0),
                          const SizedBox(width: 4.0),
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

  Widget _listTileOrg(Map<String, dynamic> orgData, bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Fixed padding syntax
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3), // Fixed margin syntax
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800]! : const Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrganizationDetails(mapData: mapData)));
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : const Color.fromARGB(255, 221, 221, 221),
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
                    color: textColor,
                  ),
                ),
                Text(
                  "@${orgData['org_username'].toString().toLowerCase()}    ${orgData['member_count'].toString()} member${orgData['member_count'] > 1 ? 's' : ''}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listTileFollower(Map<String, dynamic> followData, bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Fixed padding syntax
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3), // Fixed margin syntax
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800]! : const Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PeopleProfile(mapData: mapData)));
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : const Color.fromARGB(255, 221, 221, 221),
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
                  "${followData['firstname']} ${followData['lastname']}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  followData['username'] != ""
                      ? '@${followData['username'].toString().toLowerCase()}'
                      : '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listTileFollowing(Map<String, dynamic> followingData, bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Fixed padding syntax
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3), // Fixed margin syntax
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800]! : const Color.fromARGB(255, 183, 219, 253),
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PeopleProfile(mapData: mapData)));
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : const Color.fromARGB(255, 221, 221, 221),
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
                  "${followingData['firstname']} ${followingData['lastname']}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  followingData['username'] != ""
                      ? '@${followingData['username'].toString().toLowerCase()}'
                      : '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader1(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0, left: 2, right: 2),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: baseColor,
              ),
              title: Container(
                height: 16,
                color: baseColor,
              ),
              subtitle: Container(
                height: 12,
                color: baseColor,
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: baseColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoader2(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 1),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              height: 70,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(String postID, String postedBy, BuildContext contextA) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification', style: TextStyle(color: textColor)),
          content: Text('Are you sure want to delete this post?', style: TextStyle(color: textColor)),
          backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.white,
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _clickedID = postID;
                  _isDeleting = true;
                });
                await _deletePost(postID, postedBy);
                setState(() {
                  int index = posts.indexWhere(
                      (post) => post['post_id'].toString() == _clickedID);
                  if (index != -1) {
                    posts.removeAt(index);
                  }
                  _isDeleting = false;
                  _clickedID = '';
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchProfile(String subjectID) async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    try {
      final response = await http.get(
        Uri.parse(
            '$domainName/api/profile/get_user_profile_pickcolumn?subjects_id=$subjectID¶ms="firstname,lastname,picture,device_tokens,username,email,profession,profession_category,followers,followings,organizations"'),
        headers: {'Authorization': token ?? ''},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          setState(() {
            toData = ProfileData.fromJson(responseData['data']);
            _followers = toData?.followers ?? 0;
            _followings = toData?.followings ?? 0;
            _townhalls = toData?.townhalls ?? 0;
            _isBlocked = toData?.blocked_or_not == "not_blocked" ? false : true;
            _isFollowing = toData?.is_following == "yes" ? true : false;
            _isProfileLoaded = true;
            _isLoadingProfile = false;
          });
          if (toData != null &&
              toData!.device_tokens != null &&
              toData!.device_tokens!.isNotEmpty) {
            for (DeviceTokensData token in toData!.device_tokens!) {
              setState(() {
                _toDeviceTokens.add(token.device_token);
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() {
        _isLoadingProfile = false;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '$domainName/api/townhall/fetch_posts?org_id=&group_id=&page_owner=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage&older_or_newer=&last_post_id='),
        headers: {'Authorization': authToken ?? ''},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            posts.addAll(data['data']);
            _isLoadingPosts = false;
            _isLoadingMore = false;
            _hasErrorPosts = false;
          });
        } else {
          setState(() {
            _isLoadingPosts = false;
            _isLoadingMore = false;
            _hasErrorPosts = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
        _isLoadingMore = false;
        _hasErrorPosts = true;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchAllOrg() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '$domainName/api/profile/list_of_user_joined_orgs?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {'Authorization': authToken ?? ''},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            organizations.addAll(data['data']);
            _isLoadingOrg = false;
            _isLoadingMore = false;
            _hasErrorOrg = false;
          });
        } else {
          setState(() {
            _isLoadingOrg = false;
            _isLoadingMore = false;
            _hasErrorOrg = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingOrg = false;
        _isLoadingMore = false;
        _hasErrorOrg = true;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchFollowings() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '$domainName/api/profile/followings_of_viewed_user?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {'Authorization': authToken ?? ''},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            followings.addAll(data['data']);
            _isLoadingFollowings = false;
            _isLoadingMore = false;
            _hasErrorFollowings = false;
          });
        } else {
          setState(() {
            _isLoadingFollowings = false;
            _isLoadingMore = false;
            _hasErrorFollowings = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingFollowings = false;
        _isLoadingMore = false;
        _hasErrorFollowings = true;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _fetchFollowers() async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '$domainName/api/profile/followers_of_viewed_user?viewed_user=${widget.mapData['subjectID']}&limit=$_limit&page=$_currentPage'),
        headers: {'Authorization': authToken ?? ''},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            followers.addAll(data['data']);
            _isLoadingFollowers = false;
            _isLoadingMore = false;
            _hasErrorFollowers = false;
          });
        } else {
          setState(() {
            _isLoadingFollowers = false;
            _isLoadingMore = false;
            _hasErrorFollowers = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingFollowers = false;
        _isLoadingMore = false;
        _hasErrorFollowers = true;
      });
      _showErrorDialog('$e');
    }
  }

  Future<void> _followUser(String followeeId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/profile/follow'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'followee': int.parse(followeeId)}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          _showSuccessSnackBar('Successfully followed user');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to follow user: $e');
    }
  }

  Future<void> _unfollowUser(String followeeId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/profile/unfollow'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'followee': int.parse(followeeId)}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          _showSuccessSnackBar('Successfully unfollowed user');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to unfollow user: $e');
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/townhall/like'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'post_id': postId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      _showErrorDialog('Failed to like post: $e');
    }
  }

  Future<void> _unlikePost(String postId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/townhall/unlike'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'post_id': postId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to unlike post');
      }
    } catch (e) {
      _showErrorDialog('Failed to unlike post: $e');
    }
  }

  Future<void> _castPollVote(String postId, String optionId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/townhall/poll_vote'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'post_id': postId, 'option_id': optionId}),
      );
      if (response.statusCode == 200) {
        setState(() {
          int index = posts.indexWhere((post) => post['post_id'] == postId);
          if (index != -1) {
            posts[index]['user_voted'] = true;
            posts[index]['user_option'] = optionId;
            posts[index]['poll_details']
                .firstWhere((opt) => opt['option_id'] == optionId)['votes'] += 1;
          }
        });
        _fetchPosts(); // Refresh in background
      }
    } catch (e) {
      _showErrorDialog('Failed to cast vote: $e');
    }
  }

  Future<void> _reportPost(String postId, String comment, String reportedId) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/townhall/report_abuse'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'post_id': postId,
          'comment': comment,
          'reported': reportedId
        }),
      );
      if (response.statusCode == 200) {
        _showSuccessSnackBar('Post reported successfully');
      }
    } catch (e) {
      _showErrorDialog('Failed to report post: $e');
    }
  }

  Future<void> _deletePost(String postId, String postedBy) async {
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('$domainName/api/townhall/delete_feed'),
        headers: {
          'Authorization': authToken ?? '',
          'Content-Type': 'application/json'
        },
        body: json.encode({'post_id': postId, 'posted_by': postedBy}),
      );
      if (response.statusCode == 200) {
        _showSuccessSnackBar('Post deleted successfully');
      }
    } catch (e) {
      _showErrorDialog('Failed to delete post: $e');
    }
  }

  int daysToWeeks(int days) => (days / 7).floor();
  int daysToMonths(int days) => (days / 30.44).ceil();
  int daysToYears(int days) => (days / 365.25).floor();

  Future<void> fetchMoreOrgs() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchAllOrg();
  }

  Future<void> fetchMoreFollowings() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchFollowings();
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchPosts();
  }

  Future<void> fetchMoreFollowers() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    await _fetchFollowers();
  }

  Future<void> _initUserID() async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = userID ?? '';
    });
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  String _substring(String char, int count) {
    return char.length > count ? '${char.substring(0, count)}...' : char;
  }

  String _getTimeAgo(DateTime dt) {
    return timeago.format(dt, locale: 'en_short');
  }

  String numberFormat(int n) {
    String num = n.toString();
    int len = num.length;
    if (n >= 1000 && n < 1000000) {
      return '${num.substring(0, len - 3)}.${num.substring(len - 3, 1 + (len - 3))}k';
    } else if (n >= 1000000 && n < 1000000000) {
      return '${num.substring(0, len - 6)}.${num.substring(len - 6, 1 + (len - 6))}m';
    } else if (n > 1000000000) {
      return '${num.substring(0, len - 9)}.${num.substring(len - 9, 1 + (len - 9))}b';
    } else {
      return num;
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> share(String text, String title) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(text,
        subject: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  void _showErrorDialog(String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: textColor)),
          content: Text(message, style: TextStyle(color: textColor)),
          backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.white,
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;

  const NotificationBadge({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}