//import 'dart:html';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/bloc/suggestion/suggestion_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bloc/bloc.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/social/followee_response.dart';
import 'package:mobilizer/models/suggestion/suggestion_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/common/navigation.dart';
import 'package:getwidget/getwidget.dart';

class SuggestionScreen extends StatefulWidget {
  static String routeName = 'suggestion_screen';

  const SuggestionScreen({Key? key}) : super(key: key);

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  List<SuggestionData> data = [];
  List<dynamic> _isFollowList = [];

  int _clickedID = 0;
  bool loading = false;
  String _showLoaderFor = "";
  bool _capLoader = false;
  String _statusText = "Follow";

  int countFollowers = 0;

  // int selectedNumber = 1000;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<SuggestionBloc>(context).add(
        GetSuggestionEvent(),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // return Text("Testing");
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        shadowColor: Colors.white,
        title: Center(
          child: Column(
            children: [
              SizedBox(
                height: 25.0,
              ),
              Text(
                'Suggestions',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: Text(
                  'You need to follow at least ${3 - countFollowers} people',
                  style: TextStyle(color: Color(0xff00AFEF), fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<SuggestionBloc, SuggestionState>(
        listener: (context, state) {
          if (state is LoadingState) {
            if (_capLoader == false) {
              loading = true;
            }
          }
          if (state is GetSuggestionState) {
            loading = false;
            data = state.getSuggestionResponse.data;
          }
          if (state is FollowState) {
            setState(() {
              countFollowers++;
              _capLoader = false;
              _isFollowList[_clickedID] = !_isFollowList[_clickedID];
            });

            print("am inside follow state");
            loading = false;
          }
          if (state is UnFollowState) {
            setState(() {
              _capLoader = false;
              _isFollowList[_clickedID] = !_isFollowList[_clickedID];
            });
            if (countFollowers > 0) {
              setState(() {
                countFollowers--;
              });
            }
            loading = false;
            print("am inside unfollow state");
          }
          if (state is ErrorState) {
            loading = false;
            _capLoader = false;
            print(state.message);
            final snackBar =
                SnackBar(content: Text('${state.message.toString()}'));
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
                SingleChildScrollView(
                  child: Container(
                    //height: height.ceil().toInt() - 84,
                    width: double.infinity,
                    child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(height: 2),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final suggestions = data[index];
                          _isFollowList.add(false);
                          return ListTile(
                              title: Text(
                                suggestions.fullname,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('@${suggestions.userName}'),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    suggestions.photo_path,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              trailing: _clickedID == index &&
                                      _capLoader == true
                                  ? SizedBox(
                                      child: _capLoader
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                child: SpinKitCircle(
                                                  color: Colors.blue,
                                                  size: 30.0,
                                                ),
                                              ),
                                            )
                                          : null,
                                    )
                                  : _buildButtons(
                                      context, index, suggestions.userID));
                        }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 0, bottom: 8, left: width - 100),
                child: GFButton(
                    shape: GFButtonShape.pills,
                    color: countFollowers < 3 ? Colors.black26 : Colors.green,
                    size: GFSize.MEDIUM,
                    textColor:
                        countFollowers < 3 ? Colors.black26 : Colors.white,
                    text: 'Proceed',
                    onPressed: countFollowers < 3
                        ? null
                        : () async {
                            PackageInfo packageInfo =
                                await PackageInfo.fromPlatform();
                            await AppSharedPreferences.setValue(
                                key: 'orgID', value: '');
                            await AppSharedPreferences.setValue(
                                key: 'dismissedVersion',
                                value: packageInfo.version);
                            Navigation.intentWithClearAllRoutes(
                                context, HomeScreen.routeName);
                          })),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, int index, int subjectID) {
    return GFButton(
      onPressed: () {
        _clickedID = index;
        _showLoaderFor = index.toString();
        if (_isFollowList[index] == true) {
          BlocProvider.of<SuggestionBloc>(context)
              .add(UnFollowEvent(followee: subjectID));
        } else {
          BlocProvider.of<SuggestionBloc>(context)
              .add(FollowEvent(followee: subjectID));
        }
      },
      text: ("${_isFollowList[index] == true ? "Unfollow" : "Follow"}"),
      shape: GFButtonShape.pills,
      color: _isFollowList[index] == true ? Colors.red : Colors.blue,
    );
  }
}
