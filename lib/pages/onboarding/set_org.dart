import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../splash/splash_screen.dart';
import 'package:mobilizer/common/common/constants.dart'; // Import your base_url

class SetOrgPage extends StatefulWidget {
  const SetOrgPage({super.key});

  @override
  State<SetOrgPage> createState() => _SetOrgPageState();
}

class _SetOrgPageState extends State<SetOrgPage> {
  List<Map<String, dynamic>> _orgs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrgs();
  }

  Future<void> _fetchOrgs() async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/mobilizer/orgs'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          setState(() {
            _orgs = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          _showError(data['msg']);
        }
      } else {
        _showError('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching organizations: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setSelectedOrg(Map<String, dynamic> org) async {
    
    final prefs = await SharedPreferences.getInstance();
    
    // Store values in SharedPreferences
    await prefs.setInt('current_org', org['id']);
    await prefs.setString('presentation_org_logo', org['logo']);
    await prefs.setString('presentation_org_bg', org['bg']);
    await prefs.setString('org_name', org['name']);
    await prefs.setString('presentation_org_slide_1', org['slide_1'] ?? '');
    await prefs.setString('presentation_org_slide_2', org['slide_2'] ?? '');
    await prefs.setString('presentation_org_slide_3', org['slide_3'] ?? '');
    await prefs.setString('presentation_org_slide_1_title', org['slide_1_title'] ?? '');
    await prefs.setString('presentation_org_slide_2_title', org['slide_2_title'] ?? '');
    await prefs.setString('presentation_org_slide_3_title', org['slide_3_title'] ?? '');
    await prefs.setString('presentation_org_slide_1_desc', org['slide_1_desc'] ?? '');
    await prefs.setString('presentation_org_slide_2_desc', org['slide_2_desc'] ?? '');
    await prefs.setString('presentation_org_slide_3_desc', org['slide_3_desc'] ?? '');

    // Print values to console for inspection
    print('SharedPreferences set:');
    print('current_org: ${org['id']}');
    print('presentation_org_logo: ${org['logo']}');
    print('presentation_org_bg: ${org['bg']}');
    print('org_name: ${org['name']}');
    print('presentation_org_slide_1: ${org['slide_1'] ?? ''}');
    print('presentation_org_slide_2: ${org['slide_2'] ?? ''}');
    print('presentation_org_slide_3: ${org['slide_3'] ?? ''}');
    print('presentation_org_slide_1_title: ${org['slide_1_title'] ?? ''}');
    print('presentation_org_slide_2_title: ${org['slide_2_title'] ?? ''}');
    print('presentation_org_slide_3_title: ${org['slide_3_title'] ?? ''}');
    print('presentation_org_slide_1_desc: ${org['slide_1_desc'] ?? ''}');
    print('presentation_org_slide_2_desc: ${org['slide_2_desc'] ?? ''}');
    print('presentation_org_slide_3_desc: ${org['slide_3_desc'] ?? ''}');

    // Navigate to FeedOutsidePage after selection
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Organization'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _orgs.length,
                itemBuilder: (context, index) {
                  final org = _orgs[index];
                  return GestureDetector(
                    onTap: () => _setSelectedOrg(org),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(org['logo']),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            org['name'],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}