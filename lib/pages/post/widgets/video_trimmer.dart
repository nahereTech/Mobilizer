// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_trimmer/video_trimmer.dart';

// class TrimmerView extends StatefulWidget {
//   final File file;

//   TrimmerView(this.file);

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

//     // await _trimmer
//     //     .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
//     //     .then((value) {
//     //   setState(() {
//     //     _progressVisibility = false;
//     //     _value = value;
//     //   });
//     // });

//     return _value;
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
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text("Video Trimmer"),
//       // ),
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
//                 ElevatedButton(
//                   onPressed: _progressVisibility
//                       ? null
//                       : () async {
//                           _saveVideo().then((outputPath) {
//                             print('OUTPUT PATH: $outputPath');
//                             final snackBar = SnackBar(
//                                 content: Text('Video Saved successfully'));
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               snackBar,
//                             );
//                           });
//                         },
//                   child: Text("SAVE"),
//                 ),
//                 Expanded(
//                   child: VideoViewer(trimmer: _trimmer),
//                 ),
//                 Center(
//                   child: TrimViewer(
//                     trimmer: _trimmer,
//                     viewerHeight: 50.0,
//                     viewerWidth: MediaQuery.of(context).size.width,
//                     maxVideoLength: const Duration(seconds: 10),
//                     onChangeStart: (value) => _startValue = value,
//                     onChangeEnd: (value) => _endValue = value,
//                     onChangePlaybackState: (value) =>
//                         setState(() => _isPlaying = value),
//                   ),
//                 ),
//                 TextButton(
//                   child: _isPlaying
//                       ? Icon(
//                           Icons.pause,
//                           size: 80.0,
//                           color: Colors.white,
//                         )
//                       : Icon(
//                           Icons.play_arrow,
//                           size: 80.0,
//                           color: Colors.white,
//                         ),
//                   onPressed: () async {
//                     bool playbackState = await _trimmer.videoPlaybackControl(
//                       startValue: _startValue,
//                       endValue: _endValue,
//                     );
//                     setState(() {
//                       _isPlaying = playbackState;
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
