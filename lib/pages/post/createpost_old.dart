// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// //import 'package:multi_image_picker/multi_image_picker.dart';
// import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
// import 'package:mobilizer/bloc/posts/posts_bloc.dart';
// import 'package:mobilizer/common/common/navigation.dart';
// import 'package:mobilizer/common/common/sharepreference.dart';
// import 'package:getwidget/getwidget.dart';
// import 'package:mobilizer/pages/polls/create_polls.dart';
// import 'package:mobilizer/widget/edit_video.dart';
// import 'package:mobilizer/widget/video_build.dart';
// import 'package:video_player/video_player.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:cloudflare/cloudflare.dart';
// import 'package:image_picker/image_picker.dart';

// class CreatePost extends StatefulWidget {
//   static String routeName = 'create_post_screen';
//   const CreatePost({Key? key}) : super(key: key);

//   @override
//   _CreatePostState createState() => _CreatePostState();
// }

// class _CreatePostState extends State<CreatePost> {
//   final File file = File(
//       '/data/user/0/com.example.video_example/cache/file_picker/big_buck_bunny_720p_10mb.mp4');
//   final _controllerText = TextEditingController();
//   List<MediaItem> images = [];
//   List<File> _selectedFiles = [];
//   bool _isUpdateImage = false;
//   bool isChecked = false;
//   List<dynamic> imageUrls = [];
//   //final File videoFile=File(
//   // '/data/user/0/com.example.video_example/cache/file_picker/big_buck_bunny_720p_10mb.mp4');
//   final ImagePicker _picker = ImagePicker();
//   final _formKey = GlobalKey<FormState>();
//   String? _isLeader = "no";
//   bool loading = false;
//   String base64Video = "";
//   String _orgName = "";
//   String _groupName = "";

//   @override
//   void initState() {
//     // TODO: implement initState
//     _setLeader();
//     _setOrgName();
//     _setGroupName();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final groupId = ModalRoute.of(context)!.settings.arguments as String?;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//         title: Text(
//           '',
//           style: TextStyle(color: Colors.black),
//         ),
//         actions: <Widget>[
//           loading
//               ? SizedBox()
//               : Padding(
//                   padding: EdgeInsets.only(right: 20.0, top: 16),
//                   child: GestureDetector(
//                     onTap: () async {
//                       if (_formKey.currentState!.validate()) {
//                         Map<String, dynamic> map = Map();
//                         _controllerText.text;
//                         var nw = await getTownhallView();
//                         var orgID = await getOrg();
//                         List<File> fileList = [];
//                         if (images.length > 0) {
//                           for (MediaItem image in images) {
//                             fileList.add(image.file);
//                           }
//                         }
//                         // BlocProvider.of<PostsBloc>(context).add(
//                         //   CreatePostEvent(
//                         //       message: _controllerText.text,
//                         //       org_id: orgID!,
//                         //       group: groupId!,
//                         //       posted_as_a_leader: isChecked ? "yes" : "no",
//                         //       with_file: images.length > 0 ? "yes" : "no",
//                         //       file: fileList),
//                         // );
//                         BlocProvider.of<PostsBloc>(context).add(
//                           CreatePostEvent(
//                               message: _controllerText.text,
//                               with_file: images.length > 0 ? "yes" : "no",
//                               org_id: orgID!,
//                               group: groupId!,
//                               posted_as_a_leader: isChecked ? "yes" : "no",
//                               file: fileList,
//                               pollOptions: [],
//                               poll: '',
//                               poll_end: ''),
//                         );
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.blue,
//                       ),
//                       padding: EdgeInsets.all(8),
//                       height: 15,
//                       child: Center(
//                         child: Text(
//                           'Post',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 17.0,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SafeArea(
//           child: BlocConsumer<PostsBloc, PostsState>(
//             listener: (context, state) {
//               if (state is LoadingState) {
//                 setState(() {
//                   loading = true;
//                 });
//               }
//               if (state is CreatePostState) {
//                 loading = false;
//                 print(state.createPostResponse.msg);
//                 print(state.createPostResponse.status);

//                 final snackBar = SnackBar(
//                   content: Text("Post was successfully created"),
//                   backgroundColor: Colors.green.shade300,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 Navigator.pop(context, 'refresh');
//               }
//               // if (state is ErrorState) {
//               //   loading = false;
//               //   print(state.message);
//               //   final snackBar =
//               //       SnackBar(content: Text(state.message.toString()));
//               //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               // }

//               if (state is NetworkState) {
//                 loading = false;
//                 print(state.message);
//                 loading = false;
//                 final snackBar = SnackBar(
//                     backgroundColor: Color(0xFFcf5555),
//                     content: Text(state.message.toString()));
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }
//             },
//             builder: (context, state) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     if (loading)
//                       Container(
//                         width: 80.0,
//                         height: 80.0,
//                         child: SpinKitCircle(
//                           color: Colors.blue,
//                           size: 50.0,
//                         ),
//                       ),
//                     Container(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Wrap(
//                         children: [
//                           Text(
//                             'You are posting into: ',
//                             style: TextStyle(fontSize: 17),
//                           ),
//                           Text(
//                             '${_orgName.toUpperCase()}',
//                             style: TextStyle(color: Colors.blue, fontSize: 17),
//                           ),
//                           SizedBox(width: 1),
//                           Icon(Icons.arrow_forward,
//                               color: Colors.blue, size: 15),
//                           Text(
//                             '${_groupName}',
//                             overflow: TextOverflow.fade,
//                             style: TextStyle(color: Colors.blue, fontSize: 17),
//                           ),
//                           SizedBox(width: 2),
//                           Text(
//                             'townhall',
//                             overflow: TextOverflow.fade,
//                             style: TextStyle(fontSize: 17),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: TextFormField(
//                         maxLines: 8,
//                         maxLength: 300,
//                         decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15.0)),
//                             labelText: 'Whats Happening?',
//                             hintText: 'Enter Post Text',
//                             alignLabelWithHint: false),
//                         autofocus: true,
//                         controller: _controllerText,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Post Text';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: GestureDetector(
//                         onTap: () async {
//                           await Navigator.pushNamed(
//                               context, CreatePollScreen.routeName,
//                               arguments: groupId);
//                         },
//                         child: Row(
//                           children: [
//                             IconButton(
//                               onPressed: () async {
//                                 gallery();
//                               },
//                               iconSize: 30,
//                               icon: Icon(
//                                 Icons.photo_size_select_actual_rounded,
//                                 color: Colors.blue,
//                                 // size: 30,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () async {
//                                 await Navigator.pushNamed(
//                                     context, CreatePollScreen.routeName,
//                                     arguments: groupId);
//                               },
//                               iconSize: 30,
//                               icon: Icon(
//                                 Icons.poll,
//                                 color: Colors.blue,
//                                 // size: 30,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Container(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: <Widget>[
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [],
//                               ),

//                               _isLeader == "yes"
//                                   ? Row(
//                                       children: [
//                                         SizedBox(
//                                           width: 45,
//                                           height: 45,
//                                           child: GFCheckbox(
//                                             size: GFSize.SMALL,
//                                             activeBorderColor: Colors.black,
//                                             activeBgColor: Colors.white,
//                                             inactiveBgColor: Colors.white,
//                                             inactiveBorderColor: Colors.black,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 isChecked = value;
//                                               });
//                                               print(isChecked);
//                                             },
//                                             value: isChecked,
//                                             activeIcon: Icon(
//                                               Icons.check,
//                                               size: 20,
//                                               color: GFColors.DARK,
//                                             ),
//                                             inactiveIcon: null,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Post as a leadership post",
//                                           style: TextStyle(fontSize: 16),
//                                         )
//                                       ],
//                                     )
//                                   : SizedBox(),

//                               // ElevatedButton(
//                               //   child: Text("Pick images"),
//                               //   onPressed: loadAssets,
//                               //   style: ButtonStyle(
//                               //       shape: MaterialStateProperty.all(
//                               //         RoundedRectangleBorder(
//                               //           borderRadius: BorderRadius.circular(10),
//                               //         ),
//                               //       ),
//                               //       backgroundColor: MaterialStateProperty.all(
//                               //           Theme.of(context)
//                               //               .accentColor
//                               //               .withOpacity(0.6))),
//                               // ),
//                               SizedBox(
//                                 height: 15.0,
//                               ),
//                               Expanded(
//                                 child: GridView.builder(
//                                   gridDelegate:
//                                       SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 3,
//                                     crossAxisSpacing: 4.0,
//                                     mainAxisSpacing: 4.0,
//                                   ),
//                                   itemCount: images.length,
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     return Stack(
//                                       alignment: Alignment.bottomRight,
//                                       children: [
//                                         _buildMediaPreview(images[index]),
//                                         IconButton(
//                                           icon: Icon(
//                                             Icons.cancel,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () {
//                                             setState(() {
//                                               images.removeAt(index);
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       height: images.length == 0 && imageUrls.length == 0
//                           ? 150
//                           : 220,
//                     ),
//                     SizedBox(
//                       height: 400,
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> gallery() async {
//     final List<XFile> medias = await _picker.pickMultipleMedia();
//     if (medias != null) {
//       setState(() {
//         images.addAll(medias.map(
//           (file) => MediaItem(
//             file: File(file.path),
//             type: _getType(
//                 File(file.path)), // You need to implement this function
//           ),
//         ));
//       });
//     }
//   }

//   MediaType _getType(File file) {
//     if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
//       return MediaType.video;
//     } else {
//       return MediaType.image;
//     }
//   }

//   Widget _buildMediaPreview(MediaItem media) {
//     if (media.type == MediaType.video) {
//       return VideoPreview(media: media);
//     } else {
//       return Image.file(media.file);
//     }
//   }

//   _setOrgName() async {
//     var _organizationName = await getOrgName();
//     setState(() {
//       _orgName = _organizationName!;
//     });
//   }

//   _setGroupName() async {
//     var _grpName = await getGroupName();
//     setState(() {
//       _groupName = _grpName!;
//     });
//   }

//   _setLeader() async {
//     var v = await getIsLeader();
//     print("Leader: ${v}");
//     setState(() {
//       _isLeader = v;
//     });
//   }

//   Future<String?> getOrgName() async {
//     return await AppSharedPreferences.getValue(key: 'orgName');
//   }

//   Future<String?> getGroupName() async {
//     return await AppSharedPreferences.getValue(key: 'groupName');
//   }

//   Future<String?> getTownhallView() async {
//     return await AppSharedPreferences.getValue(key: 'townhallView');
//   }

//   Future<String?> getIsLeader() async {
//     return await AppSharedPreferences.getValue(key: 'isTownhallLeader');
//   }

//   Future<String?> getOrg() async {
//     return await AppSharedPreferences.getValue(key: 'orgID');
//   }
// }

// class MediaItem {
//   final File file;
//   final MediaType type;

//   MediaItem({required this.file, required this.type});
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
//         AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: VideoPlayer(_controller),
//         ),
//         IconButton(
//           icon: Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             color: Colors.white,
//           ),
//           onPressed: _togglePlayPause,
//         ),
//         Positioned(
//           bottom: 22,
//           right: 5,
//           child: IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () async {
//               await TrimmerView(
//                 startPos: 0.0,
//                 endPos: 0.0,
//                 file: widget.media.file,
//                 duration: '',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
