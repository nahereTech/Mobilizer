import 'dart:convert';
import 'dart:async'; // Add this import for Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilizer/pages/post/post_details.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/townhall_contestants/contestants.dart';
import 'package:mobilizer/services/profile_service.dart';
import 'package:mobilizer/pages/settings/settings_page.dart';
import 'package:mobilizer/pages/townhall_info/townhall_info_page.dart';
import 'package:mobilizer/pages/menu/bottom_menu.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/pages/post/createpost.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../people/people_profile.dart';
import '../feed/update_townhalls.dart';

// Townhall model to parse API response
class Townhall {
  final int townhallId;
  final String townhallName;
  final String townhallImage;
  final int memberCount;
  final int orgId;
  final double circleReductionPercentage;
  final bool canShowTownhallInfo;
  final bool highlighted;
  final int unreadMessages;
  final int unreadTownhallInfo; // New field

  Townhall({
    required this.townhallId,
    required this.townhallName,
    required this.townhallImage,
    required this.memberCount,
    required this.orgId,
    required this.circleReductionPercentage,
    required this.canShowTownhallInfo,
    required this.highlighted,
    required this.unreadMessages,
    required this.unreadTownhallInfo, // Add to constructor
  });

  factory Townhall.fromJson(Map<String, dynamic> json) {
    return Townhall(
      townhallId: int.tryParse(json['townhall_id'].toString()) ?? 0,
      townhallName: json['townhall_name'] ?? '',
      townhallImage: json['townhall_image'] ?? '',
      memberCount: int.tryParse(json['member_count'].toString()) ?? 0,
      orgId: int.tryParse(json['org_id'].toString()) ?? 0,
      circleReductionPercentage: (json['circle_reduction_percentage'] as num?)?.toDouble() ?? 0.0,
      canShowTownhallInfo: json['can_show_townhall_info'] ?? false,
      highlighted: json['highlighted'] ?? false,
      unreadMessages: int.tryParse(json['unread_messages'].toString()) ?? 0,
      unreadTownhallInfo: int.tryParse(json['unread_townhall_info'].toString()) ?? 0, // Parse new field
    );
  }
}

class Post {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String fullName;
  final String message;
  final String timePosted;
  int commentCount;
  int likeCount;
  final String profilePic;
  final List<PostImage> postImages;
  bool userLiked;

  Post({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.fullName,
    required this.message,
    required this.timePosted,
    required this.commentCount,
    required this.likeCount,
    required this.profilePic,
    required this.postImages,
    required this.userLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      message: json['message'] ?? '',
      timePosted: json['time_posted'] ?? '',
      commentCount: json['comment_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      profilePic: json['profile_pic'] ?? '',
      postImages: (json['post_images'] as List? ?? [])
          .map((item) => PostImage.fromJson(item))
          .toList(),
      userLiked: json['user_liked'] ?? false,
    );
  }

  factory Post.fromComment(Map<String, dynamic> comment) {
    print('Creating Post from comment: $comment'); // Debug comment data
    try {
      return Post(
        id: int.parse(comment['id'].toString()), // Handle string or int
        firstname: '', // Not available in comments
        lastname: '',  // Not available in comments
        username: comment['commented_by_username']?.toString() ?? '',
        fullName: comment['commented_by_fullname']?.toString() ?? '',
        message: comment['message']?.toString() ?? '',
        timePosted: comment['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        commentCount: comment['comment_count'] is int
            ? comment['comment_count']
            : int.tryParse(comment['comment_count']?.toString() ?? '0') ?? 0,
        likeCount: comment['like_count'] is int
            ? comment['like_count']
            : int.tryParse(comment['like_count']?.toString() ?? '0') ?? 0,
        profilePic: comment['commented_by_profile_pics']?.toString() ?? '',
        postImages: const [], // Comments don't have images
        userLiked: comment['user_liked'] ?? false,
      );
    } catch (e) {
      print('Error in Post.fromComment: $e');
      rethrow; // Rethrow for debugging; can be handled differently in production
    }
  }
}

class PostImage {
  final int id;
  final String url;
  final String mediaType;

  PostImage({
    required this.id,
    required this.url,
    required this.mediaType,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id'],
      url: json['url'],
      mediaType: json['media_type'],
    );
  }
}

// Service to fetch townhall list
class TownhallService {
  Future<Map<String, dynamic>> fetchTownhallList() async {
    final prefs = await SharedPreferences.getInstance();
    String? orgIdString = prefs.getString('orgID');
    String? token = prefs.getString('token');
    int orgId = int.tryParse(orgIdString ?? '1') ?? 1;

    final headers = {
      'Authorization': '$token',
    };

    final uri = Uri.parse('${base_url}townhall/org_townhall_list')
        .replace(queryParameters: {'org_id': orgId.toString()});

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true) {
        final List<dynamic> data = jsonData['data'];
        return {
          'townhalls': data.map((json) => Townhall.fromJson(json)).toList(),
          'tag': null, // No special action needed
        };
      } else {
        if (jsonData['tag'] == "no_permission") {
          await prefs.setString('orgID', '1');
          await prefs.setString('orgName', 'World');
          return {
            'townhalls': <Townhall>[], // Empty list
            'tag': 'no_permission',
          };
        } else if (jsonData['tag'] == "update_townhalls") {
          return {
            'townhalls': <Townhall>[], // Empty list
            'tag': 'update_townhalls',
            'orgId': orgId, // Pass orgId for redirection
          };
        }
        throw Exception('Failed to fetch townhall list: ${jsonData['msg']}');
      }
    } else {
      throw Exception('Failed to fetch townhall list: ${response.statusCode}');
    }
  }
}

// Service to fetch posts
class PostService {
  Future<List<Post>> fetchPosts({
    required int orgId,
    required int townhallId,
    required int page,
    required int limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse('${base_url}/townhall/fetch_townhall_posts').replace(
      queryParameters: {
        'org_id': orgId.toString(),
        'townhall_id': townhallId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 200 && jsonData['data'] != null) {
        final List<dynamic> data = jsonData['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        return [];
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }
  }
}

class FeedOutsidePage extends StatefulWidget {
  static String routeName = 'feed_outside_page';

  const FeedOutsidePage({Key? key}) : super(key: key);

  @override
  _FeedOutsidePageState createState() => _FeedOutsidePageState();
}

class _FeedOutsidePageState extends State<FeedOutsidePage> {
  bool _isLoading = true;
  bool _isTownhallLoading = true;
  bool _isPostsLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  bool _isFabMenuOpen = false;
  late ScrollController _scrollController;
  double _topSectionProgress = 1.0;
  double _bottomMenuProgress = 1.0;
  double _lastOffset = 0.0;
  List<Townhall> _townhalls = [];
  List<Post> _posts = [];
  int _currentPage = 1;
  final int _limit = 10;
  int? _selectedTownhallId;
  String _orgName = 'World';
  int _orgId = 1;

  static const double _topSectionHeight = 135.0;
  static const double _bottomMenuHeight = 56.0;
  static const double _scrollThreshold = 300.0;

  bool isLoggedIn = false;
  bool isLoading = true;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    print('FeedOutsidePage: initState called');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_loadMoreListener);

    // Check user onboarding status
    _checkUserOnboarding();

    _loadOrgData();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _checkUserOnboarding() async {
    final profileService = ProfileService();
    final isOnboarded = await profileService.checkUserOnboarding(context);

    if (!mounted) return;

    if (isOnboarded) {
      // User is fully onboarded, proceed with fetching townhall list and posts
      print('FeedOutsidePage: User is onboarded, fetching townhall list');
      _fetchTownhallList();
    }
    // If the user is not onboarded, checkUserOnboarding has already handled redirection
    // (to LoginScreen, RegisterOtpScreen, or Profile), so we don't need to do anything here
  }

  Future<void> _loadOrgData() async {
    final prefs = await SharedPreferences.getInstance();
    String? orgName = prefs.getString('orgName');
    String? orgIdString = prefs.getString('orgID');

    if (orgName == null) {
      await prefs.setString('orgName', 'World');
      orgName = 'World';
    }
    int orgId = int.tryParse(orgIdString ?? '1') ?? 1;

    if (mounted) {
      setState(() {
        _orgName = orgName ?? 'World';
        _orgId = orgId;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final profileService = ProfileService();
    final loggedIn = await profileService.checkUserLoggedIn();

    if (!mounted) return;

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
    });

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> _fetchTownhallList() async {
    try {
      final townhallService = TownhallService();
      final result = await townhallService.fetchTownhallList();

      if (!mounted) return;

      final List<Townhall> townhalls = result['townhalls'];
      final String? tag = result['tag'];

      // Handle special tags
      if (tag == "no_permission") {
        final prefs = await SharedPreferences.getInstance();
        final currentOrgId = prefs.getString('orgID');
        final currentOrgName = prefs.getString('orgName');

        // Show the no permission dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              title: Text(
                'Access Denied',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              content: Text(
                'You have no permission to be in this organization.',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue background
                    foregroundColor: Colors.white, // White text/icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // Proceed with resetting to default organization
        if (currentOrgId == '1' && currentOrgName == 'World') {
          setState(() {
            _orgId = 1;
            _orgName = 'World';
            _isTownhallLoading = true;
            _posts.clear();
            _currentPage = 1;
            _hasMorePosts = true;
          });
          await _fetchTownhallList(); // Recursive call to reload
          return;
        }
      } else if (tag == "update_townhalls") {
        // Redirect to UpdateMyTownhall page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateMyTownhall(
              orgID: result['orgId'].toString(),
              hasUpdated: (bool updated) {
                if (updated) {
                  _fetchTownhallList(); // Refresh townhall list after update
                }
              },
            ),
          ),
        );
        return; // Exit after redirection
      }

      // Normal case: update townhall list
      setState(() {
        _townhalls = townhalls;
        _isTownhallLoading = false;
        _selectedTownhallId = townhalls.firstWhere(
          (townhall) => townhall.highlighted,
          orElse: () => townhalls.first,
        ).townhallId;
      });

      // Clear unreadMessages for the default selected townhall
      _updateTownhallUnread(_selectedTownhallId!, clearMessages: true);

      _fetchPosts(page: 1);
    } catch (e) {
      print('FeedOutsidePage: Error fetching townhall list: $e');
      if (!mounted) return;
      setState(() {
        _isTownhallLoading = false;
      });
    }
  }


  // Helper method to update a townhall's unread counts
  void _updateTownhallUnread(int townhallId, {bool clearMessages = false, bool clearInfo = false}) {
    setState(() {
      _townhalls = _townhalls.map((townhall) {
        if (townhall.townhallId == townhallId) {
          return Townhall(
            townhallId: townhall.townhallId,
            townhallName: townhall.townhallName,
            townhallImage: townhall.townhallImage,
            memberCount: townhall.memberCount,
            orgId: townhall.orgId,
            circleReductionPercentage: townhall.circleReductionPercentage,
            canShowTownhallInfo: townhall.canShowTownhallInfo,
            highlighted: townhall.highlighted,
            unreadMessages: clearMessages ? 0 : townhall.unreadMessages,
            unreadTownhallInfo: clearInfo ? 0 : townhall.unreadTownhallInfo,
          );
        }
        return townhall;
      }).toList();
    });
  }

  Future<void> _fetchPosts({required int page}) async {
    if (_selectedTownhallId == null) return;
    if (page != 1 && !_hasMorePosts) return;

    try {
      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _isPostsLoading = true;
          _posts.clear();
          _hasMorePosts = true;
        } else {
          _isLoadingMore = true;
        }
      });

      final postService = PostService();
      final newPosts = await postService.fetchPosts(
        orgId: _orgId,
        townhallId: _selectedTownhallId!,
        page: page,
        limit: _limit,
      );

      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _posts = newPosts;
          _isPostsLoading = false;
        } else {
          _posts.addAll(newPosts);
          _isLoadingMore = false;
        }

        if (newPosts.isNotEmpty) {
          _currentPage = page;
        } else {
          _hasMorePosts = false;
        }

        if (page == 1 && _scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      print('FeedOutsidePage: Error fetching posts: $e');
      if (!mounted) return;
      setState(() {
        _isPostsLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMoreListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMorePosts) {
      _fetchPosts(page: _currentPage + 1);
    }
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastOffset;

    if (!mounted) return;
    setState(() {
      if (delta > 0) {
        _topSectionProgress -= delta / _scrollThreshold;
        _bottomMenuProgress -= delta / _scrollThreshold;
      } else if (delta < 0) {
        _topSectionProgress += (-delta) / _scrollThreshold;
        _bottomMenuProgress += (-delta) / _scrollThreshold;
      }

      _topSectionProgress = _topSectionProgress.clamp(0.0, 1.0);
      _bottomMenuProgress = _bottomMenuProgress.clamp(0.0, 1.0);

      _lastOffset = currentOffset;
    });
  }

  void _onTownhallTap(int townhallId, String townhallName) {
    final selectedTownhall = _townhalls.firstWhere((townhall) => townhall.townhallId == townhallId);

    // Clear unreadMessages for the tapped townhall
    _updateTownhallUnread(townhallId, clearMessages: true);

    if (_selectedTownhallId == townhallId && selectedTownhall.canShowTownhallInfo) {
      // Clear unreadTownhallInfo when navigating to Townhall Info page
      _updateTownhallUnread(townhallId, clearInfo: true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TownhallInfoPage(
            townhallId: townhallId,
            townhallName: townhallName,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      setState(() {
        _selectedTownhallId = townhallId;
        _currentPage = 1;
        _hasMorePosts = true;
      });
      _fetchPosts(page: 1);
    }
  }


  // Add this method to handle liking a post
  Future<Map<String, dynamic>> _likePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        print('No token found');
        return {'success': false, 'msg': 'No token found'};
      }

      final encodedFormData = 'post_id=$postId';

      final response = await http
          .post(
            Uri.parse('${base_url}townhall/like_it'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token,
            },
            body: encodedFormData,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          print('Post liked successfully: ${jsonData['msg']}');
          return {
            'success': true,
            'msg': jsonData['msg'],
            'latest_like_count': jsonData['latest_like_count']
          };
        } else {
          print('Failed to like post: ${jsonData['msg']}');
          return {'success': false, 'msg': jsonData['msg']};
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return {'success': false, 'msg': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error liking post: $e');
      return {'success': false, 'msg': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> _unlikePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        print('No token found');
        return {'success': false, 'msg': 'No token found'};
      }

      final encodedFormData = 'post_id=$postId';

      final response = await http
          .post(
            Uri.parse('${base_url}townhall/unlike_it'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': token,
            },
            body: encodedFormData,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          print('Post unliked successfully: ${jsonData['msg']}');
          return {
            'success': true,
            'msg': jsonData['msg'],
            'latest_like_count': jsonData['latest_like_count']
          };
        } else {
          print('Failed to unlike post: ${jsonData['msg']}');
          return {'success': false, 'msg': jsonData['msg']};
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return {'success': false, 'msg': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error unliking post: $e');
      return {'success': false, 'msg': 'An error occurred: $e'};
    }
  }

  @override
  void dispose() {
    print('FeedOutsidePage: dispose called');
    _scrollController.removeListener(_scrollListener);
    _scrollController.removeListener(_loadMoreListener);
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Check if we're returning from PostDetails and need to refresh
    if (Navigator.canPop(context)) {
      _fetchPosts(page: 1); // Reload posts when navigating back
    }
    return true; // Allow the pop to proceed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => OrganizationScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
              ? const Color(0xFF121212)
              : Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight * _bottomMenuProgress + 3),
            child: Opacity(
              opacity: _bottomMenuProgress,
              child: Transform.translate(
                offset: Offset(0, -kToolbarHeight * (1 - _bottomMenuProgress)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: AppBar(
                    centerTitle: true,
                    backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    elevation: 1,
                    leadingWidth: 45,
                    leading: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: Image.asset(
                          'images/icon_blue.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    OrganizationScreen(),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(-1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _orgName.length > 10
                                      ? '${_orgName.substring(0, 10)}...'
                                      : _orgName,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () {
                if (_isFabMenuOpen) {
                  if (!mounted) return;
                  setState(() {
                    _isFabMenuOpen = false;
                  });
                }
              },
              child: _isLoading ? _buildShimmerLoader() : _buildFeedList(),
            ),
          ),
          floatingActionButton: Stack(
            children: [
              if (_isFabMenuOpen)
                Positioned(
                  right: 16,
                  bottom: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          setState(() {
                            _isFabMenuOpen = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TownhallContestantsPage(
                                orgId: _orgId, // Pass orgId
                                townhallId: _selectedTownhallId!, // Pass selected townhallId
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 108, 108, 108),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Contest for Townhall Leadership',
                            style: TextStyle(
                              color: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.white
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color.fromARGB(255, 226, 158, 32),
                        onPressed: () {
                          if (!mounted) return;
                          setState(() {
                            _isFabMenuOpen = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TownhallContestantsPage(
                                orgId: _orgId, // Pass orgId
                                townhallId: _selectedTownhallId!, // Pass selected townhallId
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.leaderboard,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isFabMenuOpen)
                Positioned(
                  right: 16,
                  bottom: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 108, 108, 108),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Make Post',
                          style: TextStyle(
                            color: Provider.of<ThemeProvider>(context).isDarkMode
                                ? Colors.white
                                : Colors.white,
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color.fromARGB(255, 9, 189, 63),
                        onPressed: () {
                          if (_selectedTownhallId != null) {
                            final selectedTownhall = _townhalls.firstWhere(
                              (townhall) => townhall.townhallId == _selectedTownhallId!,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatePost(
                                  orgId: _orgId,
                                  townhallId: _selectedTownhallId!,
                                  mapData: {},
                                  townhallName: selectedTownhall.townhallName,
                                ),
                              ),
                            ).then((value) {
                              if (value == 'refresh') {
                                _fetchPosts(page: 1);
                              }
                            });
                          }
                          if (!mounted) return;
                          setState(() {
                            _isFabMenuOpen = false;
                          });
                        },
                        child: const Icon(
                          Icons.post_add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _isFabMenuOpen = !_isFabMenuOpen;
                    });
                  },
                  backgroundColor: const Color.fromARGB(255, 18, 118, 200),
                  child: Icon(
                    _isFabMenuOpen ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomMenu(
            bottomMenuProgress: _bottomMenuProgress,
            bottomMenuHeight: _bottomMenuHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Provider.of<ThemeProvider>(context).isDarkMode
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: Provider.of<ThemeProvider>(context).isDarkMode
          ? Colors.grey[600]!
          : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
            ),
            title: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            subtitle: Container(
              height: 12,
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: _isPostsLoading
              ? _buildShimmerLoader()
              : _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add,
                            size: 48,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Post',
                            style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: const PageStorageKey<String>('feedList'),
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: _topSectionHeight * _topSectionProgress,
                        bottom: _bottomMenuHeight + 40.0,
                      ),
                      itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length && _isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final post = _posts[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetails(),
                                settings: RouteSettings(
                                  arguments: {
                                    'post': post,
                                    'comment_id': '',
                                  },
                                ),
                              ),
                            ).then((value) {
                              if (value == 'refresh') {
                                _fetchPosts(page: _currentPage);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.grey[200],
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
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to PeopleProfile when avatar is clicked
                                          final mapData = {
                                            'subjectID': post.id.toString(), // Assuming post.id is the user ID
                                            'picture': post.profilePic,
                                            'full_name': post.fullName,
                                            'username': post.username,
                                          };
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PeopleProfile(mapData: mapData),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundImage: NetworkImage(post.profilePic),
                                          onBackgroundImageError: (error, stackTrace) {},
                                          child: post.profilePic.isEmpty
                                              ? Icon(
                                                  Icons.person,
                                                  color: themeProvider.isDarkMode
                                                      ? Colors.white
                                                      : Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, top: 16.0, right: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Navigate to PeopleProfile when full name is clicked
                                                      final mapData = {
                                                        'subjectID': post.id.toString(), // Assuming post.id is the user ID
                                                        'picture': post.profilePic,
                                                        'full_name': post.fullName,
                                                        'username': post.username,
                                                      };
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => PeopleProfile(mapData: mapData),
                                                        ),
                                                      );
                                                    },
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
                                            GestureDetector(
                                              onTap: () {
                                                // Navigate to PeopleProfile when username is clicked
                                                final mapData = {
                                                  'subjectID': post.id.toString(), // Assuming post.id is the user ID
                                                  'picture': post.profilePic,
                                                  'full_name': post.fullName,
                                                  'username': post.username,
                                                };
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PeopleProfile(mapData: mapData),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                post.username,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                ),
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
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
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
                                      StatefulBuilder(
                                        builder: (context, setState) {
                                          return Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  post.userLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border_outlined,
                                                  color: post.userLiked ? Colors.red : Colors.grey,
                                                  size: 18.0,
                                                ),
                                                onPressed: () async {
                                                  if (post.userLiked) {
                                                    setState(() {
                                                      post.userLiked = false;
                                                      post.likeCount--;
                                                    });

                                                    final result = await _unlikePost(post.id);

                                                    if (!result['success'] && mounted) {
                                                      setState(() {
                                                        post.userLiked = true;
                                                        post.likeCount++;
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(result['msg']),
                                                          backgroundColor: Colors.red,
                                                          duration: const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    } else if (result['success'] && mounted) {
                                                      setState(() {
                                                        post.likeCount = result['latest_like_count'];
                                                      });
                                                    }
                                                  } else {
                                                    setState(() {
                                                      post.userLiked = true;
                                                      post.likeCount++;
                                                    });

                                                    final result = await _likePost(post.id);

                                                    if (!result['success'] && mounted) {
                                                      setState(() {
                                                        post.userLiked = false;
                                                        post.likeCount--;
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(result['msg']),
                                                          backgroundColor: Colors.red,
                                                          duration: const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
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
                                          );
                                        },
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share_outlined,
                                              color: Colors.grey,
                                              size: 18.0,
                                            ),
                                            onPressed: () {
                                              print('Share post ${post.id}');
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 4.0),
                                          const Text(
                                            '5',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          if (value == 'reply') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PostDetails(),
                                                settings: RouteSettings(
                                                  arguments: {
                                                    'post': post,
                                                    'comment_id': '',
                                                  },
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == 'refresh') {
                                                _fetchPosts(page: _currentPage);
                                              }
                                            });
                                          } else if (value == 'report') {
                                            print('Report post ${post.id}');
                                          }
                                        },
                                        color: themeProvider.isDarkMode
                                            ? const Color(0xFF252525)
                                            : Colors.white,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                            value: 'reply',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                              leading: Icon(
                                                Icons.reply_outlined,
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              title: Text(
                                                'Reply',
                                                style: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
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
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              title: Text(
                                                'Report',
                                                style: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.more_vert_outlined,
                                            color: Colors.grey,
                                            size: 18.0,
                                          ),
                                          onPressed: null, // Handled by PopupMenuButton
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: _topSectionHeight * _topSectionProgress,
            child: Opacity(
              opacity: _topSectionProgress,
              child: Transform.translate(
                offset: Offset(0, -_topSectionHeight * (1 - _topSectionProgress)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
                  child: _isTownhallLoading
                      ? Shimmer.fromColors(
                          baseColor: themeProvider.isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          highlightColor: themeProvider.isDarkMode
                              ? Colors.grey[600]!
                              : Colors.grey[100]!,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[300], // Already circular
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 60,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 40,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )

                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _townhalls.length,
                          itemBuilder: (context, index) {
                            final townhall = _townhalls[index];
                            final baseRadius = 30.0;
                            final reducedRadius = baseRadius * (1 - (townhall.circleReductionPercentage / 100));

                            return GestureDetector(
                              onTap: () => _onTownhallTap(townhall.townhallId, townhall.townhallName),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start, // Align content to start
                                  children: [
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 60, // Fixed height for avatar container
                                      width: 60,  // Fixed width to ensure consistent spacing
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: townhall.townhallId == _selectedTownhallId
                                                  ? Colors.blue
                                                  : Colors.grey[300]!,
                                              width: townhall.townhallId == _selectedTownhallId ? 3.0 : 2.0,
                                            ),
                                            boxShadow: townhall.townhallId == _selectedTownhallId
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.5),
                                                      spreadRadius: 3,
                                                      blurRadius: 7,
                                                      offset: const Offset(0, 0),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: CircleAvatar(
                                            radius: reducedRadius,
                                            backgroundImage: NetworkImage(townhall.townhallImage),
                                            onBackgroundImageError: (error, stackTrace) {},
                                            child: townhall.townhallImage.isEmpty
                                                ? Icon(
                                                    Icons.group,
                                                    color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        townhall.townhallName,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Red dot for unreadMessages
                                        if (townhall.unreadMessages > 0)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(right: 4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        // Amber dot for unreadTownhallInfo
                                        if (townhall.unreadTownhallInfo > 0)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (townhall.unreadMessages == 0 && townhall.unreadTownhallInfo == 0)
                                      const SizedBox(height: 10), // Maintain spacing when no dots
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double value = number / 1000;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}k';
    } else {
      double value = number / 1000000;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}m';
    }
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