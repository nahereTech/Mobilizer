import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/models/election/election_types_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/pages/result/result.dart';

class ResultTypeScreen extends StatefulWidget {
  const ResultTypeScreen({Key? key});
  static String routeName = 'result_type';
  @override
  State<ResultTypeScreen> createState() => _ResultTypeScreenState();
}

class _ResultTypeScreenState extends State<ResultTypeScreen> {
  bool loading = true;
  List<TypesData> _data = [];
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<PostsBloc>(context).add(GetElectionTypesEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.lightBlue,
          elevation: 0.0,
          title: Text('Polling Unit Result'),
        ),
        body: BlocConsumer<PostsBloc, PostsState>(listener: (context, state) {
          if (state is LoadingState) {
            setState(() {
              loading = true;
            });
          }
          if (state is GetElectionTypesState) {
            setState(() {
              loading = false;
              _data = state.getElectionTypesResponse.data;
            });
          }

          if (state is NetworkState) {
            setState(() {
              loading = false;
            });
            // loading = false;
            final snackBar = SnackBar(
                backgroundColor: Color(0xFFcf5555),
                content: Text(state.message.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }, builder: (context, state) {
          return Indexer(
            children: [
              if (loading)
                Center(
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    child: SpinKitCircle(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  ),
                ),
              if (_data.length < 1 && loading == false)
                Center(
                  child: Text(
                    "No Polling Unit Result Types",
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(
                  //   width: 250,
                  //   height: 50,
                  //   child: Card(
                  //     child: Text("Hello"),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(5),
                  //       //set border radius more than 50% of height and width to make circle
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 25,
                  ),
                  if (_data.length > 0)
                    Container(
                      padding: EdgeInsets.only(left: 25, bottom: 25),
                      child: Text("What results are you submitting?",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  SizedBox(
                    height: 7,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (context) => PostsBloc(),
                                child: ResultScreen(
                                    name: _data[index].name,
                                    id: _data[index].id.toString()),
                              );
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 25, bottom: 20),
                            child: Row(
                              children: [
                                Text(_data[index].name,
                                    style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 0,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return BlocProvider(
                                        create: (context) => PostsBloc(),
                                        child: ResultScreen(
                                            name: _data[index].name,
                                            id: _data[index].id.toString()),
                                      );
                                    }));
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.greaterThan,
                                    size: 13,
                                    color: Colors.black54,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      })
                ],
              ),
            ],
          );
        }));
  }
}

// class ResultTypeScreen extends StatefulWidget {
//   //final String? ref;
//   const ResultTypeScreen({Key? key}) : super(key: key);
//   static String routeName = 'result_type';

//   @override
//   ResultTypeScreenState createState() => ResultTypeScreenState();
// }

// class ResultTypeScreenState extends State<ResultTypeScreen> {
//   final controller = TextEditingController();
//   final styleActive = TextStyle(color: Colors.black);
//   final styleHint = TextStyle(color: Colors.black54);
//   final style = TextStyle(color: Colors.black54);
//   final String hintText = 'Search Message';
//   FocusNode _focus = FocusNode();
//   bool loading = false;
//   bool noResult = false;
//   MessagesBloc _messageBloc = MessagesBloc();

//   void initState() {
//     // Future.delayed(Duration.zero, () {
//     //   BlocProvider.of<MessagesBloc>(context)
//     //       .add(GetInboxMessages(keyword: '', message_category: ''));
//     // });
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
//       appBar: AppBar(
//         toolbarHeight: 70.0,
//         leading: Row(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 8),
//               child: ImageIcon(
//                 AssetImage("images/icon_blue.png"),
//                 color: Colors.blue,
//                 size: 25.0,
//               ),
//             ),
//           ],
//         ),
//         actions: [
        
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: GFIconBadge(
//                   child: GFIconButton(
//                       onPressed: () {},
//                       icon: FaIcon(
//                         FontAwesomeIcons.filter,
//                         size: 25,
//                         color: Colors.blue,
//                       ),
//                       size: 20,
//                       type: GFButtonType.transparent),
//                   counterChild: Padding(
//                     padding: const EdgeInsets.only(top: 8.0, right: 2.0),
//                     child: GFBadge(
//                       textStyle: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold),
//                       child: Text("12"),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
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
//               "No Result",
//             ),
//           ),
//         Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
//               child: Container(
//                 height: 45,
//                 margin: const EdgeInsets.fromLTRB(10, 1, 10, 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.white,
//                   border: Border.all(
//                     color: Colors.blue,
//                   ),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: TextField(
//                     controller: controller,
//                     focusNode: _focus,
//                     decoration: InputDecoration(
//                       icon: Icon(Icons.search, color: style.color),
//                       suffixIcon: controller.text.isNotEmpty
//                           ? GestureDetector(
//                               child: Icon(Icons.close, color: style.color),
//                               onTap: () {
//                                 controller.clear();

//                                 FocusScope.of(context)
//                                     .requestFocus(FocusNode());
//                               },
//                             )
//                           : null,
//                       hintText: hintText,
//                       hintStyle: style,
//                       border: InputBorder.none,
//                     ),
//                     style: style,
//                     onChanged: (val) {}),
//               ),
//             ),
//             BlocConsumer<MessagesBloc, MessagesState>(
//                 listener: (context, state) {
//               if (state is LoadingState) {
//                 setState(() {
//                   loading = true;
//                   noResult = false;
//                 });
//               }
//               if (state is NoResultState) {
//                 setState(() {
//                   loading = false;
//                   noResult = true;
//                 });
//               }
//               if (state is NetworkState) {
//                 setState(() {
//                   loading = false;
//                   noResult = false;
//                 });
//                 // loading = false;
//                 final snackBar = SnackBar(
//                     backgroundColor: Color(0xFFcf5555),
//                     content: Text(state.message.toString()));
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }
//             }, builder: (context, state) {
//               double width = MediaQuery.of(context).size.width;
//               double height = MediaQuery.of(context).size.height;
//               return Column(
//                 children: [

//                 ],
//               );
           
//           ],
//         ),
//       ]),
//     );
//   }
// }
