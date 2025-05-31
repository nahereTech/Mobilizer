import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/people_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/models/profile/get_short_profile_info_response.dart';
import 'package:mobilizer/pages/people/people_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class Messages extends StatefulWidget {
  @override
  final Map<String, dynamic> mapData;
  Messages({required this.mapData, Key? key}) : super(key: key);
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with WidgetsBindingObserver {
  StreamSubscription<DocumentSnapshot>? _userStatusSubscription;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ProfileData? toData;
  ProfileData? fromData;
  String _statusMessage = '';

  final _controllerMessage = TextEditingController();
  Duration typingDelay = Duration(seconds: 2);
  late Timer _timer;
  Timer? _typingTimer;

  DateTime? postDateDiff;
  String _lastSeen = "";
  String _pics = "";
  String _userID = "";
  String _conversationID = "";
  List<dynamic> _toDeviceTokens = [];
  List<Message> cachedMessages = [];

  bool _isOnline = false;
  bool _isTyping = false;

  @override
  void initState() {
    _updateUserStatus(true); // User is online when the app starts
    setState(() {
      _conversationID = widget.mapData['conversationID'];
    });
    _toDeviceTokens.addAll(widget.mapData['toDeviceTokens']);
    if (_conversationID != "") {
      _loadCachedMessages();
    }
    _initProfilePic();
    if (widget.mapData['conversationID'] == "") {
      //check and set conversationID if there is an exist chat(s)
      _initConversationID();
    }
    _fetchFromProfile(widget.mapData['from']);
    super.initState();
    _timer =
        Timer.periodic(Duration(seconds: 59), (Timer t) => _updateTimeAgo());

    _controllerMessage.addListener(() {
      if (_controllerMessage.text.isNotEmpty) {
        _resetTypingTimer();
      } else {
        _typingTimer?.cancel();
        _updateTypingStatus(_conversationID, _userID, false);
      }
    });
    _userSubscription();
    // _connectivitySubscription = Connectivity()
    //     .onConnectivityChanged
    //     .listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.none) {
    //     // Network disconnected
    //     _updateTypingStatus(_conversationID, _userID, false);
    //   }
    // });
    Connectivity()
        .onConnectivityChanged
        .cast<ConnectivityResult>() // Explicitly cast to ConnectivityResult
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Network disconnected
        _updateTypingStatus(_conversationID, _userID, false);
      }
    });
    if (_conversationID != "") {
      _listenForTypingStatus(_conversationID, widget.mapData['to']);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_userID != 'null' || _userID != '') {
      if (state == AppLifecycleState.resumed) {
        _updateUserStatus(true);
      }
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        // App is in background or detached
        _updateTypingStatus(_conversationID, _userID, false);
      } else {
        _updateUserStatus(false);
      }
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _connectivitySubscription.cancel();
    _updateTypingStatus(_conversationID, _userID, false);
    _userStatusSubscription?.cancel();
    _controllerMessage.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.mapData['toPics'],
                  ),
                  radius: 20,
                  // You can set the avatar image here
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor:
                        _isOnline ? Colors.greenAccent : Colors.orange,
                    child: SizedBox(),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                Map<String, dynamic> mapData = {
                  'subjectID': widget.mapData['to'],
                  'picture': widget.mapData['toPics'],
                  'post_update_by': widget.mapData['toName'],
                  'username': widget.mapData['toUsername'],
                };
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (contextA) => PeopleBloc(),
                      ),
                      BlocProvider(
                        create: (context) => PostsBloc(),
                      ),
                    ],
                    child: PeopleProfile(mapData: mapData),
                  );
                }));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _substring(widget.mapData['toName'],
                        20), // Replace with the person's name
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isOnline == false
                        ? "Last seen $_lastSeen"
                        : (_isTyping
                            ? 'typing...'
                            : '@${_substring(widget.mapData['toUsername'], 20)}'),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle:
                            _isTyping ? FontStyle.italic : FontStyle.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert), // Three dot icon
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text("Clear Conversation"),
                value: 1,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: Text("Confirm")),
                        content: Text(
                            "Are you sure you want to clear your conversations?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "No",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black45),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                              _clearConversations(
                                  widget.mapData['conversationID'],
                                  widget.mapData['from']);
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('conversationID', isEqualTo: _conversationID)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs.where((doc) {
                    var deletedBy = doc['deletedBy'] as List<dynamic>?;
                    return deletedBy == null ||
                        !deletedBy.contains(widget.mapData['from']);
                  }).toList();
                  List<Message> messages = docs
                      .map((doc) => Message.fromMap(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  _cacheMessages(messages); // Cache the messages
                  return _buildMessageList(messages);
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading messages"));
                } else if (!snapshot.hasData && cachedMessages.length > 0) {
                  return _buildMessageList(
                      cachedMessages); // Use cached messages if no data from stream
                } else if (!snapshot.hasData) {
                  return Center(child: Text("No conversation"));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllerMessage,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     IconButton(
                //       icon: Icon(Icons.attach_file), // File icon
                //       onPressed: () {
                //         // Add functionality to handle file attachment
                //       },
                //     ),
                //   ],
                // ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        // Add functionality to send message
                        _sendMessage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        print("To: ${widget.mapData['to']}");
        DateTime dateT;
        DateTime currentTime = DateTime.now();
        final message = messages[index];
        List<dynamic> receipts = message.receipts;
        List<dynamic> readBy = message.readBy;
        print("MessageTo ${widget.mapData['to']}");
        bool isDelivered =
            receipts.contains(widget.mapData['to']) ? true : false;
        bool isRead = readBy.contains(widget.mapData['to']);
        print(
            "isRead ${isRead} ${readBy} ${message.text} ${widget.mapData['to']}");
        if (message.id != '' && readBy.contains(_userID) == false) {
          _onRead(message.id);
        }
        if (message.timestamp != null) {
          dateT = message.timestamp.toDate();
        } else {
          dateT = currentTime;
        }
        Duration difference =
            currentTime.difference(DateTime.parse(dateT.toString()));
        DateTime postDateDiff = currentTime.subtract(difference);

        final EdgeInsetsGeometry padding =
            message.from.toString() == widget.mapData['from']
                ? EdgeInsets.fromLTRB(30.0, 8.0, 8.0, 8.0)
                : EdgeInsets.fromLTRB(8.0, 8.0, 30.0, 8.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: padding,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: message.from.toString() == widget.mapData['from']
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft:
                            message.from.toString() == widget.mapData['from']
                                ? Radius.circular(15)
                                : Radius.circular(0),
                        bottomRight:
                            message.from.toString() == widget.mapData['from']
                                ? Radius.circular(0)
                                : Radius.circular(15),
                      ),
                    ),
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          // _decryptData(message.text, 'xperience1111'),
                          style: TextStyle(
                            color: message.from.toString() ==
                                    widget.mapData['from']
                                ? Colors.white
                                : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Align(
                          alignment:
                              message.from.toString() == widget.mapData['from']
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Text(
                            '. ' + _getTimeAgo(postDateDiff),
                            style: TextStyle(
                              color: message.from.toString() ==
                                      widget.mapData['from']
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  message.from.toString() == widget.mapData['from']
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              isDelivered ? Icons.done_all_rounded : Icons.done,
                              color: isRead ? Colors.blue : Colors.black38,
                              size: 25,
                            ),
                          ],
                        )
                      : SizedBox()
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_controllerMessage.text.isNotEmpty) {
      final msg = _controllerMessage.text;
      final encryMsg = _encryptData(msg, 'xperience1111');
      FocusScope.of(context).unfocus();
      _controllerMessage.clear();
      try {
        //check conversations collections
        if (_conversationID != "") {
          DocumentReference docRef =
              await FirebaseFirestore.instance.collection('messages').add({
            'text': msg,
            'from': widget.mapData['from'],
            'deletedBy': [],
            'readBy': FieldValue.arrayUnion([_userID]),
            'receipts': FieldValue.arrayUnion([_userID]),
            'to': widget.mapData['to'],
            'timestamp': FieldValue.serverTimestamp(),
            'conversationID': _conversationID
          });
          _updateUserStatus(true);
          final int unread = await _getUnreadMessageCount(widget.mapData['to']);
          _sendPushNotification(
              widget.mapData['conversationID'],
              msg,
              widget.mapData['fromName'] == ""
                  ? fromData!.firstname.toString() +
                      " " +
                      fromData!.lastname.toString()
                  : widget.mapData['fromName'],
              widget.mapData['to'],
              widget.mapData['from'],
              _pics,
              _toDeviceTokens,
              unread);
        } else {
          //create conversation before submitting message
          DocumentReference docRef =
              await FirebaseFirestore.instance.collection('conversations').add({
            'participants': FieldValue.arrayUnion(
                [widget.mapData['from'], widget.mapData['to']]),
          });
          setState(() {
            _conversationID = docRef.id;
          });
          //you submit the message using the conversation document ID
          FirebaseFirestore.instance.collection('messages').add({
            'text': msg,
            'from': widget.mapData['from'],
            'deletedBy': [],
            'readBy': FieldValue.arrayUnion([_userID]),
            'receipts': FieldValue.arrayUnion([_userID]),
            'to': widget.mapData['to'],
            'timestamp': FieldValue.serverTimestamp(),
            'conversationID': _conversationID
          });
          FirebaseFirestore.instance
              .collection('typing_events')
              .doc(_conversationID)
              .set({
            'participants': [],
          });
          _updateUserStatus(true);
          final int unread = await _getUnreadMessageCount(widget.mapData['to']);
          _sendPushNotification(
              _conversationID,
              msg,
              widget.mapData['fromName'] == ""
                  ? fromData!.firstname.toString() +
                      " " +
                      fromData!.lastname.toString()
                  : widget.mapData['fromName'],
              widget.mapData['to'],
              widget.mapData['from'],
              _pics,
              _toDeviceTokens,
              unread);

          //after submit record if the conversation ID exist
          //or create new conversation and get the ID
        }
      } catch (e) {
        setState(() {
          _statusMessage = 'Failed to send message: $e';
        });
      }
    }
  }

  Future<int> _getUnreadMessageCount(String userID) async {
    try {
      // Firestore collection reference
      CollectionReference messagesRef =
          FirebaseFirestore.instance.collection('messages');

      // Query to get unread messages count
      QuerySnapshot querySnapshot = await messagesRef
          .where('to', isEqualTo: userID)
          .where('readBy',
              arrayContains: userID) // Assuming 'readBy' is an array field
          .get();

      // Return the count of unread messages
      return querySnapshot.docs.length;
    } catch (e) {
      // Handle errors
      print('Error retrieving unread message count: $e');
      return 0; // Return 0 or handle error as per your app's logic
    }
  }

  void _clearConversations(String conversationID, String userID) async {
    // Reference to the Firestore collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('messages');

    // Query to find all documents where userID is 5
    Query query = collection.where('conversationID', isEqualTo: conversationID);

    // Get the documents
    QuerySnapshot querySnapshot = await query.get();

    // Iterate through each document and update it
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Assuming you want to update the 'status' field to 'active'
      await collection.doc(doc.id).update({
        'deletedBy': FieldValue.arrayUnion([userID]),
        // Add other fields you want to update
      }).then((_) {
        print('Document with ID: ${doc.id} updated successfully.');
      }).catchError((error) {
        print('Error updating document: $error');
      });
    }
  }

  Future<void> _sendPushNotification(
      String conversationID,
      String body,
      String title,
      String to,
      String from,
      String fromPics,
      List deviceToken,
      int unread) async {
    // Retrieve the FCM bearer token
    String? bearer = await getFCMToken();
    const String url =
        'https://us-central1-townhall-c8792.cloudfunctions.net/sendPushNotification';

    if (deviceToken.isNotEmpty && bearer != null) {
      debugPrint("Devices1: $deviceToken");
      for (var i = 0; i < deviceToken.length; i++) {
        print("messageTo $to");
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $bearer', // Add the bearer token here
          },
          body: jsonEncode({
            'token': deviceToken[i].toString(),
            'message': {
              'title': title,
              'body': body,
              'data': {
                'notification_type': 'chat',
                'conversationID': conversationID,
                'messageTo': to,
                'toPics': '',
                'toUsername': '',
                'toName': '',
                'messageFrom': from,
                'fromPics': fromPics,
                'unread': unread,
              },
            },
          }),
        );
        if (response.statusCode == 200) {
          print('Notification sent successfully');
        } else {
          debugPrint(
              'Error: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
        }
      }
    } else {
      print("Device tokens list is empty or bearer token is null.");
    }
  }

  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      String? bearerToken = await messaging.getToken();
      print("FCM Token: $bearerToken");
      return bearerToken;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }

  void _onRead(String docID) async {
    print("Ref IDz $_userID ${docID}");
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(docID)
          .update({
        'receipts': FieldValue.arrayUnion([_userID]),
        'readBy': FieldValue.arrayUnion([_userID]),
      });
    } catch (e) {
      print("Ref ID ${docID} $e");
    }
  }

  void _updateTimeAgo() {
    if (mounted)
      setState(() {
        postDateDiff;
      });
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  String _getTimeAgo(DateTime dt) {
    String timeAgo = timeago.format(dt, locale: 'en_short');
    return timeAgo; // Return the formatted time ago string
  }

  void _initConversationID() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('messages');
    Query query = collection
        .where('from', isEqualTo: widget.mapData['from'])
        .where('to', isEqualTo: widget.mapData['to'])
        .limit(1);
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      print("Am here");
      QueryDocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final conversationID = data['conversationID'];
      setState(() {
        _conversationID = conversationID;
      });
    }
  }

  void _resetTypingTimer() {
    if (_typingTimer != null && _typingTimer!.isActive) {
      _typingTimer!.cancel();
    }
    _updateTypingStatus(_conversationID, _userID, true);
    _typingTimer = Timer(typingDelay, () {
      _updateTypingStatus(_conversationID, _userID, false);
    });
  }

  void _updateTypingStatus(
      String conversationID, String userId, bool isTyping) {
    try {
      if (conversationID != "") {
        FirebaseFirestore.instance
            .collection('typing_events')
            .doc(conversationID)
            .update({
          'participants': isTyping
              ? FieldValue.arrayUnion([userId])
              : FieldValue.arrayRemove([userId])
        });
      }
    } catch (e) {
      debugPrint("catch typing event error");
    }
  }

  Stream<DocumentSnapshot> _getTypingStatusStream(String conversationID) {
    return FirebaseFirestore.instance
        .collection('typing_events')
        .doc(conversationID)
        .snapshots();
  }

  void _listenForTypingStatus(String conversationID, String to) {
    _getTypingStatusStream(conversationID).listen((snapshot) {
      try {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          List<dynamic> typingUsers = data['participants'] ?? [];
          if (mounted) {
            setState(() {
              _isTyping = typingUsers.contains(to);
            });
          }
        }
      } catch (e) {
        debugPrint("catch typing error");
      }
    });
  }

  Future<void> _loadCachedMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('cachedMessages_${_conversationID}');
      if (cachedData != null) {
        List<dynamic> decodedData = jsonDecode(cachedData);
        setState(() {
          cachedMessages = decodedData.map((e) {
            final Map<String, dynamic> data = e as Map<String, dynamic>;
            final String id = data['id'] ?? '';
            return Message.fromMap(data, id);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("catch loadingcatch error");
    }
  }

  String _encryptData(String plainText, String key) {
    final keyBytes = utf8.encode(key);
    final keyHash = sha256.convert(keyBytes).bytes;
    final encryptionKey = encrypt.Key(Uint8List.fromList(keyHash));
    final iv = encrypt.IV.fromLength(16); // Initialization Vector

    final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  String _decryptData(String encryptedText, String key) {
    if (!_isValidEncryptedFormat(encryptedText)) {
      return encryptedText;
    }
    final keyBytes = utf8.encode(key);
    final keyHash = sha256.convert(keyBytes).bytes;
    final encryptionKey = encrypt.Key(Uint8List.fromList(keyHash));
    final iv = encrypt.IV.fromLength(16); // Initialization Vector

    final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));
    try {
      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      throw Exception("Failed to decrypt text: $e");
    }
  }

  bool _isValidEncryptedFormat(String text) {
    // Simple check for length. Encrypted strings typically have a length that is a multiple of 4.
    return text.length % 4 == 0 && _isBase64(text);
  }

  bool _isBase64(String text) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64Regex.hasMatch(text);
  }

  Future<void> _cacheMessages(List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> dataToCache =
        messages.map((e) => e.toMap()).toList();
    await prefs.setString(
        'cachedMessages_${_conversationID}', jsonEncode(dataToCache));
  }

  Future<void> _initProfilePic() async {
    final pics = await AppSharedPreferences.getValue(key: 'profilePic');
    setState(() {
      _pics = pics.toString();
    });
    print("P ${pics}");
  }

  Future<void> _fetchToProfile(String subjectID) async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");
    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/get_user_profile_pickcolumn?subjects_id=$subjectID&params="firstname,lastname,picture,device_tokens,username,email"'),
        headers: {
          'Authorization': token!,
        },
      );
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          setState(() {
            toData = ProfileData.fromJson(responseData['data']);
          });
        } else {
          throw Exception('Invalid response format: data field is missing');
        }
      } else {
        debugPrint("Response code: " + response.statusCode.toString());
        print("am here");
      }
    } catch (e) {
      debugPrint("catch fetch profile error");
    }
  }

  Future<void> _updateUserStatus(bool status) async {
    try {
      final userID = await AppSharedPreferences.getValue(key: 'user_id');
      setState(() {
        _userID = userID.toString();
      });

      if (_userID != "null" || _userID != "") {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userID)
            .update({
          'isOnline': status,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("catch update user error");
    }
  }

  Future<void> _fetchFromProfile(String userID) async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");

    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/get_user_profile_pickcolumn?subjects_id=$userID&params="firstname,lastname,picture,device_tokens,username,email"'),
        headers: {
          'Authorization': token!,
        },
      );
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          setState(() {
            fromData = ProfileData.fromJson(responseData['data']);
          });
        } else {
          throw Exception('Invalid response format: data field is missing');
        }
      } else {
        debugPrint("Response code: " + response.statusCode.toString());
        print("am here");
      }
    } catch (e) {
      debugPrint("update profile error");
    }
  }

  void _userSubscription() {
    try {
      _userStatusSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.mapData['to']) // Specify the document ID to listen to
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          var doc = snapshot.data() as Map<String, dynamic>;
          final difference = DateTime.now()
              .difference(DateTime.parse(doc['lastSeen'].toDate().toString()));
          DateTime seenDateDiff = DateTime.now().subtract(difference);
          if (mounted) {
            setState(() {
              _isOnline =
                  doc['isOnline']; // Update state based on document data
              _lastSeen = timeago.format(seenDateDiff);
            });
          }
          print('Document data: ${snapshot.id}, ${doc} ${_lastSeen}');
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      debugPrint("user status error");
    }
  }
}

class Message {
  final String id;
  final String from;
  final String text;
  final Timestamp timestamp;
  final List<dynamic> deletedBy;
  final List<dynamic> receipts;
  final List<dynamic> readBy;

  Message({
    required this.id,
    required this.from,
    required this.text,
    required this.timestamp,
    required this.deletedBy,
    required this.receipts,
    required this.readBy,
  });

  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      from: data['from'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] is Timestamp
          ? data['timestamp']
          : Timestamp.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      deletedBy: data['deletedBy'] ?? [],
      receipts: data['receipts'] ?? [],
      readBy: data['readBy'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'deletedBy': deletedBy,
      'receipts': receipts,
      'readBy': readBy,
    };
  }
}
