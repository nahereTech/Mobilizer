import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bloc/bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/townhall/townhall_info_response.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TownhallInfoScreen extends StatefulWidget {
  final String townhallID;
  const TownhallInfoScreen({Key? key, required this.townhallID})
      : super(key: key);

  static String routeName = 'townhall_info_screen';

  @override
  State<TownhallInfoScreen> createState() => _TownhallInfoScreenState();
}

class _TownhallInfoScreenState extends State<TownhallInfoScreen> {
  final postsBloc = PostsBloc();
  // List<RepData> repData = [];
  // late String townhallName, townhallAbout;
  // bool noResult = false;
  // bool loading = true;
  // void initState() {
  //   Future.delayed(Duration.zero, () {
  //     bloc:
  //     postsBloc.add(GetTownhallInfoEvent(townhall_id: widget.townhallID));
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 90,
          //automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.blue, //change your color here
          ),
          title: Text(
            'Townhall Info',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Text("Townhall Info Page")
        // BlocConsumer<PostsBloc, PostsState>(
        //   bloc: postsBloc,
        //   listener: (context, state) {
        //     if (state is TownhallInfoState) {
        //       loading = false;
        //       repData = state.townhallResponse.data.townhall_reps;
        //       townhallName =
        //           state.townhallResponse.data.townhall_info.townhall_name;
        //       townhallAbout =
        //           state.townhallResponse.data.townhall_info.about_townhall;
        //       print(
        //           "TName: ${state.townhallResponse.data.townhall_info.townhall_name}");
        //       //print(repData);
        //     }
        //     if (state is LoadingState) {
        //       loading = true;
        //       print("Search loading");
        //     }
        //     if (state is NetworkState) {
        //       loading = false;
        //       noResult = true;
        //       final snackBar = SnackBar(
        //           backgroundColor: Color(0xFFcf5555),
        //           content: Text(state.message.toString()));
        //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //     }
        //     if (state is NoResultState) {
        //       loading = false;
        //       noResult = true;
        //     }
        //   },
        //   builder: (context, state) {
        //     return Container(
        //       child: loading
        //           ? Center(
        //               child: Container(
        //                 width: 80.0,
        //                 height: 80.0,
        //                 child: SpinKitCircle(
        //                   color: Colors.blue,
        //                   size: 50.0,
        //                 ),
        //               ),
        //             )
        //           : SingleChildScrollView(
        //               child: noResult
        //                   ? Center(
        //                       child: Text("No Result"),
        //                     )
        //                   : Column(
        //                       children: [
        //                         Container(
        //                           width: double.infinity,
        //                           child: Column(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             children: [
        //                               Padding(
        //                                 padding: const EdgeInsets.only(left: 18),
        //                                 child: Text(
        //                                   townhallName,
        //                                   style: TextStyle(fontSize: 20.0),
        //                                 ),
        //                               ),
        //                               SizedBox(
        //                                 height: 10,
        //                               )
        //                             ],
        //                           ),
        //                         ),
        //                         SizedBox(
        //                           height: 10,
        //                         ),
        //                         Column(
        //                           children: [
        //                             Container(
        //                               color: Color(0xffCCE9FD),
        //                               width: double.infinity,
        //                               height: 200,
        //                               child: ListView.builder(
        //                                   itemCount: repData.length,
        //                                   itemBuilder: (context, index) {
        //                                     final rep = repData[index];
        //                                     return ListTile(
        //                                       title: Text(
        //                                         rep.fullname,
        //                                         style: TextStyle(
        //                                             fontWeight: FontWeight.bold),
        //                                       ),
        //                                       subtitle: Text(rep.position),
        //                                       leading: CircleAvatar(
        //                                         radius: 25,
        //                                         backgroundColor: Colors.grey,
        //                                         child: ClipRRect(
        //                                           borderRadius:
        //                                               BorderRadius.circular(50),
        //                                           child: Image.network(
        //                                             rep.picture,
        //                                             width: 50,
        //                                             height: 50,
        //                                             fit: BoxFit.cover,
        //                                           ),
        //                                         ),
        //                                       ),
        //                                     );
        //                                   }),
        //                             ),
        //                           ],
        //                         ),
        //                         SizedBox(
        //                           height: 20,
        //                         ),
        //                         Container(
        //                           width: double.infinity,
        //                           child: Padding(
        //                             padding: const EdgeInsets.only(
        //                                 left: 15, right: 20),
        //                             child: Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               children: [
        //                                 HtmlWidget(
        //                                   "About $townhallName",
        //                                   textStyle: TextStyle(
        //                                       fontWeight: FontWeight.bold),
        //                                 ),
        //                                 SizedBox(
        //                                   height: 10,
        //                                 ),
        //                                 Container(
        //                                   child: Text(
        //                                     townhallAbout,
        //                                     textAlign: TextAlign.justify,
        //                                   ),
        //                                 )
        //                               ],
        //                             ),
        //                           ),
        //                         )
        //                       ],
        //                     ),
        //             ),
        //     );
        //   },
        // ),

        );
  }
}
