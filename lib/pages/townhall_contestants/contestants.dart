import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TownhallContestantsPage extends StatefulWidget {
  static String routeName = 'contest_townhall_leadership_page';
  
  final int orgId;
  final int townhallId;

  const TownhallContestantsPage({
    Key? key,
    required this.orgId,
    required this.townhallId,
  }) : super(key: key);

  @override
  _TownhallContestantsPageState createState() => _TownhallContestantsPageState();
}

class _TownhallContestantsPageState extends State<TownhallContestantsPage> {
  List<Contestant> contestants = [];
  bool isLoading = true;
  List<dynamic> isContestantData = [];
  bool alreadyVoted = false;
  bool showContestButton = true;
  bool showVoteButtons = true;
  bool showWithdrawButton = false; // New variable
  bool isJoining = false;
  final TextEditingController _searchController = TextEditingController();
  String? _searchKeyword;

  @override
  void initState() {
    super.initState();
    fetchContestants();
  }

  Future<void> fetchContestants({String? keyword}) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('No authorization token found in SharedPreferences');
      }

      final Map<String, String> queryParams = {
        'townhall_id': widget.townhallId.toString(),
        'org_id': widget.orgId.toString(),
      };
      
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final response = await http.get(
        Uri.parse('${base_url}townhall/fetch_contestants_in_townhall')
            .replace(queryParameters: queryParams),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            contestants = (jsonData['data'] as List)
                .map((item) => Contestant(
                      name: '${item['firstname']} ${item['lastname']}',
                      username: item['username'],
                      bio: item['manifesto'],
                      avatarColor: Colors.blue,
                      votes: item['votes'],
                      imageUrl: item['picture'],
                      votedForContestant: item['voted_for_contestant'] ?? false,
                      townhallId: widget.townhallId,  // Use widget's townhallId
                      orgId: widget.orgId,            // Use widget's orgId
                      userId: item['user_id'].toString(),  // Get from API response
                    ))
                .toList();
            isContestantData = jsonData['is_contestant_data'] ?? [];
            alreadyVoted = jsonData['already_voted'] ?? false;
            showContestButton = jsonData['show_contest_button'] ?? true;
            showVoteButtons = jsonData['show_vote_buttons'] ?? true;
            showWithdrawButton = jsonData['show_withdraw_button'] ?? false;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['msg'])),
          );
        }
      } else {
        throw Exception('Failed to load contestants: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  void _showSearchBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search contestants...',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: themeProvider.isDarkMode 
                          ? Colors.grey[900] 
                          : Colors.grey[100],
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setModalState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                    onChanged: (value) {
                      setModalState(() {}); // Update to show/hide clear button
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_searchKeyword != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchKeyword = null;
                              _searchController.clear();
                              isLoading = true;
                            });
                            fetchContestants();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Clear Search',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchKeyword = _searchController.text.trim();
                            isLoading = true;
                          });
                          fetchContestants(keyword: _searchKeyword);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContestForm(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profilePhoto = prefs.getString('profile_photo');
    final String? firstName = prefs.getString('firstname');
    final String? lastName = prefs.getString('lastname');
    final String? username = prefs.getString('username');
    final String? token = prefs.getString('token');
    final TextEditingController manifestoController = TextEditingController();
    bool manifestoError = false;
    bool localIsJoining = false; // Local loading state for the modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: profilePhoto != null
                          ? Image.network(
                              profilePhoto,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  firstName?[0] ?? 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue,
                              child: Text(
                                firstName?[0] ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${firstName ?? ''} ${lastName ?? ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${username ?? ''}',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: manifestoController,
                      maxLines: 4,
                      onChanged: (value) {
                        if (manifestoError) {
                          setModalState(() {
                            manifestoError = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your manifesto',
                        hintStyle: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: themeProvider.isDarkMode 
                            ? Colors.grey[900] 
                            : Colors.grey[100],
                        errorBorder: manifestoError ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1.0),
                        ) : null,
                        focusedErrorBorder: manifestoError ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1.0),
                        ) : null,
                      ),
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    if (manifestoError)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            'Please fill in your manifesto',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: localIsJoining
                            ? null
                            : () async {
                                if (manifestoController.text.trim().isEmpty) {
                                  setModalState(() {
                                    manifestoError = true;
                                  });
                                  return;
                                }

                                if (token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No authorization token found'),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  localIsJoining = true;
                                });
                                setState(() {
                                  isJoining = true;
                                });

                                try {
                                  final response = await http.get(
                                    Uri.parse('${base_url}townhall/join_contest')
                                        .replace(queryParameters: {
                                          'townhall_id': widget.townhallId.toString(),
                                          'org_id': widget.orgId.toString(),
                                          'manifesto': manifestoController.text,
                                        }),
                                    headers: {
                                      'Authorization': token,
                                      'Content-Type': 'application/json',
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    final jsonData = jsonDecode(response.body);
                                    if (jsonData['status'] == true) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Joined the contest successfully! List refreshed.',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      await fetchContestants();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(jsonData['msg']),
                                        ),
                                      );
                                      setModalState(() {
                                        localIsJoining = false;
                                      });
                                    }
                                  } else {
                                    throw Exception('Failed to join contest: ${response.statusCode}');
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                    ),
                                  );
                                  setModalState(() {
                                    localIsJoining = false;
                                  });
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isJoining = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: localIsJoining
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Join',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // First, let's add a method to handle withdrawal from the contest
  void _withdrawFromContest(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? currentUserId = prefs.getString('user_id'); // Assuming user_id is stored

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authorization token found'),
        ),
      );
      return;
    }

    setState(() {
      isJoining = true; // Reuse the same loading state
    });

    try {
      final response = await http.get(
        Uri.parse('${base_url}townhall/withdraw_from_contest').replace(
          queryParameters: {
            'townhall_id': widget.townhallId.toString(),
            'org_id': widget.orgId.toString(),
          },
        ),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Withdrawn from the contest successfully! List refreshed.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          // Remove the contestant from the list client-side
          if (currentUserId != null) {
            setState(() {
              contestants.removeWhere((contestant) => contestant.userId == currentUserId);
            });
          }
          // Refresh the contestants list from server
          await fetchContestants();
          // Update state to hide withdraw button
          setState(() {
            showWithdrawButton = false;
            showContestButton = true; // Show contest button again
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['msg']),
            ),
          );
        }
      } else {
        throw Exception('Failed to withdraw from contest: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
        title: Text(
          'Townhall Contestants',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => _showSearchBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'The most popular contestant will be assigned the leader of the Townhall on 30th of June, 2025.',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor: themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white, // This will be covered by shimmer effect
                            borderRadius: BorderRadius.circular(12.0), // Add border radius
                          ),
                        ),
                      ),
                    )
                  : contestants.isEmpty
                      ? const Center(child: Text('No contestants found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: contestants.length,
                          itemBuilder: (context, index) {
                            final contestant = contestants[index];
                            return ContestantProfileCard(
                              contestant: contestant,
                              alreadyVoted: alreadyVoted,
                              showVoteButtons: showVoteButtons,
                              onVoteCast: () => fetchContestants(),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: (showContestButton || showWithdrawButton)
        ? FloatingActionButton.extended(
            onPressed: isJoining 
                ? null 
                : () {
                    if (showWithdrawButton) { // Prioritize withdraw button
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          final themeProvider = Provider.of<ThemeProvider>(context);
                          return AlertDialog(
                            backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            title: Text(
                              'Withdraw from Contest',
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to withdraw from this contest? This action cannot be undone.',
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  _withdrawFromContest(context);
                                },
                                child: Text(
                                  'Withdraw',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.red[400] : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      );
                    } else if (isContestantData.isEmpty) {
                      _showContestForm(context);
                    }
                  },
            backgroundColor: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue,
            label: isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    showWithdrawButton ? 'Withdraw' : 'Contest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )
        : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Contestant {
  final String name;
  final String username;
  final String bio;
  final Color avatarColor;
  final int votes;
  final String imageUrl;
  final bool votedForContestant;
  final int townhallId;      // Added
  final int orgId;          // Added
  final String userId;      // Added

  Contestant({
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarColor,
    required this.votes,
    required this.imageUrl,
    this.votedForContestant = false,
    required this.townhallId,
    required this.orgId,
    required this.userId,
  });
}

class ContestantProfileCard extends StatefulWidget {
  final Contestant contestant;
  final bool alreadyVoted;
  final bool showVoteButtons;
  final VoidCallback onVoteCast; // New callback

  const ContestantProfileCard({
    Key? key,
    required this.contestant,
    required this.alreadyVoted,
    required this.showVoteButtons,
    required this.onVoteCast, // Add this
  }) : super(key: key);

  @override
  _ContestantProfileCardState createState() => _ContestantProfileCardState();
}


class _ContestantProfileCardState extends State<ContestantProfileCard> {
  bool isVoting = false;

  Future<void> _castVote(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing')),
      );
      return;
    }

    setState(() {
      isVoting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${base_url}townhall/cast_a_vote'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'townhall_id': widget.contestant.townhallId.toString(),
          'org_id': widget.contestant.orgId.toString(),
          'contestant_user_id': widget.contestant.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vote cast successfully for ${widget.contestant.name}'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onVoteCast();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['msg'] ?? 'Failed to cast vote')),
          );
        }
      } else {
        throw Exception('Failed to cast vote: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isVoting = false;
        });
      }
    }
  }

  void _showContestantDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          widget.contestant.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => CircleAvatar(
                            radius: 40,
                            backgroundColor: widget.contestant.avatarColor,
                            child: Text(
                              widget.contestant.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contestant.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            widget.contestant.username,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manifesto:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.contestant.bio,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Votes: ${widget.contestant.votes}',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                  if (widget.showVoteButtons && !widget.alreadyVoted && !widget.contestant.votedForContestant)
                    const SizedBox(height: 24),
                  if (widget.showVoteButtons && !widget.alreadyVoted && !widget.contestant.votedForContestant)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isVoting
                            ? null
                            : () async {
                                setModalState(() {
                                  isVoting = true;
                                });
                                await _castVote(context);
                                if (mounted) {
                                  setModalState(() {
                                    isVoting = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isVoting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Vote',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => _showContestantDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                widget.contestant.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  radius: 30,
                  backgroundColor: widget.contestant.avatarColor,
                  child: Text(
                    widget.contestant.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.contestant.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              widget.contestant.username,
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              widget.contestant.bio,
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      SizedBox(
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.showVoteButtons && !widget.alreadyVoted && !widget.contestant.votedForContestant)
                              GestureDetector(
                                onTap: () => _showContestantDetails(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Vote',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.showVoteButtons && !widget.alreadyVoted && !widget.contestant.votedForContestant)
                              const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.contestant.votes} votes',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (widget.contestant.votedForContestant)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}