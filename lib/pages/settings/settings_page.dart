import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/navigation.dart';
import 'package:mobilizer/common/common/theme_provider.dart'; // Import ThemeProvider
import 'package:mobilizer/pages/login/login.dart';
import 'package:mobilizer/pages/organization/my_organizations.dart';
import 'package:mobilizer/pages/profile/profile.dart';
import 'package:mobilizer/pages/settings/my_account.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loading = false;
  bool absorbPointer = false;
  String _version = '';
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AbsorbPointer(
      absorbing: absorbPointer,
      child: Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 25,
            icon: FaIcon(
              FontAwesomeIcons.arrowLeft,
              size: 25,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: themeProvider.getTheme().appBarTheme.backgroundColor,
          title: Text(
            'Settings',
            style: themeProvider.getTheme().appBarTheme.titleTextStyle,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildSection(
                  icon: Icons.person,
                  title: 'My Profile',
                  subtitle:
                      'View and edit your profile, townhall locations, profession and more.',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()));
                  },
                ),
                const SizedBox(height: 15),

                // Account Section
                _buildSection(
                  icon: Icons.folder_shared_outlined,
                  title: 'My Account',
                  subtitle:
                      'Manage account information, deactivate account, logout.',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyAccount()));
                  },
                ),
                const SizedBox(height: 15),

                // // Advertise Section
                // _buildSection(
                //   icon: Icons.campaign_outlined,
                //   title: 'Advertise',
                //   subtitle: 'Promote your services to millions of users.',
                //   contactInfo: false,
                //   onTap: () {
                //     // Implement Advertise functionality
                //   },
                // ),
                // const SizedBox(height: 15),

                // Donate Section
                _buildSection(
                  icon: Icons.info_outline,
                  title: 'Donate',
                  subtitle: 'To support Townhall, please follow link',
                  onTap: () {
                    // Implement Donate functionality
                  },
                ),
                const SizedBox(height: 15),

                // About Townhall Section
                _buildSection(
                  icon: Icons.info_outline,
                  title: 'About Townhall',
                  subtitle: 'Version: v${_packageInfo.version}',
                  onTap: () {
                    // Implement About functionality
                  },
                ),

                const Spacer(),

                // Dark Mode Toggle Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dark Mode',
                      style: themeProvider.getTheme().textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: Colors.blue,
                      activeTrackColor: Colors.blue.withOpacity(0.5),
                      inactiveThumbColor: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      inactiveTrackColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  // Reusable section builder (dark blue circle for both modes)
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    bool contactInfo = false,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: themeProvider.getTheme().cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 100, 183, 243).withOpacity(0.2), // Dark blue circle for both modes
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: themeProvider.getTheme().iconTheme.color,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: themeProvider.getTheme().textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: themeProvider.getTheme().textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contactInfo) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '+234 808 432 2878',
                          style: themeProvider.getTheme().textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'contact@townhall.mobi',
                          style: themeProvider.getTheme().textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}