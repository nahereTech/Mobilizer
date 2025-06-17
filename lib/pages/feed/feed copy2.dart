// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:getwidget/getwidget.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:nahere/bloc/auth/auth_bloc.dart' as a;
// import 'package:nahere/bloc/search/organization_bloc.dart' as o;
// import 'package:nahere/bloc/search/polling_bloc.dart' as p;
// import 'package:nahere/bloc/suggestion/suggestion_bloc.dart' as s;
// import 'package:nahere/common/common/constants.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:intl/intl.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart';
// import 'package:nahere/bloc/search/people_bloc.dart' as p;
// import 'package:nahere/models/feed/feed_request.dart';
// import 'package:nahere/models/feed/feed_response.dart';
// import 'package:nahere/models/feed/topfeed_response.dart';
// import 'package:nahere/models/profile/get_profile_response.dart';
// import 'package:nahere/models/social/like_list_response.dart';
// import 'package:nahere/models/townhall/townhall_info_response.dart';
// import 'package:nahere/pages/comments/comments.dart';
// import 'package:nahere/pages/people/people_profile.dart';
// import 'package:nahere/pages/post/createpost.dart';
// import 'package:nahere/pages/profile/profile.dart';
// import 'package:nahere/pages/organization/organization.dart';
// import 'package:nahere/pages/register_otp/registerotp.dart';
// import 'package:nahere/pages/result/result.dart';
// import 'package:nahere/pages/result/result_type.dart';
// import 'package:nahere/pages/settings/settings.dart';
// import 'package:nahere/pages/suggestion/org_suggestion.dart';

// import 'package:nahere/pages/suggestion/suggestion.dart';
// import 'package:nahere/pages/townhall_info/townhall_info_screen.dart';
// import 'package:nahere/widget/image_swipe.dart';
// import 'package:nahere/widget/video_build.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:retrofit/http.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:super_tooltip/super_tooltip.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:indexed/indexed.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:video_player/video_player.dart';

// import '../../common/common/navigation.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:hawk_fab_menu/hawk_fab_menu.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// // import 'package:audio_service/audio_service.dart';
// // import 'package:just_audio/just_audio.dart';
// import 'package:nahere/pages/feed/audio_list.dart';
// import 'package:intl/intl.dart';
// import 'package:typicons_flutter/typicons_flutter.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:in_app_notification/in_app_notification.dart';
// import 'package:simple_moment/simple_moment.dart';

// int current = 0;
// // MediaItem mediaItem = MediaItem(
// //     id: audioList[0].url,
// //     title: audioList[0].name,
// //     artUri: Uri.parse(audioList[0].icon),
// //     album: audioList[0].album,
// //     duration: audioList[0].duration,
// //     artist: audioList[0].artist);

// // class AudioPlayerTask extends BackgroundAudioTask {
// //   final _audioPlayer = AudioPlayer();

// @override
// // Future<void> onStart(Map<String, dynamic> params) async {
// //   AudioServiceBackground.setState(controls: [
// //     MediaControl.pause,
// //     MediaControl.stop,
// //     MediaControl.skipToNext,
// //     MediaControl.skipToPrevious
// //   ], systemActions: [
// //     MediaAction.seekTo
// //   ], playing: true, processingState: AudioProcessingState.connecting);
// //   // Connect to the URL
// //   await _audioPlayer.setUrl(mediaItem.id);
// //   AudioServiceBackground.setMediaItem(mediaItem);
// //   // Now we're ready to play
// //   _audioPlayer.play();
// //   // Broadcast that we're playing, and what controls are available.
// //   AudioServiceBackground.setState(controls: [
// //     MediaControl.pause,
// //     MediaControl.stop,
// //     MediaControl.skipToNext,
// //     MediaControl.skipToPrevious
// //   ], systemActions: [
// //     MediaAction.seekTo
// //   ], playing: true, processingState: AudioProcessingState.ready);
// // }

// // @override
// // Future<void> onStop() async {
// //   AudioServiceBackground.setState(
// //       controls: [],
// //       playing: false,
// //       processingState: AudioProcessingState.ready);
// //   await _audioPlayer.stop();
// //   await super.onStop();
// // }

// // @override
// // Future<void> onPlay() async {
// //   AudioServiceBackground.setState(controls: [
// //     MediaControl.pause,
// //     MediaControl.stop,
// //     MediaControl.skipToNext,
// //     MediaControl.skipToPrevious
// //   ], systemActions: [
// //     MediaAction.seekTo
// //   ], playing: true, processingState: AudioProcessingState.ready);
// //   await _audioPlayer.play();
// //   return super.onPlay();
// // }

// // @override
// // Future<void> onPause() async {
// //   AudioServiceBackground.setState(controls: [
// //     MediaControl.play,
// //     MediaControl.stop,
// //     MediaControl.skipToNext,
// //     MediaControl.skipToPrevious
// //   ], systemActions: [
// //     MediaAction.seekTo
// //   ], playing: false, processingState: AudioProcessingState.ready);
// //   await _audioPlayer.pause();
// //   return super.onPause();
// // }

// // @override
// // Future<void> onSkipToNext() async {
// //   if (current < audioList.length - 1)
// //     current = current + 1;
// //   else
// //     current = 0;
// //   mediaItem = MediaItem(
// //       id: audioList[current].url,
// //       title: audioList[current].name,
// //       artUri: Uri.parse(audioList[current].icon),
// //       album: audioList[current].album,
// //       duration: audioList[current].duration,
// //       artist: audioList[current].artist);
// //   AudioServiceBackground.setMediaItem(mediaItem);
// //   await _audioPlayer.setUrl(mediaItem.id);
// //   AudioServiceBackground.setState(position: Duration.zero);
// //   return super.onSkipToNext();
// //}

// // @override
// // Future<void> onSkipToPrevious() async {
// //   if (current != 0)
// //     current = current - 1;
// //   else
// //     current = audioList.length - 1;
// //   mediaItem = MediaItem(
// //       id: audioList[current].url,
// //       title: audioList[current].name,
// //       artUri: Uri.parse(audioList[current].icon),
// //       album: audioList[current].album,
// //       duration: audioList[current].duration,
// //       artist: audioList[current].artist);
// //   AudioServiceBackground.setMediaItem(mediaItem);
// //   await _audioPlayer.setUrl(mediaItem.id);
// //   AudioServiceBackground.setState(position: Duration.zero);
// //   return super.onSkipToPrevious();
// // }

// // @override
// // Future<void> onSeekTo(Duration position) {
// //   _audioPlayer.seek(position);
// //   AudioServiceBackground.setState(position: position);
// //   return super.onSeekTo(position);
// // }
// //}

// class Feed extends StatefulWidget {
//   const Feed({Key? key}) : super(key: key);

//   @override
//   _FeedState createState() => _FeedState();
// }

// class _FeedState extends State<Feed> {
//   // late VideoPlayerController _vcontroller;
//   List<dynamic> data = [];
//   List<dynamic> newDataList = []; //new data from list.
//   List<dynamic> newList = []; //list of groups with new feed notification.
//   List<TopFeedData> topFeed = [];
//   List<InfoData> townhallInfo = [];
//   List<Map<String, dynamic>> _likeList = [];
//   // List<dynamic> _isLikeList = [];
//   List<LikeData> likeData = [];

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
//   bool isFirstFeedRequest =
//       true; //check if it's first time requesting for feeds
//   bool isCachedDataAvailable = false;
//   bool isPlaying = false;
//   bool canDismiss = true;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   List<dynamic> _isFollowList = [];
//   List<dynamic> _groupList = [];
//   String networkMsg = "";
//   String profileImage = "";
//   String _slideUpTitle = "";
//   String _showSlideUpFor = "";
//   String _deviceType = "";
//   ScrollController _scrollController = ScrollController();
//   PanelController _pc = new PanelController();
//   final _formKey = GlobalKey<FormState>();
//   final _controllerComment = TextEditingController();
//   //This is build number coming from the backend.
//   int _clickedFollowID = 0;
//   int _topFeedIndexID = 0;
//   bool _isPageVisited = false;
//   static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   final newVersion =
//       NewVersionPlus(iOSId: IOSPackageID, androidId: androidPackageID);
//   int limit = 30;
//   Timer? timer;
//   var moment = new Moment.now();
//   var sampleVideo =
//       "https://ia601205.us.archive.org/18/items/SampleVideo1280x7201mb/SampleVideo_1280x720_1mb.mp4";

//   void onTap(TopFeedData item) {
//     // Future.delayed(const Duration(seconds: 4), () {
//     //   tooltip?.close();
//     // });
//     // if (tooltip != null && tooltip!.isOpen) {
//     //   tooltip?.close();
//     //   return;
//     // }
//     // tooltip = SuperTooltip(
//     //   arrowLength: 0,
//     //   top: 120,
//     //   borderColor: Colors.blue.shade100,
//     //   backgroundColor: Colors.blue.shade100,
//     //   popupDirection: TooltipDirection.up,
//     //   content: Material(
//     //       color: Colors.blue.shade100,
//     //       child: Text(
//     //         item.entry_message,
//     //         softWrap: true,
//     //         style: TextStyle(
//     //           fontWeight: FontWeight.bold,
//     //           fontSize: 18.0,
//     //         ),
//     //       )),
//     // );
//     // // tooltip!.show(context);
//   }

//   // _backgroundTaskEntrypoint() {
//   //   AudioServiceBackground.run(() => AudioPlayerTask());
//   // }

//   @override
//   initState() {
//     timer = Timer.periodic(Duration(seconds: 10), (timer) {
//       setState(() {
//         moment = Moment.now();
//       });
//     });
//     // Workmanager().registerPeriodicTask(
//     //   'TaskTwo'
//     //   'backup',
//     //   frequency: Duration(hours: 15),
//     // );
//     // initPlatformState();
//     var deviceToken = getDeviceToken();
//     setUpTimedFetch();
//     //_setGroupID();
//     setState(() {
//       isPageFirstLoad = true;
//       _groupList = [];
//     });
//     print("is page first load: ${isPageFirstLoad}");
//     _setOrgName();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         if (isLastDownRequest == false) {
//           _getOlderPosts(limit, deviceToken);
//         }
//       } else if (_scrollController.position.pixels ==
//           _scrollController.position.minScrollExtent) {
//         if (isLoadingUpRequest == false) {
//           _getNewerPosts(limit, deviceToken);
//         }
//       }
//     });

//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<PostsBloc>(context).add(
//         FeedEvent(
//           feedRequest: FeedRequest(
//               skipOnboarding: false,
//               skipTopFeed: false,
//               isFirstFeedRequest: true,
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

//     var dismissedVersion = getDismissedVersion();

//     _checkViewStatus();
//     _getCachedFeedData(_topFeedIndexID);
//     _getCachedTopData(_topFeedIndexID);

//     if (_topFeedIndexID == 0 && data.length > 0) {
//       setState(() {
//         loading = true;
//         olderLoader = true;
//       });
//     }
//     super.initState();
//   }

//   // basicStatusCheck(NewVersion newVersion) {
//   //   newVersion.showAlertIfNecessary(context: context);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Material(
//       child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           body: SlidingUpPanel(
//             minHeight: 0.0,
//             maxHeight: size.height - 150,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20.0),
//               topRight: Radius.circular(20.0),
//             ),
//             onPanelClosed: () {
//               setState(() {
//                 showSlideUpPanel = false;
//               });
//             },
//             controller: _pc,
//             backdropEnabled: true,
//             panel: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
//                   child: Column(
//                     children: [
//                       Column(
//                         children: [
//                           Container(
//                             width: size.width - 50,
//                             height: 20.0,
//                             child: IconButton(
//                                 alignment: Alignment.topRight,
//                                 icon: Icon(Icons.close, color: Colors.grey),
//                                 iconSize: 20.0,
//                                 onPressed: () {
//                                   _pc.close();
//                                 }),
//                           ),
//                           Container(
//                             width: size.width - 50,
//                             child: Column(
//                               children: [
//                                 Container(
//                                   alignment: Alignment.topLeft,
//                                   child: Text(
//                                     _slideUpTitle,
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15),
//                                   ),
//                                 ),
//                                 Divider(
//                                   thickness: 0.5,
//                                   color: Colors.black,
//                                 ),
//                                 showTownhallLoader
//                                     ? Center(
//                                         child: Container(
//                                           width: 80.0,
//                                           height: 80.0,
//                                           child: SpinKitCircle(
//                                             color: Colors.blue,
//                                             size: 50.0,
//                                           ),
//                                         ),
//                                       )
//                                     : Column(
//                                         children: [
//                                           _showSlideUpFor == "likes"
//                                               ? Container(
//                                                   child: ListView.separated(
//                                                       shrinkWrap: true,
//                                                       separatorBuilder:
//                                                           (BuildContext context,
//                                                                   int index) =>
//                                                               Divider(
//                                                                   height: 2),
//                                                       itemCount:
//                                                           likeData.length,
//                                                       itemBuilder:
//                                                           (context, index) {
//                                                         final list =
//                                                             likeData[index];

//                                                         return ListTile(
//                                                           minVerticalPadding:
//                                                               10.0,
//                                                           title:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               // Navigator.push(
//                                                               //     context,
//                                                               //     MaterialPageRoute(
//                                                               //         builder:
//                                                               //             (context) {
//                                                               //   return MultiBlocProvider(
//                                                               //     providers: [
//                                                               //       BlocProvider(
//                                                               //         create: (contextA) =>
//                                                               //             p.PeopleBloc(),
//                                                               //       ),
//                                                               //       BlocProvider(
//                                                               //         create: (context) =>
//                                                               //             PostsBloc(),
//                                                               //       ),
//                                                               //     ],
//                                                               //     child: PeopleProfile(
//                                                               //         subjectID:
//                                                               //             list.user_id),
//                                                               //   );
//                                                               // }));
//                                                             },
//                                                             child: Text(
//                                                               "${list.firstname + " " + list.lastname}",
//                                                               style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold),
//                                                             ),
//                                                           ),
//                                                           subtitle:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               print(
//                                                                   list.user_id);
//                                                               // Navigator.push(
//                                                               //     context,
//                                                               //     MaterialPageRoute(
//                                                               //         builder:
//                                                               //             (context) {
//                                                               //   return MultiBlocProvider(
//                                                               //     providers: [
//                                                               //       BlocProvider(
//                                                               //         create: (contextA) =>
//                                                               //             p.PeopleBloc(),
//                                                               //       ),
//                                                               //       BlocProvider(
//                                                               //         create: (context) =>
//                                                               //             PostsBloc(),
//                                                               //       ),
//                                                               //     ],
//                                                               //     child: PeopleProfile(
//                                                               //         subjectID:
//                                                               //             list.user_id),
//                                                               //   );
//                                                               // }));
//                                                             },
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                     '${list.username}'),
//                                                                 Text(
//                                                                   list.location,
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           11),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           leading:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               // Navigator.push(
//                                                               //     context,
//                                                               //     MaterialPageRoute(
//                                                               //         builder:
//                                                               //             (context) {
//                                                               //   return MultiBlocProvider(
//                                                               //     providers: [
//                                                               //       BlocProvider(
//                                                               //         create: (contextA) =>
//                                                               //             p.PeopleBloc(),
//                                                               //       ),
//                                                               //       BlocProvider(
//                                                               //         create: (context) =>
//                                                               //             PostsBloc(),
//                                                               //       ),
//                                                               //     ],
//                                                               //     child: PeopleProfile(
//                                                               //         subjectID:
//                                                               //             list.user_id),
//                                                               //   );
//                                                               // }));
//                                                             },
//                                                             child: CircleAvatar(
//                                                               radius: 25,
//                                                               backgroundColor:
//                                                                   Colors.grey,
//                                                               child: ClipRRect(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             50),
//                                                                 child: Image
//                                                                     .network(
//                                                                   list.pic,
//                                                                   width: 50,
//                                                                   height: 50,
//                                                                   fit: BoxFit
//                                                                       .cover,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         );
//                                                       }),
//                                                 )
//                                               : SizedBox(),
//                                           _showSlideUpFor == "townhall"
//                                               ? Container(
//                                                   height: size.height - 230,
//                                                   child: ListView.builder(
//                                                     shrinkWrap: true,
//                                                     scrollDirection:
//                                                         Axis.vertical,
//                                                     itemCount:
//                                                         townhallInfo.length,
//                                                     itemBuilder:
//                                                         (context, index) {
//                                                       final section =
//                                                           townhallInfo[index]
//                                                               .section;
//                                                       final body =
//                                                           townhallInfo[index]
//                                                               .body;

//                                                       return Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .stretch,
//                                                         children: [
//                                                           section == "" ||
//                                                                   section ==
//                                                                       null
//                                                               ? SizedBox()
//                                                               : Padding(
//                                                                   padding: const EdgeInsets
//                                                                       .only(
//                                                                       top: 0,
//                                                                       bottom:
//                                                                           18.0),
//                                                                   child: Text(
//                                                                       "${section}",
//                                                                       style: TextStyle(
//                                                                           fontSize:
//                                                                               18.0,
//                                                                           fontWeight:
//                                                                               FontWeight.bold)),
//                                                                 ),
//                                                           ListView.separated(
//                                                               physics:
//                                                                   NeverScrollableScrollPhysics(),
//                                                               shrinkWrap: true,
//                                                               separatorBuilder:
//                                                                   (BuildContext
//                                                                               context,
//                                                                           int
//                                                                               index) =>
//                                                                       SizedBox(
//                                                                           height:
//                                                                               20),
//                                                               itemCount:
//                                                                   body!.length,
//                                                               itemBuilder:
//                                                                   (BuildContext
//                                                                           context,
//                                                                       int index) {
//                                                                 _isFollowList.add(body[index].show_follow !=
//                                                                             null &&
//                                                                         body[index].show_follow ==
//                                                                             "follow"
//                                                                     ? true
//                                                                     : false);

//                                                                 if (body[index]
//                                                                             .audio !=
//                                                                         null &&
//                                                                     body![index]
//                                                                             .audio !=
//                                                                         "") {
//                                                                   List<Audio>
//                                                                       audioList =
//                                                                       [
//                                                                     Audio(
//                                                                         url: body[index]
//                                                                             .audio,
//                                                                         name: body[index]
//                                                                             .body,
//                                                                         artist:
//                                                                             "Townhall",
//                                                                         duration: Duration(
//                                                                             minutes:
//                                                                                 6,
//                                                                             seconds:
//                                                                                 12),
//                                                                         icon: body[index]
//                                                                             .image,
//                                                                         album:
//                                                                             "Album 1")
//                                                                   ];
//                                                                 }
//                                                                 return Container(
//                                                                   child: Row(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       if (body[index]
//                                                                               .is_this_a_more ==
//                                                                           "yes")
//                                                                         Container(
//                                                                           child:
//                                                                               Text(
//                                                                             "More",
//                                                                             style:
//                                                                                 TextStyle(
//                                                                               color: Colors.black,
//                                                                               decoration: TextDecoration.underline,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       body[index].image == "" ||
//                                                                               body[index].image == null
//                                                                           ? Column(
//                                                                               children: [
//                                                                                 //                                               StreamBuilder<MediaItem>(
//                                                                                 // stream: AudioService.currentMediaItemStream,
//                                                                                 // builder: (_, snapshot) {
//                                                                                 //   return Text(snapshot.data?.title ?? "title");
//                                                                                 // }),
//                                                                                 // StreamBuilder<
//                                                                                 //         PlaybackState>(
//                                                                                 //     stream:
//                                                                                 //         AudioService.playbackStateStream,
//                                                                                 //     builder: (context, snapshot) {
//                                                                                 //       final playing = snapshot.data?.playing ?? false;
//                                                                                 //       if (playing)
//                                                                                 //         return ElevatedButton(
//                                                                                 //             child: Text("Pause"),
//                                                                                 //             onPressed: () {
//                                                                                 //               AudioService.pause();
//                                                                                 //             });
//                                                                                 //       else
//                                                                                 //         return ElevatedButton(
//                                                                                 //             child: Text("Play"),
//                                                                                 //             onPressed: () {

//                                                                                 //               if (AudioService.running) {
//                                                                                 //                 AudioService.play();
//                                                                                 //               } else {
//                                                                                 //                 AudioService.start(
//                                                                                 //                   backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
//                                                                                 //                 );
//                                                                                 //               }
//                                                                                 //             });
//                                                                                 //     }),
//                                                                                 // ElevatedButton(
//                                                                                 //     onPressed:
//                                                                                 //         () async {
//                                                                                 //       await AudioService.skipToNext();
//                                                                                 //     },
//                                                                                 //     child:
//                                                                                 //         Text("Next Song")),
//                                                                                 // ElevatedButton(
//                                                                                 //     onPressed:
//                                                                                 //         () async {
//                                                                                 //       await AudioService.skipToPrevious();
//                                                                                 //     },
//                                                                                 //     child:
//                                                                                 //         Text("Previous Song")),
//                                                                                 // StreamBuilder<
//                                                                                 //     Duration>(
//                                                                                 //   stream:
//                                                                                 //       AudioService.positionStream,
//                                                                                 //   builder:
//                                                                                 //       (_, snapshot) {
//                                                                                 //     final mediaState =
//                                                                                 //         snapshot.data;
//                                                                                 //     return Slider(
//                                                                                 //       value: mediaState?.inSeconds?.toDouble() ?? 0,
//                                                                                 //       min: 0,
//                                                                                 //       max: mediaItem.duration!.inSeconds.toDouble(),
//                                                                                 //       onChanged: (val) {
//                                                                                 //         AudioService.seekTo(Duration(seconds: val.toInt()));
//                                                                                 //       },
//                                                                                 //     );
//                                                                                 //   },
//                                                                                 // )
//                                                                               ],
//                                                                             )
//                                                                           : Container(
//                                                                               child: body[index].image == null
//                                                                                   ? SizedBox()
//                                                                                   : Padding(
//                                                                                       padding: const EdgeInsets.only(right: 8.0),
//                                                                                       child: GestureDetector(
//                                                                                         onTap: body[index].user_id == null || body[index].user_id == ""
//                                                                                             ? null
//                                                                                             : () {
//                                                                                                 // Navigator.push(context, MaterialPageRoute(builder: (context) {
//                                                                                                 //   return MultiBlocProvider(
//                                                                                                 //     providers: [
//                                                                                                 //       BlocProvider(
//                                                                                                 //         create: (contextA) => p.PeopleBloc(),
//                                                                                                 //       ),
//                                                                                                 //       BlocProvider(
//                                                                                                 //         create: (context) => PostsBloc(),
//                                                                                                 //       ),
//                                                                                                 //     ],
//                                                                                                 //     child: PeopleProfile(subjectID: body[index].user_id.toString()),
//                                                                                                 //   );
//                                                                                                 // }));
//                                                                                               },
//                                                                                         child: CircleAvatar(
//                                                                                           radius: 30,
//                                                                                           backgroundColor: Colors.grey,
//                                                                                           child: ClipRRect(
//                                                                                             borderRadius: BorderRadius.circular(50),
//                                                                                             child: Image.network(
//                                                                                               body[index].image.toString(),
//                                                                                               width: 55,
//                                                                                               height: 55,
//                                                                                               fit: BoxFit.cover,
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                             ),
//                                                                       Expanded(
//                                                                         child:
//                                                                             Column(
//                                                                           crossAxisAlignment:
//                                                                               CrossAxisAlignment.start,
//                                                                           mainAxisAlignment:
//                                                                               MainAxisAlignment.start,
//                                                                           children: [
//                                                                             body[index].audio != null && body[index].audio != "" && body[index].is_this_a_more == "no"
//                                                                                 ? Container(
//                                                                                     child: Column(
//                                                                                       children: [
//                                                                                         Slider(value: position.inSeconds.toDouble(), min: 0, max: duration.inSeconds.toDouble(), onChanged: (value) async {}),
//                                                                                         Row(
//                                                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                           children: [
//                                                                                             Text(formatTime(position)),
//                                                                                             Text(formatTime(duration - position))
//                                                                                           ],
//                                                                                         ),
//                                                                                         CircleAvatar(
//                                                                                             radius: 35,
//                                                                                             child: IconButton(
//                                                                                               iconSize: 50,
//                                                                                               onPressed: () async {},
//                                                                                               icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//                                                                                             ))
//                                                                                       ],
//                                                                                     ),
//                                                                                   )
//                                                                                 : body[index].is_this_a_more == "yes"
//                                                                                     ? SizedBox()
//                                                                                     : GestureDetector(
//                                                                                         onTap: body[index].user_id == null || body[index].user_id == ""
//                                                                                             ? null
//                                                                                             : () {
//                                                                                                 // Navigator.push(context, MaterialPageRoute(builder: (context) {
//                                                                                                 //   return MultiBlocProvider(
//                                                                                                 //     providers: [
//                                                                                                 //       BlocProvider(
//                                                                                                 //         create: (contextA) => p.PeopleBloc(),
//                                                                                                 //       ),
//                                                                                                 //       BlocProvider(
//                                                                                                 //         create: (context) => PostsBloc(),
//                                                                                                 //       ),
//                                                                                                 //     ],
//                                                                                                 //     child: PeopleProfile(subjectID: body[index].user_id.toString()),
//                                                                                                 //   );
//                                                                                                 // }));
//                                                                                               },
//                                                                                         child: HtmlWidget(
//                                                                                           body[index].body == null ? '' : body[index].body,
//                                                                                           onTapUrl: (url) async {
//                                                                                             return launchUrl(Uri.parse(url));
//                                                                                           },
//                                                                                         ),
//                                                                                       ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                       body[index].show_follow == "no" ||
//                                                                               body[index].show_follow == null
//                                                                           ? SizedBox()
//                                                                           : GFButton(
//                                                                               onPressed: () {
//                                                                                 setState(() {
//                                                                                   _clickedFollowID = index;
//                                                                                 });
//                                                                                 if (_isFollowList[_clickedFollowID]) {
//                                                                                   //unfollow
//                                                                                   BlocProvider.of<PostsBloc>(context).add(UnFollowEvent(followee: int.parse(body[index].user_id)));
//                                                                                   setState(() {
//                                                                                     _isFollowList[_clickedFollowID] = !_isFollowList[_clickedFollowID];
//                                                                                   });
//                                                                                 } else {
//                                                                                   //follow
//                                                                                   BlocProvider.of<PostsBloc>(context).add(FollowEvent(followee: int.parse(body[index].user_id)));
//                                                                                   setState(() {
//                                                                                     _isFollowList[_clickedFollowID] = !_isFollowList[_clickedFollowID];
//                                                                                   });
//                                                                                 }
//                                                                               },
//                                                                               text: ("${_isFollowList[index] == true ? "Unfollow" : "Follow"}"),
//                                                                               shape: GFButtonShape.pills,
//                                                                               color: _isFollowList[index] ? Colors.red : Colors.blue,
//                                                                             ),
//                                                                     ],
//                                                                   ),
//                                                                 );
//                                                               }),
//                                                           SizedBox(height: 25),
//                                                         ],
//                                                       );
//                                                     },
//                                                   ),
//                                                 )
//                                               : SizedBox(),
//                                         ],
//                                       ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             body: SafeArea(
//               child: BlocConsumer<PostsBloc, PostsState>(
//                 listener: (context, state) {
//                   // print(
//                   //     "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");
//                   //
//                   if (state is NoResultState) {
//                     print(
//                         "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");
//                     isThereResult = false;

//                     setState(() {
//                       newFeedLoader = false;
//                       isLoadingUpRequest = false;
//                       isLastDownRequest = false;
//                       isNoNetwork = false;
//                       olderLoader = false;
//                       showLikeLoader = false;
//                       loading = false;
//                       reloadTop = false;
//                     });
//                   }
//                   // if (state is LoadingState && olderLoader == false) {
//                   //   if (showLikeLoader == false) {
//                   //     loading = true;
//                   //   }
//                   //   loading = false;
//                   //   olderLoader = false;
//                   //   newLoader = false;
//                   //   reloadTop = false;
//                   //   print("P1");
//                   // }

//                   // if (state is LoadingState) {
//                   //   loading = true;
//                   // }
//                   if (state is LoadingState) {
//                     if (olderLoader) {
//                       olderLoader = true;
//                     } else if (newLoader) {
//                       newLoader = true;
//                     } else if (reloadTop) {
//                       reloadTop = true;
//                     } else {
//                       loading = true;
//                     }
//                     isNoNetwork = false;
//                     isThereResult = false;
//                   }

//                   if (state is GoToSuggestionState) {
//                     loading = false;
//                     reloadTop = false;
//                     isNoNetwork = false;
//                     Navigator.pushNamed(context, SuggestionScreen.routeName);
//                   }
//                   //Go to profile page
//                   if (state is GoToProfileState) {
//                     isNoNetwork = false;
//                     Navigator.pushNamed(context, Profile.routeName);
//                   }
//                   if (state
//                       is GoToOrganizationState) //Go to Organization suggestion page
//                   {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return BlocProvider(
//                         create: (context) => s.SuggestionBloc(),
//                         child: OrgSuggestionScreen(),
//                       );
//                     }));
//                   }
//                   if (state
//                       is GoToConfirmState) //Go to Organization suggestion page
//                   {
//                     AppSharedPreferences.removeValue(key: 'token');
//                     AppSharedPreferences.removeValue(key: 'townhallView');
//                     AppSharedPreferences.removeValue(key: 'groupID');
//                     AppSharedPreferences.removeValue(key: 'orgID');
//                     AppSharedPreferences.removeValue(key: 'orgName');
//                     AppSharedPreferences.removeValue(key: 'isLeader');
//                     AppSharedPreferences.removeValue(key: 'login');
//                     AppSharedPreferences.removeValue(key: 'dismissedVersion');
//                     Navigator.pushReplacementNamed(
//                         context, RegisterOtpScreen.routeName,
//                         arguments: state.email);
//                   }
//                   if (state is AbuseReportState) {
//                     Navigator.of(context, rootNavigator: true).pop();
//                     final snackBar = SnackBar(
//                       content: Text('Post was successfully reported'),
//                       backgroundColor: Colors.green.shade300,
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     _controllerComment.text = '';
//                   }
//                   if (state is TownhallInfoState) {
//                     setState(() {
//                       showTownhallLoader = false;
//                       townhallInfo = state.townhallResponse.data;
//                     });
//                   }
//                   if (state is LikeListState) {
//                     setState(() {
//                       showTownhallLoader = false;
//                       loading = false;
//                       likeData = state.likeResponse.data!;
//                     });
//                   }
//                   if (state is FeedState) {
//                     print("YY- Api Data: ${state.inputedData.group_id}");
//                     // if (state.inputedData.group_id.toString() ==
//                     //         groupId.toString() ||
//                     //     groupId == null ||
//                     //     groupId == "") {
//                     //   print(
//                     //       "YY- Successful GRP: ${state.inputedData.group_id.toString()}");
//                       //Navigator.pushNamed(context, SuggestionScreen.routeName);
//                       // print("P2");
//                       isLoadingUpRequest = false;
//                       isLastDownRequest = false;
//                       isNoNetwork = false;
//                       networkMsg = "";

//                       _checkVersion(newVersion, state.build_number);

//                       // canDismiss = (buildNo != null &&
//                       //         buildNo > int.parse(state.build_number))
//                       //     ? true
//                       //     : false;

//                       if (isPageFirstLoad) {
//                         setState(() {
//                           showFloatingButton =
//                               state.topFeedResponse.data![0].can_post == "yes"
//                                   ? true
//                                   : false;
//                           showResultButton = state.topFeedResponse.data![0]
//                                       .show_result_button ==
//                                   "yes"
//                               ? true
//                               : false;

//                           _topFeedIndexID = int.parse(
//                               state.topFeedResponse.data![0].townhall_id);
//                         });
//                         print("SHOW FLOATING BUTTON: ${showFloatingButton}");
//                       }
//                       if (orgName == "" || orgName == null) {
//                         setState(() {
//                           orgName = state.orgName;
//                           AppSharedPreferences.setValue(
//                               key: 'orgName', value: state.orgName);
//                         });
//                       }
//                       //if (newLoader) {
//                       setState(() {
//                         showLikeLoader = false;
//                         newFeedLoader = false;
//                         likeSubjectID = "";
//                         //first_post_id = state.feedResponse[0].post_id;
//                         first_post_id = state.feedResponse.length < 1
//                             ? ''
//                             : state.feedResponse[0].post_id;
//                         loading = false;
//                         olderLoader = false;
//                         newLoader = false;
//                         reloadTop = false;
//                       });
//                       //}

//                       if (state.feedResponse.length > 0) {
//                         // if (isFirstFeedRequest && isCachedDataAvailable) {
//                         //   newDataList = state.feedResponse;

//                         //   newDataFirstPostID = _getFirstWhere(newDataList);
//                         //   cachedDataFirstPostID = _getFirstWhere(data);
//                         //   print(
//                         //       "NewPostID: ${newDataFirstPostID} CachedPostID: ${cachedDataFirstPostID}");

//                         //   setState(() {
//                         //     isFirstFeedRequest = false;
//                         //   });
//                         // } else {
//                         setState(() {
//                           data = state.feedResponse;
//                         });

//                         print(
//                             "Setting cache orgID: ${state.orgID.toString()} , Townh ID: ${_topFeedIndexID.toString()}");
//                         AppSharedPreferences.setValue(
//                             key:
//                                 "page_feed_${state.orgID.toString()}_${_topFeedIndexID.toString()}",
//                             value: jsonEncode(state.feedResponse));
//                         AppSharedPreferences.setValue(
//                             key:
//                                 "page_feed_top_${state.orgID.toString()}_${_topFeedIndexID.toString()}",
//                             value: jsonEncode(state.topFeedResponse.data));
//                         //}

//                         isThereResult = true;
//                         isNoNetwork = false;
//                       }
//                       print(
//                           "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");

//                       topFeed = state.topFeedResponse.data!;

//                       setState(() {
//                         olderLoader = false;
//                         loading = false;
//                         newLoader = false;
//                         // isThereResult = true;
//                         reloadTop = false;
//                       });

//                       if (groupId.isEmpty) {
//                         if (topFeed.isNotEmpty) {
//                           groupId = topFeed[0].townhall_id.toString();
//                         }
//                       }
//                     }
//                   }
//                   if (state is NoPartyState) {
//                     setState(() {
//                       isNoParty = true;

//                       olderLoader = false;
//                       loading = false;
//                       newLoader = false;

//                       reloadTop = false;
//                     });
//                     isThereResult = true;
//                     isNoNetwork = false;
//                   }
//                   if (state is LikeState) {
//                     print("i am inside like state");
//                     //print("Before like: ${_isLikeList[_clickedID]}");
//                     setState(() {
//                       isLiked = true;
//                       loading = false;
//                       isNoNetwork = false;
//                       olderLoader = false;
//                       reloadTop = false;
//                       likeSubjectID = "";
//                     });
//                     //print("After like: ${_isLikeList[_clickedID]}");
//                     print(state.like.msg);
//                     print(state.like.status);

//                     // BlocProvider.of<PostsBloc>(context).add(
//                     //   FeedEvent(
//                     //     feedRequest: FeedRequest(
//                     //         last_post_id: '',
//                     //         group_id: groupId,
//                     //         org_id: orgId,
//                     //         post_id: '',
//                     //         limit: limit,
//                     //         older_or_newer: '',
//                     //         page_owner: ''),
//                     //   ),
//                     // );
//                   }
//                   if (state is FollowState) {
//                     print("Successfully followed");
//                   }
//                   if (state is UnFollowState) {
//                     print("successfully unfollowed");
//                   }
//                   if (state is DeleteFeedState) {
//                     setState(() {
//                       loading = false;
//                       reloadTop = false;
//                       isNoNetwork = false;
//                     });

//                     print(state.deleteFeedResponse.msg);
//                     print(state.deleteFeedResponse.status);
//                     var deviceToken = getDeviceToken();
//                     BlocProvider.of<PostsBloc>(context).add(
//                       FeedEvent(
//                         feedRequest: FeedRequest(
//                             skipOnboarding: false,
//                             skipTopFeed: false,
//                             isFirstFeedRequest: false,
//                             last_post_id: '',
//                             group_id: groupId,
//                             org_id: orgId,
//                             page: '',
//                             limit: limit,
//                             older_or_newer: '',
//                             page_owner: '',
//                             device_token: deviceToken,
//                             device_type: _deviceType),
//                       ),
//                     );
//                   }

//                   if (state is UnLikeState) {
//                     print("i am inside unlike state");
//                     setState(() {
//                       likeSubjectID = "";
//                       olderLoader = false;
//                       loading = false;
//                       isLiked = false;
//                       reloadTop = false;
//                       isNoNetwork = false;
//                     });

//                     print(state.unlike.msg);
//                     print(state.unlike.status);
//                     // BlocProvider.of<PostsBloc>(context).add(
//                     //   FeedEvent(
//                     //     feedRequest: FeedRequest(
//                     //         last_post_id: '',
//                     //         group_id: groupId,
//                     //         org_id: orgId,
//                     //         post_id: '',
//                     //         limit: limit,
//                     //         older_or_newer: '',
//                     //         page_owner: ''),
//                     //   ),
//                     // );
//                   }
//                   if (state is ErrorState) {
//                     setState(() {
//                       newFeedLoader = false;
//                       isLoadingUpRequest = false;
//                       showLikeLoader = false;
//                       likeSubjectID = "";
//                       isLastDownRequest = false;
//                       olderLoader = false;
//                       loading = false;
//                       isNoNetwork = false;
//                     });
//                     print(state.message);
//                     // if (_subjectID != -1)
//                     // {
//                     //   _isLiked(int.parse(item.post_id))==true
//                     //   _isLikeList[_clickedID] = !_isLikeList[_clickedID];
//                     // }
//                     // final snackBar =
//                     //     SnackBar(content: Text(state.message.toString()));
//                     // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   }
//                   if (state is NetworkState) {
//                     setState(() {
//                       newFeedLoader = false;
//                       isLoadingUpRequest = false;
//                       showLikeLoader = false;
//                       likeSubjectID = "";
//                       isLastDownRequest = false;
//                       isNoNetwork = true;
//                       networkMsg = state.message!;

//                       olderLoader = false;
//                       loading = false;
//                       reloadTop = false;
//                       likeSubjectID = "";
//                     });
//                     isThereResult = false;
//                     // final snackBar = SnackBar(
//                     //     backgroundColor: Color(0xFFcf5555),
//                     //     content: Text(state.message.toString()));
//                     // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   }
//                   if (state is BlockUserState) {
//                     final snackBar = SnackBar(
//                         backgroundColor: Color.fromARGB(255, 85, 207, 158),
//                         content: Text('User was successfully blocked'));
//                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   }
//                 },
//                 builder: (context, state) {
//                   var deviceToken = getDeviceToken();
//                   return Column(
//                     children: [
//                       SizedBox(
//                         height: 1.0,
//                       ),
//                       reloadTop
//                           ? SizedBox(width: 0)
//                           : Column(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () async {
//                                     //clear
//                                     print("ID: ${groupId}  ${orgId}");

//                                     SharedPreferences prefs =
//                                         await SharedPreferences.getInstance();
//                                     Set<String> keys = prefs.getKeys();
//                                     List<String> filteredKeys = keys
//                                         .where(
//                                             (key) => key.contains("page_feed_"))
//                                         .toList();

//                                     if (filteredKeys.length > 0) {
//                                       for (var i = 0;
//                                           i < filteredKeys.length;
//                                           i++) {
//                                         await AppSharedPreferences.removeValue(
//                                             key: '${filteredKeys[i]}');
//                                         print("Key R: ${filteredKeys[i]}");
//                                       }
//                                     }
//                                     print(filteredKeys);
//                                     // print(
//                                     //     "Keys that contain 'page_feed_': $filteredKeys");
//                                     Navigator.push(context,
//                                         MaterialPageRoute(builder: (context) {
//                                       return BlocProvider(
//                                         create: (context) =>
//                                             o.OrganizationBloc(),
//                                         child: OrganizationScreen(),
//                                       );
//                                     }));
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.only(
//                                         left: 20.0, right: 6.0, top: 2.0),
//                                     height: 50.0,
//                                     //width: double.infinity,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             ImageIcon(
//                                               AssetImage(
//                                                   "images/icon_blue.png"),
//                                               color: Colors.blue,
//                                               size: 20.0,
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             orgName == null
//                                                 ? SizedBox()
//                                                 : Container(
//                                                     height: 30,
//                                                     //width: 120,
//                                                     padding: EdgeInsets.only(
//                                                         left: 5),
//                                                     decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                         color: Colors.blue,
//                                                         width: 1,
//                                                       ),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10),
//                                                     ),
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           "${orgName == null ? '' : _substring(orgName.toString(), 10)}",
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.blue),
//                                                         ),
//                                                         SizedBox(
//                                                           width: 25,
//                                                           child: IconButton(
//                                                             padding:
//                                                                 EdgeInsets.only(
//                                                                     bottom: 3,
//                                                                     right:
//                                                                         20.0),
//                                                             onPressed:
//                                                                 () async {
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return BlocProvider(
//                                                                   create: (context) =>
//                                                                       o.OrganizationBloc(),
//                                                                   child:
//                                                                       OrganizationScreen(),
//                                                                 );
//                                                               }));
//                                                             },
//                                                             iconSize: 20,
//                                                             icon: Icon(
//                                                               Icons
//                                                                   .keyboard_arrow_down,
//                                                               color:
//                                                                   Colors.blue,
//                                                               //size: 30,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) {
//                                                   return BlocProvider(
//                                                     create: (context) =>
//                                                         a.AuthBloc(),
//                                                     child: Settings(),
//                                                   );
//                                                 }));
//                                               },
//                                               child: Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 8.0, right: 8.0),
//                                                 child: CircleAvatar(
//                                                   radius: 15,
//                                                   backgroundColor:
//                                                       Colors.lightBlue,
//                                                   child: ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             25),
//                                                     child: Image.network(
//                                                       profileImage == ""
//                                                           ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
//                                                           : profileImage,
//                                                       width: 55,
//                                                       height: 55,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   //starting how  of reps
//                                   height: 120.0,
//                                   width: double.infinity,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     // Let the ListView know how many items it needs to build.
//                                     itemCount: topFeed.length,
//                                     // Provide a builder function. This is where the magic happens.
//                                     // Convert each item into a widget based on the type of item it is.
//                                     itemBuilder: (context, index) {
//                                       final item = topFeed[index];

//                                       if (index == 0) {}
//                                       return GestureDetector(
//                                         onTap: () async {
//                                           setState(() {
//                                             data =
//                                                 []; // I can comment if incase it later post an issue in future
//                                             print(
//                                                 "YY- Last Tapped: ${item.townhall_id.toString()}");
//                                             if (data.length > 0) {
//                                               _scrollController.jumpTo(0);
//                                             }
//                                             isPageFirstLoad = false;
//                                             showFloatingButton =
//                                                 item.can_post == "yes"
//                                                     ? true
//                                                     : false;
//                                             showResultButton =
//                                                 item.show_result_button == 'yes'
//                                                     ? true
//                                                     : false;
//                                             _topFeedIndexID =
//                                                 int.parse(item.townhall_id);

//                                             // _topFeedIndexID = item.townhall_id
//                                             //         .toString() ==
//                                             //     topFeed[0]
//                                             //         .townhall_id
//                                             //         .toString()
//                                             // ? 0
//                                             // : int.parse(item.townhall_id);
//                                           });
//                                           //onTap(item);

//                                           last_post_id = '';
//                                           print(
//                                               "TEST PRINT: ${groupId == item.townhall_id}  ${orgId == item.org_id} ${item.can_show_townhall_info == "yes"}");
//                                           _getCachedFeedData(
//                                               int.parse(item.townhall_id));
//                                           _getCachedTopData(
//                                               int.parse(item.townhall_id));
//                                           int townID = topFeed[0].townhall_id ==
//                                                   item.townhall_id
//                                               ? 0
//                                               : int.parse(item.townhall_id);
//                                           print(
//                                               "TwnID: ${townID} ORG: ${orgId}");

//                                           setState(() {
//                                             loading =
//                                                 data.length < 1 ? true : false;
//                                             olderLoader =
//                                                 data.length < 1 ? true : false;
//                                           });

//                                           if (groupId == item.townhall_id &&
//                                               orgId == item.org_id &&
//                                               item.can_show_townhall_info ==
//                                                   "yes") {
//                                             _pc.open();

//                                             setState(() {
//                                               _slideUpTitle = "Townhall Info";
//                                               _showSlideUpFor = "townhall";
//                                               showTownhallLoader = true;
//                                               showSlideUpPanel = true;
//                                               loading = false;
//                                             });

//                                             BlocProvider.of<PostsBloc>(context)
//                                                 .add(GetTownhallInfoEvent(
//                                                     townhall_id: groupId,
//                                                     org_id: orgId,
//                                                     is_this_a_more: 'no'));
//                                           } else {
//                                             setState(() {
//                                               groupId =
//                                                   item.townhall_id.toString();
//                                               isFirstFeedRequest = true;
//                                               newList.add(groupId);
//                                               newFeedLoader = false;
//                                               newDataList = [];
//                                               loading = isCachedDataAvailable
//                                                   ? false
//                                                   : true;
//                                               //data = [];
//                                             });
//                                             print("I'm loading: ${loading}");
//                                             print(
//                                                 "Decision: ${isCachedDataAvailable}");
//                                             if (isCachedDataAvailable) {
//                                               Future.delayed(
//                                                   const Duration(seconds: 0),
//                                                   () {
//                                                 setState(() {
//                                                   newFeedLoader = true;
//                                                   loading = false;
//                                                 });
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 loading = true;
//                                                 olderLoader = false;
//                                               });
//                                             }
//                                             await AppSharedPreferences.setValue(
//                                                 key: 'groupID', value: groupId);
//                                             firstTimeLoading = true;

//                                             BlocProvider.of<PostsBloc>(context)
//                                                 .add(
//                                               FeedEvent(
//                                                 feedRequest: FeedRequest(
//                                                     skipOnboarding: false,
//                                                     skipTopFeed: false,
//                                                     isFirstFeedRequest: true,
//                                                     last_post_id: last_post_id,
//                                                     group_id: item.townhall_id
//                                                         .toString(),
//                                                     org_id: orgId,
//                                                     page: '',
//                                                     limit: limit,
//                                                     older_or_newer:
//                                                         older_or_newer,
//                                                     page_owner: '',
//                                                     device_token: deviceToken,
//                                                     device_type: _deviceType),
//                                               ),
//                                             );
//                                           }
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             children: [
//                                               Stack(
//                                                 children: [
//                                                   CircleAvatar(
//                                                     radius: 30,
//                                                     backgroundColor: groupId ==
//                                                             item.townhall_id
//                                                                 .toString()
//                                                         ? Colors.lightBlue
//                                                         : Colors.grey,
//                                                     child: ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               50),
//                                                       child: Image.network(
//                                                         item.rep_picture_mid
//                                                                 .toString()
//                                                                 .isEmpty
//                                                             ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
//                                                             : item
//                                                                 .rep_picture_mid
//                                                                 .toString(),
//                                                         width: 55,
//                                                         height: 55,
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   groupId ==
//                                                           item.townhall_id
//                                                               .toString()
//                                                       ? Positioned(
//                                                           bottom: 40,
//                                                           right: 1,
//                                                           child: Container(
//                                                             width: 20,
//                                                             height: 20,
//                                                             child: ImageIcon(
//                                                               AssetImage(
//                                                                   'images/info.png'),
//                                                               size: 25,
//                                                               color:
//                                                                   Colors.white,
//                                                             ),
//                                                             decoration: BoxDecoration(
//                                                                 color: Colors
//                                                                     .lightBlue,
//                                                                 shape: BoxShape
//                                                                     .circle),
//                                                           )

//                                                           // SizedBox(
//                                                           //   width: 25,
//                                                           //   child: IconButton(
//                                                           //     iconSize: 35,
//                                                           //     color: Colors.red,
//                                                           //     icon: Icon(Typicons.info),
//                                                           //     onPressed: () {
//                                                           //       debugPrint(
//                                                           //           "debug print");
//                                                           //     }, // icon user
//                                                           //   ),
//                                                           // ),
//                                                           )
//                                                       : SizedBox(),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(4.0),
//                                                 child: Column(
//                                                   children: [
//                                                     Text(
//                                                       '${item.townhall_display_name.toString()}',
//                                                       style: TextStyle(
//                                                         fontWeight: groupId ==
//                                                                 item.townhall_id
//                                                                     .toString()
//                                                             ? FontWeight.w800
//                                                             : null,
//                                                         color: groupId ==
//                                                                 item.townhall_id
//                                                                     .toString()
//                                                             ? Colors.lightBlue
//                                                             : null,
//                                                       ),
//                                                     ),
//                                                     item.member_count == null ||
//                                                             item.member_count ==
//                                                                 ""
//                                                         ? SizedBox()
//                                                         : Text(
//                                                             "(${NumberFormat.compact().format(item.member_count)})",
//                                                             style: TextStyle(
//                                                               fontSize: 12,
//                                                               color: groupId ==
//                                                                       item.townhall_id
//                                                                           .toString()
//                                                                   ? Colors
//                                                                       .lightBlue
//                                                                   : Colors.grey,
//                                                             ),
//                                                           )
//                                                   ],
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ), //ending of rep
//                               ],
//                             ),
//                       if (older_or_newer == "" &&
//                           loading == false &&
//                           data.length == 0 &&
//                           isNoNetwork == true)
//                         GestureDetector(
//                           onTap: () {
//                             BlocProvider.of<PostsBloc>(context).add(
//                               FeedEvent(
//                                 feedRequest: FeedRequest(
//                                     skipOnboarding: false,
//                                     skipTopFeed: false,
//                                     isFirstFeedRequest: false,
//                                     last_post_id: last_post_id,
//                                     group_id: groupId,
//                                     org_id: orgId,
//                                     page: '',
//                                     limit: limit,
//                                     older_or_newer: older_or_newer,
//                                     page_owner: '',
//                                     device_token: deviceToken,
//                                     device_type: _deviceType),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             alignment: Alignment.center,
//                             margin: EdgeInsets.only(top: 110),
//                             child: Center(
//                               child: Column(
//                                 children: [
//                                   Image.asset(
//                                     'images/network.png',
//                                     width: 150,
//                                     height: 150,
//                                   ),
//                                   Text(networkMsg),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                       if (newFeedLoader)
//                         Center(
//                           child: Container(
//                             width: 40.0,
//                             height: 40.0,
//                             child: SpinKitCircle(
//                               color: Colors.blue,
//                               size: 25.0,
//                             ),
//                           ),
//                         ),
//                       if (older_or_newer == "" &&
//                           loading == false &&
//                           data.length == 0 &&
//                           isNoNetwork == false)
//                         GestureDetector(
//                           onTap: (() async {
//                             await Navigator.pushNamed(
//                                     context, CreatePost.routeName,
//                                     arguments: groupId)
//                                 .then((result) {
//                               if (result == 'refresh') {
//                                 setState(() {
//                                   loading = false;
//                                   olderLoader = false;
//                                 });
//                                 BlocProvider.of<PostsBloc>(context).add(
//                                   FeedEvent(
//                                     feedRequest: FeedRequest(
//                                         skipOnboarding: false,
//                                         skipTopFeed: false,
//                                         isFirstFeedRequest: false,
//                                         last_post_id: '',
//                                         group_id: groupId,
//                                         org_id: orgId,
//                                         page: '',
//                                         limit: limit,
//                                         older_or_newer: '',
//                                         page_owner: '',
//                                         device_token: deviceToken,
//                                         device_type: _deviceType),
//                                   ),
//                                 );
//                               }
//                             });
//                           }),
//                           child: Container(
//                             alignment: Alignment.center,
//                             margin: EdgeInsets.only(top: 120),
//                             child: Center(
//                               child: Column(
//                                 children: [
//                                   //Image.asset('images/nopost.svg'),
//                                   SvgPicture.asset(
//                                     'images/nopost.svg',
//                                     width: 130,
//                                     height: 130,
//                                   ),
//                                   Text("Start the conversation"),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                       if (loading && olderLoader == false)
//                         Center(
//                           child: Container(
//                             width: 80.0,
//                             height: 80.0,
//                             child: SpinKitCircle(
//                               color: Colors.blue,
//                               size: 50.0,
//                             ),
//                           ),
//                         ),
//                       if (data.length > 0) //feeds start
//                         Form(
//                           key: _formKey,
//                           child: Expanded(
//                             child: loading
//                                 ? SizedBox(height: 1)
//                                 : Stack(
//                                     children: [
//                                       ListView.builder(
//                                         padding: EdgeInsets.only(bottom: 80),
//                                         controller: _scrollController,
//                                         //itemExtent: 20,
//                                         // Let the ListView know how many items it needs to build.
//                                         itemCount: isThereResult
//                                             ? data.length + 1
//                                             : data.length,
//                                         // Provide a builder function. This is where the magic happens.
//                                         // Convert each item into a widget based on the type of item it is.

//                                         itemBuilder: (context, index) {
//                                           if (index == data.length) {
//                                             isLastDownRequest = index < 20
//                                                 ? true
//                                                 : false; //This is the last down request. No more data to load again.
//                                             return Container(
//                                               width: 80.0,
//                                               height: 80.0,
//                                               child: data.length == 1
//                                                   ? SizedBox()
//                                                   : Container(
//                                                       child: index < 20
//                                                           ? null
//                                                           : SpinKitCircle(
//                                                               color:
//                                                                   Colors.blue,
//                                                               size: 30.0,
//                                                             ),
//                                                     ),
//                                             );
//                                           }
//                                           if (last_post_id.isEmpty ||
//                                               newLoader) {
//                                             first_post_id = data[0].post_id;
//                                           }
//                                           final item = data[index];
//                                           List<dynamic> imageList = [];
//                                           last_post_id = item.post_id;
//                                           print(
//                                               "Status: ${_isLiked(int.parse(item.post_id))}");
//                                           bool status = item.is_liked == 'yes'
//                                               ? true
//                                               : false;
//                                           _updateLike(
//                                               int.parse(item.post_id), status);
//                                           //print("My Keys: ${index}");
//                                           //print("Last Post ID: ${last_post_id}");
//                                           if (item.post_images != null) {
//                                             // print("My first post: " +
//                                             //     data[0].post_id);
//                                             for (FeedImagesData image
//                                                 in item.post_images!) {
//                                               imageList.add(image.name);
//                                             }
//                                           }

//                                           // DateTime postUTCTime = new DateFormat(
//                                           //         "yyyy-MM-dd hh:mm:ss")
//                                           //     .parse(item.post_updated_time_utc);
//                                           // DateTime postUTCTime =
//                                           //     DateFormat("yyyy-MM-dd hh:mm:ss")
//                                           //         .parse(item.post_updated_time);
//                                           // "2023-02-13T08:15:30-05:00";
//                                           // DateTime startTime =
//                                           //     new DateFormat("yyyy-MM-dd hh:mm:ss")
//                                           //         .parse(item.post_updated_time);
//                                           DateTime currentTime =
//                                               new DateTime.now();
//                                           String videoUrl =
//                                               "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

//                                           return item.can_delete == 'no'
//                                               ? Column(
//                                                   children: [
//                                                     Container(
//                                                       color:
//                                                           item.noticeboard_msg ==
//                                                                   "yes"
//                                                               ? Color(
//                                                                   0xffCCE9FD)
//                                                               : null,
//                                                       child: Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .fromLTRB(
//                                                                     9.0,
//                                                                     9.0,
//                                                                     6.0,
//                                                                     8.0),
//                                                             child:
//                                                                 GestureDetector(
//                                                               onTap: () {
//                                                                 // Navigator.push(
//                                                                 //     context,
//                                                                 //     MaterialPageRoute(
//                                                                 //         builder:
//                                                                 //             (context) {
//                                                                 //   return MultiBlocProvider(
//                                                                 //     providers: [
//                                                                 //       BlocProvider(
//                                                                 //         create: (contextA) =>
//                                                                 //             p.PeopleBloc(),
//                                                                 //       ),
//                                                                 //       BlocProvider(
//                                                                 //         create: (context) =>
//                                                                 //             PostsBloc(),
//                                                                 //       ),
//                                                                 //     ],
//                                                                 //     child: PeopleProfile(
//                                                                 //         subjectID:
//                                                                 //             item.posted_by),
//                                                                 //   );
//                                                                 // }));
//                                                               },
//                                                               child:
//                                                                   CircleAvatar(
//                                                                 radius: 30,
//                                                                 backgroundColor:
//                                                                     Colors.grey,
//                                                                 child:
//                                                                     ClipRRect(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               50),
//                                                                   child: Image
//                                                                       .network(
//                                                                     item.post_profile_pics,
//                                                                     width: 55,
//                                                                     height: 55,
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           Expanded(
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(1.0),
//                                                               child: Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .start,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .stretch,
//                                                                 children: [
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                         .only(
//                                                                         top:
//                                                                             4.0,
//                                                                         bottom:
//                                                                             1.0,
//                                                                         left:
//                                                                             4.0,
//                                                                         right:
//                                                                             4.0),
//                                                                     child: Row(
//                                                                       children: [
//                                                                         GestureDetector(
//                                                                           onTap:
//                                                                               () {
//                                                                             // groupId = item
//                                                                             //     .post_group_id
//                                                                             //     .toString();
//                                                                             // BlocProvider.of<PostsBloc>(context)
//                                                                             //     .add(
//                                                                             //   FeedEvent(
//                                                                             //     feedRequest: FeedRequest(last_post_id: last_post_id, group_id: item.post_group_id.toString(), post_id: '', limit: limit, older_or_newer: older_or_newer, page_owner: ''),

//                                                                             //   ),

//                                                                             // );
//                                                                             // Navigator.push(context,
//                                                                             //     MaterialPageRoute(builder: (context) {
//                                                                             //   return MultiBlocProvider(
//                                                                             //     providers: [
//                                                                             //       BlocProvider(
//                                                                             //         create: (contextA) => p.PeopleBloc(),
//                                                                             //       ),
//                                                                             //       BlocProvider(
//                                                                             //         create: (context) => PostsBloc(),
//                                                                             //       ),
//                                                                             //     ],
//                                                                             //     child: PeopleProfile(subjectID: item.posted_by),
//                                                                             //   );
//                                                                             // }));
//                                                                           },
//                                                                           child:
//                                                                               Text(
//                                                                             _substring(item.post_update_by,
//                                                                                 20),
//                                                                             style:
//                                                                                 TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                                                                           ),
//                                                                         ),
//                                                                         Text(
//                                                                           '. ' +
//                                                                               // timeago.format(
//                                                                               //     startTime,
//                                                                               //     locale: 'en_short'),
//                                                                               _getTimeAgo(DateTime.parse(item.post_updated_time)),
//                                                                           style:
//                                                                               TextStyle(color: Colors.grey),
//                                                                         ),
//                                                                         //Spacer(),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   Column(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       item.designation == null ||
//                                                                               item.designation == ""
//                                                                           ? SizedBox()
//                                                                           : Padding(
//                                                                               padding: const EdgeInsets.only(bottom: 4.0, right: 4.0, left: 4.0),
//                                                                               child: Row(
//                                                                                 children: [
//                                                                                   Container(
//                                                                                     padding: EdgeInsets.only(left: 7, right: 7),
//                                                                                     decoration: BoxDecoration(
//                                                                                         color: Colors.lightBlue, //0xffCCE9FD
//                                                                                         borderRadius: BorderRadius.all(Radius.circular(8))),
//                                                                                     alignment: Alignment.centerLeft,
//                                                                                     height: 20,
//                                                                                     child: Text(
//                                                                                       item.designation,
//                                                                                       style: TextStyle(color: Colors.white, fontSize: 12.0),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                       Align(
//                                                                         alignment: item.post_alignment == "ltr" ||
//                                                                                 item.post_alignment == null ||
//                                                                                 item.post_alignment == ""
//                                                                             ? Alignment.topLeft
//                                                                             : Alignment.topRight,
//                                                                         child:
//                                                                             InkWell(
//                                                                           onLongPress:
//                                                                               () {
//                                                                             FlutterClipboard.copy(item.post_message).then(
//                                                                               (value) => GFToast.showToast('Copied', context,
//                                                                                   toastPosition: GFToastPosition.BOTTOM,
//                                                                                   textStyle: TextStyle(fontSize: 15, color: GFColors.DARK),
//                                                                                   backgroundColor: GFColors.LIGHT,
//                                                                                   trailing: Icon(
//                                                                                     Icons.notifications,
//                                                                                     color: GFColors.SUCCESS,
//                                                                                   )),
//                                                                             );
//                                                                           },
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 const EdgeInsets.all(04.0),
//                                                                             child: Linkify(
//                                                                                 options: LinkifyOptions(humanize: false),
//                                                                                 onOpen: _onOpen,
//                                                                                 text: item.post_message,
//                                                                                 style: TextStyle(fontSize: 15)),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                   if (imageList
//                                                                           .length >
//                                                                       0)
//                                                                     ImageSwipe(
//                                                                         imageList:
//                                                                             imageList),
//                                                                   // VideoBuild(
//                                                                   //     videoPlayerController:
//                                                                   //         VideoPlayerController.network(
//                                                                   //             videoUrl),
//                                                                   //     looping:
//                                                                   //         true,
//                                                                   //     autoplay:
//                                                                   //         false),
//                                                                   Row(
//                                                                     children: [
//                                                                       IconButton(
//                                                                         icon:
//                                                                             Icon(
//                                                                           Icons
//                                                                               .messenger_outline,
//                                                                           color:
//                                                                               Colors.grey,
//                                                                         ),
//                                                                         onPressed:
//                                                                             () async {
//                                                                           await Navigator.pushNamed(context, Comments.routeName, arguments: item)
//                                                                               .then((result) {
//                                                                             if (result ==
//                                                                                 'refresh') {
//                                                                               BlocProvider.of<PostsBloc>(context).add(
//                                                                                 FeedEvent(
//                                                                                   feedRequest: FeedRequest(skipOnboarding: false, skipTopFeed: false, isFirstFeedRequest: false, last_post_id: '', group_id: groupId, org_id: orgId, page: '', limit: limit, older_or_newer: '', page_owner: '', device_token: deviceToken, device_type: _deviceType),
//                                                                                 ),
//                                                                               );
//                                                                             }
//                                                                           });
//                                                                         },
//                                                                       ),
//                                                                       Text(
//                                                                         numberFormat(
//                                                                             item.comment_count),
//                                                                         style: TextStyle(
//                                                                             color:
//                                                                                 Colors.grey),
//                                                                       ),
//                                                                       // Text(
//                                                                       //     "${_likeList['']}"),
//                                                                       IconButton(
//                                                                         icon:
//                                                                             Icon(
//                                                                           _isLiked(int.parse(item.post_id)) == true
//                                                                               ? Icons.favorite
//                                                                               : Icons.favorite_outline,
//                                                                           color: _isLiked(int.parse(item.post_id)) == true
//                                                                               ? Colors.red
//                                                                               : Colors.grey,
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {
//                                                                           setState(
//                                                                               () {
//                                                                             _clickedID =
//                                                                                 index;
//                                                                             likeSubjectID =
//                                                                                 item.post_id;
//                                                                           });

//                                                                           if (_isLiked(int.parse(item.post_id)) ==
//                                                                               true) {
//                                                                             clickedPostID =
//                                                                                 item.post_id;
//                                                                             setState(() {
//                                                                               _updateLike(int.parse(item.post_id), true);
//                                                                             });
//                                                                             BlocProvider.of<PostsBloc>(context).add(
//                                                                               UnLikePostEvent(post_id: item.post_id),
//                                                                             );
//                                                                           } else {
//                                                                             clickedPostID =
//                                                                                 item.post_id;
//                                                                             BlocProvider.of<PostsBloc>(context).add(
//                                                                               LikePostEvent(post_id: item.post_id),
//                                                                             );
//                                                                             setState(() {
//                                                                               _updateLike(int.parse(item.post_id), false);
//                                                                             });
//                                                                           }
//                                                                         },
//                                                                       ),
//                                                                       GestureDetector(
//                                                                         onTap: item.like_count ==
//                                                                                 0
//                                                                             ? null
//                                                                             : () {
//                                                                                 BlocProvider.of<PostsBloc>(context).add(GetLikesEvent(
//                                                                                   post_id: item.post_id,
//                                                                                 ));
//                                                                                 _pc.open();
//                                                                                 setState(() {
//                                                                                   _slideUpTitle = "Likes(${numberFormat(item.like_count)})";
//                                                                                   _showSlideUpFor = "likes";

//                                                                                   showTownhallLoader = true;
//                                                                                   showSlideUpPanel = true;
//                                                                                   loading = false;
//                                                                                 });
//                                                                               },
//                                                                         child: Text(
//                                                                             numberFormat(item
//                                                                                 .like_count),
//                                                                             style:
//                                                                                 TextStyle(color: Colors.grey)),
//                                                                       ),
//                                                                       IconButton(
//                                                                         icon:
//                                                                             Icon(
//                                                                           Icons
//                                                                               .share,
//                                                                           color:
//                                                                               Colors.grey,
//                                                                         ),
//                                                                         onPressed:
//                                                                             () async {
//                                                                           share(
//                                                                             item.sharelink,
//                                                                             '',
//                                                                           );
//                                                                         },
//                                                                       ),
//                                                                     ],
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           SizedBox(
//                                                             height: 28,
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       top: 8),
//                                                               child:
//                                                                   PopupMenuButton(
//                                                                 icon: ImageIcon(
//                                                                   AssetImage(
//                                                                       "images/dots.png"),
//                                                                   color: Colors
//                                                                       .grey,
//                                                                   size: 20.0,
//                                                                 ),
//                                                                 onSelected:
//                                                                     (choice) {
//                                                                   if (choice ==
//                                                                       'Report') {
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder:
//                                                                           (BuildContext
//                                                                               contextTwo) {
//                                                                         return AlertDialog(
//                                                                           scrollable:
//                                                                               true,
//                                                                           title:
//                                                                               Text('Report'),
//                                                                           content:
//                                                                               Container(
//                                                                             height:
//                                                                                 175.0,
//                                                                             width:
//                                                                                 350.0,
//                                                                             child:
//                                                                                 Column(
//                                                                               children: [
//                                                                                 Container(
//                                                                                   child: SizedBox(
//                                                                                     child: TextFormField(
//                                                                                       maxLength: 300,
//                                                                                       maxLines: 3,
//                                                                                       minLines: 1,
//                                                                                       keyboardType: TextInputType.text,
//                                                                                       decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), labelText: 'Comment', hintText: 'Enter Comment', contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
//                                                                                       controller: _controllerComment,
//                                                                                       validator: (value) {
//                                                                                         if (value == null || value.isEmpty) {
//                                                                                           return 'Please Enter Comment';
//                                                                                           final snackBar = SnackBar(
//                                                                                             content: Text('Please Enter Comment'),
//                                                                                             backgroundColor: Colors.green.shade300,
//                                                                                           );
//                                                                                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                                                         }
//                                                                                         return null;
//                                                                                       },
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                                 SizedBox(
//                                                                                   height: 2.0,
//                                                                                 ),
//                                                                                 SizedBox(
//                                                                                   height: 50,
//                                                                                   child: ElevatedButton(
//                                                                                     style: raisedButtonStyleGreen,
//                                                                                     onPressed: () {
//                                                                                       if (_formKey.currentState!.validate()) {
//                                                                                         BlocProvider.of<PostsBloc>(context).add(
//                                                                                           ReportAbuseEvent(comment: _controllerComment.text, post_id: item.post_id, reported: item.posted_by),
//                                                                                         );
//                                                                                       }
//                                                                                     },
//                                                                                     child: Row(
//                                                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                                                       children: [
//                                                                                         const Text(
//                                                                                           'Submit',
//                                                                                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                                                                                         ),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         );
//                                                                       },
//                                                                     );
//                                                                   } else if (choice ==
//                                                                       'Block') {
//                                                                     BlocProvider.of<PostsBloc>(
//                                                                             context)
//                                                                         .add(
//                                                                       BlockUserEvent(
//                                                                           subjectID: item
//                                                                               .posted_by,
//                                                                           req_type:
//                                                                               'block'),
//                                                                     );
//                                                                   }
//                                                                 },
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .zero,
//                                                                 itemBuilder:
//                                                                     (BuildContext
//                                                                         context) {
//                                                                   return [
//                                                                     'Report',
//                                                                     'Block'
//                                                                   ].map((String
//                                                                       choice) {
//                                                                     return PopupMenuItem<
//                                                                         String>(
//                                                                       value:
//                                                                           choice,
//                                                                       child: Text(
//                                                                           choice),
//                                                                     );
//                                                                   }).toList();
//                                                                 },
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           Divider(),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Divider(),
//                                                   ],
//                                                 )
//                                               : Slidable(
//                                                   actionPane:
//                                                       SlidableDrawerActionPane(),
//                                                   actionExtentRatio: 0.25,
//                                                   child: Container(
//                                                     child: Column(
//                                                       children: [
//                                                         Container(
//                                                           color:
//                                                               item.noticeboard_msg ==
//                                                                       "yes"
//                                                                   ? Color(
//                                                                       0xffCCE9FD)
//                                                                   : null,
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .fromLTRB(
//                                                                         9.0,
//                                                                         9.0,
//                                                                         6.0,
//                                                                         8.0),
//                                                                 child:
//                                                                     GestureDetector(
//                                                                   onTap: () {
//                                                                     // Navigator.push(
//                                                                     //     context,
//                                                                     //     MaterialPageRoute(builder:
//                                                                     //         (context) {
//                                                                     //   return MultiBlocProvider(
//                                                                     //     providers: [
//                                                                     //       BlocProvider(
//                                                                     //         create: (contextA) =>
//                                                                     //             p.PeopleBloc(),
//                                                                     //       ),
//                                                                     //       BlocProvider(
//                                                                     //         create: (context) =>
//                                                                     //             PostsBloc(),
//                                                                     //       ),
//                                                                     //     ],
//                                                                     //     child: PeopleProfile(
//                                                                     //         subjectID:
//                                                                     //             item.posted_by),
//                                                                     //   );
//                                                                     // }));
//                                                                   },
//                                                                   child:
//                                                                       GestureDetector(
//                                                                     onTap: () {
//                                                                       // Navigator.push(
//                                                                       //     context,
//                                                                       //     MaterialPageRoute(builder:
//                                                                       //         (context) {
//                                                                       //   return MultiBlocProvider(
//                                                                       //     providers: [
//                                                                       //       BlocProvider(
//                                                                       //         create: (contextA) => p.PeopleBloc(),
//                                                                       //       ),
//                                                                       //       BlocProvider(
//                                                                       //         create: (context) => PostsBloc(),
//                                                                       //       ),
//                                                                       //     ],
//                                                                       //     child:
//                                                                       //         PeopleProfile(subjectID: item.posted_by),
//                                                                       //   );
//                                                                       // }));
//                                                                     },
//                                                                     child:
//                                                                         CircleAvatar(
//                                                                       radius:
//                                                                           30,
//                                                                       backgroundColor:
//                                                                           Colors
//                                                                               .grey,
//                                                                       child:
//                                                                           ClipRRect(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(50),
//                                                                         child: Image
//                                                                             .network(
//                                                                           item.post_profile_pics,
//                                                                           width:
//                                                                               55,
//                                                                           height:
//                                                                               55,
//                                                                           fit: BoxFit
//                                                                               .cover,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Expanded(
//                                                                 child: Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                           .all(
//                                                                           8.0),
//                                                                   child: Column(
//                                                                     mainAxisAlignment:
//                                                                         MainAxisAlignment
//                                                                             .start,
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .stretch,
//                                                                     children: [
//                                                                       Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .all(
//                                                                             1.0),
//                                                                         child:
//                                                                             Row(
//                                                                           children: [
//                                                                             GestureDetector(
//                                                                               onTap: () {
//                                                                                 // Navigator.push(context, MaterialPageRoute(builder: (context) {
//                                                                                 //   return MultiBlocProvider(
//                                                                                 //     providers: [
//                                                                                 //       BlocProvider(
//                                                                                 //         create: (contextA) => p.PeopleBloc(),
//                                                                                 //       ),
//                                                                                 //       BlocProvider(
//                                                                                 //         create: (context) => PostsBloc(),
//                                                                                 //       ),
//                                                                                 //     ],
//                                                                                 //     child: PeopleProfile(subjectID: item.posted_by),
//                                                                                 //   );
//                                                                                 // }));
//                                                                               },
//                                                                               child: Text(
//                                                                                 _substring(item.post_update_by, 20),
//                                                                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                                                                               ),
//                                                                             ),
//                                                                             Text(
//                                                                               '. ' +

//                                                                                   //timeago.format(startTime, locale: 'en_short'),
//                                                                                   _getTimeAgo(DateTime.parse(item.post_updated_time)),
//                                                                               style: TextStyle(color: Colors.grey),
//                                                                             ),
//                                                                             Spacer(),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                       Column(
//                                                                         crossAxisAlignment:
//                                                                             CrossAxisAlignment.start,
//                                                                         children: [
//                                                                           item.designation == null || item.designation == ""
//                                                                               ? SizedBox()
//                                                                               : Padding(
//                                                                                   padding: const EdgeInsets.only(top: 4.0, bottom: 1.0, left: 4.0, right: 4.0),
//                                                                                   child: Row(
//                                                                                     children: [
//                                                                                       Container(
//                                                                                         padding: EdgeInsets.only(left: 7, right: 7),
//                                                                                         decoration: BoxDecoration(
//                                                                                             color: Colors.lightBlue, //0xffCCE9FD
//                                                                                             borderRadius: BorderRadius.all(Radius.circular(8))),
//                                                                                         alignment: Alignment.centerLeft,
//                                                                                         height: 20,
//                                                                                         child: Text(
//                                                                                           item.designation,
//                                                                                           style: TextStyle(color: Colors.white, fontSize: 12.0),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ],
//                                                                                   ),
//                                                                                 ),
//                                                                           Align(
//                                                                             alignment: item.post_alignment == "ltr" || item.post_alignment == null || item.post_alignment == ""
//                                                                                 ? Alignment.topLeft
//                                                                                 : Alignment.topRight,
//                                                                             child:
//                                                                                 InkWell(
//                                                                               onLongPress: () {
//                                                                                 FlutterClipboard.copy(item.post_message).then(
//                                                                                   (value) => GFToast.showToast('Copied', context,
//                                                                                       toastPosition: GFToastPosition.BOTTOM,
//                                                                                       textStyle: TextStyle(fontSize: 15, color: GFColors.DARK),
//                                                                                       backgroundColor: GFColors.LIGHT,
//                                                                                       trailing: Icon(
//                                                                                         Icons.notifications,
//                                                                                         color: GFColors.SUCCESS,
//                                                                                       )),
//                                                                                 );
//                                                                               },
//                                                                               child: Padding(
//                                                                                 padding: const EdgeInsets.all(4.0),
//                                                                                 child: Linkify(onOpen: _onOpen, text: item.post_message, style: TextStyle(fontSize: 15)),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                       if (imageList
//                                                                               .length >
//                                                                           0)
//                                                                         ImageSwipe(
//                                                                             imageList:
//                                                                                 imageList),
//                                                                       Row(
//                                                                         children: [
//                                                                           IconButton(
//                                                                             icon:
//                                                                                 Icon(
//                                                                               Icons.messenger_outline,
//                                                                               color: Colors.grey,
//                                                                             ),
//                                                                             onPressed:
//                                                                                 () async {
//                                                                               await Navigator.pushNamed(context, Comments.routeName, arguments: item).then((result) {
//                                                                                 if (result == 'refresh') {
//                                                                                   BlocProvider.of<PostsBloc>(context).add(
//                                                                                     FeedEvent(
//                                                                                       feedRequest: FeedRequest(skipOnboarding: false, skipTopFeed: false, isFirstFeedRequest: false, last_post_id: last_post_id, group_id: groupId, org_id: orgId, page: '', limit: limit, older_or_newer: older_or_newer, page_owner: ''),
//                                                                                     ),
//                                                                                   );
//                                                                                 }
//                                                                               });
//                                                                             },
//                                                                           ),
//                                                                           Text(
//                                                                               numberFormat(item.comment_count),
//                                                                               style: TextStyle(color: Colors.grey)),
//                                                                           IconButton(
//                                                                             icon:
//                                                                                 Icon(
//                                                                               _isLiked(int.parse(item.post_id)) == true ? Icons.favorite : Icons.favorite_outline,
//                                                                               color: _isLiked(int.parse(item.post_id)) == true ? Colors.red : Colors.grey,
//                                                                             ),
//                                                                             onPressed:
//                                                                                 () {
//                                                                               setState(() {
//                                                                                 likeSubjectID = item.post_id;
//                                                                                 showLikeLoader = true;
//                                                                                 _clickedID = int.parse(item.post_id);
//                                                                               });
//                                                                               if (_isLiked(int.parse(item.post_id)) == true) {
//                                                                                 BlocProvider.of<PostsBloc>(context).add(
//                                                                                   UnLikePostEvent(post_id: item.post_id),
//                                                                                 );
//                                                                                 setState(() {
//                                                                                   _updateLike(int.parse(item.post_id), false);
//                                                                                 });
//                                                                               } else {
//                                                                                 BlocProvider.of<PostsBloc>(context).add(
//                                                                                   LikePostEvent(post_id: item.post_id),
//                                                                                 );
//                                                                                 setState(() {
//                                                                                   _updateLike(int.parse(item.post_id), true);
//                                                                                 });
//                                                                               }
//                                                                             },
//                                                                           ),
//                                                                           GestureDetector(
//                                                                             onTap: item.like_count == 0
//                                                                                 ? null
//                                                                                 : () {
//                                                                                     BlocProvider.of<PostsBloc>(context).add(GetLikesEvent(
//                                                                                       post_id: item.post_id,
//                                                                                     ));
//                                                                                     _pc.open();
//                                                                                     setState(() {
//                                                                                       _slideUpTitle = "Likes(${numberFormat(item.like_count)})";
//                                                                                       _showSlideUpFor = "likes";

//                                                                                       showTownhallLoader = true;
//                                                                                       showSlideUpPanel = true;
//                                                                                       loading = false;
//                                                                                     });
//                                                                                   },
//                                                                             child:
//                                                                                 Text(numberFormat(item.like_count), style: TextStyle(color: Colors.grey)),
//                                                                           ),
//                                                                           IconButton(
//                                                                             icon:
//                                                                                 Icon(
//                                                                               Icons.share,
//                                                                               color: Colors.grey,
//                                                                             ),
//                                                                             onPressed:
//                                                                                 () async {
//                                                                               share(item.sharelink, '');
//                                                                             },
//                                                                           ),
//                                                                         ],
//                                                                       )
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 28,
//                                                                 child: Padding(
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .only(
//                                                                               top: 8),
//                                                                   child:
//                                                                       PopupMenuButton(
//                                                                     icon:
//                                                                         ImageIcon(
//                                                                       AssetImage(
//                                                                           "images/dots.png"),
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       size:
//                                                                           20.0,
//                                                                     ),
//                                                                     onSelected:
//                                                                         (choice) {
//                                                                       print(
//                                                                           choice);
//                                                                       if (choice ==
//                                                                           'Report') {
//                                                                         showDialog(
//                                                                           context:
//                                                                               context,
//                                                                           builder:
//                                                                               (BuildContext contextTwo) {
//                                                                             return AlertDialog(
//                                                                               scrollable: true,
//                                                                               title: Text('Report'),
//                                                                               content: Container(
//                                                                                 height: 175.0,
//                                                                                 width: 350.0,
//                                                                                 child: Column(
//                                                                                   children: [
//                                                                                     Container(
//                                                                                       child: SizedBox(
//                                                                                         child: TextFormField(
//                                                                                           maxLength: 300,
//                                                                                           maxLines: 3,
//                                                                                           minLines: 1,
//                                                                                           keyboardType: TextInputType.text,
//                                                                                           decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), labelText: 'Comment', hintText: 'Enter Comment', contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
//                                                                                           controller: _controllerComment,
//                                                                                           validator: (value) {
//                                                                                             if (value == null || value.isEmpty) {
//                                                                                               return 'Please Enter Comment';
//                                                                                               final snackBar = SnackBar(
//                                                                                                 content: Text('Please Enter Comment'),
//                                                                                                 backgroundColor: Colors.green.shade300,
//                                                                                               );
//                                                                                               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                                                             }
//                                                                                             return null;
//                                                                                           },
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                     SizedBox(
//                                                                                       height: 2.0,
//                                                                                     ),
//                                                                                     SizedBox(
//                                                                                       height: 50,
//                                                                                       child: ElevatedButton(
//                                                                                         style: raisedButtonStyleGreen,
//                                                                                         onPressed: () {
//                                                                                           if (_formKey.currentState!.validate()) {
//                                                                                             BlocProvider.of<PostsBloc>(context).add(
//                                                                                               ReportAbuseEvent(comment: _controllerComment.text, post_id: item.post_id, reported: item.posted_by),
//                                                                                             );
//                                                                                           }
//                                                                                         },
//                                                                                         child: Row(
//                                                                                           mainAxisAlignment: MainAxisAlignment.center,
//                                                                                           children: [
//                                                                                             const Text(
//                                                                                               'Submit',
//                                                                                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                                                                                             ),
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                         );
//                                                                       }
//                                                                       // else if (choice ==
//                                                                       //     'Block') {
//                                                                       //   BlocProvider.of<PostsBloc>(context)
//                                                                       //       .add(
//                                                                       //     BlockUserEvent(
//                                                                       //         subjectID: item.posted_by,
//                                                                       //         req_type: 'block'),
//                                                                       //   );
//                                                                       // }
//                                                                     },
//                                                                     padding:
//                                                                         EdgeInsets
//                                                                             .zero,
//                                                                     itemBuilder:
//                                                                         (BuildContext
//                                                                             context) {
//                                                                       return [
//                                                                         'Report',
//                                                                         //'Block'
//                                                                       ].map((String
//                                                                           choice) {
//                                                                         return PopupMenuItem<
//                                                                             String>(
//                                                                           value:
//                                                                               choice,
//                                                                           child:
//                                                                               Text(choice),
//                                                                         );
//                                                                       }).toList();
//                                                                     },
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Divider(),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   secondaryActions: <Widget>[
//                                                     IconSlideAction(
//                                                       caption: 'Delete',
//                                                       color: Colors.red,
//                                                       icon: Icons.delete,
//                                                       onTap: () {
//                                                         print('Delete');
//                                                         BlocProvider.of<
//                                                                     PostsBloc>(
//                                                                 context)
//                                                             .add(
//                                                           DeleteFeedEvent(
//                                                               post_id:
//                                                                   item.post_id,
//                                                               posted_by: item
//                                                                   .posted_by),
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 );
//                                         },
//                                       ),
//                                       // newList.contains(groupId) &&
//                                       //         newDataList.length > 0 &&
//                                       //         newDataFirstPostID != '' &&
//                                       //         cachedDataFirstPostID !=
//                                       //             newDataFirstPostID
//                                       //     ? GestureDetector(
//                                       //         onTap: () {
//                                       //           //remove from the group and pass new feeds to data
//                                       //           AppSharedPreferences.setValue(
//                                       //               key:
//                                       //                   "page_feed_${_topFeedIndexID.toString()}",
//                                       //               value:
//                                       //                   jsonEncode(newDataList));

//                                       //           setState(() {
//                                       //             newList.removeWhere((item) =>
//                                       //                 item.toString() ==
//                                       //                 groupId.toString());
//                                       //             data = List.from(newDataList);
//                                       //           });
//                                       //           newDataList = [];
//                                       //         },
//                                       //         child: Padding(
//                                       //           padding: const EdgeInsets.only(
//                                       //               left: 150, right: 150.0),
//                                       //           child: Container(
//                                       //             alignment: Alignment.center,
//                                       //             width: 150,
//                                       //             height: 50,
//                                       //             decoration: BoxDecoration(
//                                       //                 color: Colors.blue,
//                                       //                 borderRadius:
//                                       //                     BorderRadius.all(
//                                       //                         Radius.circular(
//                                       //                             15))),
//                                       //             child: Row(
//                                       //               mainAxisAlignment:
//                                       //                   MainAxisAlignment.center,
//                                       //               children: [
//                                       //                 IconButton(
//                                       //                     padding:
//                                       //                         EdgeInsets.only(
//                                       //                             left: 15),
//                                       //                     alignment:
//                                       //                         Alignment.center,
//                                       //                     icon: FaIcon(
//                                       //                       FontAwesomeIcons
//                                       //                           .arrowUp,
//                                       //                       size: 25,
//                                       //                       color: Colors.white,
//                                       //                     ),
//                                       //                     iconSize: 20.0,
//                                       //                     onPressed: () {}),
//                                       //                 // Row(
//                                       //                 //   children: [
//                                       //                 //     SizedBox(
//                                       //                 //       width: 90,
//                                       //                 //       child: Stack(
//                                       //                 //         children: [
//                                       //                 //           CircleAvatar(
//                                       //                 //             radius: 19,
//                                       //                 //             backgroundColor:
//                                       //                 //                 Colors
//                                       //                 //                     .white,
//                                       //                 //             child:
//                                       //                 //                 ClipRRect(
//                                       //                 //               borderRadius:
//                                       //                 //                   BorderRadius
//                                       //                 //                       .circular(
//                                       //                 //                           25),
//                                       //                 //               child: Image
//                                       //                 //                   .network(
//                                       //                 //                 '${data[0].post_profile_pics}',
//                                       //                 //                 width: 35,
//                                       //                 //                 height: 35,
//                                       //                 //                 fit: BoxFit
//                                       //                 //                     .cover,
//                                       //                 //               ),
//                                       //                 //             ),
//                                       //                 //           ),
//                                       //                 //           Positioned(
//                                       //                 //             left: 25,
//                                       //                 //             child: Row(
//                                       //                 //               children: [
//                                       //                 //                 CircleAvatar(
//                                       //                 //                   radius:
//                                       //                 //                       19,
//                                       //                 //                   backgroundColor:
//                                       //                 //                       Colors
//                                       //                 //                           .white,
//                                       //                 //                   child:
//                                       //                 //                       ClipRRect(
//                                       //                 //                     borderRadius:
//                                       //                 //                         BorderRadius.circular(25),
//                                       //                 //                     child: Image
//                                       //                 //                         .network(
//                                       //                 //                       '${data[1].post_profile_pics}',
//                                       //                 //                       width:
//                                       //                 //                           35,
//                                       //                 //                       height:
//                                       //                 //                           35,
//                                       //                 //                       fit: BoxFit
//                                       //                 //                           .cover,
//                                       //                 //                     ),
//                                       //                 //                   ),
//                                       //                 //                 ),
//                                       //                 //               ],
//                                       //                 //             ),
//                                       //                 //           ),
//                                       //                 //           Positioned(
//                                       //                 //             left: 45,
//                                       //                 //             child:
//                                       //                 //                 CircleAvatar(
//                                       //                 //               radius: 19,
//                                       //                 //               backgroundColor:
//                                       //                 //                   Colors
//                                       //                 //                       .white,
//                                       //                 //               child:
//                                       //                 //                   ClipRRect(
//                                       //                 //                 borderRadius:
//                                       //                 //                     BorderRadius.circular(
//                                       //                 //                         25),
//                                       //                 //                 child: Image
//                                       //                 //                     .network(
//                                       //                 //                   '${data[2].post_profile_pics}',
//                                       //                 //                   width: 35,
//                                       //                 //                   height:
//                                       //                 //                       35,
//                                       //                 //                   fit: BoxFit
//                                       //                 //                       .cover,
//                                       //                 //                 ),
//                                       //                 //               ),
//                                       //                 //             ),
//                                       //                 //           ),
//                                       //                 //         ],
//                                       //                 //       ),
//                                       //                 //     ),
//                                       //                 //   ],
//                                       //                 // ),
//                                       //                 Text(
//                                       //                   "Latest",
//                                       //                   style: TextStyle(
//                                       //                       color: Colors.white,
//                                       //                       fontWeight:
//                                       //                           FontWeight.bold,
//                                       //                       fontSize: 15.0),
//                                       //                 ),
//                                       //                 SizedBox(
//                                       //                   width: 22,
//                                       //                 )
//                                       //               ],
//                                       //             ),
//                                       //           ),
//                                       //         ),
//                                       //       )
//                                       //     : SizedBox()
//                                     ],
//                                   ),
//                           ),
//                         ),

//                       //Feeds end
//                       // if (state is NoResultState)
//                       //   Container(
//                       //     child: data.length == 0
//                       //         ? Center(
//                       //             child: Text("No Post"),
//                       //           )
//                       //         : SizedBox(width: 1),
//                       //   )

//                       // if (olderLoader)
//                       //   Container(
//                       //     width: 80.0,
//                       //     height: 80.0,
//                       //     child: SpinKitCircle(
//                       //       color: Colors.blue,
//                       //       size: 25.0,
//                       //     ),
//                       //   ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//           floatingActionButton:
//               // showFloatingButton && showSlideUpPanel == false
//               //     ?
//               Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               showFloatingButton && showSlideUpPanel == false
//                   ? FloatingActionButton(
//                       heroTag: null,
//                       onPressed: () async {
//                         await Navigator.pushNamed(context, CreatePost.routeName,
//                                 arguments: groupId)
//                             .then((result) {
//                           if (result == 'refresh') {
//                             // setState(() {
//                             //   olderLoader = false;
//                             //   loading = false;
//                             // });
//                             BlocProvider.of<PostsBloc>(context).add(
//                               FeedEvent(
//                                 feedRequest: FeedRequest(
//                                     skipOnboarding: false,
//                                     skipTopFeed: false,
//                                     isFirstFeedRequest: false,
//                                     last_post_id: '',
//                                     group_id: groupId,
//                                     org_id: orgId,
//                                     page: '',
//                                     limit: limit,
//                                     older_or_newer: '',
//                                     page_owner: ''),
//                               ),
//                             );
//                           }
//                         });
//                       },
//                       child: Icon(Icons.chat),
//                     )
//                   : SizedBox(),
//               SizedBox(
//                   height:
//                       showFloatingButton && showSlideUpPanel == false ? 20 : 0),
//               showResultButton
//                   ? FloatingActionButton(
//                       backgroundColor: Colors.green,
//                       heroTag: null,
//                       onPressed: () async {
//                         await Navigator.pushNamed(
//                           context,
//                           ResultTypeScreen.routeName,
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 2.0),
//                         child: Text("Post Result",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 13,
//                             )),
//                       ),
//                       //Icon(Icons.poll),
//                     )
//                   : SizedBox(),
//             ],
//           )
//           // : SizedBox(),
//           ),
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

//   _checkVersion(NewVersionPlus newVersion, int min_build_no) async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     final status = await newVersion.getVersionStatus();

//     var dismissedVersion =
//         await getDismissedVersion(); //this is will only show notification when user hasn't updated
//     print("dismissedVersion: ${dismissedVersion}");
//     print("LocalVersion: ${packageInfo.version}");
//     print("StoreVersion: ${status!.storeVersion}");
//     print("Expected Build No: ${min_build_no}");
//     AppSharedPreferences.setInt(
//         key: 'installedAppBuildNo', value: int.parse(packageInfo.buildNumber));
//     if (dismissedVersion != status.storeVersion) {
//       debugPrint("release note: " + status.releaseNotes!);
//       debugPrint("Store link: " + status.appStoreLink);
//       debugPrint("Local version: " + status.localVersion);
//       debugPrint("Store version: " + status.storeVersion);
//       debugPrint("System Version: " + packageInfo.version);

//       //debugPrint(status.canUpdate.toString());
//       newVersion.showUpdateDialog(
//         context: context,
//         versionStatus: status,
//         dialogText: 'A new version of TownHall app is available for download.',
//         dialogTitle: 'UPDATE!',
//         updateButtonText: 'Update Now',
//         allowDismissal:
//             min_build_no > int.parse(packageInfo.buildNumber) ? false : true,
//         dismissButtonText: 'Later',
//         dismissAction: () => {
//           Navigator.of(context).pop(),
//         },
//       );
//       AppSharedPreferences.setValue(
//           key: 'dismissedVersion', value: status.storeVersion);
//     }
//   }

//   Future<void> dismiss() async {
//     AppSharedPreferences.setBool(key: 'userNewVersionClickAction', value: true);
//     Navigator.of(context, rootNavigator: true).pop();
//   }

//   Future<String?> getDismissedVersion() async {
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
//     if (!await launchUrl(_url)) {
//       throw 'Could not launch $_url';
//     }
//   }

//   Future<String?> getGroupID() async {
//     return await AppSharedPreferences.getValue(key: 'groupID');
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
//         _isPageVisited = pages!.contains(value);
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
//     return moment.from(utcTime.toLocal());
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

//   // loadVideoPlayer() {
//   //   _vcontroller = VideoPlayerController.network(
//   //       'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
//   //   _vcontroller.addListener(() {
//   //     setState(() {});
//   //   });
//   //   _vcontroller.initialize().then((value) {
//   //     setState(() {});
//   //   });
//   // }
//   //Widget renderTownhall(List info) {
//   // return ListView.builder(
//   //     itemCount: info.length,
//   //     itemBuilder: (BuildContext context, int index) {
//   //       return ListTile(
//   //           leading: Text('Text'),
//   //           trailing: const Text(
//   //             "GFG",
//   //             style: TextStyle(color: Colors.green, fontSize: 15),
//   //           ),
//   //           title: Text("List item $index"));
//   //     });

//   //print("Tell length: ${info.length}");
//   //return ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: info.length)
//   // return Row(
//   //     children: data
//   //         .map(
//   //           (data) => ListTile(
//   //             title: Text('My title'),
//   //             subtitle: Text('subtitle'),
//   //             leading: Text('leading'),
//   //             trailing: Text('example'),
//   //           ),
//   //         )
//   //         .toList());
//   ////}
//   ///@override
//   void dispose() {
//     super.dispose();
//     timer?.cancel();
//     //_vcontroller.dispose();
//   }

//   _getCachedFeedData(int index) async {
//     await _getOrgID();
//     var sharedGrpId = await getGroupID();
//     var grpID = isPageFirstLoad ? sharedGrpId.toString() : index.toString();
//     print("Cached data was called Org ID: ${orgId} TowhnID: ${grpID}");
//     var pageData = await getPageData('page_feed_${orgId}_${grpID}');
//     if (pageData != null && pageData != "") {
//       var json = jsonDecode(pageData);
//       setState(() {
//         // List<Map<String, dynamic>> data = List.from(json);
//         isCachedDataAvailable = true;
//         loading = false;
//         newFeedLoader = true;
//       });
//       data = json.map<FeedData>((json) => FeedData.fromJson(json)).toList();
//     } else {
//       setState(() {
//         loading = true;
//         isCachedDataAvailable = false;
//         newFeedLoader = false;
//       });
//     }
//     print("Cached Statuc:${isCachedDataAvailable}");
//   }

//   _getCachedTopData(int index) async {
//     await _getOrgID();
//     var sharedGrpId = await getGroupID();
//     var grpID = isPageFirstLoad ? sharedGrpId.toString() : index.toString();
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
//       loading = true;
//       //isCachedDataAvailable = false;
//     }
//     //print("Cached Statuc:${isCachedDataAvailable}");
//   }

//   setUpTimedFetch() {
//     var dToken = getDeviceToken();
//     //Timer.periodic(Duration(milliseconds: 5000), (timer) {
//     // FeedEvent(
//     //   feedRequest: FeedRequest(
//     //       last_post_id: last_post_id,
//     //       group_id: groupId,
//     //       org_id: orgId,
//     //       post_id: '',
//     //       limit: 20,
//     //       older_or_newer: older_or_newer,
//     //       page_owner: '',
//     //       device_token: dToken,
//     //       device_type: _deviceType),
//     // );
//     // setState(() {
//     //   _future = Future.value(timer.tick.toString());
//     // });
//     // InAppNotification.show(
//     //   child: NotificationBody(
//     //     count: 5,
//     //     minHeight: 100,
//     //   ),
//     //   context: context,
//     //   onTap: () => print('Notification tapped!'),
//     //   duration: Duration(milliseconds: 10),
//     // );
//     //});
//   }

//   _getFirstWhere(List dataList) {
//     for (var i = 0; i < dataList.length; i++) {
//       if (dataList[i].noticeboard_msg == "no") {
//         return dataList[i].post_id;
//         break;
//       }
//     }
//   }

//   bool _isLiked(int subjectID) {
//     bool status = false;
//     for (var map in _likeList) {
//       if (map.containsKey("id")) {
//         if (map["id"] == subjectID) {
//           status = map["status"];
//           break;
//         }
//       }
//     }
//     return status;
//   }

//   _updateLike(int subjectID, bool status) async {
//     int foundKey = -1;
//     for (var map in _likeList) {
//       if (map.containsKey("id")) {
//         if (map["id"] == subjectID) {
//           foundKey = subjectID;
//           break;
//         }
//       }
//     }
//     if (-1 != foundKey) {
//       _likeList.removeWhere((map) {
//         return map["id"] == foundKey;
//       });
//     }
//     Map<String, dynamic> json = {"id": subjectID, "status": status};
//     _likeList.add(json);
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

// // class ToolTipCustomShape extends ShapeBorder {

// //   final bool usePadding;
// //   ToolTipCustomShape({this.usePadding = true});

// //   @override
// //   EdgeInsetsGeometry get dimensions =>
// //       EdgeInsets.only(bottom: usePadding ? 20 : 0);

// //   @override
// //   Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

// //   @override
// //   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
// //     rect =
// //         Rect.fromPoints(rect.topLeft, rect.bottomRight - const Offset(0, 20));
// //     return Path()
// //       ..addRRect(
// //           RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 3)))
// //       ..moveTo(rect.bottomCenter.dx - 10, rect.bottomCenter.dy)
// //       ..relativeLineTo(10, 20)
// //       ..relativeLineTo(10, -20)
// //       ..close();
// //   }

// //   @override
// //   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

// //   @override
// //   ShapeBorder scale(double t) => this;
// // }
