import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/profile/get_short_profile_info_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsHistory extends StatefulWidget {
  @override
  State<ConversationsHistory> createState() => _ConversationsHistoryState();
}

class _ConversationsHistoryState extends State<ConversationsHistory>
    with WidgetsBindingObserver {
  String _userID = '';
  List<CachedConversation>? cachedDocs;
  Map<String, ProfileData> profileCache = {};
  late Timer _timer;
  DateTime? postDateDiff;
  Timer? _typingTimer;

  bool _isTyping = false;
  @override
  void initState() {
    super.initState();
    _loadCachedConversations();
    _timer =
        Timer.periodic(Duration(seconds: 59), (Timer t) => _updateTimeAgo());
    WidgetsBinding.instance!.addObserver(this);
    _updateUserStatus(true); // User is online when the app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("Away2");
    super.didChangeAppLifecycleState(state);
    if (_userID != 'null' || _userID != '') {
      if (state == AppLifecycleState.resumed) {
        _updateUserStatus(true);
      } else {
        _updateUserStatus(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
        ),
        //actions: [
        // IconButton(
        //   icon: Icon(Icons.block),
        //   onPressed: () {
        //     // Implement search functionality here
        //   },
        // ),
        // PopupMenuButton(
        //   itemBuilder: (context) => [
        //     PopupMenuItem(
        //       child: Text('Option 1'),
        //     ),
        //     PopupMenuItem(
        //       child: Text('Option 2'),
        //     ),
        //     PopupMenuItem(
        //       child: Text('Option 3'),
        //     ),
        //   ],
        //   icon: Icon(Icons.more_vert),
        // ),
        //],
      ),
      body: _buildTaskList(),

      // SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.all(15.0),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(15),
      //             border: Border.all(
      //                 color: Colors.grey), // You can customize the border color
      //           ),
      //           child: TextField(
      //             decoration: InputDecoration(
      //               hintText: 'Search...',
      //               prefixIcon: Icon(Icons.search),
      //               border: InputBorder
      //                   .none, // Remove the border from the input decoration
      //             ),
      //             onChanged: (value) {
      //               // Implement search functionality here
      //             },
      //           ),
      //         ),
      //       ),

      //       _buildTaskList(), // Use the custom task list builder
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildTaskList() {
    // return ListView.builder(
    //   shrinkWrap: true,
    //   physics: NeverScrollableScrollPhysics(),
    //   itemCount: 20, // Example: adjust the number of tasks
    //   itemBuilder: (context, index) {
    //     return GestureDetector(
    //       onTap: () {
    //         // Navigate to ChatConversation page
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => Messages()),
    //         );
    //       },
    //       child: Container(
    //         margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    //         decoration: BoxDecoration(
    //           color: Colors.grey[200],
    //           borderRadius: BorderRadius.circular(15.0),
    //         ),
    //         child: ListTile(
    //           leading: const CircleAvatar(
    //             backgroundImage: CachedNetworkImageProvider(
    //               'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/28da1872-8865-47fa-edae-a0f0c6a3a200/mid',
    //             ),
    //             radius: 24,
    //           ),
    //           title: Text(
    //             'Ugochukwu Marachino Nwagba ${index + 1}',
    //             style: const TextStyle(
    //               fontWeight: FontWeight.bold,
    //             ),
    //             overflow: TextOverflow.ellipsis,
    //             maxLines: 1,
    //           ),
    //           subtitle: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 'Description of Protocol ${index + 1}',
    //                 overflow: TextOverflow.ellipsis,
    //                 maxLines: 1,
    //               ),
    //               const Text(
    //                 '5.00pm',
    //                 overflow: TextOverflow.ellipsis,
    //                 maxLines: 1,
    //               ),
    //             ],
    //           ),
    //           trailing: Stack(
    //             alignment: Alignment.center,
    //             children: [
    //               Icon(
    //                 Icons.lightbulb_outline,
    //                 color: Colors.grey,
    //               ),
    //               CircleAvatar(
    //                 radius: 10,
    //                 backgroundColor: Colors.red,
    //                 child: Text(
    //                   '5', // Replace with the desired number
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 12,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );

    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('to', isEqualTo: _userID)
          .orderBy('timestamp', descending: true)
          .limit(25)
          .snapshots()
          .asyncMap((snapshot) async {
        final toDocs = snapshot.docs;

        final fromSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('from', isEqualTo: _userID)
            .orderBy('timestamp', descending: true)
            .limit(25)
            .get();

        final fromDocs = fromSnapshot.docs;

        final allDocs = toDocs + fromDocs;

        final filteredDocs = allDocs.where((doc) {
          var data = doc.data();
          List<dynamic>? deletedBy = data['deletedBy'] as List<dynamic>?;
          bool isDeleted = deletedBy != null && deletedBy.contains(_userID);
          return !isDeleted;
        }).toList();

        return filteredDocs;
      }),
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
              snapshot) {
        List<Map<String, dynamic>> docs;
        if (snapshot.hasData) {
          _cacheConversations(snapshot.data!);
          docs = snapshot.data!
              .map((doc) => {'id': doc.id, 'data': doc.data()})
              .toList();
        } else if (cachedDocs != null) {
          docs = cachedDocs!.map((e) => {'id': e.id, 'data': e.data}).toList();
        } else {
          return _buildShimmerList();
        }

        // Group messages by conversationID and count unread messages
        Map<String, int> unreadCounts = {};
        for (var doc in docs) {
          String conversationID = doc['data']['conversationID'];
          if (!unreadCounts.containsKey(conversationID)) {
            unreadCounts[conversationID] = 0;
          }

          var data = doc['data'];
          List<dynamic>? readBy = data['readBy'] as List<dynamic>?;
          final List receipts = data['receipts'];
          bool isUnread = readBy == null || !readBy.contains(_userID);

          if (isUnread) {
            unreadCounts[conversationID] = unreadCounts[conversationID]! + 1;
          }
          if (!receipts.contains(_userID)) //update receipts
          {
            _onRecieved(doc['id']);
          }
        }

        // Ensure all conversation IDs are included, even those with 0 unread counts
        Map<String, List<Map<String, dynamic>>> groupedDocs = {};
        for (var doc in docs) {
          String conversationID = doc['data']['conversationID'];
          if (!groupedDocs.containsKey(conversationID)) {
            groupedDocs[conversationID] = [];
          }
          groupedDocs[conversationID]!.add(doc['data']);
        }

        // Convert grouped messages map to a list of conversationIDs and unread counts
        List<MapEntry<String, int>> groupedMessagesList = groupedDocs.entries
            .map((entry) => MapEntry(entry.key, unreadCounts[entry.key] ?? 0))
            .toList();

        return ListView.builder(
          itemCount: groupedMessagesList.length,
          itemBuilder: (context, index) {
            final entry = groupedMessagesList[index];
            final conversationID = entry.key;
            final unreadCount = entry.value;

            final doc = groupedDocs[conversationID]!.first;

            DateTime currentTime = DateTime.now();
            DateTime dateT;
            if (doc['timestamp'] != null) {
              dateT = doc['timestamp'].toDate();
            } else {
              dateT = currentTime;
            }
            Duration difference = currentTime.difference(dateT);
            DateTime postDateDiff = currentTime.subtract(difference);
            final toID = _userID == doc['to'].toString()
                ? doc['from'].toString()
                : doc['to'].toString();
            print("To ID $toID from ${doc['from']} to ${doc['to']}");
            print("Unread $unreadCount");

            if (profileCache.containsKey(toID)) {
              final toData = profileCache[toID]!;
              _fetchProfile(toID, updateCache: true);
              print(toData.firstname);
              List _toDeviceTokens = [];
              if (toData.device_tokens != null &&
                  toData.device_tokens!.isNotEmpty) {
                for (DeviceTokensData token in toData.device_tokens!) {
                  _toDeviceTokens.add(token.device_token);
                }
                print("Devices: ${_toDeviceTokens}");
              } else {
                print("No device tokens available");
              }
              return GestureDetector(
                onTap: () async {
                  int calUnread = 0;
                  //get unread messages count from sharedPre
                  final prefUnreadMsg =
                      await AppSharedPreferences.getInt(key: 'unreadMessages');
                  if (prefUnreadMsg != null && prefUnreadMsg != 0) {
                    calUnread = unreadCount >
                            int.parse(prefUnreadMsg.toString())
                        ? (unreadCount - int.parse(prefUnreadMsg.toString()))
                        : (int.parse(prefUnreadMsg.toString()) - unreadCount);
                  }
                  await AppSharedPreferences.setInt(
                      key: 'unreadMessages', value: calUnread);
                  Map<String, dynamic> mapData = {
                    'from': _userID,
                    'fromPics': '',
                    'fromName': '',
                    'fromUsername': '',
                    'toName': '${toData.firstname} ${toData.lastname}',
                    'toUsername': toData.username,
                    'to': toID,
                    'toPics': toData.photo_path_mid,
                    'conversationID': conversationID,
                    'toDeviceTokens': _toDeviceTokens,
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Messages(
                        mapData: mapData,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(toData.photo_path_mid),
                      radius: 24,
                    ),
                    title: Text(
                      '${toData.firstname} ${toData.lastname}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${doc['text']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '. ' + _getTimeAgo(postDateDiff),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    trailing: unreadCount > 0
                        ? CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            } else {
              return FutureBuilder<ProfileData>(
                future: _fetchProfile(toID),
                builder: (context, fromSnapshot) {
                  if (!fromSnapshot.hasData) {
                    return SizedBox();
                    //return Center(child: CircularProgressIndicator());
                  }
                  if (fromSnapshot.hasError) {
                    return Center(child: Text('Error loading profile'));
                  }
                  final toData = fromSnapshot.data!;
                  print(toData.firstname);
                  List _toDeviceTokens = [];
                  final message = doc['text'];
                  if (toData.device_tokens != null &&
                      toData.device_tokens!.isNotEmpty) {
                    for (DeviceTokensData token in toData.device_tokens!) {
                      _toDeviceTokens.add(token.device_token);
                    }
                    print("Devices: ${_toDeviceTokens}");
                  } else {
                    print("No device tokens available");
                  }
                  return GestureDetector(
                    onTap: () async {
                      int calUnread = 0;
                      //get unread messages count from sharedPre
                      final prefUnreadMsg = await AppSharedPreferences.getInt(
                          key: 'unreadMessages');
                      if (prefUnreadMsg != null && prefUnreadMsg != 0) {
                        calUnread =
                            unreadCount > int.parse(prefUnreadMsg.toString())
                                ? (unreadCount -
                                    int.parse(prefUnreadMsg.toString()))
                                : (int.parse(prefUnreadMsg.toString()) -
                                    unreadCount);
                      }
                      AppSharedPreferences.setInt(
                          key: 'unreadMessages', value: calUnread);
                      Map<String, dynamic> mapData = {
                        'from': _userID,
                        'fromPics': '',
                        'fromName': '',
                        'fromUsername': '',
                        'toName': '${toData.firstname} ${toData.lastname}',
                        'toUsername': toData.username,
                        'to': toID,
                        'toPics': toData.photo_path_mid,
                        'conversationID': conversationID,
                        'toDeviceTokens': _toDeviceTokens,
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Messages(
                            mapData: mapData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(toData.photo_path_mid),
                          radius: 24,
                        ),
                        title: Text(
                          '${toData.firstname} ${toData.lastname}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              //_decryptData(message.toString(), "xperience1111"),
                              message,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              '. ' + _getTimeAgo(postDateDiff),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        trailing: unreadCount > 0
                            ? CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildShimmerList() {
    // print(_filteredOrganizations);
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> fetchMessages() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(25)
        .get();

    return querySnapshot.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic>? deletedBy = data['deletedBy'] as List<dynamic>?;
      return deletedBy == null || !deletedBy.contains(_userID);
    }).toList();
  }

  Stream<List<DocumentSnapshot>> fetchMessagesStream() {
    var query1 = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: _userID)
        .where('deleteBy', whereNotIn: [_userID])
        .orderBy('timestamp', descending: true)
        .snapshots();

    var query2 = FirebaseFirestore.instance
        .collection('messages')
        .where('to', isEqualTo: '45')
        .orderBy('timestamp', descending: true)
        .snapshots();

    var controller = StreamController<List<DocumentSnapshot>>();

    var subscriptions = <StreamSubscription>[];

    void addSnapshots(QuerySnapshot snapshot) {
      var documents = snapshot.docs;
      controller.add(documents);
    }

    subscriptions.add(query1.listen(addSnapshots));
    subscriptions.add(query2.listen(addSnapshots));

    // Cancel all subscriptions when the controller's stream is closed
    controller.onCancel = () {
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
    };
    return controller.stream;
  }

  void _updateTimeAgo() {
    if (mounted)
      setState(() {
        postDateDiff;
      });
  }

  Future<void> _onRecieved(String id) async {
    print("Ref ID ${id}");
    await FirebaseFirestore.instance.collection('messages').doc(id).update({
      'receipts': FieldValue.arrayUnion([_userID]),
    });
  }

  Future<void> _loadCachedConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedConversations');
    if (cachedData != null) {
      final List<dynamic> decodedData = jsonDecode(cachedData);
      setState(() {
        cachedDocs =
            decodedData.map((e) => CachedConversation.fromJson(e)).toList();
      });
    }
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

  Future<void> _cacheConversations(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CachedConversation> cacheList = docs
        .map((doc) => CachedConversation(
            id: doc.id, data: doc.data() as Map<String, dynamic>))
        .toList();
    await prefs.setString('cachedConversations',
        jsonEncode(cacheList.map((e) => e.toJson()).toList()));
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  String _getTimeAgo(DateTime dt) {
    String timeAgo = timeago.format(dt, locale: 'en_short');
    return timeAgo; // Return the formatted time ago string
  }

  Future<void> _cacheProfile(String subjectID, ProfileData profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'profile_$subjectID',
      jsonEncode(profileData.toJson()),
    );
    print('Cached profile data for $subjectID: ${profileData.toJson()}');
  }

  Future<ProfileData> _fetchProfile(String subjectID,
      {bool updateCache = false}) async {
    if (updateCache == false) {
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('profile_$subjectID');
      if (cachedProfile != null) {
        final profileData = ProfileData.fromJson(jsonDecode(cachedProfile));
        profileCache[subjectID] = profileData;
        return profileData;
      }
    }

    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");
    print("subject ${subjectID}");
    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/profile/get_user_profile_pickcolumn?subjects_id=$subjectID&params="firstname,lastname,picture,device_tokens,username,email"'),
        headers: {
          'Authorization': token!,
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        print("response ${response.body}");
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          final profileData = ProfileData.fromJson(responseData['data']);
          profileCache[subjectID] =
              profileData; // Cache the profile data in memory
          _cacheProfile(subjectID,
              profileData); // Store the profile data in SharedPreferences
          return profileData;
        } else {
          throw Exception('Invalid response format: data field is missing');
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> _updateUserStatus(bool status) async {
    try {
      final userID = await AppSharedPreferences.getValue(key: 'user_id');
      setState(() {
        _userID = userID.toString();
      });
      print('User ID: ${_userID}');
      await FirebaseFirestore.instance.collection('users').doc(_userID).update({
        'isOnline': status,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }
}

class CachedConversation {
  final String id;
  final Map<String, dynamic> data;

  CachedConversation({required this.id, required this.data});

  factory CachedConversation.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = Map<String, dynamic>.from(json['data']);

    // Convert timestamp strings back to Timestamp objects
    data['timestamp'] = data['timestamp'] != null
        ? Timestamp.fromMillisecondsSinceEpoch(
            DateTime.parse(data['timestamp']).millisecondsSinceEpoch)
        : null;

    return CachedConversation(
      id: json['id'],
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dataCopy = Map<String, dynamic>.from(data);

    // Convert Timestamp objects to strings
    dataCopy['timestamp'] = dataCopy['timestamp'] != null
        ? (dataCopy['timestamp'] as Timestamp).toDate().toIso8601String()
        : null;

    return {
      'id': id,
      'data': dataCopy,
    };
  }
}

class ProfileData {
  final String firstname;
  final String lastname;
  final String username;
  final String photo_path_mid;
  final List<DeviceTokensData>? device_tokens;

  ProfileData({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.photo_path_mid,
    this.device_tokens,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      firstname: json['firstname'],
      lastname: json['lastname'],
      username: json['username'],
      photo_path_mid: json['photo_path_mid'],
      device_tokens: (json['device_tokens'] as List<dynamic>?)
          ?.map((e) => DeviceTokensData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'photo_path_mid': photo_path_mid,
      'device_tokens': device_tokens?.map((e) => e.toJson()).toList(),
    };
  }
}

class DeviceTokensData {
  final String device_token;

  DeviceTokensData({required this.device_token});

  factory DeviceTokensData.fromJson(Map<String, dynamic> json) {
    return DeviceTokensData(
      device_token: json['device_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_token': device_token,
    };
  }
}
