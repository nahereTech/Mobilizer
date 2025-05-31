import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class InviteBottomSheet extends StatefulWidget {
  InviteBottomSheet({required this.orgID, required this.orgName});
  final String orgID;
  final String orgName;
  @override
  InviteBottomSheetState createState() => InviteBottomSheetState();
}

class InviteBottomSheetState extends State<InviteBottomSheet> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _showEmailView = false;
  bool _isSendingEmail = false;
  String _emailError = '';

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _sendEmailInvite() async {
    final email = _emailController.text.trim();
    if (!isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isSendingEmail = true;
      _emailError = '';
    });
    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.post(
        Uri.parse('${domainName}/api/orgs/invite_user'),
        headers: {
          'Authorization': '$authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user': email,
          //'org_id': 5,
          'org_id': widget.orgID
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          Navigator.of(context).pop();
          _emailController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invitation sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _emailError = data['msg'] ?? 'Failed to send invitation';
          });
        }
      } else {
        setState(() {
          _emailError = 'Failed to send invitation';
        });
      }
    } catch (e) {
      setState(() {
        _emailError = 'Error sending invitation';
      });
    } finally {
      setState(() {
        _isSendingEmail = false;
      });
    }
  }

  Widget _buildEmailView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invite by Email',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showEmailView = false;
                  _emailError = '';
                  _emailController.clear();
                });
              },
              child: Text(
                'or invite from townhall',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Enter email address',
            hintStyle: TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _emailError.isNotEmpty ? _emailError : null,
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: !_isSendingEmail,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSendingEmail ? null : () => _sendEmailInvite(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: _isSendingEmail
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Send Invite',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // Your existing methods remain unchanged
  Widget _buildShimmerPlaceholder() {
    // Existing implementation
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _searchPeople(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/townhall/findPeople?term=$searchTerm&limit=25'),
        headers: {
          'Authorization': '$authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Widget _showSearchSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _showEmailView
          ? _buildEmailView(context)
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invite Friend',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showEmailView = true;
                            });
                          },
                          child: Text(
                            'or invite by email',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Rest of your existing search view implementation
                    SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(Duration(milliseconds: 500), () {
                          _searchPeople(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Townhall...',
                        hintStyle: TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? _buildShimmerPlaceholder()
                          : _searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    _searchController.text.isEmpty
                                        ? 'Search Townhall for people to invite'
                                        : 'No results found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final user = _searchResults[index];
                                    return GestureDetector(
                                      onTap: () {
                                        _showConfirmationDialog(user);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 0),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 2,
                                                ),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      user['photo_path'] ?? ''),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user['fullname'] ?? '',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "@${user['username'] ?? ''}",
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _showConfirmationDialog(Map user) {
    bool _isInviting = false; // Track if the invitation is in progress
    String _errorMessage = ""; // Store error message
    bool _showOverlay = false; // Control visibility of the full-screen overlay

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // Ensure content takes minimal space
                children: [
                  Wrap(
                    children: [
                      Text(
                          'Do you want to invite ${user['fullname']} to join '),
                      Text(
                        "${widget.orgName} ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("?")
                    ],
                  ),
                  if (_errorMessage
                      .isNotEmpty) // Only show the error message if it's not empty
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red, // Red color for the error message
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.red.shade100, // Light red background
                    foregroundColor: Colors.white, // White text color
                  ),
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _isInviting
                        ? Colors.grey
                        : Colors.green, // Green background, grey when loading
                    foregroundColor: Colors.white, // White text color
                  ),
                  child: _isInviting
                      ? CircularProgressIndicator(
                          color: Colors.white) // Show loader when inviting
                      : Text('Yes'),
                  onPressed: _isInviting
                      ? null // Disable button when the invitation is in progress
                      : () async {
                          setDialogState(() {
                            _isInviting = true; // Start loading
                            _showOverlay = true; // Show the overlay
                            _errorMessage =
                                ""; // Reset any previous error messages
                          });

                          // Send the invite request
                          try {
                            final authToken =
                                await AppSharedPreferences.getValue(
                                    key: 'token');
                            final response = await http
                                .post(
                                  Uri.parse(
                                      '${domainName}/api/orgs/invite_user'),
                                  headers: {
                                    'Authorization': '$authToken',
                                    'Content-Type': 'application/json',
                                  },
                                  body: json.encode({
                                    'user': user[
                                        'user_id'], // User ID to be invited
                                    'org_id': widget.orgID, // Hardcoded org_id
                                  }),
                                )
                                .timeout(Duration(
                                    seconds: 60)); // Set timeout for 60 seconds

                            if (response.statusCode == 200) {
                              final data = json.decode(response.body);
                              if (data['status'] == true) {
                                // Success case
                                Navigator.of(context).pop(); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Invitation sent successfully'),
                                      backgroundColor: Colors.green),
                                );
                                setState(() {
                                  _searchResults
                                      .clear(); // Clear the search results
                                  _searchController
                                      .clear(); // Clear the search field
                                });
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
                              } else {
                                // Show error message from the API response
                                setDialogState(() {
                                  _errorMessage = data['msg'] ??
                                      'Failed to send invitation';
                                });
                              }
                            } else {
                              // Handle other HTTP errors (e.g., non-200 status)
                              setDialogState(() {
                                _errorMessage = 'Failed to send invitation';
                              });
                            }
                          } catch (e) {
                            // Handle request error (e.g., timeout, no internet)
                            setDialogState(() {
                              _errorMessage = 'Error sending invitation';
                            });
                          } finally {
                            // Ensure button is re-enabled after request
                            setDialogState(() {
                              _isInviting = false;
                              _showOverlay = false; // Hide the overlay
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );

    // Full-screen overlay while the request is going on
    if (_showOverlay) {
      // Show the overlay to block user interaction
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent closing the overlay by tapping outside
        builder: (BuildContext context) {
          return Center(
            child:
                CircularProgressIndicator(), // Show a loading spinner in the center
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _emailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showSearchSheet();
  }
}
