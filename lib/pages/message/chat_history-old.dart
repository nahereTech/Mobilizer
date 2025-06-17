//import 'dart:html';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart' as post;
import 'package:mobilizer/bloc/search/people_bloc.dart' as people;
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/bloc/messages/messages_bloc.dart';
import 'package:indexed/indexed.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:mobilizer/widget/image_swipe.dart';
//import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:badges/badges.dart';

class ChatHistoryScreen extends StatefulWidget {
  final String userID;
  final String co_chatter;
  final String profile_pics;
  final String profile_name;

  const ChatHistoryScreen(
      {Key? key,
      required this.userID,
      required this.co_chatter,
      required this.profile_pics,
      required this.profile_name})
      : super(key: key);
  static String routeName = 'chat_history';

  @override
  ChatHistoryScreenState createState() => ChatHistoryScreenState();
}

class ChatHistoryScreenState extends State<ChatHistoryScreen> {
  var messageTextController = TextEditingController();
  final _controllerComment = TextEditingController();
  final styleActive = TextStyle(color: Colors.black);
  final styleHint = TextStyle(color: Colors.black54);
  final style = TextStyle(color: Colors.black54);
  final String hintText = 'Search Message';
  String daysAgo = ""; //Ex: Today,Yesterday,Sunday/Monday etc, Wed 7,Dec
  String curDaysAgo = "";
  DateTime? previous_date; //
  String text_to_print = "";
  String messageText = '';
  String last_shown_id = '';
  List<dynamic> data = [];
  List<Asset> images = <Asset>[];
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  FocusNode _focus = FocusNode();
  bool loading = false;
  bool noResult = false;
  bool _isUpdateImage = false;
  bool isLoadingUpRequest = false;
  bool isLastDownRequest = false;
  int indexID = 0;
  String loaderMessage = '';
  ScrollController _scrollController = ScrollController();
  void initState() {
    // List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List;
    // print(args[0]);
    Future.delayed(Duration.zero, () {
      BlocProvider.of<MessagesBloc>(context).add(
        GetChatHistory(
            co_chatter: widget.co_chatter,
            direction: '',
            last_shown_id: '',
            limit: 50),
      );
    });
    _getCachedData(widget.co_chatter);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("OlderDirection");
        if (isLastDownRequest == false) {
          _getOlderChats(50);
        }
      }
    });

    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void _onFocusChange() {
    // setState(() {
    //   refresh = true;
    // });
  }
  @override
  Widget build(BuildContext contextA) {
    return WillPopScope(
      onWillPop: () async => !Loader.isShown,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 70.0,
          title: GestureDetector(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return MultiBlocProvider(
              //     providers: [
              //       BlocProvider(
              //         create: (contextA) => people.PeopleBloc(),
              //       ),
              //       BlocProvider(
              //         create: (context) => post.PostsBloc(),
              //       ),
              //     ],
              //     child: PeopleProfile(subjectID: widget.co_chatter),
              //   );
              // }));
            },
            child: Row(
              children: [
                SizedBox(width: 25),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.profile_pics,
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  _substring(widget.profile_name, 20, ''),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          leading: Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: IconButton(
                    iconSize: 25,
                    icon: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      size: 25,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PopupMenuButton(
                icon: ImageIcon(
                  AssetImage("images/dots.png"),
                  color: Colors.grey,
                  size: 20.0,
                ),
                onSelected: (choice) {
                  Loader.show(
                    context,
                    //isSafeAreaOverlay: false,
                    //isBottomBarOverlay: false,
                    //overlayFromBottom: 80,
                    overlayColor: Colors.black26,
                    progressIndicator: Container(
                      width: 200.0,
                      height: 160.0,
                      child: Column(
                        children: [
                          SpinKitCircle(
                            color: Colors.blue,
                            size: 45.0,
                          ),
                          Text(
                            loaderMessage,
                            style: TextStyle(
                                fontSize: 17,
                                decoration: TextDecoration.none,
                                color: Colors.black54),
                          )
                        ],
                      ),
                    ),
                  );
                  setState(() {
                    loaderMessage = 'Deleting...';
                  });

                  BlocProvider.of<MessagesBloc>(context).add(
                    DeleteChatHistoryEvent(
                      coChatter: widget.co_chatter,
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context) {
                  return [
                    'Delete Conversations',
                  ].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            )
          ],
        ),
        body: AbsorbPointer(
          absorbing: Loader.isShown,
          child: BlocConsumer<MessagesBloc, MessagesState>(
              listener: (context, state) {
            if (state is LoadingState) {
              setState(() {
                loading = true;
                noResult = false;
              });
            }
            if (state is NoResultState) {
              setState(() {
                loading = false;
                noResult = true;
                isLastDownRequest = false;
              });
            }
            if (state is NetworkState) {
              setState(() {
                loading = false;
                noResult = false;
                !Loader.isShown;
                isLastDownRequest = false;
              });
              // loading = false;
              final snackBar = SnackBar(
                  backgroundColor: Color(0xFFcf5555),
                  content: Text(state.message.toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is ChatListState) {
              print("I am in state");
              setState(() {
                loading = false;
                data = state.chatResponse;
                var no = data.length;
                state.chatResponse;
                last_shown_id = data[no - 1].message_id;
                isLastDownRequest = false;
              });
              AppSharedPreferences.setValue(
                  key: 'page_chat_${widget.co_chatter}',
                  value: jsonEncode(data));
              print("Last SHOWN: ${last_shown_id}");
            }
            if (state is PostChatState) {
              Loader.hide();
              setState(() {
                loading = false;
              });
              final snackBar = SnackBar(
                  backgroundColor: Color.fromARGB(255, 46, 198, 130),
                  content: Text("Message sent!"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Future.delayed(Duration(seconds: 5), () {
                Navigator.pop(context);
              });
            }
            if (state is DeleteState) {
              Loader.hide();
              setState(() {
                loading = false;
                data.removeAt(indexID);
              });
              final snackBar = SnackBar(
                  backgroundColor: Color.fromARGB(255, 46, 198, 130),
                  content: Text("Chat was successully deleted!"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (state is DeleteConversationState) {
              Loader.hide();
              setState(() {
                loading = false;
                data = [];
              });
              final snackBar = SnackBar(
                  backgroundColor: Color.fromARGB(255, 46, 198, 130),
                  content: Text("Conversation was successully deleted!"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }, builder: (context, state) {
            double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;
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
                if (data.length == 0 && loading == false)
                  Center(
                    child: Text("No Messages"),
                  ),
                Column(
                  children: [
                    Expanded(
                      flex: 20,
                      child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: data.length,
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          //physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == data.length) {
                              isLastDownRequest = index < 10
                                  ? true
                                  : false; //This is the last down request. No more data to load again.
                              return Container(
                                width: 80.0,
                                height: 80.0,
                                child: data.length == 1
                                    ? SizedBox()
                                    : Container(
                                        child: index < 20
                                            ? null
                                            : SpinKitCircle(
                                                color: Colors.blue,
                                                size: 50.0,
                                              ),
                                      ),
                              );
                            }
                            DateTime msgTime =
                                new DateFormat("yyyy-MM-dd hh:mm:ss")
                                    .parse(data[index].message_time);
                            DateTime currentTime = new DateTime.now();
                            convertDate2(msgTime);
                            List<dynamic> imageList = [];
                            if (data[index].message_images != null) {
                              for (ImageData image
                                  in data[index].message_images!) {
                                imageList.add(image.image_filepath);
                              }
                            }
                            return Column(
                              children: [
                                ContextMenuArea(
                                  verticalPadding: 8,
                                  builder: (contextB) => [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      height: 150,
                                      width: 20,
                                      color: Colors.white,
                                      child: GestureDetector(
                                        onTap: () {
                                          indexID = index;
                                          Loader.show(
                                            context,
                                            //isSafeAreaOverlay: false,
                                            //isBottomBarOverlay: false,
                                            //overlayFromBottom: 80,
                                            overlayColor: Colors.black26,
                                            progressIndicator: Container(
                                              width: 200.0,
                                              height: 160.0,
                                              child: Column(
                                                children: [
                                                  SpinKitCircle(
                                                    color: Colors.blue,
                                                    size: 45.0,
                                                  ),
                                                  Text(
                                                    loaderMessage,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        decoration:
                                                            TextDecoration.none,
                                                        color: Colors.black54),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                          setState(() {
                                            loaderMessage = 'Deleting...';
                                          });

                                          BlocProvider.of<MessagesBloc>(context)
                                              .add(
                                            DeleteMessageEvent(
                                              messageID: data[index].message_id,
                                            ),
                                          );
                                          print(index);
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 0, top: 10, bottom: 10),
                                    child: Align(
                                      alignment: (data[index].from_me == "yes"
                                          ? Alignment.topRight
                                          : Alignment.topLeft),
                                      child: Column(
                                        crossAxisAlignment:
                                            data[index].from_me == "yes"
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          if (imageList.length > 0)
                                            ImageSwipe(imageList: imageList),
                                          Container(
                                            width: 350,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: data[index]
                                                              .from_me ==
                                                          "yes"
                                                      ? Radius.circular(20.0)
                                                      : Radius.zero,
                                                  topRight: data[index]
                                                              .from_me ==
                                                          "yes"
                                                      ? Radius.zero
                                                      : Radius.circular(20.0),
                                                  bottomLeft: data[index]
                                                              .from_me ==
                                                          "yes"
                                                      ? Radius.circular(20.0)
                                                      : Radius.zero,
                                                  bottomRight: data[index]
                                                              .from_me ==
                                                          "yes"
                                                      ? Radius.zero
                                                      : Radius.circular(20.0),
                                                ),
                                                color:
                                                    data[index].from_me == "yes"
                                                        ? Colors.grey.shade200
                                                        : Color(0xffCCE9FD)),
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              data[index].message,
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Text(DateFormat('hh:mm a')
                                                .format(msgTime)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Text(text_to_print),
                              ],
                            );
                          }),
                    ),
                    // Expanded(
                    //   child: buildGridView(),
                    // ),
                    Form(
                      key: _formKey,
                      child: Container(
                        decoration: kMessageContainerDecoration,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // IconButton(
                            //   onPressed: () {
                            //     loadAssets;
                            //   },
                            //   icon: const Icon(Icons.image),
                            //   tooltip: 'Send',
                            // ),
                            Expanded(
                              child: TextFormField(
                                controller: messageTextController,
                                onChanged: (value) {
                                  messageText = value;
                                },
                                decoration: kMessageTextFieldDecoration,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.send),
                                tooltip: 'Send',
                                onPressed: () async {
                                  print("Testing");
                                  if (_formKey.currentState!.validate()) {
                                    Map<String, dynamic> map = Map();
                                    map["message"] = messageTextController.text;
                                    map["message_to"] = widget.co_chatter;
                                    if (images.length > 0) {
                                      map["with_file"] = 'yes';
                                    } else {
                                      map["with_file"] = 'no';
                                    }
                                    for (int i = 0; i < images.length; i++) {
                                      ByteData byteData = await images[i]
                                          .getByteData(quality: 100);
                                      var imageData =
                                          byteData.buffer.asUint8List();
                                      var base64Image = base64Encode(imageData);
                                      map["img_files[" + i.toString() + "]"] =
                                          'data:image/jpeg;base64,' +
                                              base64Image;
                                    }
                                    BlocProvider.of<MessagesBloc>(context).add(
                                      PostChatEvent(createPostRequest: map),
                                    );
                                    messageTextController.clear();
                                  }
                                  setState(() {
                                    loaderMessage = 'Sending...';
                                  });
                                  Loader.show(
                                    context,
                                    //isSafeAreaOverlay: false,
                                    //isBottomBarOverlay: false,
                                    //overlayFromBottom: 80,
                                    overlayColor: Colors.black26,
                                    progressIndicator: Container(
                                      width: 200.0,
                                      height: 160.0,
                                      child: Column(
                                        children: [
                                          SpinKitCircle(
                                            color: Colors.blue,
                                            size: 45.0,
                                          ),
                                          Text(
                                            loaderMessage,
                                            style: TextStyle(
                                                fontSize: 17,
                                                decoration: TextDecoration.none,
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildGridView() {
    return GridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
        crossAxisSpacing: 15,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return Stack(
            children: [
              AssetThumb(
                asset: asset,
                width: 200,
                height: 200,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.multiply_circle_fill,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        images.removeAt(index);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }));
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const AlbumSetting albumSetting = AlbumSetting(
      fetchResults: {
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumRegular,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumVideos,
        ),
      },
    );
    const SelectionSetting selectionSetting = SelectionSetting(
      min: 0,
      max: 3,
      unselectOnReachingMax: true,
    );
    const DismissSetting dismissSetting = DismissSetting(
      enabled: true,
      allowSwipe: true,
    );
    final ThemeSetting themeSetting = ThemeSetting(
      backgroundColor: colorScheme.background,
      selectionFillColor: colorScheme.primary,
      selectionStrokeColor: colorScheme.onPrimary,
      previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
      previewTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
      albumTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
    );
    const ListSetting listSetting = ListSetting(
      spacing: 5.0,
      cellsPerRow: 4,
    );
    final CupertinoSettings iosSettings = CupertinoSettings(
      fetch: const FetchSetting(album: albumSetting),
      theme: themeSetting,
      selection: selectionSetting,
      dismiss: dismissSetting,
      list: listSetting,
    );
    try {
      // resultList = await MultiImagePicker.pickImages(
      //   maxImages: 10,
      //   enableCamera: true,
      //   selectedAssets: images,
      //   cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
      //   materialOptions: MaterialOptions(
      //     actionBarColor: "#27272A",
      //     actionBarTitle: "NaHere",
      //     allViewTitle: "All Photos",
      //     useDetailsView: false,
      //     selectCircleStrokeColor: "#000000",
      //   ),
      // );

      // resultList = await MultiImagePicker.pickImages(
      //   selectedAssets: images,
      //   iosOptions: IOSOptions(
      //     doneButton:
      //         UIBarButtonItem(title: 'Confirm', tintColor: colorScheme.primary),
      //     cancelButton:
      //         UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
      //     albumButtonColor: colorScheme.primary,
      //     settings: iosSettings,
      //   ),
      //   androidOptions: AndroidOptions(
      //     actionBarColor: colorScheme.surface,
      //     actionBarTitleColor: colorScheme.onSurface,
      //     statusBarColor: colorScheme.surface,
      //     actionBarTitle: "Townhall",
      //     allViewTitle: "All Photos",
      //     useDetailsView: false,
      //     selectCircleStrokeColor: colorScheme.primary,
      //     exceptMimeType: {MimeType.PNG, MimeType.JPEG},
      //   ),
      // );
    } on Exception catch (e) {
      error = e.toString();
      print(error);
    }

    if (!mounted) return;

    setState(() {
      _isUpdateImage = true;
      images = resultList;
      // _error = error;
    });
  }

  void convertDate(DateTime msgDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    //final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck = msgDate;
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    print("SENT DATE: ${aDate}");
    print("TODAY DATE: ${today}");

    if (curDaysAgo != daysAgo) {
      daysAgo = curDaysAgo;
    }
    if (aDate == today) {
      curDaysAgo = "Today";
    }
    if (aDate == yesterday) {
      curDaysAgo = "Yesterday";
    }
    if (daysBetween(msgDate, now) > 1 && daysBetween(msgDate, now) <= 7) {
      curDaysAgo = DateFormat('EEEE').format(msgDate);
    }
    if (daysBetween(msgDate, now) > 1 && daysBetween(msgDate, now) > 7) {
      curDaysAgo = DateFormat('E, d MMM').format(msgDate);
    }
    daysAgo = curDaysAgo;
  }

  void convertDate2(DateTime msgDate) {
    final aDate = DateTime(msgDate.year, msgDate.month, msgDate.day); //mgs date
    // final previous_date; //

    if (previous_date != null && previous_date != aDate) {
      //if today or yesterday
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      if (previous_date == today) {
        text_to_print = "Today";
      } else if (previous_date == yesterday) {
        text_to_print = "Yesterday";
      } else if (daysBetween(previous_date!, now) > 1 &&
          daysBetween(previous_date!, now) <= 7) {
        text_to_print = DateFormat('EEEE').format(previous_date!);
      } else if (daysBetween(previous_date!, now) > 1 &&
          daysBetween(previous_date!, now) > 7) {
        text_to_print = DateFormat('E, d MMM').format(previous_date!);
      }
    } else {
      text_to_print = "";
    }
    print("text to print: " + text_to_print);
    previous_date = aDate;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  _getOlderChats(int limit) {
    print("Last Shown ID: ${last_shown_id}");
    print("Co chatter: ${widget.co_chatter}");
    print("limit: ${limit}");
    setState(() {
      isLastDownRequest = true;
    });
    BlocProvider.of<MessagesBloc>(context).add(
      GetChatHistory(
          co_chatter: widget.co_chatter,
          direction: 'older',
          last_shown_id: last_shown_id,
          limit: limit),
    );
    setState(() {});
  }

  // _getNewerChats(int limit) {
  //   setState(() {
  //     isLoadingUpRequest = true;
  //   });
  //   BlocProvider.of<MessagesBloc>(context).add(
  //     GetChatHistory(
  //         co_chatter: widget.co_chatter,
  //         direction: 'newer',
  //         last_shown_id: '7',
  //         limit: limit),
  //   );
  //   setState(() {});
  // }
  _getCachedData(String coChatter) async {
    var pageData = await getPageData('page_chat_${coChatter}');
    if (pageData != null) {
      var json = jsonDecode(pageData);
      setState(() {
        data = json.map<ChatData>((json) => ChatData.fromJson(json)).toList();
        loading = false;
      });
      // print("My Data: ${data[0].message}");
    }
  }

  Future<String?> getPageData(String value) async {
    return await AppSharedPreferences.getValue(key: value);
  }

  String _substring(String char, int count, String pattern) {
    return char.length > count ? char.substring(0, count) + pattern : char;
  }
}
