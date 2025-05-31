import 'package:flutter/material.dart';
import 'package:mobilizer/pages/search/search_product_details_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart'; // Import this at the top
import 'package:intl/intl.dart';

// First, add these to your state class
class OrganizationLevel {
  final List<Map<String, dynamic>> organizations;
  final int? selectedOrgId;
  final bool isLoading;

  OrganizationLevel({
    required this.organizations,
    this.selectedOrgId,
    this.isLoading = false,
  });
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedTab = "Organizations"; // Default tab
  bool isLoading = true; // Loading state for shimmer effect
  String? selectedGlobal;
  String? selectedCountry;
  String? selectedState;
  String? selectedLGA;
  List<dynamic> searchResults = [];
  String keyword = ''; // Default empty search
  bool isRequesting = false; // Add this to prevent multiple calls
  Timer? _debounce;

  // Add these new variables
  List<Map<String, dynamic>> countries = [];
  bool isLoadingCountries = false;

  int? selectedOrganization; // Add this line to declare selectedOrganization

  bool isDataLoaded = false; // Flag to track if the data is loaded
  List<String> organizationNames = []; // Declare it at the class level

  List<String> peopleData = [];
  List<String> postData = [];
  bool _isLoading = false; // Add this to track loading state

  List<Map<String, dynamic>> organizations = [];

  List<OrganizationLevel> organizationLevels = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _tabController = TabController(length: 5, vsync: this);

    // Simplified tab controller listener
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        String newTab;
        switch (_tabController.index) {
          case 0:
            newTab = "Organizations";
            break;
          case 1:
            newTab = "People";
            break;
          case 2:
            newTab = "Posts";
            break;
          case 3:
            newTab = "Professionals";
            break;
          case 4:
            newTab = "Market";
            break;
          default:
            newTab = "Organizations";
        }

        setState(() {
          selectedTab = newTab;
          isLoading = true; // Show loading state
        });

        // Fetch new data for the selected tab
        _fetchSearchResults().then((_) {
          if (mounted) {
            setState(() {
              isLoading = false; // Hide loading state after data is fetched
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              isLoading = false;
              searchResults = [];
            });
          }
        });
      }
    });

    // Initial data fetch
    _fetchOrganizationsAndPopulate();
    _fetchInitialData();
    _fetchOrganizationsForLevel(0);
  }

  // New method to fetch initial data
  Future<void> _fetchInitialData() async {
    try {
      setState(() {
        isLoading = true; // Set loading state before fetching
      });

      await _fetchSearchResults();

      if (mounted) {
        setState(() {
          isLoading = false; // Set loading state to false after data is fetched
        });
      }
    } catch (e) {
      print("Error fetching initial data: $e");
      if (mounted) {
        setState(() {
          isLoading =
              false; // Ensure loading state is set to false even on error
          searchResults = []; // Clear results on error
        });
      }
    }
  }

  // Updated function to fetch organizations for any level
  Future<void> _fetchOrganizationsForLevel(int levelIndex,
      {int? parentId}) async {
    // If it's not the first level and no parentId is provided, return
    if (levelIndex > 0 && parentId == null) return;

    // Update loading state for this level
    setState(() {
      if (levelIndex >= organizationLevels.length) {
        organizationLevels.add(OrganizationLevel(
          organizations: [],
          isLoading: true,
        ));
      } else {
        organizationLevels[levelIndex] = OrganizationLevel(
          organizations: organizationLevels[levelIndex].organizations,
          selectedOrgId: organizationLevels[levelIndex].selectedOrgId,
          isLoading: true,
        );
      }
    });

    try {
      final queryParams = parentId != null ? '&parent_id=$parentId' : '';
      final response = await http.get(
        Uri.parse(
            'https://townhall.empl-dev.com.ng/api/orgs/list_orgs_user_joined?page=1&limit=100$queryParams'),
        headers: {
          'Authorization':
              'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> orgs = responseData['data'];

        setState(() {
          organizationLevels[levelIndex] = OrganizationLevel(
            organizations: orgs
                .map((org) => {
                      'org_name': org['org_name'],
                      'org_id': org['org_id'],
                      'has_children': org['has_children'],
                    })
                .toList(),
            isLoading: false,
          );
        });
      } else {
        throw Exception('Failed to load organizations');
      }
    } catch (e) {
      print("Error fetching organizations for level $levelIndex: $e");
      setState(() {
        organizationLevels[levelIndex] = OrganizationLevel(
          organizations: [],
          isLoading: false,
        );
      });
    }
  }

  // Update the _fetchOrganizationsAndPopulate method
  void _fetchOrganizationsAndPopulate() async {
    if (isDataLoaded) return;

    try {
      // Fetch organization data
      organizations = await _fetchOrganizations();
      setState(() {
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error fetching organizations: $e");
    }
  }

  // Add this new method to fetch countries
  Future<void> _fetchCountries() async {
    setState(() {
      isLoadingCountries = true;
    });

    try {
      final url = Uri.parse(
          'https://townhall.empl-dev.com.ng/api/townhall/fetch_townhall_children?parent_id=1');
      final response = await http.get(url, headers: {
        'Authorization':
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          setState(() {
            countries = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error fetching countries: $e');
    } finally {
      setState(() {
        isLoadingCountries = false;
      });
    }
  }

  // First, modify the _fetchOrganizations() function to return the full organization details
  Future<List<Map<String, dynamic>>> _fetchOrganizations() async {
    String token =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU';

    try {
      final response = await http.get(
        Uri.parse(
            'https://townhall.empl-dev.com.ng/api/orgs/list_orgs_user_joined?page=1&limit=100&parent_id'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> orgs = responseData['data'];

        // Convert the data to the required format
        return orgs
            .map((org) => {
                  'org_name': org['org_name'],
                  'org_id': org['org_id'],
                  'has_children': org['has_children'],
                })
            .toList();
      } else {
        throw Exception('Failed to load organizations');
      }
    } catch (e) {
      print("Error fetching organizations: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Reset status bar style when leaving the page
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // Default color when leaving the page
      statusBarIconBrightness: Brightness.light, // Reset icons to light
      statusBarBrightness: Brightness.dark, // Reset text color
    ));

    super.dispose();
  }

  Future<void> _fetchSearchResults({String? locations}) async {
    if (isRequesting) return; // Prevent multiple simultaneous requests

    try {
      setState(() {
        isRequesting = true;
        isLoading = true; // Ensure loading state is true while fetching
      });

      // Construct the URL, including the locations parameter if provided
      final url = Uri.parse(
          'https://townhall.empl-dev.com.ng/api/townhall/perform_search?section=$selectedTab&keyword=${Uri.encodeComponent(keyword)}&page=1&limit=10&org_id=1&locations=$locations');

      final response = await http.get(url, headers: {
        'Authorization':
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            if (data['status'] == true) {
              searchResults = data['data'] ?? [];
            } else {
              searchResults = [];
            }
            isLoading = false;
            isRequesting = false;
          });
        }
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print("Error fetching search results: $e");
      if (mounted) {
        setState(() {
          searchResults = [];
          isLoading = false;
          isRequesting = false;
        });
      }
    }
  }

  Widget _buildTabContent() {
    if (isLoading) {
      return _shimmerLoader();
    } else {
      if (searchResults.isEmpty) {
        return Center(child: Text('No Content'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 15),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          var item = searchResults[index];

          switch (selectedTab) {
            case "Posts":
              return _buildPostRow(item);
            case "Professionals":
              return _buildProfessionalsRow(item);
            case "People":
              return _buildPeopleRow(item);
            case "Market":
              return _buildMarketRow(item);
            default:
              return _buildOrganizationRow(item);
          }
        },
      );
    }
  }

  Widget _buildMarketRow(dynamic item) {
    // Format the cost with commas for better readability
    String formattedCost =
        NumberFormat("#,##0").format(int.parse(item['cost']));
    String currency = item['currency'] == "1" ? "₦" : "\$";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailsPage(item: item)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 230, 230, 230),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Container
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item['main_image'] ?? '',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                size: 30, color: Colors.grey[400]),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          item['name'] ?? 'Unknown Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4),

                        // Price
                        Text(
                          '$currency$formattedCost',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00AFEF),
                          ),
                        ),

                        SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['item_location'] ??
                                    'Location not specified',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        // Description
                        Text(
                          item['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildPeopleRow(dynamic item) {
    // Ensure the 'is_following' key is available in 'item'
    String followStatus =
        item['is_following'] ?? 'no'; // Default to 'no' if it's not available
    bool isButtonLoading = false; // To manage the loading state

    Future<void> _handleFollowUnfollow() async {
      setState(() {
        isButtonLoading = true; // Start the loading spinner
      });

      String apiUrl = followStatus == 'no'
          ? 'https://townhall.empl-dev.com.ng/api/townhall/createConnection'
          : 'https://townhall.empl-dev.com.ng/api/townhall/removeConnection';

      // Prepare the form data
      final Map<String, String> body = {
        'followee': item['user_id'].toString(), // Pass the user ID as followee
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type':
                'application/x-www-form-urlencoded', // Set content type to form-urlencoded
            'Authorization':
                'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU', // Pass the authorization token
          },
          body: body, // Send form data as body
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          print(responseData['status']);
          if (responseData['status'] == "200") {
            setState(() {
              isButtonLoading = false; // Stop the loading spinner
              // Toggle follow status based on current status
              if (followStatus == 'no') {
                item['is_following'] = 'yes'; // User is now following
              } else {
                item['is_following'] = 'no'; // User unfollowed
              }
            });
          } else {
            setState(() {
              isButtonLoading = false; // Stop the loading spinner on failure
            });
            // Show error snackbar with red background
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error: ${responseData['message']}'),
                  backgroundColor: Colors.red),
            );
          }
        } else {
          setState(() {
            isButtonLoading = false; // Stop the loading spinner on failure
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: Unable to process request'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        setState(() {
          isButtonLoading = false; // Stop the loading spinner on exception
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Network error. Please try again.'),
              backgroundColor: Colors.red),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 230, 230),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              // Navigate to the person's profile page
            },
            child: CircleAvatar(
              backgroundImage:
                  (item['photo_path'] != null && item['photo_path'].isNotEmpty)
                      ? NetworkImage(item['photo_path'] ?? '')
                      : null,
              child: (item['photo_path'] == null || item['photo_path'].isEmpty)
                  ? Text((item['fullname']?.isNotEmpty ?? false)
                      ? item['fullname'][0].toUpperCase()
                      : 'N')
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['fullname'] ?? 'No Name',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Single sentence location with ellipsis
              Text(
                [
                  item['country_name'] ?? '',
                  item['state_name'] ?? '',
                  item['lga_name'] ?? ''
                ].where((element) => element.isNotEmpty).join(', '),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              if (item['mutuals_count'] != null && item['mutuals_count'] > 0)
                Text(
                  '${item['mutuals_count']} mutuals',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
            ],
          ),
          trailing: isButtonLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                )
              : TextButton(
                  onPressed:
                      _handleFollowUnfollow, // Handle follow/unfollow action
                  style: TextButton.styleFrom(
                    backgroundColor:
                        followStatus == "no" ? Colors.blue : Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: Text(
                    followStatus == "no" ? 'Follow' : 'Unfollow',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOrganizationRow(dynamic item) {
    // Determine the button color and text based on is_member status
    Color buttonColor;
    String buttonText;

    if (item['is_member'] == 'yes') {
      buttonColor = Colors.red; // Red for "Leave"
      buttonText = 'Leave';
    } else if (item['is_member'] == 'no') {
      buttonColor = Colors.blue; // Blue for "Join"
      buttonText = 'Join';
    } else if (item['is_member'] == 'pending') {
      buttonColor = Colors.orange; // Orange for "Pending"
      buttonText = 'Pending';
    } else {
      buttonColor = Colors.blue; // Default fallback to blue if no match
      buttonText = 'Join';
    }

    bool isButtonLoading = false; // Track shimmer state

    Future<void> _handleAction() async {
      setState(() {
        isButtonLoading = true; // Start shimmer effect
      });

      String apiUrl;

      if (buttonText == 'Join') {
        apiUrl = 'https://townhall.empl-dev.com.ng/api/townhall/join_org';
      } else if (buttonText == 'Leave') {
        apiUrl = 'https://townhall.empl-dev.com.ng/api/townhall/leave_org';
      } else {
        // Handle Pending case
        bool confirmLeave = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pending Request'),
              content:
                  Text('Your request is still pending. Do you want to leave?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );

        if (!confirmLeave) {
          setState(() {
            isButtonLoading = false; // Stop shimmer if user cancels
          });
          return;
        }

        apiUrl = 'https://townhall.empl-dev.com.ng/api/townhall/leave_org';
      }

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(
              {'org_id': item['org_id']}), // Pass org_id in the request body
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNleWV6eUBnbWFpbC5jb20iLCJpZCI6IjQ1IiwiY29tcGFueV9pZCI6IjcwIiwiZGV2aWNlX3RrbiI6ImVVdW0xaUVHdjBaN2dfYUx1S1pNbnc6QVBBOTFiRlltQWlibVROZGc5cTZVV0VFcnU3a3hDaHlWRjllSlFKUTY4STMweUF3M2JRQmpiQU1sVnd5X18td2pUOTdjend1SFFtblc0SEczcGtxRkk4RzcyMTVPSXVjaDZUeEdjQlU2X1lvS2FoOFFLeDMtODQ0WjZfZndKUWlYTkVkYVY4elI1cWIifQ.NFYEOwKcKhzw45tVcCF90e8Dgs3JO2vXJTJCOY_h-mU',
          },
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          if (responseData['status'] == 200) {
            print(responseData['tag']);
            // Successful action, update the button state
            if (buttonText == 'Join') {
              // Successful "Join" action
              setState(() {
                isButtonLoading = false; // Stop shimmer

                if (responseData['tag'] == 'join_is_pending') {
                  item['is_member'] = 'pending'; // Now the user is a member
                  // If the tag is 'join_is_pending', set the button to 'Pending'
                  buttonText = 'Pending';
                  buttonColor = Colors
                      .orange; // Set the button color to orange for Pending
                } else {
                  item['is_member'] = 'yes'; // Now the user is a member
                  // If not pending, set the button to 'Leave'
                  buttonText = 'Leave';
                  buttonColor =
                      Colors.red; // Set the button color to red for Leave
                }
              });
            } else if (buttonText == 'Leave') {
              // Successful "Leave" action
              setState(() {
                isButtonLoading = false; // Stop shimmer
                item['is_member'] = 'no'; // User is no longer a member
                buttonText = 'Join'; // Change button text to 'Join'
                buttonColor = Colors.blue; // Set button color to blue
              });
            } else if (buttonText == 'Pending') {
              // In case of 'Pending', update the state to reflect user action
              setState(() {
                isButtonLoading = false; // Stop shimmer
                item['is_member'] = 'no'; // User has left
                buttonText = 'Join'; // Change button text to 'Join'
                buttonColor = Colors.blue; // Set button color to blue
              });
            }
          } else {
            setState(() {
              isButtonLoading = false; // Stop shimmer on failure
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Action failed. Please try again.')),
            );
          }
        } else {
          setState(() {
            isButtonLoading = false; // Stop shimmer on failure
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action failed. Please try again.')),
          );
        }
      } catch (e) {
        setState(() {
          isButtonLoading = false; // Stop shimmer on exception
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 230, 230),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              // Keep this as is for organization profile
            },
            child: CircleAvatar(
              backgroundImage:
                  item['picture'] != null && item['picture'].isNotEmpty
                      ? NetworkImage(item['picture'])
                      : null,
              child: item['picture'] == null || item['picture'].isEmpty
                  ? Text(item['org_name'][0].toUpperCase())
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['org_name'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (item['org_about'] != null && item['org_about'] != '')
                Text(
                  item['org_about'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              if (item['org_username'] != null && item['org_username'] != '')
                Text(
                  '@${item['org_username']}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
            ],
          ),
          trailing: TextButton(
            onPressed: isButtonLoading
                ? null
                : _handleAction, // Disable button while loading
            style: TextButton.styleFrom(
              backgroundColor: isButtonLoading ? Colors.grey[300] : buttonColor,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            child: isButtonLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      width: 50,
                      color: Colors.grey[300],
                    ),
                  )
                : Text(
                    buttonText,
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalsRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 230, 230),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              // Navigate to the professional's profile page
              // Map<String, dynamic> mapData = {
              //   'userID': item['user_id'] ?? '',
              //   'fullname': item['fullname'] ?? 'No Name',
              //   'photo': item['photo_path'] ?? '',
              //   'username': item['username'] ?? '',
              //   'country': item['country_name'] ?? '',
              //   'state': item['state_name'] ?? '',
              //   'lga': item['lga_name'] ?? '',
              //   'professionCategory': item['profession_category'] ?? '',
              //   'profession': item['profession'] ?? '',
              // };
              // Navigate to a new screen with mapData
            },
            child: CircleAvatar(
              backgroundImage:
                  (item['photo_path'] != null && item['photo_path'].isNotEmpty)
                      ? NetworkImage(item['photo_path'] ?? '')
                      : null,
              child: (item['photo_path'] == null || item['photo_path'].isEmpty)
                  ? Text((item['fullname']?.isNotEmpty ?? false)
                      ? item['fullname'][0].toUpperCase()
                      : 'N')
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // Add this to prevent unbounded height
            children: [
              Text(
                item['fullname'] ?? 'No Name',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (item['profession_category'] != null &&
                  item['profession_category'].isNotEmpty)
                Text(
                  '${item['profession_category']} - ${item['profession']}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        item['country_name'] ?? '',
                        if (item['state_name'] != null &&
                            item['state_name'].isNotEmpty)
                          item['state_name'],
                        if (item['lga_name'] != null &&
                            item['lga_name'].isNotEmpty)
                          item['lga_name'],
                      ].join(', '),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // trailing: IconButton(
          //   icon: Icon(Icons.more_horiz),
          //   onPressed: () {
          //     // Handle more button (e.g., show additional options for the professional)
          //   },
          // ),
        ),
      ),
    );
  }

  Widget _buildPostRow(dynamic item) {
    // Format the timestamp for display
    String formattedTime = '';
    try {
      DateTime postTime = DateTime.parse(item['post_updated_time']);
      DateTime currentTime = DateTime.parse(item['current_time']);
      Duration difference = currentTime.difference(postTime);

      if (difference.inMinutes < 60) {
        formattedTime = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours}h ago';
      } else {
        formattedTime = '${difference.inDays}d ago';
      }
    } catch (e) {
      formattedTime = 'recently';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 18, right: 18),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 230, 230),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  // Navigate to user profile
                  // Map<String, dynamic> mapData = {
                  //   'userID': item['posted_by'],
                  //   'username': item['username'],
                  //   'photo': item['photo_path'],
                  //   'name': item['poste_update_by'],
                  // };
                  // Navigate to profile page with mapData
                },
                child: CircleAvatar(
                  backgroundImage: (item['post_profile_pics'] != null &&
                          item['post_profile_pics'].isNotEmpty)
                      ? NetworkImage(item['post_profile_pics'])
                      : null,
                  child: (item['post_profile_pics'] == null ||
                          item['post_profile_pics'].isEmpty)
                      ? Text(item['poste_update_by'][0].toUpperCase())
                      : null,
                ),
              ),
              title: Text(
                item['poste_update_by'] ?? 'Unknown User',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '@${item['username']} • $formattedTime',
                style: TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  // Handle more options
                },
              ),
            ),

            // Post content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item['posted_message'] ?? '',
                style: TextStyle(fontSize: 14),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: Row(
                children: [
                  // Like button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          item['is_liked'] == 'yes'
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: item['is_liked'] == 'yes'
                              ? Colors.red
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          // Handle like action
                        },
                      ),
                      Text(
                        '${item['like_count']}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Comment button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                        ),
                        onPressed: () {
                          // Handle comment action
                        },
                      ),
                      Text(
                        '${item['comment_count']}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Share button
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      // Handle share action
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated bottom sheet with recursive dropdowns
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build dropdowns for each level
                    ...List.generate(organizationLevels.length, (index) {
                      return Column(
                        children: [
                          if (index > 0) SizedBox(height: 16),
                          _buildDropdown(
                            label: index == 0
                                ? "Select Organization"
                                : "Select Sub-Organization Level ${index + 1}",
                            value: organizationLevels[index].selectedOrgId,
                            items: organizationLevels[index].organizations,
                            isLoading: organizationLevels[index].isLoading,
                            enabled: !organizationLevels[index].isLoading,
                            onChanged: (newValue) async {
                              setModalState(() {
                                // Update selected value for current level
                                organizationLevels[index] = OrganizationLevel(
                                  organizations:
                                      organizationLevels[index].organizations,
                                  selectedOrgId: newValue,
                                  isLoading: false,
                                );

                                // Remove all subsequent levels
                                if (organizationLevels.length > index + 1) {
                                  organizationLevels.removeRange(
                                      index + 1, organizationLevels.length);
                                }
                              });

                              if (newValue != null) {
                                // Check if selected organization has children
                                final selectedOrg = organizationLevels[index]
                                    .organizations
                                    .firstWhere(
                                        (org) => org['org_id'] == newValue);

                                if (selectedOrg['has_children'] == true) {
                                  // Fetch next level
                                  await _fetchOrganizationsForLevel(index + 1,
                                      parentId: newValue);
                                  setModalState(
                                      () {}); // Refresh the modal state
                                }
                              }
                            },
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: 32),
                    TextButton(
                      onPressed: () {
                        // Collect all selected organization IDs
                        final selectedOrgs = organizationLevels
                            .where((level) => level.selectedOrgId != null)
                            .map((level) => level.selectedOrgId)
                            .toList();

                        // Convert the list of selected org IDs to a comma-separated string
                        String locationFilter = selectedOrgs.join(',');

                        // Close the bottom sheet
                        Navigator.pop(context);

                        // Call _fetchSearchResults() and add the 'locations' parameter
                        _fetchSearchResults(locations: locationFilter);

                        // Optionally, show a success dialog
                        // _showSuccessDialog();
                      },
                      child: Text(
                        "Apply Filters",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Color(0xFF00AFEF),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56),
                        side: BorderSide(color: Color(0xFF00AFEF), width: 2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Add this helper widget for the dropdown with default option
  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required bool isLoading,
    required List<Map<String, dynamic>> items,
    required Function(dynamic) onChanged,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500,
        //     color: Colors.black87,
        //   ),
        // ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: value,
              isExpanded: true,
              hint: Text("Select an organization"),
              items: [
                // Add default "All Organizations" option with null value
                DropdownMenuItem(
                  value: null,
                  child: Text("-- Select --"),
                ),
                // Add the rest of the organizations
                ...items.map((item) {
                  return DropdownMenuItem(
                    value: item['org_id'],
                    child: Text(item['org_name']),
                  );
                }).toList(),
              ],
              onChanged: enabled ? onChanged : null,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Success dialog to show after applying filters
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filters Applied'),
          content: Text('Your filters have been successfully applied.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              // Search form at the top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    // Set loading state immediately when typing starts
                    setState(() {
                      keyword = value;
                      isLoading = true; // Show shimmer while typing
                    });

                    // Cancel the previous timer if it's still running
                    if (_debounce?.isActive ?? false) {
                      _debounce?.cancel();
                    }

                    // Set a new timer to trigger the search after 1 second of inactivity
                    _debounce = Timer(const Duration(seconds: 1), () {
                      _fetchSearchResults(); // Trigger the search when the user stops typing for 1 second
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search $selectedTab',
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Prevent label from floating
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _tabController.index !=
                            0 // Check if the active tab is not 'Organizations'
                        ? IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed:
                                _openFilterBottomSheet, // Open the bottom sheet on click
                          )
                        : null, // Hide the filter icon when 'Organizations' tab is active
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 80, 94, 252)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF00AFEF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF00AFEF)),
                    ),
                  ),
                ),
              ),

              // Tab Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Color.fromARGB(255, 0, 120, 219),
                  indicatorColor: const Color.fromARGB(255, 0, 120, 219),
                  padding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(
                      child: Text(
                        'Organizations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tabController.index == 0
                              ? FontWeight.w600
                              : FontWeight.normal, // Semi-bold for active tab
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'People',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tabController.index == 1
                              ? FontWeight.w600
                              : FontWeight.normal, // Semi-bold for active tab
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tabController.index == 2
                              ? FontWeight.w600
                              : FontWeight.normal, // Semi-bold for active tab
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Professionals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tabController.index == 3
                              ? FontWeight.w600
                              : FontWeight.normal, // Semi-bold for active tab
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Market',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tabController.index == 4
                              ? FontWeight.w600
                              : FontWeight.normal, // Semi-bold for active tab
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content for each tab
              Expanded(
                child: IndexedStack(
                  index: _tabController
                      .index, // Index of the currently selected tab
                  children: [
                    _buildTabContent(), // Organizations
                    _buildTabContent(), // People
                    _buildTabContent(), // Posts
                    _buildTabContent(), // Professionals
                    _buildTabContent(), // Market
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer loader widget
  Widget _shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 200.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
