import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/my_organizations.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart';

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

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  bool _loading = false;
  bool _isDisabling = false;
  bool _isDeleting = false;
  bool _isConfirmingPassword = false;
  bool _obscurePassword = true;
  bool absorbPointer = false;

  String _purpose = "";
  final _controllerPassword = TextEditingController();

  @override
  void dispose() {
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    print('MyAccount - Is Dark Mode (via ThemeProvider): $isDarkMode');

    Size size = MediaQuery.of(context).size;

    Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color subTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey.shade700;
    Color iconColor = isDarkMode ? Colors.grey[400]! : Colors.black54;
    Color overlayColor = isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey.withOpacity(0.5);

    return OverlayLoaderWithAppIcon(
      isLoading: _loading,
      overlayBackgroundColor: overlayColor,
      circularProgressColor: Colors.blue,
      appIconSize: 25,
      appIcon: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset('images/icon_blue.png'),
      ),
      child: AbsorbPointer(
        absorbing: absorbPointer,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: FaIcon(FontAwesomeIcons.arrowLeft, size: 25, color: Colors.blue),
            ),
            backgroundColor: backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Text('My Account', style: TextStyle(color: textColor)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  _buildOptionRow(
                    context: context,
                    icon: Icons.logout_rounded,
                    iconColor: Colors.red,
                    title: 'Logout',
                    description: 'Logout from your account',
                    onTap: _handleLogout,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    size: size,
                  ),
                  SizedBox(height: 20),
                  _buildOptionRow(
                    context: context,
                    icon: Icons.folder_shared_outlined,
                    iconColor: iconColor,
                    title: 'Disable Account',
                    description: 'Temporarily disable your account. Re-enable whenever you choose',
                    onTap: () => _showConfirmationDialog(context, 'disable', 'terminate your account'),
                    textColor: textColor,
                    subTextColor: subTextColor,
                    size: size,
                  ),
                  SizedBox(height: 20),
                  _buildOptionRow(
                    context: context,
                    icon: Icons.people,
                    iconColor: iconColor,
                    title: 'Delete Account',
                    description: 'Start the process of deleting your account and data',
                    onTap: () => _showConfirmationDialog(context, 'delete', 'delete your account'),
                    textColor: textColor,
                    subTextColor: subTextColor,
                    size: size,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color textColor,
    required Color subTextColor,
    required Size size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.05), // Slight background tint for contrast
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: textColor.withOpacity(0.1), // Subtle border
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 42),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 15, color: subTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    setState(() {
      _loading = true;
      absorbPointer = true;
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
        body: json.encode({}), // Add an empty JSON body
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
        _loading = false;
        absorbPointer = false;
      });
    }
  }

  void _showConfirmationDialog(BuildContext context, String tag, String desc) {
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
      desc: "Are you sure you want to $desc?",
      buttons: [
        DialogButton(
          color: Colors.black45,
          child: Text("No", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Colors.blue,
          child: Text("Yes", style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: () {
            Navigator.pop(context);
            _buildConfirmPassword(tag, context, isDarkMode: isDarkMode);
          },
          width: 120,
        ),
      ],
    ).show();
  }

  void _buildConfirmPassword(String tag, BuildContext context, {required bool isDarkMode}) {
    Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color subTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey.shade700;
    Color borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey.withOpacity(0.5);

    Alert(
      closeFunction: () {
        _controllerPassword.text = '';
        Navigator.pop(context);
      },
      context: context,
      style: AlertStyle(
        isButtonVisible: false,
        buttonAreaPadding: EdgeInsets.only(bottom: 10),
        titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
        overlayColor: isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey.withOpacity(0.5),
        backgroundColor: backgroundColor,
      ),
      title: "Password",
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 0, right: 0),
                height: 55,
                child: TextFormField(
                  controller: _controllerPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: subTextColor),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: _obscurePassword
                          ? Icon(Icons.visibility_off, color: subTextColor)
                          : Icon(Icons.visibility, color: subTextColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.blue.withOpacity(0.2),
                  backgroundColor: Colors.blue,
                  fixedSize: Size(282, 43),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isDeleting || _isDisabling || _isConfirmingPassword
                    ? SpinKitWave(color: Colors.white.withOpacity(0.5), size: 15.0)
                    : Text("Submit", style: TextStyle(color: Colors.white, fontSize: 14)),
                onPressed: _isDeleting || _isConfirmingPassword || _isDisabling
                    ? null
                    : () => _handlePasswordSubmit(tag, context),
              ),
            ],
          );
        }),
      ),
    ).show();
  }

  void _handlePasswordSubmit(String tag, BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_controllerPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password cannot be empty', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _loading = true;
        absorbPointer = true;
        _purpose = tag;
        if (tag == "delete") {
          _isDeleting = true;
        } else {
          _isDisabling = true;
        }
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _loading = false;
          _isDeleting = false;
          _isDisabling = false;
          _controllerPassword.text = '';
        });
        Navigator.pop(context);
        final displayMsg = _purpose == "delete"
            ? "Account was successfully deleted"
            : "Account was successfully disabled";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(displayMsg, style: TextStyle(color: Colors.white)),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
        _purpose = "";
      });
    }
  }
}