// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// //import 'package:multi_image_picker/multi_image_picker.dart';
// import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
// import 'package:mobilizer/bloc/events/events_bloc.dart';
// import 'package:mobilizer/common/common/constants.dart';
// import 'package:mobilizer/common/common/navigation.dart';
// import 'package:mobilizer/common/common/sharepreference.dart';
// import 'package:getwidget/getwidget.dart';
// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:mobilizer/models/events/event_create_response.dart';
// import 'package:mobilizer/models/events/event_types_response.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
//     as picker;
// import 'package:mobilizer/models/townhall/townhalls_user_is_leader_in_response.dart';
// import 'package:mobilizer/widget/edit_video.dart';
// //import 'package:mobilizer/models/login/is_user_onboarded_response.dart';
// import 'package:timeago/timeago.dart';
// import 'package:video_player/video_player.dart';

// class CreateEventScreen extends StatefulWidget {
//   CreateEventScreen({required this.townhalls, Key? key}) : super(key: key);
//   static String routeName = 'create_event_screen';
//   List<Data> townhalls = [];

//   @override
//   _CreateEventScreenState createState() => _CreateEventScreenState();
// }

// class _CreateEventScreenState extends State<CreateEventScreen> {
//   final _controllerTownhall = TextEditingController();
//   final _controllerTitle = TextEditingController();
//   final _controllerDetails = TextEditingController();
//   final _controllerMeetingPoint = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   final _controllerType = TextEditingController();
//   late TextEditingController _controllerDate;
//   late TextEditingController _controllerTime;

//   List<TypeData> typeData = [];
//   Data? _selectedValue = null;
//   bool _isUpdateImage = false;
//   bool isChecked = true;
//   bool _mediaHasError = false;

//   final _formKey = GlobalKey<FormState>();
//   String? _isLeader = "no";
//   String _valueDate = '';
//   String _valueTime = '';
//   String _typeID = "";
//   String _townhallID = '';
//   //List<Data> _townhalls = [];
//   String _orgID = '';
//   bool loading = false;
//   DateTime _currentTime = DateTime.now();

//   List<dynamic> imageUrls = [];
//   List<MediaItem> images = [];
//   List<int> _mediaErrors = [];
//   List<MediaItem> editedMediaList = [];

//   @override
//   void initState() {
//     // TODO: implement initState
//     _setLeader();
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<EventsBloc>(context).add(GetEventTypesEvent());
//       // _townhalls = ModalRoute.of(context)!.settings.arguments as List<Data>;
//       // print("Townhall counts:" + _townhalls.length.toString());
//     });
//     _setOrgID();
//     _controllerDate = TextEditingController(text: '0000-00-00');
//     _valueDate = DateTime.now().toString();
//     _controllerTime = TextEditingController(text: '00:00');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 70,
//         title: Text('Create Event'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Builder(builder: (context) {
//           return SafeArea(
//             child: BlocConsumer<EventsBloc, EventsState>(
//               listener: (context, state) {
//                 if (state is LoadingState) {
//                   loading = true;
//                 }
//                 if (state is CreateEventState) {
//                   loading = false;
//                   print(state.createEventResponse.msg);
//                   print(state.createEventResponse.status);
//                   final createData = state.createEventResponse.data!;

//                   final List r = [
//                     {
//                       'event_id': state.createEventResponse.data!.event_id,
//                       'title': state.createEventResponse.data!.title,
//                       'desc': state.createEventResponse.data!.desc,
//                       'event_type': state.createEventResponse.data!.event_type,
//                       'event_time_full':
//                           state.createEventResponse.data!.event_time_full,
//                       'meeting_point':
//                           state.createEventResponse.data!.meeting_point
//                     }
//                   ];

//                   print("Create Event: ${r}");
//                   final snackBar = SnackBar(
//                     content: Text("Event was successfully created"),
//                     backgroundColor: Colors.green.shade300,
//                   );
//                   print(
//                       "Create state ${state.createEventResponse.data!.event_id}");

//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   Future.delayed(Duration(seconds: 5), () {
//                     Navigator.pop(context, r);
//                   });
//                 }
//                 if (state is ErrorState) {
//                   loading = false;
//                   print(state.message);
//                   final snackBar =
//                       SnackBar(content: Text(state.message.toString()));
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 }
//                 if (state is EventTypesState) {
//                   loading = false;
//                   typeData = state.typeResponse.data;
//                 }
//                 if (state is NetworkState) {
//                   loading = false;
//                   print(state.message);
//                   loading = false;
//                   final snackBar = SnackBar(
//                       backgroundColor: Color(0xFFcf5555),
//                       content: Text(state.message.toString()));
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 }
//               },
//               builder: (context, state) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       SizedBox(height: 60),
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: _buildDropDownMenu(widget.townhalls),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext contextTwo) {
//                                 return AlertDialog(
//                                   scrollable: true,
//                                   title: Text('Event Type'),
//                                   content: Container(
//                                     height: 200.0,
//                                     width: 400.0,
//                                     child: ListView.builder(
//                                       shrinkWrap: true,
//                                       itemCount: typeData.length,
//                                       itemBuilder:
//                                           (BuildContext contextOne, int index) {
//                                         return ListTile(
//                                           title: Text(typeData[index].name),
//                                           onTap: () {
//                                             _controllerType.text =
//                                                 typeData[index].name;
//                                             _typeID =
//                                                 typeData[index].id.toString();
//                                             print(_typeID);
//                                             Navigator.of(contextTwo,
//                                                     rootNavigator: true)
//                                                 .pop();
//                                           },
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                           readOnly: true,
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Event Type',
//                               hintText: 'Event Type'),
//                           controller: _controllerType,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Event Type';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Title',
//                               hintText: 'Enter Event title'),
//                           controller: _controllerTitle,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Event Title';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Date',
//                               hintText: 'Enter Event date'),
//                           controller: _controllerDate,
//                           validator: (value) {
//                             if (value == null || value == "0000-00-00") {
//                               return 'Please enter Date of event';
//                             }
//                             return null;
//                           },
//                           onTap: () {
//                             picker.DatePicker.showDatePicker(context,
//                                 showTitleActions: true,
//                                 minTime: DateTime(_currentTime.year,
//                                     _currentTime.month, _currentTime.day),
//                                 maxTime:
//                                     DateTime(_currentTime.year + 1, 12, 31),
//                                 theme: picker.DatePickerTheme(
//                                     // headerColor: Colors.orange,
//                                     // backgroundColor: Colors.blue,
//                                     containerHeight: 140.0,
//                                     itemStyle: TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18),
//                                     doneStyle: TextStyle(
//                                         color: Colors.blue,
//                                         fontSize: 16)), onChanged: (date) {
//                               var mn = date.month < 10
//                                   ? "0" + date.month.toString()
//                                   : date.month.toString();
//                               var dd = date.day < 10
//                                   ? "0" + date.day.toString()
//                                   : date.day.toString();
//                               _controllerDate.text =
//                                   date.year.toString() + "-" + mn + "-" + dd;
//                             }, onConfirm: (date) {
//                               //2023-07-17
//                               var mn = date.month < 10
//                                   ? "0" + date.month.toString()
//                                   : date.month.toString();
//                               var dd = date.day < 10
//                                   ? "0" + date.day.toString()
//                                   : date.day.toString();
//                               _controllerDate.text =
//                                   date.year.toString() + "-" + mn + "-" + dd;
//                             },
//                                 currentTime: DateTime.now(),
//                                 locale: picker.LocaleType.en);
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Time',
//                               hintText: 'Enter Event Time'),
//                           controller: _controllerTime,
//                           validator: (value) {
//                             if (value == null || value == "00:00") {
//                               return 'Please enter Event time';
//                             }
//                             return null;
//                           },
//                           onTap: () {
//                             picker.DatePicker.showTimePicker(context,
//                                 showTitleActions: true,
//                                 showSecondsColumn: false,
//                                 onChanged: (date) {
//                                   _controllerTime.text = date.hour.toString() +
//                                       ":" +
//                                       date.minute.toString();
//                                 },
//                                 theme: picker.DatePickerTheme(
//                                     // headerColor: Colors.orange,
//                                     // backgroundColor: Colors.blue,
//                                     containerHeight: 140.0,
//                                     itemStyle: TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18),
//                                     doneStyle: TextStyle(
//                                         color: Colors.blue, fontSize: 16)),
//                                 onConfirm: (date) {
//                                   // _controllerTime.text = date.hour.toString() +
//                                   //     ":" +
//                                   //     date.minute.toString();
//                                   _controllerTime.text = formatTime(date);
//                                 },
//                                 currentTime: DateTime.now());
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Meeting Point',
//                               hintText: 'Enter Event Meeting Point'),
//                           controller: _controllerMeetingPoint,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Event Meeting Point';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: TextFormField(
//                           minLines: 4,
//                           maxLines: 8,
//                           // maxLength: 300,
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               labelText: 'Details',
//                               hintText: 'Enter Event Details',
//                               alignLabelWithHint: false),
//                           autofocus: true,
//                           controller: _controllerDetails,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Event Text';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               onPressed: () async {
//                                 await gallery();
//                               },
//                               iconSize: 30,
//                               icon: Icon(
//                                 Icons.photo_size_select_actual_rounded,
//                                 color: Colors.grey,
//                                 // size: 30,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (images.length > 0)
//                         Container(
//                           height: 130,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: images.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.fromLTRB(
//                                     16.0, 0.0, 4.0, 0.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         Container(
//                                           width: 120,
//                                           height: 120,
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                               color: _mediaHasError &&
//                                                       _mediaErrors
//                                                           .contains(index)
//                                                   ? Colors.red
//                                                   : Colors.white,
//                                             ),
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                           child: ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(8.0),
//                                               child: _buildMediaPreview(
//                                                   images[index])),
//                                         ),
//                                         Positioned(
//                                           top: 0,
//                                           right: 0,
//                                           child: IconButton(
//                                             color: Colors.red,
//                                             icon: Icon(Icons.cancel),
//                                             onPressed: () {
//                                               // Add delete functionality here
//                                               setState(() {
//                                                 int posIndex =
//                                                     _mediaErrors.indexOf(index);
//                                                 if (posIndex != -1) {
//                                                   _mediaHasError = false;
//                                                   _mediaErrors
//                                                       .removeAt(posIndex);
//                                                 }
//                                                 images.removeAt(
//                                                     index); //this is just the dummy
//                                                 editedMediaList.removeAt(
//                                                     index); //this the file that will eventually be upload to server
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                         images[index].type.toString() ==
//                                                 "MediaType.video"
//                                             ? Positioned(
//                                                 bottom: 15,
//                                                 right: 10,
//                                                 child: Container(
//                                                   width: 21,
//                                                   height: 21,
//                                                   alignment: Alignment.center,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.blue,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             50.0),
//                                                   ),
//                                                   child: IconButton(
//                                                     padding: EdgeInsets.only(
//                                                         top: 1, left: 2),
//                                                     iconSize: 17,
//                                                     icon: Icon(Icons.edit),
//                                                     onPressed: () async {
//                                                       var adjustedDurationInSeconds =
//                                                           3.0;
//                                                       // Add delete functionality here
//                                                       // await TrimmerView(
//                                                       //     file: images[index].file);
//                                                       VideoPlayerController
//                                                           controller =
//                                                           VideoPlayerController
//                                                               .file(
//                                                                   images[index]
//                                                                       .file);
//                                                       await controller
//                                                           .initialize();
//                                                       int fileSizeInBytes =
//                                                           await images[index]
//                                                               .file
//                                                               .length();
//                                                       double fileSizeInMB =
//                                                           fileSizeInBytes /
//                                                               (1024 * 1024);
//                                                       print(
//                                                           "fileSize: ${fileSizeInMB}");

//                                                       if (fileSizeInMB > 15) {
//                                                         print("here");
//                                                         double
//                                                             originalVideoDurationInSeconds =
//                                                             controller
//                                                                 .value
//                                                                 .duration
//                                                                 .inSeconds
//                                                                 .toDouble(); // Convert duration to seconds
//                                                         print(
//                                                             "Ori ${originalVideoDurationInSeconds}");

//                                                         double val = controller
//                                                                 .value
//                                                                 .duration
//                                                                 .inSeconds /
//                                                             (fileSizeInMB /
//                                                                 15.0);
//                                                         setState(() {
//                                                           adjustedDurationInSeconds =
//                                                               val;
//                                                         }); // Adjust duration based on file size
//                                                         print(
//                                                             "adj ${adjustedDurationInSeconds}");
//                                                       }

//                                                       final result =
//                                                           await Navigator.of(
//                                                                   context)
//                                                               .push(
//                                                         MaterialPageRoute(
//                                                             builder: (context) {
//                                                           return TrimmerView(
//                                                               // start: 0.0,
//                                                               startPos:
//                                                                   images[index]
//                                                                       .startPos,
//                                                               endPos:
//                                                                   images[index]
//                                                                       .endPos,
//                                                               file:
//                                                                   images[index]
//                                                                       .file,
//                                                               duration:
//                                                                   adjustedDurationInSeconds);
//                                                         }),
//                                                       );
//                                                       if (result != null) {
//                                                         if (_mediaErrors
//                                                             .contains(index)) {
//                                                           print("Am here F");
//                                                           // Remove the element from the list
//                                                           setState(() {
//                                                             _mediaErrors
//                                                                 .remove(index);
//                                                             _mediaHasError =
//                                                                 false;
//                                                           });
//                                                         }
//                                                         int positionIndex = editedMediaList
//                                                             .indexWhere((media) =>
//                                                                 media.indexID
//                                                                     .toString() ==
//                                                                 index
//                                                                     .toString());
//                                                         if (positionIndex !=
//                                                             -1) {
//                                                           editedMediaList[
//                                                                       positionIndex]
//                                                                   .fileSize =
//                                                               await _getSize(
//                                                                   File(result[
//                                                                       'editedFile']));

//                                                           editedMediaList[
//                                                                       positionIndex]
//                                                                   .file =
//                                                               File(result[
//                                                                   'editedFile']);
//                                                           editedMediaList[
//                                                                   positionIndex]
//                                                               .wasEdited = true;
//                                                           editedMediaList[
//                                                                       positionIndex]
//                                                                   .startPos =
//                                                               result[
//                                                                   'startValue'];
//                                                           editedMediaList[
//                                                                       positionIndex]
//                                                                   .endPos =
//                                                               result[
//                                                                   'endValue'];
//                                                           editedMediaList[
//                                                                       positionIndex]
//                                                                   .type =
//                                                               MediaType.video;
//                                                           setState(() {});
//                                                           debugPrint("Fi2: " +
//                                                               editedMediaList[
//                                                                       positionIndex]
//                                                                   .fileSize
//                                                                   .toString());
//                                                         }
//                                                       }
//                                                     },
//                                                   ),
//                                                 ),
//                                               )
//                                             : SizedBox(),
//                                       ],
//                                     ),
//                                     SizedBox(height: 8),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: loading
//                             ? null
//                             : ElevatedButton(
//                                 onPressed: () async {
//                                   List<File> fileList = [];
//                                   if (_selectedValue == null) {
//                                     final snackBar = SnackBar(
//                                       content:
//                                           Text("You need to choose a Townhall"),
//                                       backgroundColor: Colors.red,
//                                     );
//                                     ScaffoldMessenger.of(context)
//                                         .showSnackBar(snackBar);
//                                   } else if (_formKey.currentState!
//                                       .validate()) {
//                                     if (editedMediaList.length > 0) {
//                                       int errCounts = 0;
//                                       for (var i = 0;
//                                           i < editedMediaList.length;
//                                           i++) {
//                                         print(
//                                             "TestL ${editedMediaList[i].indexID}");
//                                         if (editedMediaList[i].fileSize >
//                                             15.0) {
//                                           print(
//                                               "FilesizeS ${editedMediaList[i].fileSize} ${editedMediaList[i].file}");
//                                           setState(() {
//                                             _mediaHasError = true;
//                                             _mediaErrors.add(i);
//                                           });
//                                         }
//                                       }
//                                     }
//                                     if (_mediaHasError) {
//                                       final snackBar = SnackBar(
//                                         content: Text(
//                                             'Maximum allowed file size is 15MB. Please use the editor to resize your video'),
//                                         backgroundColor: Colors.red,
//                                       );
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(snackBar);
//                                       setState(() {
//                                         loading = false;
//                                       });
//                                     } else {
//                                       if (editedMediaList.length > 0) {
//                                         for (MediaItem image
//                                             in editedMediaList) {
//                                           fileList.add(image.file);
//                                         }
//                                       }
//                                       Map<String, dynamic> map = {
//                                         'event_type': _typeID.toString(),
//                                         'title': _controllerTitle.text,
//                                         'desc': _controllerDetails.text,
//                                         'meeting_point':
//                                             _controllerMeetingPoint.text,
//                                         'event_date': _controllerDate.text,
//                                         'event_time': _controllerTime.text,
//                                         'org_id':
//                                             _selectedValue!.org_id.toString(),
//                                         'townhall_id': _selectedValue!
//                                             .townhall_id
//                                             .toString(),
//                                         'files': fileList
//                                       };

//                                       print(map);
//                                       BlocProvider.of<EventsBloc>(context).add(
//                                         CreateEventEvent(
//                                             createEventRequest: map),
//                                       );
//                                     }
//                                   }
//                                 },
//                                 style: raisedButtonStyleGreen,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       'Submit',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                           fontSize: 20.0),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                       ),
//                       if (loading)
//                         Container(
//                           width: 80.0,
//                           height: 80.0,
//                           child: SpinKitCircle(
//                             color: Colors.blue,
//                             size: 50.0,
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   _setLeader() async {
//     var v = await getIsLeader();
//     setState(() {
//       _isLeader = v;
//     });
//   }

//   Future<String?> getTownhallView() async {
//     return await AppSharedPreferences.getValue(key: 'townhallView');
//   }

//   Future<String?> getIsLeader() async {
//     return await AppSharedPreferences.getValue(key: 'isLeader');
//   }

//   Future<String?> _getEventTownhallID() async {
//     return await AppSharedPreferences.getValue(key: 'eventTownhallID');
//   }

//   Future<String?> _getEventTownhallName() async {
//     return await AppSharedPreferences.getValue(key: 'eventTownhallName');
//   }

//   Future<String?> _getOrgID() async {
//     return await AppSharedPreferences.getValue(key: 'orgID');
//   }

//   Widget _buildDropDownMenu(List<Data> items) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       width: 390,
//       height: 55,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           // set border width
//           borderRadius: const BorderRadius.all(
//             Radius.circular(15.0),
//           ) // set rounded corner radius
//           ),
//       child: DropdownButtonFormField<Data>(
//         value: _selectedValue,
//         elevation: 16,
//         style: const TextStyle(color: Colors.black),
//         icon: Icon(Icons.arrow_drop_down),
//         decoration: InputDecoration(border: InputBorder.none),
//         iconSize: 26,
//         hint: Text(
//           "Please Select                                         ",
//           style: TextStyle(
//             fontSize: 14,
//           ),
//         ),
//         onChanged: (Data? newValue) {
//           if (newValue!.townhall_id != -1) {
//             _selectedValue = newValue;
//           }
//         },
//         items: items.map<DropdownMenuItem<Data>>((Data value) {
//           return DropdownMenuItem<Data>(
//             value: value,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 5.0),
//                   child: Text(value.townhall_name.toString()),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   void _setOrgID() async {
//     var orgID = await _getOrgID();
//     setState(() {
//       _orgID = orgID!;
//     });
//   }

//   String formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   Future<void> gallery() async {
//     int i = 0;
//     int z = 0;
//     //final List<XFile> medias = await _picker.pickMultipleMedia();
//     final List<XFile> medias = await _picker.pickMultiImage();
//     if (medias != null) {
//       if (medias.length < 4) {
//         images.addAll(await Future.wait(medias.map((file) async {
//           return MediaItem(
//             indexID: z++,
//             file: File(file.path),
//             fileSize:
//                 await _getType(File(file.path)).toString() == 'MediaType.video'
//                     ? await _getSize(File(file.path)) // Wait for size here
//                     : 0.0,
//             type: _getType(File(file.path)),
//             wasEdited: false,
//             startPos: 0.0,
//             endPos: 0.0, // You need to implement this function
//           );
//         })));
//         editedMediaList.addAll(await Future.wait(medias.map((file) async {
//           return MediaItem(
//             indexID: i++,
//             file: File(file.path),
//             fileSize:
//                 await _getType(File(file.path)).toString() == 'MediaType.video'
//                     ? await _getSize(File(file.path)) // Wait for size here
//                     : 0.0,
//             type: _getType(File(file.path)),
//             wasEdited: false,
//             startPos: 0.0,
//             endPos: 0.0, // You need to implement this function
//           );
//         })));

//         setState(() {});
//       }
//     }
//     if (images.length > 4) {
//       int orgCounts = images.length;
//       for (int i = 4; i < orgCounts; i++) {
//         setState(() {
//           medias.removeAt(i);
//         });
//       }
//     }
//   }

//   MediaType _getType(File file) {
//     if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
//       return MediaType.video;
//     } else {
//       return MediaType.image;
//     }
//   }

//   Future<double> _getSize(File file) async {
//     VideoPlayerController controller = VideoPlayerController.file(file);
//     await controller.initialize();
//     int fileSizeInBytes = await file.length();
//     double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
//     return fileSizeInMB;
//   }

//   Widget _buildMediaPreview(MediaItem media) {
//     if (media.type == MediaType.video) {
//       return VideoPreview(media: media);
//     } else {
//       return Image.file(
//         media.file,
//         fit: BoxFit.cover,
//       );
//     }
//   }
// }

// class MediaItem {
//   int indexID;
//   File file;
//   MediaType type;
//   double startPos;
//   double endPos;
//   bool wasEdited;
//   double fileSize;

//   MediaItem({
//     required this.indexID,
//     required this.file,
//     required this.fileSize,
//     required this.type,
//     required this.startPos,
//     required this.endPos,
//     required this.wasEdited,
//   });
// }

// enum MediaType { image, video }

// class VideoPreview extends StatefulWidget {
//   final MediaItem media;
//   const VideoPreview({required this.media});

//   @override
//   _VideoPreviewState createState() => _VideoPreviewState();
// }

// class _VideoPreviewState extends State<VideoPreview> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.media.file)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller.pause();
//     } else {
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   // void _editVideo() async {
//   //   final output = await VideoEditor.editVideo(
//   //     widget.media.file.path,
//   //     startTime: Duration(seconds: 0),
//   //     endTime: _controller.value.duration,
//   //   );

//   //   if (output != null) {
//   //     setState(() {
//   //       _controller = VideoPlayerController.file(output)
//   //         ..initialize().then((_) {
//   //           setState(() {});
//   //         });
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           width: _controller.value.size.width,
//           height: _controller.value.size.height,
//           child: AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           ),
//         ),
//         IconButton(
//           iconSize: 50,
//           icon: Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             color: Colors.white,
//           ),
//           onPressed: _togglePlayPause,
//         ),
//         // Positioned(
//         //   bottom: 22,
//         //   right: 5,
//         //   child: IconButton(
//         //     icon: Icon(Icons.edit),
//         //     onPressed: () async {
//         //       await TrimmerView(file: widget.media.file);
//         //     },
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
