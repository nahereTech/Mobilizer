import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import '../../pages/feed/feed_outside.dart';

class OnboardingOtherTownhalls extends StatefulWidget {
  const OnboardingOtherTownhalls({super.key});

  @override
  State<OnboardingOtherTownhalls> createState() => _OnboardingOtherTownhallsState();
}

class _OnboardingOtherTownhallsState extends State<OnboardingOtherTownhalls> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<List<DropdownMenuItem<int>>> _dropdownItems = [];
  List<int?> _selectedValues = [];
  List<bool> _requiredFields = [];
  bool _isSubmitting = false;
  String? _orgID;
  List<Map<String, dynamic>> _organizations = [];
  TextEditingController _orgController = TextEditingController();
  List<String> _avatarImages = [];
  bool _isLoadingImages = true;

  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // _fetchOrganizations();
    _fetchAvatarImages();
    // Do not call _fetchInitialTownhallData here; wait for organization selection
  }

  Future<void> _fetchAvatarImages() async {
    // [Unchanged code]
    final url = '${base_url}orgs/images_for_onboarding_page';
    final token = await AppSharedPreferences.getValue(key: 'token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _avatarImages = List<Map<String, dynamic>>.from(data['data'])
                .map((item) => item['url'] as String)
                .toList();
            _isLoadingImages = false;
          });
        }
      } else {
        throw Exception('Failed to fetch avatar images');
      }
    } catch (e) {
      setState(() {
        _isLoadingImages = false;
      });
      Fluttertoast.showToast(
        msg: 'Error fetching images: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _searchOrganizations(String keyword) async {
    // [Unchanged code]
    final url =
        '${base_url}townhall/perform_search?section=organizations&keyword=$keyword';
    final token = await AppSharedPreferences.getValue(key: 'token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _organizations = List<Map<String, dynamic>>.from(data['data']);
            _isSearching = false;
          });
        } else {
          setState(() {
            _organizations = [];
            _isSearching = false;
          });
        }
      } else {
        throw Exception('Failed to search organizations');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      Fluttertoast.showToast(
        msg: 'Error searching organizations: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _fetchOrganizations() async {
    // [Unchanged code]
    final url = '${base_url}api/organizations';
    final token = await AppSharedPreferences.getValue(key: 'token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _organizations = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      } else {
        throw Exception('Failed to fetch organizations');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching organizations: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _fetchInitialTownhallData(int orgId) async {
    final url = '${base_url}townhall/fetch_townhall_children?org_id=$orgId';
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
            _selectedValues = [null];
            _requiredFields = [true];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch initial townhall data');
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
    // [Unchanged code]
    final url = '${base_url}townhall/fetch_townhall_children?parent_id=$parentId';
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
            for (int i = level + 1; i < _selectedValues.length; i++) {
              _selectedValues[i] = null;
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  void _handleDropdownChange(int level, int? value) {
    // [Unchanged code]
    if (_selectedValues[level] != value) {
      setState(() {
        _selectedValues[level] = value;
        if (level + 1 < _dropdownItems.length) {
          _dropdownItems.removeRange(level + 1, _dropdownItems.length);
          _selectedValues.removeRange(level + 1, _selectedValues.length);
          _requiredFields.removeRange(level + 1, _requiredFields.length);
        }
        if (value != null) {
          _fetchChildren(value, level);
        }
      });
    }
  }

  Future<void> _handleJoin() async {
    // [Unchanged code]
    if (_orgID == null) {
      Fluttertoast.showToast(
        msg: 'Organization ID not available',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final token = await AppSharedPreferences.getValue(key: 'token');
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
            'org_id': _orgID,
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

          // Redirect to FeedsOutside page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FeedOutsidePage()),
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

  double calculateTotalWidth() {
    // [Unchanged code]
    double totalWidth = 0;
    for (int i = 0; i < _avatarImages.length; i++) {
      final radius = i.isEven ? 35.0 : (i % 3 == 1 ? 25.0 : 30.0);
      totalWidth += radius * 2;
      if (i < _avatarImages.length - 1) totalWidth += 10;
    }
    return totalWidth;
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
              SizedBox(
                height: 145,
                child: _isLoadingImages
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ClipRect(
                        child: Center(
                          child: SizedBox(
                            width: calculateTotalWidth(),
                            height: 145,
                            child: Stack(
                              alignment: Alignment.center,
                              children: _avatarImages.asMap().entries.map((entry) {
                                int index = entry.key;
                                String url = entry.value;
                                double radius = index.isEven
                                    ? 35.0
                                    : (index % 3 == 1 ? 25.0 : 30.0);
                                double leftPosition = 0;
                                for (int i = 0; i < index; i++) {
                                  final prevRadius = i.isEven
                                      ? 35.0
                                      : (i % 3 == 1 ? 25.0 : 30.0);
                                  leftPosition += (prevRadius * 2) + 10;
                                }
                                double topPosition;
                                if (index % 3 == 0) {
                                  topPosition = 40.0;
                                } else if (index % 3 == 1) {
                                  topPosition = 20.0;
                                } else {
                                  topPosition = 60.0;
                                }
                                return Positioned(
                                  left: leftPosition,
                                  top: topPosition,
                                  child: CircleAvatar(
                                    radius: radius,
                                    backgroundImage: NetworkImage(url),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Join other communities',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Search for communities you are interested in below and join their sub townhalls',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _orgID == null ? Colors.red : Theme.of(context).dividerColor,
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
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _organizations
                        .map((org) => org['org_name'] as String)
                        .where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    final selectedOrg = _organizations.firstWhere(
                      (org) => org['org_name'] == selection,
                    );
                    setState(() {
                      _orgID = selectedOrg['org_id'].toString();
                      _orgController.text = selection;
                      _isLoading = true; // Show loading while fetching townhalls
                      _dropdownItems.clear(); // Clear previous dropdowns
                      _selectedValues.clear();
                      _requiredFields.clear();
                    });
                    _fetchInitialTownhallData(int.parse(_orgID!)); // Fetch townhalls for selected org
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    _orgController = fieldTextEditingController;
                    return TextFormField(
                      controller: _orgController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        labelText: 'Organization',
                        hintText: 'Search organizations...',
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select an organization' : null,
                      onChanged: (value) {
                        setState(() {
                          _isSearching = true;
                        });
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(seconds: 1), () {
                          _searchOrganizations(value);
                        });
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: _isSearching
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: SpinKitCircle(
                                      color: Colors.blue,
                                      size: 40.0,
                                    ),
                                  ),
                                )
                              : options.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No organizations found'),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final String option = options.elementAt(index);
                                        return GestureDetector(
                                          onTap: () => onSelected(option),
                                          child: ListTile(
                                            title: Text(option),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : _dropdownItems.isEmpty
                      ? const Text('Select an organization to see townhalls')
                      : Column(
                          children: [
                            ..._dropdownItems.asMap().entries.map((entry) {
                              int index = entry.key;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: _requiredFields[index] &&
                                              _selectedValues[index] == null
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

  @override
  void dispose() {
    _orgController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}