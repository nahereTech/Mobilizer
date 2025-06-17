import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobilizer/common/common/constants.dart';
import 'package:flutter/services.dart';
import 'package:mobilizer/pages/onboarding/onboarding_join_orgs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/onboarding/onboarding_world_townhalls.dart'; // Import the existing OnboardingWorldTownhalls
import 'package:country_code_picker/country_code_picker.dart';
// 1. Add rflutter_alert import for the confirmation dialog
import 'package:rflutter_alert/rflutter_alert.dart';
// 2. Add LoginScreen import for navigation after logout
import 'package:mobilizer/pages/login/login.dart';
// 3. Add provider and ThemeProvider imports for consistent theming

import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart';

// 8. Add SharedPreference class to manage token
class SharedPreference {
  static const _tokenKey = 'token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

class Profile extends StatefulWidget {
  static String routeName = 'profile';

  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Controllers for text fields
  final _controllerUserName = TextEditingController();
  final _controllerFirstName = TextEditingController();
  final _controllerLastName = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerAbout = TextEditingController();
  final _controllerGender = TextEditingController();
  final _controllerUserProfessionCategory = TextEditingController();
  final _controllerUserProfession = TextEditingController();
  final _controllerEmail = TextEditingController();

  bool _isUsernameEditable = false;
  String? _initialUsername; // To store the initial username value

  // Focus nodes for DOB dropdowns
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Image handling
  final picker = ImagePicker();
  File? _image;
  String profileImage =
      "https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid";

  // DOB variables
  String selectedY = 'Year';
  String selectedM = 'Month';
  String selectedD = 'Day';
  bool _isYFocused = false;
  bool _isMFocused = false;
  bool _isDFocused = false;

  // Loading state
  bool _isLoading = true;
  List<Map<String, dynamic>> professionCategories = [];

  // API configuration
  String? token;

  String? selectedProfessionCategoryId;

   String? selectedCountryCode = '+1'; // Default country code

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() => setState(() => _isYFocused = _focusNode1.hasFocus));
    _focusNode2.addListener(() => setState(() => _isMFocused = _focusNode2.hasFocus));
    _focusNode3.addListener(() => setState(() => _isDFocused = _focusNode3.hasFocus));
    _initializeData();
  }

  // Future<void> _initializeData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  //   final savedProfilePhoto = prefs.getString('profile_photo');
  //   if (savedProfilePhoto != null) {
  //     setState(() {
  //       profileImage = savedProfilePhoto;
  //     });
  //   }
    
  //   await _fetchProfessionCategories();
  //   await _fetchProfileData();
  // }


  


  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final savedProfilePhoto = prefs.getString('profile_photo');
    // Fetch and print current_org from SharedPreferences
    final currentOrg = prefs.getString('current_org');
    print("This is the SP-SP: $currentOrg");
    if (savedProfilePhoto != null) {
      setState(() {
        profileImage = savedProfilePhoto;
      });
    }

    try {
      await _fetchProfessionCategories();
    } catch (e) {
      print('Error fetching profession categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profession categories: $e')),
      );
    }

    try {
      await _fetchProfileData();
    } catch (e) {
      print('Error fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ensure loader stops
      });
    }
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _controllerUserName.dispose();
    _controllerFirstName.dispose();
    _controllerLastName.dispose();
    _controllerPhone.dispose();
    _controllerAbout.dispose();
    _controllerGender.dispose();
    _controllerUserProfessionCategory.dispose();
    _controllerUserProfession.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    if (token == null) {
      print('No token found, enabling username field and clearing email');
      setState(() {
        _isLoading = false;
        _isUsernameEditable = true;
        _controllerEmail.text = '';
        _controllerUserName.text = '';
        _initialUsername = '';
      });
      return;
    }

    try {
      print('Fetching profile data with token: $token');
      final response = await http.get(
        Uri.parse('$base_url/profile/fetch_user_profile_2'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!,
        },
      );

      print('Profile fetch response: ${response.statusCode} - ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == true) {
          print('Profile fetched successfully, email: ${data['data']['email']}');
          setState(() {
            _initialUsername = data['data']['username'] ?? '';
            _controllerUserName.text = _initialUsername!;
            _isUsernameEditable = _initialUsername!.isEmpty;
            print('Setting _isUsernameEditable to $_isUsernameEditable');

            _controllerFirstName.text = data['data']['firstname'] ?? '';
            _controllerLastName.text = data['data']['lastname'] ?? '';
            _controllerPhone.text = data['data']['phone'] ?? '';
            _controllerAbout.text = data['data']['about_me'] ?? '';
            _controllerGender.text = data['data']['gender'] ?? '';
            _controllerUserProfession.text = data['data']['profession'] ?? '';
            _controllerEmail.text = data['data']['email'] ?? ''; // Set email
            print('Setting email controller to: ${_controllerEmail.text}');
            profileImage = data['data']['pics'] ?? profileImage;

            selectedProfessionCategoryId = data['data']['profession_category']?.toString();
            if (selectedProfessionCategoryId != null && professionCategories.isNotEmpty) {
              final selectedCategory = professionCategories.firstWhere(
                (category) => category['id'].toString() == selectedProfessionCategoryId,
                orElse: () => {'name': ''},
              );
              _controllerUserProfessionCategory.text = selectedCategory['name'] ?? '';
            } else {
              _controllerUserProfessionCategory.text = '';
            }

            if (data['data']['dob'] != null && data['data']['dob'] != "0000-00-00") {
              try {
                final dob = DateTime.parse(data['data']['dob']);
                selectedY = dob.year.toString();
                selectedM = dob.month.toString().padLeft(2, '0');
                selectedD = dob.day.toString().padLeft(2, '0');
              } catch (e) {
                print('Error parsing DOB: $e');
                selectedY = 'Year';
                selectedM = 'Month';
                selectedD = 'Day';
              }
            } else {
              selectedY = 'Year';
              selectedM = 'Month';
              selectedD = 'Day';
            }

            _isLoading = false;
          });
        } else if (data['status'] == 401 && data['msg'] == 'No Existing Profile') {
          print('No existing profile, enabling username field');
          print('Email from API (data.email): ${data['email']}');
          print('Email from API (data.data.email): ${data['data']['email']}');
          setState(() {
            _initialUsername = '';
            _isUsernameEditable = true;
            _controllerEmail.text = data['data']['email'] ?? data['email'] ?? ''; // Fallback to data['email']
            print('Setting email controller to: ${_controllerEmail.text}');
            _controllerUserName.text = '';
            _controllerFirstName.text = '';
            _controllerLastName.text = '';
            _controllerPhone.text = '';
            _controllerAbout.text = '';
            _controllerGender.text = '';
            _controllerUserProfession.text = '';
            _controllerUserProfessionCategory.text = '';
            selectedProfessionCategoryId = null;
            selectedY = 'Year';
            selectedM = 'Month';
            selectedD = 'Day';
            profileImage = "https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/90b1661f-f2a7-47eb-414f-c7e79ceacd00/mid";
            _isLoading = false;
          });
        } else {
          print('Unexpected response body: ${data['status']} - ${data['msg']}');
          setState(() {
            _isLoading = false;
            _isUsernameEditable = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: ${data['msg'] ?? 'Unknown error'}')),
          );
        }
      } else {
        print('Unexpected HTTP status: ${response.statusCode} - ${data['msg']}');
        setState(() {
          _isLoading = false;
          _isUsernameEditable = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${data['msg'] ?? response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error in _fetchProfileData: $e');
      setState(() {
        _isLoading = false;
        _isUsernameEditable = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  Future<void> _fetchProfessionCategories() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${base_url}profile/profession_categories'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          setState(() {
            professionCategories = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profession categories: $e')),
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_image == null || token == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$base_url/profile/upload_users_profile_picture'),
      );
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': token!,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'fileName',
          _image!.path,
        ),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        setState(() {
          profileImage = data['data']['photo_path_mid'];
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_photo', data['data']['photo_path_mid']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } else {
        throw Exception(data['msg'] ?? 'Failed to upload image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile picture: $e')),
      );
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
      
      setState(() => _isLoading = true);
      
      await _uploadProfilePicture();
      
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dob = '$selectedY-$selectedM-$selectedD';
      final response = await http.post(
        Uri.parse('$base_url/profile/update_profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!,
        },
        body: jsonEncode({
          'firstname': _controllerFirstName.text,
          'lastname': _controllerLastName.text,
          'phone': _controllerPhone.text,
          'country_phone_code': selectedCountryCode ?? '+1',
          'gender': _controllerGender.text,
          'dob': dob,
          'profession_category': selectedProfessionCategoryId,
          'profession_description': _controllerUserProfession.text,
          'username': _controllerUserName.text,
          'about': _controllerAbout.text
          
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        // Check if initial username was empty
        if (_initialUsername == null || _initialUsername!.isEmpty) {
          // Redirect to OnboardingWorldTownhalls
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingWorldTownhalls()),
            // MaterialPageRoute(builder: (context) => const OnboardingJoinOrg()),
           
          );
        } else {
          // Show success bottom sheet as before
          _showSuccessBottomSheet();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['msg'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.green,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Profile updated successfully!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Controllers (define them in your state)
  final TextEditingController _controllerYear = TextEditingController();
  final TextEditingController _controllerMonth = TextEditingController();
  final TextEditingController _controllerDay = TextEditingController();

  // Dialog functions
  void _showYearDialog() async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Year'),
        children: _getYears().map((val) {
          return SimpleDialogOption(
            child: Text(val),
            onPressed: () => Navigator.pop(context, val),
          );
        }).toList(),
      ),
    );
    if (selected != null) setState(() => _controllerYear.text = selected);
  }

  void _showMonthDialog() async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Month'),
        children: _getMonths().map((val) {
          return SimpleDialogOption(
            child: Text(val),
            onPressed: () => Navigator.pop(context, val),
          );
        }).toList(),
      ),
    );
    if (selected != null) setState(() => _controllerMonth.text = selected);
  }

  void _showDayDialog() async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Day'),
        children: _getDays().map((val) {
          return SimpleDialogOption(
            child: Text(val),
            onPressed: () => Navigator.pop(context, val),
          );
        }).toList(),
      ),
    );
    if (selected != null) setState(() => _controllerDay.text = selected);
  }


  // 4. Add logout method adapted from MyAccount
  void _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String? token = await SharedPreference.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('${base_url}user/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 200) {
        await SharedPreference.clearToken();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              responseData['msg'] ?? "Logged out successfully",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        throw Exception(responseData['msg'] ?? 'Logout failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Logout failed: ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // 5. Add logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;

    Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color subTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey.shade700;
    Color overlayColor = isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey.withOpacity(0.5);

    Alert(
      context: context,
      style: AlertStyle(
        titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
        descStyle: TextStyle(color: subTextColor),
        overlayColor: overlayColor,
        backgroundColor: backgroundColor,
      ),
      title: "Confirm",
      desc: "Are you sure you want to exit this page? You will be logged out",
      buttons: [
        DialogButton(
          color: Colors.black45,
          child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Colors.blue,
          child: Text("Yes", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () {
            Navigator.pop(context);
            _handleLogout();
          },
          width: 120,
        ),
      ],
    ).show();
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0), // Adjust the value as needed
          child: Text('Profile...'),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : NetworkImage(profileImage) as ImageProvider,
                            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            color: Colors.white,
                            onPressed: getImage,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader(context, 'Bio'),
                    TextFormField(
                      controller: _controllerUserName,
                      decoration: _inputDecoration('Username').copyWith(
                        hintText: _isUsernameEditable ? 'Enter your username' : 'Username (cannot be changed)',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.grey[600],
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isUsernameEditable
                                ? (isDarkMode ? Colors.white70 : Colors.grey[400]!)
                                : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      readOnly: !_isUsernameEditable,
                      enabled: _isUsernameEditable, // Explicitly enable/disable the field
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(25),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        if (value.contains(' ')) {
                          return 'Spaces are not allowed';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Only letters and numbers allowed';
                        }
                        if (value.length > 25) {
                          return 'Maximum 25 characters allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerFirstName,
                      decoration: _inputDecoration('First Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter first name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerLastName,
                      decoration: _inputDecoration('Last Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter last name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerAbout,
                      decoration: _inputDecoration('About Me'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Please enter about me' : null,
                    ),
                    const SizedBox(height: 16),
                    // TextFormField(
                    //   controller: _controllerGender,
                    //   decoration: _inputDecoration('Gender'),
                    //   readOnly: true,
                    //   onTap: () => _showGenderDialog(),
                    //   validator: (value) => value!.isEmpty ? 'Please select gender' : null,
                    // ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerGender,
                      decoration: _inputDecoration('Gender'),
                      readOnly: true,
                      onTap: () => _showGenderDialog(),
                      validator: (value) => value!.isEmpty ? 'Please select gender' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controllerYear,
                            decoration: _inputDecoration('Year'),
                            readOnly: true,
                            onTap: () => _showYearDialog(),
                            validator: (value) => value!.isEmpty ? 'Please select year' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerMonth,
                            decoration: _inputDecoration('Month'),
                            readOnly: true,
                            onTap: () => _showMonthDialog(),
                            validator: (value) => value!.isEmpty ? 'Please select month' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _controllerDay,
                            decoration: _inputDecoration('Day'),
                            readOnly: true,
                            onTap: () => _showDayDialog(),
                            validator: (value) => value!.isEmpty ? 'Please select day' : null,
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Contact Information'),
                    Row(
                      children: [
                        // Country Code Picker
                        Expanded(
                          flex: 2,
                          child: CountryCodePicker(
                            onChanged: (code) {
                              setState(() {
                                selectedCountryCode = code.dialCode ?? '+1';
                              });
                            },
                            initialSelection: '+1',
                            favorite: ['+1', '+44', '+234'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Phone Number Input
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _controllerPhone,
                            decoration: _inputDecoration('Phone Number'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              } else if (!RegExp(r'^\d{7,15}$').hasMatch(value)) {
                                return 'Enter a valid number (7-15 digits)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerEmail,
                      decoration: _inputDecoration('Email'),
                      readOnly: true,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Profession'),
                    TextFormField(
                      controller: _controllerUserProfessionCategory,
                      decoration: _inputDecoration('Profession Category'),
                      readOnly: true,
                      onTap: () => _showProfessionCategoryDialog(),
                      validator: (value) => value!.isEmpty ? 'Please select profession category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllerUserProfession,
                      decoration: _inputDecoration('Describe Your Profession'),
                      validator: (value) => value!.isEmpty ? 'Please describe profession' : null,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Update Profile', style: TextStyle(fontSize: 22)),
                    ),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.grey[600],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white70 : Colors.grey[400]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white70 : Colors.grey[400]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white : Colors.blue,
        ),
      ),
    );
  }

  List<String> _getYears() =>
      ['Year'] + List.generate(100, (index) => (2023 - index).toString());
    List<String> _getMonths() => ['Month'] + List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    List<String> _getDays() {
    int? year = int.tryParse(_controllerYear.text);
    int? month = int.tryParse(_controllerMonth.text);
    
    if (year != null && month != null) {
      int lastDay = DateTime(year, month + 1, 0).day; // 💡 Get last day of the month
      return List.generate(lastDay, (index) => '${index + 1}');
    }
    
    // Default to 31 days if year/month not selected yet
    return List.generate(31, (index) => '${index + 1}');
  }


  void _showGenderDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Gender'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['Male', 'Female', 'Others']
            .map((gender) => SimpleDialogOption(
                  onPressed: () {
                    _controllerGender.text = gender;
                    Navigator.pop(context);
                  },
                  child: Text(gender),
                ))
            .toList(),
      ),
    );
  }

  void _showProfessionCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return SimpleDialog(
          title: Text(
            'Profession Category',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          children: professionCategories
              .map((prof) => SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        _controllerUserProfessionCategory.text = prof['name'];
                        selectedProfessionCategoryId = prof['id'].toString();
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      prof['name'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

void main() {
  // 7. Wrap MaterialApp in MultiProvider to provide ThemeProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        home: const Profile(),
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            titleLarge: TextStyle(fontSize: 20),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[900],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            titleLarge: TextStyle(fontSize: 20, color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        themeMode: ThemeMode.system,
      ),
    ),
  );
}