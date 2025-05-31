import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileOnboarding extends StatefulWidget {
  static String routeName = 'profile';

  const ProfileOnboarding({Key? key}) : super(key: key);

  @override
  _ProfileOnboardingState createState() => _ProfileOnboardingState();
}

class _ProfileOnboardingState extends State<ProfileOnboarding> {
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
  final _controllerCountry = TextEditingController();
  final _controllerState = TextEditingController();
  final _controllerLocalArea = TextEditingController();
  final _controllerWard = TextEditingController();
  final _controllerPolling = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() => setState(() => _isYFocused = _focusNode1.hasFocus));
    _focusNode2.addListener(() => setState(() => _isMFocused = _focusNode2.hasFocus));
    _focusNode3.addListener(() => setState(() => _isDFocused = _focusNode3.hasFocus));
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
    _controllerCountry.dispose();
    _controllerState.dispose();
    _controllerLocalArea.dispose();
    _controllerWard.dispose();
    _controllerPolling.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Avatar
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

                // Personal Information Section
                _buildSectionHeader(context, 'Bio'),
                TextFormField(
                  controller: _controllerUserName,
                  decoration: _inputDecoration('Username'),
                  validator: (value) => value!.isEmpty ? 'Please enter username' : null,
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
                      child: DropdownButtonFormField<String>(
                        focusNode: _focusNode1,
                        value: selectedY,
                        decoration: _inputDecoration('Year'),
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        items: _getYears().map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (value) => setState(() => selectedY = value!),
                        validator: (value) => value == 'Year' ? 'Please select year' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        focusNode: _focusNode2,
                        value: selectedM,
                        decoration: _inputDecoration('Month'),
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        items: _getMonths().map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (value) => setState(() => selectedM = value!),
                        validator: (value) => value == 'Month' ? 'Please select month' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        focusNode: _focusNode3,
                        value: selectedD,
                        decoration: _inputDecoration('Day'),
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        items: _getDays().map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (value) => setState(() => selectedD = value!),
                        validator: (value) => value == 'Day' ? 'Please select day' : null,
                      ),
                    ),
                  ],
                ),

                // Contact Information Section
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Contact Information'),
                TextFormField(
                  controller: _controllerPhone,
                  decoration: _inputDecoration('Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerEmail,
                  decoration: _inputDecoration('Email'),
                  readOnly: true,
                ),

                // Profession Section
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

                // Location Section
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Location'),
                TextFormField(
                  controller: _controllerCountry,
                  decoration: _inputDecoration('Country of Residence'),
                  readOnly: true,
                  onTap: () => _showCountryDialog(),
                  validator: (value) => value!.isEmpty ? 'Please select country' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerState,
                  decoration: _inputDecoration('State of Residence'),
                  readOnly: true,
                  onTap: () => _showStateDialog(),
                  validator: (value) => value!.isEmpty ? 'Please select state' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerLocalArea,
                  decoration: _inputDecoration('LGA of Residence'),
                  readOnly: true,
                  onTap: () => _showLgaDialog(),
                  validator: (value) => value!.isEmpty ? 'Please select LGA' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerWard,
                  decoration: _inputDecoration('Ward of Residence'),
                  readOnly: true,
                  onTap: () => _showWardDialog(),
                  validator: (value) => value!.isEmpty ? 'Please select ward' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllerPolling,
                  decoration: _inputDecoration('My Polling Unit'),
                  readOnly: true,
                  onTap: () => _showPollingDialog(),
                  validator: (value) => value!.isEmpty ? 'Please select polling unit' : null,
                ),

                // Submit Button
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update Profile', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create section headers
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

  // Helper method for consistent InputDecoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Helper methods for dropdowns and dialogs
  List<String> _getYears() =>
      ['Year'] + List.generate(100, (index) => (2023 - index).toString());
  List<String> _getMonths() => ['Month'] + List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _getDays() => ['Day'] + List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Profession Category'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['IT', 'Healthcare', 'Education']
            .map((prof) => SimpleDialogOption(
                  onPressed: () {
                    _controllerUserProfessionCategory.text = prof;
                    Navigator.pop(context);
                  },
                  child: Text(prof),
                ))
            .toList(),
      ),
    );
  }

  void _showCountryDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Country of Residence'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['USA', 'Canada', 'Nigeria']
            .map((country) => SimpleDialogOption(
                  onPressed: () {
                    _controllerCountry.text = country;
                    Navigator.pop(context);
                  },
                  child: Text(country),
                ))
            .toList(),
      ),
    );
  }

  void _showStateDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('State of Residence'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['State 1', 'State 2', 'State 3']
            .map((state) => SimpleDialogOption(
                  onPressed: () {
                    _controllerState.text = state;
                    Navigator.pop(context);
                  },
                  child: Text(state),
                ))
            .toList(),
      ),
    );
  }

  void _showLgaDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('LGA of Residence'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['LGA 1', 'LGA 2', 'LGA 3']
            .map((lga) => SimpleDialogOption(
                  onPressed: () {
                    _controllerLocalArea.text = lga;
                    Navigator.pop(context);
                  },
                  child: Text(lga),
                ))
            .toList(),
      ),
    );
  }

  void _showWardDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Ward of Residence'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['Ward 1', 'Ward 2', 'Ward 3']
            .map((ward) => SimpleDialogOption(
                  onPressed: () {
                    _controllerWard.text = ward;
                    Navigator.pop(context);
                  },
                  child: Text(ward),
                ))
            .toList(),
      ),
    );
  }

  void _showPollingDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('My Polling Unit'),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        children: ['Unit 1', 'Unit 2', 'Unit 3']
            .map((unit) => SimpleDialogOption(
                  onPressed: () {
                    _controllerPolling.text = unit;
                    Navigator.pop(context);
                  },
                  child: Text(unit),
                ))
            .toList(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const ProfileOnboarding(),
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
  ));
}