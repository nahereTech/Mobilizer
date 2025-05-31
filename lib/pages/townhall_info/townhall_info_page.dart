import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobilizer/common/common/theme_provider.dart'; // Assuming you have this for theme support

class TownhallInfoPage extends StatefulWidget {
  final int townhallId;
  final String townhallName;

  const TownhallInfoPage({
    Key? key,
    required this.townhallId,
    required this.townhallName,
  }) : super(key: key);

  @override
  _TownhallInfoPageState createState() => _TownhallInfoPageState();
}

class _TownhallInfoPageState extends State<TownhallInfoPage> {
  bool _isLoading = true;
  Map<String, dynamic> _townhallDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchTownhallDetails();
  }

  // Simulated API call to fetch more details about the townhall
  Future<void> _fetchTownhallDetails() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock data for demonstration
      setState(() {
        _townhallDetails = {
          'description': 'This is a vibrant community focused on mobilization and action.',
          'memberCount': 1500,
          'createdDate': '2023-01-15',
          'imageUrl': 'https://example.com/townhall-image.jpg',
          'rules': [
            'Be respectful to all members',
            'No spam or self-promotion',
            'Follow community guidelines'
          ],
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching townhall details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
        title: Text(
          widget.townhallName,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: _townhallDetails['imageUrl'] != null
                          ? DecorationImage(
                              image: NetworkImage(_townhallDetails['imageUrl']),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            )
                          : null,
                      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    ),
                    child: _townhallDetails['imageUrl'] == null
                        ? Icon(
                            Icons.group,
                            size: 80,
                            color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                          )
                        : null,
                  ),

                  // Townhall Details Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Townhall Name and ID
                        // Text(
                        //   'Townhall ID: ${widget.townhallId}',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        
                        // Member Count
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 20,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              // '${_townhallDetails['memberCount']} Members',
                              '_ Members',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Created Date
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.calendar_today,
                        //       size: 20,
                        //       color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                        //     ),
                        //     const SizedBox(width: 8),
                        //     Text(
                        //       'Created: ${_townhallDetails['createdDate']}',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _townhallDetails['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rules Section
                        Text(
                          'Community Rules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_townhallDetails['rules'] as List<dynamic>).asMap().entries.map((entry) {
                          final index = entry.key;
                          final rule = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    rule,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // // Action Buttons
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       ElevatedButton.icon(
                  //         onPressed: () {
                  //           // Implement join functionality
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(content: Text('Join functionality coming soon!')),
                  //           );
                  //         },
                  //         icon: const Icon(Icons.add),
                  //         label: const Text('Donate to Townhall'),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.blue,
                  //           foregroundColor: Colors.white,
                  //         ),
                  //       ),
                  //       OutlinedButton.icon(
                  //         onPressed: () {
                  //           // Implement report functionality
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(content: Text('Report functionality coming soon!')),
                  //           );
                  //         },
                  //         icon: const Icon(Icons.report_outlined),
                  //         label: const Text('Report'),
                  //         style: OutlinedButton.styleFrom(
                  //           foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  //           side: BorderSide(
                  //             color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}