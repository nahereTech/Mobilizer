import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart' as auth;
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/feed/feed_request.dart';
import 'package:mobilizer/models/feed/topfeed_response.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/list_of_org_members.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/pages/post/createpost.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:mobilizer/pages/push_notification/post_notification_screen.dart'
    as postN;
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
import 'package:mobilizer/pages/settings/settings.dart' as settings;
import 'package:mobilizer/pages/suggestion/org_suggestion.dart';
import 'package:mobilizer/pages/suggestion/suggestion.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:mobilizer/widget/bottom_sheet_pick_edit_townhalls.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// import 'package:simple_moment/simple_moment.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class Feed extends StatefulWidget {
  static String routeName = 'feed_screen';
  const Feed({Key? key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with WidgetsBindingObserver {
  var deviceToken = getDeviceToken();
  late ScrollController _scrollController;
  bool _showLoadingTop = true;
  bool _showBodyLoading = true;
  bool _isReporting = false;
  bool _isBlocking = false;
  bool _isDeleting = false;
  bool _showNewerPostLoader = false;
  bool _showOlderPostLoader = false;
  bool _showTownhallsOnTop = true;
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
  String _userID = '';
  bool _isLoading = true;
  bool _isLoadingTop = true;
  bool _showCircleRow = true; // Initially show circle row

  // Initially show bottom menu
  double _previousOffset = 0; // Track the previous scroll offset
  List<dynamic> data = [];
  List<dynamic> newDataList = []; //new data from list.
  List<dynamic> newList = []; //list of groups with new feed notification.
  List<TopFeedData> topFeed = [];
  // List<InfoData> townhallInfo = [];
  List<dynamic> _isLikeList = [];
  //AudioPlayer _audioPlayer = AudioPlayer();

  //List<AudioItem> _audioItems = <AudioItem>[];

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
  String _selectedTownhallID = "";
  int _nextPage = 1;
  int _newNextPage = -1; //used to know already ongoing next page number
  int _buildNo = -1;
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
  DateTime? postDateDiff;

  final newVersion =
      NewVersionPlus(iOSId: IOSPackageID, androidId: androidPackageID);

  int limit = 25;
  late Timer _timer;
  // var moment = new Moment.now();
  var sampleVideo =
      "https://ia601205.us.archive.org/18/items/SampleVideo1280x7201mb/SampleVideo_1280x720_1mb.mp4";
  @override
  void initState() {
    _setUserID();
    _setGroupID();
    // print("Group: ${_getGroupID().toString()}");
    _getCachedTopData();
    _getCachedFeedData();
    _checkOnboarded();
    initPlatformState();
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    _loadProfileImage();
    WidgetsBinding.instance.addObserver(this);
    // _timer =
    //     Timer.periodic(Duration(seconds: 59), (Timer t) => _updateTimeAgo());
    // Listen for new messages for the recipient
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_userID != 'null' || _userID != '') {
      if (state == AppLifecycleState.resumed) {
        //_updateUserStatus(true);
      } else {
        //_updateUserStatus(false);
      }
    }
  }

  // void _scrollListener() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     _isScrollingUp = true;
  //     _fetchOlderPosts();
  //   }
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.minScrollExtent) {
  //     //_getNewerPosts(limit, getDeviceToken());
  //     _isScrollingUp = false;
  //   }
  //   final currentOffset = _scrollController.offset;
  //   final direction = currentOffset - _previousOffset;
  //   setState(() {
  //     if (direction < 0) {
  //       // Scrolling up
  //       _showBottomMenu = true;
  //       _showCircleRow = true;
  //     } else if (direction > 0) {
  //       // Scrolling down
  //       _showBottomMenu = false;
  //       _showCircleRow = false;
  //     }
  //     _previousOffset = currentOffset;
  //   });
  // }

  final ScrollController _topController = ScrollController();
  void _scrollToPosition(double position) {
    _topController.jumpTo(position);
    // _topController.animateTo(
    //   position,
    //   duration: Duration(seconds: 2),
    //   curve: Curves.easeIn,
    // );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  final GlobalKey<CustomDropdownButtonState> dropdownKey =
      GlobalKey<CustomDropdownButtonState>();
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
    return GestureDetector(
      onTap: () {
        dropdownKey.currentState?.closeDropdown();
      },
      child: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) async {
          if (state is InvalidTokenState) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BlocProvider(
                create: (context) => auth.AuthBloc(),
                child: LoginScreen(showSnack: ''),
              );
            }));
          }
          if (state is GoToSuggestionState) {
            Navigator.pushNamed(context, SuggestionScreen.routeName);
          }
          //Go to profile page
          if (state is GoToProfileState) {
            _showBodyLoading = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            Navigator.pushNamed(context, Profile.routeName);
          }
          if (state
              is GoToOrganizationState) //Go to Organization suggestion page
          {
            _showBodyLoading = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BlocProvider(
                create: (context) => o.OrganizationBloc(),
                child: OrgSuggestionScreen(),
              );
            }));
          }
          if (state is LandingGroupState) {
            print('LandingGroupState');
            _buildNo = state.buildNo;
            _fetchLandingGroup();
          }
          if (state is LoadedLandingGroupState) {
            _selectedTownhallID = state.responseData.townhall_id;
            _fetchTopFeed(state.responseData.org_id.toString());
          }
          if (state is FullyOnboardedState) {
            //get top feed
            _buildNo = state.buildNo;
            print('FullyOnboardedState');
            final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');

            _fetchTopFeed(prefOrgID.toString());
          }
          if (state is LoadedTopFeedState) {
            print("Show Townhalls: ${state.showTownhallsOnTop}");
            setState(() {
              _showTownhallsOnTop = state.showTownhallsOnTop;
            });

            final prefGroupID =
                await AppSharedPreferences.getValue(key: 'groupID');
            final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
            final prefGroupName =
                await AppSharedPreferences.getValue(key: 'groupName');

            _selectedTownhallID = prefGroupID.toString() == ""
                ? state.topFeedResponse.data![0].townhall_id
                : prefGroupID.toString();
            if (prefGroupID.toString() == "") {
              AppSharedPreferences.setValue(
                  key: 'isTownhallLeader',
                  value: state.topFeedResponse.data![0].is_townhall_leader);
            }
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
              setState(() {
                canPostPoll =
                    state.topFeedResponse.data![0].can_post_polls == "yes"
                        ? true
                        : false;
              });
            } else {
              //Mr. Ugo said if onboarding landing townhall ID is not in the list of topFeed townhall ID, immediately set shared preference group ID to first element in the topFeed list.
              int arrIndex = state.topFeedResponse.data!.indexWhere(
                  (element) => element.townhall_id.toString() == prefGroupID);

              if (arrIndex == -1) {
                _selectedTownhallID =
                    state.topFeedResponse.data![0].townhall_id;
                AppSharedPreferences.setValue(
                    key: 'groupID',
                    value:
                        state.topFeedResponse.data![0].townhall_id.toString());
                AppSharedPreferences.setValue(
                    key: 'groupName',
                    value:
                        state.topFeedResponse.data![0].townhall_display_name);
                AppSharedPreferences.setValue(
                    key: 'groupFullName',
                    value: state.topFeedResponse.data![0].townhall_full_name);
                setState(() {
                  canPostPoll =
                      state.topFeedResponse.data![0].can_post_polls == "yes"
                          ? true
                          : false;
                });
              } else {
                setState(() {
                  canPostPoll =
                      state.topFeedResponse.data![arrIndex].can_post_polls ==
                              "yes"
                          ? true
                          : false;
                });
              }
            }
            _fetchTownhallFeeds(_selectedTownhallID.toString(),
                prefGroupName.toString(), '', false);
            print("Selec ${prefOrgID} ${_selectedTownhallID}");
            AppSharedPreferences.setValue(
                key: "page_feed_top_${prefOrgID}_${_selectedTownhallID}",
                value: jsonEncode(state.topFeedResponse.data));
            orgName = await AppSharedPreferences.getValue(key: 'orgName');
            _showLoadingTop = false;
            topFeed = state.topFeedResponse.data!;
            Future.delayed(Duration(seconds: 1), () {
              if (_showTownhallsOnTop) {
                _scrollToPosition(20.0);
              }
            });
          }
          if (state is TopFeedBlockedState) {
            _showBodyLoading = false;
            _showLoadingTop = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            _isReporting = false;
            _isDeleting = false;
            _isBlocking = false;
            final snackBar = SnackBar(
                duration: Duration(seconds: 15),
                backgroundColor: Colors.red,
                content: Text(state.message));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is TopFeedNoPermissionState) {
            final snackBar = SnackBar(
                duration: Duration(seconds: 15),
                backgroundColor: Colors.red,
                content: Text(state.message));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is TopFeedPendingState) {
            _showBodyLoading = false;
            _showLoadingTop = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            _isReporting = false;
            _isDeleting = false;
            _isBlocking = false;
            final snackBar = SnackBar(
                duration: Duration(seconds: 15),
                backgroundColor: Colors.red,
                content: Text(state.message));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is TopFeedUpdateTownhallState) {
            _showBodyLoading = false;
            _showLoadingTop = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            _isReporting = false;
            _isDeleting = false;
            _isBlocking = false;
            final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
            print("Testing P");
            print(" Am here update ${prefOrgID.toString()}");
            if (mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return TownhallBottomSheetEdit(
                    orgID: prefOrgID.toString(),
                    hasUpdated: _hasUpdated,
                  );
                },
              );
            }
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
          if (state is CastedState) {
            print("state  emitted ${state.userOption} ${state.postID}");
            final prefGroupID =
                await AppSharedPreferences.getValue(key: 'groupID');
            final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
            AppSharedPreferences.setValue(
                key: "page_feed_${prefOrgID}_${prefGroupID}",
                value: jsonEncode(data));
          }
          if (state is AbuseReportState) {
            _isReporting = false;
            _controllerComment.text = '';
            final snackBar = SnackBar(
                backgroundColor: Color.fromARGB(255, 85, 207, 158),
                content: Text('User was successfully reported'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is LikeState) {
            final List<dynamic> newData = data;

            //update sharepreference with the new like details
            int index = newData.indexWhere((newData) =>
                newData.post_id.toString() == _clickedID.toString());

            if (index != -1) {
              newData[index].is_liked = true;
              newData[index].like_count = newData[index].like_count + 1;
              print("New Data ${newData[1].like_count} ${newData[1].is_liked}");
              final prefOrgID = await _getOrgID();
              AppSharedPreferences.setValue(
                  key: "page_feed_${prefOrgID}_${_selectedTownhallID}",
                  value: jsonEncode(newData));
            }
          }
          if (state is UnLikeState) {}
          if (state is BlockUserState) {
            final snackBar = SnackBar(
                backgroundColor: Color.fromARGB(255, 85, 207, 158),
                content: Text('User was successfully blocked'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              _isBlocking = false;
            });
          }
          if (state is DeleteFeedState) {
            print("delete state");
            int index = data.indexWhere(
                (data) => data.post_id.toString() == _clickedID.toString());
            if (index != -1) {
              data.removeAt(index);
              _clickedID = -1; //resetting click ID to

              //caching the new data
              final prefOrgID = await _getOrgID();
              AppSharedPreferences.setValue(
                  key: "page_feed_${prefOrgID}_${_selectedTownhallID}",
                  value: jsonEncode(data));
            } else {
              print("Index: $index");
            }
            setState(() {
              _isDeleting = false;
              loading = false;
              reloadTop = false;
              isNoNetwork = false;
            });

            print(state.deleteFeedResponse.msg);
            print(state.deleteFeedResponse.status);
            var deviceToken = getDeviceToken();
            // BlocProvider.of<PostsBloc>(context).add(
            //   FeedEvent(
            //     feedRequest: FeedRequest(
            //         skipOnboarding: false,
            //         skipTopFeed: false,
            //         isFirstFeedRequest: false,
            //         last_post_id: '',
            //         group_id: groupId,
            //         org_id: orgId,
            //         page: '',
            //         limit: limit,
            //         older_or_newer: '',
            //         page_owner: '',
            //         device_token: deviceToken,
            //         device_type: _deviceType),
            //   ),
            // );
          }
          if (state is BlockUserState) {
            final snackBar = SnackBar(
                backgroundColor: Color.fromARGB(255, 85, 207, 158),
                content: Text('User was successfully blocked'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (state is LoadedFeedState) {
            print("Has poll ended loaded feed state on poll");
            setState(() {
              data = state.feedResponse;
            });

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
                  ? topFeed[0].townhall_id
                  : prefGrpID;
              firstTimeLoading = false;
              _showVersionNotification(newVersion, context, _buildNo);
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
          // if (state is TownhallInfoState) {
          //   print("I am inside Townhall info");
          //   setState(() {
          //     townhallInfo = state.townhallResponse.data;
          //     _showTownhallInfoLoader = false;
          //   });
          // }
          if (state is NetworkState) {
            _showBodyLoading = false;
            _showLoadingTop = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            _isReporting = false;
            _isDeleting = false;
            _isBlocking = false;
          }
          if (state is ErrorState) {
            _showBodyLoading = false;
            _showLoadingTop = false;
            _showNewerPostLoader = false;
            _showOlderPostLoader = false;
            _isFeedRequestInProgress = false;
            _isReporting = false;
            _isDeleting = false;
            _isBlocking = false;

            if (state.errorFor == "like" || state.errorFor == "unlike") {
              _toggleLike(_clickedID);
            }
          }
        },
        builder: (context, state) {
          return OverlayLoaderWithAppIcon(
            isLoading:
                _isReporting || _isDeleting || _isBlocking ? true : false,
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
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return buildSliverAppBar(
                    topFeed,
                    context,
                  );
                },
                body: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    // Check if the scroll is vertical
                    if (notification.metrics.axis == Axis.vertical) {
                      if (notification.scrollDelta! > 0) {
                        // Scrolling down
                        setState(() {
                          _showBottomMenu = false;
                        });
                      } else if (notification.scrollDelta! < 0) {
                        // Scrolling up
                        setState(() {
                          _showBottomMenu = true;
                        });
                      }

                      // Check if the scroll is within the desired Container
                      if (notification.context
                              ?.findAncestorWidgetOfExactType<Container>() !=
                          null) {
                        if (notification.metrics.extentAfter == 0) {
                          // Show snackbar or perform other actions
                          _fetchOlderPosts();
                          print(
                              "Bottom At bottom: ${notification.metrics.extentAfter}");
                        } else {
                          print("Bottom: ${notification.metrics.extentAfter}");
                        }
                      }
                    }
                    // Return true to continue receiving notifications
                    return true;
                  },
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showNewerPostLoader) _buildNewPostShimmerLoader(),
                        if (data.length < 1 &&
                            canPost &&
                            !_showBodyLoading &&
                            !_showNewerPostLoader &&
                            !_showLoadingTop)
                          _buildStartConversation(canPost),
                        //canPost is false
                        if (data.length < 1 &&
                            canPost == false &&
                            !_showBodyLoading &&
                            !_showNewerPostLoader &&
                            !_showLoadingTop)
                          _buildStartConversation(canPost),
                        _showBodyLoading
                            ? _buildBodyShimmerLoader()
                            : Expanded(child: _buildTaskList()),
                        if (_showOlderPostLoader)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildOlderPostShimmerLoader(),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: canPost ? _floatingButton() : null,
              bottomNavigationBar: AnimatedContainer(
                duration: Duration(
                    milliseconds:
                        _showBottomMenu ? 350 : 350), // Adjusted duration
                height: _showBottomMenu ? kBottomNavigationBarHeight : 0.0,
                child: _showBottomMenu ? _bottomNavBar() : null,
              ),
            ),
          );
        },
      ),
    );
  }

  void _hasUpdated(bool status) {
    if (status) {
      _showLoadingTop = true;
      _showBodyLoading = true;
      _checkOnboarded();
    }
  }

  void _updateTimeAgo() {
    if (mounted)
      setState(() {
        postDateDiff;
      });
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImage = prefs.getString('profilePic') ?? 'default_image_path';
    });
  }

  PreferredSize _appBar() {
    return PreferredSize(
      //preferredSize: Size.fromHeight(kToolbarHeight),
      preferredSize: Size.fromHeight(kToolbarHeight),
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
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                      create: (context) => a.AuthBloc(),
                      child: settings.Settings(),
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            subtitle: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
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

  void _showTownhallInfoSheet(String orgID, String townhallID) {
    showModalBottomSheet(
      //backgroundColor: Colors.red,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (_) => PostsBloc()
            ..add(GetTownhallInfoEvent(
                orgID: orgID, townhallID: townhallID, isThisAMore: '')),
          child: TownhallInfoContent(),
        );
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
        // await await Navigator.pushNamed(context, CreatePost.routeName,
        //         arguments: {'canPost': canPost, 'canPostPoll': canPostPoll})

        // await Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return MultiBlocProvider(
        //     providers: [
        //       BlocProvider(
        //         create: (context) => PostsBloc(),
        //       ),
        //     ],
        //     // child: CreatePost(
        //     //   mapData: {'canPost': canPost, 'canPostPoll': canPostPoll, mapData: {},},
        //     // ),
        //   );
        // })).then((result) {
        //   if (result == 'refresh') {
        //     print("rGroupz ${rPrefGroup}");
        //     setState(() {
        //       _showNewerPostLoader = true;
        //       _nextPage = 1;
        //     });
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
                    _onTapOfTownhallCircle(top);
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

  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 15),
        // controller: _scrollController,
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
          final List<dynamic> optionList = [];
          late DateTime pollEndTime;
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
            print(
                "Poll rebuilding: ${feeds.post_id} ${feeds.post_message} ${feeds.user_voted}");
            hasVoted = feeds.user_voted;
            pollEndTime = DateTime.tryParse(feeds.poll_end) ?? DateTime.now();
            hasPollEnded = currentTime.isAfter(pollEndTime);

            Duration difference =
                DateTime.parse(feeds.poll_end).difference(DateTime.now());

            //int days = difference.inDays; // this trunctates remaining hours if it's not up to 24hours
            int days = (difference.inHours / 24)
                .ceil(); // Rounds up if there are extra hours
            int hours = difference.inHours.remainder(24);
            int minutes = difference.inMinutes.remainder(60);
            print("Days left: $days");
            poll_end_desc = days <= 0 && hours <= 0 && minutes <= 0
                ? 'ended'
                : days < 7 && days > 0
                    ? '$days days left'
                    : days == 0 && hours >= 1
                        ? '${hours.toString()} hour${hours > 1 ? 's' : ''} left'
                        : days == 0 && hours == 0 && minutes >= 1
                            ? '${minutes.toString()} minute${minutes > 1 ? 's' : ''} left'
                            : days > 6 && days < 30
                                ? '${daysToWeeks(days)} week${daysToWeeks(days) > 1 ? 's' : ''} left'
                                : days > 30
                                    ? '${daysToMonths(days)} month${daysToMonths(days) > 1 ? 's' : ''} left'
                                    : days > 365
                                        ? '${daysToYears(days)}year${daysToYears(days) > 1 ? 's' : ''} left'
                                        : '';
            print("poll Date: ${feeds.poll_end}");
            print(
                "Has poll ended: $hasPollEnded Message: ${feeds.post_message} ${(days <= 0 && hours <= 0 && minutes <= 0)} index ${index}  ${feeds.poll_end}");
            for (PollOptions poll in feeds.poll_details!) {
              optionList.add({
                'option_id': poll.option_id,
                'option_value': poll.option_value,
                'votes': poll.votes,
              });
            }
            print(
                "Options: ${optionList} index: ${index} feeds: ${feeds.post_message}");
          }
          print(
              "This time from server ${feeds.post_message} ${DateTime.parse(feeds.post_updated_time)} CURRENT DATETIME ${DateTime.now()}");
          Map<String, dynamic> mapData = {
            'id': feeds.post_id,
            'posted_by': feeds.posted_by.toString(),
            'post_message': feeds.post_message,
            'like_count': likeCounts[arrIndex].likeCounts,
            'is_liked': likeCounts[arrIndex].isLiked,
            'comment_count': feeds.comment_count,
            'post_profile_pics': feeds.post_profile_pics,
            'post_update_by': feeds.post_update_by,
            'post_updated_time': feeds.post_updated_time,
            'username': feeds.username,
            'post_alignment': feeds.post_alignment,
            'is_comment_of_comment': false,
            'media': imageList,
            'poll_details': feeds.poll_details,
            'poll_end': feeds.poll_end,
            'poll': feeds.poll,
            'total_votes': feeds.total_votes,
            'user_voted': feeds.user_voted,
            'user_option': feeds.user_option,
          };
          String videoUrl =
              "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
          Duration difference = currentTime.difference(DateTime.parse(
              feeds.post_updated_time)); // Calculate the difference
          postDateDiff =
              currentTime.subtract(difference); // Subtract the duration

          //feed details show here
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
                  if (feeds.reference_post != null)
                    GestureDetector(
                      onTap: () async {
                        Map<String, dynamic> mapData = {
                          'id': feeds.reference_post.post_id,
                          'posted_by':
                              feeds.reference_post.posted_by.toString(),
                          'post_message': feeds.reference_post.post_message,
                          'like_count': feeds.reference_post.like_count,
                          'is_liked': feeds.reference_post.is_liked,
                          'comment_count': feeds.reference_post.comment_count,
                          'post_profile_pics':
                              feeds.reference_post.post_profile_pics,
                          'post_update_by': feeds.reference_post.post_update_by,
                          'post_updated_time':
                              feeds.reference_post.post_updated_time,
                          'username': feeds.reference_post.username,
                          'post_alignment': feeds.reference_post.post_alignment,
                          'is_comment_of_comment': false,
                          'media': feeds.reference_post.post_images ?? [],
                          'poll_details': feeds.reference_post.poll_details,
                          'poll_end': feeds.reference_post.poll_end,
                          'poll': feeds.reference_post.poll,
                          'total_votes': feeds.reference_post.total_votes,
                          'user_voted': feeds.reference_post.user_voted,
                          'user_option': feeds.reference_post.user_option,
                        };
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => PostsBloc(),
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
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(
                                  '${feeds.reference_post.post_profile_pics}',
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${feeds.reference_post.post_update_by}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' · ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '@${feeds.reference_post.username}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' · ${_getTimeAgo(currentTime.subtract(currentTime.difference(DateTime.parse(feeds.reference_post.post_updated_time))))}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${feeds.reference_post.post_message}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // const SizedBox(width: 8),
                                        // ClipRRect(
                                        //   borderRadius: BorderRadius.circular(4.0),
                                        //   child: Image.network(
                                        //     'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/81c17eb9-9613-4db9-54a6-c6e3923ddb00/mid',
                                        //     width: 30,
                                        //     height: 30,
                                        //     fit: BoxFit.cover,
                                        //   ),
                                        // ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, top: 16.0),
                        child: GestureDetector(
                          onTap: () async {
                            Map<String, dynamic> mapData = {
                              'subjectID': feeds.posted_by,
                              'picture': feeds.post_profile_pics,
                              'post_update_by': feeds.post_update_by,
                              'username': feeds.username,
                            };
                            await Navigator.push(context,
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
                            })).then((result) async {
                              print("Am here");
                              if (result != null &&
                                  result['userAction'] == "block") {
                                setState(() {
                                  data.removeWhere((item) =>
                                      item.posted_by.toString() ==
                                      feeds.posted_by);
                                });
                                print("Action ${result['userAction']}");
                              }
                              if (result != null &&
                                  result['userAction'] == "unblock") {
                                //reload feeds
                                data = [];
                                setState(() {
                                  older_or_newer = "";
                                  _showBodyLoading = true;
                                  _isFeedRequestInProgress = true;
                                  _nextPage = 1;
                                });
                                final prefGroupName =
                                    await AppSharedPreferences.getValue(
                                        key: 'groupName');
                                final prefTownhallID =
                                    await AppSharedPreferences.getValue(
                                        key: "groupID");
                                _fetchTownhallFeeds(prefTownhallID.toString(),
                                    prefGroupName.toString(), '', false);
                              }
                            });
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
                                      onTap: () async {
                                        Map<String, dynamic> mapData = {
                                          'subjectID': feeds.posted_by,
                                          'picture': feeds.post_profile_pics,
                                          'post_update_by':
                                              feeds.post_update_by,
                                          'username': feeds.username,
                                        };
                                        await Navigator.push(context,
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
                                        })).then((result) async {
                                          print("Am here");
                                          if (result != null &&
                                              result['userAction'] == "block") {
                                            setState(() {
                                              data.removeWhere((item) =>
                                                  item.posted_by.toString() ==
                                                  feeds.posted_by);
                                            });
                                            print(
                                                "Action ${result['userAction']}");
                                          }
                                          if (result != null &&
                                              result['userAction'] ==
                                                  "unblock") {
                                            //reload feeds
                                            data = [];
                                            setState(() {
                                              older_or_newer = "";
                                              _showBodyLoading = true;
                                              _isFeedRequestInProgress = true;
                                              _nextPage = 1;
                                            });
                                            final prefGroupName =
                                                await AppSharedPreferences
                                                    .getValue(key: 'groupName');
                                            final prefTownhallID =
                                                await AppSharedPreferences
                                                    .getValue(key: "groupID");
                                            _fetchTownhallFeeds(
                                                prefTownhallID.toString(),
                                                prefGroupName.toString(),
                                                '',
                                                false);
                                          }
                                        });
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
                                    'subjectID': feeds.posted_by,
                                    'picture': feeds.post_profile_pics,
                                    'post_update_by': feeds.post_update_by,
                                    'username': feeds.username,
                                  };
                                  await Navigator.push(context,
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
                                  })).then((result) async {
                                    if (result != null &&
                                        result['userAction'] == "block") {
                                      setState(() {
                                        data.removeWhere((item) =>
                                            item.posted_by.toString() ==
                                            feeds.posted_by);
                                      });
                                      print("Action ${result['userAction']}");
                                    }
                                    if (result != null &&
                                        result['userAction'] == "unblock") {
                                      //reload feeds
                                      data = [];
                                      setState(() {
                                        older_or_newer = "";
                                        _showBodyLoading = true;
                                        _isFeedRequestInProgress = true;
                                        _nextPage = 1;
                                      });
                                      final prefGroupName =
                                          await AppSharedPreferences.getValue(
                                              key: 'groupName');
                                      final prefTownhallID =
                                          await AppSharedPreferences.getValue(
                                              key: "groupID");
                                      _fetchTownhallFeeds(
                                          prefTownhallID.toString(),
                                          prefGroupName.toString(),
                                          '',
                                          false);
                                    }
                                  });
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
                  if (feeds.poll == "yes")
                    LayoutBuilder(builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FlutterPolls(
                          key: ValueKey(feeds.post_id),
                          votedProgressColor: Color(0xff84D2F6),
                          leadingVotedProgessColor: Color(0xff84D2F6),
                          pollEnded: currentTime.isAfter(pollEndTime),
                          //pollEnded: true,
                          heightBetweenTitleAndOptions: 0,
                          hasVoted: feeds.user_voted ?? false,
                          userVotedOptionId: feeds.user_voted
                              ? feeds.user_option.toString()
                              : null,
                          votedPercentageTextStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          pollId: feeds.post_id.toString(),
                          votesText: 'vote${feeds.total_votes == 0 ? '' : 's'}',
                          onVoted:
                              (PollOption pollOption, int newTotalVotes) async {
                            bool hasPollEnded =
                                currentTime.isAfter(pollEndTime);
                            print("poll $hasPollEnded");
                            if (hasPollEnded) {
                              setState(() {
                                hasPollEnded = true;
                              });
                              final snackBar = SnackBar(
                                  backgroundColor: Color(0xFFcf5555),
                                  content: Text("Poll has ended"));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return false;
                            } else {
                              BlocProvider.of<PostsBloc>(context).add(
                                PollCastEvent(
                                    postID: feeds.post_id.toString(),
                                    optionID: pollOption.id.toString()),
                              );
                              final List<dynamic> pollDetails =
                                  feeds.poll_details;
                              final optionIndex = pollDetails.indexWhere(
                                  (pollDetails) =>
                                      pollDetails.option_id.toString() ==
                                      pollOption.id.toString());
                              final postIndex = data.indexWhere((post) =>
                                  post.post_id.toString() ==
                                  feeds.post_id.toString());
                              print("optionID ${data[0]}");
                              if (postIndex != -1) {
                                setState(() {
                                  //update poll useroption
                                  data[postIndex].user_option =
                                      int.parse(pollOption.id.toString());
                                  data[postIndex].user_voted = true;

                                  if (optionIndex != -1) {
                                    data[postIndex]
                                        .poll_details[optionIndex]
                                        .votes += 1;
                                  }
                                });
                              }
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
                  if (imageList.length > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
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
                                  print("Am print unlike");
                                  BlocProvider.of<PostsBloc>(context).add(
                                    UnLikePostEvent(post_id: feeds.post_id),
                                  );
                                  _toggleLike(likeCounts[arrIndex].id);
                                } else {
                                  print("Am print like");
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
                                              onPressed: _isReporting
                                                  ? null
                                                  : () {
                                                      print("Am here");
                                                      setState(() {
                                                        _controllerComment
                                                            .text = "";
                                                        _isReporting = true;
                                                      });

                                                      BlocProvider.of<
                                                                  PostsBloc>(
                                                              context)
                                                          .add(
                                                        ReportAbuseEvent(
                                                            comment:
                                                                _controllerComment
                                                                    .text,
                                                            post_id:
                                                                feeds.post_id,
                                                            reported: feeds
                                                                .posted_by),
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
                              if (mounted)
                                _confirmDelete(
                                    feeds.post_id, feeds.posted_by, context);
                            } else if (value == 'block') {
                              setState(() {
                                _isBlocking = true;
                              });
                              BlocProvider.of<PostsBloc>(context).add(
                                BlockUserEvent(
                                    subjectID: feeds.posted_by,
                                    req_type: 'block'),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            if (_userID != feeds.posted_by.toString())
                              const PopupMenuItem<String>(
                                value: 'report',
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Report'),
                                ),
                              ),
                            if (_userID == feeds.posted_by.toString())
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

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  String _getTimeAgo(DateTime dt) {
    String timeAgo = timeago.format(dt, locale: 'en_short');
    return timeAgo; // Return the formatted time ago string
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

  Widget buildImageArea() {
    return GestureDetector(
      onTap: () {
        _showImageDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Placeholder color
          borderRadius: BorderRadius.circular(12.0), // Add border radius
        ),
        height: 180, // Adjust height as needed
        child: const Center(
          child: Icon(
            Icons.image,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Post Images'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Replace this with your logic to display images in the dialog
                Image.network(
                    'https://via.placeholder.com/150'), // Example image
                Image.network(
                    'https://via.placeholder.com/150'), // Example image
                Image.network(
                    'https://via.placeholder.com/150'), // Example image
                // Add more images as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Widget _buildStartConversation(bool canPost) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 8.5),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: canPost == false
                ? null
                : (() async {
                    // await Navigator.pushNamed(context, CreatePost.routeName,
                    //     arguments: {
                    //       'canPost': canPost,
                    //       'canPostPoll': canPostPoll
                    //     })
                    // await Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return MultiBlocProvider(
                    //     providers: [
                    //       BlocProvider(
                    //         create: (context) => PostsBloc(),
                    //       ),
                    //     ],
                    //     child: CreatePost(
                    //       mapData: {
                    //         'canPost': canPost,
                    //         'canPostPoll': canPostPoll
                    //       },
                    //     ),
                    //   );
                    // })).then((result) {
                    //   if (result == 'refresh') {
                    //     //appended the new posted to the data list
                    //     BlocProvider.of<PostsBloc>(context).add(
                    //       FeedEvent(
                    //         orgID: orgId,
                    //         groupID: groupId,
                    //         page: '',
                    //         limit: limit.toString(),
                    //         olderOrNewer: '',
                    //         pageOwner: '',
                    //       ),
                    //       // FeedEvent(
                    //       //   feedRequest: FeedRequest(
                    //       //       skipOnboarding: true,
                    //       //       skipTopFeed: true,
                    //       //       isFirstFeedRequest: false,
                    //       //       last_post_id: '',
                    //       //       group_id: groupId,
                    //       //       org_id: orgId,
                    //       //       page: '',
                    //       //       limit: limit,
                    //       //       older_or_newer: '',
                    //       //       page_owner: '',
                    //       //       device_token: getDeviceToken(),
                    //       //       device_type: _deviceType
                    //       // ),
                    //       // ),
                    //     );
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
                  Text(canPost ? "Start the conversation" : "No post"),
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
    final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
    final prefOrgName = await AppSharedPreferences.getValue(key: 'orgName');
    final prefGroupID = await AppSharedPreferences.getValue(key: "groupID");
    orgName = prefOrgName ?? '';
    print("Sele ${prefOrgID} ${prefGroupID}");
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
      Future.delayed(Duration(seconds: 1), () {
        _scrollToPosition(20.0);
      });
    } else {
      print("Sele else");
    }
  }

  _getCachedFeedData([String? townhallID]) async {
    final prefOrgID = await AppSharedPreferences.getValue(key: 'orgID');
    final prefGroupID =
        townhallID ?? await AppSharedPreferences.getValue(key: 'groupID');
    print('rGroup page_feed_${prefOrgID}_${prefOrgID}');
    var pageData = await getPageData('page_feed_${prefOrgID}_${prefGroupID}');
    print(pageData);
    if (pageData != null && pageData != "") {
      print(
          "Cached data was called Org ID: ${prefOrgID} TowhnID: ${townhallID}");
      var json = jsonDecode(pageData);
      setState(() {
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

  _onTapOfTownhallCircle(top) async {
    //check if this is a first or second tap
    _scrollController.jumpTo(0);
    final prefOrgID = await _getOrgID();
    setState(() {
      _nextPage = 1;
      canPost =
          top.can_post == "yes" || top.can_post_polls == "yes" ? true : false;
    });
    if (_selectedTownhallID.toString() == top.townhall_id.toString() &&
        prefOrgID == top.org_id.toString() &&
        top.can_show_townhall_info == "yes") {
      //_showTownhallInfoSheet(prefOrgID, top.townhall_id.toString());
      setState(() {
        _showTownhallInfoLoader = true;
        _selectedTownhallID = top.townhall_id.toString();
        canPostPoll = top.can_post_polls == "yes" ? true : false;
      });
      // _fetchTownhallInfo(prefOrgID, top.townhall_id.toString());
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
        _selectedTownhallID = top.townhall_id.toString();
      });
      _fetchTownhallFeeds(top.townhall_id, top.townhall_display_name,
          top.townhall_full_name, true);
      //get cache data
      print("rGroup tapped townhall ID:  ${top.townhall_id}");
      _getCachedFeedData(top.townhall_id.toString());
    }
  }

  _fetchTownhallFeeds(String townhall_id, String townhall_display_name,
      String townhall_full_name, bool townhall_tap) async {
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
    print("rGroup next page ${_nextPage} ${orgId}");
    BlocProvider.of<PostsBloc>(context).add(FeedEvent(
      orgID: orgId,
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

  _setGroupID() async {
    var prefG = await AppSharedPreferences.getValue(key: 'groupID');
    setState(() {
      _selectedTownhallID = prefG ?? "";
    });
    print('Sele Townhall ${_selectedTownhallID}');
  }

  _setUserID() async {
    var prefUserID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = prefUserID ?? "";
    });
  }

  void _showVersionNotification(
      NewVersionPlus newVersion, BuildContext cont, int min_build_no) async {
    final status = await newVersion.getVersionStatus();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var dismissedVersion =
        await _getDismissedVersion(); //this is will only show notification when user hasn't updated

    print("dismissedVersion: ${dismissedVersion}");
    print("LocalVersion: ${packageInfo.version}");
    print("StoreVersion: ${status!.storeVersion}");
    print("Expected Build No: ${min_build_no}");

    debugPrint("release note: " + status!.releaseNotes!);
    debugPrint("Store link: " + status.appStoreLink);
    debugPrint("Local version: " + status.localVersion);
    debugPrint("Store version: " + status.storeVersion);
    debugPrint("System Version: " + packageInfo.version);
    print("Dismissed: ${dismissedVersion}");
    AppSharedPreferences.setInt(
        key: 'installedAppBuildNo', value: int.parse(packageInfo.buildNumber));
    if (status.localVersion != status.storeVersion &&
        dismissedVersion != status.storeVersion) {
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: cont,
        versionStatus: status,
        dialogText: 'A new version of TownHall app is available for download.',
        dialogTitle: 'UPDATE!',
        updateButtonText: 'Update Now',
        allowDismissal:
            min_build_no > int.parse(packageInfo.buildNumber) ? false : true,
        dismissButtonText: 'Later',
        dismissAction: () => {
          Navigator.of(cont).pop(),
          AppSharedPreferences.setValue(
              key: 'dismissedVersion', value: status.storeVersion),
        },
      );
    } else {}
  }

  Future<String?> _getDismissedVersion() async {
    return await AppSharedPreferences.getValue(key: 'dismissedVersion');
  }

  List<Widget> buildSliverAppBar(List topData, BuildContext cont) {
    return [
      SliverAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        expandedHeight: _showTownhallsOnTop ? 192 : 1, // Adjusted height
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            padding: EdgeInsets.only(
              top: 80.0,
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: _showTownhallsOnTop ? 140 : 1,
              width: double.infinity,
              child: _showLoadingTop
                  ? _buildTopShimmerLoader()
                  : _showTownhallsOnTop == false
                      ? SizedBox()
                      : ListView.builder(
                          controller: _topController,
                          scrollDirection: Axis.horizontal,
                          itemCount: topData.length,
                          itemBuilder: (context, index) {
                            final top = topData[index];
                            return GestureDetector(
                              onTap: _isFeedRequestInProgress
                                  ? null
                                  : () async {
                                      _onTapOfTownhallCircle(top);
                                      setState(() {
                                        top.unread = 0;
                                      });
                                    },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 70,
                                      width: 90,
                                      child: Stack(
                                        children: [
                                          // CircleAvatar(
                                          //   radius: 30.0 -
                                          //       (30.0 *
                                          //           top.circle_reduction_percentage /
                                          //           100),
                                          //   backgroundColor:
                                          //       _selectedTownhallID.toString() ==
                                          //               top.townhall_id.toString()
                                          //           ? Colors.lightBlue
                                          //           : Colors.grey,
                                          //   child: ClipRRect(
                                          //     borderRadius:
                                          //         BorderRadius.circular(50.0),
                                          //     child: Image.network(
                                          //       top.rep_picture_mid
                                          //               .toString()
                                          //               .isEmpty
                                          //           ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
                                          //           : top.rep_picture_mid
                                          //               .toString(),
                                          //       width: 55.0 -
                                          //           (55 *
                                          //               top.circle_reduction_percentage /
                                          //               100),
                                          //       height: 55.0 -
                                          //           (55 *
                                          //               top.circle_reduction_percentage /
                                          //               100),
                                          //       fit: BoxFit.cover,
                                          //     ),
                                          //   ),
                                          // ),
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _selectedTownhallID
                                                            .toString() ==
                                                        top.townhall_id
                                                            .toString()
                                                    ? Colors.lightBlue
                                                    : Colors.grey,
                                                width:
                                                    3.0, // Adjust the border width as needed
                                              ),
                                              boxShadow: [
                                                if (_selectedTownhallID
                                                        .toString() ==
                                                    top.townhall_id.toString())
                                                  BoxShadow(
                                                    color: Colors.lightBlue
                                                        .withOpacity(0.6),
                                                    blurRadius: 10.0,
                                                    spreadRadius: 5.0,
                                                  ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 30.0 -
                                                  (30.0 *
                                                      top.circle_reduction_percentage /
                                                      100) -
                                                  3.0, // Adjust the radius to account for the border width
                                              backgroundColor: Colors.grey,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                child: Image.network(
                                                  top.rep_picture_mid
                                                          .toString()
                                                          .isEmpty
                                                      ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
                                                      : top.rep_picture_mid
                                                          .toString(),
                                                  width: 55.0 -
                                                      (55 *
                                                          top.circle_reduction_percentage /
                                                          100),
                                                  height: 55.0 -
                                                      (55 *
                                                          top.circle_reduction_percentage /
                                                          100),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // _selectedTownhallID.toString() ==
                                          //         top.townhall_id.toString()
                                          //     ? Positioned(
                                          //         bottom: 40.0 -
                                          //             (40 *
                                          //                 top.circle_reduction_percentage /
                                          //                 100),
                                          //         right: 1,
                                          //         child: Container(
                                          //           width: 20.0 -
                                          //               (20 *
                                          //                   top.circle_reduction_percentage /
                                          //                   100),
                                          //           height: 20.0 -
                                          //               (20 *
                                          //                   top.circle_reduction_percentage /
                                          //                   100),
                                          //           child: ImageIcon(
                                          //             AssetImage('images/info.png'),
                                          //             size: 25.0 -
                                          //                 (25 *
                                          //                     top.circle_reduction_percentage /
                                          //                     100),
                                          //             color: Colors.white,
                                          //           ),
                                          //           decoration: BoxDecoration(
                                          //               color: Colors.lightBlue,
                                          //               shape: BoxShape.circle),
                                          //         )

                                          //         // SizedBox(
                                          //         //   width: 25,
                                          //         //   child: IconButton(
                                          //         //     iconSize: 35,
                                          //         //     color: Colors.red,
                                          //         //     icon: Icon(Typicons.info),
                                          //         //     onPressed: () {
                                          //         //       debugPrint(
                                          //         //           "debug print");
                                          //         //     }, // icon user
                                          //         //   ),
                                          //         // ),
                                          //         )
                                          //     : SizedBox(),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0,
                                          right: 4.0,
                                          left: 4.0,
                                          bottom: 0.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${top.townhall_name}', // Replace with your desired text
                                            textAlign: TextAlign.center,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '(${NumberFormat.compact().format(top.member_count)})', // Replace with your desired text
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                              SizedBox(
                                                width: top.unread == 0 ? 0 : 5,
                                              ),
                                              top.unread == 0
                                                  ? SizedBox()
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      radius: 5,
                                                      child: SizedBox(),
                                                    )
                                            ],
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
            ),
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     colors: [Colors.blue, Colors.green],
            //   ),
            // ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Column
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 0), // Margin on the left edge
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero, // Remove default padding
                      alignment: Alignment.centerLeft, // Align icon to the left
                      onPressed: () {
                        //Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider(
                            create: (context) => o.OrganizationBloc(),
                            child: OrganizationScreen(),
                          );
                        }));
                      },
                      iconSize: 25,
                      icon: FaIcon(
                        FontAwesomeIcons.chevronLeft,
                        size: 25,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle Column
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: SizedBox(
                        width: 25,
                        height: 25,
                        child: Image.asset('images/icon_blue.png'),
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Right Column
            // Expanded(
            //   child: Container(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         SizedBox(
            //           height: 30.0,
            //           child: TextButton.icon(
            //             onPressed: () async {
            //               Navigator.push(context,
            //                   MaterialPageRoute(builder: (context) {
            //                 return BlocProvider(
            //                   create: (context) => o.OrganizationBloc(),
            //                   child: OrganizationScreen(),
            //                 );
            //               }));
            //             },
            //             style: ButtonStyle(
            //               backgroundColor:
            //                   MaterialStateProperty.all<Color>(Colors.white),
            //               shape: MaterialStateProperty.all<OutlinedBorder>(
            //                 RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(20.0),
            //                   side: const BorderSide(
            //                     color: Colors.blue,
            //                     width: 2.0,
            //                   ),
            //                 ),
            //               ),
            //               padding:
            //                   MaterialStateProperty.all<EdgeInsetsGeometry>(
            //                 const EdgeInsets.fromLTRB(13.0, 3.0, 5.0, 5.0),
            //               ),
            //             ),
            //             icon: Text(
            //               "${orgName == null ? '' : _substring(orgName.toString(), 10)}",
            //               style: TextStyle(color: Colors.blue),
            //             ),
            //             label: Padding(
            //               padding: const EdgeInsets.symmetric(vertical: 0),
            //               child: SizedBox(),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
                child: SizedBox(
              height: 30.0,
              child: CustomDropdownButton(
                dropdownKey: dropdownKey,
                bloc: context.read<o.OrganizationBloc>(),
                orgName: orgName.toString(),
                notificationCount: 0,
                options: [
                  //"Feeds",
                  "Members",
                  // "Info",
                  // "Donate",
                  //"Voting"
                ],
              ),
            ))
          ],
        ),
        automaticallyImplyLeading: false,
        floating: true,
        snap: true,
      ),
    ];
  }

  Future<void> _updateUserStatus(bool status) async {
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    setState(() {
      _userID = userID.toString();
    });
    print('User ID: ${_userID}');
    await FirebaseFirestore.instance.collection('users').doc(_userID).update({
      'isOnline': status,
      'lastSeen': FieldValue.serverTimestamp(),
    });
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
                  _clickedID = int.parse(postID);
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

class TownhallInfoContent extends StatelessWidget {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  AudioPlayerController _audioPlayerController = AudioPlayerController();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  List<InfoData> townhallInfo = [];
  List<AudioItem> _audioItems = <AudioItem>[];
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 15, 0),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  alignment: Alignment.topRight,
                  height: 20.0,
                  child: IconButton(
                    alignment: Alignment.topRight,
                    icon: Icon(Icons.close, color: Colors.grey),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width - 50,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Townhall Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      BlocConsumer<PostsBloc, PostsState>(
                        listener: (context, state) {
                          // Perform side effects here based on the state
                        },
                        builder: (context, state) {
                          if (state is TownhallInfoLoadingState) {
                            return Column(
                              children: [
                                SizedBox(height: 20),
                                _buildBodyShimmerLoader(),
                              ],
                            );
                          } else if (state is TownhallInfoState) {
                            townhallInfo = state.townhallResponse.data;
                            return Column(
                              children:
                                  List.generate(townhallInfo.length, (index) {
                                final info = townhallInfo[index];
                                final section = info.section;
                                final body = info.body;
                                final section_tag = info.section_tag ?? '';
                                final orientation = info.orientation ?? '';
                                final actionType = info.action_type ?? '';

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (section.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 18.0),
                                        child: Text(
                                          section,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (orientation == "landscape")
                                      _buildLandscape(orientation, body),
                                    if (orientation == "portrait")
                                      _buildPortrait(orientation, body),
                                    if (orientation == "landscape_rectangle")
                                      _buildLandscapeRectangle(
                                          section_tag, body),
                                    SizedBox(height: 25),
                                  ],
                                );
                              }),
                            );
                          } else {
                            return Text('Something went wrong!');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Future<String?> _getDismissedVersion() async {
    return await AppSharedPreferences.getValue(key: 'dismissedVersion');
  }
}

class TownhallNotificationBadge extends StatelessWidget {
  final int count;
  TownhallNotificationBadge({required this.count});

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

class CustomDropdownButton extends StatefulWidget {
  final String orgName;
  final List<String> options;
  final int notificationCount;
  final o.OrganizationBloc bloc;
  final GlobalKey<CustomDropdownButtonState> dropdownKey;

  const CustomDropdownButton({
    //Key? key,
    required this.dropdownKey,
    required this.bloc,
    required this.orgName,
    required this.options,
    required this.notificationCount,
  }) : super(key: dropdownKey);

  @override
  CustomDropdownButtonState createState() => CustomDropdownButtonState();
}

class CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? selectedOption;
  bool isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void closeDropdown() {
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: 200, // Increased width for better layout
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Smooth rounded corners
          border: Border.all(color: Colors.blue, width: 1.5),
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.blue.withOpacity(0.15),
          //     spreadRadius: 1,
          //     blurRadius: 5,
          //     offset: Offset(0, 3),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _toggleDropdown, // Makes both text and circle clickable
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 11.0), // Slight padding for text
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.orgName,
                          style: TextStyle(
                            color: Colors.blue,
                            //fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (widget.notificationCount > 0)
                        Container(
                          margin: EdgeInsets.only(
                              left: 8), // Space between text and circle
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              // Shadow for emphasis
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '${widget.notificationCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                padding: EdgeInsets.only(bottom: 5),
                icon: Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.blue,
                  size: 28, // Reduced arrow size for a cleaner look
                ),
                onPressed: _toggleDropdown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                children: widget.options.map((String option) {
                  return InkWell(
                    onTap: () async {
                      final prefOrgID =
                          await AppSharedPreferences.getValue(key: 'orgID');
                      setState(() {
                        selectedOption = option;
                        _toggleDropdown();
                        if (option == "Members") {
                          print("hello members");
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (context) => widget.bloc),
                              ],
                              child: ListOfOrgMembers(
                                orgID: prefOrgID.toString(),
                              ),
                            );
                          }));
                        }
                      });
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: selectedOption == option
                              ? Colors.blue.shade700
                              : Colors.black87,
                          fontWeight: selectedOption == option
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      if (isExpanded) {
        _removeOverlay();
      } else {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      }
      isExpanded = !isExpanded;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
