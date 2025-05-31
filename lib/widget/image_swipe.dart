import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobilizer/pages/feed/show_video_screen.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'dart:core';

class ImageSwipe extends StatefulWidget {
  final List imageList;

  ImageSwipe({required this.imageList});

  @override
  _ImageSwipeState createState() => _ImageSwipeState();
}

class _ImageSwipeState extends State<ImageSwipe> {
  int _selectedPage = 0;
  int _clickedID = 0;
  List<Image> remoteImages = [];
  List<int> intArr = [1, 2, 3, 4, 5];

  StreamController<Widget> overlayController =
      StreamController<Widget>.broadcast();
  @override
  void dispose() {
    overlayController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Arr ${widget.imageList.length}");
    return Container(
      height: 200.0,
      child: Stack(
        children: [
          PageView(
            onPageChanged: (num) {
              setState(() {
                _selectedPage = num;
              });
            },
            children: [
              for (int i = 0; i < widget.imageList.length; i++)
                // remoteImages.add(Image.network('${widget.imageList[i]}'));
                // _addToArr(Image.network('${widget.imageList[i]}'));

                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 0),
                  child: Container(
                      // decoration: BoxDecoration(
                      //   border: Border.all(
                      //     color: Colors.grey,
                      //   ),
                      //   borderRadius: BorderRadius.all(
                      //     Radius.circular(20),
                      //   ),
                      // ),
                      child: GestureDetector(
                    onTap: () async {
                      _clickedID = i;
                      print("Subject ID ${_clickedID}");
                      widget.imageList[_clickedID]['type'] == "video"
                          ? await Navigator.pushNamed(
                              context, ShowVideoScreen.routeName, arguments: [
                              widget.imageList[_clickedID]['mp4_video']
                            ])
                          : SwipeImageGallery(
                              context: context,
                              //children: widget.imageList[i],
                              initialIndex: _clickedID,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Stack(
                                    children: [
                                      Image.network(widget.imageList[index]
                                                  ['type'] ==
                                              "image"
                                          ? widget.imageList[index]['name']
                                          : widget.imageList[index]
                                              ['thumbnail']),
                                      if (widget.imageList[index]['type'] ==
                                          "video")
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                    context,
                                                    ShowVideoScreen.routeName,
                                                    arguments: [
                                                      widget.imageList[index]
                                                          ['mp4_video']
                                                    ]);
                                              },
                                              child: IconButton(
                                                iconSize: 35,
                                                onPressed: () async {
                                                  debugPrint("Video click");
                                                  await Navigator.pushNamed(
                                                      context,
                                                      ShowVideoScreen.routeName,
                                                      arguments: [
                                                        widget.imageList[index]
                                                            ['mp4_video']
                                                      ]);
                                                },
                                                icon: Icon(
                                                  Icons.play_circle_sharp,
                                                ),
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },

                              itemCount: widget.imageList.length,
                            ).show();
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "${widget.imageList[i]['type'] == "image" ? widget.imageList[i]['name'] : widget.imageList[i]['thumbnail']}",
                            fit: BoxFit.cover,
                            //width: 350,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                        if (widget.imageList[i]['type'] == "video")
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                iconSize: 35,
                                onPressed: () async {
                                  // print(
                                  //     "Video: ${widget.imageList[i]['mp4_video']}");

                                  // await Navigator.pushNamed(
                                  //     context, ShowVideoScreen.routeName,
                                  //     arguments: [
                                  //       widget.imageList[i]['mp4_video']
                                  //     ]);

                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ShowVideoScreen(args: [
                                      widget.imageList[i]['mp4_video']
                                    ]);
                                  }));
                                },
                                icon: Icon(
                                  Icons.play_circle_sharp,
                                  size: 70,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var v = 0; v < widget.imageList.length; v++)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    width: _selectedPage == v ? 35.0 : 10.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0)),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _addToArr(Image name) {
    remoteImages.add(name);
  }
}
