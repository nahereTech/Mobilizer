import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobilizer/bloc/posts/posts_bloc.dart';
import 'package:mobilizer/bloc/search/organization_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/models/organization/default_available_twh_response.dart';
import 'package:mobilizer/models/organization/default_postable_twh_response.dart';
import 'package:mobilizer/models/organization/my_organization_response.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/foundation.dart';

// Flag to show snack bars for debugging purposes
const showSnackBar = false;
const expandChildrenOnReady = true;

// Maps to store node data
final Map<String, String> nodeNames = {};
final Map<String, int> nodeLevels = {};
final Map<String, String> nodeWhoCanPost = {};
final Map<String, int> nodeParents = {};
final Map<String, String> nodeActives = {};
final Map<String, int> nodeTownhallID = {};
final Map<String, String> nodeWhocanPost = {};

TreeNode? sampleTree;

class OrganizationEdit extends StatefulWidget {
  // Constructor parameters to pass organization data
  final String orgId;
  final String? picture;
  final String? orgBg;
  final String? orgName;
  final String? username;
  final String? orgAbout;
  final VoidCallback? onSuccess; // Callback for successful update
  final Function(String)? onError; // Callback for error handling

  const OrganizationEdit({
    Key? key,
    required this.orgId,
    this.picture,
    this.orgBg,
    this.orgName,
    this.username,
    this.orgAbout,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  _OrganizationEditState createState() => _OrganizationEditState();
}

class _OrganizationEditState extends State<OrganizationEdit> {
  bool _isDeleting = false;
  bool _isConfirmingPassword = false;
  bool _obscurePassword = true;
  bool absorbPointer = false;
  bool _requiresConfirmation = false;
  bool _isPrivate = false;
  bool _isInviteOnly = false;
  bool _isSubmitting = false;
  bool _isApplyToLevel = false;
  bool _isChanged = false;
  bool _isDataLoaded = false;
  bool _isSwitchOn = true;

  List<Postable> postableList = [];
  List<Available> availableList = [];

  String? _selectedOrgType;
  String? _selectedPlan;
  String _whoCanPost = 'everyone';
  String? _orgPlan;
  String? _networkLogoUrl;
  String? _networkBannerUrl;
  String dynamicExp = "";

  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _orgDescriptionController = TextEditingController();
  final _usernameController = TextEditingController();
  final _controllerPassword = TextEditingController();
  final Map<String, int> lastChildNumber = {'root': 0};
  TreeViewController? _treeController;

  File? _selectedImage;
  File? _selectedBannerImage;

  Future<List<dynamic>>? _plansFuture;

  final List<Color> levelColors = [
    Colors.deepPurple[100]!,
    Colors.orange[200]!,
    Colors.teal[300]!,
    Colors.amber[400]!,
    Colors.cyan[500]!,
  ];

  @override
  void initState() {
    super.initState();

    // Initialize data from constructor parameters
    _plansFuture = fetchPlans();
    if (sampleTree != null) {
      sampleTree!.clear();
    }
    setState(() {
      _networkLogoUrl = widget.picture;
      _networkBannerUrl = widget.orgBg;
      _orgNameController.text = widget.orgName ?? '';
      _usernameController.text = widget.username ?? '';
      dynamicExp = widget.username ?? '';
      _orgDescriptionController.text = widget.orgAbout ?? '';
      _isDataLoaded = true;
    });

    // Fetch organization details
    fetchOrgDetails().then((data) {
      if (data['status'] == 200) {
        setState(() {
          var orgData = data['data'];
          _orgNameController.text = orgData['org_name'];
          _orgDescriptionController.text = orgData['org_details'];

          for (var townhall in orgData['available_townhalls']) {
            availableList.add(
              Available(
                townhall['name'],
                townhall['pic'],
                townhall['is_checked'] == "yes",
                townhall['circle_reduction_percentage'],
              ),
            );
          }

          for (var townhall in orgData['postable_townhalls']) {
            postableList.add(
              Postable(
                townhall['name'],
                townhall['pic'],
                townhall['is_checked'] == "yes",
                townhall['circle_reduction_percentage'],
              ),
            );
          }

          _requiresConfirmation = orgData['requires_confirmation'] == 'yes';
          _isInviteOnly = orgData['invite_only'] == 'yes';
          _isPrivate = orgData['org_privacy'] == 'close';
          _selectedOrgType = orgData['org_structure'].toString();
          _isSwitchOn = orgData['org_status'] == 'yes';
          _orgPlan = orgData['org_plan'].toString();
          _selectedPlan = _orgPlan;

          if (orgData['org_structure'] == 3) {
            List<dynamic> parsedJson = orgData['townhall_tree'];
            Map<String, dynamic> rootJson = parsedJson.first;
            sampleTree = populateTreeFromJson(rootJson);
          }
        });

        _plansFuture?.then((plans) {
          setState(() {
            _selectedPlan = plans.any((plan) => plan['plan_id'] == _orgPlan)
                ? plans.firstWhere((plan) => plan['plan_id'] == _orgPlan)['plan_id'].toString()
                : null;
          });
        });
      }
    }).catchError((error) {
      print('Error fetching organization details: $error');
      widget.onError?.call('Failed to load organization details.');
    });
  }

  TreeNode populateTreeFromJson(Map<String, dynamic> jsonNode) {
    String key = jsonNode['key'];
    String name = jsonNode['name'];
    int parent = jsonNode['parent_id'];
    String active = jsonNode['active'];
    String whoCanPost = jsonNode['who_can_post'];
    int townhallID = jsonNode['id'];

    TreeNode node = TreeNode(key: key);
    nodeNames[key] = name;
    nodeParents[key] = parent;
    nodeActives[key] = active;
    nodeWhoCanPost[key] = whoCanPost;
    nodeTownhallID[key] = townhallID;
    lastChildNumber[key] = 0;

    if (jsonNode['children'] != null && jsonNode['children'] is List) {
      List<dynamic> childrenList = jsonNode['children'];
      for (var child in childrenList) {
        node.add(populateTreeFromJson(child));
      }
    }

    return node;
  }

  int _getTownhallIndex(String name) {
    final List<String> townhallLabels = ['pu', 'ward', 'lga', 'state', 'country', 'global'];
    return townhallLabels.indexOf(name.toLowerCase());
  }

  void _checkForChanges(bool ex) {
    setState(() {
      _isChanged = _isDataLoaded && ex ? true : false;
    });
  }

  Future<List<dynamic>> fetchPlans() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    await Future.delayed(Duration(seconds: 2));
    final response = await http.get(
      Uri.parse('${domainName}/api/orgs/org_plans_2?currency=&frequency=monthly'),
      headers: {'Authorization': '$authToken'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Future<Map<String, dynamic>> fetchOrgDetails() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse('${domainName}/api/orgs/fetch_org_details?org_id=${widget.orgId}'),
      headers: {'Authorization': '$authToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load organization details');
    }
  }

  Future<void> _editOrganization() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _isSubmitting = true;
        });
        final authToken = await AppSharedPreferences.getValue(key: 'token');
        Map<String, dynamic> data = {
          'org_id': widget.orgId,
          'org_name': _orgNameController.text,
          'org_desc': _orgDescriptionController.text,
          'org_url': _usernameController.text,
          'requires_confirmation': _requiresConfirmation.toString(),
          'invite_only': _isInviteOnly.toString(),
          'org_privacy': _isPrivate.toString(),
          'org_structure': _selectedOrgType ?? '',
          'org_plan': _selectedPlan ?? '',
          'active_status': _isSwitchOn.toString(),
        };

        if (_selectedOrgType == '2') {
          data['available_townhalls'] =
              jsonEncode(availableList.map((available) => available.toJson()).toList());
          data['postable_townhalls'] =
              jsonEncode(postableList.map((postable) => postable.toJson()).toList());
        } else if (_selectedOrgType == '3') {
          data['townhall_tree'] = json.encode([_serializeTree(sampleTree)]);
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${domainName}/api/orgs/update_org_bulktree'),
        );

        request.headers['Authorization'] = '$authToken';
        data.forEach((key, value) {
          request.fields[key] = value;
        });

        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'org_pic',
            _selectedImage!.path,
          ));
        }

        if (_selectedBannerImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'org_bg',
            _selectedBannerImage!.path,
          ));
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        var responseData = jsonDecode(response.body);

        if (responseData['status'] == 200) {
          setState(() {
            _isSubmitting = false;
          });
          _showSuccessDialog();
        } else {
          setState(() {
            _isSubmitting = false;
          });
          _showErrorDialog('Failed to update organization. Please try again.');
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Organization updated successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                widget.onSuccess?.call();
                Navigator.of(context).pop();
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
                widget.onError?.call(message);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _networkLogoUrl = null;
      });
      _checkForChanges(true);
    }
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedBannerImage = File(pickedFile.path);
        _networkBannerUrl = null;
      });
      _checkForChanges(true);
    }
  }

  Map<String, dynamic> _serializeTree(dynamic node, {int level = 1}) {
    if (node is TreeNode) {
      nodeLevels[node.key] = level;
      return {
        'key': node.key,
        'name': nodeNames[node.key] ?? node.key,
        'level': level,
        'who_can_post': nodeWhoCanPost[node.key] ?? 'everyone',
        'id': nodeTownhallID[node.key] ?? 0,
        'parent_id': nodeParents[node.key] ?? 0,
        'active': nodeActives[node.key] ?? 'yes',
        'children': node.children.values
            .map((child) => _serializeTree(child, level: level + 1))
            .toList(),
      };
    } else {
      throw ArgumentError('Invalid node type: expected TreeNode.');
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
                        ...snapshot.data!.map((plan) => _buildPlanSection(plan)).toList(),
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
                    value: 'leaders',
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
                setState(() {
                  nodeWhoCanPost[node.key] = _whoCanPost;
                });
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
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitConfirmationDialog(context);
        return shouldPop;
      },
      child: OverlayLoaderWithAppIcon(
        isLoading: _isDeleting,
        overlayBackgroundColor: Colors.grey,
        circularProgressColor: Colors.blue,
        appIconSize: 25,
        appIcon: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset('images/icon_blue.png'),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickBannerImage,
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
                              : _networkBannerUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_networkBannerUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _selectedBannerImage == null && _networkBannerUrl == null
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
                        onPressed: _pickBannerImage,
                      ),
                    ),
                    Positioned(
                      bottom: -60,
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
                                  : _networkLogoUrl != null
                                      ? NetworkImage(_networkLogoUrl!) as ImageProvider
                                      : AssetImage('images/icon_blue.png') as ImageProvider,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: _pickImage,
                          ),
                        ],
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
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _orgNameController,
                          decoration: InputDecoration(
                            labelText: 'Organization Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.all(16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the organization name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _checkForChanges(true);
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
                          onChanged: (value) {
                            _checkForChanges(true);
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          readOnly: true,
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username (@username)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.all(16.0),
                            counterText: '',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                          ],
                          maxLength: 30,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the organization username';
                            } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Username can only contain letters, numbers, and underscores';
                            } else if (value.length > 30) {
                              return 'Username cannot exceed 30 characters';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _checkForChanges(true);
                          },
                        ),
                        if (dynamicExp != "") Text("${domainName}/$dynamicExp"),
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
                            _checkForChanges(true);
                          },
                        ),
                        SizedBox(height: 20),
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
                            _checkForChanges(true);
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
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: 'Organizations based on specific geographic locations.\n',
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
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: 'Customizable organizational structure.\n',
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
                            _checkForChanges(true);
                            if (_selectedOrgType == "3" && sampleTree == null) {
                              List<dynamic> parsedJson = [
                                {
                                  "id": 0,
                                  "name": "Head Office",
                                  "level": 1,
                                  "parent_id": 0,
                                  "key": "root",
                                  "who_can_post": "Everyone",
                                  "active": "yes",
                                  "children": []
                                }
                              ];
                              Map<String, dynamic> rootJson = parsedJson.first;
                              sampleTree = populateTreeFromJson(rootJson);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an organization type';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
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
                                child: Wrap(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 175,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: availableList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final available = availableList[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 70,
                                                  width: 90,
                                                  child: CircleAvatar(
                                                    radius: 30.0 -
                                                        (30.0 * available.circle_reduction_percentage / 100) -
                                                        3.0,
                                                    backgroundColor: Colors.grey,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(50.0),
                                                      child: Image.network(
                                                        available.pic.toString(),
                                                        width: 55.0 -
                                                            (55 * available.circle_reduction_percentage / 100),
                                                        height: 55.0 -
                                                            (55 * available.circle_reduction_percentage / 100),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 4.0, right: 4.0, left: 4.0, bottom: 0.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${available.name}',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Transform.scale(
                                                            scale: 1.3,
                                                            child: Checkbox(
                                                              value: availableList[index].is_checked,
                                                              onChanged: (value) {
                                                                _checkForChanges(true);
                                                                setState(() {
                                                                  availableList[index].is_checked =
                                                                      !availableList[index].is_checked;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
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
                                child: Wrap(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 175,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: postableList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final postable = postableList[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 70,
                                                  width: 90,
                                                  child: CircleAvatar(
                                                    radius: 30.0 -
                                                        (30.0 * postable.circle_reduction_percentage / 100) -
                                                        3.0,
                                                    backgroundColor: Colors.grey,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(50.0),
                                                      child: Image.network(
                                                        postable.pic.toString(),
                                                        width: 55.0 -
                                                            (55 * postable.circle_reduction_percentage / 100),
                                                        height: 55.0 -
                                                            (55 * postable.circle_reduction_percentage / 100),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 4.0, right: 4.0, left: 4.0, bottom: 0.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${postable.name}',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Transform.scale(
                                                            scale: 1.3,
                                                            child: Checkbox(
                                                              value: postableList[index].is_checked,
                                                              onChanged: availableList[index].is_checked
                                                                  ? (value) {
                                                                      _checkForChanges(true);
                                                                      setState(() {
                                                                        postableList[index].is_checked =
                                                                            !postableList[index].is_checked;
                                                                      });
                                                                    }
                                                                  : null,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
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
                                      "Create your own hierarchy of townhalls within your organization.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              sampleTree != null && _selectedOrgType == '3'
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      height: 400.0,
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
                                              tree: sampleTree!,
                                              showRootNode: true,
                                              expansionIndicatorBuilder: (context, node) =>
                                                  ChevronIndicator.rightDown(
                                                tree: node,
                                                color: Colors.blue[700],
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              indentation: const Indentation(style: IndentStyle.roundJoint),
                                              onItemTap: (item) {
                                                if (kDebugMode) print("Item tapped: ${item.key}");
                                              },
                                              onTreeReady: (controller) {
                                                _treeController = controller;
                                                if (expandChildrenOnReady)
                                                  controller.expandAllChildren(sampleTree!);
                                              },
                                              builder: (context, node) => Card(
                                                color: _getColorForLevel(node.level + 1),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: ListTile(
                                                          title: Text(_getNodeName(node.key)),
                                                          subtitle: Row(
                                                            children: [
                                                              Text('Level ${node.level + 1}'),
                                                              SizedBox(width: 5),
                                                              Icon(
                                                                nodeWhoCanPost[node.key] == 'everyone'
                                                                    ? Icons.person
                                                                    : Icons.person_outline,
                                                                size: 18,
                                                                color: nodeWhoCanPost[node.key] == 'everyone'
                                                                    ? Colors.green
                                                                    : Colors.blue,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      PopupMenuButton<String>(
                                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                                        onSelected: (String value) {
                                                          switch (value) {
                                                            case 'Rename':
                                                              _renameNode(node);
                                                              break;
                                                            case 'Delete':
                                                              _deleteNode(node);
                                                              break;
                                                            case 'Delete All Children':
                                                              _confirmDelete('Delete All Children', node);
                                                              break;
                                                            case 'Add Sub-townhall':
                                                              _addTownhall(node);
                                                              break;
                                                            case 'Who Can Post?':
                                                              _showWhoCanPostDialog(node);
                                                              setState(() {
                                                                _whoCanPost = nodeWhoCanPost[node.key].toString();
                                                              });
                                                              break;
                                                          }
                                                        },
                                                        itemBuilder: (BuildContext context) {
                                                          return [
                                                            PopupMenuItem(
                                                              value: 'Rename',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.edit),
                                                                  SizedBox(width: 5),
                                                                  Text('Rename Townhall'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Delete',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.delete),
                                                                  SizedBox(width: 5),
                                                                  Text('Delete Townhall'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Delete All Children',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.delete),
                                                                  SizedBox(width: 5),
                                                                  Text('Delete All Children'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Add Sub-townhall',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.add),
                                                                  SizedBox(width: 5),
                                                                  Text('Add Sub-townhall'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Who Can Post?',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.person),
                                                                  SizedBox(width: 5),
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
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(height: sampleTree != null && _selectedOrgType == '3' ? 20 : 0),
                            ],
                          ),
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
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No plans available');
                            } else {
                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedPlan,
                                decoration: InputDecoration(
                                  labelText: 'Pick Plan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: EdgeInsets.all(16.0),
                                ),
                                hint: Text('--Select plan--'),
                                items: snapshot.data!.map<DropdownMenuItem<String>>((plan) {
                                  String displayText =
                                      "${plan['plan_name']} (${plan['currency']}${plan['plan_cost']}/user/month)";
                                  return DropdownMenuItem<String>(
                                    value: plan['plan_id'].toString(),
                                    child: Text(
                                      displayText,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _checkForChanges(true);
                                  setState(() {
                                    _selectedPlan = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
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
                              text: 'Active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
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
                          value: _isSwitchOn,
                          onChanged: (bool value) {
                            _checkForChanges(true);
                            setState(() {
                              _isSwitchOn = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    await _editOrganization();
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
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            _buildConfirmPassword(context);
                          },
                          child: Text(
                            "Delete organization",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.red,
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
        ),
      ),
    );
  }

  Color _getColorForLevel(int level) {
    return levelColors[(level - 1) % levelColors.length];
  }

  String _getNodeName(String key) {
    return nodeNames[key] ?? key;
  }

  int _getParentID(String key) {
    return nodeParents[key] ?? 0;
  }

  String _getNodeActive(String key) {
    return nodeActives[key] ?? key;
  }

  void _renameNode(TreeNode node) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController(text: _getNodeName(node.key));
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
                  nodeNames[node.key] = controller.text;
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
      lastChildNumber.remove(node.key);
    });
  }

  void _buildConfirmPassword(BuildContext cont) {
    Alert(
      onWillPopActive: _isDeleting ? true : false,
      closeFunction: () {
        _controllerPassword.text = '';
        Navigator.pop(context);
      },
      context: context,
      style: AlertStyle(
        isButtonVisible: false,
        buttonAreaPadding: EdgeInsets.only(bottom: 10),
        titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        overlayColor: Colors.black54,
      ),
      title: "Delete?",
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              Text(
                "Are you sure you want to delete? Deleting this organization will wipe off everything in this organization.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 0, right: 0),
                height: 55,
                child: TextFormField(
                  controller: _controllerPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? Icon(Icons.visibility_off, color: Colors.grey)
                          : Icon(Icons.visibility, color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.blue.withOpacity(0.2),
                  backgroundColor: Colors.blue,
                  fixedSize: Size(282, 43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isDeleting || _isConfirmingPassword
                    ? SpinKitWave(
                        color: Colors.white.withOpacity(0.5),
                        size: 15.0,
                      )
                    : Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                onPressed: _isDeleting || _isConfirmingPassword
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        if (_controllerPassword.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password cannot be empty')),
                          );
                        } else {
                          Navigator.pop(context);
                          await _deleteOrg(widget.orgId, _controllerPassword.text);
                        }
                      },
              ),
              SizedBox(height: 20),
            ],
          );
        }),
      ),
    ).show();
  }

  void _deleteAllChildren(TreeNode node) {
    setState(() {
      node.children.values.toList().forEach((child) {
        node.remove(child);
        nodeNames.remove(child.key);
        lastChildNumber.remove(child.key);
      });
      lastChildNumber[node.key] = 0;
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
        overlayColor: Colors.black54,
      ),
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
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: Size(282, 43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _deleteAllChildren(node);
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 20),
            ],
          );
        }),
      ),
    ).show();
  }

  void _addTownhall(TreeNode node) {
    setState(() {
      lastChildNumber[node.key] ??= 0;
      String newKey;
      do {
        lastChildNumber[node.key] = lastChildNumber[node.key]! + 1;
        newKey = '${node.key}_Child_${lastChildNumber[node.key]}';
      } while (nodeNames.containsKey(newKey));

      final newNode = TreeNode(key: newKey);
      node.add(newNode);
      nodeNames[newKey] = 'New Townhall';
      nodeParents[newKey] = _getParentID(node.key);
      lastChildNumber[newKey] = 0;
    });
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return _isChanged == false
        ? true
        : await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Exit"),
                content: Text("Do you really want to exit? Changes made haven't been updated"),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _isChanged = false;
                        });
                      }
                      Navigator.of(context).pop(false);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("Yes, Exit"),
                  ),
                ],
              ),
            ) ??
            false;
  }

  Future<void> _deleteOrg(String orgID, String password) async {
    try {
      setState(() {
        _isDeleting = true;
      });
      final authToken = await AppSharedPreferences.getValue(key: 'token');
      Map<String, String> data = {'org_id': orgID, 'password': password};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${domainName}/api/orgs/delete_org'),
      );
      request.headers['Authorization'] = '$authToken';
      data.forEach((key, value) {
        request.fields[key] = value;
      });
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        setState(() {
          _isDeleting = false;
        });
        widget.onSuccess?.call();
      } else {
        setState(() {
          _isDeleting = false;
        });
        _showErrorDialog('${responseData['msg']}');
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      _showErrorDialog('An error occurred. Please try again.');
    }
  }
}

class Postable {
  String name;
  String pic;
  bool is_checked;
  int circle_reduction_percentage;
  Postable(this.name, this.pic, this.is_checked, this.circle_reduction_percentage);
  Map<String, dynamic> toJson() => {
        'name': name,
        'pic': pic,
        'is_checked': is_checked,
        'circle_reduction_percentage': circle_reduction_percentage,
      };
}

class Available {
  String name;
  String pic;
  bool is_checked;
  int circle_reduction_percentage;
  Available(this.name, this.pic, this.is_checked, this.circle_reduction_percentage);
  Map<String, dynamic> toJson() => {
        'name': name,
        'pic': pic,
        'is_checked': is_checked,
        'circle_reduction_percentage': circle_reduction_percentage,
      };
}