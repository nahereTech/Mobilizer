import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart';
import 'package:mobilizer/models/parties/parties_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart' as img;
import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:flutter_absolute_path/flutter_absolute_path.dart';

class ResultScreen extends StatefulWidget {
  static String routeName = 'result';
  final String name;
  final String id;
  const ResultScreen({Key? key, required this.name, required this.id})
      : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ScrollController _scrollController = ScrollController();
  PanelController _pc = new PanelController();
  String _headings = "";
  FocusNode _focus = FocusNode();
  bool loading = true;
  bool submitLoader = false;
  bool _showSlideUpPanel = false;
  bool showSubmitLoader = false;
  bool noResult = false;
  List<dynamic> _parties = [];
  List<Map<String, dynamic>> _values = [];
  List<dynamic> imageUrls = [];
  List<dynamic> result = [];
  //List<Asset> images = <Asset>[];
  List<dynamic> _images = []; //uploaded result sheet
  bool _isUpdateImage = false;
  String bsImage = "";
  Map<String, dynamic> map = Map();
  late File imageFile;
  List<ImagesData> _remoteImageList = [];
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<PostsBloc>(context).add(GetPartyEvent(
          countryID: '', forResult: 'yes', theElection: widget.id));
    });
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // setState(() {
    //   refresh = true;
    // });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, 'refresh');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print("PRINT WIDTH: ${size.width - 73}");
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.lightBlue,
              elevation: 0.0,
              title: Text('Polling Unit Result'),
            ),
            // body: SlidingUpPanel(
            //   minHeight: 0.0,
            //   maxHeight: size.height - 150,
            //   borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(20.0),
            //     topRight: Radius.circular(20.0),
            //   ),
            //   onPanelClosed: () {
            //     setState(() {
            //       _showSlideUpPanel = false;
            //     });
            //   },
            //   controller: _pc,
            //   backdropEnabled: true,
            //   panel:
            //   Row(children: [
            //     Padding(
            //       padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
            //       child: Column(
            //         children: [
            //           Column(
            //             children: [
            //               Container(
            //                 width: size.width - 50,
            //                 height: 20.0,
            //                 child: IconButton(
            //                     alignment: Alignment.topRight,
            //                     icon: Icon(Icons.close, color: Colors.grey),
            //                     iconSize: 20.0,
            //                     onPressed: () {
            //                       _pc.close();
            //                     }),
            //               ),
            //               Container(
            //                 width: size.width - 50,
            //                 child: Column(
            //                   children: [
            //                     Container(
            //                       alignment: Alignment.topLeft,
            //                       child: Text(
            //                         'Picture Source',
            //                         style: TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 15),
            //                       ),
            //                     ),
            //                     Divider(
            //                       thickness: 0.5,
            //                       color: Colors.black,
            //                     ),
            //                     Column(
            //                       children: [
            //                         Container(child: Text("From Camera")),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           )
            //         ],
            //       ),
            //     ),
            //   ]),
            body:
                BlocConsumer<PostsBloc, PostsState>(listener: (context, state) {
              if (state is LoadingState) {
                setState(() {
                  loading = true;
                  submitLoader = false;
                  noResult = false;
                });
              }
              if (state is PartyState) {
                setState(() {
                  loading = false;
                  submitLoader = false;
                  noResult = true;
                  _parties = state.partyResponse.data;
                  _headings = state.partyResponse.page_headings;
                  if (state.partyResponse.uploaded_images != null) {
                    _remoteImageList = state.partyResponse.uploaded_images!;
                  }
                });
              }
              if (state is PostResultState) {
                setState(() {
                  loading = false;
                  submitLoader = false;
                });
                print(state.postResultResponse.msg);
                final snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Result was successfully submitted"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              if (state is NetworkState) {
                setState(() {
                  loading = false;
                  submitLoader = false;
                  noResult = false;
                });
                // loading = false;
                final snackBar = SnackBar(
                    backgroundColor: Color(0xFFcf5555),
                    content: Text(state.message.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }, builder: (context, state) {
              return Indexer(
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
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _parties != null && _parties.length > 0
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              left: 5,
                                              top: 15,
                                              bottom: 5,
                                              right: 5),
                                          width: size.width - 25,
                                          child: HtmlWidget(_headings),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        if (bsImage != "")
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 8),
                            width: bsImage != "" ? double.infinity : 0,
                            height: bsImage != "" ? 100 : 0,
                            child: bsImage != "" ? buildGridView() : SizedBox(),
                          ),
                        if (_remoteImageList.length > 0)
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 20),
                            width: _remoteImageList.length > 0
                                ? double.infinity
                                : 0,
                            height: _remoteImageList.length > 0 ? 100 : 0,
                            child: _remoteImageList.length > 0
                                ? buildGridView2()
                                : SizedBox(),
                          ),
                        Flexible(
                          // height: size.height,
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(height: 2),
                              itemCount: _parties.length,
                              itemBuilder: (context, index) {
                                final party = _parties[index];
                                Map<String, dynamic> json = {
                                  "id": index,
                                  "party_id": party.id,
                                  "votes": party.votes.toString(),
                                };
                                _values.add(json);
                                // _isFollowList[index] =
                                //     people.is_following == "yes" ? true : false;
                                return ListTile(
                                    minVerticalPadding: 10.0,
                                    title: Text(
                                      party.fullname,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          party.party_logo,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    trailing: Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: buildTextField(
                                          index,
                                          party.id.toString(),
                                          party.votes.toString()),
                                    ));
                              }),
                        ),
                        if (loading == false && _parties.length > 0)
                          Container(
                            padding: EdgeInsets.only(right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    iconSize: 35,
                                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                                    icon: FaIcon(FontAwesomeIcons.camera),
                                    onPressed: () {
                                      loadAssets('image');
                                      //_pc.show();
                                      // setState(() {
                                      //   _showSlideUpPanel = true;
                                      // });

                                      //loadAssets('image');
                                    }),
                                GestureDetector(
                                  onTap: () {
                                    loadAssets('image');
                                    //loadAssets('image');
                                    // setState(() {
                                    //   _showSlideUpPanel = true;
                                    // });
                                    //_pc.show();
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Upload Result Sheet"),
                                      Text("(Do your best to get a picture)")
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          child: _parties != null && _parties.length > 0
                              ? SizedBox(
                                  width: 140,
                                  height: 50,
                                  child: submitLoader
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
                                      : GFButton(
                                          fullWidthButton: true,
                                          padding: EdgeInsets.all(0),
                                          size: GFSize.MEDIUM,
                                          onPressed: () async {
                                            setState(() {
                                              submitLoader = true;
                                              loading = false;
                                            });
                                            //List<File> fileArray = [];
                                            // images.forEach((imageAsset) async {
                                            //   final filePath =
                                            //       await FlutterAbsolutePath
                                            //           .getAbsolutePath(
                                            //               imageAsset.identifier);

                                            //   File tempFile = File(filePath);
                                            //   if (tempFile.existsSync()) {
                                            //     fileArray.add(tempFile);
                                            //   }
                                            // });

                                            result = [];
                                            result = _values.toList();

                                            // for (int i = 0;
                                            //     i < images.length;
                                            //     i++) {

                                            // }
                                            map["the_result"] = result;
                                            map["the_election"] = widget.id;
                                            map["files[" + 0.toString() + "]"] =
                                                'data:image/jpeg;base64,' +
                                                    bsImage;

                                            BlocProvider.of<PostsBloc>(context)
                                                .add(
                                              PostResultEvent(
                                                postResultRequest: map,
                                                //images: fileArray
                                              ),
                                            );

                                            print("The R ${map}");
                                            print(widget.name);
                                          },
                                          text: ("Submit"),
                                          shape: GFButtonShape.pills,
                                          color: Colors.blue,
                                        ),
                                )
                              : Text(''),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ],
              );
            })));
    // );
  }

  Widget buildGridView() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 200,
              child: imageFile != null
                  ? Image.file(
                      File(imageFile.path),
                      width: 500,
                      height: 100,
                    )
                  : SizedBox(),
            ),
            Positioned(
              left: 50,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.multiply_circle_fill,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          bsImage = "";
                          imageFile.writeAsString('');
                        });
                        print("Image File: ${imageFile}");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGridView2() {
    //uploaded result sheet
    return GridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
        crossAxisSpacing: 15,
        children: List.generate(_remoteImageList.length, (index) {
          return Stack(
            children: [
              Container(
                width: 200,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Image.network(
                    _remoteImageList[index].image_url,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Container(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       IconButton(
              //         icon: Icon(
              //           CupertinoIcons.multiply_circle_fill,
              //           color: Colors.red,
              //         ),
              //         onPressed: () {
              //           setState(() {
              //             bsImage = "";
              //             imageFile.writeAsString('');
              //           });
              //         },
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        }));
  }

  Future<void> loadAssets(String type) async {
    if (type == "image") {
      final img.ImagePicker _picker = img.ImagePicker();

      //List<Asset> resultList = <Asset>[];
      //String error = 'No Error Detected';

      // try {
      //   resultList = await MultiImagePicker.pickImages(
      //     maxImages: 10,
      //     enableCamera: true,
      //     selectedAssets: images,
      //     cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
      //     materialOptions: MaterialOptions(
      //       actionBarColor: "#27272A",
      //       actionBarTitle: "Townhall",
      //       allViewTitle: "All Photos",
      //       useDetailsView: false,
      //       selectCircleStrokeColor: "#000000",
      //     ),
      //   );
      // } on Exception catch (e) {
      //   error = e.toString();
      //   print(error);
      // }

      final img.XFile? photo =
          await _picker.pickImage(source: img.ImageSource.gallery);
      if (photo != null) {
        File photoFile = await File(photo.path);
        Uint8List videoBytes = await photoFile.readAsBytes();
        String bs4str = base64.encode(videoBytes);
        setState(() {
          _remoteImageList = [];
          bsImage = bs4str;
          imageFile = File(photo.path);
        });
        _scrollController.jumpTo(0);
      }
    }
    if (type == "video") {}
  }

  Widget buildTextField(int index, String partyID, String votes) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        //decoration: Input,
        keyboardType: TextInputType.number,
        initialValue: votes == "0" ? "" : votes,
        onTap: () {
          // _scrollController
          //     .jumpTo(_scrollController.position.maxScrollExtent);
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );

          print("Event was called");
        },
        onChanged: (val) {
          _onUpdate(index, int.parse(partyID), val);
          print("This value: ${val}");
        },
      ),
    );
  }

  _onUpdate(int index, int PartyID, String val) async {
    int foundKey = -1;
    for (var map in _values) {
      if (map.containsKey("id")) {
        if (map["id"] == index) {
          foundKey = index;
          break;
        }
      }
    }
    if (-1 != foundKey) {
      _values.removeWhere((map) {
        return map["id"] == foundKey;
      });
      print("I was here");
    }
    Map<String, dynamic> json = {
      "id": index,
      "party_id": PartyID,
      "votes": val,
    };
    _values.add(json);
    print(_values);
  }
}
