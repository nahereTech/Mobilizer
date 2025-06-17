import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart'; // Add this import
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/pages/menu/bottom_menu.dart';
import '../organization/organization_details.dart';
import '../feed/feed_outside.dart';
import '../people/people_profile.dart';

// Organization Model
class Organization {
  final int orgId;
  final String orgName;
  final String orgAbout;
  final String picture;
  final String verified;
  final String isMember;
  final String orgUsername;
  final String orgBg;
  final String orgMemberCount;
  final String joinStatus;
  final String requiresConfirmation;

  Organization({
    required this.orgId,
    required this.orgName,
    required this.orgAbout,
    required this.picture,
    required this.verified,
    required this.isMember,
    required this.orgUsername,
    required this.orgBg,
    required this.orgMemberCount,
    required this.joinStatus,
    required this.requiresConfirmation,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['org_id'] ?? 0,
      orgName: json['org_name'] ?? '',
      orgAbout: json['org_about'] ?? '',
      picture: json['picture'] ?? '',
      verified: json['verified'] ?? '',
      isMember: json['is_member'] ?? '',
      orgUsername: json['org_username'] ?? '',
      orgBg: json['org_bg'] ?? '',
      orgMemberCount: json['org_member_count'] ?? '',
      joinStatus: json['join_status'] ?? '',
      requiresConfirmation: json['requires_confirmation'] ?? '',
    );
  }
}

// People Model
class Person {
  final String userId;
  final String username;
  final String fullname;
  final String photoPath;
  final String photoPathLg;
  final String isFollowing;
  final String countryName;
  final String stateName;
  final String lgaName;
  final int mutualsCount;

  Person({
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoPath,
    required this.photoPathLg,
    required this.isFollowing,
    required this.countryName,
    required this.stateName,
    required this.lgaName,
    required this.mutualsCount,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      photoPath: json['photo_path'] ?? '',
      photoPathLg: json['photo_path_lg'] ?? '',
      isFollowing: json['is_following'] ?? '',
      countryName: json['country_name'] ?? '',
      stateName: json['state_name'] ?? '',
      lgaName: json['lga_name'] ?? '',
      mutualsCount: json['mutuals_count'] ?? 0,
    );
  }
}

// Professionals Model
class Professional {
  final String userId;
  final String username;
  final String fullname;
  final String photoPath;
  final String photoPathLg;
  final String isFollowing;
  final String countryName;
  final String stateName;
  final String lgaName;
  final int mutualsCount;
  final String professionCategory;
  final String profession;

  Professional({
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoPath,
    required this.photoPathLg,
    required this.isFollowing,
    required this.countryName,
    required this.stateName,
    required this.lgaName,
    required this.mutualsCount,
    required this.professionCategory,
    required this.profession,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      photoPath: json['photo_path'] ?? '',
      photoPathLg: json['photo_path_lg'] ?? '',
      isFollowing: json['is_following'] ?? '',
      countryName: json['country_name'] ?? '',
      stateName: json['state_name'] ?? '',
      lgaName: json['lga_name'] ?? '',
      mutualsCount: json['mutuals_count'] ?? 0,
      professionCategory: json['profession_category'] ?? '',
      profession: json['profession'] ?? '',
    );
  }
}

// Post Model
class SearchPost {
  final int postId;
  final String postedBy;
  final String postedMessage;
  final int likeCount;
  final int commentCount;
  final String username;
  final String photoPath;
  final String isLiked;

  SearchPost({
    required this.postId,
    required this.postedBy,
    required this.postedMessage,
    required this.likeCount,
    required this.commentCount,
    required this.username,
    required this.photoPath,
    required this.isLiked,
  });

  factory SearchPost.fromJson(Map<String, dynamic> json) {
    return SearchPost(
      postId: int.tryParse(json['post_id'].toString()) ?? 0,
      postedBy: json['posted_by'] ?? '',
      postedMessage: json['posted_message'] ?? '',
      likeCount: int.tryParse(json['like_count'].toString()) ?? 0,
      commentCount: int.tryParse(json['comment_count'].toString()) ?? 0,
      username: json['username'] ?? '',
      photoPath: json['photo_path'] ?? '',
      isLiked: json['is_liked'] ?? 'no',
    );
  }
}

// Market Model
class MarketItem {
  final int id;
  final String name;
  final String description;
  final String cost;
  final String currency;
  final String mainImage;
  final String itemLocation;

  MarketItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.currency,
    required this.mainImage,
    required this.itemLocation,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? '',
      currency: json['currency'] ?? '',
      mainImage: json['main_image'] ?? '',
      itemLocation: json['item_location'] ?? '',
    );
  }
}

// Search Service
class SearchService {
  Future<List<dynamic>> performSearch({
    required String section,
    String? keyword,
    String? locations,
    String? startDate, // For posts only
    String? endDate,   // For posts only
    int page = 1,
    int limit = 25,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found in SharedPreferences');
    }
    final headers = {'Authorization': '$token'};

    final uri = Uri.parse('${base_url}townhall/perform_search').replace(
      queryParameters: {
        'section': section.toLowerCase(),
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (locations != null && locations.isNotEmpty) 'locations': locations,
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true && jsonData['data'] != null) {
        final List<dynamic> data = jsonData['data'];
        switch (section.toLowerCase()) {
          case 'organizations':
            return data.map((json) => Organization.fromJson(json)).toList();
          case 'people':
            return data.map((json) => Person.fromJson(json)).toList();
          case 'professionals':
            return data.map((json) => Professional.fromJson(json)).toList();
          case 'posts':
            return data.map((json) => SearchPost.fromJson(json)).toList();
          case 'market':
            return data.map((json) => MarketItem.fromJson(json)).toList();
          default:
            return [];
        }
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to perform search: ${response.statusCode} - ${response.body}');
    }
  }
}

// Search Page
class Search extends StatefulWidget {
  static String routeName = 'search_page';

  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  double _bottomMenuProgress = 1.0;
  double _searchSectionProgress = 1.0;
  static const double _bottomMenuHeight = 56.0;
  static const double _searchSectionHeight = 60.0;
  static const double _scrollThreshold = 300.0;
  late ScrollController _scrollController;
  double _lastOffset = 0.0;

  late PageController _pageController;
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Organizations', 'People', 'Posts', 'Professionals', 'Market'];
  Map<int, bool> _isLoading = {0: true, 1: true, 2: true, 3: true, 4: true};
  Map<int, List<dynamic>> _results = {0: [], 1: [], 2: [], 3: [], 4: []};
  Map<int, int> _currentPage = {0: 1, 1: 1, 2: 1, 3: 1, 4: 1};
  Map<int, bool> _hasMore = {0: true, 1: true, 2: true, 3: true, 4: true};
  final int _limit = 25;

  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  Timer? _debounceTimer; // Timer for debouncing
  CancelableOperation? _currentSearchOperation; // To cancel previous search requests

  // Replace the single _lastSearchTerm with a Map for each tab
  final Map<int, String> _lastSearchTerms = {0: '', 1: '', 2: '', 3: '', 4: ''};

  // Add this new map to track loading state per organization
  Map<String, bool> _isJoining = {}; // Key will be orgId as String

  // Add this new map to track loading state per person
  Map<String, bool> _isFollowing = {}; // Key will be userId as String

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _pageController = PageController(initialPage: _selectedTabIndex);
    
    _fetchResults(_selectedTabIndex, isInitial: true);
    _searchController.addListener(() {
      final currentTerm = _searchController.text.trim();
      if (currentTerm != _lastSearchTerms[_selectedTabIndex]) {
        _onSearchChanged();
      }
    });
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastOffset;

    if (!mounted) return;
    setState(() {
      if (delta > 0) {
        _searchSectionProgress -= delta / _scrollThreshold;
        _bottomMenuProgress -= delta / _scrollThreshold;
      } else if (delta < 0) {
        _searchSectionProgress += (-delta) / _scrollThreshold;
        _bottomMenuProgress += (-delta) / _scrollThreshold;
      }

      _searchSectionProgress = _searchSectionProgress.clamp(0.0, 1.0);
      _bottomMenuProgress = _bottomMenuProgress.clamp(0.0, 1.0);

      _lastOffset = currentOffset;
    });
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    final currentTabIndex = _selectedTabIndex;
    final currentSearchTerm = _searchController.text.trim();

    if (currentSearchTerm.isNotEmpty && currentSearchTerm != _lastSearchTerms[currentTabIndex]) {
      setState(() {
        _currentPage[currentTabIndex] = 1;
        _hasMore[currentTabIndex] = true;
        _results[currentTabIndex] = [];
        _isLoading[currentTabIndex] = true;
      });
    }

    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _currentSearchOperation?.cancel();

      _currentSearchOperation = CancelableOperation.fromFuture(
        _fetchResults(currentTabIndex).then((_) {
          _currentSearchOperation = null;
          _lastSearchTerms[currentTabIndex] = currentSearchTerm;
        }),
      );
    });
  }

  Future<void> _fetchResults(int tabIndex, {bool isInitial = false}) async {
    if (!_hasMore[tabIndex]!) return;

    print('Fetching results for tab: ${_tabs[tabIndex]}, page: ${_currentPage[tabIndex]}');

    try {
      final section = _tabs[tabIndex].toLowerCase();
      final keyword = _searchController.text.trim();
      final results = await _searchService.performSearch(
        section: section,
        keyword: keyword.isEmpty && !isInitial ? null : keyword,
        page: _currentPage[tabIndex]!,
        limit: _limit,
      );

      print('Received ${results.length} results for ${_tabs[tabIndex]}');

      if (mounted) {
        setState(() {
          if (isInitial || _currentPage[tabIndex] == 1) {
            _results[tabIndex] = results;
          } else {
            _results[tabIndex] = [..._results[tabIndex]!, ...results];
          }
          _isLoading[tabIndex] = false;
          if (results.length < _limit) {
            _hasMore[tabIndex] = false;
          }
          _currentPage[tabIndex] = _currentPage[tabIndex]! + 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading[tabIndex] = false;
        });
      }
      print('Error fetching ${_tabs[tabIndex].toLowerCase()}: $e');
    }
  }


  // Add this new method to handle follow action
  Future<void> _handleFollowPerson(Person person) async {
    setState(() {
      _isFollowing[person.userId] = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('${base_url}townhall/createConnection'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'followee': person.userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            // Update the person's following status
            final updatedPerson = Person(
              userId: person.userId,
              username: person.username,
              fullname: person.fullname,
              photoPath: person.photoPath,
              photoPathLg: person.photoPathLg,
              isFollowing: 'yes', // Updated to match API response format
              countryName: person.countryName,
              stateName: person.stateName,
              lgaName: person.lgaName,
              mutualsCount: person.mutualsCount,
            );
            
            // Update the results list
            final personIndex = _results[1]!.indexWhere((item) => (item as Person).userId == person.userId);
            if (personIndex != -1) {
              _results[1]![personIndex] = updatedPerson;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                jsonData['msg'] ?? 'Failed to follow',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isFollowing[person.userId] = false;
      });
    }
  }


  // Add this new method to handle unfollow action
  Future<void> _handleUnfollowPerson(Person person) async {
    setState(() {
      _isFollowing[person.userId] = true; // Using the same loading map for consistency
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('${base_url}townhall/removeConnection'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'followee': person.userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Note: The API returns status: false even on success, but tag: "success"
        // We'll check the tag instead of status due to this API behavior
        if (jsonData['tag'] == 'success') {
          setState(() {
            // Update the person's following status
            final updatedPerson = Person(
              userId: person.userId,
              username: person.username,
              fullname: person.fullname,
              photoPath: person.photoPath,
              photoPathLg: person.photoPathLg,
              isFollowing: 'no', // Update to not following
              countryName: person.countryName,
              stateName: person.stateName,
              lgaName: person.lgaName,
              mutualsCount: person.mutualsCount,
            );
            
            // Update the results list
            final personIndex = _results[1]!.indexWhere((item) => (item as Person).userId == person.userId);
            if (personIndex != -1) {
              _results[1]![personIndex] = updatedPerson;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                jsonData['msg'] ?? 'Failed to unfollow',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isFollowing[person.userId] = false;
      });
    }
  }

  

  void _onTabTap(int index) {
    if (_selectedTabIndex == index) return; // Prevent re-fetching if already on the same tab

    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    final currentTerm = _searchController.text.trim();
    if (_results[index]!.isEmpty || currentTerm != _lastSearchTerms[index]) {
      setState(() {
        _isLoading[index] = true;
        _currentPage[index] = 1;
        _hasMore[index] = true;
        _results[index] = [];
      });
      _fetchResults(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
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
                backgroundColor: themeProvider.isDarkMode
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
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: _searchSectionHeight * _searchSectionProgress),
                SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tabs.asMap().entries.map((entry) {
                        int index = entry.key;
                        String tab = entry.value;
                        bool isSelected = _selectedTabIndex == index;
                        return GestureDetector(
                          onTap: () => _onTabTap(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.blue
                                    : themeProvider.isDarkMode
                                        ? Colors.white70
                                        : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                      // Fetch data for the new tab if it’s empty or the search term has changed
                      final currentTerm = _searchController.text.trim();
                      if (_results[index]!.isEmpty || currentTerm != _lastSearchTerms[index]) {
                        setState(() {
                          _isLoading[index] = true;
                          _currentPage[index] = 1;
                          _hasMore[index] = true;
                          _results[index] = [];
                        });
                        _fetchResults(index);
                      }
                    },
                    children: _tabs.map((tab) {
                      int index = _tabs.indexOf(tab);
                      return _buildTabContent(index);
                    }).toList(),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _searchSectionHeight * _searchSectionProgress,
                child: Opacity(
                  opacity: _searchSectionProgress,
                  child: Transform.translate(
                    offset: Offset(0, -_searchSectionHeight * (1 - _searchSectionProgress)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      color: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                                filled: true,
                                fillColor: themeProvider.isDarkMode
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(
        bottomMenuProgress: _bottomMenuProgress,
        bottomMenuHeight: _bottomMenuHeight,
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_isLoading[index]! && _results[index]!.isEmpty) {
      return _buildShimmerLoader();
    } else if (_results[index]!.isEmpty) {
      return Center(
        child: Text(
          'No results found for ${_tabs[index]}',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
          ),
        ),
      );
    } else {
      return ListView.builder(
        controller: _scrollController, // Attach the scroll controller here
        padding: EdgeInsets.only(
          top: 8.0, // Use a smaller fixed padding here instead
          // top: _searchSectionHeight * _searchSectionProgress, // Adjusted to remove extra 50
          bottom: _bottomMenuHeight * _bottomMenuProgress + 40.0,
        ),
        itemCount: _results[index]!.length + (_hasMore[index]! ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _results[index]!.length && _hasMore[index]!) {
            _fetchResults(index);
            return const Center(child: CircularProgressIndicator());
          }
          final item = _results[index]![i];
          switch (_tabs[index].toLowerCase()) {
            case 'organizations':
              final org = item as Organization;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Create mapData for OrganizationDetails
                    final Map<String, dynamic> mapData = {
                      'org_id': org.orgId.toString(),
                      'org_name': org.orgName,
                      'org_about': org.orgAbout,
                      'org_bg': org.orgBg,
                      'org_member_count': org.orgMemberCount,
                      'join_status': org.joinStatus,
                      'org_username': org.orgUsername,
                      'picture': org.picture,
                      'verified': org.verified,
                      'navigateTo': 'search', // To handle back navigation
                    };
                    // Navigate to OrganizationDetails without Bloc
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizationDetails(mapData: mapData),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(org.picture),
                            backgroundColor:
                                themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        org.orgName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (org.verified == '1')
                                      Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 18.0,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '@${org.orgUsername}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                if (org.orgAbout.isNotEmpty)
                                  Text(
                                    org.orgAbout,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '${org.orgMemberCount} members',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: themeProvider.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const Spacer(),
                                    _buildJoinButton(org, themeProvider),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            case 'people':
              final person = item as Person;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    final Map<String, dynamic> mapData = {
                      'subjectID': person.userId,
                      'picture': person.photoPath,
                      'full_name': person.fullname,
                      'username': person.username,
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PeopleProfile(mapData: mapData)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(person.photoPath),
                            backgroundColor:
                                themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.fullname,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color:
                                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '@${person.username}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                if (person.stateName.isNotEmpty || person.countryName.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14.0,
                                        color: themeProvider.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text(
                                          _formatLocation(person.stateName, person.countryName),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    if (person.mutualsCount > 0)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            size: 14.0,
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            '${person.mutualsCount} mutual${person.mutualsCount > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    const Spacer(),
                                    _buildFollowButton(person, themeProvider),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            case 'professionals':
              final pro = item as Professional;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(pro.photoPath),
                          backgroundColor:
                              themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pro.fullname,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '@${pro.username}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    size: 14.0,
                                    color: themeProvider.isDarkMode
                                        ? Colors.blue[300]
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Expanded(
                                    child: Text(
                                      _formatProfession(pro.professionCategory, pro.profession),
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        color: themeProvider.isDarkMode
                                            ? Colors.blue[300]
                                            : Colors.blue,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),
                              if (pro.stateName.isNotEmpty || pro.countryName.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4.0),
                                    Expanded(
                                      child: Text(
                                        _formatLocation(pro.stateName, pro.countryName),
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12.0),
                              Row(
                                children: [
                                  if (pro.mutualsCount > 0)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 14.0,
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '${pro.mutualsCount} mutual${pro.mutualsCount > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  const Spacer(),
                                  _buildProfessionalConnect(pro, themeProvider),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            case 'posts':
              final post = item as SearchPost;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(post.photoPath),
                              backgroundColor:
                                  themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '@${post.username.toLowerCase().replaceAll(' ', '')}',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          post.postedMessage,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPostInteractionButton(
                              icon: post.isLiked == 'yes' ? Icons.favorite : Icons.favorite_border,
                              color: post.isLiked == 'yes' ? Colors.red : null,
                              label: post.likeCount.toString(),
                              themeProvider: themeProvider,
                              onTap: () {},
                            ),
                            _buildPostInteractionButton(
                              icon: Icons.comment_outlined,
                              label: post.commentCount.toString(),
                              themeProvider: themeProvider,
                              onTap: () {},
                            ),
                            _buildPostInteractionButton(
                              icon: Icons.share_outlined,
                              label: "Share",
                              themeProvider: themeProvider,
                              onTap: () {},
                            ),
                            _buildPostInteractionButton(
                              icon: Icons.bookmark_border,
                              label: "Save",
                              themeProvider: themeProvider,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            case 'market':
              final market = item as MarketItem;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            market.mainImage,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                market.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color:
                                      themeProvider.isDarkMode ? Colors.white : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                '${market.cost} ${market.currency}',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: themeProvider.isDarkMode
                                      ? Colors.green[300]
                                      : Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              if (market.itemLocation.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14.0,
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4.0),
                                    Expanded(
                                      child: Text(
                                        market.itemLocation,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12.0),
                              if (market.description.isNotEmpty)
                                Text(
                                  market.description,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 8.0),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: const Text(
                                      'View Details',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
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
              );
            default:
              return const SizedBox.shrink();
          }
        },
      );
    }
  }


  Widget _buildJoinButton(Organization org, ThemeProvider themeProvider) {
    final isLoading = _isJoining[org.orgId.toString()] ?? false;

    switch (org.joinStatus.toLowerCase()) {
      case 'yes':
        return GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('orgID', org.orgId.toString());
            await prefs.setString('orgName', org.orgName);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedOutsidePage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Text(
              'Enter',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );

      case 'pending':
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrganizationDetails(mapData: {})),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );

      case 'no':
        return GestureDetector(
          onTap: isLoading
              ? null // Disable button while loading
              : () async {
                  await _handleJoinOrganization(org);
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        );

      case 'blocked':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Text(
            'Blocked',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        );

      default:
        return GestureDetector(
          onTap: isLoading
              ? null
              : () async {
                  await _handleJoinOrganization(org);
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
    }
  }


  Future<void> _handleJoinOrganization(Organization org) async {
    setState(() {
      _isJoining[org.orgId.toString()] = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('${base_url}townhall/join_org'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'org_id': org.orgId.toString(),
          // Add other parameters if needed
          // 'townhalls': [],
          // 'with_townhalls': false,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            // Update the organization's join status
            final updatedOrg = Organization(
              orgId: org.orgId,
              orgName: org.orgName,
              orgAbout: org.orgAbout,
              picture: org.picture,
              verified: org.verified,
              isMember: org.isMember,
              orgUsername: org.orgUsername,
              orgBg: org.orgBg,
              orgMemberCount: org.orgMemberCount,
              joinStatus: jsonData['data']['join_status'] ?? 'yes', // Update to 'yes' if joined
              requiresConfirmation: org.requiresConfirmation,
            );
            
            // Update the results list
            final orgIndex = _results[0]!.indexWhere((item) => (item as Organization).orgId == org.orgId);
            if (orgIndex != -1) {
              _results[0]![orgIndex] = updatedOrg;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['msg'] ?? 'Failed to join organization')),
          );
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isJoining[org.orgId.toString()] = false;
      });
    }
  }

  // Helper to format the location text
  String _formatLocation(String state, String country) {
    if (state.isNotEmpty && country.isNotEmpty) {
      return '$state, $country';
    } else if (state.isNotEmpty) {
      return state;
    } else if (country.isNotEmpty) {
      return country;
    }
    return '';
  }

  // Update the _buildFollowButton method
  Widget _buildFollowButton(Person person, ThemeProvider themeProvider) {
    final isLoading = _isFollowing[person.userId] ?? false;

    if (person.isFollowing.toLowerCase() == 'yes') {
      return GestureDetector(
        onTap: isLoading
            ? null // Disable button while loading
            : () async {
                await _handleUnfollowPerson(person);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: isLoading
            ? null // Disable button while loading
            : () async {
                await _handleFollowPerson(person);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Follow',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }
  }


  // Helper to format the profession information
  String _formatProfession(String category, String profession) {
    if (category.isNotEmpty && profession.isNotEmpty) {
      return '$profession · $category';
    } else if (profession.isNotEmpty) {
      return profession;
    } else if (category.isNotEmpty) {
      return category;
    }
    return 'Professional';
  }

  // Connect button for professionals
  Widget _buildProfessionalConnect(Professional pro, ThemeProvider themeProvider) {
    if (pro.isFollowing == '1') {
      return GestureDetector(
        onTap: () {
          // Implement disconnect functionality
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            'Connected',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // Implement connect functionality
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            'Connect',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }



  // Add this helper method to your _SearchState class
  Widget _buildPostInteractionButton({
    required IconData icon,
    required String label,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.0,
            color: color ?? (themeProvider.isDarkMode 
                ? Colors.grey[400] 
                : Colors.grey[600]),
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              color: color ?? (themeProvider.isDarkMode 
                  ? Colors.grey[400] 
                  : Colors.grey[600]),
            ),
          ),
        ],
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
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      final currentTerm = _searchController.text.trim();
      if (currentTerm != _lastSearchTerms[_selectedTabIndex]) {
        _onSearchChanged();
      }
    });
    _debounceTimer?.cancel();
    _currentSearchOperation?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
