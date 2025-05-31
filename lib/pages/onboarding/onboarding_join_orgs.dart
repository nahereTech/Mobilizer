import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobilizer/common/common/sharepreference.dart'; // Import AppSharedPreferences
import 'package:fluttertoast/fluttertoast.dart'; // For error toasts
import '../../pages/onboarding/onboarding_world_townhalls.dart';

class OnboardingJoinOrg extends StatefulWidget {
  const OnboardingJoinOrg({super.key});

  @override
  State<OnboardingJoinOrg> createState() => _OnboardingJoinOrgState();
}

class _OnboardingJoinOrgState extends State<OnboardingJoinOrg> {
  final TextEditingController _searchController = TextEditingController();
  List<Organization> _orgs = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounce; // Add a Timer for debouncing
  bool _buttonLoading = false; // Comment 1: Add buttonLoading to state class

  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch organizations on page load
  //   _fetchOrganizations();
  //   // Add listener to update UI when text changes (to show/hide clear button and filter results)
  //   _searchController.addListener(() {
  //     setState(() {});
  //     _debounceSearch(); // Call debounced search
  //     // _fetchOrganizations(keyword: _searchController.text);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounced search function
  void _debounceSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _fetchOrganizations(keyword: _searchController.text);
      }
    });
  }

  // Function to call the API with Authorization header
  Future<void> _fetchOrganizations({String keyword = '', int page = 1, int limit = 100}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Retrieve token from AppSharedPreferences
      final token = await AppSharedPreferences.getValue(key: 'token');
      if (token == null) {
        setState(() {
          _errorMessage = 'No authentication token found';
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'No authentication token found',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Use base_url from constants.dart
      final response = await http.get(
        Uri.parse('${base_url}orgs/fetch_orgs_for_onboarding?page=$page&limit=$limit&keyword=$keyword'),
        headers: {
          'Authorization': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          setState(() {
            _orgs = (jsonResponse['data'] as List)
                .map((org) => Organization.fromJson(org))
                .toList();
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse['msg'] ?? 'Failed to load organizations';
          });
          Fluttertoast.showToast(
            msg: jsonResponse['msg'] ?? 'Failed to load organizations',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        Fluttertoast.showToast(
          msg: 'Server error: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _joinOrganization(int orgId, int index) async {
    try {
      // Retrieve token from AppSharedPreferences
      final token = await AppSharedPreferences.getValue(key: 'token');
      if (token == null) {
        _showErrorSnackBar('No authentication token found');
        setState(() {
          _orgs[index].joined = false; // Revert state
        });
        return;
      }

      final response = await http.post(
        Uri.parse('${base_url}townhall/join_org'),
        headers: {
          'Authorization': token.toString(),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'org_id': orgId.toString(),
          'with_townhalls': 'false', // Adjust as needed
        },
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        // Success
        setState(() {
          _orgs[index].joined = true;
        });
        if (jsonResponse['tag'] == 'join_is_pending') {
          _showInfoSnackBar('Join request is pending approval');
        } else {
          _showInfoSnackBar('Successfully joined the organization');
        }
      } else {
        // Handle error
        setState(() {
          _orgs[index].joined = false; // Revert state
        });
        _showErrorSnackBar(jsonResponse['msg'] ?? 'Failed to join organization');
      }
    } catch (e) {
      setState(() {
        _orgs[index].joined = false; // Revert state
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _leaveOrganization(int orgId, int index) async {
    try {
      // Retrieve token from AppSharedPreferences
      final token = await AppSharedPreferences.getValue(key: 'token');
      if (token == null) {
        _showErrorSnackBar('No authentication token found');
        setState(() {
          _orgs[index].joined = true; // Revert state
        });
        return;
      }

      final response = await http.post(
        Uri.parse('${base_url}townhall/leave_org'),
        headers: {
          'Authorization': token.toString(),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'org_id': orgId.toString(),
        },
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 200) {
        // Success
        setState(() {
          _orgs[index].joined = false;
        });
        _showInfoSnackBar('Successfully left the organization');
      } else {
        // Handle error
        setState(() {
          _orgs[index].joined = true; // Revert state
        });
        _showErrorSnackBar(jsonResponse['msg'] ?? 'Failed to leave organization');
      }
    } catch (e) {
      setState(() {
        _orgs[index].joined = true; // Revert state
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  Future<void> _checkJoinedOrgsAndProceed() async {
    try {
      final token = await AppSharedPreferences.getValue(key: 'token');
      if (token == null) {
        _showErrorSnackBar('No authentication token found');
        setState(() {
          _buttonLoading = false; // Comment 3: Reset loader on error
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${base_url}orgs/count_joined_orgs'),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          final count = jsonResponse['count_of_orgs_joined'] ?? 0;
          if (count >= 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingWorldTownhalls()),
            );
          } else {
            _showErrorSnackBar('Please join at least 2 organizations to proceed');
          }
        } else {
          _showErrorSnackBar(jsonResponse['msg'] ?? 'Failed to fetch joined organizations');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      setState(() {
        _buttonLoading = false; // Comment 3: Reset loader on exception
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              "Join Townhalls",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),
        ),
        leadingWidth: 200,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _buttonLoading
            ? null
            : () async {
                print('Continue button pressed'); // Debug
                setState(() {
                  _buttonLoading = true; // Comment 2: Set loading state
                  print('buttonLoading set to true'); // Debug
                });
                await _checkJoinedOrgsAndProceed();
                setState(() {
                  _buttonLoading = false; // Comment 2: Reset loading state
                  print('buttonLoading set to false'); // Debug
                });
              },
        label: _buttonLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Continue'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Search field
              Form(
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Update UI for clear button
                    _debounceSearch();
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Townhall',
                    labelStyle: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.white
                                  : Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _fetchOrganizations(keyword: ''); // Trigger search with blank keyword
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Organization list
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _orgs.isEmpty
                          ? const Center(child: Text('No organizations found'))
                          : ListView.builder(
                              shrinkWrap: true, // Ensures ListView takes only the space it needs
                              physics: const NeverScrollableScrollPhysics(), // Disables ListView's own scrolling
                              itemCount: _orgs.length,
                              itemBuilder: (context, index) {
                                final org = _orgs[index];
                                // Determine container background color based on theme
                                final baseCardColor = Theme.of(context).cardColor;
                                final containerColor = Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Color.lerp(baseCardColor, Colors.white, 0.1) // Lighter in dark mode
                                    : Color.lerp(baseCardColor, Colors.black, 0.1); // Darker in light mode

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: containerColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider(org.orgLogo),
                                      child: org.orgLogo.isEmpty ? Text(org.orgName[0]) : null,
                                    ),
                                    title: Text(
                                      org.orgName,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      org.orgDesc,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: org.isLoading // Add isLoading to Organization model
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2.0),
                                          )
                                        : Checkbox(
                                            value: org.joined,
                                            onChanged: (org.changeable ?? true)
                                                ? (bool? value) async {
                                                    // Store the original state in case of error
                                                    final originalState = org.joined;
                                                    // Optimistically update UI
                                                    setState(() {
                                                      _orgs[index].joined = value ?? false;
                                                      _orgs[index].isLoading = true; // Show loader
                                                    });

                                                    if (value == true) {
                                                      // Call join_org endpoint
                                                      await _joinOrganization(org.id, index);
                                                    } else {
                                                      // Call leave_org endpoint
                                                      await _leaveOrganization(org.id, index);
                                                    }

                                                    setState(() {
                                                      _orgs[index].isLoading = false; // Hide loader
                                                    });
                                                  }
                                                : null,
                                          ),
                                  ),
                                );
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model class for Organization
class Organization {
  final int id;
  final String orgName;
  final String orgDesc;
  bool joined;
  final bool? changeable;
  final String orgLogo;
  bool isLoading; // Add isLoading field

  Organization({
    required this.id,
    required this.orgName,
    required this.orgDesc,
    required this.joined,
    this.changeable = true,
    required this.orgLogo,
    this.isLoading = false, // Default to false
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      orgName: json['org_name'],
      orgDesc: json['org_desc'],
      joined: json['joined'],
      changeable: json['changeable'] ?? true,
      orgLogo: json['org_logo'],
      isLoading: false, // Initialize isLoading
    );
  }
}