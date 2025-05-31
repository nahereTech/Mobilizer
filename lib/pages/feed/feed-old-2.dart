// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:getwidget/colors/gf_color.dart';
// import 'package:getwidget/components/toast/gf_toast.dart';
// import 'package:getwidget/position/gf_toast_position.dart';
// import 'package:intl/intl.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart';
// import 'package:nahere/common/common/constants.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/models/feed/feed_request.dart';
// import 'package:nahere/models/feed/topfeed_response.dart';
// import 'package:nahere/models/townhall/townhall_info_response.dart';
// import 'package:nahere/pages/comments/comments.dart';
// import 'package:nahere/pages/login/login.dart';
// import 'package:nahere/pages/organization/organization.dart';
// import 'package:nahere/pages/people/people_profile.dart';
// import 'package:nahere/pages/post/createpost.dart';
// import 'package:nahere/pages/profile/profile.dart';
// import 'package:nahere/pages/register_otp/registerotp.dart';
// import 'package:nahere/bloc/auth/auth_bloc.dart' as a;
// import 'package:nahere/bloc/search/organization_bloc.dart' as o;
// import 'package:nahere/bloc/search/polling_bloc.dart' as p;
// import 'package:nahere/bloc/suggestion/suggestion_bloc.dart' as s;
// import 'package:nahere/bloc/search/people_bloc.dart' as p;
// import 'package:nahere/models/feed/feed_response.dart';
// import 'package:nahere/models/profile/get_profile_response.dart';
// import 'package:nahere/models/social/like_list_response.dart';
// import 'package:nahere/models/townhall/townhall_info_response.dart';
// import 'package:nahere/pages/settings/settings.dart';
// import 'package:nahere/pages/suggestion/org_suggestion.dart';
// import 'package:nahere/pages/suggestion/suggestion.dart';
// import 'package:nahere/widget/bottom_navigational_bar.dart';
// import 'package:nahere/widget/image_swipe.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import 'package:simple_moment/simple_moment.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class Feed extends StatefulWidget {
//   static String routeName = 'feed_screen';
//   const Feed({Key? key}) : super(key: key);

//   @override
//   _FeedState createState() => _FeedState();
// }

// class _FeedState extends State<Feed> {
//   bool _isLoading = true;
//   bool _isLoadingTop = true;
//   bool _showCircleRow = true; // Initially show circle row
//   late ScrollController _scrollController;
//   bool _showBottomMenu = true; // Initially show bottom menu
//   double _previousOffset = 0; // Track the previous scroll offset

//   List<dynamic> data = [];
//   List<dynamic> newDataList = []; //new data from list.
//   List<dynamic> newList = []; //list of groups with new feed notification.
//   List<TopFeedData> topFeed = [];
//   List<InfoData> townhallInfo = [];
//   List<dynamic> _isLikeList = [];
//   //AudioPlayer _audioPlayer = AudioPlayer();

//   List<AudioItem> _audioItems = <AudioItem>[];

//   List<Like> likeCounts = [];
//   List<Comment> commentCounts = [];
//   //SuperTooltip? tooltip;
//   String newDataFirstPostID = '';
//   String cachedDataFirstPostID = '';
//   String groupId = '';
//   String orgId = '';
//   String? orgName;
//   String last_post_id = '';
//   String first_post_id = '';
//   bool isLiked = false;
//   String clickedPostID = '';
//   bool isTownhallView = false;
//   int _clickedID = -1;
//   bool reloadTop = false;
//   bool loading = true;
//   bool _showRep = true;
//   bool newFeedLoader = false; //new feed loader when Townhall is clicked
//   bool olderLoader = false;
//   bool newLoader = false;
//   String older_or_newer = '';
//   String likeSubjectID = "";
//   bool showLikeLoader = false;
//   bool isThereResult = false;
//   bool isNoParty = false; //if not party yet.
//   bool firstTimeLoading = true;
//   bool isLoadingUpRequest = false; //This tell if loading up is feeding data now
//   bool isLastDownRequest =
//       false; //No more data to fetch from database for scroll down
//   bool isNoNetwork = false;
//   bool showFloatingButton = false;
//   bool showResultButton = false;
//   bool showTownhallLoader = false;
//   bool showSlideUpPanel = false;
//   bool isPageFirstLoad = false;
//   bool _isScrollingUp = false;
//   bool isFirstFeedRequest =
//       true; //check if it's first time requesting for feeds
//   bool isCachedDataAvailable = false;
//   bool isPlaying = false;
//   bool canDismiss = true;
//   bool canPost = false;
//   bool canPostPoll = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   List<dynamic> _isFollowList = [];
//   List<dynamic> _groupList = [];
//   String networkMsg = "";
//   String profileImage = "";
//   String _slideUpTitle = "";
//   String _showSlideUpFor = "";
//   String _deviceType = "";
//   PanelController _pc = new PanelController();
//   final _formKey = GlobalKey<FormState>();
//   final _controllerComment = TextEditingController();
//   //This is build number coming from the backend.
//   int _clickedFollowID = 0;
//   int _selectedIndexID = -1;
//   int _topFeedIndexID = 0;
//   bool _isPageVisited = false;
//   bool _canUpdate = false;
//   String _currentVersion = "";
//   String _storeVersion = "";
//   String _storeUrl = "";
//   String _dismissedVersion = "";
//   AudioPlayer _audioPlayer = AudioPlayer();
//   AudioPlayerController _audioPlayerController = AudioPlayerController();
//   static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   final newVersion =
//       NewVersionPlus(iOSId: IOSPackageID, androidId: androidPackageID);
//   int limit = 30;
//   Timer? timer;

//   var moment = new Moment.now();
//   var sampleVideo =
//       "https://ia601205.us.archive.org/18/items/SampleVideo1280x7201mb/SampleVideo_1280x720_1mb.mp4";
//   // NativeAd? _ad;
//   bool _isLoaded = false;
//   @override
//   void initState() {
//     //_audioPlayer = AudioPlayer();
//     _initDismissedVersion();
//     _initVersion();
//     _setProfilePic();
//     var deviceToken = getDeviceToken();
//     // setUpTimedFetch();
//     _setOrgName();
//     //_setGroupID();
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<PostsBloc>(context).add(
//         FeedEvent(
//           feedRequest: FeedRequest(
//               isFirstFeedRequest: true,
//               skipOnboarding: false,
//               skipTopFeed: false,
//               last_post_id: last_post_id,
//               group_id: groupId,
//               org_id: orgId,
//               page: '',
//               limit: limit,
//               older_or_newer: older_or_newer,
//               page_owner: '',
//               device_token: deviceToken,
//               device_type: _deviceType),
//         ),
//       );
//     });
//     // _getGroupID();
//     _getOrgID();
//     _getDismissedVersion();

//     _checkViewStatus();
//     _getCachedFeedData(_topFeedIndexID);
//     _getCachedTopData(_topFeedIndexID);

//     if (_topFeedIndexID == 0 && data.length > 0) {
//       setState(() {
//         loading = true;
//         olderLoader = true;
//       });
//     }
//     setState(() {
//       isPageFirstLoad = true;
//       _groupList = [];
//     });
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       _isScrollingUp = true;
//       if (isLastDownRequest == false) {
//         _getOlderPosts(limit, getDeviceToken());
//       }
//       print("Testing scoll bottom");
//     }
//     if (_scrollController.position.pixels ==
//         _scrollController.position.minScrollExtent) {
//       _getNewerPosts(limit, getDeviceToken());
//       print("Testing scroll top");
//       _isScrollingUp = false;
//     }
//     final currentOffset = _scrollController.offset;
//     final direction = currentOffset - _previousOffset;

//     setState(() {
//       if (direction < 0) {
//         // Scrolling up
//         _showBottomMenu = true;
//         _showCircleRow = true;
//       } else if (direction > 0) {
//         // Scrolling down
//         _showBottomMenu = false;
//         _showCircleRow = false;
//       }
//       _previousOffset = currentOffset;
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     //inheritedWidget = MyInheritedWidget.of(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
//     //   statusBarColor: Colors.black, // Set the status bar color to white
//     // ));

//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         systemNavigationBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
//         statusBarColor: Theme.of(context).primaryColor,
//       ),
//     );

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle(
//           statusBarColor: Colors.white, // Set status bar color to white
//         ),
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: PreferredSize(
//             //preferredSize: Size.fromHeight(kToolbarHeight),
//             preferredSize: Size.fromHeight(kToolbarHeight),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               height: _showBottomMenu ? kToolbarHeight + 20 : 0,
//               child: AppBar(
//                 centerTitle: true,
//                 leading: Builder(
//                   builder: (BuildContext context) {
//                     return IconButton(
//                       icon: SizedBox(
//                         width: 25,
//                         height: 25,
//                         child: Image.asset('images/icon_blue.png'),
//                       ),
//                       onPressed: () {
//                         Scaffold.of(context).openDrawer();
//                       },
//                     );
//                   },
//                 ),
//                 actions: [
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 30.0,
//                         child: TextButton.icon(
//                           onPressed: () async {
//                             // Add your onPressed function here
//                             Navigator.push(context,
//                                 MaterialPageRoute(builder: (context) {
//                               return BlocProvider(
//                                 create: (context) => o.OrganizationBloc(),
//                                 child: OrganizationScreen(),
//                               );
//                             }));
//                           },
//                           style: ButtonStyle(
//                             backgroundColor:
//                                 MaterialStateProperty.all<Color>(Colors.white),
//                             shape: MaterialStateProperty.all<OutlinedBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 side: const BorderSide(
//                                   color: Colors.blue,
//                                   width: 2.0,
//                                 ),
//                               ),
//                             ),
//                             padding:
//                                 MaterialStateProperty.all<EdgeInsetsGeometry>(
//                               const EdgeInsets.fromLTRB(12.0, 5.0, 5.0, 5.0),
//                             ),
//                           ),
//                           icon: Text(
//                             "${orgName == null ? '' : _substring(orgName.toString(), 10)}",
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                           label: const Icon(
//                             Icons.arrow_drop_down,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return BlocProvider(
//                               create: (context) => a.AuthBloc(),
//                               child: Settings(),
//                             );
//                           }));
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 15.0),
//                           child: CircleAvatar(
//                             radius: 16,
//                             backgroundImage: NetworkImage(
//                               profileImage == ""
//                                   ? 'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid'
//                                   : profileImage,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // drawer: const MenuWidget(),
//           body: SafeArea(
//               child: BlocConsumer<PostsBloc, PostsState>(
//                   listener: (context, state) {
//             if (state is NoResultState) {
//               print(
//                   "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");
//               isThereResult = false;

//               setState(() {
//                 _isLoading = false;
//                 _isLoadingTop = false;
//                 newFeedLoader = false;
//                 isLoadingUpRequest = false;
//                 isLastDownRequest = false;
//                 isNoNetwork = false;
//                 olderLoader = false;
//                 showLikeLoader = false;
//                 loading = false;
//                 reloadTop = false;
//               });
//             }
//             // if (state is LoadingState && olderLoader == false) {
//             //   if (showLikeLoader == false) {
//             //     loading = true;
//             //   }
//             //   loading = false;
//             //   olderLoader = false;
//             //   newLoader = false;
//             //   reloadTop = false;
//             //   print("P1");
//             // }

//             // if (state is LoadingState) {
//             //   loading = true;
//             // }
//             if (state is LoadingState) {
//               if (olderLoader) {
//                 olderLoader = true;
//               } else if (newLoader) {
//                 newLoader = true;
//               } else if (reloadTop) {
//                 reloadTop = true;
//               } else {
//                 _isLoading = true;
//               }
//               isNoNetwork = false;
//               isThereResult = false;
//             }

//             if (state is GoToSuggestionState) {
//               print("Suggestion screen");
//               loading = false;
//               reloadTop = false;
//               isNoNetwork = false;
//               Navigator.pushNamed(context, SuggestionScreen.routeName);
//             }
//             //Go to profile page
//             if (state is GoToProfileState) {
//               isNoNetwork = false;
//               Navigator.pushNamed(context, Profile.routeName);
//             }
//             if (state
//                 is GoToOrganizationState) //Go to Organization suggestion page
//             {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return BlocProvider(
//                   create: (context) => o.OrganizationBloc(),
//                   child: OrgSuggestionScreen(),
//                 );
//               }));
//             }
//             if (state is GoToConfirmState) //Go to Organization suggestion page
//             {
//               AppSharedPreferences.removeValue(key: 'token');
//               AppSharedPreferences.removeValue(key: 'townhallView');
//               AppSharedPreferences.removeValue(key: 'groupID');
//               AppSharedPreferences.removeValue(key: 'orgID');
//               AppSharedPreferences.removeValue(key: 'orgName');
//               AppSharedPreferences.removeValue(key: 'isOrgLeader');
//               AppSharedPreferences.removeValue(key: 'isTownhallLeader');
//               AppSharedPreferences.removeValue(key: 'login');
//               AppSharedPreferences.removeValue(key: 'dismissedVersion');
//               Navigator.pushReplacementNamed(
//                   context, RegisterOtpScreen.routeName,
//                   arguments: state.email);
//             }
//             if (state is AbuseReportState) {
//               Navigator.of(context, rootNavigator: true).pop();
//               final snackBar = SnackBar(
//                 content: Text('Post was successfully reported'),
//                 backgroundColor: Colors.green.shade300,
//               );
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               _controllerComment.text = '';
//             }
//             if (state is TownhallInfoState) {
//               setState(() {
//                 showTownhallLoader = false;
//                 townhallInfo = state.townhallResponse.data;
//               });
//             }
//             // if (state is LikeListState) {
//             //   setState(() {
//             //     showTownhallLoader = false;
//             //     loading = false;
//             //     likeData = state.likeResponse.data!;
//             //   });
//             // }
//             if (state is UnauthorizedState) {
//               AppSharedPreferences.clearCache();
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return BlocProvider(
//                   create: (context) => a.AuthBloc(),
//                   child: LoginScreen(),
//                 );
//               }));
//             }
//             if (state is JoinedOrganizationState) {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return BlocProvider(
//                   create: (context) => a.AuthBloc(),
//                   child: OrganizationScreen(),
//                 );
//               }));
//             }
//             if (state is FeedState) {
//               // print("YY- Api Data: ${state.inputedData.group_id}");
//               // if (state.inputedData.group_id.toString() == groupId.toString() ||
//               //     groupId == null ||
//               //     groupId == "") {
//               //   print(
//               //       "YY- Successful GRP: ${state.inputedData.group_id.toString()}");
//                 //Navigator.pushNamed(context, SuggestionScreen.routeName);
//                 // print("P2");
//                 isLoadingUpRequest = false;
//                 _isLoading = false;
//                 _isLoadingTop = false;
//                 isLastDownRequest = false;
//                 isNoNetwork = false;
//                 networkMsg = "";

//                 if (isPageFirstLoad) {
//                   print("Dismis: ${_dismissedVersion}");
//                   if (_canUpdate &&
//                       _dismissedVersion != null &&
//                       _storeVersion != _dismissedVersion) {
//                     _showVersionNotification(_storeUrl, state.build_number);
//                   }
//                 }

//                 // canDismiss = (buildNo != null &&
//                 //         buildNo > int.parse(state.build_number))
//                 //     ? true
//                 //     : false;

//                 if (isPageFirstLoad) {
//                   AppSharedPreferences.setValue(
//                       key: 'isTownhallLeader',
//                       value: state.topFeedResponse.data![0].is_townhall_leader);
//                   setState(() {
//                     showFloatingButton =
//                         state.topFeedResponse.data![0].can_post == "yes"
//                             ? true
//                             : false;
//                     showResultButton =
//                         state.topFeedResponse.data![0].show_result_button ==
//                                 "yes"
//                             ? true
//                             : false;

//                     _topFeedIndexID =
//                         int.parse(state.topFeedResponse.data![0].townhall_id);
//                   });
//                   print(
//                       "Townhall ID onload for the first time: ${_topFeedIndexID}");
//                   print("SHOW FLOATING BUTTON: ${showFloatingButton}");
//                 }
//                 if (older_or_newer == "older") {
//                   setState(() {
//                     _isLikeList = [];
//                   });
//                 }
//                 if (orgName == "" || orgName == null) {
//                   setState(() {
//                     orgName = state.orgName;
//                     AppSharedPreferences.setValue(
//                         key: 'orgName', value: state.orgName);
//                   });
//                 }
//                 //if (newLoader) {
//                 setState(() {
//                   showLikeLoader = false;
//                   newFeedLoader = false;
//                   likeSubjectID = "";
//                   //first_post_id = state.feedResponse[0].post_id;
//                   first_post_id = state.feedResponse.length < 1
//                       ? ''
//                       : state.feedResponse[0].post_id;
//                   loading = false;
//                   olderLoader = false;
//                   newLoader = false;
//                   reloadTop = false;
//                 });
//                 //}

//                 if (state.feedResponse.length > 0) {
//                   // if (isFirstFeedRequest && isCachedDataAvailable) {
//                   //   newDataList = state.feedResponse;

//                   //   newDataFirstPostID = _getFirstWhere(newDataList);
//                   //   cachedDataFirstPostID = _getFirstWhere(data);
//                   //   print(
//                   //       "NewPostID: ${newDataFirstPostID} CachedPostID: ${cachedDataFirstPostID}");

//                   //   setState(() {
//                   //     isFirstFeedRequest = false;
//                   //   });
//                   // } else {
//                   setState(() {
//                     data = state.feedResponse;
//                   });
//                   print("Data Length: ${data.length}");
//                   print(
//                       "Cached was Setting cache orgID: ${state.orgID.toString()} , Townh ID: ${_topFeedIndexID.toString()}");
//                   AppSharedPreferences.setValue(
//                       key:
//                           "page_feed_${state.orgID.toString()}_${_topFeedIndexID.toString()}",
//                       value: jsonEncode(state.feedResponse));
//                   AppSharedPreferences.setValue(
//                       key:
//                           "page_feed_top_${state.orgID.toString()}_${_topFeedIndexID.toString()}",
//                       value: jsonEncode(state.topFeedResponse.data));
//                   //}

//                   isThereResult = true;
//                   isNoNetwork = false;
//                   print(
//                       "page_feed_${state.orgID.toString()}_${_topFeedIndexID.toString()}");
//                 }
//                 print(
//                     "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");

//                 topFeed = state.topFeedResponse.data!;

//                 setState(() {
//                   olderLoader = false;
//                   loading = false;
//                   newLoader = false;
//                   // isThereResult = true;
//                   reloadTop = false;
//                 });

//                 if (groupId.isEmpty) {
//                   if (topFeed.isNotEmpty) {
//                     groupId = topFeed[0].townhall_id.toString();
//                   }
//                 }
//               }
//             }
//             // if (state is CastedState) {}
//             if (state is NoPartyState) {
//               setState(() {
//                 isNoParty = true;

//                 olderLoader = false;
//                 loading = false;
//                 newLoader = false;

//                 reloadTop = false;
//               });
//               isThereResult = true;
//               isNoNetwork = false;
//             }
//             if (state is LikeState) {
//               setState(() {
//                 isLiked = true;
//                 loading = false;
//                 isNoNetwork = false;
//                 olderLoader = false;
//                 reloadTop = false;
//                 likeSubjectID = "";
//               });
//             }
//             if (state is FollowState) {
//               print("Successfully followed");
//             }
//             if (state is UnFollowState) {
//               print("successfully unfollowed");
//             }
//             if (state is DeleteFeedState) {
//               setState(() {
//                 loading = false;
//                 reloadTop = false;
//                 isNoNetwork = false;
//                 data.removeAt(_clickedID);
//               });
//               if (data.length > 0) {
//                 List reindexedData = List.from(data);
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                 final snackBar = SnackBar(
//                     backgroundColor: Color.fromARGB(255, 85, 207, 158),
//                     content: Text('Successfully deleted'));
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);

//                 AppSharedPreferences.setValue(
//                     key: "page_feed_${orgId.toString()}_${groupId.toString()}",
//                     value: jsonEncode(reindexedData));
//                 print("Print: ${orgId.toString()} ${groupId.toString()}");
//                 AppSharedPreferences.setValue(
//                     key:
//                         "page_feed_top_${orgId.toString()}_${groupId.toString()}",
//                     value: jsonEncode(topFeed));
//               } else //delete stored Townhall shared preference data
//               {
//                 AppSharedPreferences.removeValue(
//                     key: 'page_feed_${orgId.toString()}_${groupId.toString()}');
//                 print(
//                     'Delete ID: page_feed_${orgId.toString()}_${groupId.toString()}');
//               }

//               print(state.deleteFeedResponse.msg);
//               print(state.deleteFeedResponse.status);
//               var deviceToken = getDeviceToken();
//               // BlocProvider.of<PostsBloc>(context).add(
//               //   FeedEvent(
//               //     feedRequest: FeedRequest(
//               //         isFirstFeedRequest: false,
//               //         last_post_id: '',
//               //         group_id: groupId,
//               //         org_id: orgId,
//               //         post_id: '',
//               //         limit: limit,
//               //         older_or_newer: '',
//               //         page_owner: '',
//               //         device_token: deviceToken,
//               //         device_type: _deviceType),
//               //   ),
//               // );
//             }

//             if (state is ErrorState) {
//               setState(() {
//                 newFeedLoader = false;
//                 isLoadingUpRequest = false;
//                 showLikeLoader = false;
//                 likeSubjectID = "";
//                 isLastDownRequest = false;
//                 olderLoader = false;
//                 loading = false;
//                 _isLoading = false;
//                 _isLoadingTop = false;
//                 isNoNetwork = false;
//               });
//               print(state.message);

//               // final snackBar =
//               //     SnackBar(content: Text(state.message.toString()));
//               // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               if (state.errorFor == "like" || state.errorFor == "unlike") {
//                 _toggleLike(_clickedID);
//               }
//             }

//             if (state is NetworkState) {
//               setState(() {
//                 newFeedLoader = false;
//                 isLoadingUpRequest = false;
//                 showLikeLoader = false;
//                 likeSubjectID = "";
//                 isLastDownRequest = false;
//                 isNoNetwork = true;
//                 networkMsg = state.message!;

//                 olderLoader = false;
//                 loading = false;
//                 reloadTop = false;
//                 likeSubjectID = "";
//                 _isLoading = false;
//                 _isLoadingTop = false;
//               });
//               isThereResult = false;
//               // final snackBar = SnackBar(
//               //     backgroundColor: Color(0xFFcf5555),
//               //     content: Text(state.message.toString()));
//               // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//             if (state is BlockUserState) {
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 158),
//                   content: Text('User was successfully blocked'));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//           }, builder: (context, state) {
//             return _buildTaskList(context);
//           })),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () async {
//               await Navigator.pushNamed(context, CreatePost.routeName,
//                   arguments: {
//                     'canPost': canPost,
//                     'canPostPoll': canPostPoll
//                   }).then((result) {
//                 if (result == 'refresh') {
//                   // setState(() {
//                   //   olderLoader = false;
//                   //   loading = false;
//                   // });
//                   BlocProvider.of<PostsBloc>(context).add(
//                     FeedEvent(
//                       feedRequest: FeedRequest(
//                           skipOnboarding: false,
//                           skipTopFeed: false,
//                           isFirstFeedRequest: false,
//                           last_post_id: '',
//                           group_id: groupId,
//                           org_id: orgId,
//                           page: '',
//                           limit: limit,
//                           older_or_newer: '',
//                           page_owner: ''),
//                     ),
//                   );
//                 }
//               });
//             },
//             backgroundColor: const Color(0xFF00AFEF),
//             child: const Icon(
//               Icons.edit,
//               color: Colors.white,
//             ),
//           ),
//           bottomNavigationBar: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
//             child: _showBottomMenu
//                 ? BottomNavigation(
//                     page: Feed.routeName, showBottomMenu: _showBottomMenu)
//                 : null,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopShimmerLoader() {
//     return Container(
//       width: double.infinity,
//       child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Colors.grey[300],
//               ),
//               CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Colors.grey[300],
//               ),
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.grey[300],
//               ),
//               CircleAvatar(
//                 radius: 35,
//                 backgroundColor: Colors.grey[300],
//               ),
//             ],
//           )),
//     );
//   }

//   Widget _buildSingleShimmerLoader() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         itemCount: 1,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.grey[300],
//             ),
//             title: Container(
//               height: 16,
//               color: Colors.grey[300],
//             ),
//             subtitle: Container(
//               height: 12,
//               color: Colors.grey[300],
//             ),
//             trailing: Container(
//               width: 24,
//               height: 24,
//               color: Colors.grey[300],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildShimmerLoader() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.grey[300],
//             ),
//             title: Container(
//               height: 16,
//               color: Colors.grey[300],
//             ),
//             subtitle: Container(
//               height: 12,
//               color: Colors.grey[300],
//             ),
//             trailing: Container(
//               width: 24,
//               height: 24,
//               color: Colors.grey[300],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTaskList(BuildContext cont) {
//     return Stack(
//       children: [
//         if (older_or_newer == "" &&
//             loading == false &&
//             data.length == 0 &&
//             isNoNetwork == true)
//           GestureDetector(
//             onTap: () {
//               BlocProvider.of<PostsBloc>(context).add(
//                 FeedEvent(
//                   feedRequest: FeedRequest(
//                       skipOnboarding: true,
//                       skipTopFeed: true,
//                       isFirstFeedRequest: false,
//                       last_post_id: last_post_id,
//                       group_id: groupId,
//                       org_id: orgId,
//                       page: '',
//                       limit: limit,
//                       older_or_newer: older_or_newer,
//                       page_owner: '',
//                       device_token: getDeviceToken(),
//                       device_type: _deviceType),
//                 ),
//               );
//             },
//             child: Container(
//               alignment: Alignment.center,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'images/network.png',
//                       width: 150,
//                       height: 150,
//                     ),
//                     Text(networkMsg),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//         //   Center(
//         //     child: Container(
//         //       width: 40.0,
//         //       height: 40.0,
//         //       child: SpinKitCircle(
//         //         color: Colors.blue,
//         //         size: 25.0,
//         //       ),
//         //     ),
//         //   ),

//         if (older_or_newer == "" &&
//             loading == false &&
//             newFeedLoader == false &&
//             data.length == 0 &&
//             isNoNetwork == false)
//           GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: (() async {
//               await Navigator.pushNamed(context, CreatePost.routeName,
//                   arguments: {
//                     'canPost': canPost,
//                     'canPostPoll': canPostPoll
//                   }).then((result) {
//                 if (result == 'refresh') {
//                   setState(() {
//                     loading = false;
//                     olderLoader = false;
//                   });
//                   BlocProvider.of<PostsBloc>(context).add(
//                     FeedEvent(
//                       feedRequest: FeedRequest(
//                           skipOnboarding: true,
//                           skipTopFeed: true,
//                           isFirstFeedRequest: false,
//                           last_post_id: '',
//                           group_id: groupId,
//                           org_id: orgId,
//                           page: '',
//                           limit: limit,
//                           older_or_newer: '',
//                           page_owner: '',
//                           device_token: getDeviceToken(),
//                           device_type: _deviceType),
//                     ),
//                   );
//                 }
//               });
//             }),
//             child: Container(
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   //Image.asset('images/nopost.svg'),
//                   SvgPicture.asset(
//                     'images/nopost.svg',
//                     width: 130,
//                     height: 130,
//                   ),
//                   Text("Start the conversation"),
//                 ],
//               ),
//             ),
//           ),
//         if (_isLoading && olderLoader == false && newFeedLoader == false)
//           _buildShimmerLoader(),

//         if (data.length > 0 && _isLoading == false) //feeds start
//           Stack(
//             children: [
//               Column(
//                 children: [
//                   newFeedLoader
//                       ? Container(
//                           height: 70,
//                           margin: EdgeInsets.only(top: 140),
//                           width: double.infinity,
//                           color: Colors.red,
//                           child: _buildSingleShimmerLoader(),
//                         )
//                       : SizedBox(
//                           height: 140,
//                         ),
//                   Expanded(
//                     child: ListView.builder(
//                       padding: EdgeInsets.only(top: 0),
//                       controller: _scrollController,
//                       itemCount: isThereResult ? data.length + 1 : data.length,
//                       itemBuilder: (context, index) {
//                         // Get the current time
//                         DateTime currentTime = DateTime.now();
//                         int days = 0; //days left for polls to end
//                         String poll_end_desc =
//                             ''; //description to show when poll is about to or has ended
//                         if (index == data.length) {
//                           isLastDownRequest = index < 20
//                               ? true
//                               : false; //This is the last down request. No more data to load again.
//                           return Container(
//                             width: 80.0,
//                             height: 80.0,
//                             child: data.length == 1
//                                 ? SizedBox()
//                                 : Container(
//                                     child: index < 20
//                                         ? null
//                                         : SpinKitCircle(
//                                             color: Colors.blue,
//                                             size: 30.0,
//                                           ),
//                                   ),
//                           );
//                         }
//                         if (last_post_id.isEmpty || newLoader) {
//                           first_post_id = data[0].post_id;
//                         }
//                         final feeds = data[index];
//                         print("Post ID: ${feeds.post_id}");
//                         List<dynamic> imageList = [];
//                         List<dynamic> optionList = [];
//                         DateTime? pollEndTime;
//                         bool hasPollEnded = false;
//                         bool hasVoted = false;

//                         last_post_id = feeds.post_id;

//                         likeCounts.add(Like(
//                             isLiked: feeds.is_liked == "yes" ? true : false,
//                             likeCounts: feeds.like_count,
//                             id: int.parse(feeds.post_id)));
//                         commentCounts.add(Comment(
//                             counts: feeds.comment_count,
//                             id: int.parse(feeds.post_id)));
//                         int arrIndex = likeCounts.indexWhere((likeCounts) =>
//                             likeCounts.id == int.parse(feeds.post_id));
//                         int arrCIndex = commentCounts.indexWhere(
//                             (commentCounts) =>
//                                 commentCounts.id == int.parse(feeds.post_id));
//                         if (feeds.post_images != null) {
//                           // print("My first post: " +
//                           //     data[0].post_id);

//                           for (FeedImagesData image in feeds.post_images!) {
//                             //imageList.add(image.name);
//                             imageList.add({
//                               'name': image.name,
//                               'mp4_video': image.mp4_video,
//                               'type': image.type,
//                               'thumbnail': image.thumbnail,
//                             });
//                             debugPrint("IMG: ${imageList}");
//                           }
//                         }
//                         if (feeds.poll == "yes") {
//                           hasVoted = feeds.user_voted;
//                           pollEndTime = DateTime.parse(feeds.poll_end);
//                           hasPollEnded = currentTime.isAfter(pollEndTime);
//                           days = DateTime(
//                             DateTime.parse(feeds.poll_end).year,
//                             DateTime.parse(feeds.poll_end).month,
//                             DateTime.parse(feeds.poll_end).day,
//                           )
//                               .difference(DateTime(
//                                 DateTime.now().year,
//                                 DateTime.now().month,
//                                 DateTime.now().day,
//                               ))
//                               .inDays;
//                           poll_end_desc = days < 1
//                               ? 'ended'
//                               : days < 7 && days > 0
//                                   ? '$days days left'
//                                   : days > 6 && days < 30
//                                       ? '${daysToWeeks(days)} week${daysToWeeks(days) > 1 ? 's' : ''} left'
//                                       : days > 30
//                                           ? '${daysToMonths(days)} month${daysToMonths(days) > 1 ? 's' : ''} left'
//                                           : days > 365
//                                               ? '${daysToYears(days)}year${daysToYears(days) > 1 ? 's' : ''} left'
//                                               : '';
//                           print("poll Date: ${feeds.poll_end}");

//                           for (PollOptions poll in feeds.poll_details!) {
//                             optionList.add({
//                               'option_id': poll.option_id,
//                               'option_value': poll.option_value,
//                               'votes': poll.votes,
//                             });
//                           }
//                         }
//                         print(
//                             "This time from server ${feeds.post_message} ${DateTime.parse(feeds.post_updated_time)} CURRENT DATETIME ${DateTime.now()}");
//                         Map<String, dynamic> mapData = {
//                           'id': feeds.post_id,
//                           'post_message': feeds.post_message,
//                           'like_count': feeds.like_count,
//                           'comment_count': feeds.comment_count,
//                           'post_profile_pics': feeds.post_profile_pics,
//                           'post_update_by': feeds.post_update_by,
//                           'post_updated_time': feeds.post_updated_time,
//                           'username': feeds.username,
//                           'post_alignment': feeds.post_alignment,
//                           'is_comment_of_comment': false,
//                           'media': imageList,
//                         };
//                         String videoUrl =
//                             "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
//                         return GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () async {
//                             Navigator.push(context,
//                                 MaterialPageRoute(builder: (context) {
//                               return MultiBlocProvider(
//                                 providers: [
//                                   BlocProvider(
//                                     create: (contextA) => PostsBloc(),
//                                   ),
//                                 ],
//                                 child: Comments(
//                                   mapData: mapData,
//                                 ),
//                               );
//                             }));
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 8.0),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(
//                                           left: 16.0, top: 16.0),
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           Map<String, dynamic> mapData = {
//                                             'subjectID': feeds.posted_by,
//                                             'picture': feeds.post_profile_pics,
//                                             'post_update_by':
//                                                 feeds.post_update_by,
//                                             'username': feeds.username,
//                                           };
//                                           Navigator.push(context,
//                                               MaterialPageRoute(
//                                                   builder: (context) {
//                                             return MultiBlocProvider(
//                                               providers: [
//                                                 BlocProvider(
//                                                   create: (contextA) =>
//                                                       p.PeopleBloc(),
//                                                 ),
//                                                 BlocProvider(
//                                                   create: (context) =>
//                                                       PostsBloc(),
//                                                 ),
//                                               ],
//                                               child: PeopleProfile(
//                                                   mapData: mapData),
//                                             );
//                                           }));
//                                         },
//                                         child: CircleAvatar(
//                                           backgroundImage:
//                                               CachedNetworkImageProvider(
//                                             '${feeds.post_profile_pics}',
//                                           ),
//                                           radius: 24,
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 16.0, top: 16.0, right: 16.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Expanded(
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       Map<String, dynamic>
//                                                           mapData = {
//                                                         'subjectID':
//                                                             feeds.posted_by,
//                                                         'picture': feeds
//                                                             .post_profile_pics,
//                                                         'post_update_by': feeds
//                                                             .post_update_by,
//                                                         'username':
//                                                             feeds.username,
//                                                       };
//                                                       Navigator.push(context,
//                                                           MaterialPageRoute(
//                                                               builder:
//                                                                   (context) {
//                                                         return MultiBlocProvider(
//                                                           providers: [
//                                                             BlocProvider(
//                                                               create: (contextA) =>
//                                                                   p.PeopleBloc(),
//                                                             ),
//                                                             BlocProvider(
//                                                               create: (context) =>
//                                                                   PostsBloc(),
//                                                             ),
//                                                           ],
//                                                           child: PeopleProfile(
//                                                               mapData: mapData),
//                                                         );
//                                                       }));
//                                                     },
//                                                     child: Text(
//                                                       _substring(
//                                                           feeds.post_update_by,
//                                                           20),
//                                                       style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 16,
//                                                       ),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       maxLines: 1,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   '. ' +
//                                                       _getTimeAgo(
//                                                           DateTime.parse(feeds
//                                                               .post_updated_time)),
//                                                   style: TextStyle(
//                                                     color: Colors.grey,
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 1.0),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Map<String, dynamic> mapData = {
//                                                   'subjectID': feeds.posted_by,
//                                                   'picture':
//                                                       feeds.post_profile_pics,
//                                                   'post_update_by':
//                                                       feeds.post_update_by,
//                                                   'username': feeds.username,
//                                                 };
//                                                 Navigator.push(context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) {
//                                                   return MultiBlocProvider(
//                                                     providers: [
//                                                       BlocProvider(
//                                                         create: (contextA) =>
//                                                             p.PeopleBloc(),
//                                                       ),
//                                                       BlocProvider(
//                                                         create: (context) =>
//                                                             PostsBloc(),
//                                                       ),
//                                                     ],
//                                                     child: PeopleProfile(
//                                                         mapData: mapData),
//                                                   );
//                                                 }));
//                                               },
//                                               child: Text(
//                                                 '@${feeds.username}',
//                                                 overflow: TextOverflow.ellipsis,
//                                                 maxLines: 1,
//                                                 style: TextStyle(
//                                                   color: Colors.grey,
//                                                   fontSize: 15,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding:
//                                       EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
//                                   child: Align(
//                                     alignment: feeds.post_alignment == "ltr" ||
//                                             feeds.post_alignment == null ||
//                                             feeds.post_alignment == ""
//                                         ? Alignment.topLeft
//                                         : Alignment.topRight,
//                                     child: InkWell(
//                                       onLongPress: () {
//                                         FlutterClipboard.copy(
//                                                 feeds.post_message)
//                                             .then(
//                                           (value) => GFToast.showToast(
//                                               'Copied', context,
//                                               toastPosition:
//                                                   GFToastPosition.BOTTOM,
//                                               textStyle: TextStyle(
//                                                   fontSize: 15,
//                                                   color: GFColors.DARK),
//                                               backgroundColor: GFColors.LIGHT,
//                                               trailing: Icon(
//                                                 Icons.notifications,
//                                                 color: GFColors.SUCCESS,
//                                               )),
//                                         );
//                                       },
//                                       onTap: () {
//                                         Navigator.push(context,
//                                             MaterialPageRoute(
//                                                 builder: (context) {
//                                           return MultiBlocProvider(
//                                             providers: [
//                                               BlocProvider(
//                                                 create: (contextA) =>
//                                                     PostsBloc(),
//                                               ),
//                                             ],
//                                             child: Comments(
//                                               mapData: mapData,
//                                             ),
//                                           );
//                                         }));
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(04.0),
//                                         child: Linkify(
//                                           options:
//                                               LinkifyOptions(humanize: false),
//                                           onOpen: _onOpen,
//                                           text: feeds.post_message,
//                                           style: TextStyle(fontSize: 15),
//                                           textAlign:
//                                               feeds.post_alignment == "rtl"
//                                                   ? TextAlign.right
//                                                   : TextAlign.left,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 if (imageList.length > 0)
//                                   Padding(
//                                     padding: const EdgeInsets.fromLTRB(
//                                         16.0, 12.0, 16.0, 0.0),
//                                     child: ImageSwipe(imageList: imageList),
//                                   ),
//                                 const SizedBox(height: 10.0),
//                                 Padding(
//                                   padding:
//                                       EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(Icons.comment_outlined,
//                                               color: Colors.grey, size: 18.0),
//                                           SizedBox(width: 4.0),
//                                           Text(
//                                               '${numberFormat(commentCounts[arrCIndex].counts)}',
//                                               style: TextStyle(
//                                                   color: Colors.grey,
//                                                   fontSize: 14.0)),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           GestureDetector(
//                                             child: Icon(
//                                                 likeCounts[arrIndex].isLiked
//                                                     ? Icons.favorite
//                                                     : Icons
//                                                         .favorite_border_outlined,
//                                                 color:
//                                                     likeCounts[arrIndex].isLiked
//                                                         ? Colors.red
//                                                         : Colors.grey,
//                                                 size: 18.0),
//                                             onTap: () {
//                                               setState(() {
//                                                 _clickedID =
//                                                     int.parse(feeds.post_id);
//                                               });

//                                               if (likeCounts[arrIndex]
//                                                   .isLiked) {
//                                                 BlocProvider.of<PostsBloc>(
//                                                         context)
//                                                     .add(
//                                                   UnLikePostEvent(
//                                                       post_id: feeds.post_id),
//                                                 );
//                                               } else {
//                                                 BlocProvider.of<PostsBloc>(
//                                                         context)
//                                                     .add(
//                                                   LikePostEvent(
//                                                       post_id: feeds.post_id),
//                                                 );
//                                                 _toggleLike(
//                                                     likeCounts[arrIndex].id);
//                                               }
//                                             },
//                                           ),
//                                           SizedBox(width: 4.0),
//                                           Text(
//                                               '${numberFormat(likeCounts[arrIndex].likeCounts)}',
//                                               style: TextStyle(
//                                                   color: Colors.grey,
//                                                   fontSize: 14.0)),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () async {
//                                               share(
//                                                 feeds.sharelink,
//                                                 '',
//                                               );
//                                             },
//                                             child: Icon(Icons.share_outlined,
//                                                 color: Colors.grey, size: 18.0),
//                                           ),
//                                           SizedBox(width: 4.0),
//                                         ],
//                                       ),
//                                       PopupMenuButton<String>(
//                                         onSelected: (String value) {
//                                           if (value == "report") {
//                                             showDialog(
//                                               context: context,
//                                               builder:
//                                                   (BuildContext contextTwo) {
//                                                 return AlertDialog(
//                                                   scrollable: true,
//                                                   title: Text('Report'),
//                                                   content: Container(
//                                                     height: 175.0,
//                                                     width: 350.0,
//                                                     child: Column(
//                                                       children: [
//                                                         Container(
//                                                           child: SizedBox(
//                                                             child:
//                                                                 TextFormField(
//                                                               maxLength: 300,
//                                                               maxLines: 3,
//                                                               minLines: 1,
//                                                               keyboardType:
//                                                                   TextInputType
//                                                                       .text,
//                                                               decoration: InputDecoration(
//                                                                   border: OutlineInputBorder(
//                                                                       borderRadius: BorderRadius.circular(
//                                                                           15.0)),
//                                                                   labelText:
//                                                                       'Comment',
//                                                                   hintText:
//                                                                       'Enter Comment',
//                                                                   contentPadding: EdgeInsets.symmetric(
//                                                                       vertical:
//                                                                           20.0,
//                                                                       horizontal:
//                                                                           10.0)),
//                                                               controller:
//                                                                   _controllerComment,
//                                                               validator:
//                                                                   (value) {
//                                                                 if (value ==
//                                                                         null ||
//                                                                     value
//                                                                         .isEmpty) {
//                                                                   return 'Please Enter Comment';
//                                                                   final snackBar =
//                                                                       SnackBar(
//                                                                     content: Text(
//                                                                         'Please Enter Comment'),
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .green
//                                                                             .shade300,
//                                                                   );
//                                                                   ScaffoldMessenger.of(
//                                                                           context)
//                                                                       .showSnackBar(
//                                                                           snackBar);
//                                                                 }
//                                                                 return null;
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 2.0,
//                                                         ),
//                                                         SizedBox(
//                                                           height: 50,
//                                                           child: ElevatedButton(
//                                                             style:
//                                                                 raisedButtonStyleGreen,
//                                                             onPressed: () {
//                                                               if (_formKey
//                                                                   .currentState!
//                                                                   .validate()) {
//                                                                 BlocProvider.of<
//                                                                             PostsBloc>(
//                                                                         context)
//                                                                     .add(
//                                                                   ReportAbuseEvent(
//                                                                       comment:
//                                                                           _controllerComment
//                                                                               .text,
//                                                                       post_id: feeds
//                                                                           .post_id,
//                                                                       reported:
//                                                                           feeds
//                                                                               .posted_by),
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 const Text(
//                                                                   'Submit',
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontSize:
//                                                                           20.0),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             );
//                                           } else if (value == 'delete') {
//                                             setState(() {
//                                               _clickedID = index;
//                                             });
//                                             BlocProvider.of<PostsBloc>(context)
//                                                 .add(
//                                               DeleteFeedEvent(
//                                                   post_id: feeds.post_id,
//                                                   posted_by: feeds.posted_by),
//                                             );
//                                           } else if (value == 'block') {
//                                             BlocProvider.of<PostsBloc>(context)
//                                                 .add(
//                                               BlockUserEvent(
//                                                   subjectID: feeds.posted_by,
//                                                   req_type: 'block'),
//                                             );
//                                           }
//                                         },
//                                         itemBuilder: (BuildContext context) =>
//                                             <PopupMenuEntry<String>>[
//                                           const PopupMenuItem<String>(
//                                             value: 'report',
//                                             child: ListTile(
//                                               leading:
//                                                   Icon(Icons.edit_outlined),
//                                               title: Text('Report'),
//                                             ),
//                                           ),
//                                           const PopupMenuItem<String>(
//                                             value: 'delete',
//                                             child: ListTile(
//                                               leading:
//                                                   Icon(Icons.delete_outline),
//                                               title: Text('Delete'),
//                                             ),
//                                           ),
//                                           const PopupMenuItem<String>(
//                                             value: 'block',
//                                             child: ListTile(
//                                               leading:
//                                                   Icon(Icons.delete_outline),
//                                               title: Text('Block'),
//                                             ),
//                                           ),
//                                         ],
//                                         child: const Row(
//                                           children: [
//                                             Icon(Icons.more_vert_outlined,
//                                                 color: Colors.grey, size: 18.0),
//                                             SizedBox(width: 4.0),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5.0),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               // Positioned(
//               //   top: 140,
//               //   left: 0,
//               //   right: 0,
//               //   child: Container(
//               //     color: Colors.white, // Example background color
//               //     child: Padding(
//               //       padding: const EdgeInsets.all(8.0),
//               //       child: Text(
//               //         'Static Element',
//               //         textAlign: TextAlign.center,
//               //         style:
//               //             TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),

//         AnimatedPositioned(
//           duration: const Duration(milliseconds: 300),
//           top: _showCircleRow ? 0 : -125,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             height: 140,
//             color: Colors.white,
//             child: _isLoadingTop
//                 ? _buildTopShimmerLoader()
//                 : ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: topFeed.length,
//                     itemBuilder: (context, index) {
//                       final top = topFeed[index];
//                       return GestureDetector(
//                         onTap: () async {
//                           var deviceToken = getDeviceToken();
//                           await AppSharedPreferences.setValue(
//                               key: 'isTownhallLeader',
//                               value: top.is_townhall_leader);

//                           setState(() {
//                             olderLoader = false;
//                             // I can comment if incase it later post an issue in future
//                             print(
//                                 "Townhall ID on tap Tapped: ${top.townhall_id.toString()}");
//                             if (data.length > 0) {
//                               _scrollController.jumpTo(0);
//                             }
//                             isPageFirstLoad = false;
//                             showFloatingButton =
//                                 top.can_post == "yes" ? true : false;
//                             showResultButton =
//                                 top.show_result_button == 'yes' ? true : false;
//                             _topFeedIndexID = int.parse(top.townhall_id);

//                             // _topFeedIndexID = item.townhall_id
//                             //         .toString() ==
//                             //     topFeed[0]
//                             //         .townhall_id
//                             //         .toString()
//                             // ? 0
//                             // : int.parse(item.townhall_id);
//                           });
//                           //onTap(item);

//                           last_post_id = '';
//                           print(
//                               "TEST PRINT: ${groupId == top.townhall_id}  ${orgId == top.org_id} ${top.can_show_townhall_info == "yes"}");

//                           int townID = topFeed[0].townhall_id == top.townhall_id
//                               ? 0
//                               : int.parse(top.townhall_id);

//                           print("TwnID: ${townID} ORG: ${orgId}");
//                           print("Can P: ${top.can_post} ${top.can_post_polls}");
//                           setState(() {
//                             loading = data.length < 1 ? true : false;
//                             olderLoader = data.length < 1 ? true : false;
//                             canPost = top.can_post == "yes" ? true : false;
//                             canPostPoll =
//                                 top.can_post_polls == "yes" ? true : false;
//                           });

//                           if (groupId == top.townhall_id &&
//                               orgId == top.org_id &&
//                               top.can_show_townhall_info == "yes") {
//                             _showTownhallSheet(context);

//                             setState(() {
//                               _slideUpTitle = "Townhall Info";
//                               _showSlideUpFor = "townhall";
//                               isCachedDataAvailable = false;
//                               showTownhallLoader = true;
//                               newFeedLoader = false;
//                               showSlideUpPanel = true;
//                               loading = false;
//                             });

//                             BlocProvider.of<PostsBloc>(context).add(
//                                 GetTownhallInfoEvent(
//                                     townhall_id: groupId,
//                                     org_id: orgId,
//                                     is_this_a_more: 'no'));
//                           } else {
//                             _getCachedFeedData(int.parse(top.townhall_id));
//                             _getCachedTopData(int.parse(top.townhall_id));
//                             setState(() {
//                               groupId = top.townhall_id.toString();
//                               isFirstFeedRequest = true;
//                               newList.add(groupId);
//                               newFeedLoader = false;
//                               newDataList = [];
//                               _isLoading = isCachedDataAvailable ? false : true;
//                               print(
//                                   "Is cached available: ${isCachedDataAvailable}");
//                               //data = [];
//                             });
//                             print("I'm loading: ${loading}");
//                             print("Decision: ${isCachedDataAvailable}");
//                             if (isCachedDataAvailable) {
//                               Future.delayed(const Duration(seconds: 0), () {
//                                 setState(() {
//                                   newFeedLoader = true;
//                                   loading = false;
//                                 });
//                               });
//                             } else {
//                               setState(() {
//                                 loading = true;
//                                 olderLoader = false;
//                               });
//                             }
//                             await AppSharedPreferences.setValue(
//                                 key: 'groupID', value: groupId);
//                             await AppSharedPreferences.setValue(
//                                 key: 'groupName',
//                                 value: top.townhall_display_name);
//                             await AppSharedPreferences.setValue(
//                                 key: 'groupFullName',
//                                 value: top.townhall_full_name);
//                             firstTimeLoading = true;

//                             BlocProvider.of<PostsBloc>(cont).add(
//                               FeedEvent(
//                                 feedRequest: FeedRequest(
//                                     skipOnboarding: true,
//                                     skipTopFeed: true,
//                                     isFirstFeedRequest: true,
//                                     last_post_id: last_post_id,
//                                     group_id: top.townhall_id.toString(),
//                                     org_id: orgId,
//                                     page: '',
//                                     limit: limit,
//                                     older_or_newer: older_or_newer,
//                                     page_owner: '',
//                                     device_token: deviceToken,
//                                     device_type: _deviceType),
//                               ),
//                             );
//                           }
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 1.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 alignment: Alignment.center,
//                                 height: 70,
//                                 width: 90,
//                                 child: Stack(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 30.0 -
//                                           (30.0 *
//                                               top.circle_reduction_percentage /
//                                               100),
//                                       backgroundColor:
//                                           groupId == top.townhall_id.toString()
//                                               ? Colors.lightBlue
//                                               : Colors.grey,
//                                       child: ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(50.0),
//                                         child: Image.network(
//                                           top.rep_picture_mid.toString().isEmpty
//                                               ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
//                                               : top.rep_picture_mid.toString(),
//                                           width: 55.0 -
//                                               (55 *
//                                                   top.circle_reduction_percentage /
//                                                   100),
//                                           height: 55.0 -
//                                               (55 *
//                                                   top.circle_reduction_percentage /
//                                                   100),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     groupId == top.townhall_id.toString()
//                                         ? Positioned(
//                                             bottom: 40.0 -
//                                                 (40 *
//                                                     top.circle_reduction_percentage /
//                                                     100),
//                                             right: 1,
//                                             child: Container(
//                                               width: 20.0 -
//                                                   (20 *
//                                                       top.circle_reduction_percentage /
//                                                       100),
//                                               height: 20.0 -
//                                                   (20 *
//                                                       top.circle_reduction_percentage /
//                                                       100),
//                                               child: ImageIcon(
//                                                 AssetImage('images/info.png'),
//                                                 size: 25.0 -
//                                                     (25 *
//                                                         top.circle_reduction_percentage /
//                                                         100),
//                                                 color: Colors.white,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                   color: Colors.lightBlue,
//                                                   shape: BoxShape.circle),
//                                             )

//                                             // SizedBox(
//                                             //   width: 25,
//                                             //   child: IconButton(
//                                             //     iconSize: 35,
//                                             //     color: Colors.red,
//                                             //     icon: Icon(Typicons.info),
//                                             //     onPressed: () {
//                                             //       debugPrint(
//                                             //           "debug print");
//                                             //     }, // icon user
//                                             //   ),
//                                             // ),
//                                             )
//                                         : SizedBox(),
//                                   ],
//                                 ),
//                               ),

//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                     top: 4.0,
//                                     right: 4.0,
//                                     left: 4.0,
//                                     bottom: 0.0),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${top.townhall_name}', // Replace with your desired text
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     Text(
//                                       '(${NumberFormat.compact().format(top.member_count)})', // Replace with your desired text
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           color: Colors.grey, fontSize: 12),
//                                     ),
//                                   ],
//                                 ),
//                               ) // Adjust the space between CircleAvatar and Text
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildImageArea() {
//     return GestureDetector(
//       onTap: () {
//         _showImageDialog(context);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue, // Placeholder color
//           borderRadius: BorderRadius.circular(12.0), // Add border radius
//         ),
//         height: 180, // Adjust height as needed
//         child: const Center(
//           child: Icon(
//             Icons.image,
//             color: Colors.white,
//             size: 40,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showImageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Post Images'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Replace this with your logic to display images in the dialog
//                 Image.network(
//                     'https://via.placeholder.com/150'), // Example image
//                 Image.network(
//                     'https://via.placeholder.com/150'), // Example image
//                 Image.network(
//                     'https://via.placeholder.com/150'), // Example image
//                 // Add more images as needed
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String numberFormat(int n) {
//     String num = n.toString();
//     int len = num.length;

//     if (n >= 1000 && n < 1000000) {
//       return num.substring(0, len - 3) +
//           '.' +
//           num.substring(len - 3, 1 + (len - 3)) +
//           'k';
//     } else if (n >= 1000000 && n < 1000000000) {
//       return num.substring(0, len - 6) +
//           '.' +
//           num.substring(len - 6, 1 + (len - 6)) +
//           'm';
//     } else if (n > 1000000000) {
//       return num.substring(0, len - 9) +
//           '.' +
//           num.substring(len - 9, 1 + (len - 9)) +
//           'b';
//     } else {
//       return num.toString();
//     }
//   }

//   _getOlderPosts(int limit, deviceToken) {
//     setState(() {
//       olderLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//     });
//     BlocProvider.of<PostsBloc>(context).add(
//       FeedEvent(
//         feedRequest: FeedRequest(
//             skipOnboarding: false,
//             skipTopFeed: false,
//             isFirstFeedRequest: false,
//             last_post_id: last_post_id,
//             group_id: groupId,
//             org_id: orgId,
//             page: '',
//             limit: limit,
//             older_or_newer: 'older',
//             page_owner: '',
//             device_token: deviceToken,
//             device_type: _deviceType),
//       ),
//     );
//     setState(() {});

//     print("YY- Last PostID ${last_post_id}");
//     print("YY- groupID ${groupId}");
//     print("YY- limit ${limit}");
//   }

//   _getNewerPosts(int limit, deviceToken) {
//     setState(() {
//       isLoadingUpRequest = true;
//       newLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//     });
//     isThereResult = false;
//     print("I am search for new post with ID: ${first_post_id}");
//     BlocProvider.of<PostsBloc>(context).add(
//       FeedEvent(
//         feedRequest: FeedRequest(
//             skipOnboarding: false,
//             skipTopFeed: false,
//             isFirstFeedRequest: false,
//             last_post_id: first_post_id,
//             group_id: groupId,
//             org_id: orgId,
//             page: '',
//             limit: limit,
//             older_or_newer: 'newer',
//             page_owner: '',
//             device_token: deviceToken,
//             device_type: _deviceType),
//       ),
//     );
//     setState(() {});
//   }

//   _setOrgName() async {
//     var organizationName = await getOrgName();
//     setState(() {
//       orgName = organizationName;
//     });
//     print("This is orgName: ${orgName}");
//   }

//   // _checkVersion(NewVersionPlus newVersion, int min_build_no) async {
//   //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   //   final status = await newVersion.getVersionStatus();

//   //   var dismissedVersion =
//   //       await _getDismissedVersion(); //this is will only show notification when user hasn't updated

//   //   // print("dismissedVersion: ${dismissedVersion}");
//   //   // print("LocalVersion: ${packageInfo.version}");
//   //   // print("StoreVersion: ${status!.storeVersion}");
//   //   // print("Expected Build No: ${min_build_no}");

//   //   debugPrint("release note: " + status!.releaseNotes!);
//   //   debugPrint("Store link: " + status.appStoreLink);
//   //   debugPrint("Local version: " + status.localVersion);
//   //   debugPrint("Store version: " + status.storeVersion);
//   //   debugPrint("System Version: " + packageInfo.version);
//   //   print("Dismissed: ${dismissedVersion}");
//   //   AppSharedPreferences.setInt(
//   //       key: 'installedAppBuildNo', value: int.parse(packageInfo.buildNumber));

//   //   if (status.localVersion != status.storeVersion &&
//   //       dismissedVersion != status.storeVersion) {
//   //     //debugPrint(status.canUpdate.toString());
//   //     newVersion.showUpdateDialog(
//   //       context: context,
//   //       versionStatus: status,
//   //       dialogText: 'A new version of TownHall app is available for download.',
//   //       dialogTitle: 'UPDATE!',
//   //       updateButtonText: 'Update Now',
//   //       allowDismissal:
//   //           min_build_no > int.parse(packageInfo.buildNumber) ? false : true,
//   //       dismissButtonText: 'Later',
//   //       dismissAction: () => {
//   //         Navigator.of(context).pop(),
//   //         AppSharedPreferences.setValue(
//   //             key: 'dismissedVersion', value: status.storeVersion),
//   //       },
//   //     );
//   //   } else {}
//   // }
//   void _initVersion() async {
//     //final package = AppInfo.of(context).package;
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     // final _checker = AppVersionChecker();
//     // PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     // _checker.checkUpdate().then((value) {
//     //   _canUpdate = value.canUpdate;
//     //   _currentVersion = value.currentVersion;
//     //   _storeVersion = value.newVersion.toString();
//     //   _storeUrl = value.appURL.toString();
//     //   //return the new app version
//     //   print("Package Info Version: ${packageInfo.version}");
//     //   //return error message if found else it will return null
//     // });
//     _canUpdate = false;
//     _currentVersion = packageInfo.version;
//     _storeVersion = packageInfo.buildNumber;
//     _storeUrl = packageInfo.installerStore.toString();
//   }

//   // Widget _showVersion() {
//   //   return GFFloatingWidget(
//   //     child: GFAlert(
//   //       title: 'Welcome !',
//   //       content:
//   //           'Get Flutter is one of the largest Flutter open-source UI library for mobile or web apps with  1000+ pre-built reusable widgets.',
//   //       type: GFAlertType.rounded,
//   //       bottombar: Row(children: [
//   //         GFButton(
//   //           onPressed: () {
//   //             setState(() {
//   //               //showalert=false;
//   //             });
//   //           },
//   //           shape: GFButtonShape.pills,
//   //           child: Text('Skip', style: TextStyle(color: Colors.black)),
//   //         ),
//   //         SizedBox(width: 5),
//   //         GFButton(
//   //           onPressed: () {
//   //             setState(() {
//   //               //showalert=false;
//   //             });
//   //           },
//   //           shape: GFButtonShape.pills,
//   //           icon: Icon(
//   //             Icons.keyboard_arrow_right,
//   //             color: GFColors.SECONDARY,
//   //           ),
//   //           position: GFPosition.end,
//   //           text: 'Learn More',
//   //         ),
//   //       ]),
//   //     ),
//   //   );
//   // }
//   void _showVersionNotification(String storeUrl, int min_build_no) async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     Alert(
//       context: context,
//       onWillPopActive: true,
//       style: AlertStyle(
//           isCloseButton: false,
//           titleStyle: TextStyle(fontWeight: FontWeight.bold),
//           overlayColor: Colors.black54),
//       title: "Update!",
//       desc: "WE HAVE IMPROVED TOWNHALL FOR YOU \n Please Update to Enjoy",
//       buttons: [
//         DialogButton(
//           color: Colors.black45,
//           child: Text(
//             "Later",
//             style: TextStyle(color: Colors.white, fontSize: 20),
//           ),
//           onPressed: min_build_no > int.parse(packageInfo.buildNumber)
//               ? null
//               : () {
//                   AppSharedPreferences.setValue(
//                       key: 'dismissedVersion', value: _storeVersion);
//                   Navigator.pop(context);
//                   print("Min: ${min_build_no}");
//                 },
//           width: 120,
//         ),
//         DialogButton(
//           child: Text(
//             "Update",
//             style: TextStyle(color: Colors.white, fontSize: 20),
//           ),
//           onPressed: () {
//             //_onOpen();
//             _launchUrl(_storeUrl);
//             // _launchUrl(
//             //     "https://play.google.com/store/apps/details?id=com.naheretownhall.nahere");
//           },
//           width: 120,
//         )
//       ],
//     ).show();
//   }

//   Future<void> dismiss() async {
//     AppSharedPreferences.setBool(key: 'userNewVersionClickAction', value: true);
//     Navigator.of(context, rootNavigator: true).pop();
//   }

//   Future<String?> _getDismissedVersion() async {
//     return await AppSharedPreferences.getValue(key: 'dismissedVersion');
//   }

//   Future<int?> getInstalledAppBuildNo() async {
//     return AppSharedPreferences.getInt(key: 'installedAppBuildNo');
//   }

//   Future<String?> getPageData(String value) async {
//     return await AppSharedPreferences.getValue(key: value);
//   }

//   Future<String?> getTownhallView() async {
//     return await AppSharedPreferences.getValue(key: 'townhallView');
//   }

//   // _getGroupID() async {
//   //   var grpID = await getGroupID();
//   //   setState(() {
//   //     groupId = grpID;
//   //   });
//   // }

//   _getOrgID() async {
//     var orgID = await getOrg();
//     print("First Time Landing ORG ID ${orgID}");
//     setState(() {
//       orgId = orgID.toString();
//     });
//   }

//   Future<void> _onOpen(LinkableElement link) async {
//     if (await launch(link.url)) {
//       await launch(link.url);
//     } else {
//       throw 'Could not launch $link';
//     }
//   }

//   Future<void> _launchUrl(String url) async {
//     final Uri _url = Uri.parse(url);
//     debugPrint("DebugPrint ${_url}");
//     if (!await launchUrl(_url)) {
//       throw 'Could not launch $_url';
//     } else {
//       debugPrint("Was successfully launched");
//     }
//   }

//   Future<String?> getGroupID() async {
//     return await AppSharedPreferences.getValue(key: 'groupID');
//   }

//   Future<String?> _getDissmedVersion() async {
//     return await AppSharedPreferences.getValue(key: 'dismissedVersion');
//   }

//   // _setGroupID() async {
//   //   var gId = await getGroupID();

//   //   if (gId.toString() == "") {
//   //     setState(() {
//   //       groupId = '0';
//   //     });
//   //   } else {
//   //     setState(() {
//   //       groupId = gId.toString();
//   //     });
//   //   }
//   //   print("groupid: ${gId}");
//   // }
//   void _setProfilePic() async {
//     var picture = await _getProfilePic();
//     setState(() {
//       profileImage = picture!;
//     });
//   }

//   Widget _buildPortrait(String orientation, List<BodyData>? items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ListView.separated(
//             physics: NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             separatorBuilder: (BuildContext context, int index) => SizedBox(
//                   height: 2,
//                 ),
//             itemCount: items!.length,
//             itemBuilder: (context, index) {
//               return Column(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.only(
//                         bottom: index < items.length - 1 ? 1 : 0),
//                     height: 85,
//                     width: double.infinity,
//                     //color: Colors.blue,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         items[index].image == null || items[index].image == ""
//                             ? SizedBox()
//                             : Container(
//                                 width: 65,
//                                 height: 65,
//                                 // color: Colors.red,
//                                 child: CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Colors.grey,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(50),
//                                     child: Image.network(
//                                       items[index].image.toString(),
//                                       width: 60,
//                                       height: 60,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                         SizedBox(
//                           width: items[index].image == null ||
//                                   items[index].image == ""
//                               ? 0
//                               : 20,
//                         ),
//                         Flexible(
//                           child: Container(
//                             height: 99,
//                             //color: Colors.green,
//                             child: HtmlWidget('${items[index].body}'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }),
//       ],
//     );
//   }

//   Widget _buildLandscape(String orientation, List<BodyData>? items) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Container(
//             alignment: Alignment.topLeft,
//             height: 180,
//             // color: Colors.blue,
//             child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 physics: BouncingScrollPhysics(),
//                 shrinkWrap: true,
//                 separatorBuilder: (BuildContext context, int index) => SizedBox(
//                       width: 15,
//                     ),
//                 itemCount: items!.length,
//                 itemBuilder: (context, index) {
//                   return items[index].image == null || items[index].image == ""
//                       ? SizedBox()
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             //if orientation is landscape
//                             if (orientation == "landscape")
//                               Container(
//                                 width: 120,
//                                 // color: Colors.red,
//                                 child: Column(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 38,
//                                       backgroundColor: Colors.grey,
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(50),
//                                         child: Image.network(
//                                           items[index].image.toString(),
//                                           width: 75,
//                                           height: 75,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Container(
//                                       alignment: Alignment.topCenter,
//                                       height: 80,
//                                       width: 100,
//                                       child: HtmlWidget(items[index].body),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             if (orientation == "landscape_rectangle")
//                               Container(
//                                 width: 120,
//                                 // color: Colors.red,
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       width: 300,
//                                       height: 100,
//                                       // color: Colors.yellow,
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Container(
//                                       alignment: Alignment.topCenter,
//                                       height: 80,
//                                       width: 100,
//                                       child: HtmlWidget(items[index].body),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         );
//                 }),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLandscapeRectangle(String section_tag, List<BodyData>? items) {
//     for (var i = 0; i < items!.length; i++)
//       _audioItems.add(AudioItem(
//           bodyTxt: '${items[i].body}',
//           audioUrl: '${items[i].link}',
//           bgImage: '${items[i].image}'));
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Container(
//             alignment: Alignment.topLeft,
//             height: 190,
//             //color: Colors.blue,
//             child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 physics: BouncingScrollPhysics(),
//                 shrinkWrap: true,
//                 separatorBuilder: (BuildContext context, int index) => SizedBox(
//                       width: 15,
//                     ),
//                 itemCount: _audioItems.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 200,
//                     height: 200,
//                     // color: Colors.green,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: MediaQuery.of(context).size.width / 0.5,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(15.0),
//                                     topRight: Radius.circular(15.0)),
//                                 image: DecorationImage(
//                                   image:
//                                       NetworkImage(_audioItems[index].bgImage),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             StatefulBuilder(builder: (BuildContext context,
//                                 StateSetter newSetState) {
//                               return IconButton(
//                                   alignment: Alignment.topRight,
//                                   icon: isPlaying
//                                       ? Icon(Icons.pause_circle,
//                                           color: Colors.grey[300])
//                                       : Icon(Icons.play_circle,
//                                           color: Colors.grey[300]),
//                                   iconSize: 50.0,
//                                   onPressed: () async {
//                                     if (_audioPlayerController.isPlaying) {
//                                       _audioPlayerController
//                                           .pause(_audioPlayer);
//                                       newSetState(() {
//                                         isPlaying = false;
//                                       });
//                                     } else if (_audioPlayerController.isPause) {
//                                       _audioPlayerController
//                                           .resume(_audioPlayer);
//                                       newSetState(() {
//                                         isPlaying = false;
//                                       });
//                                     } else {
//                                       newSetState(() {
//                                         isPlaying = true;
//                                       });

//                                       //_audioPlayerController.resume(_audioPlayer);
//                                       _audioPlayerController.play(_audioPlayer,
//                                           _audioItems[index].audioUrl);
//                                       print("Play");
//                                     }
//                                     // if (isPlaying) {
//                                     //   _audioPlayer.stop();
//                                     // } else {
//                                     //   await _audioPlayer.play(
//                                     //       UrlSource('${items[index].link}'));
//                                     // }

//                                     // setState(() {
//                                     //   isPlaying = !isPlaying;
//                                     // });
//                                   });
//                             }),
//                           ],
//                         ),
//                         Container(
//                           //color: Colors.red,
//                           width: 200,
//                           child: HtmlWidget(_audioItems[index].bodyTxt),
//                         )
//                       ],
//                     ),
//                   );
//                 }),
//           ),
//         ),
//       ],
//     );
//   }

//   _checkViewStatus() async {
//     var nw = await getTownhallView();
//     print("status: $nw");
//     if (nw == "party") {
//       setState(() {
//         isTownhallView = false;
//       });
//     } else {
//       setState(() {
//         isTownhallView = true;
//       });
//     }
//   }

//   _verifyPageVisit(String value) async {
//     var pages = await getPages();
//     print(pages);
//     if (pages != null) {
//       setState(() {
//         _isPageVisited = pages.contains(value);
//       });
//     }
//   }

//   Future<void> share(String text, String title) async {
//     final box = context.findRenderObject() as RenderBox?;
//     // final imageUrl = "https://empl-dev.site/image1.jpg";
//     // final url = Uri.parse(imageUrl);
//     // final response = await http.get(url);
//     // final bytes = response.bodyBytes;
//     // final temp = await getTemporaryDirectory();
//     // final path = '${temp.path}/image.jpg';
//     // File(path).writeAsBytesSync(bytes);
//     // if (imageList.length > 0) {
//     //   await Share.shareFiles([path],
//     //       text: text,
//     //       //subject: title,
//     //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
//     // } else {
//     await Share.share(text,
//         subject: title,
//         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
//     //}
//   }

//   Future<List<String>?> getPages() async {
//     return await AppSharedPreferences.getList(key: 'pages');
//   }

//   String formatTime(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
//   }

//   Future<String?> getDeviceToken() async {
//     return await AppSharedPreferences.getValue(key: 'deviceToken');
//   }

//   Future<String?> _getProfilePic() async {
//     return await AppSharedPreferences.getValue(key: 'profilePic');
//   }

//   String _substring(String char, int count) {
//     return char.length > count ? char.substring(0, count) + '...' : char;
//   }

//   Future<String?> getOrg() async {
//     return await AppSharedPreferences.getValue(key: 'orgID');
//   }

//   Future<String?> getOrgName() async {
//     return await AppSharedPreferences.getValue(key: 'orgName');
//   }

//   String _getTimeAgo(DateTime utcTime) {
//     //return moment.from(utcTime.toLocal());
//     return moment.from(utcTime);
//   }

//   void _showTownhallSheet(BuildContext context) {
//     showModalBottomSheet(
//       //backgroundColor: Colors.red,
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return DraggableScrollableSheet(
//             expand: false,
//             initialChildSize: 0.9,
//             maxChildSize: 0.9,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return SingleChildScrollView(
//                 controller: scrollController,
//                 scrollDirection: Axis.vertical,
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(25, 20, 1, 0),
//                       child: Column(
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 width: MediaQuery.of(context).size.width - 50,
//                                 alignment: Alignment.topRight,
//                                 height: 20.0,
//                                 child: IconButton(
//                                     alignment: Alignment.topRight,
//                                     icon: Icon(Icons.close, color: Colors.grey),
//                                     iconSize: 20.0,
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     }),
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width - 50,
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       alignment: Alignment.topLeft,
//                                       child: Text(
//                                         _slideUpTitle,
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 15),
//                                       ),
//                                     ),
//                                     Divider(
//                                       thickness: 0.5,
//                                       color: Colors.black,
//                                     ),
//                                     showTownhallLoader
//                                         ? Center(
//                                             child: Container(
//                                               width: 80.0,
//                                               height: 80.0,
//                                               child: SpinKitCircle(
//                                                 color: Colors.blue,
//                                                 size: 50.0,
//                                               ),
//                                             ),
//                                           )
//                                         : Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               ListView.builder(
//                                                 shrinkWrap: true,
//                                                 scrollDirection: Axis.vertical,
//                                                 itemCount: townhallInfo.length,
//                                                 itemBuilder: (context, index) {
//                                                   final section =
//                                                       townhallInfo[index]
//                                                           .section;
//                                                   final body =
//                                                       townhallInfo[index].body;
//                                                   final section_tag = townhallInfo[
//                                                                       index]
//                                                                   .section_tag ==
//                                                               null ||
//                                                           townhallInfo[index]
//                                                                   .section_tag ==
//                                                               ""
//                                                       ? ''
//                                                       : townhallInfo[index]
//                                                           .section_tag;
//                                                   final orientation =
//                                                       townhallInfo[index]
//                                                                   .orientation ==
//                                                               null
//                                                           ? ''
//                                                           : townhallInfo[index]
//                                                               .orientation;
//                                                   print(
//                                                       "Orientation: ${orientation}");
//                                                   final actionType =
//                                                       townhallInfo[index]
//                                                                   .action_type ==
//                                                               null
//                                                           ? ''
//                                                           : townhallInfo[index]
//                                                               .action_type;

//                                                   return Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .stretch,
//                                                     children: [
//                                                       section == "" ||
//                                                               section == null
//                                                           ? SizedBox()
//                                                           : Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       top: 0,
//                                                                       bottom:
//                                                                           18.0),
//                                                               child: Text(
//                                                                   "${section}",
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           18.0,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold)),
//                                                             ),
//                                                       if (orientation ==
//                                                           "landscape")
//                                                         _buildLandscape(
//                                                             orientation!, body),
//                                                       if (orientation ==
//                                                           "portrait")
//                                                         _buildPortrait(
//                                                             orientation!, body),
//                                                       if (orientation ==
//                                                           "landscape_rectangle")
//                                                         _buildLandscapeRectangle(
//                                                             section_tag
//                                                                 .toString(),
//                                                             body),
//                                                       SizedBox(height: 25),
//                                                     ],
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             });
//       },
//     );
//   }

//   Future<void> initPlatformState() async {
//     var deviceData = <String, dynamic>{};
//     try {
//       if (Platform.isAndroid) {
//         _deviceType = "Android";
//       } else if (Platform.isIOS) {
//         _deviceType = "IOS";
//       } else if (Platform.isLinux) {
//         _deviceType = "Linux";
//       } else if (Platform.isMacOS) {
//         _deviceType = "MacOS";
//       } else if (Platform.isWindows) {
//         _deviceType = "Window";
//       }
//     } on PlatformException {
//       deviceData = <String, dynamic>{
//         'Error:': 'Failed to get platform version.'
//       };
//     }
//     print("My device type: ${_deviceType}");
//   }

//   _getCachedFeedData(int index) async {
//     await _getOrgID();
//     setState(() {
//       data = [];
//     });
//     var sharedGrpId = await getGroupID();
//     var grpID = isPageFirstLoad
//         ? sharedGrpId != null
//             ? sharedGrpId
//             : ''
//         : index.toString();
//     setState(() {
//       groupId = sharedGrpId != null ? sharedGrpId : grpID;
//     });

//     var pageData = await getPageData('page_feed_${orgId}_${grpID}');
//     if (pageData != null && pageData != "") {
//       print("Cached data was called Org ID: ${orgId} TowhnID: ${grpID}");
//       var json = jsonDecode(pageData);
//       setState(() {
//         // List<Map<String, dynamic>> data = List.from(json);
//         isCachedDataAvailable = true;
//         loading = false;
//         _isLoading = true;
//         if (showTownhallLoader == false) {
//           newFeedLoader = true;
//           _isLoading = false;
//           data = json.map<FeedData>((json) => FeedData.fromJson(json)).toList();
//         }
//       });
//     } else {
//       setState(() {
//         loading = true;
//         _isLoading = true;
//         isCachedDataAvailable = false;
//         newFeedLoader = false;
//       });
//     }
//     print("Cached Statuc:${isCachedDataAvailable}");
//   }

//   _initDismissedVersion() async {
//     var dismiss = await _getDismissedVersion();
//     setState(() {
//       _dismissedVersion = dismiss.toString();
//     });
//   }

//   _getCachedTopData(int index) async {
//     await _getOrgID();
//     var sharedGrpId = await getGroupID();
//     var grpID = isPageFirstLoad
//         ? sharedGrpId != null
//             ? sharedGrpId
//             : ''
//         : index.toString();
//     setState(() {
//       groupId = sharedGrpId != null ? sharedGrpId : grpID;
//     });
//     print("Cache OrgID ${orgId}, ${grpID}");

//     var pageData = await getPageData('page_feed_top_${orgId}_${grpID}');
//     if (pageData != null && pageData != "") {
//       var json = jsonDecode(pageData);
//       setState(() {
//         loading = false;
//         isCachedDataAvailable = true;
//         topFeed = json
//             .map<TopFeedData>((json) => TopFeedData.fromJson(json))
//             .toList();
//       });
//       //print("Page2: ${json}");
//     } else {
//       _isLoading = true;
//       //isCachedDataAvailable = false;
//     }
//     //print("Cached Statuc:${isCachedDataAvailable}");
//   }

//   int daysToWeeks(int days) {
//     const daysInWeek = 7;
//     return (days / daysInWeek).floor();
//   }

//   int daysToMonths(int days) {
//     const daysInMonth = 30.44; // Average number of days in a month
//     return (days / daysInMonth).ceil();
//   }

//   int daysToYears(int days) {
//     const daysInYear =
//         365.25; // Average number of days in a year, considering leap years
//     return (days / daysInYear).floor();
//   }

//   void _toggleLike(int id) {
//     int index = likeCounts
//         .indexWhere((likeCounts) => likeCounts.id == int.parse(id.toString()));
//     setState(() {
//       likeCounts.insert(
//           index,
//           Like(
//               isLiked: likeCounts[index].isLiked ? false : true,
//               likeCounts: likeCounts[index].isLiked
//                   ? likeCounts[index].likeCounts - 1
//                   : likeCounts[index].likeCounts + 1,
//               id: id));
//     });
//   }

//   bool _containValue(int index) {
//     if (_isLikeList.length > 0) {
//       for (var i = 0; i < _isLikeList.length; i++) {
//         if (_isLikeList[i]['index'] == index) {
//           return true;
//           break;
//         }
//       }
//       return false;
//     } else {
//       return false;
//     }
//   }

//   _getFirstWhere(List dataList) {
//     for (var i = 0; i < dataList.length; i++) {
//       if (dataList[i].noticeboard_msg == "no") {
//         return dataList[i].post_id;
//         break;
//       }
//     }
//   }
// }

// class RenderTownhall extends StatefulWidget {
//   final List<BodyData> data;
//   const RenderTownhall({required this.data});

//   @override
//   State<RenderTownhall> createState() => _RenderTownhallState();
// }

// class NotificationBody extends StatelessWidget {
//   final int count;
//   final double minHeight;

//   NotificationBody({
//     Key? key,
//     this.count = 0,
//     this.minHeight = 0.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final minHeight = 100.0;
//     return ConstrainedBox(
//       constraints: BoxConstraints(minHeight: minHeight),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
//         child: DecoratedBox(
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 spreadRadius: 12,
//                 blurRadius: 16,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   color: Colors.lightGreen.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(16.0),
//                   border: Border.all(
//                     width: 1.4,
//                     color: Colors.lightGreen.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Center(
//                     child: Text(
//                       'Count: $count',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headline4!
//                           .copyWith(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Like {
//   bool isLiked;
//   int likeCounts;
//   int id; //postID

//   Like({required this.isLiked, required this.likeCounts, required this.id});
// }

// class Comment {
//   int counts;
//   int id;
//   Comment({required this.counts, required this.id});
// }

// class _RenderTownhallState extends State<RenderTownhall> {
//   @override
//   Widget build(BuildContext context) {
//     print("Test: ${widget.data[0].image}");
//     return ListView.builder(
//         itemCount: 5,
//         itemBuilder: (BuildContext context, int index) {
//           return ListTile(
//               leading: Text('${index}'),
//               trailing: const Text(
//                 "GFG",
//                 style: TextStyle(color: Colors.green, fontSize: 15),
//               ),
//               title: Text("List item ${index}"));
//         });
//     // return Text("I know why");
//   }
// }

// class AudioPlayerController {
//   Duration duration = Duration();
//   Duration position = Duration();
//   bool isPlaying = false;
//   bool isPause = false;
//   // late VoidCallback _stateSetter;

//   void play(AudioPlayer player, String url) async {
//     await player.stop();
//     await player.play(UrlSource(url));

//     player.onDurationChanged.listen((event) {
//       duration = event;
//       setState(() {}); // Update UI on duration change
//     });
//     player.onPlayerStateChanged.listen((event) {
//       isPlaying = event == PlayerState.playing;
//       setState(() {});
//       print(isPlaying);
//     });

//     player.onPositionChanged.listen((event) {
//       position = event;
//       setState(() {}); // Update UI on position change
//     });
//   }

//   void pause(AudioPlayer player) async {
//     //await _audioPlayer.pause();
//     await player.pause();
//     setState(() {
//       isPlaying = false;
//       isPause = true;
//     });
//     print("isPause ${isPause}");
//   }

//   void resume(AudioPlayer player) async {
//     // await _audioPlayer.resume();
//     await player.resume();
//     setState(() {
//       isPlaying = true;
//       isPause = false;
//     });
//   }

//   void seek(AudioPlayer player, Duration duration) async {
//     //await _audioPlayer.seek(duration);
//     await player.seek(duration);
//   }

//   void setState(VoidCallback callback) {
//     //_stateSetter = callback;
//   }
// }

// class AudioItem {
//   final String bodyTxt;
//   final String audioUrl;
//   final String bgImage;

//   AudioItem(
//       {required this.bodyTxt, required this.audioUrl, required this.bgImage});
// }
