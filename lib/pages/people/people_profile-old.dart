// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:getwidget/getwidget.dart' as gw;
// //import 'package:getwidget/components/loader/gf_loader.dart';
// import 'package:intl/intl.dart';
// import 'package:nahere/bloc/messages/messages_bloc.dart' as m;
// import 'package:nahere/bloc/posts/posts_bloc.dart' as p;
// import 'package:nahere/bloc/posts/posts_bloc.dart';
// import 'package:nahere/bloc/search/people_bloc.dart' as pe;
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/injector_container.dart';
// import 'package:nahere/models/Follow/followees_response.dart';
// import 'package:nahere/models/Follow/followers_response.dart';
// import 'package:nahere/models/Follow/verify_following_response.dart';
// import 'package:nahere/models/feed/feed_request.dart';
// import 'package:nahere/models/feed/feed_response.dart';
// import 'package:nahere/models/feed/topfeed_response.dart';
// import 'package:nahere/models/profile/get_profile_response.dart';
// import 'package:nahere/pages/comments/comments.dart';
// import 'package:nahere/pages/message/chat_history.dart';
// import 'package:nahere/pages/profile/profile.dart';
// import 'package:nahere/pages/suggestion/suggestion.dart';
// import 'package:nahere/widget/image_swipe.dart';
// import 'package:retrofit/http.dart';
// import 'package:nahere/common/common/constants.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

// class PeopleProfile extends StatefulWidget {
//   static String routeName = 'people_profile';
//   final String subjectID;
//   const PeopleProfile({Key? key, required this.subjectID}) : super(key: key);

//   @override
//   State<PeopleProfile> createState() => _PeopleProfileState();
// }

// class _PeopleProfileState extends State<PeopleProfile> {
//   List<dynamic> data = [];
//   List<TopFeedData> topFeed = [];
//   List<FollowersData> followers = [];
//   List<FolloweesData> followees = [];

//   List<GetVerifyFollowingResponse> Followingdata = [];
//   bool loading = true;
//   int noFollowing = 0;
//   int noFollowers = 0;

//   String userID = "";
//   String groupId = "";
//   bool followingStatus = false;
//   String last_post_id = '';
//   String share_link = "";
//   String first_post_id = '';
//   bool isLiked = false;
//   String clickedPostID = '';
//   bool isTownhallView = false;
//   bool reloadTop = false;

//   bool olderLoader = false;
//   bool newLoader = false;
//   String older_or_newer = '';
//   String likeSubjectID = "";
//   bool showLikeLoader = false;
//   bool isThereResult = false;
//   String orgId = '';
//   bool isNoParty = false; //if not party yet.
//   bool firstTimeLoading = true;
//   bool isLoadingUpRequest = false; //This tell if loading up is feeding data now
//   ScrollController _scrollController = ScrollController();
//   bool isNoNetwork = false;
//   String networkMsg = "";
//   String selfView = "yes";
//   bool _isFollowing = false;
//   bool scroll_visibility = true;
//   bool _showSlideUpPanel = false;
//   String _slideUpTitle = "";
//   String _showSlideUpFor = "";
//   PanelController _pc = new PanelController();
//   final _formKey = GlobalKey<FormState>();
//   final _controllerComment = TextEditingController();
//   bool isLastDownRequest =
//       false; //No more data to fetch from database for scroll down
//   String firstname = "",
//       lastname = "",
//       username = "",
//       about = "",
//       support_group = "",
//       state_name = "",
//       country_name = "",
//       lga_name = "",
//       ward_name = "",
//       email = "",
//       pu = "",
//       dob = "",
//       profession = "",
//       profession_description = "",
//       pics =
//           "https://nahere.com/files/images/user_profile_images/mid_default.png";
//   String req_status = "";

//   @override
//   void initState() {
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         if (isLastDownRequest == false) {
//           _getOlderPosts(20);
//         }
//       }
//       // else if (_scrollController.position.pixels ==
//       //     _scrollController.position.minScrollExtent) {
//       //   if (isLoadingUpRequest == false) {
//       //     _getNewerPosts(20);
//       //   }
//       // }
//       if (_scrollController.position.pixels > 180)
//         scroll_visibility = false;
//       else
//         scroll_visibility = true;
//       setState(() {});
//     });
//     Future.delayed(Duration.zero, () {
//       // setState(() {
//       //   userID = ModalRoute.of(context)!.settings.arguments as String;
//       // });

//       BlocProvider.of<pe.PeopleBloc>(context).add(
//         pe.GetPeoplePostsEvent(clickedUserID: widget.subjectID),
//       );
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async => !Loader.isShown,
//       child: Scaffold(
//           appBar: PreferredSize(
//             preferredSize: Size.fromHeight(25.0),
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0.0,
//               leading: SizedBox(
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   color: Colors.blue,
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//               actions: [
//                 // IconButton(
//                 //   onPressed: () async {
//                 //     var userID = await getUserID();
//                 //     Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 //       return BlocProvider(
//                 //         create: (context) => m.MessagesBloc(),
//                 //         child: ChatHistoryScreen(
//                 //           co_chatter: widget.subjectID,
//                 //           profile_name: firstname + ' ' + lastname,
//                 //           profile_pics: pics,
//                 //           userID: userID.toString(),
//                 //         ),
//                 //       );
//                 //     }));
//                 //   },
//                 //   icon: Icon(Icons.mail_outline, color: Colors.red),
//                 // ),
//                 selfView == "yes"
//                     ? SizedBox()
//                     : PopupMenuButton(
//                         onSelected: (int) {
//                           if (int == "Block user" || int == "Unblock user") {
//                             var parts = int.toString().split(' ');
//                             //print(parts[0].toLowerCase());
//                             Loader.show(
//                               context,
//                               //isSafeAreaOverlay: false,
//                               //isBottomBarOverlay: false,
//                               //overlayFromBottom: 80,
//                               overlayColor: Colors.black26,
//                               progressIndicator: Container(
//                                 width: 200.0,
//                                 height: 120.0,
//                                 child: Column(
//                                   children: [
//                                     SpinKitCircle(
//                                       color: Colors.blue,
//                                       size: 45.0,
//                                     ),
//                                     Text(
//                                       '${parts[0].toLowerCase()}ing...',
//                                       style: TextStyle(
//                                           fontSize: 17,
//                                           decoration: TextDecoration.none,
//                                           color: Colors.black54),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             );

//                             BlocProvider.of<pe.PeopleBloc>(context).add(
//                               pe.BlockUserEvent(
//                                   subjectID: widget.subjectID,
//                                   req_type: parts[0].toLowerCase()),
//                             );
//                           } else {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext contextTwo) {
//                                 return AlertDialog(
//                                   scrollable: true,
//                                   title: Text('Report User'),
//                                   content: Container(
//                                     height: 175.0,
//                                     width: 350.0,
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           child: SizedBox(
//                                             child: TextFormField(
//                                               maxLength: 300,
//                                               maxLines: 3,
//                                               minLines: 1,
//                                               keyboardType: TextInputType.text,
//                                               decoration: InputDecoration(
//                                                   border: OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15.0)),
//                                                   labelText: 'Comment',
//                                                   hintText: 'Enter Comment',
//                                                   contentPadding:
//                                                       EdgeInsets.symmetric(
//                                                           vertical: 20.0,
//                                                           horizontal: 10.0)),
//                                               controller: _controllerComment,
//                                               validator: (value) {
//                                                 if (value == null ||
//                                                     value.isEmpty) {
//                                                   return 'Please Enter Comment';
//                                                   final snackBar = SnackBar(
//                                                     content: Text(
//                                                         'Please Enter Comment'),
//                                                     backgroundColor:
//                                                         Colors.green.shade300,
//                                                   );
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(snackBar);
//                                                 }
//                                                 return null;
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: 2.0,
//                                         ),
//                                         SizedBox(
//                                           height: 50,
//                                           child: ElevatedButton(
//                                             style: raisedButtonStyleGreen,
//                                             onPressed: () {
//                                               if (_formKey.currentState!
//                                                   .validate()) {
//                                                 BlocProvider.of<p.PostsBloc>(
//                                                         context)
//                                                     .add(
//                                                   p.ReportAbuseEvent(
//                                                       comment:
//                                                           _controllerComment
//                                                               .text,
//                                                       post_id: '',
//                                                       reported:
//                                                           widget.subjectID),
//                                                 );
//                                               }
//                                             },
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 const Text(
//                                                   'Submit',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 20.0),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           }
//                         },
//                         icon: ImageIcon(
//                           AssetImage("images/dots.png"),
//                           color: Colors.grey,
//                           size: 20.0,
//                         ),
//                         padding: EdgeInsets.zero,
//                         itemBuilder: (BuildContext context) {
//                           return [
//                             'Report user',
//                             '${capitalize(req_status)} user'
//                           ].map((String choice) {
//                             return PopupMenuItem<String>(
//                               value: choice,
//                               child: Text(choice),
//                             );
//                           }).toList();
//                         },
//                       )
//               ],
//             ),
//           ),
//           body: SlidingUpPanel(
//             minHeight: 0.0,
//             maxHeight: size.height - 150,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20.0),
//               topRight: Radius.circular(20.0),
//             ),
//             onPanelClosed: () {
//               setState(() {
//                 _showSlideUpPanel = false;
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
//                                 loading
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
//                                           _showSlideUpFor == "followers"
//                                               ? Container(
//                                                   child: ListView.separated(
//                                                       shrinkWrap: true,
//                                                       separatorBuilder:
//                                                           (BuildContext context,
//                                                                   int index) =>
//                                                               Divider(
//                                                                   height: 2),
//                                                       itemCount:
//                                                           followers.length,
//                                                       itemBuilder:
//                                                           (context, index) {
//                                                         final list =
//                                                             followers[index];

//                                                         return ListTile(
//                                                           minVerticalPadding:
//                                                               10.0,
//                                                           title:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.username),
//                                                                 );
//                                                               }));
//                                                             },
//                                                             child: Text(
//                                                               "${list.followerName}",
//                                                               style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold),
//                                                             ),
//                                                           ),
//                                                           subtitle:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.followerID),
//                                                                 );
//                                                               }));
//                                                             },
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                     '@${list.username}'),
//                                                                 Text(
//                                                                   "${list.state_name}",
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
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.followerID),
//                                                                 );
//                                                               }));
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
//                                                                   list.photo_path,
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
//                                           _showSlideUpFor == "followings"
//                                               ? Container(
//                                                   child: ListView.separated(
//                                                       shrinkWrap: true,
//                                                       separatorBuilder:
//                                                           (BuildContext context,
//                                                                   int index) =>
//                                                               Divider(
//                                                                   height: 2),
//                                                       itemCount:
//                                                           followees.length,
//                                                       itemBuilder:
//                                                           (context, index) {
//                                                         final list =
//                                                             followees[index];

//                                                         return ListTile(
//                                                           minVerticalPadding:
//                                                               10.0,
//                                                           title:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.username),
//                                                                 );
//                                                               }));
//                                                             },
//                                                             child: Text(
//                                                               "${list.followeeName}",
//                                                               style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold),
//                                                             ),
//                                                           ),
//                                                           subtitle:
//                                                               GestureDetector(
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.followeeID),
//                                                                 );
//                                                               }));
//                                                             },
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                     '@${list.username}'),
//                                                                 Text(
//                                                                   "${list.state_name}",
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
//                                                               Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) {
//                                                                 return MultiBlocProvider(
//                                                                   providers: [
//                                                                     BlocProvider(
//                                                                       create: (contextA) =>
//                                                                           pe.PeopleBloc(),
//                                                                     ),
//                                                                     BlocProvider(
//                                                                       create: (context) =>
//                                                                           PostsBloc(),
//                                                                     ),
//                                                                   ],
//                                                                   child: PeopleProfile(
//                                                                       subjectID:
//                                                                           list.followeeID),
//                                                                 );
//                                                               }));
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
//                                                                   list.photo_path,
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
//             body: MultiBlocListener(
//               listeners: [
//                 BlocListener<pe.PeopleBloc, pe.PeopleState>(
//                   listener: (context, state) {
//                     if (state is pe.GetFolloweesState) {
//                       setState(() {
//                         followees = state.getFolloweesResponse.data!;
//                         loading = false;
//                       });
//                     }
//                     if (state is pe.GetFollowersState) {
//                       setState(() {
//                         followers = state.getFollowersResponse.data!;
//                         loading = false;
//                       });
//                     }
//                     if (state is pe.GetPeoplePostsState) {
//                       loading = false;
//                       setState(() {
//                         firstname = state.profileResponse.data!.firstname;
//                         lastname = state.profileResponse.data!.lastname;
//                         username = state.profileResponse.data!.username;
//                         about = state.profileResponse.data!.about_me == null
//                             ? ""
//                             : state.profileResponse.data!.about_me;
//                         profession =
//                             state.profileResponse.data!.profession == null
//                                 ? ""
//                                 : state.profileResponse.data!.profession;
//                         profession_description = state.profileResponse.data!
//                                     .profession_category_txt ==
//                                 null
//                             ? ""
//                             : state
//                                 .profileResponse.data!.profession_category_txt;
//                         pics = state.profileResponse.data!.photo_path_mid;
//                         email = state.profileResponse.data!.email;
//                         lga_name = state.profileResponse.data!.lga_name == null
//                             ? ""
//                             : state.profileResponse.data!.lga_name;
//                         state_name =
//                             state.profileResponse.data!.state_name == null
//                                 ? ""
//                                 : state.profileResponse.data!.state_name;
//                         ward_name =
//                             state.profileResponse.data!.ward_name == null
//                                 ? ""
//                                 : state.profileResponse.data!.ward_name;
//                         country_name =
//                             state.profileResponse.data!.country_name == null
//                                 ? ""
//                                 : state.profileResponse.data!.country_name;
//                         pu = state.profileResponse.data!.pu_name == null
//                             ? ""
//                             : state.profileResponse.data!.pu_name;
//                         final DateTime db = new DateFormat("yyyy-MM-dd")
//                             .parse(state.profileResponse.data!.dob);

//                         dob = DateFormat('MMMd').format(db);
//                         data = state.feedResponse.data!;
//                         // followingStatus =
//                         //     state.followingResponse.data!.isFollowing == 'Yes'
//                         //         ? true
//                         //         : false;
//                         // noFollowers = state.totalFollowers.count;
//                         // noFollowing = state.totalFollowing.count;
//                         userID = state.profileResponse.data!.user_id;
//                         selfView = state.profileResponse.data!.self_view;
//                         share_link = state.profileResponse.data!.share_link;
//                         _isFollowing =
//                             state.profileResponse.data!.is_following == "yes"
//                                 ? true
//                                 : false;

//                         print('SubjectID: ${widget.subjectID} UserID: $userID');
//                       });
//                       req_status = state.profileResponse.data!.blocked_or_not ==
//                               "blocked"
//                           ? "unblock"
//                           : "block";
//                       // if (state.profileResponse.data!.blocked_or_not) {

//                       // }
//                     }
//                     if (state is pe.PeopleLoadingState) {}
//                     if (state is BlockUserState) {
//                       // @override
//                       // void dispose() {
//                       //   Loader.hide();
//                       //   super.dispose();
//                       // }

//                       Loader.hide();
//                       final snackBar = SnackBar(
//                           backgroundColor: Color.fromARGB(255, 85, 207, 158),
//                           content: Text('User successfully ${req_status}ed'));
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                       req_status =
//                           req_status == "unblock" ? "block" : "unblock";
//                     }
//                     if (state is ErrorState) {
//                       final snackBar = SnackBar(
//                           backgroundColor: Color(0xFFcf5555),
//                           content: Text('An error has occurred'));
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     }
//                   },
//                 ),
//                 BlocListener<p.PostsBloc, p.PostsState>(
//                   listener: (context, state) {
//                     if (state is p.NoResultState) {
//                       print(
//                           "is there result: ${isThereResult}} Loading: ${loading} older_newer: ${older_or_newer}");
//                       isThereResult = false;

//                       setState(() {
//                         isLoadingUpRequest = false;
//                         isLastDownRequest = false;
//                         isNoNetwork = false;
//                         olderLoader = false;
//                         showLikeLoader = false;
//                         loading = false;
//                         reloadTop = false;
//                       });
//                     }
//                     // if (state is LoadingState && olderLoader == false) {
//                     //   if (showLikeLoader == false) {
//                     //     loading = true;
//                     //   }
//                     //   loading = false;
//                     //   olderLoader = false;
//                     //   newLoader = false;
//                     //   reloadTop = false;
//                     //   print("P1");
//                     // }

//                     // if (state is LoadingState) {
//                     //   loading = true;
//                     // }
//                     if (state is p.LoadingState) {
//                       if (olderLoader) {
//                         olderLoader = true;
//                       } else if (newLoader) {
//                         newLoader = true;
//                       } else if (reloadTop) {
//                         reloadTop = true;
//                       } else if (showLikeLoader) {
//                         showLikeLoader = true;
//                       } else {
//                         loading = true;
//                       }
//                       isNoNetwork = false;
//                       isThereResult = false;
//                     }

//                     if (state is p.GoToSuggestionState) {
//                       loading = false;
//                       reloadTop = false;
//                       isNoNetwork = false;
//                       Navigator.pushNamed(context, SuggestionScreen.routeName);
//                     }
//                     //Go to profile page
//                     if (state is p.GoToProfileState) {
//                       isNoNetwork = false;
//                       Navigator.pushNamed(context, Profile.routeName);
//                     }
//                     if (state is p.AbuseReportState) {
//                       Navigator.of(context, rootNavigator: true).pop();
//                       final snackBar = SnackBar(
//                         content: Text('Post was successfully reported'),
//                         backgroundColor: Colors.green.shade300,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                       _controllerComment.text = '';
//                     }
//                     if (state is p.FeedState) {
//                       //Navigator.pushNamed(context, SuggestionScreen.routeName);
//                       // print("P2");
//                       isLoadingUpRequest = false;
//                       isLastDownRequest = false;
//                       isNoNetwork = false;
//                       networkMsg = "";
//                       if (newLoader) {
//                         setState(() {
//                           showLikeLoader = false;
//                           likeSubjectID = "";
//                           //first_post_id = state.feedResponse[0].post_id;
//                           first_post_id = state.feedResponse.length < 1
//                               ? ''
//                               : state.feedResponse[0].post_id;
//                           loading = false;
//                           olderLoader = false;
//                           newLoader = false;
//                           reloadTop = false;
//                         });
//                       }

//                       if (state.feedResponse.length > 0) {
//                         data = state.feedResponse;

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
//                     if (state is p.NoPartyState) {
//                       setState(() {
//                         isNoParty = true;

//                         olderLoader = false;
//                         loading = false;
//                         newLoader = false;

//                         reloadTop = false;
//                       });
//                       isThereResult = true;
//                       isNoNetwork = false;
//                     }
//                     if (state is p.LikeState) {
//                       isLiked = true;
//                       loading = false;
//                       isNoNetwork = false;
//                       olderLoader = false;
//                       reloadTop = false;
//                       likeSubjectID = "";
//                       print(state.like.msg);
//                       print(state.like.status);

//                       BlocProvider.of<p.PostsBloc>(context).add(
//                         p.FeedEvent(
//                           feedRequest: FeedRequest(
//                               skipOnboarding: false,
//                               skipTopFeed: false,
//                               isFirstFeedRequest: false,
//                               last_post_id: '',
//                               group_id: groupId,
//                               org_id: orgId,
//                               page: '',
//                               limit: 20,
//                               older_or_newer: '',
//                               page_owner: ''),
//                         ),
//                       );
//                     }
//                     if (state is p.DeleteFeedState) {
//                       setState(() {
//                         loading = false;
//                         reloadTop = false;
//                         isNoNetwork = false;
//                       });

//                       print(state.deleteFeedResponse.msg);
//                       print(state.deleteFeedResponse.status);

//                       BlocProvider.of<p.PostsBloc>(context).add(
//                         p.FeedEvent(
//                           feedRequest: FeedRequest(
//                               skipOnboarding: false,
//                               skipTopFeed: false,
//                               isFirstFeedRequest: true,
//                               last_post_id: '',
//                               group_id: groupId,
//                               org_id: orgId,
//                               page: '',
//                               limit: 20,
//                               older_or_newer: '',
//                               page_owner: ''),
//                         ),
//                       );
//                     }

//                     if (state is p.UnLikeState) {
//                       setState(() {
//                         likeSubjectID = "";
//                         olderLoader = false;
//                         loading = false;
//                         isLiked = false;
//                         reloadTop = false;
//                         isNoNetwork = false;
//                       });

//                       print(state.unlike.msg);
//                       print(state.unlike.status);
//                       BlocProvider.of<p.PostsBloc>(context).add(
//                         p.FeedEvent(
//                           feedRequest: FeedRequest(
//                               skipOnboarding: false,
//                               skipTopFeed: false,
//                               isFirstFeedRequest: false,
//                               last_post_id: '',
//                               group_id: groupId,
//                               org_id: orgId,
//                               page: '',
//                               limit: 20,
//                               older_or_newer: '',
//                               page_owner: ''),
//                         ),
//                       );
//                     }
//                     if (state is p.ErrorState) {
//                       setState(() {
//                         isLoadingUpRequest = false;
//                         showLikeLoader = false;
//                         likeSubjectID = "";
//                         isLastDownRequest = false;
//                         olderLoader = false;
//                         loading = false;
//                         isNoNetwork = false;
//                       });

//                       print(state.message);
//                       final snackBar =
//                           SnackBar(content: Text(state.message.toString()));
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     }
//                     if (state is p.NetworkState) {
//                       setState(() {
//                         isLoadingUpRequest = false;
//                         showLikeLoader = false;
//                         likeSubjectID = "";
//                         isLastDownRequest = false;
//                         isNoNetwork = true;
//                         networkMsg = state.message!;

//                         olderLoader = false;
//                         loading = false;
//                         reloadTop = false;
//                         likeSubjectID = "";
//                       });
//                       isThereResult = false;
//                       final snackBar = SnackBar(
//                           backgroundColor: Color(0xFFcf5555),
//                           content: Text(state.message.toString()));
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     }
//                   },
//                 ),
//               ],
//               child: loading == false
//                   ? SafeArea(
//                       child: SingleChildScrollView(
//                         controller: _scrollController,
//                         physics: const ClampingScrollPhysics(),
//                         child: Column(
//                           children: [
//                             // SizedBox(
//                             //   height: 1.0,
//                             // ),
//                             // Padding(
//                             //   padding: const EdgeInsets.only(top: 5),
//                             //   child: Align(
//                             //     alignment: Alignment.topLeft,
//                             //     child: IconButton(
//                             //       icon: Icon(Icons.arrow_back),
//                             //       color: Colors.blue,
//                             //       onPressed: () {
//                             //         Navigator.pop(context);
//                             //       },
//                             //     ),
//                             //   ),
//                             // ),
//                             Visibility(
//                               visible: scroll_visibility,
//                               child: Container(
//                                 //profile
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 50,
//                                           backgroundColor: Colors.grey,
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(50),
//                                             child: Image.network(
//                                               pics,
//                                               width: 100,
//                                               height: 100,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Column(
//                                       children: [
//                                         Container(
//                                           child: Text(
//                                             firstname + " " + lastname,
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 20),
//                                           ),
//                                         ),
//                                         Container(
//                                           child: Text(
//                                             "@${username}",
//                                             style: TextStyle(
//                                                 color: Colors.black26,
//                                                 fontSize: 19),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: 10,
//                                         )
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: selfView == "yes"
//                                           ? MainAxisAlignment.center
//                                           : MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         selfView == "yes"
//                                             ? SizedBox()
//                                             : gw.GFButton(
//                                                 onPressed: () {
//                                                   if (_isFollowing) {
//                                                     BlocProvider.of<
//                                                                 pe.PeopleBloc>(
//                                                             context)
//                                                         .add(pe.UnFollowEvent(
//                                                             followee: int.parse(
//                                                                 widget
//                                                                     .subjectID)));
//                                                     //unfollow
//                                                     setState(() {
//                                                       _isFollowing =
//                                                           !_isFollowing;
//                                                     });
//                                                   } else {
//                                                     BlocProvider.of<
//                                                                 pe.PeopleBloc>(
//                                                             context)
//                                                         .add(pe.FollowEvent(
//                                                             followee: int.parse(
//                                                                 widget
//                                                                     .subjectID)));
//                                                     //follow
//                                                     setState(() {
//                                                       _isFollowing =
//                                                           !_isFollowing;
//                                                     });
//                                                   }
//                                                 },
//                                                 text:
//                                                     ("${_isFollowing ? "Unfollow" : "Follow"}"),
//                                                 shape: gw.GFButtonShape.pills,
//                                                 color: _isFollowing
//                                                     ? Colors.red
//                                                     : Colors.blue,
//                                               ),
//                                         selfView == "yes"
//                                             ? SizedBox()
//                                             : IconButton(
//                                                 iconSize: 35.0,
//                                                 onPressed: () async {
//                                                   var userID =
//                                                       await getUserID();
//                                                   Navigator.push(context,
//                                                       MaterialPageRoute(
//                                                           builder: (context) {
//                                                     return BlocProvider(
//                                                       create: (context) =>
//                                                           m.MessagesBloc(),
//                                                       child: ChatHistoryScreen(
//                                                         co_chatter:
//                                                             widget.subjectID,
//                                                         profile_name:
//                                                             firstname +
//                                                                 ' ' +
//                                                                 lastname,
//                                                         profile_pics: pics,
//                                                         userID:
//                                                             userID.toString(),
//                                                       ),
//                                                     );
//                                                   }));
//                                                 },
//                                                 icon: Icon(Icons.mail_outline,
//                                                     color: Colors.blue),
//                                               ),
//                                         share_link == "" || share_link == null
//                                             ? SizedBox()
//                                             : IconButton(
//                                                 icon: Icon(
//                                                   Icons.share,
//                                                   color: Colors.blue,
//                                                 ),
//                                                 onPressed: () async {
//                                                   share(
//                                                     share_link,
//                                                     '',
//                                                   );
//                                                 },
//                                               ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // GestureDetector(
//                                         //   onTap: noFollowers == 0 ||
//                                         //           noFollowers == null
//                                         //       ? null
//                                         //       : () {
//                                         //           setState(() {
//                                         //             _slideUpTitle =
//                                         //                 "Followers(${noFollowing})";
//                                         //             _showSlideUpFor =
//                                         //                 "followers";
//                                         //             loading = true;
//                                         //           });
//                                         //           BlocProvider.of<
//                                         //                       pe.PeopleBloc>(
//                                         //                   context)
//                                         //               .add(pe.GetFollowersEvent(
//                                         //                   subjectID:
//                                         //                       widget.subjectID,
//                                         //                   limit: '',
//                                         //                   page: '1'));
//                                         //           print(
//                                         //               "Followers was clicked");
//                                         //         },
//                                         //child:
//                                         Column(
//                                           children: [
//                                             Center(
//                                               child: Text(
//                                                 NumberFormat.compact()
//                                                     .format(noFollowers),
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 15.0,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 5.0,
//                                             ),
//                                             Text(
//                                               "Followers",
//                                               style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 15.0,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         // ),
//                                         SizedBox(
//                                           width: 20,
//                                         ),
//                                         // GestureDetector(
//                                         //   onTap: null
//                                         //       : () {
//                                         // setState(() {
//                                         //   _slideUpTitle =
//                                         //       "Followings(${noFollowing})";
//                                         //   _showSlideUpFor =
//                                         //       "followings";
//                                         //   loading = true;
//                                         // });
//                                         // _pc.open();
//                                         //   BlocProvider.of<
//                                         //               pe.PeopleBloc>(
//                                         //           context)
//                                         //       .add(pe.GetFolloweesEvent(
//                                         //           subjectID:
//                                         //               widget.subjectID,
//                                         //           limit: '',
//                                         //           page: '1'));
//                                         //   print(
//                                         //       "Followees was clicked");
//                                         // },
//                                         // child:
//                                         Column(
//                                           children: [
//                                             Center(
//                                               child: Text(
//                                                 NumberFormat.compact()
//                                                     .format(noFollowing),
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 14.0,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             Center(
//                                               child: Text(
//                                                 "Followings",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 14.0,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         // ),
//                                       ],
//                                     ),

//                                     //Birthday start
//                                     SizedBox(
//                                         height:
//                                             dob == null || dob == "" ? 0 : 20),
//                                     dob == null || dob == ""
//                                         ? SizedBox()
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 24.0),
//                                                 child: Container(
//                                                   width: size.width - 45,
//                                                   child: Row(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       SizedBox(
//                                                         width: 20,
//                                                         height: 40,
//                                                         child: IconButton(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 0),
//                                                           alignment:
//                                                               Alignment.topLeft,
//                                                           icon:
//                                                               Icon(Icons.cake),
//                                                           color:
//                                                               Colors.grey[400],
//                                                           onPressed: () {},
//                                                         ),
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 top: 5.0,
//                                                                 left: 24),
//                                                         child: Text(
//                                                           "${dob}",
//                                                           style: TextStyle(
//                                                             color: Colors.black,
//                                                             fontSize: 16.0,
//                                                           ),
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                     //dob end

//                                     //about start
//                                     SizedBox(
//                                         height: about == null || about == ""
//                                             ? 0
//                                             : 2),
//                                     about == null || about == ""
//                                         ? SizedBox()
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 24.0),
//                                                 child: Container(
//                                                   width: size.width - 45,
//                                                   child: Row(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       SizedBox(
//                                                         width: 20,
//                                                         height: 40,
//                                                         child: IconButton(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 0),
//                                                           alignment:
//                                                               Alignment.topLeft,
//                                                           icon: Icon(
//                                                               Icons.people),
//                                                           color:
//                                                               Colors.grey[400],
//                                                           onPressed: () {},
//                                                         ),
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 top: 5.0,
//                                                                 left: 24),
//                                                         child: Container(
//                                                           width:
//                                                               size.width - 89,
//                                                           child: Text(
//                                                             "${about}",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 16.0,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                     //about end

//                                     //location start
//                                     SizedBox(
//                                         height: state_name == null ||
//                                                 state_name == ""
//                                             ? 0
//                                             : 10),
//                                     state_name == null || state_name == ""
//                                         ? SizedBox()
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 24.0),
//                                                 child: Container(
//                                                   width: size.width - 45,
//                                                   child: Row(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       SizedBox(
//                                                         width: 20,
//                                                         height: 40,
//                                                         child: IconButton(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 0),
//                                                           alignment:
//                                                               Alignment.topLeft,
//                                                           icon: Icon(Icons
//                                                               .location_on),
//                                                           color:
//                                                               Colors.grey[400],
//                                                           onPressed: () {},
//                                                         ),
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 top: 5.0,
//                                                                 left: 24),
//                                                         child: Container(
//                                                           width:
//                                                               size.width - 95,
//                                                           child: Text(
//                                                             "${state_name} > ${lga_name} > ${ward_name}",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 16.0,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                     //location end

//                                     //support group start
//                                     SizedBox(
//                                       height: support_group == null ||
//                                               support_group == ""
//                                           ? 0
//                                           : 10,
//                                     ),
//                                     support_group == null || support_group == ""
//                                         ? SizedBox()
//                                         : Row(children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 24.0, top: 20),
//                                               child: SizedBox(
//                                                 width: 20,
//                                                 height: 40,
//                                                 child: IconButton(
//                                                   padding:
//                                                       EdgeInsets.only(top: 0),
//                                                   alignment: Alignment.topLeft,
//                                                   icon: Icon(Icons.people),
//                                                   color: Colors.grey[400],
//                                                   onPressed: () {},
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: size.width - 80,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 24),
//                                                 child: Text(
//                                                   support_group,
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 16.0),
//                                                 ),
//                                               ),
//                                             ),
//                                           ]),
//                                     //support group end
//                                     //divider start
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 35.0, right: 35.0),
//                                       child: Divider(color: Colors.grey[400]),
//                                     )

//                                     //divider end
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Form(
//                               key: _formKey,
//                               child: ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 //itemExtent: 20,
//                                 // Let the ListView know how many items it needs to build.
//                                 itemCount: isThereResult
//                                     ? data.length + 1
//                                     : data.length,
//                                 // Provide a builder function. This is where the magic happens.
//                                 // Convert each item into a widget based on the type of item it is.

//                                 itemBuilder: (context, index) {
//                                   print("Data Index: ${index}");
//                                   if (index == data.length) {
//                                     isLastDownRequest = index < 20
//                                         ? true
//                                         : false; //This is the last down request. No more data to load again.
//                                     return Container(
//                                       width: 80.0,
//                                       height: 80.0,
//                                       child: data.length == 1
//                                           ? SizedBox()
//                                           : Container(
//                                               child: index < 20
//                                                   ? null
//                                                   : SpinKitCircle(
//                                                       color: Colors.blue,
//                                                       size: 50.0,
//                                                     ),
//                                             ),
//                                     );
//                                   }
//                                   if (last_post_id.isEmpty || newLoader) {
//                                     first_post_id = data[0].post_id;
//                                   }
//                                   final item = data[index];
//                                   List<dynamic> imageList = [];
//                                   last_post_id = item.post_id;

//                                   if (item.post_images != null) {
//                                     print("My first post: " + data[0].post_id);

//                                     for (FeedImagesData image
//                                         in item.post_images!) {
//                                       imageList.add(image.name);
//                                     }
//                                   }

//                                   DateTime startTime =
//                                       new DateFormat("yyyy-MM-dd hh:mm:ss")
//                                           .parse(item.post_updated_time);
//                                   DateTime currentTime = new DateTime.now();
//                                   var diff_dy =
//                                       currentTime.difference(startTime).inDays;
//                                   var diff_hr =
//                                       currentTime.difference(startTime).inHours;
//                                   var diff_mn = currentTime
//                                       .difference(startTime)
//                                       .inMinutes;
//                                   var diff_sc = currentTime
//                                       .difference(startTime)
//                                       .inSeconds;
//                                   print(
//                                       'difference = ${item.post_updated_time}');
//                                   print('difference = ${startTime}');
//                                   print('difference = ${currentTime}');
//                                   print('difference = $diff_dy');
//                                   print('difference = $diff_hr');
//                                   print('difference = $diff_mn');
//                                   print('difference = $diff_sc');
//                                   var deference = '';
//                                   if (diff_dy > 0) {
//                                     deference =
//                                         deference + diff_dy.toString() + "d";
//                                   } else {
//                                     if (diff_hr > 0) {
//                                       deference =
//                                           deference + diff_hr.toString() + "h";
//                                     } else {
//                                       if (diff_mn > 0) {
//                                         deference = deference +
//                                             diff_mn.toString() +
//                                             "m";
//                                       } else {
//                                         if (diff_sc > 0) {
//                                           deference = deference +
//                                               diff_sc.toString() +
//                                               "s";
//                                         }
//                                       }
//                                     }
//                                   }
//                                   return item.can_delete == 'no'
//                                       ? Column(
//                                           children: [
//                                             Container(
//                                               color:
//                                                   item.noticeboard_msg == "yes"
//                                                       ? Color(0xffCCE9FD)
//                                                       : null,
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Padding(
//                                                       padding: const EdgeInsets
//                                                           .fromLTRB(
//                                                           9.0, 9.0, 6.0, 8.0),
//                                                       child: CircleAvatar(
//                                                         radius: 30,
//                                                         backgroundColor:
//                                                             Colors.grey,
//                                                         child: ClipRRect(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(50),
//                                                           child: Image.network(
//                                                             item.post_profile_pics,
//                                                             width: 55,
//                                                             height: 55,
//                                                             fit: BoxFit.cover,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Expanded(
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(1.0),
//                                                         child: Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .stretch,
//                                                           children: [
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(4.0),
//                                                               child: Row(
//                                                                 children: [
//                                                                   GestureDetector(
//                                                                     onTap: () {
//                                                                       // groupId = item
//                                                                       //     .post_group_id
//                                                                       //     .toString();
//                                                                       // BlocProvider.of<PostsBloc>(context)
//                                                                       //     .add(
//                                                                       //   FeedEvent(
//                                                                       //     feedRequest: FeedRequest(last_post_id: last_post_id, group_id: item.post_group_id.toString(), post_id: '', limit: 20, older_or_newer: older_or_newer, page_owner: ''),

//                                                                       //   ),

//                                                                       // );
//                                                                       // Navigator.push(
//                                                                       //     context,
//                                                                       //     MaterialPageRoute(builder:
//                                                                       //         (context) {
//                                                                       //   return BlocProvider(
//                                                                       //     create: (context) =>
//                                                                       //         p.PeopleBloc(),
//                                                                       //     child:
//                                                                       //         PeopleProfile(subjectID: item.posted_by),
//                                                                       //   );
//                                                                       // }));
//                                                                     },
//                                                                     child: Text(
//                                                                       _substring(
//                                                                           item.post_update_by,
//                                                                           15,
//                                                                           ''),
//                                                                       style: TextStyle(
//                                                                           fontWeight: FontWeight
//                                                                               .bold,
//                                                                           fontSize:
//                                                                               15),
//                                                                     ),
//                                                                   ),
//                                                                   Text(
//                                                                     '. ' +
//                                                                         _getTimeAgo(
//                                                                             startTime),
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .grey),
//                                                                   ),
//                                                                   //Spacer(),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(
//                                                                       04.0),
//                                                               child: Linkify(
//                                                                   options: LinkifyOptions(
//                                                                       humanize:
//                                                                           false),
//                                                                   onOpen:
//                                                                       _onOpen,
//                                                                   text: item
//                                                                       .post_message,
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           15)),
//                                                             ),
//                                                             if (imageList
//                                                                     .length >
//                                                                 0)
//                                                               ImageSwipe(
//                                                                   imageList:
//                                                                       imageList),
//                                                             Row(
//                                                               children: [
//                                                                 IconButton(
//                                                                   icon: Icon(
//                                                                     Icons
//                                                                         .messenger_outline,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                   ),
//                                                                   onPressed:
//                                                                       () async {
//                                                                     await Navigator.pushNamed(
//                                                                             context,
//                                                                             Comments
//                                                                                 .routeName,
//                                                                             arguments:
//                                                                                 item)
//                                                                         .then(
//                                                                             (result) {
//                                                                       if (result ==
//                                                                           'refresh') {
//                                                                         BlocProvider.of<p.PostsBloc>(context)
//                                                                             .add(
//                                                                           p.FeedEvent(
//                                                                             feedRequest: FeedRequest(
//                                                                               townhall_tap: false,
//                                                                                 skipOnboarding: false,
//                                                                                 skipTopFeed: false,
//                                                                                 isFirstFeedRequest: false,
//                                                                                 last_post_id: '',
//                                                                                 group_id: groupId,
//                                                                                 org_id: orgId,
//                                                                                 page: '',
//                                                                                 limit: 20,
//                                                                                 older_or_newer: '',
//                                                                                 page_owner: ''),
//                                                                           ),
//                                                                         );
//                                                                       }
//                                                                     });
//                                                                   },
//                                                                 ),
//                                                                 Text(
//                                                                     numberFormat(item
//                                                                         .comment_count),
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .grey)),
//                                                                 (showLikeLoader &&
//                                                                         likeSubjectID ==
//                                                                             item.post_id)
//                                                                     ? Container(
//                                                                         width:
//                                                                             30.0,
//                                                                         height:
//                                                                             30.0,
//                                                                         child:
//                                                                             SpinKitCircle(
//                                                                           color:
//                                                                               Colors.blue,
//                                                                           size:
//                                                                               20.0,
//                                                                         ),
//                                                                       )
//                                                                     : IconButton(
//                                                                         icon:
//                                                                             Icon(
//                                                                           item.is_liked == 'yes'
//                                                                               ? Icons.favorite
//                                                                               : Icons.favorite_outline,
//                                                                           color: item.is_liked == 'yes'
//                                                                               ? Colors.red
//                                                                               : Colors.grey,
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {
//                                                                           setState(
//                                                                               () {
//                                                                             showLikeLoader =
//                                                                                 true;
//                                                                             likeSubjectID =
//                                                                                 item.post_id;
//                                                                           });
//                                                                           if (item.is_liked ==
//                                                                               'yes') {
//                                                                             clickedPostID =
//                                                                                 item.post_id;
//                                                                             BlocProvider.of<p.PostsBloc>(context).add(
//                                                                               p.UnLikePostEvent(post_id: item.post_id),
//                                                                             );
//                                                                           } else {
//                                                                             clickedPostID =
//                                                                                 item.post_id;
//                                                                             BlocProvider.of<p.PostsBloc>(context).add(
//                                                                               p.LikePostEvent(post_id: item.post_id),
//                                                                             );
//                                                                           }
//                                                                         },
//                                                                       ),
//                                                                 Text(
//                                                                     numberFormat(item
//                                                                         .like_count),
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .grey)),
//                                                                 IconButton(
//                                                                   icon: Icon(
//                                                                     Icons.share,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                   ),
//                                                                   onPressed:
//                                                                       () async {
//                                                                     share(
//                                                                       item.sharelink,
//                                                                       '',
//                                                                     );
//                                                                   },
//                                                                 ),
//                                                               ],
//                                                             )
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       height: 28,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(top: 8),
//                                                         child: PopupMenuButton(
//                                                           icon: ImageIcon(
//                                                             AssetImage(
//                                                                 "images/dots.png"),
//                                                             color: Colors.grey,
//                                                             size: 20.0,
//                                                           ),
//                                                           onSelected: (int) {
//                                                             showDialog(
//                                                               context: context,
//                                                               builder:
//                                                                   (BuildContext
//                                                                       contextTwo) {
//                                                                 return AlertDialog(
//                                                                   scrollable:
//                                                                       true,
//                                                                   title: Text(
//                                                                       'Report'),
//                                                                   content:
//                                                                       Container(
//                                                                     height:
//                                                                         175.0,
//                                                                     width:
//                                                                         350.0,
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           child:
//                                                                               SizedBox(
//                                                                             child:
//                                                                                 TextFormField(
//                                                                               maxLength: 300,
//                                                                               maxLines: 3,
//                                                                               minLines: 1,
//                                                                               keyboardType: TextInputType.text,
//                                                                               decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), labelText: 'Comment', hintText: 'Enter Comment', contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
//                                                                               controller: _controllerComment,
//                                                                               validator: (value) {
//                                                                                 if (value == null || value.isEmpty) {
//                                                                                   return 'Please Enter Comment';
//                                                                                   final snackBar = SnackBar(
//                                                                                     content: Text('Please Enter Comment'),
//                                                                                     backgroundColor: Colors.green.shade300,
//                                                                                   );
//                                                                                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                                                 }
//                                                                                 return null;
//                                                                               },
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               2.0,
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               50,
//                                                                           child:
//                                                                               ElevatedButton(
//                                                                             style:
//                                                                                 raisedButtonStyleGreen,
//                                                                             onPressed:
//                                                                                 () {
//                                                                               if (_formKey.currentState!.validate()) {
//                                                                                 BlocProvider.of<p.PostsBloc>(context).add(
//                                                                                   p.ReportAbuseEvent(comment: _controllerComment.text, post_id: item.post_id, reported: item.posted_by),
//                                                                                 );
//                                                                               }
//                                                                             },
//                                                                             child:
//                                                                                 Row(
//                                                                               mainAxisAlignment: MainAxisAlignment.center,
//                                                                               children: [
//                                                                                 const Text(
//                                                                                   'Submit',
//                                                                                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             );
//                                                           },
//                                                           padding:
//                                                               EdgeInsets.zero,
//                                                           itemBuilder:
//                                                               (BuildContext
//                                                                   context) {
//                                                             return ['Report']
//                                                                 .map((String
//                                                                     choice) {
//                                                               return PopupMenuItem<
//                                                                   String>(
//                                                                 value: choice,
//                                                                 child: Text(
//                                                                     choice),
//                                                               );
//                                                             }).toList();
//                                                           },
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Divider(),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             Divider(),
//                                           ],
//                                         )
//                                       : Slidable(
//                                           actionPane:
//                                               SlidableDrawerActionPane(),
//                                           actionExtentRatio: 0.25,
//                                           child: Container(
//                                             child: Column(
//                                               children: [
//                                                 Container(
//                                                   color: item.noticeboard_msg ==
//                                                           "yes"
//                                                       ? Color(0xffCCE9FD)
//                                                       : null,
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .fromLTRB(9.0,
//                                                                 9.0, 6.0, 8.0),
//                                                         child: CircleAvatar(
//                                                           radius: 30,
//                                                           backgroundColor:
//                                                               Colors.grey,
//                                                           child: ClipRRect(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         50),
//                                                             child:
//                                                                 Image.network(
//                                                               item.post_profile_pics,
//                                                               width: 55,
//                                                               height: 55,
//                                                               fit: BoxFit.cover,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Expanded(
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .stretch,
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         4.0),
//                                                                 child: Row(
//                                                                   children: [
//                                                                     GestureDetector(
//                                                                       onTap:
//                                                                           () {
//                                                                         // Navigator.push(
//                                                                         //     context,
//                                                                         //     MaterialPageRoute(builder: (context) {
//                                                                         //   return BlocProvider(
//                                                                         //     create: (context) => p.PeopleBloc(),
//                                                                         //     child: PeopleProfile(subjectID: item.posted_by),
//                                                                         //   );
//                                                                         // }));
//                                                                       },
//                                                                       child:
//                                                                           Text(
//                                                                         _substring(
//                                                                             item.post_update_by,
//                                                                             15,
//                                                                             ''),
//                                                                         style: TextStyle(
//                                                                             fontWeight:
//                                                                                 FontWeight.bold,
//                                                                             fontSize: 15),
//                                                                       ),
//                                                                     ),
//                                                                     Text(
//                                                                       '. ' +
//                                                                           _getTimeAgo(
//                                                                               startTime),
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               Colors.grey),
//                                                                     ),
//                                                                     Spacer(),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         4.0),
//                                                                 child: Linkify(
//                                                                     onOpen:
//                                                                         _onOpen,
//                                                                     text: item
//                                                                         .post_message,
//                                                                     style: TextStyle(
//                                                                         fontSize:
//                                                                             15)),
//                                                               ),
//                                                               if (imageList
//                                                                       .length >
//                                                                   0)
//                                                                 ImageSwipe(
//                                                                     imageList:
//                                                                         imageList),
//                                                               Row(
//                                                                 children: [
//                                                                   IconButton(
//                                                                     icon: Icon(
//                                                                       Icons
//                                                                           .messenger_outline,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                     ),
//                                                                     onPressed:
//                                                                         () async {
//                                                                       await Navigator.pushNamed(
//                                                                               context,
//                                                                               Comments.routeName,
//                                                                               arguments: item)
//                                                                           .then((result) {
//                                                                         if (result ==
//                                                                             'refresh') {
//                                                                           BlocProvider.of<p.PostsBloc>(context)
//                                                                               .add(
//                                                                             p.FeedEvent(
//                                                                               feedRequest: FeedRequest(skipOnboarding: false, skipTopFeed: false, isFirstFeedRequest: false, last_post_id: last_post_id, group_id: groupId, org_id: orgId, page: '', limit: 20, older_or_newer: older_or_newer, page_owner: '',townhall_tap: false),
//                                                                             ),
//                                                                           );
//                                                                         }
//                                                                       });
//                                                                     },
//                                                                   ),
//                                                                   Text(
//                                                                       numberFormat(item
//                                                                           .comment_count),
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               Colors.grey)),
//                                                                   (showLikeLoader &&
//                                                                           likeSubjectID ==
//                                                                               item.post_id)
//                                                                       ? Container(
//                                                                           width:
//                                                                               30.0,
//                                                                           height:
//                                                                               30.0,
//                                                                           child:
//                                                                               SpinKitCircle(
//                                                                             color:
//                                                                                 Colors.blue,
//                                                                             size:
//                                                                                 20.0,
//                                                                           ),
//                                                                         )
//                                                                       : IconButton(
//                                                                           icon:
//                                                                               Icon(
//                                                                             item.is_liked == 'yes'
//                                                                                 ? Icons.favorite
//                                                                                 : Icons.favorite_outline,
//                                                                             color: item.is_liked == 'yes'
//                                                                                 ? Colors.red
//                                                                                 : Colors.grey,
//                                                                           ),
//                                                                           onPressed:
//                                                                               () {
//                                                                             setState(() {
//                                                                               likeSubjectID = item.post_id;
//                                                                               showLikeLoader = true;
//                                                                             });
//                                                                             if (item.is_liked ==
//                                                                                 'yes') {
//                                                                               BlocProvider.of<p.PostsBloc>(context).add(
//                                                                                 p.UnLikePostEvent(post_id: item.post_id),
//                                                                               );
//                                                                             } else {
//                                                                               BlocProvider.of<p.PostsBloc>(context).add(
//                                                                                 p.LikePostEvent(post_id: item.post_id),
//                                                                               );
//                                                                             }
//                                                                           },
//                                                                         ),
//                                                                   Text(
//                                                                       numberFormat(item
//                                                                           .like_count),
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               Colors.grey)),
//                                                                   IconButton(
//                                                                     icon: Icon(
//                                                                       Icons
//                                                                           .share,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                     ),
//                                                                     onPressed:
//                                                                         () async {
//                                                                       share(
//                                                                           item.sharelink,
//                                                                           '');
//                                                                     },
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         height: 28,
//                                                         child: Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 8),
//                                                           child:
//                                                               PopupMenuButton(
//                                                             icon: ImageIcon(
//                                                               AssetImage(
//                                                                   "images/dots.png"),
//                                                               color:
//                                                                   Colors.grey,
//                                                               size: 20.0,
//                                                             ),
//                                                             onSelected: (int) {
//                                                               showDialog(
//                                                                 context:
//                                                                     context,
//                                                                 builder:
//                                                                     (BuildContext
//                                                                         contextTwo) {
//                                                                   return AlertDialog(
//                                                                     scrollable:
//                                                                         true,
//                                                                     title: Text(
//                                                                         'Report'),
//                                                                     content:
//                                                                         Container(
//                                                                       height:
//                                                                           175.0,
//                                                                       width:
//                                                                           350.0,
//                                                                       child:
//                                                                           Column(
//                                                                         children: [
//                                                                           Container(
//                                                                             child:
//                                                                                 SizedBox(
//                                                                               child: TextFormField(
//                                                                                 maxLength: 300,
//                                                                                 maxLines: 3,
//                                                                                 minLines: 1,
//                                                                                 keyboardType: TextInputType.text,
//                                                                                 decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), labelText: 'Comment', hintText: 'Enter Comment', contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
//                                                                                 controller: _controllerComment,
//                                                                                 validator: (value) {
//                                                                                   if (value == null || value.isEmpty) {
//                                                                                     return 'Please Enter Comment';
//                                                                                     final snackBar = SnackBar(
//                                                                                       content: Text('Please Enter Comment'),
//                                                                                       backgroundColor: Colors.green.shade300,
//                                                                                     );
//                                                                                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                                                   }
//                                                                                   return null;
//                                                                                 },
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           SizedBox(
//                                                                             height:
//                                                                                 2.0,
//                                                                           ),
//                                                                           SizedBox(
//                                                                             height:
//                                                                                 50,
//                                                                             child:
//                                                                                 ElevatedButton(
//                                                                               style: raisedButtonStyleGreen,
//                                                                               onPressed: () {
//                                                                                 if (_formKey.currentState!.validate()) {
//                                                                                   BlocProvider.of<p.PostsBloc>(context).add(
//                                                                                     p.ReportAbuseEvent(comment: _controllerComment.text, post_id: item.post_id, reported: item.posted_by),
//                                                                                   );
//                                                                                 }
//                                                                               },
//                                                                               child: Row(
//                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                 children: [
//                                                                                   const Text(
//                                                                                     'Submit',
//                                                                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                               );
//                                                             },
//                                                             padding:
//                                                                 EdgeInsets.zero,
//                                                             itemBuilder:
//                                                                 (BuildContext
//                                                                     context) {
//                                                               return ['Report']
//                                                                   .map((String
//                                                                       choice) {
//                                                                 return PopupMenuItem<
//                                                                     String>(
//                                                                   value: choice,
//                                                                   child: Text(
//                                                                       choice),
//                                                                 );
//                                                               }).toList();
//                                                             },
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Divider(),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           secondaryActions: <Widget>[
//                                             IconSlideAction(
//                                               caption: 'Delete',
//                                               color: Colors.red,
//                                               icon: Icons.delete,
//                                               onTap: () {
//                                                 print('Delete');
//                                                 BlocProvider.of<p.PostsBloc>(
//                                                         context)
//                                                     .add(
//                                                   p.DeleteFeedEvent(
//                                                       post_id: item.post_id,
//                                                       posted_by:
//                                                           item.posted_by),
//                                                 );
//                                               },
//                                             ),
//                                           ],
//                                         );
//                                 },
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   : _buildLoading(),
//             ),
//           )),
//     );
//   }

//   String _getTimeAgo(DateTime dt) {
//     final now = DateTime.now().toLocal();
//     final diff = now.difference(dt.toLocal());
//     return timeago.format(now.subtract(diff), locale: 'en_short');
//   }

//   String _substring(String char, int count, String pattern) {
//     return char.length > count ? char.substring(0, count) + '...' : char;
//   }

//   Future<String?> getGroupID() async {
//     return await AppSharedPreferences.getValue(key: 'groupID');
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

//   Future<String?> getOrgID() async {
//     return await AppSharedPreferences.getValue(key: 'orgID');
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

//   _getOlderPosts(int limit) {
//     setState(() {
//       olderLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//     });

//     BlocProvider.of<p.PostsBloc>(context).add(
//       p.FeedEvent(
//         feedRequest: FeedRequest(
//             skipOnboarding: false,
//             skipTopFeed: false,
//             isFirstFeedRequest: false,
//             last_post_id: last_post_id,
//             group_id: groupId,
//             org_id: orgId,
//             page: '',
//             townhall_tap: false,
//             limit: limit,
//             older_or_newer: 'older',
//             page_owner: widget.subjectID),
//       ),
//     );
//     setState(() {});
//   }

//   _getNewerPosts(int limit) {
//     setState(() {
//       isLoadingUpRequest = true;
//       newLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//     });
//     isThereResult = false;
//     print("I am search for new post with ID: ${first_post_id}");
//     BlocProvider.of<p.PostsBloc>(context).add(
//       p.FeedEvent(
//         feedRequest: FeedRequest(
//             skipOnboarding: false,
//             skipTopFeed: false,
//             isFirstFeedRequest: false,
//             last_post_id: first_post_id,
//             group_id: groupId,
//             org_id: orgId,
//             townhall_tap: false,
//             page: '',
//             limit: limit,
//             older_or_newer: 'newer',
//             page_owner: widget.subjectID),
//       ),
//     );
//     setState(() {});
//   }

//   Future<String?> getUserID() async {
//     return await AppSharedPreferences.getValue(key: 'user_id');
//   }

//   Future<void> _onOpen(LinkableElement link) async {
//     if (!await canLaunch(link.url)) {
//       await launch(link.url);
//     } else {
//       throw 'Could not launch $link';
//     }
//   }

//   String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

//   Widget _buildLoading() => Center(
//         child: Container(
//           width: 80.0,
//           height: 80.0,
//           child: SpinKitCircle(
//             color: Colors.blue,
//             size: 50.0,
//           ),
//         ),
//       );
// }
