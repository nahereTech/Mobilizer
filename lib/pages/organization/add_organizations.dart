import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/organization/default_available_twh_response.dart';
import 'package:mobilizer/models/organization/default_postable_twh_response.dart';
import 'package:mobilizer/pages/feed/feed.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/foundation.dart';

// Flag to show snack bars for debugging purposes
const showSnackBar = false;
const expandChildrenOnReady = true;

// Create a map to store names for nodes
// Create a map to store names, levels, and who_can_post for nodes ####here
final Map<String, String> nodeNames = {}; // Map to store node names ####here
final Map<String, int> nodeLevels = {}; // Map to store node levels ####here
final Map<String, String> nodeWhoCanPost =
    {}; // Map to store who_can_post ####here
final Map<String, bool> nodeApplyToLevel = {};
// Sample tree initialization with only the root node
final sampleTree = TreeNode(key: "root");

class AddOrganization extends StatefulWidget {
  static String routeName = 'add_organization_screen';
  _AddOrganizationState createState() => _AddOrganizationState();
}

class _AddOrganizationState extends State<AddOrganization> {
  final _formKey = GlobalKey<FormState>();
  bool _requiresConfirmation = false;
  bool _isPrivate = false;
  bool _isInviteOnly = false;
  bool _isApplyToLevel = false;
  String? _selectedOrgType;
  String? _selectedPlanID;
  String dynamicExp = "";
  Map<String, dynamic>? _selectedPlan;
  final _orgNameController = TextEditingController();
  final _orgDescriptionController = TextEditingController();
  final _usernameController = TextEditingController();
  final Map<String, int> lastChildNumber = {'root': 0};
  bool _isSwitchOn = true; // Initial state of the switch
  bool _isSubmitting = false;

  // State for image picker and image files
  File? _selectedImage;
  File? _selectedBannerImage;
  final ImagePicker _picker = ImagePicker();

  // State for checkboxes in "Available Townhalls"
  List<bool> isCheckedAvailable = List.generate(6, (index) => false);

  // State for checkboxes in "Postable Townhalls"
  List<bool> isCheckedPostable = List.generate(6, (index) => false);

  Future<List<dynamic>>? _plansFuture;
  TreeViewController? _treeController;

  String _whoCanPost = 'everyone'; // New state variable

  // Define a list of distinct colors to be used for different levels
  final List<Color> levelColors = [
    Colors.deepPurple[100]!, // Level 1
    Colors.orange[200]!, // Level 2
    Colors.teal[300]!, // Level 3
    Colors.amber[400]!, // Level 4
    Colors.cyan[500]!, // Level 5
  ];
  List<PostableData> postableData = [];
  List<AvailableData> availableData = [];

  @override
  void initState() {
    super.initState();
    _plansFuture = fetchPlans();
    _fetchPostable();
    _fetchAvailable();
    // Initialize the tree
    nodeNames.clear();
    sampleTree.children.values.toList().forEach(sampleTree.remove);
    nodeNames['root'] = 'Head Office'; // Set a name for the root node
    nodeLevels['root'] = 1; // Set level for root node ####here
    nodeWhoCanPost['root'] =
        'Everyone'; // Default who_can_post for root node ####here
    nodeApplyToLevel['root'] = false;
  }

  Future<List<dynamic>> fetchPlans() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');

    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    final response = await http.get(
      Uri.parse(
          '${domainName}/api/orgs/org_plans_2?currency=&frequency=monthly'),
      headers: {
        'Authorization': '$authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Future<void> _fetchPostable() async {
    print("Am here");
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse('${domainName}/api/orgs/default_postable_twh'),
      headers: {
        'Authorization': '$authToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map && jsonData.containsKey('data')) {
        final dataList = jsonData['data'];
        if (dataList is List) {
          postableData.addAll(
              dataList.map((json) => PostableData.fromJson(json)).toList());
          print("PostableList ${postableData[0].name}");
        }
        //return jsonData['data'];
      } else {
        throw Exception('Failed to load postable townhall');
      }
    }
  }

  Future<void> _fetchAvailable() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse('${domainName}/api/orgs/default_available_twh'),
      headers: {
        'Authorization': '$authToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map && jsonData.containsKey('data')) {
        final dataList = jsonData['data'];
        if (dataList is List) {
          availableData.addAll(
              dataList.map((json) => AvailableData.fromJson(json)).toList());
          print("AvailableList ${availableData[0].name}");
        }
        //return jsonData['data'];
      } else {
        throw Exception('Failed to load available townhall');
      }
    }
  }

  Future<void> _createOrganization() async {
    // print("Sample: ${_serializeTree(sampleTree)}");
    //print("WhoCanPost: ${nodeWhoCanPost}");
    // print("Level: ${nodeLevels}");
    if (_formKey.currentState?.validate() ?? false) {
      // Prepare the form data
      Map<String, String> data = {
        'org_name': _orgNameController.text,
        'org_desc': _orgDescriptionController.text,
        'org_url': _usernameController.text,
        'requires_confirmation': _requiresConfirmation.toString(),
        'invite_only': _isInviteOnly.toString(),
        'org_privacy': _isPrivate.toString(),
        'org_plan': _selectedPlanID ?? '',
        'structure_type': _selectedOrgType.toString(),
        'active_status': _isSwitchOn.toString()
      };
      print("MapD: $data");

      if (_selectedOrgType == '2') {
        if (availableData.isNotEmpty) {
          data['available_townhalls'] = json.encode(
              availableData.map((available) => available.toJson()).toList());
        }
        if (postableData.isNotEmpty) {
          data['postable_townhalls'] = json.encode(
              postableData.map((postable) => postable.toJson()).toList());
        }
      }
      if (_selectedOrgType == '3') {
        // Serialize the tree
        var treeData = _serializeTree(sampleTree);

        // Ensure we create a list containing the serialized tree as an array
        List<dynamic> treeArray = [treeData]; // Wrap the map in a list
        // print("TreeData: ${treeData}");
        // Encode the array as JSON
        data['townhall_tree'] = json.encode(treeArray);
        //print("Townhalltree: ${data['townhall_tree']}");
      }

      try {
        // Create a multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${domainName}/api/orgs/create_org_bulktree'),
        );
        // Add form fields
        data.forEach((key, value) {
          request.fields[key] = value;
        });

        // Add the avatar image file if available
        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'org_pic', // The name of the field in the form
            _selectedImage!.path,
          ));
        }

        // Add the banner image file if available
        if (_selectedBannerImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'org_bg', // The name of the field in the form
            _selectedBannerImage!.path,
          ));
        }
        // Log the request details (fields, headers, files)
        print("---- Request Details ----");
        print("Fields: ${request.fields}"); // Form fields
        print("Headers: ${request.headers}"); // Headers including Authorization

        final authToken = await AppSharedPreferences.getValue(key: 'token');
        request.headers['Authorization'] = '$authToken';
        // Send the request
        var streamedResponse = await request.send();

        // Handle the response
        if (streamedResponse.statusCode == 200) {
          setState(() {
            _isSubmitting = false;
          });
          var response = await http.Response.fromStream(streamedResponse);
          var responseData = json.decode(response.body);
          if (responseData['status'] == 200) {
            _showSuccessDialog();

            print("Message: ${responseData['msg']}");
            print("OPOP: ${responseData['opop']}");
            _clearFeedCache();
            // Future.delayed(Duration(seconds: 5), () {
            //   Navigator.push(context, MaterialPageRoute(builder: (context) {
            //     return MultiBlocProvider(providers: [
            //       BlocProvider(create: (context) => PostsBloc()),
            //       BlocProvider(create: (context) => OrganizationBloc()),
            //     ], child: Feed());
            //   }));
            // });
          } else {
            //alert error here
            _showErrorDialog('${responseData['msg']}');
            debugPrint(response.body);
          }
        } else {
          setState(() {
            _isSubmitting = false;
          });
          print("Was here");
          var response = await http.Response.fromStream(streamedResponse);
          var responseData = json.decode(response.body);
          debugPrint(response.body);

          _showErrorDialog(
              'Failed to create organization. Please try again.${responseData['msg']}');
        }
      } on FormatException catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        debugPrint(e.source);
      } catch (e) {
        print("i am here now");
        debugPrint('${e}');
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('$e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Organization created successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MultiBlocProvider(providers: [
                    BlocProvider(create: (context) => PostsBloc()),
                    BlocProvider(create: (context) => OrganizationBloc()),
                  ], child: Feed());
                }));
                // You can add navigation to another page here if needed
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Save the selected image file
      });
    }
  }

  Map<String, dynamic> _serializeTree(dynamic node, {int level = 1}) {
    if (node is TreeNode) {
      // Assign level dynamically based on tree depth
      nodeLevels[node.key] = level;

      return {
        'key': node.key,
        'name': nodeNames[node.key] ?? node.key,
        'level': level, // Use the dynamically calculated level
        'who_can_post':
            nodeWhoCanPost[node.key] ?? 'everyone', // Serialize who_can_post
        'apply_to_level': nodeApplyToLevel[node.key] ?? false,
        'children': node.children.values
            .map((child) => _serializeTree(child, level: level + 1))
            .toList(),
      };
    } else {
      throw ArgumentError('Invalid node type: expected TreeNode.');
    }
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedBannerImage =
            File(pickedFile.path); // Save the selected banner image file
      });
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: FutureBuilder<List<dynamic>>(
                future: _plansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoader();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No plans available'));
                  } else {
                    return ListView(
                      controller: scrollController,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing Plans',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '*/user refers to organization admin\n',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.0),
                        ...snapshot.data!
                            .map((plan) => _buildPlanSection(plan))
                            .toList(),
                        SizedBox(height: 25.0),
                      ],
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showWhoCanPostDialog(TreeNode node) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Who Can Post?'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: Text('Everyone'),
                    value: 'everyone',
                    groupValue: _whoCanPost,
                    onChanged: (String? value) {
                      setState(() {
                        _whoCanPost = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Townhall Leaders'),
                    value: 'Townhall Leaders',
                    groupValue: _whoCanPost,
                    onChanged: (String? value) {
                      setState(() {
                        _whoCanPost = value!;
                      });
                    },
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isApplyToLevel,
                        onChanged: (bool? value) {
                          setState(() {
                            _isApplyToLevel = value!;
                          });
                        },
                      ),
                      Text("Apply to entire level (Level ${node.level + 1})"),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Update'),
              onPressed: () {
                // Here you can update the node or do any other necessary operations
                setState(() {
                  nodeWhoCanPost[node.key] =
                      _whoCanPost; // Update who_can_post ####here
                });
                print(
                    '$nodeWhoCanPost Updated Who Can Post for ${node.key} to: $_whoCanPost');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanSection(Map<String, dynamic> plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10.0, left: 10.0, top: 10, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan['plan_name'],
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '${plan['currency']}${plan['plan_cost']}/user/month',
                style: TextStyle(fontSize: 20.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        ...plan['features'].map<Widget>((feature) {
          return Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              children: [
                Icon(
                  feature['checked'] == 1 ? Icons.check : Icons.close,
                  color: feature['checked'] == 1 ? Colors.green : Colors.red,
                ),
                SizedBox(width: 5.0),
                Text(
                  feature['feature_name'],
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 25.0),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(6, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: double.infinity,
              height: 20.0,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _pickBannerImage, // Handle the edit action here
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: _selectedBannerImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedBannerImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedBannerImage == null
                        ? Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed:
                        _pickBannerImage, // Open the gallery to pick a new banner image
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : AssetImage('images/Townhall_1024_width.png')
                                    as ImageProvider,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed:
                              _pickImage, // Open the gallery to pick a new profile image
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Text(
                    //   'Learn How to Create',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     color: Colors.blue,
                    //     decoration: TextDecoration.underline,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _orgNameController,
                      decoration: InputDecoration(
                        labelText: 'Organization Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9_& ]'))
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the organization name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _orgDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Organization Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      minLines: 2,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the organization description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username (@username)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        counterText:
                            '', // Optionally hide the character counter if you don't want it displayed
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9_]')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Automatically convert text to lowercase
                          return TextEditingValue(
                            text: newValue.text.toLowerCase(),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      maxLength:
                          30, // Sets the maximum number of characters allowed
                      onChanged: (value) {
                        setState(() {
                          dynamicExp = value
                              .toLowerCase(); // update dynamic expression as user types
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the organization username';
                        } else if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                          return 'Username can only contain letters, numbers, and underscores, with no spaces';
                        } else if (value.length > 30) {
                          return 'Username cannot exceed 30 characters';
                        }
                        return null;
                      },
                    ),
                    if (dynamicExp != "") Text("${domainName}/${dynamicExp}"),
                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Members require confirmation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\nUsers who join will need your confirmation before they can be admitted into the organization',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: _requiresConfirmation,
                      onChanged: (bool? value) {
                        setState(() {
                          _requiresConfirmation = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    // CheckboxListTile(
                    //   title: RichText(
                    //     text: TextSpan(
                    //       children: [
                    //         TextSpan(
                    //           text: 'Invite-only Organization',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16.0,
                    //             color: Colors.black,
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text:
                    //               '\nThis setting makes the organization invite-only, requiring an invitation to join.',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.normal,
                    //             fontSize: 14.0,
                    //             color: Colors.grey,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   value: _isInviteOnly,
                    //   onChanged: (bool? value) {
                    //     setState(() {
                    //       _isInviteOnly = value ?? false;
                    //     });
                    //   },
                    // ),
                    // SizedBox(height: 20),
                    CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Private Organization',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\nThis designation ensures that the organization does not appear in search results',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: _isPrivate,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPrivate = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedOrgType,
                      decoration: InputDecoration(
                        labelText: 'Pick Structure Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      hint: Text('--Select structure type--'),
                      items: [
                        DropdownMenuItem(
                          value: '2',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Location-based Structure\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        'Organizations based on specific geographic locations.\n',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '3',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Custom Structure\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        'Customizable organizational structure.\n',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOrgType = newValue;
                        });
                        print("Org structure ${_selectedOrgType}");
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an organization type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    //available townhalls section
                    if (_selectedOrgType == '2')
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Levels',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Townhalls checked here will be available for members to view posts.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(children: [
                                Container(
                                  width: double.infinity,
                                  height: 175,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: availableData.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final available = availableData[index];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                height: 70,
                                                width: 90,
                                                child: Container(
                                                  child: CircleAvatar(
                                                    radius: 30.0 -
                                                        (30.0 *
                                                            available
                                                                .circle_reduction_percentage /
                                                            100) -
                                                        3.0, // Adjust the radius to account for the border width
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      child: Image.network(
                                                        available.pic
                                                            .toString(),
                                                        width: 55.0 -
                                                            (55 *
                                                                available
                                                                    .circle_reduction_percentage /
                                                                100),
                                                        height: 55.0 -
                                                            (55 *
                                                                available
                                                                    .circle_reduction_percentage /
                                                                100),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0,
                                                    right: 4.0,
                                                    left: 4.0,
                                                    bottom: 0.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${available.name}', // Replace with your desired text
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Transform.scale(
                                                          scale: 1.3,
                                                          child: Checkbox(
                                                            value:
                                                                availableData[
                                                                        index]
                                                                    .is_checked,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                availableData[
                                                                            index]
                                                                        .is_checked =
                                                                    !availableData[
                                                                            index]
                                                                        .is_checked;
                                                                if (availableData[
                                                                            index]
                                                                        .is_checked ==
                                                                    false) {
                                                                  postableData[
                                                                          index]
                                                                      .is_checked = false;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ) // Adjust the space between CircleAvatar and Text
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ])),
                          SizedBox(height: 20),
                        ],
                      ),

                    // Postable Townhalls Section
                    if (_selectedOrgType == '2')
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Postable Levels',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Townhalls checked here will allow members to post in them.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(children: [
                                Container(
                                  width: double.infinity,
                                  height: 175,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: postableData.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final postable = postableData[index];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                height: 70,
                                                width: 90,
                                                child: Container(
                                                  child: CircleAvatar(
                                                    radius: 30.0 -
                                                        (30.0 *
                                                            postable
                                                                .circle_reduction_percentage /
                                                            100) -
                                                        3.0, // Adjust the radius to account for the border width
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      child: Image.network(
                                                        postable.pic.toString(),
                                                        width: 55.0 -
                                                            (55 *
                                                                postable
                                                                    .circle_reduction_percentage /
                                                                100),
                                                        height: 55.0 -
                                                            (55 *
                                                                postable
                                                                    .circle_reduction_percentage /
                                                                100),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0,
                                                    right: 4.0,
                                                    left: 4.0,
                                                    bottom: 0.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${postable.name}', // Replace with your desired text
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Transform.scale(
                                                          scale: 1.3,
                                                          child: Checkbox(
                                                            value: postableData[
                                                                    index]
                                                                .is_checked,
                                                            onChanged:
                                                                availableData[
                                                                            index]
                                                                        .is_checked
                                                                    ? (value) {
                                                                        setState(
                                                                            () {
                                                                          postableData[index].is_checked =
                                                                              !postableData[index].is_checked;
                                                                        });
                                                                      }
                                                                    : null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ) // Adjust the space between CircleAvatar and Text
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ])),
                          SizedBox(height: 20),
                        ],
                      ),
                    //end available townhalls

                    // Custom Townhalls Section
                    if (_selectedOrgType == '3')
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Custom Structure',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Create your own hierarchy of townhalls within your organization. You don't have to add all levels now. You can always update this tree later.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 400.0, // Set the height to 300
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: TreeView.simple(
                                    tree: sampleTree,
                                    showRootNode: true, // Show the root node
                                    expansionIndicatorBuilder:
                                        (context, node) =>
                                            ChevronIndicator.rightDown(
                                      tree: node,
                                      color: Colors.blue[700],
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    indentation: const Indentation(
                                        style: IndentStyle.roundJoint),
                                    onItemTap: (item) {
                                      if (kDebugMode)
                                        print("Item tapped: ${item.key}");
                                    },
                                    onTreeReady: (controller) {
                                      _treeController = controller;
                                      if (expandChildrenOnReady)
                                        controller
                                            .expandAllChildren(sampleTree);
                                    },
                                    builder: (context, node) => Card(
                                      color: _getColorForLevel(
                                          node.level + 1), // Adjust level by +1
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ListTile(
                                                title: Text(_getNodeName(node
                                                    .key)), // Display the full name
                                                subtitle: Text(
                                                    'Level ${node.level + 1}'), // Adjust level display by +1
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onSelected: (String value) {
                                                switch (value) {
                                                  case 'Rename':
                                                    _renameNode(node);
                                                    break;
                                                  case 'Delete':
                                                    _deleteNode(node);
                                                    break;
                                                  case 'Hide All Children':
                                                    _hideAllChildren(node);
                                                    break;
                                                  case 'Delete All Children':
                                                    _confirmDelete(
                                                        'Delete All Children',
                                                        node);
                                                    break;
                                                  case 'Add Sub-townhall':
                                                    _addTownhall(node);
                                                    break;
                                                  case 'Who Can Post?':
                                                    _showWhoCanPostDialog(node);
                                                    setState(() {
                                                      _whoCanPost =
                                                          nodeWhoCanPost[
                                                                  node.key]
                                                              .toString();
                                                    });
                                                    break;
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'Rename',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text('Rename Townhall'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'Delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text('Delete Townhall'),
                                                      ],
                                                    ),
                                                  ),
                                                  // PopupMenuItem(value: 'Hide All Children', child: Text('Hide All Children')),
                                                  PopupMenuItem(
                                                    value:
                                                        'Delete All Children',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                            'Delete All Children'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'Add Sub-townhall',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.add),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                            'Add Sub-townhall'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'Who Can Post?',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.person),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text('Who Can Post?'),
                                                      ],
                                                    ),
                                                  ),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // ClipRRect(
                                //   borderRadius: BorderRadius.vertical(
                                //     bottom: Radius.circular(12.0), // Apply the same radius as the parent for bottom corners
                                //   ),
                                //   child: Container(
                                //     width: double.infinity, // This makes the container stretch to full width
                                //     color: Colors.grey[200], // Background color for the strip
                                //     padding: const EdgeInsets.all(8.0),
                                //     child: ElevatedButton(
                                //       onPressed: () {
                                //         // Add your collapse action here
                                //         print('Collapse Tree button pressed');
                                //       },
                                //       child: Text('Collapse Tree'),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    //end custom townhalls section

                    GestureDetector(
                      onTap: () => _showBottomSheet(context),
                      child: Text(
                        'View Plans',
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    FutureBuilder<List<dynamic>>(
                      future: _plansFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('No plans available');
                        } else {
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                                _selectedPlanID, // Set _selectedPlanId to store the plan_id as the value
                            decoration: InputDecoration(
                              labelText: 'Pick Plan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(16.0),
                            ),
                            hint: Text('--Select plan--'),
                            items: snapshot.data!
                                .map<DropdownMenuItem<String>>((plan) {
                              String displayText =
                                  "${plan['plan_name']} (${plan['currency']}${plan['plan_cost']}/user/month)";
                              return DropdownMenuItem<String>(
                                value: plan['plan_id']
                                    .toString(), // Use plan_id as the value
                                child: Text(
                                  displayText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPlanID =
                                    newValue; // Store the selected plan_id
                                // Optionally, find the full plan details from the snapshot to store
                                _selectedPlan = snapshot.data!.firstWhere(
                                    (plan) =>
                                        plan['plan_id'].toString() == newValue);
                              });
                            },

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a plan';
                              }
                              if (_selectedPlanID == null) {
                                return 'Please select a plan';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),

                    SizedBox(height: 20),

                    SwitchListTile(
                      title: Text.rich(
                        TextSpan(
                          text: 'Active', // Main title
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the title bold
                            fontSize:
                                18.0, // You can adjust the font size if needed
                          ),
                        ),
                      ),
                      subtitle: Text(
                        'Uncheck this to deactivate organization till when you are ready',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      value: _isSwitchOn, // Use state variable for value
                      onChanged: (bool value) {
                        setState(() {
                          _isSwitchOn = value; // Update state on switch change
                        });
                      },
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double
                          .infinity, // Set the width to fill the parent container
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                _formKey.currentState?.validate();
                                if (_selectedPlanID != null) {
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                  await _createOrganization();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(159, 46, 100, 201),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: _isSubmitting
                            ? SpinKitWave(
                                color: Colors.grey,
                                size: 15.0,
                              )
                            : Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color:
                                      Colors.white, // Set text color to white
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get a color based on the node's level
  Color _getColorForLevel(int level) {
    // Return a color based on the node's level, or default if the level exceeds the predefined list
    return levelColors[
        (level - 1) % levelColors.length]; // Adjusted for 1-based levels
  }

  // Get the node name from the map, or return a default value
  String _getNodeName(String key) {
    return nodeNames[key] ?? key;
  }

  void _renameNode(TreeNode node) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller =
            TextEditingController(text: _getNodeName(node.key));

        return AlertDialog(
          title: Text('Rename Node'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rename'),
              onPressed: () {
                setState(() {
                  nodeNames[node.key] =
                      controller.text; // Update the name in the map
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteNode(TreeNode node) {
    setState(() {
      node.parent?.remove(node);
      nodeNames.remove(node.key);
      // Remove the last child number for this node
      lastChildNumber.remove(node.key);
      // Note: We don't decrement the parent's lastChildNumber to keep the numbering unique
    });
  }

  void _hideAllChildren(TreeNode node) {
    // Implement hide all children logic here
    // For simplicity, this is just a placeholder
    print('Hide all children of node ${node.key}');
  }

  void _deleteAllChildren(TreeNode node) {
    setState(() {
      node.children.values.toList().forEach((child) {
        node.remove(child);
        nodeNames.remove(child.key);
        // Remove the last child number for each deleted child
        lastChildNumber.remove(child.key);
      });
      // Reset the last child number for this node
      lastChildNumber[node.key] = 0;
    });
  }

  void _clearFeedCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<String> filteredKeys =
        keys.where((key) => key.contains("page_feed_")).toList();
    List<String> filteredTopKeys =
        keys.where((key) => key.contains("page_feed_top_")).toList();
    prefs.setString('orgID', '');
    prefs.setString('orgName', '');
    prefs.setString('groupID', '');
    if (filteredKeys.length > 0) {
      for (var i = 0; i < filteredKeys.length; i++) {
        await AppSharedPreferences.removeValue(key: '${filteredKeys[i]}');
      }
    }
    if (filteredTopKeys.length > 0) {
      for (var i = 0; i < filteredTopKeys.length; i++) {
        await AppSharedPreferences.removeValue(key: '${filteredKeys[i]}');
      }
    }
  }

  void _addTownhall(TreeNode node) {
    setState(() {
      // Get the last child number for this node, or initialize it if it doesn't exist
      lastChildNumber[node.key] ??= 0;
      // Increment the last child number
      lastChildNumber[node.key] = lastChildNumber[node.key]! + 1;

      // Create a new node key using the parent key and the incremented child number
      final newKey = '${node.key}_Child_${lastChildNumber[node.key]}';
      final newNode = TreeNode(key: newKey);
      node.add(newNode);
      nodeNames[newKey] = 'New Townhall';

      // Initialize the last child number for the new node
      lastChildNumber[newKey] = 0;
    });
  }

  void _confirmDelete(String tag, TreeNode node) {
    Alert(
      onWillPopActive: false,
      closeFunction: () {
        Navigator.pop(context);
      },
      context: context,
      style: AlertStyle(
          isButtonVisible: false,
          buttonAreaPadding: EdgeInsets.only(bottom: 10),
          titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          overlayColor: Colors.black54),
      title: "Delete",
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              Text(
                "Are you sure you want to delete ${tag == 'Delete All Children' ? 'all the children' : 'townhall'}?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.blue.withOpacity(0.2),
                  backgroundColor: Colors.blue, // background color
                  fixedSize: Size(282, 43), // button width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  _deleteAllChildren(node);
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          );
        }),
      ),
    ).show();
  }
}

class SelectedPostable {
  String name;
  String pic;
  bool is_checked;

  SelectedPostable(this.name, this.pic, this.is_checked);
}

class SelectedAvailable {
  String name;
  String pic;
  bool is_checked;
  SelectedAvailable(this.name, this.pic, this.is_checked);
}
