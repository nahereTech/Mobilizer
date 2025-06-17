import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../pages/onboarding/onboarding_other_townhalls.dart';
import '../feed/feed_outside.dart';

//TO DO, if already a member, move to next page

// Assuming these are defined elsewhere in your project
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';

class OnboardingWorldTownhalls extends StatefulWidget {
  const OnboardingWorldTownhalls({super.key});

  @override
  State<OnboardingWorldTownhalls> createState() => _OnboardingWorldTownhallsState();
}

class _OnboardingWorldTownhallsState extends State<OnboardingWorldTownhalls> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  List<List<DropdownMenuItem<int>>> _dropdownItems = [];
  List<int?> _selectedValues = [];
  List<bool> _requiredFields = [];
  bool _isSubmitting = false;
  String? _orgID; // Store orgID fetched from the initial API call
  Map<int, bool> _hasChildrenMap = {};

  // 1. Add a list to track loading state for each dropdown level
  List<bool> _isFetchingChildren = [];

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  Future<void> _checkMembershipStatus() async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    final orgId = await AppSharedPreferences.getValue(key: 'current_org') ?? '182'; // Fallback to '182' if not found
    final url = '${base_url}orgs/has_user_joined_this_org?org_id=$orgId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['joined'] == true) {
          // User has already joined, redirect to next page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const FeedOutsidePage(),
              ),
            );
          });
          return;
        }
      }
      // If not joined or error occurs, proceed with fetching townhall data
      _fetchInitialTownhallData();
    } catch (e) {
      // On error, still proceed with fetching townhall data
      Fluttertoast.showToast(
        msg: 'Error checking membership: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      _fetchInitialTownhallData();
    }
  }

  Future<void> _fetchInitialTownhallData() async {
    const int initialParentId = 1;
    final url = '${base_url}townhall/fetch_townhall_children?parent_id=$initialParentId';
    final token = await AppSharedPreferences.getValue(key: 'token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final dataList = data['data'] as List;
          setState(() {
            _dropdownItems = [
              [
                const DropdownMenuItem<int>(value: null, child: Text('-- Select --')),
                ...dataList.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        item['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ];
            _hasChildrenMap = {
              for (var item in dataList) item['id']: item['has_children'] == true,
            };
            _selectedValues = [null];
            _requiredFields = [true];
            // 2. Initialize _isFetchingChildren with false for the first level
            _isFetchingChildren = [false];
            _orgID = data['org_id'] ?? '182';
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch initial townhall data');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error fetching initial data: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


  Future<void> _fetchChildren(int parentId, int level) async {
    final url = '${base_url}townhall/fetch_townhall_children?parent_id=$parentId';
    final token = await AppSharedPreferences.getValue(key: 'token');


    // 3. Set loading state for the next dropdown level
    setState(() {
      if (level + 1 >= _isFetchingChildren.length) {
        _isFetchingChildren.add(true);
      } else {
        _isFetchingChildren[level + 1] = true;
      }
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final dataList = data['data'] as List;
          setState(() {
            if (level + 1 >= _dropdownItems.length) {
              _dropdownItems.add([
                const DropdownMenuItem<int>(value: null, child: Text('-- Select --')),
              ]);
              _selectedValues.add(null);
              _requiredFields.add(false);
            }
            _dropdownItems[level + 1] = [
              const DropdownMenuItem<int>(value: null, child: Text('-- Select --')),
              ...dataList.map<DropdownMenuItem<int>>((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      item['name'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ];
            // Update hasChildrenMap with new items
            _hasChildrenMap.addAll({
              for (var item in dataList) item['id']: item['has_children'] == true,
            });
            for (int i = level + 1; i < _selectedValues.length; i++) {
              _selectedValues[i] = null;
            }
            // 4. Reset loading state after fetching
            _isFetchingChildren[level + 1] = false;
          });
        }
      }
    } catch (e) {
      // 5. Reset loading state on error
      setState(() {
        _isFetchingChildren[level + 1] = false;
      });
      print('Error fetching children: $e');
    }
  }

  void _handleDropdownChange(int level, int? value) {
    if (_selectedValues[level] != value) {
      setState(() {
        _selectedValues[level] = value;

        // Trim dropdowns and values beyond the changed level
        if (level + 1 < _dropdownItems.length) {
          _dropdownItems.removeRange(level + 1, _dropdownItems.length);
          _selectedValues.removeRange(level + 1, _selectedValues.length);
          _requiredFields.removeRange(level + 1, _requiredFields.length);
          // 6. Trim _isFetchingChildren as well
          _isFetchingChildren.removeRange(level + 1, _isFetchingChildren.length);
        }

        // Only fetch children if the selected item has children
        if (value != null && _hasChildrenMap[value] == true) {
          _fetchChildren(value, level);
        }
      });
    }
  }

  Future<void> _handleJoin() async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    final orgId = await AppSharedPreferences.getValue(key: 'current_org');
    print("it is this : ${orgId}");
    
    if (orgId == null) {
      Fluttertoast.showToast(
        msg: 'Organization ID not available',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final url = '${base_url}townhall/join_org_with_townhalls';
      final selectedTownhalls = _selectedValues.whereType<int>().toList();

      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token.toString(),
          },
          body: jsonEncode({
            'org_id': orgId,
            'townhalls': selectedTownhalls,
            'with_townhalls': true,
          }),
        );
        final resp = jsonDecode(response.body);

        if (response.statusCode == 200 && resp['status'] == 200) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully joined!', style: TextStyle(color: Colors.white)),
            ),
          );
          
          // Navigate to FeedOutsidePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FeedOutsidePage(),
            ),
          );
        } else {
          setState(() {
            _isSubmitting = false;
          });
          Fluttertoast.showToast(
            msg: resp['msg'] ?? 'Failed to join',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/0fc35802-9914-4296-1276-186602fbe000/mid', // 0fc35802-9914-4296-1276-186602fbe000
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Your Location',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Select your location. It should be your location of residence.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _isLoading
                ? Shimmer.fromColors(
                    baseColor: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    highlightColor: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.grey[600]!
                        : Colors.grey[100]!,
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[400]!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : Column(
                      children: [
                        // 7. Render existing dropdowns
                        ..._dropdownItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: _requiredFields[index] && _selectedValues[index] == null
                                      ? Colors.red
                                      : Theme.of(context).dividerColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<int>(
                                value: _selectedValues[index],
                                items: _dropdownItems[index],
                                onChanged: (value) => _handleDropdownChange(index, value),
                                validator: (value) {
                                  if (_requiredFields[index] && value == null) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  labelText: 'Level ${index + 1}',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                  ),
                                  border: InputBorder.none,
                                ),
                                dropdownColor: Theme.of(context).cardColor,
                                style: Theme.of(context).textTheme.bodyLarge,
                                menuMaxHeight: 300,
                              ),
                            ),
                          );
                        }).toList(),
                        // 8. Add shimmer for the next dropdown if fetching
                        if (_isFetchingChildren.length > _dropdownItems.length &&
                            _isFetchingChildren[_dropdownItems.length])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Shimmer.fromColors(
                              baseColor: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              highlightColor: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[100]!,
                              child: Container(
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Provider.of<ThemeProvider>(context).isDarkMode
                                        ? Colors.grey[700]!
                                        : Colors.grey[400]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SpinKitCircle(
                                    color: Colors.white,
                                    size: 50.0,
                                  )
                                : const Text(
                                    "Join",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}