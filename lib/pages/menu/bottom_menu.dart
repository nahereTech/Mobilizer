import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/pages/settings/settings_page.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../search/search.dart';
import '../feed/feed_outside.dart';
import '../notifications/notifications.dart';
import '../message/conversations_history.dart';

class BottomMenu extends StatefulWidget {
  final double bottomMenuProgress;
  final double bottomMenuHeight;

  const BottomMenu({
    Key? key,
    required this.bottomMenuProgress,
    required this.bottomMenuHeight,
  }) : super(key: key);

  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  late Future<String?> _photoPathFuture;

  @override
  void initState() {
    super.initState();
    // Cache the Future so it doesn't get recreated on every rebuild
    _photoPathFuture = _getPhotoPath();
  }

  Future<String?> _getPhotoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoPath = prefs.getString('profile_photo');
      print('Retrieved photo_path from SharedPreferences: $photoPath');
      return photoPath;
    } catch (e) {
      print('Error accessing SharedPreferences: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.bottomMenuHeight * widget.bottomMenuProgress,
      child: Opacity(
        opacity: widget.bottomMenuProgress,
        child: Transform.translate(
          offset: Offset(0, widget.bottomMenuHeight * (1 - widget.bottomMenuProgress)),
          child: BottomAppBar(
            height: widget.bottomMenuHeight,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF1E1E1E)
                : const Color.fromARGB(179, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedOutsidePage()),
                    );
                  },
                ),

                IconButton(
                  icon: Icon(
                    Icons.search_outlined,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Search()),
                    );
                  },
                ),

                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Notifications()),
                    );
                  },
                ),

                IconButton(
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConversationsHistory()),
                    );

                  },
                ),
                FutureBuilder<String?>(
                  future: _photoPathFuture, // Use the cached Future
                  builder: (context, snapshot) {
                    // While waiting for the future, show the fallback avatar immediately
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildFallbackAvatar(context);
                    }

                    if (snapshot.hasError) {
                      print('Error retrieving photo_path: ${snapshot.error}');
                      return _buildFallbackAvatar(context);
                    }

                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                      print('No photo_path found in SharedPreferences or it is empty');
                      return _buildFallbackAvatar(context);
                    }

                    final photoPath = snapshot.data!;
                    print('Photo path retrieved: $photoPath');

                    // Try to load the image as a NetworkImage
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Settings()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(photoPath),
                        onBackgroundImageError: (error, stackTrace) {
                          print('Error loading image from $photoPath: $error');
                          return null; // Fallback handled below
                        },
                        child: null, // No child since we're trying to load an image
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Settings()),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: const AssetImage('assets/profile_picture.png'),
        onBackgroundImageError: (error, stackTrace) {
          print('Error loading fallback asset image: $error');
        },
        child: Icon(
          Icons.person,
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}