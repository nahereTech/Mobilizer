import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:clipboard/clipboard.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/feed/feed_request.dart';
import 'package:mobilizer/models/feed/topfeed_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/feed/testFeed.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/pages/post/createpost.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:mobilizer/pages/register_otp/registerotp.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart' as a;
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'package:mobilizer/bloc/search/polling_bloc.dart' as p;
import 'package:mobilizer/bloc/suggestion/suggestion_bloc.dart' as s;
import 'package:mobilizer/bloc/search/people_bloc.dart' as p;
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/models/profile/get_profile_response.dart';
import 'package:mobilizer/models/social/like_list_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:mobilizer/pages/settings/settings.dart';
import 'package:mobilizer/pages/suggestion/org_suggestion.dart';
import 'package:mobilizer/pages/suggestion/suggestion.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Feed extends StatefulWidget {
  static String routeName = 'feed_screen';
  const Feed({Key? key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var deviceToken = getDeviceToken();
  late ScrollController _scrollController;
  bool _showLoadingTop = true;
  bool _showBodyLoading = true;
  bool _showNewerPostLoader = false;
  bool _showOlderPostLoader = false;
  bool _showBottomMenu = true;
  bool olderLoader = false;
  bool showFloatingButton = false;
  bool canPost = false;
  bool isThereResult = false;
  bool _isScrollingUp = false;
  bool isLastDownRequest = false;

  String profileImage = '';
  String? orgName;
  String _deviceType = '';
  String last_post_id = '';
  String groupId = '';
  String older_or_newer = '';
  String orgId = '';
  bool _isLoading = true;
  bool _isLoadingTop = true;
  bool _showCircleRow = true; // Initially show circle row

  // Initially show bottom menu
  double _previousOffset = 0; // Track the previous scroll offset
  List<dynamic> data = [];
  List<dynamic> newDataList = []; //new data from list.
  List<dynamic> newList = []; //list of groups with new feed notification.
  List<TopFeedData> topFeed = [];
  List<InfoData> townhallInfo = [];
  List<dynamic> _isLikeList = [];
  //AudioPlayer _audioPlayer = AudioPlayer();

  List<AudioItem> _audioItems = <AudioItem>[];

  List<Like> likeCounts = [];
  List<Comment> commentCounts = [];
  //SuperTooltip? tooltip;
  String newDataFirstPostID = '';
  String cachedDataFirstPostID = '';

  String first_post_id = '';
  bool isLiked = false;
  String clickedPostID = '';
  bool isTownhallView = false;
  int _clickedID = -1;
  int _selectedTownhallID = -1;
  int _nextPage = 1;
  int _newNextPage = -1; //used to know already ongoing next page number
  bool reloadTop = false;
  bool loading = true;
  bool _showRep = true;
  bool newFeedLoader = false; //new feed loader when Townhall is clicked

  bool newLoader = false;
  String likeSubjectID = "";
  bool showLikeLoader = false;
  bool isNoParty = false; //if not party yet.
  bool firstTimeLoading = true;
  bool isLoadingUpRequest = false; //This tell if loading up is feeding data now
  //No more data to fetch from database for scroll down
  bool isNoNetwork = false;
  bool showResultButton = false;
  bool _showTownhallInfoLoader = false;
  bool showSlideUpPanel = false;
  bool isPageFirstLoad = false;
  bool isFirstFeedRequest =
      true; //check if it's first time requesting for feeds
  bool isCachedDataAvailable = false;
  bool isPlaying = false;
  bool canDismiss = true;
  bool canPostPoll = false;
  bool _isFeedRequestInProgress =
      false; //check to be sure no multiple api request.
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  List<dynamic> _isFollowList = [];
  List<dynamic> _groupList = [];
  String networkMsg = "";

  String _slideUpTitle = "";
  String _showSlideUpFor = "";

  PanelController _pc = new PanelController();
  final _formKey = GlobalKey<FormState>();
  final _controllerComment = TextEditingController();
  //This is build number coming from the backend.
  int _clickedFollowID = 0;
  int _selectedIndexID = -1;
  int _topFeedIndexID = 0;
  bool _isPageVisited = false;
  bool _canUpdate = false;
  String _currentVersion = "";
  String _storeVersion = "";
  String _storeUrl = "";
  String _dismissedVersion = "";
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayerController _audioPlayerController = AudioPlayerController();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final scrollDirection = Axis.horizontal;

  final newVersion =
      NewVersionPlus(iOSId: IOSPackageID, androidId: androidPackageID);
  int limit = 10;
  Timer? timer;

  var moment = new Moment.now();
  var sampleVideo =
      "https://ia601205.us.archive.org/18/items/SampleVideo1280x7201mb/SampleVideo_1280x720_1mb.mp4";
  @override
  void initState() {
    print("Group: ${_getGroupID().toString()}");
    // _getCachedTopData();
    // _getCachedFeedData(_getGroupID().toString());
    _checkOnboarded();
    initPlatformState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _isScrollingUp = true;
      _fetchOlderPosts();
    }
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      //_getNewerPosts(limit, getDeviceToken());
      _isScrollingUp = false;
    }
    final currentOffset = _scrollController.offset;
    final direction = currentOffset - _previousOffset;
    setState(() {
      if (direction < 0) {
        // Scrolling up
        _showBottomMenu = true;
        _showCircleRow = true;
      } else if (direction > 0) {
        // Scrolling down
        _showBottomMenu = false;
        _showCircleRow = false;
      }
      _previousOffset = currentOffset;
    });
  }

  final ScrollController _topController = ScrollController();
  void _scrollToPosition(double position) {
    //_topController.jumpTo(position);
    // _topController.animateTo(
    //   position,
    //   duration: Duration(seconds: 2),
    //   curve: Curves.easeIn,
    // );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //   statusBarColor: Colors.black, // Set the status bar color to white
    // ));

    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     systemNavigationBarIconBrightness: Brightness.dark,
    //     systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
    //     statusBarColor: Theme.of(context).primaryColor,
    //   ),
    // );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Make status bar white
      statusBarIconBrightness: Brightness.dark, // Dark icons on the status bar
      systemNavigationBarColor:
          Colors.white, // Make bottom navigation bar white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Dark icons on the bottom navigation bar
    ));
    return BlocConsumer<PostsBloc, PostsState>(
      listener: (context, state) async {
        if (state is GoToSuggestionState) {
          Navigator.pushNamed(context, SuggestionScreen.routeName);
        }
        //Go to profile page
        if (state is GoToProfileState) {
          Navigator.pushNamed(context, Profile.routeName);
        }
        if (state is GoToOrganizationState) //Go to Organization suggestion page
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider(
              create: (context) => o.OrganizationBloc(),
              child: OrgSuggestionScreen(),
            );
          }));
        }
        if (state is LandingGroupState) {
          print('LandingGroupState');
          _fetchLandingGroup();
        }
        if (state is LoadedLandingGroupState) {
          _selectedTownhallID = int.parse(state.responseData.townhall_id);
          _fetchTopFeed(state.responseData.org_id.toString());
        }
        if (state is FullyOnboardedState) {
          //get top feed
          print('FullyOnboardedState');
          final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');

          _fetchTopFeed(prefOrgID.toString());
        }
        if (state is LoadedTopFeedState) {
          final prefGroupID =
              await AppSharedPreferences.getValue(key: 'groupID');
          final prefOrgID = await AppSharedPreferences.getValue(key: 'OrgID');
          final prefGroupName =
              await AppSharedPreferences.getValue(key: 'groupName');

          _selectedTownhallID = prefGroupID.toString() == ""
              ? int.parse(state.topFeedResponse.data![0].townhall_id)
              : int.parse(prefGroupID.toString());

          if (prefGroupID == "" || prefGroupID == null) {
            AppSharedPreferences.setValue(
                key: 'groupID',
                value: state.topFeedResponse.data![0].townhall_id.toString());
            AppSharedPreferences.setValue(
                key: 'groupName',
                value: state.topFeedResponse.data![0].townhall_display_name);
            AppSharedPreferences.setValue(
                key: 'groupFullName',
                value: state.topFeedResponse.data![0].townhall_full_name);
          }
          _fetchTownhallFeeds(_selectedTownhallID.toString(),
              prefGroupName.toString(), '', false);
          AppSharedPreferences.setValue(
              key: "page_feed_top_${prefOrgID}_${prefOrgID}",
              value: jsonEncode(state.topFeedResponse.data));
        }
        if (state is GoToConfirmState) //Go to Organization suggestion page
        {
          AppSharedPreferences.removeValue(key: 'token');
          AppSharedPreferences.removeValue(key: 'townhallView');
          AppSharedPreferences.removeValue(key: 'groupID');
          AppSharedPreferences.removeValue(key: 'orgID');
          AppSharedPreferences.removeValue(key: 'orgName');
          AppSharedPreferences.removeValue(key: 'isOrgLeader');
          AppSharedPreferences.removeValue(key: 'isTownhallLeader');
          AppSharedPreferences.removeValue(key: 'login');
          AppSharedPreferences.removeValue(key: 'dismissedVersion');
          Navigator.pushReplacementNamed(context, RegisterOtpScreen.routeName,
              arguments: state.email);
        }

        if (state is LoadedFeedState) {
          data = state.feedResponse;

          if (firstTimeLoading) {
            final prefGrpID =
                await AppSharedPreferences.getValue(key: 'groupID');
            int arrIndex = topFeed.indexWhere(
                (element) => element.townhall_id.toString() == prefGrpID);

            canPost = topFeed[arrIndex].can_post == "yes" ||
                    topFeed[arrIndex].can_post == "yes"
                ? true
                : false;
            _selectedTownhallID = prefGrpID == null || prefGrpID == ""
                ? int.parse(topFeed[0].townhall_id)
                : int.parse(prefGrpID);
            firstTimeLoading = false;
          }

          if (state.requestFeedLength > 0) {
            _nextPage = _nextPage + 1;
            print(
                "param if ${_nextPage} ${state.feedResponse.length} ${state.requestFeedLength} ");
          } else {
            print("param else");
          }

          _showBodyLoading = false;
          _showNewerPostLoader = false;
          _showOlderPostLoader = false;
          _isFeedRequestInProgress = false;

          final prefOrgID = await _getOrgID();
          AppSharedPreferences.setValue(
              key: "page_feed_${prefOrgID}_${_selectedTownhallID}",
              value: jsonEncode(state.feedResponse));
        }
        if (state is LoadedTopFeedState) {
          orgName = await AppSharedPreferences.getValue(key: 'orgName');
          print("OrgName" + orgName.toString());
          _showLoadingTop = false;
          topFeed = state.topFeedResponse.data!;
          Future.delayed(Duration(seconds: 1), () {
            _scrollToPosition(20.0);
          });
        }
        if (state is TownhallInfoState) {
          setState(() {
            townhallInfo = state.townhallResponse.data;
            _showTownhallInfoLoader = false;
          });
        }
        if (state is NetworkState) {
          _showBodyLoading = false;
          _showLoadingTop = false;
          _showNewerPostLoader = false;
          _showOlderPostLoader = false;
          _isFeedRequestInProgress = false;
        }
        if (state is ErrorState) {
          _showBodyLoading = false;
          _showLoadingTop = false;
          _showNewerPostLoader = false;
          _showOlderPostLoader = false;
          _isFeedRequestInProgress = false;
        }
      },
      builder: (contextA, state) {
        // return Scaffold(
        //   //appBar: _appBar(),

        //   body: Container(
        //     child: NestedScrollView(
        //       headerSliverBuilder:
        //           (BuildContext context, bool innerBoxIsScrolled) {
        //         return buildSliverAppBar(
        //             context, 'https://images.app.goo.gl/7NRSNy6A1wG3KjFL9');
        //       },
        //       body: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           _showLoadingTop
        //               ? _buildTopShimmerLoader()
        //               : _buildHorizontalScrollSection(topFeed, contextA),
        //           if (_showNewerPostLoader) _buildNewPostShimmerLoader(),
        //           if (data.length < 1 &&
        //               canPost &&
        //               _showBodyLoading == false &&
        //               _showNewerPostLoader == false &&
        //               _showLoadingTop == false)
        //             _buildStartConversation(),
        //           _showBodyLoading
        //               ? _buildBodyShimmerLoader()
        //               : _buildTaskList(data),
        //           if (_showOlderPostLoader)
        //             Padding(
        //               padding: const EdgeInsets.symmetric(horizontal: 10),
        //               child: _buildOlderPostShimmerLoader(),
        //             )
        //         ],
        //       ),
        //     ),
        //   ),
        //   floatingActionButton: canPost ? _floatingButton() : null,
        //   bottomNavigationBar: _bottomNavBar(),
        // );

        return Scaffold(
            // extendBodyBehindAppBar: true,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFd0e4f7),
                    Color(0xFFDBD7C8),
                    Color(0xFFEDD1DD),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return buildSliverAppBar(context,
                      'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid');
                },
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildPostList(),
                    ],
                  ),
                ),
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {},
            //   backgroundColor: Colors.blue, // Set background color to blue
            //   child: Icon(Icons.post_add, color: Colors.white), // Add post icon
            // ),
            bottomNavigationBar: null
            // CustomBottomNavigationBar(),
            );
      },
    );
  }

  Widget _buildPostList() {
    return Column(
      children: _notifications.map((notification) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  notification['profile_pic']),
                              radius: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 14.0, top: 16.0, right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['message'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Just now', // Example subtext, you can change it accordingly
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _notifications = [
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Abraham liked your kulturee',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'John commented on your post',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    {
      'profile_pic':
          'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
      'message': 'Jane shared your story',
    },
    // Add more notifications here as needed
  ];

  List<Widget> buildSliverAppBar(BuildContext context, String profilePicPath) {
    // void _handleProfilePicTap() {
    //   // Do something when the profile picture is tapped
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => ProfilePage()),
    //   );
    // }

    return [
      SliverAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'images/icon_blue.png',
              height: 25,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            // Add a placeholder SizedBox to separate the logo and profile icon
            Expanded(child: Container()),
            // Circular profile icon
            GestureDetector(
              onTap: null,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    profilePicPath), // _profilePicUrl should be the URL of the network image
                radius: 18,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        floating: true,
        snap: true,
      ),
    ];
  }

  PreferredSize _appBar() {
    return PreferredSize(
      //preferredSize: Size.fromHeight(kToolbarHeight),
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showBottomMenu ? kToolbarHeight + 20 : 0,
        child: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: SizedBox(
                  width: 25,
                  height: 25,
                  child: Image.asset('images/icon_blue.png'),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            Row(
              children: [
                SizedBox(
                  height: 30.0,
                  child: TextButton.icon(
                    onPressed: () async {
                      // Add your onPressed function here
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider(
                          create: (context) => o.OrganizationBloc(),
                          child: OrganizationScreen(),
                        );
                      }));
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.fromLTRB(12.0, 5.0, 5.0, 5.0),
                      ),
                    ),
                    icon: Text(
                      "${orgName == null ? '' : _substring(orgName.toString(), 10)}",
                      style: TextStyle(color: Colors.blue),
                    ),
                    label: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BlocProvider(
                        create: (context) => a.AuthBloc(),
                        child: Settings(),
                      );
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        profileImage == ""
                            ? 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid'
                            : profileImage,
                      ),
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

  Widget _buildBodyShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => ListTile(
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
          ),
        ),
      ),
    );
  }

  Widget _buildNewPostShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          1,
          (index) => ListTile(
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
          ),
        ),
      ),
    );
  }

  Widget _buildOlderPostShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          1,
          (index) => ListTile(
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
          ),
        ),
      ),
    );
  }

  Widget _buildTopShimmerLoader() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10),
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
            ),
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
    // You can return any other widget here if needed
  }

  // void _showTownhallInfoSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return DraggableScrollableSheet(
  //         expand: false,
  //         initialChildSize: 0.9,
  //         maxChildSize: 0.9,
  //         builder: (BuildContext context, ScrollController scrollController) {
  //           return BlocBuilder<PostsBloc, PostsState>(
  //             builder: (context, state) {
  //               if (state is LoadingState) {
  //                 return Center(child: CircularProgressIndicator());
  //               } else if (state is TownhallInfoState) {
  //                 final townhallInfo = state.townhallResponse;
  //                 return SingleChildScrollView(
  //                   controller: scrollController,
  //                   scrollDirection: Axis.vertical,
  //                   physics: AlwaysScrollableScrollPhysics(),
  //                   child: Row(
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.fromLTRB(25, 20, 1, 0),
  //                         child: Column(
  //                           children: [
  //                             Column(
  //                               children: [
  //                                 Container(
  //                                   width:
  //                                       MediaQuery.of(context).size.width - 50,
  //                                   alignment: Alignment.topRight,
  //                                   height: 20.0,
  //                                   child: IconButton(
  //                                     alignment: Alignment.topRight,
  //                                     icon:
  //                                         Icon(Icons.close, color: Colors.grey),
  //                                     iconSize: 20.0,
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                     },
  //                                   ),
  //                                 ),
  //                                 Container(
  //                                   width:
  //                                       MediaQuery.of(context).size.width - 50,
  //                                   child: Column(
  //                                     children: [
  //                                       Container(
  //                                         alignment: Alignment.topLeft,
  //                                         child: Text(
  //                                           'Townhall Info',
  //                                           style: TextStyle(
  //                                             fontWeight: FontWeight.bold,
  //                                             fontSize: 15,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       Divider(
  //                                         thickness: 0.5,
  //                                         color: Colors.black,
  //                                       ),
  //                                       Column(
  //                                         mainAxisSize: MainAxisSize.min,
  //                                         children: [
  //                                           Container(child: Text("Text")),
  //                                           // ListView.builder(
  //                                           //   shrinkWrap: true,
  //                                           //   scrollDirection: Axis.vertical,
  //                                           //   itemCount: townhallInfo.length,
  //                                           //   itemBuilder: (context, index) {
  //                                           //     final info = townhallInfo[index];

  //                                           //     return Column(
  //                                           //       crossAxisAlignment:
  //                                           //           CrossAxisAlignment.stretch,
  //                                           //       children: [
  //                                           //         if (info.section.isNotEmpty)
  //                                           //           Padding(
  //                                           //             padding: const EdgeInsets
  //                                           //                     .only(
  //                                           //                 top: 0, bottom: 18.0),
  //                                           //             child: Text(
  //                                           //                 "${info.section}",
  //                                           //                 style: TextStyle(
  //                                           //                     fontSize: 18.0,
  //                                           //                     fontWeight:
  //                                           //                         FontWeight
  //                                           //                             .bold)),
  //                                           //           ),
  //                                           //         if (info.orientation ==
  //                                           //             "landscape")
  //                                           //           _buildLandscape(
  //                                           //               info.orientation,
  //                                           //               info.body),
  //                                           //         if (info.orientation ==
  //                                           //             "portrait")
  //                                           //           _buildPortrait(
  //                                           //               info.orientation,
  //                                           //               info.body),
  //                                           //         if (info.orientation ==
  //                                           //             "landscape_rectangle")
  //                                           //           _buildLandscapeRectangle(
  //                                           //               info.sectionTag,
  //                                           //               info.body),
  //                                           //         SizedBox(height: 25),
  //                                           //       ],
  //                                           //     );
  //                                           //   },
  //                                           // ),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               } else {
  //                 return Container(); // Handle other states if any
  //               }
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showTownhallInfoSheet(BuildContext context) {
    showModalBottomSheet(
      //backgroundColor: Colors.red,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 20, 1, 0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
                                alignment: Alignment.topRight,
                                height: 20.0,
                                child: IconButton(
                                    alignment: Alignment.topRight,
                                    icon: Icon(Icons.close, color: Colors.grey),
                                    iconSize: 20.0,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Townhall Info',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.black,
                                    ),
                                    _showTownhallInfoLoader
                                        ? Column(
                                            children: [
                                              SizedBox(height: 20),
                                              _buildBodyShimmerLoader(),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: townhallInfo.length,
                                                itemBuilder: (context, index) {
                                                  final section =
                                                      townhallInfo[index]
                                                          .section;
                                                  final body =
                                                      townhallInfo[index].body;
                                                  final section_tag = townhallInfo[
                                                                      index]
                                                                  .section_tag ==
                                                              null ||
                                                          townhallInfo[index]
                                                                  .section_tag ==
                                                              ""
                                                      ? ''
                                                      : townhallInfo[index]
                                                          .section_tag;
                                                  final orientation =
                                                      townhallInfo[index]
                                                                  .orientation ==
                                                              null
                                                          ? ''
                                                          : townhallInfo[index]
                                                              .orientation;
                                                  print(
                                                      "Orientation: ${orientation}");
                                                  final actionType =
                                                      townhallInfo[index]
                                                                  .action_type ==
                                                              null
                                                          ? ''
                                                          : townhallInfo[index]
                                                              .action_type;

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      section == "" ||
                                                              section == null
                                                          ? SizedBox()
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 0,
                                                                      bottom:
                                                                          18.0),
                                                              child: Text(
                                                                  "${section}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                      if (orientation ==
                                                          "landscape")
                                                        _buildLandscape(
                                                            orientation!, body),
                                                      if (orientation ==
                                                          "portrait")
                                                        _buildPortrait(
                                                            orientation!, body),
                                                      if (orientation ==
                                                          "landscape_rectangle")
                                                        _buildLandscapeRectangle(
                                                            section_tag
                                                                .toString(),
                                                            body),
                                                      SizedBox(height: 25),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Widget _floatingButton() {
    return FloatingActionButton(
      onPressed: () async {
        final rPrefGroup = await AppSharedPreferences.getValue(key: 'groupID');
        final rPrefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
        final rPreGroupName =
            await AppSharedPreferences.getValue(key: 'groupName');
        final rPreGroupNameFull =
            await AppSharedPreferences.getValue(key: 'groupFullName');
        // await Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return BlocProvider(
        //     create: (context) => PostsBloc(),
        //     child: CreatePost(),
        //   );
        // })).then((result) {
        //   if (result == 'refresh') {
        //     print("rGroup ${rPrefGroup}");
        //     //call the event
        //     _fetchTownhallFeeds(rPrefGroup.toString(), rPreGroupName.toString(),
        //         rPreGroupNameFull.toString(), true);
        //   }
        // });
      },
      backgroundColor: const Color(0xFF00AFEF),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
    );
  }

  Widget _bottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
      child: BottomNavigation(
          page: Feed.routeName, showBottomMenu: _showBottomMenu),
    );
  }

  Widget _buildHorizontalScrollSection(List topData, BuildContext cont) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 140,
      width: double.infinity,
      child: ListView.builder(
        controller: _topController,
        scrollDirection: Axis.horizontal,
        itemCount: topData.length,
        itemBuilder: (context, index) {
          final top = topData[index];
          return GestureDetector(
            onTap: _isFeedRequestInProgress
                ? null
                : () async {
                    _onTapOfTownhallCircle(top, cont);
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 70,
                    width: 90,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30.0 -
                              (30.0 * top.circle_reduction_percentage / 100),
                          backgroundColor: _selectedTownhallID.toString() ==
                                  top.townhall_id.toString()
                              ? Colors.lightBlue
                              : Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.network(
                              top.rep_picture_mid.toString().isEmpty
                                  ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
                                  : top.rep_picture_mid.toString(),
                              width: 55.0 -
                                  (55 * top.circle_reduction_percentage / 100),
                              height: 55.0 -
                                  (55 * top.circle_reduction_percentage / 100),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        _selectedTownhallID.toString() ==
                                top.townhall_id.toString()
                            ? Positioned(
                                bottom: 40.0 -
                                    (40 *
                                        top.circle_reduction_percentage /
                                        100),
                                right: 1,
                                child: Container(
                                  width: 20.0 -
                                      (20 *
                                          top.circle_reduction_percentage /
                                          100),
                                  height: 20.0 -
                                      (20 *
                                          top.circle_reduction_percentage /
                                          100),
                                  child: ImageIcon(
                                    AssetImage('images/info.png'),
                                    size: 25.0 -
                                        (25 *
                                            top.circle_reduction_percentage /
                                            100),
                                    color: Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      shape: BoxShape.circle),
                                )

                                // SizedBox(
                                //   width: 25,
                                //   child: IconButton(
                                //     iconSize: 35,
                                //     color: Colors.red,
                                //     icon: Icon(Typicons.info),
                                //     onPressed: () {
                                //       debugPrint(
                                //           "debug print");
                                //     }, // icon user
                                //   ),
                                // ),
                                )
                            : SizedBox(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, right: 4.0, left: 4.0, bottom: 0.0),
                    child: Column(
                      children: [
                        Text(
                          '${top.townhall_name}', // Replace with your desired text
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(${NumberFormat.compact().format(top.member_count)})', // Replace with your desired text
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ) // Adjust the space between CircleAvatar and Text
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List feedData) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 0),
        controller: _scrollController,
        itemCount: isThereResult ? data.length + 1 : data.length,
        itemBuilder: (context, index) {
          // Get the current time
          DateTime currentTime = DateTime.now();
          int days = 0; //days left for polls to end
          String poll_end_desc =
              ''; //description to show when poll is about to or has ended
          if (index == data.length) {
            isLastDownRequest = index < 20
                ? true
                : false; //This is the last down request. No more data to load again.
            return Container(
              width: 80.0,
              height: 80.0,
              child: data.length == 1
                  ? SizedBox()
                  : Container(
                      child: index < 20
                          ? null
                          : SpinKitCircle(
                              color: Colors.blue,
                              size: 30.0,
                            ),
                    ),
            );
          }
          if (last_post_id.isEmpty || newLoader) {
            first_post_id = data[0].post_id;
          }
          final feeds = data[index];
          print("Post ID: ${feeds.post_id}");
          print("designation: ${feeds.designation}");
          List<dynamic> imageList = [];
          List<dynamic> optionList = [];
          DateTime? pollEndTime;
          bool hasPollEnded = false;
          bool hasVoted = false;

          last_post_id = feeds.post_id;

          likeCounts.add(Like(
              isLiked: feeds.is_liked == "yes" ? true : false,
              likeCounts: feeds.like_count,
              id: int.parse(feeds.post_id)));
          commentCounts.add(Comment(
              counts: feeds.comment_count, id: int.parse(feeds.post_id)));
          int arrIndex = likeCounts.indexWhere(
              (likeCounts) => likeCounts.id == int.parse(feeds.post_id));
          int arrCIndex = commentCounts.indexWhere(
              (commentCounts) => commentCounts.id == int.parse(feeds.post_id));
          if (feeds.post_images != null) {
            // print("My first post: " +
            //     data[0].post_id);

            for (FeedImagesData image in feeds.post_images!) {
              //imageList.add(image.name);
              imageList.add({
                'name': image.name,
                'mp4_video': image.mp4_video,
                'type': image.type,
                'thumbnail': image.thumbnail,
              });
              debugPrint("IMG: ${imageList}");
            }
          }
          if (feeds.poll == "yes") {
            hasVoted = feeds.user_voted;
            pollEndTime = DateTime.parse(feeds.poll_end);
            hasPollEnded = currentTime.isAfter(pollEndTime);
            days = DateTime(
              DateTime.parse(feeds.poll_end).year,
              DateTime.parse(feeds.poll_end).month,
              DateTime.parse(feeds.poll_end).day,
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
            print("poll Date: ${feeds.poll_end}");

            for (PollOptions poll in feeds.poll_details!) {
              optionList.add({
                'option_id': poll.option_id,
                'option_value': poll.option_value,
                'votes': poll.votes,
              });
            }
          }
          print(
              "This time from server ${feeds.post_message} ${DateTime.parse(feeds.post_updated_time)} CURRENT DATETIME ${DateTime.now()}");
          Map<String, dynamic> mapData = {
            'id': feeds.post_id,
            'post_message': feeds.post_message,
            'like_count': feeds.like_count,
            'comment_count': feeds.comment_count,
            'post_profile_pics': feeds.post_profile_pics,
            'post_update_by': feeds.post_update_by,
            'post_updated_time': feeds.post_updated_time,
            'username': feeds.username,
            'post_alignment': feeds.post_alignment,
            'is_comment_of_comment': false,
            'media': imageList,
          };
          String videoUrl =
              "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
          return GestureDetector(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (contextA) => PostsBloc(),
                    ),
                  ],
                  child: Comments(
                    mapData: mapData,
                  ),
                );
              }));
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: feeds.noticeboard_msg == "yes"
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
                          onTap: () {
                            Map<String, dynamic> mapData = {
                              'subjectID': feeds.posted_by,
                              'picture': feeds.post_profile_pics,
                              'post_update_by': feeds.post_update_by,
                              'username': feeds.username,
                            };
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (contextA) => p.PeopleBloc(),
                                  ),
                                  BlocProvider(
                                    create: (context) => PostsBloc(),
                                  ),
                                ],
                                child: PeopleProfile(mapData: mapData),
                              );
                            }));
                          },
                          child: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              '${feeds.post_profile_pics}',
                            ),
                            radius: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, top: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Map<String, dynamic> mapData = {
                                          'subjectID': feeds.posted_by,
                                          'picture': feeds.post_profile_pics,
                                          'post_update_by':
                                              feeds.post_update_by,
                                          'username': feeds.username,
                                        };
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create: (contextA) =>
                                                    p.PeopleBloc(),
                                              ),
                                              BlocProvider(
                                                create: (context) =>
                                                    PostsBloc(),
                                              ),
                                            ],
                                            child:
                                                PeopleProfile(mapData: mapData),
                                          );
                                        }));
                                      },
                                      child: Text(
                                        _substring(feeds.post_update_by, 20),
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
                                    '. ' +
                                        _getTimeAgo(DateTime.parse(
                                            feeds.post_updated_time)),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.0),
                              GestureDetector(
                                onTap: () {
                                  Map<String, dynamic> mapData = {
                                    'subjectID': feeds.posted_by,
                                    'picture': feeds.post_profile_pics,
                                    'post_update_by': feeds.post_update_by,
                                    'username': feeds.username,
                                  };
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (contextA) => p.PeopleBloc(),
                                        ),
                                        BlocProvider(
                                          create: (context) => PostsBloc(),
                                        ),
                                      ],
                                      child: PeopleProfile(mapData: mapData),
                                    );
                                  }));
                                },
                                child: Row(
                                  children: [
                                    feeds.designation != "" &&
                                            feeds.designation != null
                                        ? Container(
                                            padding: EdgeInsets.only(
                                                left: 7, right: 7),
                                            decoration: BoxDecoration(
                                                color: Colors
                                                    .lightBlue, //0xffCCE9FD
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            alignment: Alignment.centerLeft,
                                            height: 20,
                                            child: Text(
                                              _substring(feeds.designation, 30),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0),
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      width: feeds.designation != "" &&
                                              feeds.designation != null
                                          ? 10
                                          : 0,
                                    ),
                                    Text(
                                      '@${feeds.username}',
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
                      alignment: feeds.post_alignment == "ltr" ||
                              feeds.post_alignment == null ||
                              feeds.post_alignment == ""
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      child: InkWell(
                        onLongPress: () {
                          FlutterClipboard.copy(feeds.post_message).then(
                            (value) => GFToast.showToast('Copied', context,
                                toastPosition: GFToastPosition.BOTTOM,
                                textStyle: TextStyle(
                                    fontSize: 15, color: GFColors.DARK),
                                backgroundColor: GFColors.LIGHT,
                                trailing: Icon(
                                  Icons.notifications,
                                  color: GFColors.SUCCESS,
                                )),
                          );
                        },
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (contextA) => PostsBloc(),
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
                            text: feeds.post_message,
                            style: TextStyle(fontSize: 15),
                            textAlign: feeds.post_alignment == "rtl"
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (imageList.length > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                      child: ImageSwipe(imageList: imageList),
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
                            Text(
                                '${numberFormat(commentCounts[arrCIndex].counts)}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              child: Icon(
                                  likeCounts[arrIndex].isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: likeCounts[arrIndex].isLiked
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 18.0),
                              onTap: () {
                                setState(() {
                                  _clickedID = int.parse(feeds.post_id);
                                });

                                if (likeCounts[arrIndex].isLiked) {
                                  BlocProvider.of<PostsBloc>(context).add(
                                    UnLikePostEvent(post_id: feeds.post_id),
                                  );
                                } else {
                                  BlocProvider.of<PostsBloc>(context).add(
                                    LikePostEvent(post_id: feeds.post_id),
                                  );
                                  _toggleLike(likeCounts[arrIndex].id);
                                }
                              },
                            ),
                            SizedBox(width: 4.0),
                            Text(
                                '${numberFormat(likeCounts[arrIndex].likeCounts)}',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0)),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                share(
                                  feeds.sharelink,
                                  '',
                                );
                              },
                              child: Icon(Icons.share_outlined,
                                  color: Colors.grey, size: 18.0),
                            ),
                            SizedBox(width: 4.0),
                          ],
                        ),
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
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
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
                                                    ScaffoldMessenger.of(
                                                            context)
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
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  BlocProvider.of<PostsBloc>(
                                                          context)
                                                      .add(
                                                    ReportAbuseEvent(
                                                        comment:
                                                            _controllerComment
                                                                .text,
                                                        post_id: feeds.post_id,
                                                        reported:
                                                            feeds.posted_by),
                                                  );
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'Submit',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                              setState(() {
                                _clickedID = index;
                              });
                              BlocProvider.of<PostsBloc>(context).add(
                                DeleteFeedEvent(
                                    post_id: feeds.post_id,
                                    posted_by: feeds.posted_by),
                              );
                            } else if (value == 'block') {
                              BlocProvider.of<PostsBloc>(context).add(
                                BlockUserEvent(
                                    subjectID: feeds.posted_by,
                                    req_type: 'block'),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'report',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Report'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Delete'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'block',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Block'),
                              ),
                            ),
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
          );
        },
      ),
    );
  }

  Widget _buildLandscape(String orientation, List<BodyData>? items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            height: 180,
            // color: Colors.blue,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                      width: 15,
                    ),
                itemCount: items!.length,
                itemBuilder: (context, index) {
                  return items[index].image == null || items[index].image == ""
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //if orientation is landscape
                            if (orientation == "landscape")
                              Container(
                                width: 120,
                                // color: Colors.red,
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 38,
                                      backgroundColor: Colors.grey,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          items[index].image.toString(),
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      height: 80,
                                      width: 100,
                                      child: HtmlWidget(items[index].body),
                                    )
                                  ],
                                ),
                              ),
                            if (orientation == "landscape_rectangle")
                              Container(
                                width: 120,
                                // color: Colors.red,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 300,
                                      height: 100,
                                      // color: Colors.yellow,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      height: 80,
                                      width: 100,
                                      child: HtmlWidget(items[index].body),
                                    )
                                  ],
                                ),
                              ),
                          ],
                        );
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait(String orientation, List<BodyData>? items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 2,
                ),
            itemCount: items!.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: index < items.length - 1 ? 1 : 0),
                    height: 85,
                    width: double.infinity,
                    //color: Colors.blue,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        items[index].image == null || items[index].image == ""
                            ? SizedBox()
                            : Container(
                                width: 65,
                                height: 65,
                                // color: Colors.red,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      items[index].image.toString(),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: items[index].image == null ||
                                  items[index].image == ""
                              ? 0
                              : 20,
                        ),
                        Flexible(
                          child: Container(
                            height: 99,
                            //color: Colors.green,
                            child: HtmlWidget('${items[index].body}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ],
    );
  }

  Widget _buildLandscapeRectangle(String section_tag, List<BodyData>? items) {
    for (var i = 0; i < items!.length; i++)
      _audioItems.add(AudioItem(
          bodyTxt: '${items[i].body}',
          audioUrl: '${items[i].link}',
          bgImage: '${items[i].image}'));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            height: 190,
            //color: Colors.blue,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                      width: 15,
                    ),
                itemCount: _audioItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    height: 200,
                    // color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 0.5,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0)),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(_audioItems[index].bgImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            StatefulBuilder(builder: (BuildContext context,
                                StateSetter newSetState) {
                              return IconButton(
                                  alignment: Alignment.topRight,
                                  icon: isPlaying
                                      ? Icon(Icons.pause_circle,
                                          color: Colors.grey[300])
                                      : Icon(Icons.play_circle,
                                          color: Colors.grey[300]),
                                  iconSize: 50.0,
                                  onPressed: () async {
                                    if (_audioPlayerController.isPlaying) {
                                      _audioPlayerController
                                          .pause(_audioPlayer);
                                      newSetState(() {
                                        isPlaying = false;
                                      });
                                    } else if (_audioPlayerController.isPause) {
                                      _audioPlayerController
                                          .resume(_audioPlayer);
                                      newSetState(() {
                                        isPlaying = false;
                                      });
                                    } else {
                                      newSetState(() {
                                        isPlaying = true;
                                      });

                                      //_audioPlayerController.resume(_audioPlayer);
                                      _audioPlayerController.play(_audioPlayer,
                                          _audioItems[index].audioUrl);
                                      print("Play");
                                    }
                                    // if (isPlaying) {
                                    //   _audioPlayer.stop();
                                    // } else {
                                    //   await _audioPlayer.play(
                                    //       UrlSource('${items[index].link}'));
                                    // }

                                    // setState(() {
                                    //   isPlaying = !isPlaying;
                                    // });
                                  });
                            }),
                          ],
                        ),
                        Container(
                          //color: Colors.red,
                          width: 200,
                          child: HtmlWidget(_audioItems[index].bodyTxt),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  String _getTimeAgo(DateTime utcTime) {
    //return moment.from(utcTime.toLocal());
    return moment.from(utcTime);
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

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        _deviceType = "Android";
      } else if (Platform.isIOS) {
        _deviceType = "IOS";
      } else if (Platform.isLinux) {
        _deviceType = "Linux";
      } else if (Platform.isMacOS) {
        _deviceType = "MacOS";
      } else if (Platform.isWindows) {
        _deviceType = "Window";
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    print("My device type: ${_deviceType}");
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await launch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<String?> getOrgName() async {
    return await AppSharedPreferences.getValue(key: 'orgName');
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  Future<String?> getOrg() async {
    return await AppSharedPreferences.getValue(key: 'orgID');
  }

  void _toggleLike(int id) {
    int index = likeCounts
        .indexWhere((likeCounts) => likeCounts.id == int.parse(id.toString()));
    setState(() {
      likeCounts.insert(
          index,
          Like(
              isLiked: likeCounts[index].isLiked ? false : true,
              likeCounts: likeCounts[index].isLiked
                  ? likeCounts[index].likeCounts - 1
                  : likeCounts[index].likeCounts + 1,
              id: id));
    });
  }

  Widget _buildStartConversation() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 8.5),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (() async {
              // await Navigator.pushNamed(context, CreatePost.routeName,
              //     arguments: {
              //       'canPost': canPost,
              //       'canPostPoll': canPostPoll
              //     }).then((result) {
              //   if (result == 'refresh') {
              //     //appended the new posted to the data list

              //     // BlocProvider.of<PostsBloc>(context).add(
              //     //   FeedEvent(
              //     //     feedRequest: FeedRequest(
              //     //         skipOnboarding: true,
              //     //         skipTopFeed: true,
              //     //         isFirstFeedRequest: false,
              //     //         last_post_id: '',
              //     //         group_id: groupId,
              //     //         org_id: orgId,
              //     //         page: '',
              //     //         limit: limit,
              //     //         older_or_newer: '',
              //     //         page_owner: '',
              //     //         device_token: getDeviceToken(),
              //     //         device_type: _deviceType),
              //     //   ),
              //     // );
              //   }
              // });
            }),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Image.asset('images/nopost.svg'),
                  SvgPicture.asset(
                    'images/nopost.svg',
                    width: 130,
                    height: 130,
                  ),
                  Text("Start the conversation"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _fetchOlderPosts() async {
    final prefTownhallID = await AppSharedPreferences.getValue(key: 'groupID');
    if (_newNextPage == _nextPage) {
      //if another request is send and it's the same with ongoing new page request, cancel it.
      return;
    }
    _newNextPage = _nextPage;

    setState(() {
      _showOlderPostLoader = true;
    });
    final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
    BlocProvider.of<PostsBloc>(context).add(FeedEvent(
      orgID: prefOrgID.toString(),
      groupID: prefTownhallID.toString(),
      page: _nextPage.toString(),
      limit: limit.toString(),
      olderOrNewer: 'older',
      pageOwner: '',
    ));
    setState(() {
      _isFeedRequestInProgress = true;
    });
  }

  _getNewerPosts(int limit, deviceToken) {
    setState(() {
      isLoadingUpRequest = true;
      newLoader = true;
      loading = false;
      firstTimeLoading = false;
    });
    isThereResult = false;
    print("I am search for new post with ID: ${first_post_id}");
    // BlocProvider.of<PostsBloc>(context).add(
    //   FeedEvent(
    //     feedRequest: FeedRequest(
    //         skipOnboarding: false,
    //         skipTopFeed: false,
    //         isFirstFeedRequest: false,
    //         last_post_id: first_post_id,
    //         group_id: groupId,
    //         org_id: orgId,
    //         page: '',
    //         limit: limit,
    //         older_or_newer: 'newer',
    //         townhall_tap: true,
    //         page_owner: '',
    //         device_token: deviceToken,
    //         device_type: _deviceType),
    //   ),
    // );
    setState(() {});
  }

  Future<String?> getGroupID() async {
    return await AppSharedPreferences.getValue(key: 'groupID');
  }

  _getCachedTopData() async {
    final prefOrgID = AppSharedPreferences.getValue(key: 'orgID');
    final prefGroupID = AppSharedPreferences.getValue(key: "groupID");
    var pageData =
        await getPageData('page_feed_top_${prefOrgID}_${prefGroupID}');
    if (pageData != null && pageData != "") {
      var json = jsonDecode(pageData);
      setState(() {
        _showLoadingTop = false;
        topFeed = json
            .map<TopFeedData>((json) => TopFeedData.fromJson(json))
            .toList();
      });
    }
  }

  _getCachedFeedData(String? townhallID) async {
    final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
    print('rGroup page_feed_${prefOrgID}_${townhallID}');
    var pageData = await getPageData('page_feed_${prefOrgID}_${townhallID}');
    print(pageData);
    if (pageData != null && pageData != "") {
      print(
          "Cached data was called Org ID: ${prefOrgID} TowhnID: ${townhallID}");
      var json = jsonDecode(pageData);
      setState(() {
        // List<Map<String, dynamic>> data = List.from(json);
        _showBodyLoading = false;
        isCachedDataAvailable = true;
        data = json.map<FeedData>((json) => FeedData.fromJson(json)).toList();
      });
    } else {
      setState(() {
        isCachedDataAvailable = false;
      });
      print("Cached Statuc:${isCachedDataAvailable}");
    }
  }

  _onTapOfTownhallCircle(top, BuildContext cont) async {
    //check if this is a first or second tap
    final prefOrgID = await _getOrgID();
    setState(() {
      _nextPage = 1;
      canPost =
          top.can_post == "yes" || top.can_post_polls == "yes" ? true : false;
    });
    if (_selectedTownhallID.toString() == top.townhall_id.toString() &&
        prefOrgID == top.org_id.toString() &&
        top.can_show_townhall_info == "yes") {
      _showTownhallInfoSheet(cont);
      setState(() {
        _showTownhallInfoLoader = true;
        _selectedTownhallID = int.parse(top.townhall_id);
      });
      _fetchTownhallInfo(prefOrgID, top.townhall_id.toString());
    } else {
      data = [];
      AppSharedPreferences.setValue(key: 'groupID', value: top.townhall_id);
      AppSharedPreferences.setValue(
          key: 'groupFullName', value: top.townhall_full_name);
      AppSharedPreferences.setValue(
          key: 'isTownhallLeader', value: top.is_townhall_leader);
      setState(() {
        showFloatingButton = top.can_post == "yes" ? true : false;
        canPostPoll = top.can_post_polls == "yes" ? true : false;
        _showNewerPostLoader = true;
        _selectedTownhallID = int.parse(top.townhall_id);
      });
      _fetchTownhallFeeds(top.townhall_id, top.townhall_display_name,
          top.townhall_full_name, true);
      //get cache data
      print("rGroup tapped townhall ID:  ${top.townhall_id}");
      _getCachedFeedData(top.townhall_id.toString());
    }
  }

  _fetchTownhallFeeds(String townhall_id, String townhall_display_name,
      String townhall_full_name, bool townhall_tap) {
    var deviceToken = getDeviceToken();
    // _getCachedFeedData(int.parse(townhall_id));
    if (townhall_display_name != '') {
      AppSharedPreferences.setValue(
          key: 'groupName', value: townhall_display_name);
    }
    if (townhall_full_name != '') {
      AppSharedPreferences.setValue(
          key: 'groupFullName', value: townhall_full_name);
    }
    setState(() {
      _isFeedRequestInProgress = true;
    });
    print("rGroup next page ${_nextPage}");
    BlocProvider.of<PostsBloc>(context).add(FeedEvent(
      orgID: orgId,
      // token: token.toString(),
      groupID: townhall_id.toString(),
      page: _nextPage.toString(),
      limit: limit.toString(),
      olderOrNewer: older_or_newer,
      pageOwner: '',
    ));
  }

  _fetchTownhallInfo(String orgID, String townhallID) {
    BlocProvider.of<PostsBloc>(context).add(GetTownhallInfoEvent(
        orgID: orgID, townhallID: townhallID, isThisAMore: ''));
    // BlocProvider.of<PostsBloc>(context)
    //     .add(GetTownhallInfoEvent(orgID: orgID.toString()));
  }

  _fetchLandingGroup() {
    BlocProvider.of<PostsBloc>(context).add(LandingGroupEvent());
  }

  _fetchTopFeed(String townhallID) {
    BlocProvider.of<PostsBloc>(context).add(TopFeedEvent(orgID: townhallID));
  }

  _fetchTownhall(String orgID, String groupID, String page, String limit,
      String orderOrNewer, String pageOwner) {
    BlocProvider.of<PostsBloc>(context).add(FeedEvent(
        orgID: orgID,
        groupID: groupID,
        page: page,
        limit: limit,
        olderOrNewer: orderOrNewer,
        pageOwner: pageOwner));
  }

  _checkOnboarded() {
    BlocProvider.of<PostsBloc>(context).add(
      OnboardingEvent(),
    );
  }

  Future<String> _getOrgID() async {
    var orgID = await AppSharedPreferences.getValue(key: 'orgID');
    return orgID.toString();
  }

  Future<String> _getGroupID() async {
    var groupID = await AppSharedPreferences.getValue(key: 'groupID');
    return groupID.toString();
  }

  // _setOrgName() async {
  //   var organizationName = await getOrgName();
  //   setState(() {
  //     orgName = organizationName.toString();
  //   });
  //   print("This is orgName: ${orgName}");
  // }
  // List<Widget> buildSliverAppBar(BuildContext context, String profilePicPath) {

  //   // void _handleProfilePicTap() {
  //   //   // Do something when the profile picture is tapped
  //   //   Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(builder: (context) => ProfilePage()),
  //   //   );
  //   // }

  //   return [
  //     SliverAppBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       title: Row(
  //         children: [
  //           Image.asset(
  //             'images/icon_blue.png',
  //             height: 25,
  //             fit: BoxFit.contain,
  //           ),
  //           const SizedBox(width: 8),
  //           // Add a placeholder SizedBox to separate the logo and profile icon
  //           Expanded(child: Container()),
  //           // Circular profile icon
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.push(context, MaterialPageRoute(builder: (context) {
  //                 return BlocProvider(
  //                   create: (context) => o.OrganizationBloc(),
  //                   child: NotificationsPage(),
  //                 );
  //               }));
  //             },
  //             child: CircleAvatar(
  //               backgroundImage: NetworkImage(
  //                   profilePicPath), // _profilePicUrl should be the URL of the network image
  //               radius: 18,
  //             ),
  //           ),
  //         ],
  //       ),
  //       automaticallyImplyLeading: false,
  //       floating: true,
  //       snap: true,
  //     ),
  //   ];
  // }
}

class AudioItem {
  final String bodyTxt;
  final String audioUrl;
  final String bgImage;

  AudioItem(
      {required this.bodyTxt, required this.audioUrl, required this.bgImage});
}

class AudioPlayerController {
  Duration duration = Duration();
  Duration position = Duration();
  bool isPlaying = false;
  bool isPause = false;
  // late VoidCallback _stateSetter;

  void play(AudioPlayer player, String url) async {
    await player.stop();
    await player.play(UrlSource(url));

    player.onDurationChanged.listen((event) {
      duration = event;
      setState(() {}); // Update UI on duration change
    });
    player.onPlayerStateChanged.listen((event) {
      isPlaying = event == PlayerState.playing;
      setState(() {});
      print(isPlaying);
    });

    player.onPositionChanged.listen((event) {
      position = event;
      setState(() {}); // Update UI on position change
    });
  }

  void pause(AudioPlayer player) async {
    //await _audioPlayer.pause();
    await player.pause();
    setState(() {
      isPlaying = false;
      isPause = true;
    });
    print("isPause ${isPause}");
  }

  void resume(AudioPlayer player) async {
    // await _audioPlayer.resume();
    await player.resume();
    setState(() {
      isPlaying = true;
      isPause = false;
    });
  }

  void seek(AudioPlayer player, Duration duration) async {
    //await _audioPlayer.seek(duration);
    await player.seek(duration);
  }

  void setState(VoidCallback callback) {
    //_stateSetter = callback;
  }
}
