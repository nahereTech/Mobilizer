import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/pages/home/home.dart';
import 'package:mobilizer/common/common/theme_provider.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/pages/feed/feed_outside.dart';
import 'package:mobilizer/pages/organization/organization.dart';

// Data class
class Data {
  final int townhall_id;
  final String name;
  final bool? has_children;
  final bool? required;

  Data({
    required this.townhall_id,
    required this.name,
    this.has_children,
    this.required,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      townhall_id: json['id'] ?? -1,
      name: json['name'] ?? '',
      has_children: json['has_children'] ?? false,
      required: json['required'],
    );
  }
}

class UpdateMyTownhall extends StatefulWidget {
  final String orgID;
  final Function(bool) hasUpdated;

  const UpdateMyTownhall({required this.orgID, required this.hasUpdated});

  static String routeName = 'update_my_townhall';

  @override
  _UpdateMyTownhallState createState() => _UpdateMyTownhallState();
}

class _UpdateMyTownhallState extends State<UpdateMyTownhall> {
  bool _showCCFLoader = true;
  bool _isSubmitting = false;
  bool _hasLevel = false;
  bool _showValidationErrors = true; // CHANGED: Always show validation (immediate red highlighting)
  int _widgetPosition = -1;
  double boxHeight = 111.0;
  List<Data> ccfData = [];
  List<Widget> addedWidgets = [];
  List<Map<String, dynamic>> selectedTownhalls = [];
  List<Map<String, dynamic>> dropdownRequirements = [];
  Set<int> invalidPositions = {}; // Track which dropdown positions are invalid
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchInitialCCFData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch initial CCF data using orgID
  Future<void> _fetchInitialCCFData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse('${base_url}townhall/fetch_townhall_children')
        .replace(queryParameters: {'org_id': widget.orgID});

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          final List<dynamic> data = jsonData['data'];
          final bool isRequired = jsonData['required'] ?? false;
          
          if (mounted) {
            setState(() {
              ccfData = data.map((json) => Data.fromJson(json)).toList();
              _showCCFLoader = false;
              _isSubmitting = false;
              boxHeight = 111.0;
              addedWidgets.clear();
              selectedTownhalls.clear();
              dropdownRequirements.clear();
              invalidPositions.clear();
              _widgetPosition = 0;
              
              // Track requirement for this dropdown level
              dropdownRequirements.add({
                'position': _widgetPosition,
                'required': isRequired,
              });
              
              // CHANGED: Start with invalid selection (-1) and mark as invalid if required
              selectedTownhalls.add({
                'position': _widgetPosition,
                'townhallID': -1, // Default to "-- Please Select --"
              });
              
              // CHANGED: Immediately mark as invalid if required
              if (isRequired) {
                invalidPositions.add(_widgetPosition);
              }
              
              addedWidgets.add(_buildDropDownMenu(ccfData, _widgetPosition));
              _hasLevel = ccfData.isNotEmpty ? (ccfData[0].has_children ?? false) : false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _showCCFLoader = false;
              _isSubmitting = false;
            });
          }
          _showError('No townhall data available');
        }
      } else {
        _showError('Failed to fetch initial CCF data: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching initial CCF data: $e');
    }
  }

  // Fetch children CCF data based on selected townhall_id
  Future<void> _fetchCCFChildren(String townhallId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse('${base_url}townhall/fetch_townhall_children')
        .replace(queryParameters: {
      'org_id': widget.orgID,
      'parent_id': townhallId,
    });

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          final List<dynamic> data = jsonData['data'];
          final bool isRequired = jsonData['required'] ?? false;
          
          if (mounted) {
            setState(() {
              ccfData = data.map((json) => Data.fromJson(json)).toList();
              _showCCFLoader = false;
              _isSubmitting = false;
              boxHeight += 58.0;
              _widgetPosition += 1;
              
              // Track requirement for this new dropdown level
              dropdownRequirements.add({
                'position': _widgetPosition,
                'required': isRequired,
              });
              
              // CHANGED: Start with invalid selection and mark as invalid if required
              selectedTownhalls.add({
                'position': _widgetPosition,
                'townhallID': -1, // Default to "-- Please Select --"
              });
              
              // CHANGED: Immediately mark as invalid if required
              if (isRequired) {
                invalidPositions.add(_widgetPosition);
              }
              
              addedWidgets.add(_buildDropDownMenu(ccfData, _widgetPosition));
              _hasLevel = ccfData.isNotEmpty ? (ccfData[0].has_children ?? false) : false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _showCCFLoader = false;
              _isSubmitting = false;
              _hasLevel = false;
            });
          }
        }
      } else {
        _showError('Failed to fetch CCF children: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching CCF children: $e');
    }
  }

  // Check if a specific dropdown position is required
  bool _isPositionRequired(int position) {
    final requirement = dropdownRequirements.firstWhere(
      (req) => req['position'] == position,
      orElse: () => {'required': false},
    );
    return requirement['required'] ?? false;
  }

  // CHANGED: Updated validation to work with immediate highlighting
  void _validateFormFields() {
    Set<int> newInvalidPositions = {};
    
    // Loop through all dropdown widgets to check validation
    for (int i = 0; i < addedWidgets.length; i++) {
      bool isRequired = _isPositionRequired(i);
      if (isRequired) {
        // Find the selected value for this position
        final selection = selectedTownhalls.firstWhere(
          (item) => item['position'] == i,
          orElse: () => {'townhallID': -1},
        );
        
        // If required field has no valid selection, mark as invalid
        if (selection['townhallID'] == -1) {
          newInvalidPositions.add(i);
        }
      }
    }
    
    setState(() {
      invalidPositions = newInvalidPositions;
    });
    
    print('Invalid positions: $invalidPositions');
  }

  // Ensure all dropdown positions are tracked in selectedTownhalls
  void _ensureSelectedTownhalls() {
    for (int i = 0; i < addedWidgets.length; i++) {
      if (!selectedTownhalls.any((item) => item['position'] == i)) {
        selectedTownhalls.add({
          'position': i,
          'townhallID': -1,
        });
      }
    }
  }

  // Handle Update button click with validation
  Future<void> _handleUpdateTownhalls() async {
    // Ensure all dropdowns are represented in selectedTownhalls
    _ensureSelectedTownhalls();

    // Validate form fields and populate invalidPositions
    _validateFormFields();

    // If validation fails, show errors
    if (invalidPositions.isNotEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      
      String errorMessage = invalidPositions.length == 1 
          ? 'Please select a valid option for the highlighted field.'
          : 'Please select valid options for all highlighted fields.';
      
      _showError(errorMessage);
      return;
    }

    // Additional check for empty selections
    if (selectedTownhalls.isEmpty || selectedTownhalls.every((item) => item['townhallID'] == -1)) {
      setState(() {
        _isSubmitting = false;
      });
      _showError('At least one townhall must be selected.');
      return;
    }

    // If validation passes, proceed with submission
    setState(() {
      _isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse('${base_url}townhall/update_joined_org_townhalls');

    Map<String, dynamic> map = {'org_id': widget.orgID};
    selectedTownhalls.sort((a, b) => a['position'].compareTo(b['position']));
    List uniqueTownhallList = removeDuplicate(selectedTownhalls);
    map['townhalls'] = uniqueTownhallList;

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(map),
      );
      print('API Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 200) {
          if (mounted) {
            setState(() {
              _showCCFLoader = false;
              _isSubmitting = false;
            });
            widget.hasUpdated(true);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => FeedOutsidePage()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          String errorMsg = jsonData['msg'] ?? 'Failed to update townhalls';
          if (jsonData['tag'] == 'not_a_member') {
            errorMsg = 'You are not an active member of this organization';
          } else if (jsonData['tag'] == 'error_removing_townhalls') {
            errorMsg = 'Error removing previous townhalls';
          }
          _showError(errorMsg);
        }
      } else {
        _showError('Failed to update townhalls: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error updating townhalls: $e');
    }
  }

  // Show error message
  void _showError(String message) {
    if (mounted) {
      setState(() {
        _showCCFLoader = false;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // CHANGED: Updated to handle immediate validation clearing
  void onChangeAction(int dropdownID) {
    if (mounted) {
      setState(() {
        _widgetPosition = dropdownID;
        // Note: We don't clear validation errors here anymore since we want immediate feedback
        // Validation will be updated when the dropdown value actually changes
      });
    }
  }

  // Remove duplicate townhall IDs
  List removeDuplicate(List<Map<String, dynamic>> townhalls) {
    List uniqueList = [];
    Set<int> seenIds = {};
    for (var element in townhalls) {
      if (element['townhallID'] != -1 && !seenIds.contains(element['townhallID'])) {
        seenIds.add(element['townhallID']);
        uniqueList.add(element['townhallID']);
      }
    }
    return uniqueList;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Update My Townhalls.',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => OrganizationScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Column(
                children: [
                  ListView.builder(
                    itemCount: addedWidgets.length,
                    itemBuilder: (context, index) => addedWidgets[index],
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  if (_showCCFLoader)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SpinKitWave(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.blue,
                        size: 15.0,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 26.0),
                    child: SizedBox(
                      width: 370,
                      child: ElevatedButton(
                        onPressed: _showCCFLoader || _isSubmitting
                            ? null
                            : () {
                                if (mounted) {
                                  setState(() => _isSubmitting = true);
                                }
                                _handleUpdateTownhalls();
                              },
                        child: _isSubmitting
                            ? SpinKitWave(
                                color: Colors.white,
                                size: 15.0,
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
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

  Widget _buildDropDownMenu(List<Data> items, int widgetPosition) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    List<Data?> dropdownItems = List.from(items);
    dropdownItems.insert(0, null); // Insert null for "-- Please Select --" option

    // Ensure the current position is tracked in selectedTownhalls
    if (!selectedTownhalls.any((item) => item['position'] == widgetPosition)) {
      selectedTownhalls.add({
        'position': widgetPosition,
        'townhallID': -1, // Default to invalid
      });
    }

    // Get the current selected townhall ID for this dropdown position
    final currentSelection = selectedTownhalls.firstWhere(
      (item) => item['position'] == widgetPosition,
      orElse: () => {'position': widgetPosition, 'townhallID': -1},
    );

    // Determine the current dropdown value
    Data? currentValue = currentSelection['townhallID'] == -1
        ? null
        : dropdownItems.firstWhere(
            (item) => item != null && item.townhall_id == currentSelection['townhallID'],
            orElse: () => null,
          );

    // CHANGED: Check if this dropdown should be highlighted red (immediate validation)
    bool isRequired = _isPositionRequired(widgetPosition);
    bool hasValidSelection = currentSelection['townhallID'] != -1;
    bool isInvalid = isRequired && !hasValidSelection; // Red if required and no valid selection

    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 390,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          // CHANGED: Red border for required fields with no selection
          color: isInvalid
              ? Colors.red // Red highlighting for required unselected fields
              : themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey,
          width: isInvalid ? 2.0 : 1.0, // Thicker border for invalid fields
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: DropdownButtonFormField<Data?>(
        value: currentValue,
        elevation: 16,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          // CHANGED: Show error text for required fields with no selection
          errorText: isInvalid ? 'This field is required' : null,
        ),
        iconSize: 26,
        hint: Text(
          // Show asterisk (*) for required fields in placeholder text
          isRequired ? "Please Select *" : "Please Select",
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
        ),
        dropdownColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        onChanged: (Data? newValue) {
          onChangeAction(widgetPosition);
          if (mounted) {
            setState(() {
              // Update selected townhall for this position
              selectedTownhalls
                  .removeWhere((item) => item['position'] == widgetPosition);
              selectedTownhalls.add({
                'position': widgetPosition,
                'townhallID': newValue == null ? -1 : newValue.townhall_id,
              });
              
              // CHANGED: Update validation state immediately when selection changes
              if (newValue != null && newValue.townhall_id != -1) {
                // Valid selection - remove from invalid positions
                invalidPositions.remove(widgetPosition);
              } else if (isRequired) {
                // Invalid selection on required field - add to invalid positions
                invalidPositions.add(widgetPosition);
              }
              
              _showCCFLoader = true;
              _hasLevel = newValue?.has_children ?? false;

              // Remove child dropdowns when parent selection changes
              if (addedWidgets.length > widgetPosition + 1) {
                // CHANGED: Also update validation for removed child dropdowns
                Set<int> removedPositions = {};
                for (int i = widgetPosition + 1; i < addedWidgets.length; i++) {
                  removedPositions.add(i);
                }
                invalidPositions.removeWhere((pos) => removedPositions.contains(pos));
                
                addedWidgets.removeRange(widgetPosition + 1, addedWidgets.length);
                selectedTownhalls
                    .removeWhere((item) => item['position'] > widgetPosition);
                dropdownRequirements
                    .removeWhere((req) => req['position'] > widgetPosition);
                boxHeight = 111.0 + (widgetPosition * 58.0);
              }
            });

            // Fetch child options if selected item has children
            if (newValue != null && newValue.townhall_id != -1 && (newValue.has_children ?? false)) {
              _fetchCCFChildren(newValue.townhall_id.toString());
            } else {
              setState(() {
                _showCCFLoader = false;
                _hasLevel = false;
              });
            }
          }
        },
        items: dropdownItems.map<DropdownMenuItem<Data?>>((Data? value) {
          return DropdownMenuItem<Data?>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    // Show "-- Please Select --" for null value, otherwise show townhall name
                    value == null ? '-- Please Select --' : value.name,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}