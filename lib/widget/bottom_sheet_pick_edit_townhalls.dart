import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart'; // Import ThemeProvider

class TownhallBottomSheetEdit extends StatefulWidget {
  TownhallBottomSheetEdit(
      {required this.orgID, required this.hasUpdated, Key? key})
      : super(key: key);
  final String orgID;
  final Function(bool) hasUpdated;

  @override
  _TownhallBottomSheetEditState createState() =>
      _TownhallBottomSheetEditState();
}

class _TownhallBottomSheetEditState extends State<TownhallBottomSheetEdit> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic> _dropdownData = {'dropdown': []};
  List<List<DropdownMenuItem<int>>> _dropdownItems = [];
  List<int?> _selectedValues = [];
  List<bool> _requiredFields = [];
  bool _isSubmitting = false;
  // Comment 1: Add a list to track loading state for each dropdown level to show shimmer during fetch
  List<bool> _dropdownLoading = [];
  // Comment 6: Add variable to track the maximum number of active dropdown levels
  int _maxDropdownLevels = 0;
  // Comment 7: Store has_children for each dropdown item
  List<List<Map<String, dynamic>>> _dropdownItemData = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final url =
        '${base_url}townhall/fetch_townhalls_of_joined_org_for_edit';
    final token = await AppSharedPreferences.getValue(key: 'token');
    try {
      final response = await http.get(
        Uri.parse('$url?org_id=${widget.orgID}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('dropdown')) {
          final dropdownList = data['dropdown'];
          if (dropdownList is List) {
            if (mounted) {
              setState(() {
                _dropdownItems = _buildDropdownItemsList(dropdownList);
                _selectedValues = dropdownList.map<int?>((levelData) {
                  final selectedId = levelData['selected'];
                  return selectedId is int ? selectedId : null;
                }).toList();

                for (int i = 0; i < _selectedValues.length; i++) {
                  final selectedValue = _selectedValues[i];
                  if (selectedValue != null &&
                      !_dropdownItems[i]
                          .any((item) => item.value == selectedValue)) {
                    _selectedValues[i] = null;
                  }
                }

                _requiredFields = dropdownList.map<bool>((levelData) {
                  return levelData['required'] ?? false;
                }).toList();
                // Comment 1: Initialize loading state for each dropdown
                _dropdownLoading = List<bool>.filled(dropdownList.length, false);
                // Comment 6: Initialize max dropdown levels to the full list length
                _maxDropdownLevels = dropdownList.length;
                _isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print("response S ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchChildren(int parentId, int level) async {
    final url = '${domainName}/api/townhall/fetch_townhall_children';
    final token = await AppSharedPreferences.getValue(key: 'token');
    try {
      // Comment 3: Set loading state for the next dropdown level before fetching
      setState(() {
        if (level + 1 < _dropdownLoading.length) {
          _dropdownLoading[level + 1] = true;
        }
      });
      final response = await http.get(
        Uri.parse('$url?parent_id=$parentId'),
        headers: {
          'Authorization': token.toString(),
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List) {
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            setState(() {
              if (level < _dropdownItems.length - 1) {
                // Comment 8: Update dropdown items and store item data
                _dropdownItems[level + 1] = [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      '-- Select --',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  ...dataList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          item['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ];
                // Comment 8: Store item data including has_children
                _dropdownItemData[level + 1] = dataList.map<Map<String, dynamic>>((item) => ({
                      'id': item['id'],
                      'name': item['name'],
                      'has_children': item['has_children'] ?? false,
                    })).toList();

                for (int i = level + 1; i < _selectedValues.length; i++) {
                  _selectedValues[i] = null;
                }
                // Comment 3: Reset loading state after fetch completes
                if (level + 1 < _dropdownLoading.length) {
                  _dropdownLoading[level + 1] = false;
                }
              }
            });
          }
        }
      }
      // Comment 3: Ensure loading state is reset even if request fails
      setState(() {
        if (level + 1 < _dropdownLoading.length) {
          _dropdownLoading[level + 1] = false;
        }
      });
    } catch (e) {
      // Comment 3: Reset loading state on error
      setState(() {
        if (level + 1 < _dropdownLoading.length) {
          _dropdownLoading[level + 1] = false;
        }
      });
      print('Error fetching children: $e');
    }
  }

  List<List<DropdownMenuItem<int>>> _buildDropdownItemsList(
      List<dynamic> dropdownList) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _dropdownItemData = [];
    return dropdownList.map<List<DropdownMenuItem<int>>>((levelData) {
      List<DropdownMenuItem<int>> items = [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            '-- Select --',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ];
      List<Map<String, dynamic>> levelItemData = [];
      if (levelData['level_list'] is List) {
        items.addAll(levelData['level_list'].map<DropdownMenuItem<int>>((item) {
          levelItemData.add({
            'id': item['id'],
            'name': item['name'],
            'has_children': item['has_children'] ?? false,
          });
          return DropdownMenuItem<int>(
            value: item['id'],
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                item['name'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList());
      }
      // Comment 7: Store item data for this level
      _dropdownItemData.add(levelItemData);
      return items;
    }).toList();
  }

  void _handleDropdownChange(int level, int? value) {
    if (_selectedValues[level] != value) {
      setState(() {
        _selectedValues[level] = value;

        // Comment 2: Clear dropdowns below the changed level and update max levels
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        for (int i = level + 1; i < _dropdownItems.length; i++) {
          _dropdownItems[i] = [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                '-- Select --',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ];
          _dropdownItemData[i] = [];
          _selectedValues[i] = null;
          _dropdownLoading[i] = false;
        }

        // Comment 2: Limit max dropdown levels based on has_children
        bool hasChildren = false;
        if (value != null) {
          final selectedItem = _dropdownItemData[level].firstWhere(
            (item) => item['id'] == value,
            orElse: () => {'has_children': false},
          );
          hasChildren = selectedItem['has_children'] ?? false;
        }
        _maxDropdownLevels = value != null && hasChildren ? level + 2 : level + 1;

        // Comment 2: Only fetch children if has_children is true
        if (value != null && hasChildren && level < _dropdownItems.length - 1) {
          _fetchChildren(value, level);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    if (_formKey.currentState?.validate() ?? false) {
      final url = '${domainName}/api/townhall/update_joined_org_townhalls';
      final selectedTownhalls = _selectedValues.whereType<int>().toList();
      setState(() {
        _isSubmitting = true;
      });
      try {
        print("Arg:  ${widget.orgID} ${selectedTownhalls}");
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token.toString(),
          },
          body: jsonEncode(
              {'org_id': widget.orgID, 'townhalls': selectedTownhalls}),
        );
        final resp = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (resp['status'] == 200) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Successful',
                  style: TextStyle(color: Colors.white),
                )));
            Navigator.of(context).pop();
            widget.hasUpdated(true);
          } else {
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }
            Fluttertoast.showToast(
              msg: "${resp['msg']}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
          Fluttertoast.showToast(
            msg: "${resp['msg']}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });

        Fluttertoast.showToast(
          msg: "$e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 5 / 6;

    return Container(
      height: bottomSheetHeight,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 15.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Text(
                  'Join Townhalls in Organization',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Select the townhalls you belong to. Note that townhalls you select here apply to only this organization',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: _isLoading
                        ? Shimmer.fromColors(
                            baseColor: themeProvider.isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            highlightColor: themeProvider.isDarkMode
                                ? Colors.grey[600]!
                                : Colors.grey[100]!,
                            child: Column(
                              children: List.generate(
                                3,
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Container(
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: themeProvider.isDarkMode
                                            ? Colors.grey[600]!
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
                              // Comment 5: Only show dropdowns up to _maxDropdownLevels
                              ..._dropdownItems.asMap().entries.take(_maxDropdownLevels).map((entry) {
                                int index = entry.key;
                                // Comment 4: Show shimmer if the dropdown is loading
                                if (_dropdownLoading[index]) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    child: Shimmer.fromColors(
                                      baseColor: themeProvider.isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                      highlightColor: themeProvider.isDarkMode
                                          ? Colors.grey[600]!
                                          : Colors.grey[100]!,
                                      child: Container(
                                        height: 60.0,
                                        decoration: BoxDecoration(
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[600]!
                                                : Colors.grey[400]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: _requiredFields[index] &&
                                                _selectedValues[index] == null
                                            ? Colors.red
                                            : (themeProvider.isDarkMode
                                                ? Colors.grey[600]!
                                                : Colors.grey[400]!),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider.isDarkMode
                                              ? Colors.black.withOpacity(0.5)
                                              : Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      value: _selectedValues[index],
                                      items: _dropdownItems[index],
                                      onChanged: (value) {
                                        _handleDropdownChange(index, value);
                                      },
                                      validator: (value) {
                                        if (_requiredFields[index] &&
                                            value == null) {
                                          return 'This field is required';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        labelText: 'Level ${index + 1}',
                                        labelStyle: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      dropdownColor: themeProvider.isDarkMode
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white,
                                      menuMaxHeight: 300,
                                    ),
                                  ),
                                );
                              }).toList(),
                              SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.isDarkMode
                                          ? Colors.blueGrey[700]
                                          : Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _isSubmitting
                                        ? SizedBox(
                                            width: 28.0,
                                            height: 28.0,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3.0,
                                            ),
                                          )
                                        : const Text(
                                            'Update',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.0),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}