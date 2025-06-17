import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/search/polling_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/search/search_polling_unit_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/pages/people/people_profile.dart';

class SearchPollingScreen extends StatefulWidget {
  //final String? ref;
  const SearchPollingScreen({Key? key}) : super(key: key);
  static String routeName = 'search_organization';

  @override
  SearchPollingScreenState createState() => SearchPollingScreenState();
}

class SearchPollingScreenState extends State<SearchPollingScreen> {
  List<PollingData> data = [];
  bool loading = false; //loader
  bool refresh = false;
  bool pressAttention = false;
  bool isSuccessful = false; //Query is successful
  bool isMember = false;
  String selectedID = ""; //org_id
  int count = 0;

  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<PollingBloc>(context).add(GetPollingEvent(ward_id: ''));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Polling Unit',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: BlocConsumer<PollingBloc, PollingState>(
        buildWhen: (previousState, state) {
          return true;
        },
        listener: (context, state) {
          print("Listener has been called");
          if (state is GetPollingState) {
            loading = false;
            isSuccessful = true;
            data = state.getPollingResponse.data;
          }
          if (state is PollingLoadingState) {
            loading = true;
            isSuccessful = false;
          }
          if (state is NoReturnState) {
            loading = false;
            isSuccessful = true;
          }
          if (state is NetworkState) {
            loading = false;
            isSuccessful = false;
            print(state.message);
            loading = false;
            final snackBar = SnackBar(
                backgroundColor: Color(0xFFcf5555),
                content: Text(state.message.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          return Container(
            child: Indexer(
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
                BlocProvider(
                  create: (context) => PollingBloc(),
                  child: refresh
                      ? SizedBox(width: 1)
                      : Expanded(
                          child: ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) => Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Divider(height: 2),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final polling = data[index];

                                // selectedID = organization.member == "yes"
                                //     ? polling.id
                                //     : '';
                                // isMember = organization.member == "yes"
                                //     ? true
                                //     : false;
                                // pressAttention = organization.member == "yes"
                                //     ? true
                                //     : false;
                                return ListTile(
                                    title: Text(
                                      '${polling.pu_name}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${polling.pu_official_id}'),
                                    // leading: CircleAvatar(
                                    //   radius: 25,
                                    //   backgroundColor: Colors.grey,
                                    //   child: ClipRRect(
                                    //     borderRadius:
                                    //         BorderRadius.circular(50),
                                    //     child: Image.network(
                                    //       '${polling.picture}',
                                    //       width: 50,
                                    //       height: 50,
                                    //       fit: BoxFit.cover,
                                    //     ),
                                    //   ),
                                    // ),
                                    trailing: MyButton(
                                        index: index,
                                        puID: polling.id.toString(),
                                        selectedID: selectedID));
                              }),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  final int index;
  final String puID;

  final String selectedID;
  const MyButton(
      {Key? key,
      required this.index,
      required this.puID,
      required this.selectedID})
      : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  // Default to non pressed
  bool pressAttention = false;
  bool loading = false;
  bool isSuccessful = false;
  String clickedID = '';
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PollingBloc, PollingState>(
      listener: (context, state) {
        if (state is JoinState) {
          loading = false;
          isSuccessful = true;
          //navigator.
          // Navigator.push(context,
          //                         MaterialPageRoute(builder: (context) {
          //                       return BlocProvider(
          //                         create: (context) => PostsBloc(),
          //                         child: HomeScreen(),
          //                       );
          //                     })).then((result) {
          //                       if (result == 'refresh') {
          //                         setState(() {
          //                           refresh = true;
          //                         });
          //                         BlocProvider.of<PBloc>(context).add(
          //                           GetPeopleEvent(term: ''),
          //                         );
          //                       }
          //                     });
          //Navigator.pop(context, true);
          Navigation.intentWithClearAllRoutes(context, HomeScreen.routeName);
        }
        if (state is NetworkState) {
          loading = false;
          isSuccessful = false;
          print(state.message);
          loading = false;
          final snackBar = SnackBar(
              backgroundColor: Color(0xFFcf5555),
              content: Text(state.message.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      builder: (context, state) {
        return ElevatedButton(
            child: Text(
              "Join",
              style:
                  TextStyle(color: pressAttention ? Colors.blue : Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: pressAttention ? Colors.white : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              BlocProvider.of<PollingBloc>(context)
                  .add(JoinEvent(pu_id: widget.puID));
            });
      },
    );
  }
}
