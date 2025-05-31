// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart' as post;
// import 'package:nahere/bloc/search/people_bloc.dart' as people;
// import 'package:nahere/common/common/navigation.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/models/messages/messages_response.dart';
// import 'package:nahere/pages/home/home.dart';
// import 'package:nahere/bloc/messages/messages_bloc.dart';
// import 'package:indexed/indexed.dart';
// import 'package:nahere/pages/message/chat_history.dart';
// import 'package:nahere/pages/people/people_profile.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:contextmenu/contextmenu.dart';
// import 'package:badges/badges.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

// class MessagesScreen extends StatefulWidget {
//   //final String? ref;
//   const MessagesScreen({Key? key}) : super(key: key);
//   static String routeName = 'messages';

//   @override
//   MessagesScreenState createState() => MessagesScreenState();
// }

// class MessagesScreenState extends State<MessagesScreen> {
//   final controller = TextEditingController();
//   final styleActive = TextStyle(color: Colors.black);
//   final styleHint = TextStyle(color: Colors.black54);
//   final style = TextStyle(color: Colors.black54);
//   final String hintText = 'Search Message';

//   int indexID = 0;
//   FocusNode _focus = FocusNode();
//   bool loading = false;
//   bool noResult = false;
//   List<MessageData> data = [];

//   void initState() {
//     _getCachedData();
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<MessagesBloc>(context)
//           .add(GetInboxMessages(keyword: '', message_category: ''));
//     });
//     super.initState();
//     _focus.addListener(_onFocusChange);
//   }

//   @override
//   void _onFocusChange() {
//     // setState(() {
//     //   refresh = true;
//     // });
//   }
//   @override
//   Widget build(BuildContext contextA) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           "Inbox",
//           style: TextStyle(fontSize: 16),
//         ),
//         elevation: 0,
//         toolbarHeight: 57.0,
//         leading: Row(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 19, top: 0),
//               child: ImageIcon(
//                 AssetImage("images/icon_blue.png"),
//                 color: Colors.blue,
//                 size: 20.0,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // Row(
//           //   children: [
//           //     Padding(
//           //       padding: const EdgeInsets.only(right: 20.0),
//           //       child: Badge(
//           //         position: BadgePosition.topStart(top: -15, start: 15),
//           //         badgeContent: Text(
//           //           '3',
//           //           style: TextStyle(color: Colors.white),
//           //         ),
//           //         child: FaIcon(
//           //           FontAwesomeIcons.filter,
//           //           size: 25,
//           //           color: Colors.blue,
//           //         ),
//           //       ),
//           //     )
//           //   ],
//           // ),
//         ],
//         backgroundColor: Colors.white,
//       ),
//       body: Indexer(children: [
//         if (loading)
//           Center(
//             child: Container(
//               width: 80.0,
//               height: 80.0,
//               child: SpinKitCircle(
//                 color: Colors.blue,
//                 size: 50.0,
//               ),
//             ),
//           ),
//         if (noResult)
//           Center(
//             child: Text(
//               "No messages, yet. You may send someone a message from their profile.",
//             ),
//           ),
//         SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
//                 child: Container(
//                   width: 387,
//                   height: 45,
//                   margin: const EdgeInsets.fromLTRB(10, 1, 10, 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white,
//                     border: Border.all(
//                       color: Colors.blue,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: TextField(
//                       controller: controller,
//                       focusNode: _focus,
//                       decoration: InputDecoration(
//                         icon: Icon(Icons.search, color: style.color),
//                         suffixIcon: controller.text.isNotEmpty
//                             ? GestureDetector(
//                                 child: Icon(Icons.close, color: style.color),
//                                 onTap: () {
//                                   controller.clear();

//                                   FocusScope.of(context)
//                                       .requestFocus(FocusNode());
//                                 },
//                               )
//                             : null,
//                         hintText: hintText,
//                         hintStyle: style,
//                         border: InputBorder.none,
//                       ),
//                       style: style,
//                       onChanged: (val) {}),
//                 ),
//               ),
//               BlocConsumer<MessagesBloc, MessagesState>(
//                   listener: (context, state) {
//                 if (state is LoadingState) {
//                   setState(() {
//                     loading = true;
//                     noResult = false;
//                   });
//                 }
//                 if (state is NoResultState) {
//                   setState(() {
//                     loading = false;
//                     noResult = true;
//                   });
//                 }
//                 if (state is NetworkState) {
//                   setState(() {
//                     loading = false;
//                     noResult = false;
//                   });

//                   // loading = false;
//                   final snackBar = SnackBar(
//                       backgroundColor: Color(0xFFcf5555),
//                       content: Text(state.message.toString()));
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 }
//                 if (state is MessageListState) {
//                   AppSharedPreferences.setValue(
//                       key: 'page_message',
//                       value: jsonEncode(state.messageResponse.data));

//                   setState(() {
//                     loading = false;
//                     data = state.messageResponse.data;
//                   });
//                 }
//                 if (state is DeleteState) {
//                   Loader.hide();
//                   setState(() {
//                     loading = false;
//                     data.removeAt(indexID);
//                   });
//                   final snackBar = SnackBar(
//                       backgroundColor: Color.fromARGB(255, 46, 198, 130),
//                       content: Text("Message was successully deleted!"));
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 }
//               }, builder: (context, state) {
//                 double width = MediaQuery.of(context).size.width;
//                 double height = MediaQuery.of(context).size.height;
//                 return Container(
//                   padding: EdgeInsets.only(bottom: 200),
//                   height: height,
//                   child: ListView.separated(
//                       shrinkWrap: true,
//                       separatorBuilder: (BuildContext context, int index) =>
//                           SizedBox(height: 1),
//                       itemCount: data.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         DateTime messageTime =
//                             new DateFormat("yyyy-MM-dd hh:mm:ss")
//                                 .parse(data[index].lastest_message_time);
//                         return BlocProvider(
//                           create: (context) => MessagesBloc(),
//                           child: Container(
//                             color: data[index].has_new == "yes"
//                                 ? Color(0xffCCE9FD)
//                                 : null,
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     // Navigator.push(context,
//                                     //     MaterialPageRoute(builder: (context) {
//                                     //   return MultiBlocProvider(
//                                     //     providers: [
//                                     //       BlocProvider(
//                                     //         create: (context) =>
//                                     //             people.PeopleBloc(),
//                                     //       ),
//                                     //       BlocProvider(
//                                     //         create: (context) =>
//                                     //             post.PostsBloc(),
//                                     //       ),
//                                     //     ],
//                                     //     child: PeopleProfile(
//                                     //         subjectID: data[index]
//                                     //             .message_with
//                                     //             .toString()),
//                                     //   );
//                                     // }));
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(
//                                         20, 20, 14, 20),
//                                     child: CircleAvatar(
//                                       radius: 21,
//                                       backgroundColor: Colors.grey,
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(40),
//                                         child: Image.network(
//                                           data[index].profile_image,
//                                           width: 40,
//                                           height: 40,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     var userID = await getUserID();
//                                     var noMsg = await getMessageCounts();
//                                     if (data[index].has_new == "yes") {
//                                       var newNoMsg =
//                                           noMsg != null && noMsg != "0"
//                                               ? int.parse(noMsg) - 1
//                                               : 0;
//                                       setState(() {
//                                         data[index].has_new = "no";
//                                       });
//                                     }
//                                     Navigator.push(context,
//                                         MaterialPageRoute(builder: (context) {
//                                       return BlocProvider(
//                                         create: (context) => MessagesBloc(),
//                                         child: ChatHistoryScreen(),
//                                       );
//                                     }));
//                                     // Navigator.push(context,
//                                     //     MaterialPageRoute(builder: (context) {
//                                     //   return BlocProvider(
//                                     //     create: (context) => MessagesBloc(),
//                                     //     child: ChatHistoryScreen(
//                                     //       userID: userID.toString(),
//                                     //       co_chatter: data[index]
//                                     //           .message_with
//                                     //           .toString(),
//                                     //       profile_name:
//                                     //           data[index].message_with_name,
//                                     //       profile_pics:
//                                     //           data[index].profile_image,
//                                     //     ),
//                                     //   );
//                                     // }));
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.fromLTRB(1, 20, 10, 20),
//                                     width: width - 106,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   _substring(
//                                                       data[index]
//                                                           .message_with_name,
//                                                       16,
//                                                       ''),
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 15),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 5,
//                                                 ),
//                                                 Text(
//                                                   '..' +
//                                                       timeago
//                                                           .format(messageTime),
//                                                   style: TextStyle(
//                                                       color: Colors.grey),
//                                                 ),
//                                               ],
//                                             ),
//                                             // ContextMenuArea(
//                                             //   builder: (context) => [
//                                             //     ListTile(
//                                             //       title: Text('Option 1'),
//                                             //       onTap: () {
//                                             //         Navigator.of(context).pop();
//                                             //         ScaffoldMessenger.of(context)
//                                             //             .showSnackBar(
//                                             //           SnackBar(
//                                             //             content: Text('Whatever'),
//                                             //           ),
//                                             //         );
//                                             //       },
//                                             //     ),
//                                             //   ],
//                                             //   child: ImageIcon(
//                                             //     AssetImage("images/dots.png"),
//                                             //     color: Colors.grey,
//                                             //     size: 20.0,
//                                             //   ),
//                                             // ),
//                                             data[index].unread_count == 0
//                                                 ? SizedBox()
//                                                 : Container(
//                                                     alignment: Alignment.center,
//                                                     height: 22,
//                                                     width: 22,
//                                                     decoration: BoxDecoration(
//                                                         color: Colors.red[400],
//                                                         shape: BoxShape.circle),
//                                                     child: Text(
//                                                       "${data[index].unread_count}",
//                                                       style: TextStyle(
//                                                           color: Colors.white),
//                                                     ),
//                                                   )
//                                           ],
//                                         ),
//                                         Container(
//                                           padding: EdgeInsets.only(top: 5),
//                                           child: Text(
//                                             _substring(
//                                                 data[index].message, 39, '...'),
//                                             style: TextStyle(fontSize: 15),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ]),
//     );
//   }

//   _getCachedData() async {
//     var pageData = await getPageData('page_message');
//     if (pageData != null) {
//       var json = jsonDecode(pageData);
//       setState(() {
//         data = json
//             .map<MessageData>((json) => MessageData.fromJson(json))
//             .toList();
//         loading = false;
//       });
//       // print("My Data: ${data[0].message}");
//     }
//   }
//   // _verifyPageVisit(String value) async {
//   //   var pages = await getPages();
//   //   if (pages != null) {
//   //     setState(() {
//   //       _isPageVisited = pages!.contains(value);
//   //     });
//   //     print("Pages: ${pages}");
//   //   }
//   // }

//   String _substring(String char, int count, String pattern) {
//     return char.length > count ? char.substring(0, count) + pattern : char;
//   }

//   Future<String?> getPageData(String value) async {
//     return await AppSharedPreferences.getValue(key: value);
//   }

//   Future<List<String>?> getPages() async {
//     return await AppSharedPreferences.getList(key: 'pages');
//   }

//   Future<String?> getUserID() async {
//     return await AppSharedPreferences.getValue(key: 'user_id');
//   }

//   Future<String?> getMessageCounts() async {
//     return await AppSharedPreferences.getValue(key: 'message_counts');
//   }
// }
