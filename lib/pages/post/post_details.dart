import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'dart:async';

class PostDetails extends StatefulWidget {
  static String routeName = 'post_details_screen';

  const PostDetails({Key? key}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  var messageTextController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  late Post post;
  final _formKey = GlobalKey<FormState>();
  bool loadingComments = true;
  bool noComments = true;
  String commentId = "";
  bool isSendingComment = false;
  int currentPage = 1;
  bool hasMoreComments = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      post = args['post'] as Post;
      commentId = args['comment_id'] ?? '';
      _fetchComments();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && 
            hasMoreComments && 
            !loadingComments) {
          _fetchComments(page: currentPage + 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments({int page = 1}) async {
    if (page == 1) {
      setState(() {
        loadingComments = true;
        comments.clear();
      });
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final headers = {'Authorization': '$token'};

    final uri = Uri.parse('$base_url/townhall/comments_of_post').replace(
      queryParameters: {
        'post_id': post.id.toString(),
        'limit': '10',
        'page': page.toString(),
      },
    );

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('The request timed out');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          final List<dynamic> newComments = jsonData['data'];
          
          setState(() {
            if (page == 1) {
              comments = List<Map<String, dynamic>>.from(newComments);
            } else {
              comments.addAll(List<Map<String, dynamic>>.from(newComments));
            }
            loadingComments = false;
            noComments = comments.isEmpty;
            currentPage = page;
            hasMoreComments = newComments.length == 10;
          });
        } else if (jsonData['tag'] == 'no_comment') {
          setState(() {
            loadingComments = false;
            noComments = true;
            hasMoreComments = false;
          });
        } else {
          _showError('Failed to load comments: ${jsonData['msg']}');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      _showError('Request timed out. Please check your connection and try again.');
    } catch (e) {
      _showError('Error fetching comments: $e');
    }
  }

  Future<void> _addComment(String message) async {
    setState(() {
      isSendingComment = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'post_id': post.id.toString(),
      'message': message,
      'parent_id': post.id.toString(),
    });

    try {
      final response = await http.post(
        Uri.parse('${base_url}townhall/createComment'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          await _fetchComments();
          messageTextController.clear();
        } else {
          _showError('Failed to add comment: ${jsonData['msg']}');
        }
      } else {
        _showError('There was an error sending your comment. Please try again.');
      }
    } catch (e) {
      _showError('Error adding comment.');
    } finally {
      setState(() {
        isSendingComment = false;
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(
        Uri.parse('$base_url/townhall/deleteComment/$commentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            comments.removeWhere((comment) => comment['id'].toString() == commentId);
            noComments = comments.isEmpty;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _showError('Failed to delete comment: ${jsonData['msg']}');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error deleting comment: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      loadingComments = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFcf5555),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          title: Text(
            'Post',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(post.profilePic),
                                onBackgroundImageError: (error, stackTrace) {},
                                child: post.profilePic.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            post.fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(post.timePosted),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1.0),
                                    Text(
                                      post.username,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                          child: Text(
                            post.message,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (post.postImages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                            child: buildImageArea(post.postImages),
                          ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.comment_outlined,
                                    color: Colors.grey,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    post.commentCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite_border_outlined,
                                    color: Colors.grey,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    post.likeCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    color: Colors.grey,
                                    size: 18.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String value) {},
                                color: themeProvider.isDarkMode ? const Color(0xFF252525) : Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'reply',
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      leading: Icon(
                                        Icons.reply_outlined,
                                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                      title: Text(
                                        'Reply',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'report',
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      leading: Icon(
                                        Icons.report_outlined,
                                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                      title: Text(
                                        'Report',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.more_vert_outlined,
                                      color: Colors.grey,
                                      size: 18.0,
                                    ),
                                    SizedBox(width: 4.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                  if (loadingComments && currentPage == 1)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (noComments)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    )
                  else
                    ...comments.map((comment) {
                      DateTime startTime = DateTime.parse(comment['created_at']);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        comment['commented_by_profile_pics'] ?? '',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comment['commented_by_fullname'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            Text(
                                              timeago.format(startTime),
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4.0),
                                        GestureDetector(
                                          onTap: () {
                                            print('Comment tapped: ${comment['id']}'); // Debug tap
                                            try {
                                              final commentAsPost = Post.fromComment(comment);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PostDetails(),
                                                  settings: RouteSettings(
                                                    arguments: {
                                                      'post': commentAsPost,
                                                      'comment_id': comment['id'].toString(),
                                                    },
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              print('Navigation error: $e');
                                              _showError('Failed to view comment: $e');
                                            }
                                          },
                                          child: Text(
                                            comment['message'] ?? '',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.comment_outlined,
                                        color: Colors.grey,
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        comment['comment_count'].toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite_border_outlined,
                                        color: Colors.grey,
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        comment['like_count'].toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.share_outlined,
                                        color: Colors.grey,
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        comment['share_count'].toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      if (value == 'delete') {
                                        _deleteComment(comment['id'].toString());
                                      } else if (value == 'reply') {
                                        // Handle reply action (if implemented)
                                      } else if (value == 'report') {
                                        // Handle report action (if implemented)
                                      }
                                    },
                                    color: themeProvider.isDarkMode ? const Color(0xFF252525) : Colors.white,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuEntry<String>> items = [
                                        PopupMenuItem<String>(
                                          value: 'reply',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            leading: Icon(
                                              Icons.reply_outlined,
                                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                            ),
                                            title: Text(
                                              'Reply',
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'report',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            leading: Icon(
                                              Icons.report_outlined,
                                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                            ),
                                            title: Text(
                                              'Report',
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ];
                                      if (comment['can_delete'] == true) {
                                        items.add(
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                              leading: Icon(
                                                Icons.delete_outlined,
                                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                              ),
                                              title: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return items;
                                    },
                                    child: const Icon(
                                      Icons.more_vert_outlined,
                                      color: Colors.grey,
                                      size: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  if (loadingComments && currentPage > 1)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (!hasMoreComments && comments.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          '.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80.0),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: TextFormField(
                          controller: messageTextController,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          maxLength: 400,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            counterText: "",
                          ),
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a comment';
                            }
                            if (value.length > 400) {
                              return 'Comment cannot exceed 400 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: isSendingComment
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.send,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
                              ),
                              tooltip: 'Send',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _addComment(messageTextController.text);
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timePosted) {
    try {
      final postedTime = DateTime.parse(timePosted).toLocal();
      final now = DateTime.now();
      final difference = now.difference(postedTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}y';
      }
    } catch (e) {
      print('Error parsing timePosted: $e');
      return 'Unknown';
    }
  }

  Widget buildImageArea(List<PostImage> images) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final PageController _pageController = PageController(initialPage: 0);

    return GestureDetector(
      onTap: () {
        _showImageDialog(context, images);
      },
      child: Container(
        height: 180,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    images[index].url,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        height: 180,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: images.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.blueAccent,
                      dotColor: Colors.grey.shade800.withOpacity(0.7),
                      spacing: 6.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, List<PostImage> images) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[index].url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (images.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SmoothPageIndicator(
                      controller: PageController(initialPage: 0),
                      count: images.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.blue,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}