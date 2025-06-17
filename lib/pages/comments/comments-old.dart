// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:indexed/indexed.dart';
// import 'package:intl/intl.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart';
// import 'package:nahere/common/common/constants.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/models/comments/comments_response.dart';
// import 'package:nahere/models/comments/create_comments_request.dart';
// import 'package:nahere/models/feed/feed_response.dart';
// import 'package:nahere/widget/image_swipe.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:simple_moment/simple_moment.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';

// class Comments extends StatefulWidget {
//   static String routeName = 'comments_screen';

//   const Comments({Key? key}) : super(key: key);

//   @override
//   _CommentsState createState() => _CommentsState();
// }

// class _CommentsState extends State<Comments> {
//   var messageTextController = TextEditingController();
//   final _controllerComment = TextEditingController();
//   late String messageText;
//   List<CommentData> comments = [];
//   List<FeedImagesData> postImages = [];
//   List<dynamic> imageList = [];
//   final _formKey = GlobalKey<FormState>();
//   final _formKey2 = GlobalKey<FormState>();
//   bool loading = true;
//   bool noResult = true;
//   bool isLoadingUpRequest = true;
//   bool newLoader = true;
//   bool firstTimeLoading = false;
//   bool olderLoader = false;
//   bool isThereResult = false;
//   bool isLastDownRequest = false;
//   String post_id = '';
//   String direction = '';
//   ScrollController _scrollController = ScrollController();
//   Timer? timer;
//   var moment = new Moment.now();
//   final FocusNode _focusNode = FocusNode();
//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () {
//       final postData = ModalRoute.of(context)!.settings.arguments as FeedData;
//       post_id = postData.post_id;
//       print("Po ${post_id}");
//       if (postData.post_images != null) {
//         postImages = postData.post_images!;
//         if (postImages.length > 0) {
//           for (var i = 0; i < postImages.length; i++) {
//             imageList.add({
//               'name': postImages[i].name,
//               'type': postImages[i].type,
//               'thumbnail': postImages[i].thumbnail,
//             });
//           }
//         }
//       }
//       timer = Timer.periodic(Duration(seconds: 10), (timer) {
//         //setState(() {
//         moment = Moment.now();
//         //});
//       });
//       //print("Image Name: " + postImages[0].name);
//       BlocProvider.of<PostsBloc>(context).add(
//         GetCommentEvent(
//             post_id: postData.post_id, limit: 1000, direction: direction),
//       );
//     });

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         if (isLastDownRequest == false) {
//           _getOlderComments(20);
//         }
//       } else if (_scrollController.position.pixels ==
//           _scrollController.position.minScrollExtent) {
//         if (isLoadingUpRequest == false) {
//           _getNewerComments(20);
//         }
//       }
//     });
//     super.initState();
//     @override
//     void dispose() {
//       _focusNode.dispose();
//       super.dispose();
//     }

//     ;
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.pop(context, 'refresh');
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final item = ModalRoute.of(context)!.settings.arguments as FeedData?;

//     Size size = MediaQuery.of(context).size;
//     print(item);

//     print("PRINT WIDTH: ${size.width - 73}");
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Comments'),
//         ),
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: BlocConsumer<PostsBloc, PostsState>(
//             listener: (context, state) {
//               if (state is LoadingState) {
//                 loading = true;
//               }
//               if (state is CreateCommentState) {
//                 //loading = false;
//                 print(state.createCommentsResponse.msg);
//                 print(state.createCommentsResponse.status);

//                 BlocProvider.of<PostsBloc>(context).add(GetCommentEvent(
//                     post_id: item!.post_id, limit: 50, direction: direction));
//               }
//               if (state is NetworkState) {
//                 loading = false;
//               }
//               if (state is CommentsState) {
//                 loading = false;
//                 noResult = false;
//                 print(state.commentsResponse.msg);
//                 print(state.commentsResponse.status);
//                 comments = state.commentsResponse.data!.data.post_comments;

//                 print(comments.length);
//               }

//               if (state is DeleteCommentState) {
//                 loading = false;
//                 print(state.deleteCommentResponse.msg);
//                 print(state.deleteCommentResponse.status);
//                 print(comments.length);
//                 BlocProvider.of<PostsBloc>(context).add(
//                   GetCommentEvent(
//                       post_id: item!.post_id,
//                       limit: 1000,
//                       direction: direction),
//                 );
//               }
//               if (state is AbuseReportState) {
//                 Navigator.of(context, rootNavigator: true).pop();
//                 final snackBar = SnackBar(
//                   content: Text('Post was successfully reported'),
//                   backgroundColor: Colors.green.shade300,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 _controllerComment.text = '';
//               }
//               if (state is BlockUserState) {
//                 final snackBar = SnackBar(
//                     backgroundColor: Color.fromARGB(255, 85, 207, 158),
//                     content: Text('User was successfully blocked'));
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }
//               if (state is NetworkState) {
//                 loading = false;
//                 noResult = false;
//                 print(state.message);
//                 final snackBar = SnackBar(
//                   behavior: SnackBarBehavior.floating,
//                   margin: EdgeInsets.only(bottom: 10.0),
//                   content: Text(state.message.toString()),
//                   backgroundColor: Color(0xFFcf5555),
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }
//               if (state is NoResultState) {
//                 loading = false;
//                 noResult = false;
//               }
//               if (state is ErrorState) {
//                 loading = false;
//                 noResult = false;
//                 print(state.message);
//                 // final snackBar = SnackBar(
//                 //   behavior: SnackBarBehavior.floating,
//                 //   margin: EdgeInsets.only(bottom: 100.0),
//                 //   content: Text(state.message.toString()),
//                 //   backgroundColor: Color(0xFFcf5555),
//                 // );
//                 // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }
//             },
//             builder: (context, state) {
//               return Indexer(
//                 children: [
//                   if (comments.length < 1 && loading == false)
//                     Center(
//                       child: Text("..."),
//                     ),
//                   SingleChildScrollView(
//                     controller: _scrollController,
//                     child: Column(
//                       children: [
//                         Container(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(50),
//                                       child: Image.network(
//                                         item!.post_profile_pics,
//                                         width: 55,
//                                         height: 55,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Row(
//                                             children: [
//                                               Text(
//                                                 _substring(item.post_update_by,
//                                                     80, ''),
//                                                 style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                               Text(
//                                                 '. ${_getTimeAgo(DateTime.parse(item.post_updated_time))}',
//                                                 style: TextStyle(
//                                                     color: Colors.grey),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Linkify(
//                                               options: LinkifyOptions(
//                                                   humanize: false),
//                                               onOpen: _onOpen,
//                                               text: item.post_message,
//                                               textAlign:
//                                                   item.post_alignment == "rtl"
//                                                       ? TextAlign.right
//                                                       : TextAlign.left),
//                                         ),
//                                         imageList.length > 0
//                                             ? ImageSwipe(imageList: imageList)
//                                             : SizedBox(),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         if (loading)
//                           Center(
//                             child: Container(
//                               width: 80.0,
//                               height: 80.0,
//                               child: SpinKitCircle(
//                                 color: Colors.blue,
//                                 size: 50.0,
//                               ),
//                             ),
//                           ),
//                         noResult
//                             ? SizedBox()
//                             : Container(
//                                 // height: comments.length > 0 ? 500 : 0,
//                                 child: ListView.builder(
//                                   // Let the ListView know how many items it needs to build.
//                                   scrollDirection: Axis.vertical,
//                                   itemCount: comments.length,
//                                   physics: NeverScrollableScrollPhysics(),
//                                   shrinkWrap: true,
//                                   padding: EdgeInsets.only(bottom: 200),
//                                   // Provide a builder function. This is where the magic happens.
//                                   // Convert each item into a widget based on the type of item it is.
//                                   itemBuilder: (context, index) {
//                                     final item = comments[index];

//                                     // DateTime startTime =
//                                     //     new DateFormat("yyyy-MM-dd hh:mm:ss")
//                                     //         .parse(item.created_at);
//                                     return comments[index].can_delete == "yes"
//                                         ? Slidable(
//                                             actionPane:
//                                                 SlidableDrawerActionPane(),
//                                             actionExtentRatio: 0.25,
//                                             child: Container(
//                                               child: Card(
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .stretch,
//                                                     children: [
//                                                       Row(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: CircleAvatar(
//                                                               radius: 20,
//                                                               backgroundColor:
//                                                                   Colors.grey,
//                                                               child: ClipRRect(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             40),
//                                                                 child: Image
//                                                                     .network(
//                                                                   item.commented_by_profile_pics,
//                                                                   width: 40,
//                                                                   height: 40,
//                                                                   fit: BoxFit
//                                                                       .cover,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Row(
//                                                                 children: [
//                                                                   Padding(
//                                                                     padding:
//                                                                         const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                     child: Text(
//                                                                       item.commented_by_fullname,
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               Colors.black),
//                                                                     ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding:
//                                                                         const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                     child: Text(
//                                                                       _getTimeAgo(
//                                                                           DateTime.parse(
//                                                                               item.created_at)),
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               Colors.black),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 children: [
//                                                                   Container(
//                                                                     width:
//                                                                         size.width -
//                                                                             80,
//                                                                     child:
//                                                                         Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .only(
//                                                                           left:
//                                                                               8.0,
//                                                                           right:
//                                                                               8.0,
//                                                                           bottom:
//                                                                               8.0),
//                                                                       child: Linkify(
//                                                                           options: LinkifyOptions(
//                                                                               humanize:
//                                                                                   false),
//                                                                           onOpen:
//                                                                               _onOpen,
//                                                                           text: item
//                                                                               .message,
//                                                                           style:
//                                                                               TextStyle(fontSize: 12.0)),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             actions: <Widget>[
//                                               // IconSlideAction(
//                                               //   caption: 'Replay',
//                                               //   color: Colors.blue,
//                                               //   icon: Icons.replay,
//                                               //   onTap: () => {print('Archive')},
//                                               // ),
//                                             ],
//                                             secondaryActions: <Widget>[
//                                               IconSlideAction(
//                                                 caption: 'Delete',
//                                                 color: Colors.red,
//                                                 icon: Icons.delete,
//                                                 onTap: () {
//                                                   print('Delete');
//                                                   BlocProvider.of<PostsBloc>(
//                                                           context)
//                                                       .add(
//                                                     DeleteCommentEvent(
//                                                         commented_by:
//                                                             item.commented_by,
//                                                         comment_id: item.id),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           )
//                                         : Container(
//                                             child: Card(
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment
//                                                           .stretch,
//                                                   children: [
//                                                     Row(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: CircleAvatar(
//                                                             radius: 20,
//                                                             backgroundColor:
//                                                                 Colors.grey,
//                                                             child: ClipRRect(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           40),
//                                                               child:
//                                                                   Image.network(
//                                                                 item.commented_by_profile_pics,
//                                                                 width: 40,
//                                                                 height: 40,
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Container(
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .only(
//                                                                 left: 2.0,
//                                                               ),
//                                                               width:
//                                                                   size.width -
//                                                                       80,
//                                                               child: Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   Container(
//                                                                     child: Row(
//                                                                       children: [
//                                                                         Padding(
//                                                                           padding: const EdgeInsets
//                                                                               .all(
//                                                                               8.0),
//                                                                           child:
//                                                                               Text(
//                                                                             _substring(
//                                                                                 item.commented_by_fullname,
//                                                                                 18,
//                                                                                 ''),
//                                                                             style:
//                                                                                 TextStyle(color: Colors.black),
//                                                                           ),
//                                                                         ),
//                                                                         Padding(
//                                                                           padding: const EdgeInsets
//                                                                               .all(
//                                                                               1.0),
//                                                                           child:
//                                                                               Text(
//                                                                             _getTimeAgo(DateTime.parse(item.created_at)),
//                                                                             style:
//                                                                                 TextStyle(color: Colors.black),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   SizedBox(
//                                                                     height: 28,
//                                                                     child:
//                                                                         Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .only(
//                                                                           top:
//                                                                               8),
//                                                                       child:
//                                                                           PopupMenuButton(
//                                                                         icon:
//                                                                             ImageIcon(
//                                                                           AssetImage(
//                                                                               "images/dots.png"),
//                                                                           color:
//                                                                               Colors.grey,
//                                                                           size:
//                                                                               20.0,
//                                                                         ),
//                                                                         onSelected:
//                                                                             (choice) {
//                                                                           print(
//                                                                               choice);
//                                                                           if (choice ==
//                                                                               'Report') {
//                                                                             showDialog(
//                                                                               context: context,
//                                                                               builder: (BuildContext contextTwo) {
//                                                                                 return AlertDialog(
//                                                                                   scrollable: true,
//                                                                                   title: Text('Report'),
//                                                                                   content: Container(
//                                                                                     height: 175.0,
//                                                                                     width: 350.0,
//                                                                                     child: Column(
//                                                                                       children: [
//                                                                                         Form(
//                                                                                           key: _formKey2,
//                                                                                           child: Container(
//                                                                                             child: SizedBox(
//                                                                                               child: TextFormField(
//                                                                                                 maxLength: 300,
//                                                                                                 maxLines: 3,
//                                                                                                 minLines: 1,
//                                                                                                 keyboardType: TextInputType.text,
//                                                                                                 decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), labelText: 'Comment', hintText: 'Enter Comment', contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
//                                                                                                 controller: _controllerComment,
//                                                                                                 validator: (value) {
//                                                                                                   print(value);
//                                                                                                   if (value == null || value.isEmpty) {
//                                                                                                     return 'Please Enter Comment';
//                                                                                                     final snackBar = SnackBar(
//                                                                                                       content: Text('Please Enter Comment'),
//                                                                                                       backgroundColor: Colors.green.shade300,
//                                                                                                     );
//                                                                                                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                                                                   }
//                                                                                                   return null;
//                                                                                                 },
//                                                                                               ),
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                         SizedBox(
//                                                                                           height: 2.0,
//                                                                                         ),
//                                                                                         SizedBox(
//                                                                                           height: 50,
//                                                                                           child: ElevatedButton(
//                                                                                             style: raisedButtonStyleGreen,
//                                                                                             onPressed: () {
//                                                                                               if (_formKey2.currentState!.validate()) {
//                                                                                                 BlocProvider.of<PostsBloc>(context).add(
//                                                                                                   ReportAbuseEvent(comment: item.id, post_id: '', reported: item.commented_by),
//                                                                                                 );
//                                                                                               }
//                                                                                             },
//                                                                                             child: Row(
//                                                                                               mainAxisAlignment: MainAxisAlignment.center,
//                                                                                               children: [
//                                                                                                 const Text(
//                                                                                                   'Submit',
//                                                                                                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                                                                                                 ),
//                                                                                               ],
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 );
//                                                                               },
//                                                                             );
//                                                                           } else if (choice ==
//                                                                               'Block') {
//                                                                             BlocProvider.of<PostsBloc>(context).add(
//                                                                               BlockUserEvent(subjectID: item.commented_by, req_type: 'block'),
//                                                                             );
//                                                                             print("block was called");
//                                                                           }
//                                                                         },
//                                                                         padding:
//                                                                             EdgeInsets.zero,
//                                                                         itemBuilder:
//                                                                             (BuildContext
//                                                                                 context) {
//                                                                           return [
//                                                                             'Report',
//                                                                             'Block'
//                                                                           ].map((String
//                                                                               choice) {
//                                                                             return PopupMenuItem<String>(
//                                                                               value: choice,
//                                                                               child: Text(choice),
//                                                                             );
//                                                                           }).toList();
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding: EdgeInsets
//                                                                   .only(
//                                                                       left: 8.0,
//                                                                       right:
//                                                                           8.0,
//                                                                       bottom:
//                                                                           8.0),
//                                                               child: Container(
//                                                                 width:
//                                                                     size.width -
//                                                                         97,
//                                                                 child: Linkify(
//                                                                     options: LinkifyOptions(
//                                                                         humanize:
//                                                                             false),
//                                                                     onOpen:
//                                                                         _onOpen,
//                                                                     text: item
//                                                                         .message,
//                                                                     style: TextStyle(
//                                                                         fontSize:
//                                                                             12.0)),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                   },
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomLeft,
//                     child: Form(
//                       key: _formKey,
//                       child: Container(
//                         height: 100,
//                         decoration: kMessageContainerDecoration,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Expanded(
//                               child: TextFormField(
//                                 onTap: () {
//                                   loading = false;
//                                   // _scrollController.animateTo(
//                                   //   800,
//                                   //   curve: Curves.easeOut,
//                                   //   duration: const Duration(milliseconds: 900),
//                                   // );
//                                 },
//                                 maxLines: 3,
//                                 minLines: 1,
//                                 maxLength: 400,
//                                 enableSuggestions: true,
//                                 controller: messageTextController,
//                                 onChanged: (value) {
//                                   messageText = value;
//                                 },
//                                 focusNode: _focusNode,
//                                 decoration: kMessageTextFieldDecoration,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please Enter Comment Text';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             IconButton(
//                                 icon: const Icon(Icons.send),
//                                 tooltip: 'Send',
//                                 onPressed: () async {
//                                   if (_formKey.currentState!.validate()) {
//                                     var nw = await getTownhallView();
//                                     var party_townhall =
//                                         nw == "location" ? 'yes' : 'no';
//                                     BlocProvider.of<PostsBloc>(context).add(
//                                       AddCommentEvent(
//                                         createCommentsRequest:
//                                             CreateCommentsRequest(
//                                                 party_townhall: party_townhall,
//                                                 post_id: item.post_id,
//                                                 message:
//                                                     messageTextController.text,
//                                                 reply_to_comment: '',
//                                                 parent_id: ''
//                                                 //with_file: 'no'
//                                                 ),
//                                       ),
//                                     );
//                                     messageTextController.clear();
//                                   }
//                                 }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   _getOlderComments(int limit) {
//     setState(() {
//       olderLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//       direction = 'older';
//     });
//     BlocProvider.of<PostsBloc>(context).add(
//       GetCommentEvent(post_id: post_id, limit: limit, direction: direction),
//     );

//     setState(() {});
//   }

//   _getNewerComments(int limit) {
//     setState(() {
//       isLoadingUpRequest = true;
//       newLoader = true;
//       loading = false;
//       firstTimeLoading = false;
//       direction = 'newer';
//     });
//     isThereResult = false;

//     BlocProvider.of<PostsBloc>(context).add(
//       GetCommentEvent(post_id: post_id, limit: limit, direction: direction),
//     );
//     setState(() {});
//   }

//   String _getTimeAgo(DateTime utcTime) {
//     return moment.from(utcTime.toLocal());
//   }

//   Future<void> _onOpen(LinkableElement link) async {
//     if (!await canLaunch(link.url)) {
//       await launch(link.url);
//     } else {
//       throw 'Could not launch $link';
//     }
//   }

//   String _substring(String char, int count, String pattern) {
//     return char.length > count ? char.substring(0, count) + pattern : char;
//   }

//   Future<String?> getTownhallView() async {
//     return await AppSharedPreferences.getValue(key: 'townhallView');
//   }
// }
