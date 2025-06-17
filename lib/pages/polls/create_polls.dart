import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/election/election_types_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/pages/result/result.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key});
  static String routeName = 'create_polls';
  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  bool loading = false;
  int _optCounts = 2;
  int _selectedDay = 0;
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String _pollQuestion = '';
  String _opt1 = '';
  String _opt2 = '';
  String _opt3 = '';
  String _endDate = '';

  final _formKey = GlobalKey<FormState>();
  final _controllerPollQuestion = TextEditingController();
  final _controllerOption1 = TextEditingController();
  final _controllerOption2 = TextEditingController();
  final _controllerOption3 = TextEditingController();
  final _controllerDate = TextEditingController();
  DateTime _currentTime = DateTime.now();
  List<int> days = List.generate(31, (index) => index + 1);
  List<int> hours = List.generate(24, (index) => index + 1);
  List<int> minutes = List.generate(60, (index) => index + 1);
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<PostsBloc>(context).add(GetElectionTypesEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.lightBlue,
          elevation: 0.0,
          title: Text('Create A Poll'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child:
              BlocConsumer<PostsBloc, PostsState>(listener: (context, state) {
            if (state is LoadingState) {
              setState(() {
                loading = true;
              });
            }
            if (state is CreatePostState) {
              setState(() {
                loading = false;
                _controllerPollQuestion.text = '';
                _controllerOption1.text = '';
                _controllerOption2.text = '';
                _controllerOption3.text = '';
                _controllerDate.text = '';
                _opt1 = '';
                _opt2 = '';
                _opt3 = '';
                _endDate = '';
              });
              final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Poll was successfully created"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }, builder: (context, state) {
            return Indexer(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 45,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: TextFormField(
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              labelText: 'Poll Question',
                              hintText: 'Enter your question'),
                          controller: _controllerPollQuestion,
                          onSaved: (value) => _pollQuestion = value.toString(),
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: TextFormField(
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              labelText: 'Option 1',
                              hintText: 'Enter option 1'),
                          controller: _controllerOption1,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter Option 1';
                          //   }
                          //   return null;
                          // },
                          onSaved: (value) => _opt1 = value.toString(),
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: TextFormField(
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              labelText: 'Option 2',
                              hintText: 'Enter option 2'),
                          controller: _controllerOption2,
                          onSaved: (value) => _opt2 = value.toString(),
                        ),
                      ),
                      _optCounts == 3 ? SizedBox(height: 25) : SizedBox(),
                      _optCounts == 3
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        if (_optCounts == 2) {
                                          final snackBar = SnackBar(
                                              backgroundColor:
                                                  Color(0xFFcf5555),
                                              content: Text(
                                                  "You have reached the minimum option that can be removed"));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        } else {
                                          setState(() {
                                            _optCounts = 2;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    labelText: 'Option 3',
                                    hintText: 'Enter option 3'),
                                controller: _controllerOption3,
                                onSaved: (value) => _opt3 = value.toString(),
                              ),
                            )
                          : SizedBox(),
                      _optCounts == 2
                          ? SizedBox(
                              height: 25,
                            )
                          : SizedBox(),
                      _optCounts == 2
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                width: 150,
                                height: 53,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_optCounts == 3) {
                                      final snackBar = SnackBar(
                                          backgroundColor: Color(0xFFcf5555),
                                          content: Text(
                                              "You have reached the maximum option that can be added"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      setState(() {
                                        _optCounts = 3;
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Add Option',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // <-- Radius
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Day field
                            Flexible(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Days',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.26)),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                value: null,
                                items: days.map((int day) {
                                  return DropdownMenuItem<int>(
                                    value: day,
                                    child: Text(day.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  // Add functionality to handle value change
                                  _selectedDay = value!;
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Hours field
                            Flexible(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Hours',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.26)),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                value: null,
                                items: hours.map((int hour) {
                                  return DropdownMenuItem<int>(
                                    value: hour,
                                    child: Text(hour.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  // Add functionality to handle value change
                                  _selectedMinute = value!;
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            // minutes
                            Flexible(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Minutes',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.26)),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                value: null,
                                items: minutes.map((int minute) {
                                  return DropdownMenuItem<int>(
                                    value: minute,
                                    child: Text(minute.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  // Add functionality to handle value change
                                  _selectedMinute = value!;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          width: 400,
                          height: 53,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () async {
                                    final form = _formKey.currentState;
                                    form!.save();
                                    if (_pollQuestion == "") {
                                      final snackBar = SnackBar(
                                          backgroundColor: Color(0xFFcf5555),
                                          content: Text(
                                              "Poll Question can't be empty"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                    // else if (_opt1 == "") {
                                    //   final snackBar = SnackBar(
                                    //       backgroundColor: Color(0xFFcf5555),
                                    //       content:
                                    //           Text("Option 1 can't be empty"));
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(snackBar);
                                    // } else if (_opt2 == "") {
                                    //   final snackBar = SnackBar(
                                    //       backgroundColor: Color(0xFFcf5555),
                                    //       content:
                                    //           Text("Option 2 can't be empty"));
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(snackBar);
                                    // }
                                    // else if (_opt3 == "" && _optCounts == 3) {
                                    //   final snackBar = SnackBar(
                                    //       backgroundColor: Color(0xFFcf5555),
                                    //       content:
                                    //           Text("Option 3 can't be empty"));
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(snackBar);
                                    // } else if (_endDate == "") {
                                    //   final snackBar = SnackBar(
                                    //       backgroundColor: Color(0xFFcf5555),
                                    //       content: Text(
                                    //           "Poll end date can't empty"));
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(snackBar);
                                    // }

                                    else {
                                      DateTime dateTime = DateTime.now().add(
                                          Duration(
                                              days: _selectedDay,
                                              hours: _selectedHour,
                                              minutes: _selectedMinute));
                                      setState(() {
                                        loading = true;
                                      });
                                      var orgID = await getOrg();
                                      List<dynamic> _pollOptions = [];
                                      _pollOptions.add(_opt1);
                                      _pollOptions.add(_opt2);
                                      if (_opt3 != '') {
                                        _pollOptions.add(_opt3);
                                      }

                                      BlocProvider.of<PostsBloc>(context).add(
                                          CreatePostEvent(
                                              message: _pollQuestion,
                                              with_file: 'no',
                                              org_id: orgID.toString(),
                                              group: groupId.toString(),
                                              posted_as_a_leader: 'no',
                                              file: [],
                                              pollOptions: _pollOptions,
                                              poll: 'yes',
                                              poll_end: DateFormat(
                                                      "yyyy-MM-dd HH:mm:ss")
                                                  .format(dateTime)));

                                      // print(
                                      //     "Add ${DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime)}");
                                    }
                                  },
                            child: loading
                                ? SpinKitWave(
                                    color: Colors.grey,
                                    size: 15.0,
                                  )
                                : Text(
                                    'Create',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), // <-- Radius
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ));
  }

  Future<String?> getOrg() async {
    return await AppSharedPreferences.getValue(key: 'orgID');
  }
}
