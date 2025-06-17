import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:video_player/video_player.dart';

class CreatePost extends StatefulWidget {
  final int orgId;
  final int townhallId;
  final Map<String, dynamic> mapData;
  final String townhallName;

  CreatePost({
    Key? key,
    required this.orgId,
    required this.townhallId,
    required this.mapData,
    required this.townhallName,
  }) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _postController = TextEditingController();
  final _controllerOption1 = TextEditingController();
  final _controllerOption2 = TextEditingController();
  final _controllerOption3 = TextEditingController();
  final _controllerOption4 = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _postAsNoticeboard = false;
  bool _postAsPoll = false;
  bool _loading = false;
  bool _mediaHasError = false;

  String profileImage = "";
  String? orgName;
  String _groupName = "";
  String _pollQuestion = '';
  String _opt1 = '';
  String _opt2 = '';
  String _opt3 = '';
  int _optCounts = 2;
  int _selectedDay = 0;
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String? _isLeader = "yes";

  List<MediaItem> images = [];
  List<int> _mediaErrors = [];
  List<MediaItem> editedMediaList = [];
  List<File> _selectedFiles = [];
  DateTime _currentTime = DateTime.now();
  List<int> days = List.generate(7, (index) => index + 1);
  List<int> hours = List.generate(23, (index) => index + 1);
  List<int> minutes = List.generate(59, (index) => index + 1);
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _setProfilePic();
    _setOrgName();
    _setGroupName();
    _setLeader();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _postController.dispose();
    _controllerOption1.dispose();
    _controllerOption2.dispose();
    _controllerOption3.dispose();
    _controllerOption4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = widget.mapData['canPost'] ?? false;
    final bool canPostPoll = widget.mapData['canPostPoll'] ?? false;

    print("Post: $canPost $canPostPoll");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Opacity(
        opacity: _loading ? 0.5 : 1,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
            ),
            actions: [
              Row(
                children: [
                  SizedBox(
                    height: 30.0,
                    child: TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]!
                                  : Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
                        ),
                      ),
                      child: Text(
                        _substring(orgName ?? '', 15),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward,
                    size: 18.0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.blue,
                  ),
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]!
                              : Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        _substring(widget.townhallName, 15),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.blue,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: _loading,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? Color(0xFF303030)
                              : Colors.white,
                        ),
                      ),
                      child: TextField(
                        maxLength: 400,
                        focusNode: _focusNode,
                        controller: _postController,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "What's happening?",
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                          counterStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[600]!
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    SizedBox(height: _postAsPoll ? 0 : 20.0),
                    _postAsPoll
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (images.length >= 4) {
                                    final snackBar = SnackBar(
                                      content: Text('You have reached the maximum allowed files'),
                                      backgroundColor: Colors.red,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  } else {
                                    gallery();
                                  }
                                },
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _postAsPoll = true;
                                  });
                                },
                                child: Icon(
                                  Icons.poll_outlined,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                    _postAsPoll ? SizedBox() : SizedBox(height: images.length > 0 ? 20.0 : 0),
                    if (images.length > 0)
                      _postAsPoll
                          ? SizedBox()
                          : Container(
                              height: 130,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: _mediaHasError && _mediaErrors.contains(index)
                                                      ? Colors.red
                                                      : Colors.white,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: _buildMediaPreview(images[index])),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                color: Colors.red,
                                                icon: Icon(Icons.cancel),
                                                onPressed: () {
                                                  setState(() {
                                                    int posIndex = _mediaErrors.indexOf(index);
                                                    if (posIndex != -1) {
                                                      _mediaHasError = false;
                                                      _mediaErrors.removeAt(posIndex);
                                                    }
                                                    images.removeAt(index);
                                                    editedMediaList.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                            if (images[index].type == MediaType.image)
                                              Positioned(
                                                bottom: 15,
                                                right: 10,
                                                child: Container(
                                                  width: 21,
                                                  height: 21,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(50.0),
                                                  ),
                                                  child: IconButton(
                                                    padding: EdgeInsets.only(top: 1, left: 2),
                                                    iconSize: 17,
                                                    icon: Icon(Icons.edit, color: Colors.white),
                                                    onPressed: () async {
                                                      imageEditor(context, images[index].file, index);
                                                    },
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    _postAsPoll ? SizedBox() : SizedBox(height: 20.0),
                    SizedBox(height: _postAsPoll ? 25 : 0),
                    _postAsPoll
                        ? Column(
                            children: [
                              TextFormField(
                                controller: _controllerOption1,
                                maxLength: 30,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Option 1',
                                  hintText: 'Option 1',
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  counterText: '',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  contentPadding: EdgeInsets.all(16.0),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _controllerOption2,
                                maxLength: 30,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Option 2',
                                  hintText: 'Option 2',
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  counterText: '',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  contentPadding: EdgeInsets.all(16.0),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                              SizedBox(height: 16),
                              _optCounts >= 3
                                  ? TextFormField(
                                      controller: _controllerOption3,
                                      maxLength: 30,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Option 3',
                                        hintText: 'Option 3',
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        counterText: '',
                                        hintStyle: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        contentPadding: EdgeInsets.all(16.0),
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.close_rounded,
                                              color: Theme.of(context).colorScheme.onSurface),
                                          onPressed: () {
                                            setState(() {
                                              _optCounts = 2;
                                              _controllerOption3.clear();
                                            });
                                          },
                                        ),
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                    )
                                  : SizedBox(),
                              SizedBox(height: _optCounts >= 3 ? 16 : 0),
                              _optCounts >= 4
                                  ? TextFormField(
                                      controller: _controllerOption4,
                                      maxLength: 30,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Option 4',
                                        hintText: 'Option 4',
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        counterText: '',
                                        hintStyle: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        contentPadding: EdgeInsets.all(16.0),
                                        suffixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.close_rounded,
                                                  color: Theme.of(context).colorScheme.onSurface),
                                              onPressed: () {
                                                setState(() {
                                                  _optCounts = 3;
                                                  _controllerOption4.clear();
                                                });
                                              },
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _optCounts = 3;
                                                  _controllerOption4.clear();
                                                });
                                              },
                                              child: Text(
                                                'Remove',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                    )
                                  : SizedBox(),
                              SizedBox(height: _optCounts >= 4 ? 16 : 0),
                              _optCounts < 4
                                  ? TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _optCounts++;
                                        });
                                      },
                                      icon: Icon(Icons.add_circle_outline,
                                          color: Theme.of(context).colorScheme.primary),
                                      label: Text(
                                        'Add Option',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: _optCounts == 3 ? 25 : 0),
                    _postAsPoll
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: 'Days',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  value: null,
                                  items: days.map((int day) {
                                    return DropdownMenuItem<int>(
                                      value: day,
                                      child: Text(day.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    _selectedDay = value!;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: 'Hours',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  value: null,
                                  items: hours.map((int hour) {
                                    return DropdownMenuItem<int>(
                                      value: hour,
                                      child: Text(hour.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    _selectedHour = value!;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: 'Minutes',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  value: null,
                                  items: minutes.map((int minute) {
                                    return DropdownMenuItem<int>(
                                      value: minute,
                                      child: Text(minute.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    _selectedMinute = value!;
                                  },
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: _isLeader == "yes" ? 20 : 0),
                    _isLeader == "yes" && widget.orgId.toString() != "2"
                        ? Row(
                            children: [
                              Switch(
                                activeColor: Colors.blue,
                                value: _postAsNoticeboard,
                                onChanged: (value) {
                                  setState(() {
                                    _postAsNoticeboard = value;
                                  });
                                  print(_postAsNoticeboard);
                                },
                              ),
                              SizedBox(width: 8.0),
                              const Text(
                                'Post as a leader',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: _postAsPoll ? 10 : 0),
                    _postAsPoll
                        ? SizedBox(
                            height: 20,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _postAsPoll = false;
                                });
                              },
                              child: Text(
                                "Cancel Poll",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          )
                        : SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      print("Townhall: ${widget.townhallId}");
                                      List<File> fileList = [];

                                      if (_postController.text.trim().isEmpty) {
                                        final snackBar = SnackBar(
                                          content: Text("Message can't be empty"),
                                          backgroundColor: Colors.red,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        return;
                                      }

                                      final snackBar = SnackBar(
                                        content: Text(
                                          'Please wait while your post uploads',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.amber[800],
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                      if (editedMediaList.isNotEmpty) {
                                        for (var i = 0; i < editedMediaList.length; i++) {
                                          if (editedMediaList[i].fileSize > 15.0 &&
                                              editedMediaList[i].type == MediaType.video) {
                                            setState(() {
                                              _mediaHasError = true;
                                              _mediaErrors.add(i);
                                            });
                                          }
                                          fileList.add(editedMediaList[i].file);
                                        }
                                      }

                                      setState(() {
                                        _loading = true;
                                      });

                                      try {
                                        if (_postAsPoll) {
                                          DateTime pollEnd = DateTime.now().add(
                                            Duration(
                                              days: _selectedDay,
                                              hours: _selectedHour,
                                              minutes: _selectedMinute,
                                            ),
                                          );

                                          String option1 = _controllerOption1.text.trim();
                                          String option2 = _controllerOption2.text.trim();
                                          String option3 = _controllerOption3.text.trim();
                                          String option4 = _controllerOption4.text.trim();

                                          if (option1.isEmpty || option2.isEmpty) {
                                            final snackBar = SnackBar(
                                              content: Text('Options 1 and 2 cannot be blank'),
                                              backgroundColor: Colors.red,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            setState(() {
                                              _loading = false;
                                            });
                                            return;
                                          }

                                          List<String> options = [option1, option2];
                                          if (_optCounts >= 3 && option3.isNotEmpty) options.add(option3);
                                          if (_optCounts >= 4 && option4.isNotEmpty) options.add(option4);

                                          if (options.length != options.toSet().length) {
                                            final snackBar = SnackBar(
                                              content: Text('Poll options must be unique'),
                                              backgroundColor: Colors.red,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            setState(() {
                                              _loading = false;
                                            });
                                            return;
                                          }

                                          final pollOptions = options;
                                          final pollEndString = pollEnd.toIso8601String();

                                          final response = await _createPoll(
                                            userId: 'USER_ID_HERE',
                                            message: _postController.text.trim(),
                                            orgId: widget.orgId.toString(),
                                            townhallId: widget.townhallId.toString(),
                                            leadershipPost: _postAsNoticeboard ? 'yes' : 'no',
                                            pollOptions: pollOptions,
                                            pollEnd: pollEndString,
                                          );

                                          if (response['status'] == true) {
                                            final snackBar = SnackBar(
                                              content: Text('Poll posted successfully'),
                                              backgroundColor: Colors.green.shade300,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            Navigator.of(context).pop('refresh');
                                          } else {
                                            final snackBar = SnackBar(
                                              content: Text(response['msg'] ?? 'Failed to post poll'),
                                              backgroundColor: Colors.red,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        } else {
                                          if (_mediaHasError) {
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  'Maximum allowed file size is 15MB for videos.'),
                                              backgroundColor: Colors.red,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          } else {
                                            final response = await _createPost(
                                              userId: 'USER_ID_HERE',
                                              message: _postController.text.trim(),
                                              group: widget.townhallId.toString(),
                                              orgId: widget.orgId.toString(),
                                              leadershipPost: _postAsNoticeboard ? 'yes' : 'no',
                                              files: fileList,
                                            );

                                            if (response['status'] == 200) {
                                              final snackBar = SnackBar(
                                                content: Text('Post created successfully'),
                                                backgroundColor: Colors.green.shade300,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              Navigator.of(context).pop('refresh');
                                            } else {
                                              final snackBar = SnackBar(
                                                content: Text(response['msg'] ?? 'Failed to create post'),
                                                backgroundColor: Colors.red,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        final snackBar = SnackBar(
                                          content: Text('An error occurred: $e'),
                                          backgroundColor: Colors.red,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      } finally {
                                        setState(() {
                                          _loading = false;
                                        });
                                      }
                                    },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
                                ),
                              ),
                              child: _loading
                                  ? Center(
                                      child: SpinKitCircle(
                                        color: Colors.white,
                                        size: 30.0,
                                      ),
                                    )
                                  : Text(
                                      'Post',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _createPoll({
    required String userId,
    required String message,
    required String orgId,
    required String townhallId,
    required String leadershipPost,
    required List<String> pollOptions,
    required String pollEnd,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('${base_url}townhall/create_poll');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': '${token}',
    };

    final body = {
      'user_id': userId,
      'message': message,
      'org_id': orgId,
      'townhall_id': townhallId,
      'posted_as_a_leader': leadershipPost,
      'poll_options': jsonEncode(pollOptions),
      'poll_end': pollEnd,
    };

    final response = await http.post(url, headers: headers, body: body);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> _createPost({
    required String userId,
    required String message,
    required String group,
    required String orgId,
    required String leadershipPost,
    List<File>? files,
  }) async {
    final url = Uri.parse('${base_url}townhall/createPost');
    var request = http.MultipartRequest('POST', url);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Authorization token is missing. Please log in again.");
    }

    request.headers['Authorization'] = '$token';

    request.fields['user_id'] = userId;
    request.fields['message'] = message;
    request.fields['group'] = group;
    request.fields['org_id'] = orgId;
    request.fields['posted_as_a_leader'] = leadershipPost;

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath('files[]', file.path));
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return jsonDecode(responseBody);
  }

  Future<void> imageEditor(context, File image, int index) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Image Editor',
            toolbarColor: Colors.blue,
            activeControlsWidgetColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Image Editor',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort: const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      final File convertedFile = File(croppedFile.path);
      updateMediaList(convertedFile, index);
    }
  }

  updateMediaList(File reSized, int index) async {
    int positionIndex =
        editedMediaList.indexWhere((media) => media.indexID.toString() == index.toString());

    images[index].indexID = index;
    images[index].file = File(reSized.path);
    images[index].fileSize = await _getImageSize(File(reSized.path));
    images[index].type = MediaType.image;
    images[index].startPos = 0.0;
    images[index].endPos = 0.0;
    images[index].wasEdited = false;

    editedMediaList[index].fileSize = await _getImageSize(File(reSized.path));
    editedMediaList[index].file = File(reSized.path);
    editedMediaList[index].wasEdited = true;
    editedMediaList[index].startPos = 0.0;
    editedMediaList[index].endPos = 0.0;
    editedMediaList[index].type = MediaType.image;

    setState(() {});
  }

  _setOrgName() async {
    var organizationName = await getOrgName();
    setState(() {
      orgName = organizationName;
    });
    print("This is orgName: $orgName");
  }

  void _setProfilePic() async {
    var picture = await _getProfilePic();
    setState(() {
      profileImage = picture ?? '';
    });
  }

  _setGroupName() async {
    var _grpName = await getGroupName();
    setState(() {
      _groupName = _grpName ?? '';
    });
  }

  _setLeader() async {
    var v = await getIsLeader();
    print("Leader: $v");
    setState(() {
      _isLeader = v;
    });
  }

  Future<void> gallery() async {
    int i = 0;
    int z = 0;
    final List<XFile> medias = await _picker.pickMultipleMedia();

    if (medias.isNotEmpty) {
      if (medias.length <= 4) {
        images.addAll(await Future.wait(medias.map((file) async {
          return MediaItem(
            indexID: z++,
            file: File(file.path),
            fileSize: await _getType(File(file.path)).toString() == 'MediaType.video'
                ? await _getSize(File(file.path))
                : 0.0,
            type: _getType(File(file.path)),
            wasEdited: false,
            startPos: 0.0,
            endPos: 0.0,
          );
        })));
        editedMediaList.addAll(await Future.wait(medias.map((file) async {
          return MediaItem(
            indexID: i++,
            file: File(file.path),
            fileSize: await _getType(File(file.path)).toString() == 'MediaType.video'
                ? await _getSize(File(file.path))
                : 0.0,
            type: _getType(File(file.path)),
            wasEdited: false,
            startPos: 0.0,
            endPos: 0.0,
          );
        })));

        setState(() {});
      }
    }
    if (images.length > 4) {
      int orgCounts = images.length;
      for (int i = 4; i < orgCounts; i++) {
        setState(() {
          images.removeAt(i);
          editedMediaList.removeAt(i);
        });
      }
    }
  }

  MediaType _getType(File file) {
    if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
      return MediaType.video;
    } else {
      return MediaType.image;
    }
  }

  Future<double> _getSize(File file) async {
    int fileSizeInBytes = await file.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB;
  }

  Future<double> _getImageSize(File file) async {
    final bytes = file.readAsBytesSync().lengthInBytes;
    double fileSizeInBytes = bytes / 1024;
    double fileSizeInMB = fileSizeInBytes / 1024;
    return fileSizeInMB;
  }

  Future<String?> getIsLeader() async {
    return await AppSharedPreferences.getValue(key: 'isTownhallLeader');
  }

  Widget _buildMediaPreview(MediaItem media) {
    if (media.type == MediaType.video) {
      return VideoPreview(media: media);
    } else {
      return Image.file(
        media.file,
        fit: BoxFit.cover,
      );
    }
  }

  Future<String?> getGroupName() async {
    return await AppSharedPreferences.getValue(key: 'groupFullName');
  }

  Future<String?> _getProfilePic() async {
    return await AppSharedPreferences.getValue(key: 'profilePic');
  }

  String _substring(String char, int count) {
    return char.length > count ? char.substring(0, count) + '...' : char;
  }

  Future<String?> getOrgName() async {
    return await AppSharedPreferences.getValue(key: 'orgName');
  }
}

class MediaItem {
  int indexID;
  File file;
  MediaType type;
  double startPos;
  double endPos;
  bool wasEdited;
  double fileSize;

  MediaItem({
    required this.indexID,
    required this.file,
    required this.fileSize,
    required this.type,
    required this.startPos,
    required this.endPos,
    required this.wasEdited,
  });
}

enum MediaType { image, video }

class VideoPreview extends StatefulWidget {
  final MediaItem media;
  const VideoPreview({required this.media});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.media.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        IconButton(
          iconSize: 50,
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _togglePlayPause,
        ),
      ],
    );
  }
}