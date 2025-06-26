import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';
//import 'package:flick_video_player/flick_video_player.dart';

class VideoBuild extends StatefulWidget {
  final String videoUrl;
  final bool looping;
  final bool autoplay;
  const VideoBuild({
    required this.videoUrl,
    required this.looping,
    required this.autoplay,
  });

  @override
  State<VideoBuild> createState() => _VideoBuildState();
}

class _VideoBuildState extends State<VideoBuild> {
  //late FlickManager _flickManager;
  late VideoPlayerController _videoPlayerController;
  double vHeight = 0.0;
  double vWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerController();
  }

  void _initializeVideoPlayerController() async {
    setState(() {
      // _flickManager = FlickManager(
      //     autoPlay: widget.autoplay,
      //     videoPlayerController:
      //         VideoPlayerController.network(widget.videoUrl));
    });

    await _videoPlayerController.initialize();
    setState(() {
      vHeight = _videoPlayerController.value.size.height;
      vWidth = _videoPlayerController.value.size.width;
    });
    print("Height: " + _videoPlayerController.value.size.height.toString());
  }

  @override
  void dispose() {
    //_flickManager.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: vHeight == 0.0
          ? Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            )
          : Dismissible(
              key: Key(widget.videoUrl),
              direction: DismissDirection.vertical,
              resizeDuration:
                  Duration(milliseconds: 200), // Adjust the resize duration
              dismissThresholds: {
                // Adjust the dismiss thresholds
                DismissDirection.vertical: 0.2, // 20% of the widget's size
              },
              onDismissed: (direction) {
                Navigator.of(context).pop();
              },
              child: OrientationBuilder(builder: (context, orientation) {
                return Center(
                  child: Container(
                    width: vWidth,
                    height: vHeight,
                    child: SizedBox()
                    // FlickVideoPlayer(
                    //   flickManager: _flickManager,
                    //   flickVideoWithControls: FlickVideoWithControls(
                    //     controls: FlickPortraitControls(),
                    //     videoFit: orientation == Orientation.portrait
                    //         ? BoxFit.fitWidth
                    //         : BoxFit.fitHeight,
                    //     aspectRatioWhenLoading: 4 / 3,
                    //   ),
                    // ),
                  ),
                );
              }),
            ),
    );
  }
}
