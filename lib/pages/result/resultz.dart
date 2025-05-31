// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:getwidget/getwidget.dart';
// import 'package:nahere/common/common/navigation.dart';
// import 'package:nahere/pages/home/home.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart';
// import 'package:indexed/indexed.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class ResultScreen extends StatefulWidget {
//   //final String? ref;
//   const ResultScreen({Key? key}) : super(key: key);
//   static String routeName = 'result';

//   @override
//   ResultScreenState createState() => ResultScreenState();
// }

// class ResultScreenState extends State<ResultScreen> {
//   String _headings = "";
//   FocusNode _focus = FocusNode();
//   bool loading = true;
//   bool submitLoader = false;
//   bool showSubmitLoader = false;
//   bool noResult = false;

//   List<dynamic> _parties = [];

//   void initState() {
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<PostsBloc>(context)
//           .add(GetPartyEvent(countryID: '', forResult: 'yes'));
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
//   List<Map> _books = [
//     {'id': 100, 'title': 'Flutter Basics', 'author': 'David John'},
//     {'id': 101, 'title': 'Flutter Basics', 'author': 'David John'},
//     {'id': 102, 'title': 'Git and GitHub', 'author': 'Merlin Nick'}
//   ];
//   List<Map<String, dynamic>> _values = [];
//   List<dynamic> result = [];
//   int _currentSortColumn = 0;
//   bool _isSortAsc = true;
//   @override
//   Widget build(BuildContext contextA) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         foregroundColor: Colors.lightBlue,
//         toolbarHeight: 30.0,
//         elevation: 0.0,
//         // leading: Row(
//         //   children: [
//         //     Padding(
//         //       padding: EdgeInsets.only(left: 8),
//         //       child: ImageIcon(
//         //         AssetImage("images/icon_blue.png"),
//         //         color: Colors.blue,
//         //         size: 25.0,
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         // // actions: [
//         // //   // IconButton(
//         // //   //   iconSize: 25,
//         // //   //   icon: FaIcon(
//         // //   //     FontAwesomeIcons.filter,
//         // //   //     size: 25,
//         // //   //     color: Colors.blue,
//         // //   //   ),
//         // //   //   onPressed: () {},
//         // //   // )
//         // //   Row(
//         // //     children: [
//         // //       Padding(
//         // //         padding: const EdgeInsets.only(right: 16.0),
//         // //         child: GFIconBadge(
//         // //           child: GFIconButton(
//         // //               onPressed: () {},
//         // //               icon: FaIcon(
//         // //                 FontAwesomeIcons.filter,
//         // //                 size: 25,
//         // //                 color: Colors.blue,
//         // //               ),
//         // //               size: 20,
//         // //               type: GFButtonType.transparent),
//         // //           counterChild: Padding(
//         // //             padding: const EdgeInsets.only(top: 8.0, right: 2.0),
//         // //             child: GFBadge(
//         // //               textStyle: TextStyle(
//         // //                   color: Colors.white,
//         // //                   fontSize: 15,
//         // //                   fontWeight: FontWeight.bold),
//         // //               child: Text("12"),
//         // //             ),
//         // //           ),
//         // //         ),
//         // //       ),
//         // //     ],
//         // //   ),
//         // ],

//         backgroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Indexer(children: [
//           if (loading)
//             Center(
//               child: Container(
//                 width: 80.0,
//                 height: 80.0,
//                 child: SpinKitCircle(
//                   color: Colors.blue,
//                   size: 50.0,
//                 ),
//               ),
//             ),
//           // if (noResult)
//           //   Center(
//           //     child: Text(
//           //       "No Result",
//           //     ),
//           //   ),
//           SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Container(
//                   alignment: Alignment.topLeft,
//                   padding:
//                       EdgeInsets.only(left: 20, top: 15, bottom: 5, right: 10),
//                   width: size.width,
//                   child: HtmlWidget(_headings),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 10.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Column(
//                         children: [
//                           Divider(
//                             height: 3,
//                             color: Colors.black,
//                           ),
//                           // Row(
//                           //   children: [
//                           //     IconButton(
//                           //         iconSize: 35,
//                           //         // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
//                           //         icon: FaIcon(FontAwesomeIcons.camera),
//                           //         onPressed: () {
//                           //           print("Pressed");
//                           //         }),
//                           //     Column(
//                           //       crossAxisAlignment: CrossAxisAlignment.start,
//                           //       children: [
//                           //         Text("Upload Picture"),
//                           //         Text("(Optional)")
//                           //       ],
//                           //     )
//                           //   ],
//                           // )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 BlocConsumer<PostsBloc, PostsState>(listener: (context, state) {
//                   if (state is LoadingState) {
//                     setState(() {
//                       loading = true;
//                       submitLoader = false;
//                       noResult = false;
//                     });
//                   }
//                   if (state is PartyState) {
//                     setState(() {
//                       loading = false;
//                       submitLoader = false;
//                       noResult = true;
//                       _parties = state.partyResponse.data;
//                       _headings = state.partyResponse.page_headings;
//                     });
//                   }
//                   if (state is PostResultState) {
//                     setState(() {
//                       loading = false;
//                       submitLoader = false;
//                     });
//                     final snackBar = SnackBar(
//                         backgroundColor: Colors.green,
//                         content: Text("Result was successfully submitted"));
//                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   }
//                   if (state is NetworkState) {
//                     setState(() {
//                       loading = false;
//                       submitLoader = false;
//                       noResult = false;
//                     });
//                     // loading = false;
//                     final snackBar = SnackBar(
//                         backgroundColor: Color(0xFFcf5555),
//                         content: Text(state.message.toString()));
//                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   }
//                 }, builder: (context, state) {
//                   double width = MediaQuery.of(context).size.width;
//                   double height = MediaQuery.of(context).size.height;
//                   return Column(
//                     children: [
//                       _parties != null && _parties.length > 0
//                           ? Container(
//                               height: size.height - 333,
//                               child: Column(
//                                 children: [
//                                   ListView(
//                                     physics:
//                                         const NeverScrollableScrollPhysics(),
//                                     shrinkWrap: true,
//                                     children: [_createDataTable()],
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : SizedBox(),
//                       submitLoader
//                           ? Center(
//                               child: Container(
//                                 width: 80.0,
//                                 height: 80.0,
//                                 child: SpinKitCircle(
//                                   color: Colors.blue,
//                                   size: 50.0,
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               child: _parties != null && _parties.length > 0
//                                   ? SizedBox(
//                                       width: 140,
//                                       height: 50,
//                                       child: GFButton(
//                                         fullWidthButton: true,
//                                         padding: EdgeInsets.all(0),
//                                         size: GFSize.MEDIUM,
//                                         onPressed: () {
//                                           setState(() {
//                                             submitLoader = true;
//                                             loading = false;
//                                           });
//                                           // List<dynamic> result = json
//                                           //     .map<FeedData>((json) => FeedData.fromJson(json))
//                                           //     .toList();
//                                           result = [];
//                                           result = _values.toList();
//                                           Map<String, dynamic> map = Map();
//                                           map["the_result"] = result;
//                                           BlocProvider.of<PostsBloc>(context)
//                                               .add(
//                                             PostResultEvent(
//                                                 postResultRequest: map),
//                                           );
//                                           print(result);
//                                         },
//                                         text: ("Submit"),
//                                         shape: GFButtonShape.pills,
//                                         color: Colors.blue,
//                                       ),
//                                     )
//                                   : Text(''),
//                             ),
//                     ],
//                   );
//                 })
//               ],
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   DataTable _createDataTable() {
//     return DataTable(
//       dataRowHeight: 65.0,
//       columns: _createColumns(),
//       rows: _createRows(),
//     );
//   }

//   List<DataColumn> _createColumns() {
//     return [
//       DataColumn(
//         label: Text(
//           'Party',
//           style: TextStyle(color: Colors.lightBlue),
//         ),
//       ),
//       DataColumn(
//           label: Text(
//         'Result',
//         style: TextStyle(color: Colors.lightBlue),
//       ))
//     ];
//   }

//   List<DataRow> _createRows() {
//     return _parties
//         .map((party) => DataRow(cells: [
//               DataCell(Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 5),
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.grey,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(40),
//                           child: Image.network(
//                             party.party_logo,
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     width: 15,
//                   ),
//                   SizedBox(
//                       width: 180,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Text(
//                             "${party.fullname}",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ))
//                 ],
//               )),
//               DataCell(Padding(
//                 padding: const EdgeInsets.only(right: 20),
//                 child: Container(
//                   alignment: Alignment.center,
//                   width: 80,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 1,
//                     ),
//                   ),
//                   child: buildTextField(
//                       party.index, party.id, party.votes.toString()),
//                 ),
//               ))
//             ]))
//         .toList();
//   }

//   Widget buildTextField(int index, String partyID, String votes) {
//     Map<String, dynamic> json = {
//       "id": index,
//       "party_id": partyID,
//       "votes": votes,
//     };
//     _values.add(json);
//     return TextFormField(
//       keyboardType: TextInputType.number,
//       initialValue: votes,
//       onChanged: (val) {
//         _onUpdate(index, int.parse(partyID), val);
//         print("This value: ${val}");
//       },
//     );
//   }

//   _onUpdate(int index, int PartyID, String val) async {
//     int foundKey = -1;
//     for (var map in _values) {
//       if (map.containsKey("id")) {
//         if (map["id"] == index) {
//           foundKey = index;
//           break;
//         }
//       }
//     }
//     if (-1 != foundKey) {
//       _values.removeWhere((map) {
//         return map["id"] == foundKey;
//       });
//     }
//     Map<String, dynamic> json = {
//       "id": index,
//       "party_id": PartyID,
//       "votes": val,
//     };
//     _values.add(json);
//   }
// }
