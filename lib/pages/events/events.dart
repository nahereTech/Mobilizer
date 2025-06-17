import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:mobilizer/pages/organization/organization.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobilizer/pages/events/create_event.dart'; //
import 'package:mobilizer/pages/events/event_details.dart'; // Ensure you have this page created
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/townhall/townhalls_user_is_leader_in_response.dart';

class EventsScreen extends StatefulWidget {
  @override
  EventsScreenState createState() => EventsScreenState();
  static String routeName = 'events';
}

class EventsScreenState extends State<EventsScreen> {
  List<Organization> _organizations = [];
  List<Data> _townhalls = [];
  List<dynamic> nearbyEvents = [];
  List<dynamic> allEvents = []; // List for all events
  bool loading = false;
  bool showNearbyEvents = false; // Flag to control visibility
  DateTimeRange? selectedDateRange;
  String? organizationId;
  String? keyword;
  String? pics;

  // Step 1: Add pagination variables
  ScrollController _scrollController = ScrollController();
  int currentPage = 1; // Track the current page for all events
  final int limit = 50; // Limit for API calls
  bool isLoadingMore = false; // Track if more data is being loaded
  String? selectedOrganizationId;
  bool isFiltering = false; // Track if the filtering request is in progress
  bool isSearching = false; // Track if a search is in progress

  @override
  void initState() {
    super.initState();
    _setprofilePics();
    fetchNearbyEvents();
    fetchAllEvents();
    fetchTownhallsUserIsLeaderIn();
    _fetchOrganizations();

    // Initialize scroll controller listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !loading &&
          !isLoadingMore) {
        fetchMoreEvents(); // Load more events when reaching the bottom
      }
    });
  }

  // Fetch initial nearby events
  Future<void> fetchNearbyEvents() async {
    setState(() {
      loading = true;
      nearbyEvents.clear(); // Clear previous nearby events
    });

    await _fetchNearbyEvents(); // Call the fetch method for nearby events
  }

  // Fetch initial all events
  Future<void> fetchAllEvents() async {
    setState(() {
      loading = true;
      currentPage = 1; // Reset to first page on new fetch
      allEvents.clear(); // Clear previous all events
    });

    await _fetchAllEvents(); // Call the fetch method for all events
  }

  // Fetch more events for pagination
  Future<void> fetchMoreEvents() async {
    if (isLoadingMore) return; // Prevent multiple calls
    setState(() {
      isLoadingMore = true; // Set loading state
    });

    currentPage++; // Increment the current page for all events
    await _fetchAllEvents(); // Call the fetch method for all events
  }

  // Fetch nearby events from API
  Future<void> _fetchNearbyEvents() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    Map<String, String> queryParameters = {
      'page': currentPage.toString(),
      'limit': limit.toString(),
      if (selectedOrganizationId != null)
        'organization_id': selectedOrganizationId!,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword!,
      if (selectedDateRange != null)
        'event_date_range':
            '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)}to${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
    };
    final Uri url = Uri.parse('${domainName}/api/townhall/fetch_nearby_events')
        .replace(queryParameters: queryParameters);

    final response = await http.get(url, headers: {
      'Authorization': '$authToken',
    });
    print("Parameters: ${response.request}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 200) {
        setState(() {
          nearbyEvents.addAll(data['data']); // Append new nearby events
          loading = false;
          showNearbyEvents = true;
        });
      } else {
        setState(() {
          loading = false;
          showNearbyEvents = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchTownhallsUserIsLeaderIn() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final userID = await AppSharedPreferences.getValue(key: 'user_id');
    try {
      final response = await http.get(
        Uri.parse(
            '${domainName}/api/townhall/townhalls_user_is_leader_in?&include_mf=yes'),
        headers: {
          'Authorization': '${authToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData.containsKey('data')) {
          final dataList = jsonData['data'];
          if (dataList is List) {
            setState(() {
              _townhalls = dataList.map((json) => Data.fromJson(json)).toList();
            });
          } else {
            _showSnackBar('An error occurred');
          }
        }
      } else {
        _showSnackBar('Failed to load townhalls');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Display the snackbar with the appropriate color
    final color = isError ? Colors.red : Colors.green;
    // Code to show the snackbar, e.g., using ScaffoldMessenger
  }

  // Fetch all events from API
  Future<void> _fetchAllEvents() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    Map<String, String> queryParameters = {
      'page': currentPage.toString(),
      'limit': limit.toString(),
      if (selectedOrganizationId != null)
        'organization_id': selectedOrganizationId!,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword!,
      if (selectedDateRange != null)
        'event_date_range':
            '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)}to${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
    };
    final Uri url = Uri.parse('${domainName}/api/townhall/fetch_events')
        .replace(queryParameters: queryParameters);

    final response = await http.get(url, headers: {
      'Authorization': '$authToken',
    });
    print("Request: ${response.request}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 200) {
        setState(() {
          showNearbyEvents = true;
          allEvents.addAll(data['data']); // Append new events
          loading = false;
          isLoadingMore = false; // Reset loading state
        });
      } else {
        setState(() {
          showNearbyEvents = false;
          loading = false;
          isLoadingMore = false;
        });
      }
    } else {
      setState(() {
        loading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.menu, color: Colors.black),
        //   onPressed: () {},
        // ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16.0),
          //   child: CircleAvatar(
          //     backgroundImage:
          //         NetworkImage('${pics ?? 'https://via.placeholder.com/150'}'),
          //   ),
          // ),
        ],
      ),
      body: ListView(
        controller: _scrollController, // Attach the controller here
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 24),
          showNearbyEvents
              ? const Text(
                  "Nearby Events Today",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : Container(),
          const SizedBox(height: 8),
          loading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 250,
                    color: Colors.white,
                  ),
                )
              : showNearbyEvents && nearbyEvents.isNotEmpty
                  ? _buildHorizontalSlider() // Horizontal slider for nearby events
                  : Container(),
          const SizedBox(height: 24),
          const Text(
            "All Events",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          loading
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                )
              : allEvents.isEmpty
                  ? Center(child: Text("No Event"))
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allEvents.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= allEvents.length) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                        var event = allEvents[index];

                        return _listTile(
                          event['id'].toString(),
                          event['event_time_fulltxt'],
                          event['event_time_only'],
                          event['event_icon'],
                          event['event_type_name'],
                          event['title'],
                          event['event_desc'],
                          event['event_venue'],
                          event['posted_in'],
                          event['posted_by'],
                          event['id'],
                          event[
                              'event_graphics'], // Pass the full event time here
                        );
                      },
                    ),
          SizedBox(height: 24),
        ],
      ),
      floatingActionButton: _fab(),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // height: _showBottomMenu ? kBottomNavigationBarHeight : 0,
        child:
            // _showBottomMenu
            //     ?
            BottomNavigation(
                page: EventsScreen.routeName, showBottomMenu: true),
        //: null,
      ),
    );
  }

  Widget _buildHorizontalSlider() {
    return Container(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nearbyEvents.length,
        itemBuilder: (context, index) {
          var event = nearbyEvents[index];
          print("Near By: ${event}");
          String eventGraphics = event['event_graphics'] ??
              'https://via.placeholder.com/150'; // Default image

          return GestureDetector(
            onTap: () {
              Map<String, dynamic> mapData = {
                'eventID': event['id'].toString(),
                'time': event['event_time_fulltxt'],
                'leadingIcon': event['event_icon'],
                'title': event['title'],
                'eventTypeName': event['event_type_name'],
                'description': event['event_desc'],
                'location': event['event_venue'],
                'townhall': event['posted_in'],
                'postedBy': event['posted_by'],
                'media': [
                  {'image_name': event['event_graphics']}
                ],
                'eventTimeFullTxt': event['event_time_fulltxt']
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(mapData: mapData),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              margin: EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(eventGraphics),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(event['event_icon']),
                      radius: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              event['title'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 4.0, bottom: 8.0),
                            child: Text(
                              event['event_venue'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listTile(
    String eventID,
    String eventTimeFullTxt,
    String time,
    String imageUrl,
    String eventTypeName,
    String title,
    String description,
    String location,
    String venue,
    String postedBy,
    int id,
    List media, // New parameter for full event time
  ) {
    return GestureDetector(
      onTap: () {
        print("Event ID on tap ${eventID}");
        Map<String, dynamic> mapData = {
          'eventID': eventID,
          'time': time,
          'leadingIcon': imageUrl,
          'title': title,
          'eventTypeName': eventTypeName,
          'description': description,
          'location': location,
          'townhall': venue,
          'postedBy': postedBy,
          'media': media,
          'eventTimeFullTxt': eventTimeFullTxt
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(mapData: mapData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                media[0]['thumbnail'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$eventTimeFullTxt", // Display full event time
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Venue: $location", // Display full event time
                    style: TextStyle(fontSize: 14),
                  ),

                  // SizedBox(height: 4),
                  // Text(
                  //   description,
                  //   style: TextStyle(fontSize: 14),
                  //   overflow: TextOverflow.ellipsis,
                  //   maxLines: 2,
                  // ),

                  // SizedBox(height: 4),
                  // Text(
                  //   "Venue: $venue",
                  //   style: TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab() {
    return FloatingActionButton(
      backgroundColor: Color(0xFF00AFEF), // Set the background color to blue
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateEventScreen(
                      townhalls: _townhalls,
                    )));
      },
      child: Icon(
        Icons.add,
        color: Colors.white, // Set the icon color to white
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Event Title or #ID',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value;
                  isSearching = true; // Set searching to true
                  fetchNearbyEvents(); // Fetch new events based on the search query
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.grey[600]),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return _buildFilterOptions(); // Ensure you have this method defined
                },
              );
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildDropdown('Organization', _organizations),
              SizedBox(height: 16),
              _buildDateRangePicker(setState),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isFiltering = true; // Start filtering
                    loading = true; // Show shimmer loaders
                  });

                  // Fetch events again with new filters
                  await fetchNearbyEvents();
                  await fetchAllEvents();

                  setState(() {
                    isFiltering = false; // Stop filtering
                  });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: isFiltering
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ],
                      )
                    : Text('Apply Filters'),
              ),
              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items) {
    return StatefulBuilder(
      builder: (context, setState) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          value: selectedOrganizationId, // Use the state variable here
          items: items.map((item) {
            if (item is Organization) {
              return DropdownMenuItem<String>(
                value: item.orgID, // Use org_townhall_id directly
                child: Text(item.orgName),
              );
            }
            return DropdownMenuItem<String>(
              value: item.orgID,
              child: Text(item.orgName),
            );
          }).toList(),
          onChanged: (newValue) {
            print("new Value: ${newValue}");
            setState(() {
              selectedOrganizationId =
                  newValue; // Update the selected organization ID
            });
          },
          validator: (value) => value == null ? 'Please select a $label' : null,
        );
      },
    );
  }

  Widget _buildDateRangePicker(StateSetter setBottomSheetState) {
    return GestureDetector(
      onTap: () async {
        DateTimeRange? picked = await showDateRangePicker(
          context: context,
          initialDateRange: selectedDateRange,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );

        if (picked != null) {
          setState(() {
            selectedDateRange = picked;
          });
          setBottomSheetState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDateRange == null
                  ? 'Select Date Range'
                  : 'From: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.start)} - To: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.end)}',
              style: TextStyle(color: Colors.black54),
            ),
            Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchOrganizations() async {
    final token = await AppSharedPreferences.getValue(key: 'token');
    print("token: ${token}");
    try {
      final response = await http.get(
        Uri.parse('${domainName}/api/orgs/orgs_user_joined?limit=100&page=1'),
        headers: {
          'Authorization': token!,
        },
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        final dynamic responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          final dataList = responseData['data'];
          if (dataList is List) {
            if (mounted)
              setState(() {
                _organizations =
                    dataList.map((e) => Organization.fromJson(e)).toList();
              });
          } else {
            throw Exception('Invalid response format: data is not a list');
          }
        } else {
          throw Exception(
              'Invalid response format: data field is missing or not a list');
        }
      } else {
        print("This is response else: ${response.body}");
        throw Exception('Failed to load organizations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching organizations: $e');
      // Handle error gracefully, e.g., show a snackbar or retry option
    }
  }

  void _setprofilePics() async {
    var prePics = await AppSharedPreferences.getValue(key: 'profilePic');
    setState(() {
      pics = prePics;
    });
  }
}
