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
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/search/search_people_response.dart';
import 'package:mobilizer/pages/people/people_profile.dart';

class SearchPeopleResultScreen extends StatefulWidget {
  final String term;
  static String routeName = 'search_people_result_screen';
  const SearchPeopleResultScreen({Key? key, required this.term})
      : super(key: key);

  @override
  _SearchPeopleResultScreenState createState() =>
      _SearchPeopleResultScreenState();
}

class _SearchPeopleResultScreenState extends State<SearchPeopleResultScreen> {
  final pe.PeopleBloc _peopleBloc = pe.PeopleBloc();

  List<SearchPeopleResponseData> data = [];
  bool loading = true;
  int countFollowers = 0;

  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<pe.PeopleBloc>(context).add(
        pe.GetPeopleEvent(term: widget.term),
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
          print('No result found');
        } else if (state is pe.PeopleErrorState) {
          print("Am Here3");
          loading = false;
          print(state.message);
          final snackBar = SnackBar(content: Text('No Result'));
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
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.term.length > 10
                  ? widget.term.substring(0, 10) + "..."
                  : widget.term,
              style: TextStyle(color: Colors.black),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pop(context, 'refresh');
                  },
                ),
              ),
            ),
            toolbarHeight: 70.0,
            centerTitle: true,
            backgroundColor: Colors.white,
            // bottom: TabBar(
            //   indicatorWeight: 3,
            //   indicatorColor: Colors.blueAccent,
            //   tabs: [
            //     Tab(
            //       child: Text(
            //         'People',
            //         style: TextStyle(color: Colors.black),
            //       ),
            //     ),
            //     // Tab(
            //     //   child: Text(
            //     //     'Post',
            //     //     style: TextStyle(color: Colors.black),
            //     //   ),
            //     // ),
            //   ],
            // ),
          ),
          body: Container(
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
                                subtitle: Text(people.username.isEmpty
                                    ? ''
                                    : '@${people.username}'),
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
                                    userID: int.parse(people.user_id),
                                    status: people.is_following),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyButton extends StatefulWidget {
  final int index;
  final int userID;
  final String status;
  const MyButton(
      {Key? key,
      required this.index,
      required this.userID,
      required this.status})
      : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  // Default to non pressed
  bool pressAttention = false;
  @override
  void initState() {
    if (widget.status == "yes") {
      setState(() {
        pressAttention = true;
      });
    } else {
      setState(() {
        pressAttention = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        //elevation: 2,
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
        onPressed: () async {
          //selectedNumber = widget.indexV;
          setState(() {
            pressAttention = !pressAttention;
          });
          if (pressAttention) {
            //print(widget.userID);
            //call follow event
            BlocProvider.of<pe.PeopleBloc>(context)
                .add(pe.FollowEvent(followee: widget.userID));
            print(!pressAttention);
            //set userID
            await AppSharedPreferences.setValue(
                key: 'followed_id', value: widget.userID.toString());
          } else {
            //else call unfollow event
            BlocProvider.of<pe.PeopleBloc>(context)
                .add(pe.UnFollowEvent(followee: widget.userID));
            await AppSharedPreferences.setValue(key: 'followed_id', value: '');
            print(pressAttention);
          }
        });
  }
}
