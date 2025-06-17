// import 'dart:io';

// //import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:video_trimmer/video_trimmer.dart';

// class TrimmerView extends StatefulWidget {
//   final File file;
//   final duration;
//   final startPos;
//   final endPos;
//   TrimmerView(
//       {required this.file,
//       required this.duration,
//       required this.startPos,
//       required this.endPos});

//   @override
//   _TrimmerViewState createState() => _TrimmerViewState();
// }

// class _TrimmerViewState extends State<TrimmerView> {
//   final Trimmer _trimmer = Trimmer();

//   double _startValue = 0.0;
//   double _endValue = 0.0;

//   bool _isPlaying = false;
//   bool _progressVisibility = false;

//   Future<String?> _saveVideo() async {
//     setState(() {
//       _progressVisibility = true;
//     });

//     String? _value;

//     await _trimmer.saveTrimmedVideo(
//       startValue: _startValue,
//       endValue: _endValue,
//       onSave: (String? value) {
//         setState(() {
//           _progressVisibility = true;
//           if (value != null) {
//             // Pass the edited video file path back to the previous screen
//             Navigator.of(context).pop({
//               'editedFile': value,
//               'index': 0,
//               'startValue': _startValue,
//               'endValue': _endValue
//             });
//             print(value);
//           }
//         });
//       },
//     );
//   }

//   void _loadVideo() {
//     _trimmer.loadVideo(videoFile: widget.file);
//   }

//   @override
//   void initState() {
//     super.initState();

//     _loadVideo();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Duration: " + widget.duration.toString());
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Video Editor"),
//         leading: IconButton(
//           onPressed: () {
//             _saveVideo();
//           },
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//         ),
//       ),
//       body: Builder(
//         builder: (context) => Center(
//           child: Container(
//             padding: EdgeInsets.only(bottom: 30.0),
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 Visibility(
//                   visible: _progressVisibility,
//                   child: LinearProgressIndicator(
//                     backgroundColor: Colors.red,
//                   ),
//                 ),
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       VideoViewer(trimmer: _trimmer),
//                       Center(
//                         child: TextButton(
//                           child: _isPlaying
//                               ? Icon(
//                                   Icons.pause,
//                                   size: 80.0,
//                                   color: Colors.white,
//                                 )
//                               : Icon(
//                                   Icons.play_arrow,
//                                   size: 80.0,
//                                   color: Colors.white,
//                                 ),
//                           onPressed: () async {
//                             bool playbackState =
//                                 await _trimmer.videoPlaybackControl(
//                               startValue: _startValue,
//                               endValue: _endValue,
//                             );
//                             setState(() {
//                               _isPlaying = playbackState;
//                             });
//                           },
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: TrimViewer(
//                     trimmer: _trimmer,
//                     viewerHeight: 50.0,
//                     maxVideoLength: Duration(
//                         milliseconds: (widget.duration * 1000).toInt()),
//                     onChangeStart: (value) => _startValue = value,
//                     onChangeEnd: (value) => _endValue = value,
//                     onChangePlaybackState: (value) =>
//                         setState(() => _isPlaying = value),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 // ElevatedButton(
//                 //   onPressed: _progressVisibility
//                 //       ? null
//                 //       : () async {
//                 //           _saveVideo();
//                 //         },
//                 //   child: Text("Save"),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
