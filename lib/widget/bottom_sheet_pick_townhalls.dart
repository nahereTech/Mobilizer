import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/search/join_organization_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class TownhallBottomSheet extends StatefulWidget {
  TownhallBottomSheet(
      {required this.getDropDownList,
      required this.orgID,
      required this.hasJoined,
      Key? key})
      : super(key: key);
  final List<DropData> getDropDownList;
  final String orgID;
  final Function(bool, String) hasJoined;
  @override
  _TownhallBottomSheetState createState() => _TownhallBottomSheetState();
}

class _TownhallBottomSheetState extends State<TownhallBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic> _dropdownData = {'dropdown': []};
  List<List<DropdownMenuItem<int>>> _dropdownItems = [];
  List<int?> _selectedValues = [];
  List<bool> _requiredFields = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      print("Bot: " + widget.getDropDownList[0].level_list![0].name);
      if (widget.getDropDownList.isNotEmpty) {
        final dropdownList = widget.getDropDownList;

        setState(() {
          _dropdownItems = _buildDropdownItemsList(dropdownList);
          _selectedValues = dropdownList.map<int?>((levelData) {
            final selectedId = levelData.selected;
            // Ensure selectedId exists in the dropdown items list
            final itemExists = _dropdownItems
                .any((items) => items.any((item) => item.value == selectedId));
            return itemExists ? selectedId : null;
          }).toList();

          _requiredFields = dropdownList.map<bool>((levelData) {
            return levelData.required ?? false;
          }).toList();

          _isLoading = false;
        });
      } else {
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
            setState(() {
              // Update the dropdown items for the next level
              if (level < _dropdownItems.length - 1) {
                _dropdownItems[level + 1] = [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('-- Select --'),
                  ),
                  ...dataList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          item['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ];

                // Reset the selected value for the updated level and below
                for (int i = level + 1; i < _selectedValues.length; i++) {
                  _selectedValues[i] = null;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  List<List<DropdownMenuItem<int>>> _buildDropdownItemsList(
      List<DropData> dropdownList) {
    return dropdownList.map<List<DropdownMenuItem<int>>>((levelData) {
      List<DropdownMenuItem<int>> items = [
        DropdownMenuItem<int>(
          value: null,
          child: Text('-- Select --'),
        ),
      ];

      if (levelData.level_list != null && levelData.level_list!.isNotEmpty) {
        items.addAll(levelData.level_list!.map<DropdownMenuItem<int>>((item) {
          return DropdownMenuItem<int>(
            value: item.id,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList());
      } else {
        print(
            "Level list is empty or null for DropData with id: ${levelData.id}");
      }

      return items;
    }).toList();
  }

  void _handleDropdownChange(int level, int? value) {
    if (_selectedValues[level] != value) {
      setState(() {
        _selectedValues[level] = value;

        // Clear all dropdowns below the changed one
        for (int i = level + 1; i < _selectedValues.length; i++) {
          _selectedValues[i] = null;
        }

        // Reset the items for all dropdowns below the changed one
        for (int i = level + 1; i < _dropdownItems.length; i++) {
          _dropdownItems[i] = [
            DropdownMenuItem<int>(
              value: null,
              child: Text('-- Select --'),
            ),
          ];
        }

        // Fetch and update the next level if it exists and a value is selected
        if (value != null && level < _dropdownItems.length - 1) {
          _fetchChildren(value, level);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    if (_formKey.currentState?.validate() ?? false) {
      final url = '${domainName}/api/townhall/join_org';
      final selectedTownhalls = _selectedValues.whereType<int>().toList();
      print("Before: ${selectedTownhalls} ${widget.orgID}");
      if (mounted) {
        setState(() {
          _isSubmitting = true;
        });
      }
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token.toString(),
          },
          body: jsonEncode({
            'org_id': widget.orgID,
            'townhalls': selectedTownhalls,
            'with_townhalls': true
          }),
        );
        final resp = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (resp['status'] == 200) {
            debugPrint("Resp2: ${response.body}");
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Successful',
                  style: TextStyle(color: Colors.white),
                )));
            Navigator.of(context).pop(); // Close the bottom sheet
            widget.hasJoined(true, widget.orgID);
          } else {
            debugPrint("${resp['msg']}");
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }

            Fluttertoast.showToast(
              msg: "${resp['msg']}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP, // Display at the top
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            widget.hasJoined(false, widget.orgID);
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
            gravity: ToastGravity.TOP, // Display at the top
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          widget.hasJoined(false, widget.orgID);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));

        Fluttertoast.showToast(
          msg: "${e}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP, // Display at the top
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        widget.hasJoined(false, widget.orgID);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 5 / 6;

    return Container(
      height: bottomSheetHeight,
      padding: EdgeInsets.symmetric(vertical: 20.0),
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
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Select the townhalls you belong to. Note that townhalls you select here applies to only this organization',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: _isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              children: List.generate(
                                3,
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Container(
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border:
                                          Border.all(color: Colors.grey[400]!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ..._dropdownItems.asMap().entries.map((entry) {
                                int index = entry.key;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: _requiredFields[index] &&
                                                _selectedValues[index] == null
                                            ? Colors.red
                                            : Colors.grey[400]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
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
                                        border: InputBorder.none,
                                      ),
                                      menuMaxHeight: 300,
                                    ),
                                  ),
                                );
                              }).toList(),
                              SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? Container(
                                          width: 50.0,
                                          height: 50.0,
                                          child: SpinKitCircle(
                                            color: Colors.white,
                                            size: 50.0,
                                          ),
                                        )
                                      : Text(
                                          'Join',
                                          style: TextStyle(color: Colors.white),
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
