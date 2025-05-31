import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'package:http/http.dart' as http;

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> mapData;
  EventDetailsScreen({Key? key, required this.mapData}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int ticketCount = 1; // Default selected ticket count
  final int maxTickets = 10; // Maximum ticket count

  Map<String, dynamic> _eventDetails = {};

  @override
  void initState() {
    _fetchEventDetails('${widget.mapData['eventID']}').then((data) {
      if (data['status'] == 200) {
        setState(() {
          _eventDetails = data['data'];
        });
      }
    });
    super.initState();
  }

  void increaseTickets() {
    if (ticketCount < maxTickets) {
      setState(() {
        ticketCount++;
      });
    }
  }

  void decreaseTickets() {
    if (ticketCount > 1) {
      setState(() {
        ticketCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 5, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details Container
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            '${_eventDetails.isNotEmpty ? _eventDetails['event_graphics'][0]['image_name'] : widget.mapData['media'][0]['image_name']}',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_eventDetails.isNotEmpty ? _eventDetails['title'] : widget.mapData['title']}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // Text(
                                  //   '\$45',
                                  //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                                  // ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.calendar_today, size: 16),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          '${_eventDetails.isNotEmpty ? _eventDetails['event_time_fulltxt'] : widget.mapData['eventTimeFullTxt']}',
                                          //overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          10), // Optional spacing between the two rows
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          '${_eventDetails.isNotEmpty ? _eventDetails['meeting_point'] : widget.mapData['location']}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          10), // Optional spacing between the two rows
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          '${_eventDetails.isNotEmpty ? _eventDetails['event_type_name'] : widget.mapData['eventTypeName']}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // SizedBox(height: 10),
                              // Text('256 seats available', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          '${_eventDetails.isNotEmpty ? _eventDetails['org_logo'] : widget.mapData['leadingIcon']}'), // Replace with your avatar image URL
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('About Event',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                '${_eventDetails.isNotEmpty ? _eventDetails['description'] : widget.mapData['description']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              // SizedBox(height: 8),
              // GestureDetector(
              //   onTap: () {
              //     // Handle read more functionality here
              //   },
              //   child: Text('read more', style: TextStyle(color: Colors.pink)),
              // ),
              // SizedBox(height: 20),
              // Row(
              //   children: [
              //     CircleAvatar(backgroundImage: NetworkImage('https://example.com/avatar1.jpg')),
              //     SizedBox(width: 10),
              //     CircleAvatar(backgroundImage: NetworkImage('https://example.com/avatar2.jpg')),
              //     SizedBox(width: 10),
              //     CircleAvatar(backgroundImage: NetworkImage('https://example.com/avatar3.jpg')),
              //     SizedBox(width: 10),
              //     Text('+2k Participant'),
              //   ],
              // ),
              // SizedBox(height: 20),
              // Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // Container(
              //   height: 150,
              //   color: Colors.grey[300], // Placeholder for map
              //   child: Center(child: Text('Map goes here')),
              // ),
              // SizedBox(height: 20),
              // // Ticket Quantity Selector
              // Text('Select Number of Tickets:', style: TextStyle(fontSize: 16)),
              // SizedBox(height: 8),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.remove, color: ticketCount > 1 ? Colors.black : Colors.grey),
              //       onPressed: decreaseTickets,
              //     ),
              //     Text(
              //       '$ticketCount',
              //       style: TextStyle(fontSize: 20),
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.add, color: ticketCount < maxTickets ? Colors.black : Colors.grey),
              //       onPressed: increaseTickets,
              //     ),
              //   ],
              // ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.pink,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     minimumSize: Size(double.infinity, 50),
              //   ),
              //   onPressed: () {
              //     // Handle ticket purchase action
              //     // You can use ticketCount to get the number of tickets to purchase
              //   },
              //   child: Text('Buy Ticket', style: TextStyle(color: Colors.white)),
              // ),
              // SizedBox(height: 10),
              // Center(
              //   child: IconButton(
              //     icon: Icon(Icons.favorite_border, color: Colors.pink),
              //     onPressed: () {
              //       // Handle favorite action
              //     },
              //   ),
              // ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchEventDetails(String eventID) async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse(
          '${domainName}/api/townhall/fetch_event_details?event_id=${eventID}'),
      headers: {
        'Authorization': '$authToken',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load organization details');
    }
  }
}
