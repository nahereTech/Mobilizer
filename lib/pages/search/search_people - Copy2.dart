import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/auth/auth_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart' as pe;
import 'package:mobilizer/bloc/social/social_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/models/search/search_people_response.dart';
import 'package:mobilizer/pages/people/people_profile.dart';

class SearchPeopleScreen extends StatefulWidget {
  const SearchPeopleScreen({Key? key}) : super(key: key);
  static String routeName = 'search_people';

  @override
  _SearchPeopleScreenState createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  final pe.PeopleBloc _peopleBloc = pe.PeopleBloc();

  //List<FeedData> feedData = [];
  List<SearchPeopleResponseData> data = [];
  bool loading = false;
  int countFollowers = 0;

  void initState() {
    Future.delayed(Duration.zero, () {
      // _peopleBloc.add(
      //   GetPeopleEvent(term: ''),
      // );
      BlocProvider.of<pe.PeopleBloc>(context).add(
        pe.GetPeopleEvent(term: ''),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<pe.PeopleBloc, pe.PeopleState>(
      buildWhen: (previousState, state) {
        return true;
      },
      listener: (context, state) {
        print("Listener has been called");
        if (state is pe.GetSearchResultState) {
          loading = false;
          print("Result Found in view");
        } else if (state is pe.SearchLoadingState) {
          loading = true;
          print("Search loading");
        } else if (state is pe.PeopleLoadingState) {
          loading = true;
        } else if (state is pe.GetPeopleState) {
          //print(state.getPeopleResponse.status);
          loading = false;
          data = state.getPeopleResponse.data!;
          print("Am Here2");
        } else if (state is pe.NoReturnState) {
          loading = false;
        } else if (state is pe.PeopleErrorState) {
          print("Am Here3");
          loading = false;
          print(state.message);
          final snackBar = SnackBar(content: Text('state.message.toString()'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is FollowState) {
          setState(() {
            countFollowers++;
          });

          loading = false;
          print(countFollowers);
        } else if (state is UnFollowState) {
          setState(() {
            countFollowers = countFollowers == 0 ? 0 : countFollowers - 1;
          });
          loading = false;
          print(countFollowers);
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
                create: (context) => pe.PeopleBloc(),
                child: SingleChildScrollView(
                  child: Container(
                    height: 500.0,
                    width: double.infinity,
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(height: 2),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final people = data[index];
                          return GestureDetector(
                            onTap: () async {
                              Navigator.pushNamed(
                                  context, PeopleProfile.routeName,
                                  arguments: people.user_id);
                              // Navigation.intentWithClearAllRoutes(
                              //     context, PeopleProfile.routeName);
                            },
                            child: ListTile(
                              title: Text(
                                people.fullname,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('@${people.username}'),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    people.photo_path,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              trailing: MyButton(
                                  index: index,
                                  userID: int.parse(people.user_id)),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // return BlocBuilder<PeopleBloc, PeopleState>(
    //     //bloc: blocA, // provide the local bloc instance
    //     builder: (context, state) {
    //   if (state is SearchLoadingState) {
    //     return Container(
    //       child: Text("Searching..."),
    //     );
    //   } else if (state is GetSearchResultState) {
    //     print("Search result called");
    //     print(state.getPeopleResponse.data.length);
    //     return Container(
    //       child: Text("Search Result"),
    //     );
    //   }
    //   // return widget here based on BlocA's state
    //   return Container(
    //     child: Text("Hello"),
    //   );
    // });
  }
  // return BlocBuilder<PeopleBloc, PeopleState>(buildWhen: (previous, current) {
  //   // return true/false to determine whether or not
  //   // to rebuild the widget with state
  //   return true;
  // }, builder: (context, state) {
  //   if (state is SearchLoadingState) {
  //     return Container(
  //       child: Text("Searching..."),
  //     );
  //   } else if (state is PeopleLoadingState) {
  //     return Container(
  //       child: Text("Loading"),
  //     );
  //   } else if (state is SearchPeopleState) {
  //     print("Search people called");
  //     //print(state.getPeopleResponse.data.length);
  //     return Container(
  //       child: Text("Search Result"),
  //     );
  //   } else if (state is GetSearchResultState) {
  //     print("Search result called");
  //     print(state.getPeopleResponse.data.length);
  //     return Container(
  //       child: Text("Search Result"),
  //     );
  //   }
  //   return Container(
  //     child: Text("Hello"),
  //   );
  // });
}

class MyButton extends StatefulWidget {
  final int index;
  final int userID;
  const MyButton({
    Key? key,
    required this.index,
    required this.userID,
  }) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  // Default to non pressed
  bool pressAttention = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text(
          pressAttention ? "Unfollow" : "Follow",
          style: TextStyle(color: pressAttention ? Colors.blue : Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: pressAttention ? Colors.white : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          //selectedNumber = widget.indexV;
          setState(() {
            pressAttention = !pressAttention;
          });

          if (pressAttention) {
            //print(widget.userID);
            //call follow event
            BlocProvider.of<pe.PeopleBloc>(context)
                .add(pe.FollowEvent(followee: widget.userID));
            print(pressAttention);
          } else {
            //else call unfollow event
            BlocProvider.of<pe.PeopleBloc>(context)
                .add(pe.UnFollowEvent(followee: widget.userID));
            print(pressAttention);
          }
        });
  }
}
