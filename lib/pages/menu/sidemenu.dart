// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'theme_provider.dart';  // Update this path based on your project structure
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class MenuWidget extends StatefulWidget {
//   const MenuWidget({Key? key}) : super(key: key);

//   @override
//   State<MenuWidget> createState() => _MenuWidgetState();
// }

// class _MenuWidgetState extends State<MenuWidget> {
//   Future<Map<String, String?>> _fetchUserData() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? profilePic = prefs.getString('profile_pic');
//     final String? firstName = prefs.getString('firstname');
//     final String? lastName = prefs.getString('lastname');
//     return {
//       'profilePic': profilePic,
//       'firstName': firstName,
//       'lastName': lastName,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) {
//         final themeProvider = Provider.of<ThemeProvider>(context);
        
//         return Drawer(
//           child: FutureBuilder<Map<String, String?>>(
//             future: _fetchUserData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return const Center(child: Text('Error loading user data'));
//               } else {
//                 final userData = snapshot.data!;
//                 return Column(
//                   children: [
//                     DrawerHeader(
//                       decoration: BoxDecoration(
//                         color: themeProvider.isDarkMode
//                             ? Theme.of(context).scaffoldBackgroundColor
//                             : const Color.fromARGB(255, 20, 30, 146),
//                       ),
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               // Navigate to ProfilePage
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => ProfilePage()),
//                               );
//                             },
//                             child: CircleAvatar(
//                               backgroundImage: userData['profilePic'] != null
//                                   ? NetworkImage(userData['profilePic']!)
//                                   : const AssetImage('assets/default_profile.png') as ImageProvider,
//                               radius: 40,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Clickable Name (First Name + Last Name)
//                                 GestureDetector(
//                                   onTap: () {
//                                     // Navigate to ProfilePage
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (context) => ProfilePage()),
//                                     );
//                                   },
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         userData['firstName'] ?? '',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       Text(
//                                         userData['lastName'] ?? '',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Add space before Plan: Free
//                                 const SizedBox(height: 8), // Adjust the height for desired spacing
//                                 // Clickable Plan: Free
//                                 GestureDetector(
//                                   onTap: () {
//                                     // Navigate to PlansPage
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (context) => UserPlan2()),
//                                     );
//                                   },
//                                   child: const Text(
//                                     "Plan: Free",
//                                     style: TextStyle(
//                                       color: Colors.white70, // Slightly lighter for distinction
//                                       fontSize: 14,
//                                       // decoration: TextDecoration.underline, // Optional: underline to indicate clickable
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView(
//                         padding: EdgeInsets.zero,
//                         children: [
//                           ListTile(
//                             leading: const Icon(Icons.checklist_rounded),
//                             title: const Text('Tasks'),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const MyTasksPage()),
//                               );
//                             },
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.change_circle_outlined),
//                             title: const Text('Protocols'),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const ProtocolsPage()),
//                               );
//                             },
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.folder_outlined),
//                             title: const Text('Projects'),
//                             onTap: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ProjectsPage()),
//                               );
//                             },
//                           ),
//                           // ListTile(
//                           //   leading: const Icon(Icons.message_outlined),
//                           //   title: const Text('Messages'),
//                           //   onTap: () {
//                           //     Navigator.pop(context);
//                           //     Navigator.push(
//                           //       context,
//                           //       MaterialPageRoute(
//                           //           // builder: (context) => MessagesPage()),
//                           //           builder: (context) => BannerAdWidget()),
//                           //     );
//                           //   },
//                           // ),
//                           // ListTile(
//                           //   leading: const Icon(Icons.card_giftcard),
//                           //   title: const Text('Rewards'),
//                           //   onTap: () {
//                           //     Navigator.pop(context);
//                           //     Navigator.push(
//                           //       context,
//                           //       MaterialPageRoute(
//                           //           builder: (context) => RewardsPage()),
//                           //     );
//                           //   },
//                           // ),
//                           Container(
//                             margin: EdgeInsets.symmetric(horizontal: 14.0),
//                             child: Divider(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                        decoration: BoxDecoration(
//                         border: Border(
//                           top: BorderSide(
//                             // Change color based on theme
//                             color: themeProvider.isDarkMode 
//                                 ? Colors.grey.shade800 // Darker grey for dark mode
//                                 : Colors.grey.shade300, // Lighter grey for light mode
//                             width: 1.0,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: ListTile(
//                               leading: const Icon(Icons.settings),
//                               title: const Text('Settings'),
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => SettingsPage()),
//                                 );
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 16.0),
//                             child: IconButton(
//                               icon: Icon(
//                                 themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                                 color: themeProvider.isDarkMode ? Colors.white : Colors.black,
//                               ),
//                               onPressed: () {
//                                 themeProvider.toggleTheme();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }
//             },
//           ),
//         );
//       }
//     );
//   }
// }