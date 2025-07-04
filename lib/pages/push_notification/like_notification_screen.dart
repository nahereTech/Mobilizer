import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart' as a;
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as p;
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/comments/create_comments_request.dart';
import 'package:mobilizer/models/like/like_details_response.dart' as details;
import 'package:mobilizer/models/feed/feed_request.dart';
import 'package:mobilizer/models/feed/feed_response.dart';
import 'package:mobilizer/pages/comments/comments.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart' as o;
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/pages/settings/settings.dart';
import 'package:mobilizer/widget/image_swipe.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:indexed/indexed.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:mobilizer/widget/video_build.dart';

class LikeNotificationScreen extends StatefulWidget {
  static String routeName = 'like_notification_screen';
  const LikeNotificationScreen({Key? key}) : super(key: key);

  @override
  State<LikeNotificationScreen> createState() => _LikeNotificationScreenState();
}

class _LikeNotificationScreenState extends State<LikeNotificationScreen> {
  Timer? timer;
  var moment = new Moment.now();
  PanelController _pc = new PanelController();
  final _formKey = GlobalKey<FormState>();
  final _controllerComment = TextEditingController();
  late VideoPlayerController _controller;

  bool _showLoader = false;
  bool _showShimmerLoader = true;
  bool _showSlideUpPanel = false;
  bool _reloadTop = false;
  bool _isLiked = false;
  int _clickedID = 0;

  String _postVideo = "";
  String _commentVideo = "";
  String _slideUpTitle = "";
  String _profileImage = "";
  String _showSlideUpFor = "";
  String _deviceType = "";
  String _nType = "";
  String _itemID = "";
  String? _orgName;
  String? _orgID;
  String? _groupID;
  int limit = 30;

  List<Like> _likes = [];
  List<dynamic> _data = [];
  List<dynamic> _postImageList = [];
  details.FData? _postData;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _setProfilePic();
    // _setOrgName();
    var _deviceToken = getDeviceToken();
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      // setState(() {
      moment = Moment.now();
      // });
    });
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments as Map;

      debugPrint("PostID: " + args['item_id']);
      BlocProvider.of<PostsBloc>(context).add(
        GetLikeDetailsEvent(like_id: args['item_id']),
      );
      setState(() {
        _nType = args['n_type'];
        _itemID = args['item_id'];
        _orgID = args['org_id'];
        _groupID = args['townhall_id'];
        _orgName = args['org_name'];
        AppSharedPreferences.setValue(key: 'orgID', value: _orgID!);
        AppSharedPreferences.setValue(key: 'orgName', value: _orgName!);
        AppSharedPreferences.setValue(key: 'groupID', value: _groupID!);
      });
    });
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: SlidingUpPanel(
            minHeight: 0.0,
            maxHeight: size.height - 150,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            onPanelClosed: () {
              setState(() {
                _showSlideUpPanel = false;
              });
            },
            controller: _pc,
            backdropEnabled: true,
            panel: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        width: size.width - 50,
                        height: 20.0,
                        child: IconButton(
                            alignment: Alignment.topRight,
                            icon: Icon(Icons.close, color: Colors.grey),
                            iconSize: 20.0,
                            onPressed: () {
                              _pc.close();
                            }),
                      ),
                      Container(
                        width: size.width - 50,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                _slideUpTitle,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: BlocConsumer<PostsBloc, PostsState>(
                listener: (context, state) {
                  if (state is LikeDetailsState) {
                    _postData = state.postResponse.data;
                    _showShimmerLoader = false;
                    if (_postData!.post_images != null) {
                      _likes.add(Like(
                          isLiked: _postData!.is_liked == "yes" ? true : false,
                          likeCounts: _postData!.like_count == ""
                              ? 0
                              : _postData!.like_count));
                      print(_likes);

                      for (details.FeedImagesData image
                          in _postData!.post_images!) {
                        _postImageList.add(image.name);
                      }
                    }
                    // print(
                    //     "is there result: Loading:  older_newer: ${older_or_newer}");
                  }
                  if (state is CreateCommentState) {
                    _showLoader = false;
                    final snackBar = SnackBar(
                      content: Text('Comment was successfully posted'),
                      backgroundColor: Colors.green.shade300,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Future.delayed(Duration(seconds: 5), () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(providers: [
                            BlocProvider(
                              create: (context) => AuthBloc(),
                            ),
                            BlocProvider(
                              create: (context) => EventsBloc(),
                            ),
                            BlocProvider(
                              create: (context) => MessagesBloc(),
                            ),
                            BlocProvider(
                              create: (context) => PeopleBloc(),
                            ),
                            BlocProvider(
                              create: (context) => PostsBloc(),
                            ),
                            BlocProvider(
                              create: (context) => OrganizationBloc(),
                            ),
                          ], child: HomeScreen());
                        }),
                      );
                    });
                  }
                },
                builder: (context, state) {
                  var _deviceToken = getDeviceToken();
                  return Column(
                    children: [
                      SizedBox(
                        height: 1.0,
                      ),
                      _reloadTop
                          ? SizedBox(width: 0)
                          : Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return BlocProvider(
                                        create: (context) =>
                                            o.OrganizationBloc(),
                                        child: OrganizationScreen(),
                                      );
                                    }));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 1.0, right: 6.0, top: 2.0),
                                    height: 50.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Row(
                                        //   children: [
                                        //     ImageIcon(
                                        //       AssetImage(
                                        //           "images/icon_blue.png"),
                                        //       color: Colors.blue,
                                        //       size: 20.0,
                                        //     ),
                                        //   ],
                                        // ),
                                        Row(
                                          children: [
                                            IconButton(
                                              iconSize: 15,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(
                                                            create: (context) =>
                                                                AuthBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                EventsBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                MessagesBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                PeopleBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                PostsBloc(),
                                                          ),
                                                          BlocProvider(
                                                            create: (context) =>
                                                                OrganizationBloc(),
                                                          ),
                                                        ],
                                                        child: HomeScreen());
                                                  }),
                                                );
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.arrowLeft,
                                                size: 25,
                                                color: Colors.blue,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            _orgName == null
                                                ? SizedBox()
                                                : Container(
                                                    height: 30,
                                                    //width: 120,
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.blue,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "${_orgName == null ? '' : _substring(_orgName.toString(), 10)}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                        SizedBox(
                                                          width: 25,
                                                          child: IconButton(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 3,
                                                                    right:
                                                                        20.0),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            iconSize: 20,
                                                            icon: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              color:
                                                                  Colors.blue,
                                                              //size: 30,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return BlocProvider(
                                                    create: (context) =>
                                                        a.AuthBloc(),
                                                    child: Settings(),
                                                  );
                                                }));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Colors.lightBlue,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    child: Image.network(
                                                      _profileImage == ""
                                                          ? 'https://${domainName}/files/images/user_profile_images/mid_default.png'
                                                          : _profileImage,
                                                      width: 55,
                                                      height: 55,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 0.1,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                      if (_showShimmerLoader) shimmerLoading(),
                      //feed data starts here
                      if (_postData != null)
                        Form(
                          key: _formKey,
                          child: Expanded(
                            child: _showLoader
                                ? Center(
                                    child: Container(
                                      width: 80.0,
                                      height: 80.0,
                                      child: SpinKitCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            color: _postData!.noticeboard_msg ==
                                                    "yes"
                                                ? Color(0xffCCE9FD)
                                                : null,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          9.0, 9.0, 6.0, 8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Map<String, dynamic>
                                                          mapData = {
                                                        'subjectID': _postData!
                                                            .posted_by,
                                                        'picture': _postData!
                                                            .post_profile_pics,
                                                        'post_update_by':
                                                            _postData!
                                                                .post_update_by,
                                                        'username': '',
                                                      };
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
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
                                                          child: PeopleProfile(
                                                              mapData: mapData),
                                                        );
                                                      }));
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: Image.network(
                                                          _postData!
                                                              .post_profile_pics,
                                                          width: 55,
                                                          height: 55,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4.0,
                                                                      bottom:
                                                                          1.0,
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0),
                                                              child: Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      // groupId = item
                                                                      //     .post_group_id
                                                                      //     .toString();
                                                                      // BlocProvider.of<PostsBloc>(context)
                                                                      //     .add(
                                                                      //   FeedEvent(
                                                                      //     feedRequest: FeedRequest(last_post_id: last_post_id, group_id: item.post_group_id.toString(), post_id: '', limit: limit, older_or_newer: older_or_newer, page_owner: ''),

                                                                      //   ),

                                                                      // );
                                                                      Map<String,
                                                                              dynamic>
                                                                          mapData =
                                                                          {
                                                                        'subjectID':
                                                                            _postData!.posted_by,
                                                                        'picture':
                                                                            _postData!.post_profile_pics,
                                                                        'post_update_by':
                                                                            _postData!.post_update_by,
                                                                        'username':
                                                                            '',
                                                                      };
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(builder:
                                                                              (context) {
                                                                        return MultiBlocProvider(
                                                                          providers: [
                                                                            BlocProvider(
                                                                              create: (contextA) => p.PeopleBloc(),
                                                                            ),
                                                                            BlocProvider(
                                                                              create: (context) => PostsBloc(),
                                                                            ),
                                                                          ],
                                                                          child:
                                                                              PeopleProfile(mapData: mapData),
                                                                        );
                                                                      }));
                                                                    },
                                                                    child: Text(
                                                                      _substring(
                                                                          _postData!
                                                                              .post_update_by,
                                                                          20),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '. ' +
                                                                        // timeago.format(
                                                                        //     startTime,
                                                                        //     locale: 'en_short'),
                                                                        _getTimeAgo(
                                                                            DateTime.parse(_postData!.post_updated_time)),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                  //Spacer(),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                _postData!.designation ==
                                                                            null ||
                                                                        _postData!.designation ==
                                                                            ""
                                                                    ? SizedBox()
                                                                    : Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                4.0,
                                                                            right:
                                                                                4.0,
                                                                            left:
                                                                                4.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                              padding: EdgeInsets.only(left: 7, right: 7),
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.lightBlue, //0xffCCE9FD
                                                                                  borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                              alignment: Alignment.centerLeft,
                                                                              height: 20,
                                                                              child: Text(
                                                                                _postData!.designation,
                                                                                style: TextStyle(color: Colors.white, fontSize: 12.0),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                Align(
                                                                  alignment: _postData!.post_alignment == "ltr" ||
                                                                          _postData!.post_alignment ==
                                                                              null ||
                                                                          _postData!.post_alignment ==
                                                                              ""
                                                                      ? Alignment
                                                                          .topLeft
                                                                      : Alignment
                                                                          .topRight,
                                                                  child:
                                                                      InkWell(
                                                                    onLongPress:
                                                                        () {
                                                                      FlutterClipboard.copy(
                                                                              _postData!.post_message)
                                                                          .then(
                                                                        (value) => GFToast.showToast(
                                                                            'Copied',
                                                                            context,
                                                                            toastPosition:
                                                                                GFToastPosition.BOTTOM,
                                                                            textStyle: TextStyle(fontSize: 15, color: GFColors.DARK),
                                                                            backgroundColor: GFColors.LIGHT,
                                                                            trailing: Icon(
                                                                              Icons.notifications,
                                                                              color: GFColors.SUCCESS,
                                                                            )),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          04.0),
                                                                      child: Linkify(
                                                                          options: LinkifyOptions(
                                                                              humanize:
                                                                                  false),
                                                                          onOpen:
                                                                              _onOpen,
                                                                          text: _postData!
                                                                              .post_message,
                                                                          style:
                                                                              TextStyle(fontSize: 15)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                // IconButton(
                                                                //   icon: Icon(
                                                                //     _likes[0]
                                                                //             .isLiked
                                                                //         ? Icons
                                                                //             .favorite
                                                                //         : Icons
                                                                //             .favorite_outline,
                                                                //     color: _likes[0]
                                                                //             .isLiked
                                                                //         ? Colors.red
                                                                //         : Colors
                                                                //             .grey,
                                                                //   ),
                                                                //   onPressed: () {
                                                                //     setState(() {
                                                                //       _clickedID =
                                                                //           0;
                                                                //     });
                                                                //     if (_likes[0]
                                                                //         .isLiked) {
                                                                //       _toggleLike(
                                                                //           0);

                                                                //       BlocProvider.of<
                                                                //                   PostsBloc>(
                                                                //               context)
                                                                //           .add(
                                                                //         UnLikePostEvent(
                                                                //             post_id:
                                                                //                 _postData!.post_id),
                                                                //       );
                                                                //     } else {
                                                                //       _toggleLike(
                                                                //           0);
                                                                //       BlocProvider.of<
                                                                //                   PostsBloc>(
                                                                //               context)
                                                                //           .add(
                                                                //         LikePostEvent(
                                                                //             post_id:
                                                                //                 _postData!.post_id),
                                                                //       );
                                                                //     }
                                                                //   },
                                                                // ),

                                                                // GestureDetector(
                                                                //   onTap: _likes[0]
                                                                //               .likeCounts ==
                                                                //           0
                                                                //       ? null
                                                                //       : () {
                                                                //           BlocProvider.of<PostsBloc>(
                                                                //                   context)
                                                                //               .add(
                                                                //                   GetLikesEvent(
                                                                //             post_id:
                                                                //                 _postData!.post_id,
                                                                //           ));
                                                                //           _pc.open();
                                                                //           setState(
                                                                //               () {
                                                                //             _slideUpTitle =
                                                                //                 "Likes(${_numberFormat(_postData!.like_count)})";
                                                                //             _showSlideUpFor =
                                                                //                 "likes";

                                                                //             //showTownhallLoader = true;
                                                                //             //isCachedDataAvailable = false;

                                                                //             _showSlideUpPanel =
                                                                //                 true;
                                                                //             _showLoader =
                                                                //                 false;
                                                                //           });
                                                                //         },
                                                                //   child: Text(
                                                                //       _numberFormat(
                                                                //           _likes[0]
                                                                //               .likeCounts),
                                                                //       style: TextStyle(
                                                                //           color: Colors
                                                                //               .grey)),
                                                                // ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 21)
                                                          ],
                                                        ),
                                                      ),
                                                      if (_postData!
                                                              .liker!.length >
                                                          0)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 1.0,
                                                                  bottom: 1,
                                                                  left: 1,
                                                                  right: 20),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              20),
                                                                  itemCount:
                                                                      _postData!
                                                                          .liker!
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    final likers =
                                                                        _postData!
                                                                            .liker![index];

                                                                    return Column(
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(9.0, 9.0, 6.0, 8.0),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    Map<String, dynamic> mapData = {
                                                                                      'subjectID': likers.liked_by,
                                                                                      'picture': likers.profile_photo,
                                                                                      'post_update_by': likers.firstname + ' ' + likers.lastname,
                                                                                      'username': likers.username,
                                                                                    };
                                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
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
                                                                                    radius: 25,
                                                                                    backgroundColor: Colors.grey,
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(50),
                                                                                      child: Image.network(
                                                                                        likers.profile_photo,
                                                                                        width: 45,
                                                                                        height: 45,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(1.0),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(top: 4.0, bottom: 1.0, left: 4.0, right: 4.0),
                                                                                        child: Row(
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                // groupId = item
                                                                                                //     .post_group_id
                                                                                                //     .toString();
                                                                                                // BlocProvider.of<PostsBloc>(context)
                                                                                                //     .add(
                                                                                                //   FeedEvent(
                                                                                                //     feedRequest: FeedRequest(last_post_id: last_post_id, group_id: item.post_group_id.toString(), post_id: '', limit: limit, older_or_newer: older_or_newer, page_owner: ''),

                                                                                                //   ),

                                                                                                // );
                                                                                                Map<String, dynamic> mapData = {
                                                                                                  'subjectID': likers.liked_by,
                                                                                                  'picture': likers.profile_photo,
                                                                                                  'post_update_by': likers.firstname + ' ' + likers.lastname,
                                                                                                  'username': likers.username,
                                                                                                };
                                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
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
                                                                                              child: Text(
                                                                                                _substring("${likers.firstname} ${likers.lastname}", 20),
                                                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              '. ' +
                                                                                                  // timeago.format(
                                                                                                  //     startTime,
                                                                                                  //     locale: 'en_short'),
                                                                                                  //2023-06-15 4:21:23
                                                                                                  _getTimeAgo(DateTime.parse(likers.time_of_like)),
                                                                                              style: TextStyle(color: Colors.grey),
                                                                                            ),
                                                                                            //Spacer(),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Align(
                                                                                            alignment: Alignment.topLeft,
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.only(top: 5, left: 5),
                                                                                              child: Text(
                                                                                                '${likers.username}',
                                                                                                style: TextStyle(fontSize: 14),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Align(
                                                                                            alignment: Alignment.topLeft,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.all(05.0),
                                                                                              child: Linkify(options: LinkifyOptions(humanize: false), onOpen: _onOpen, text: "Liked your post", style: TextStyle(fontSize: 15, color: Colors.grey)),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                            ],
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      direction: ShimmerDirection.ltr,
      enabled: true,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                color: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(9.0, 9.0, 6.0, 8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "images/profile1.jpeg",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 1.0, left: 7.0, right: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 230,
                                    padding: EdgeInsets.only(left: 7, right: 7),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue, //0xffCCE9FD
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1))),
                                    alignment: Alignment.centerLeft,
                                    height: 18,
                                    child: SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0,
                                      right: 4.0,
                                      left: 5.0,
                                      top: 7),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 315,
                                        padding:
                                            EdgeInsets.only(left: 7, right: 7),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.lightBlue, //0xffCCE9FD
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1))),
                                        alignment: Alignment.centerLeft,
                                        height: 18,
                                        child: SizedBox(),
                                      ),
                                      //SizedBox(height: 15),

                                      Column(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Container(
                                                color: null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          9.0, 9.0, 6.0, 8.0),
                                                      child: CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          child: Image.asset(
                                                            "images/profile1.jpeg",
                                                            width: 45,
                                                            height: 45,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4.0,
                                                                      bottom:
                                                                          1.0,
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 160,
                                                                    padding: EdgeInsets.only(
                                                                        left: 7,
                                                                        right:
                                                                            7),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            color:
                                                                                Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    height: 18,
                                                                    child:
                                                                        SizedBox(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          4.0,
                                                                      right:
                                                                          4.0,
                                                                      left: 5.0,
                                                                      top: 7),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            315,
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                7,
                                                                            right:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        height:
                                                                            18,
                                                                        child:
                                                                            SizedBox(),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Container(
                                                                        width:
                                                                            315,
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                7,
                                                                            right:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.lightBlue, //0xffCCE9FD
                                                                            borderRadius: BorderRadius.all(Radius.circular(1))),
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        height:
                                                                            18,
                                                                        child:
                                                                            SizedBox(),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              20),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            // if(_imageList.length > 0)
                                                            //  ImageSwipe(
                                                            //                                                 imageList:
                                                            //                                                     _imageList),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          Divider(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ImageIcon(
                          AssetImage("images/dots.png"),
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              )),
          Divider(),
        ],
      ),
    );
  }

  // Widget buildPost(String textPost, String postBy, String postDate,
  //     int commentCounts, int likeCounts) {
  //   return Container(
  //     color: null,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(9.0, 9.0, 6.0, 8.0),
  //           child: CircleAvatar(
  //             radius: 30,
  //             backgroundColor: Colors.grey,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(50),
  //               child: Image.asset(
  //                 "images/profile1.jpeg",
  //                 width: 55,
  //                 height: 55,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.all(1.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 4.0, bottom: 1.0, left: 4.0, right: 4.0),
  //                   child: Row(
  //                     children: [
  //                       Text(
  //                         _substring(postBy, 20),
  //                         style: TextStyle(
  //                             fontWeight: FontWeight.bold, fontSize: 15),
  //                       ),
  //                       Text(
  //                         '. ' +
  //                             // timeago.format(
  //                             //     startTime,
  //                             //     locale: 'en_short'),
  //                             _getTimeAgo(DateTime.parse(postDate)),
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.only(
  //                           bottom: 4.0, right: 4.0, left: 4.0),
  //                       child: Row(
  //                         children: [
  //                           Container(
  //                             padding: EdgeInsets.only(left: 7, right: 7),
  //                             decoration: BoxDecoration(
  //                                 color: Colors.lightBlue, //0xffCCE9FD
  //                                 borderRadius:
  //                                     BorderRadius.all(Radius.circular(8))),
  //                             alignment: Alignment.centerLeft,
  //                             height: 20,
  //                             child: Text(
  //                               "Supervisor",
  //                               style: TextStyle(
  //                                   color: Colors.white, fontSize: 12.0),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.topLeft,
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(04.0),
  //                         child: Linkify(
  //                             options: LinkifyOptions(humanize: false),
  //                             onOpen: _onOpen,
  //                             text: textPost,
  //                             style: TextStyle(fontSize: 15)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 // if(_imageList.length > 0)
  //                 //  ImageSwipe(
  //                 //                                                 imageList:
  //                 //                                                     _imageList),
  //                 Row(
  //                   children: [
  //                     IconButton(
  //                         icon: Icon(
  //                           Icons.messenger_outline,
  //                           color: Colors.grey,
  //                         ),
  //                         onPressed: null),
  //                     Text(
  //                       _numberFormat(commentCounts),
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                     IconButton(
  //                         icon: Icon(
  //                           Icons.favorite_outline,
  //                           color: Colors.grey,
  //                         ),
  //                         onPressed: null),
  //                     Text(
  //                       _numberFormat(likeCounts),
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                     IconButton(
  //                         icon: Icon(
  //                           Icons.share,
  //                           color: Colors.grey,
  //                         ),
  //                         onPressed: null),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 28,
  //           child: Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: ImageIcon(
  //               AssetImage("images/dots.png"),
  //               color: Colors.grey,
  //               size: 20.0,
  //             ),
  //           ),
  //         ),
  //         Divider(),
  //       ],
  //     ),
  //   );
  // }

  void _setProfilePic() async {
    var picture = await _getProfilePic();
    setState(() {
      _profileImage = picture!;
    });
  }

  String _numberFormat(int n) {
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

  void _toggleLike(int index) {
    setState(() {
      _likes[index].likeCounts = _likes[index].isLiked
          ? _likes[index].likeCounts == 0
              ? 0
              : _likes[index].likeCounts - 1
          : _likes[index].likeCounts + 1;
      _likes[index].isLiked = !_likes[index].isLiked;
      // Toggle the 'isLiked' flag
    });
  }

  // _setOrgName() async {
  //   var organizationName = await getOrgName();
  //   setState(() {
  //     _orgName = organizationName;
  //   });
  //   print("This is orgName: ${_orgName}");
  // }

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

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  // Future<String?> getOrg() async {
  //   return await AppSharedPreferences.getValue(key: 'orgID');
  // }

  // Future<String?> getOrgName() async {
  //   return await AppSharedPreferences.getValue(key: 'orgName');
  // }

  String _getTimeAgo(DateTime utcTime) {
    return moment.from(utcTime.toLocal());
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<String?> getDeviceToken() async {
    return await AppSharedPreferences.getValue(key: 'deviceToken');
  }

  Future<String?> _getProfilePic() async {
    return await AppSharedPreferences.getValue(key: 'profilePic');
  }
}

Future<String?> getTownhallView() async {
  return await AppSharedPreferences.getValue(key: 'townhallView');
}

class Like {
  bool isLiked;
  int likeCounts;

  Like({required this.isLiked, required this.likeCounts});
}
