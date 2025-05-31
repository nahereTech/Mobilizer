import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobilizer/common/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilizer/pages/search/search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class OrganizationDetails extends StatefulWidget {
  static String routeName = 'organization_details_screen';
  final Map<String, dynamic> mapData;
  const OrganizationDetails({required this.mapData, Key? key}) : super(key: key);

  @override
  State<OrganizationDetails> createState() => _OrganizationDetailsState();
}

class _OrganizationDetailsState extends State<OrganizationDetails> {
  String? orgID;
  String? orgBg;
  String? orgAbout;
  String? orgName;
  String? orgMemberCounts;
  String? joinStatus;
  String? orgUsername;
  String? logo;
  String? member;
  String? isLeader;
  String? verified;
  int? unread;
  String? pinned;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        orgID = widget.mapData['org_id'].toString();
        orgBg = widget.mapData['org_bg'];
        logo = widget.mapData['picture'];
        orgAbout = widget.mapData['org_about'];
        orgName = widget.mapData['org_name'];
        orgMemberCounts = widget.mapData['org_member_count'];
        joinStatus = widget.mapData['join_status'];
        orgUsername = widget.mapData['org_username'];
        member = widget.mapData['member'];
        isLeader = widget.mapData['is_leader'];
        verified = widget.mapData['verified'];
        unread = widget.mapData['unread'];
        pinned = widget.mapData['pinned'];
      });
    });
  }

  Future<void> _handleJoinOrLeaveOrganization() async {
    setState(() {
      _isJoining = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('No token found');
      }

      final isJoining = joinStatus != 'yes' && joinStatus != 'pending';
      final url = isJoining
          ? '${base_url}townhall/join_org'
          : '${base_url}townhall/leave_org'; // Adjust endpoint as needed

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'org_id': orgID,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            joinStatus = isJoining ? jsonData['data']['join_status'] ?? 'yes' : 'no';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isJoining
                    ? 'You have successfully joined'
                    : 'You have successfully left',
              ),
              backgroundColor: Colors.green.shade300,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['msg'] ?? 'Action failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
      Loader.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.mapData['navigateTo'] != null &&
            widget.mapData['navigateTo'] == 'search') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Search()),
          );
          return true;
        } else {
          Navigator.pop(context);
          return true;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                orgBg != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 32.0),
                        height: size.height * 0.3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(orgBg!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              iconSize: 25,
                              icon: const FaIcon(
                                FontAwesomeIcons.arrowLeft,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                Positioned(
                  bottom: -68,
                  child: logo != null
                      ? CircleAvatar(
                          radius: 68,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(75),
                            child: Image.network(
                              logo!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blue,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      orgName.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (orgUsername != null && orgUsername != 'null')
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, left: 16.0, right: 16.0),
                      child: Text(
                        orgUsername.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, left: 16.0, right: 16.0),
                    child: Text(
                      orgMemberCounts.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  if (joinStatus != null && joinStatus!.isNotEmpty && orgID != '1' && orgID != '2')
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 26.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(120, 50),
                          backgroundColor: joinStatus == 'yes' ||
                                  joinStatus == 'pending' ||
                                  joinStatus == 'block' ||
                                  joinStatus == 'blocked'
                              ? Colors.red
                              : Colors.blue,
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: _isJoining
                            ? null
                            : () {
                                Loader.show(
                                  context,
                                  overlayColor: Colors.black26,
                                  progressIndicator: Container(
                                    width: 200.0,
                                    height: 120.0,
                                    child: Column(
                                      children: [
                                        const SpinKitCircle(
                                          color: Colors.blue,
                                          size: 45.0,
                                        ),
                                        Text(
                                          joinStatus == 'yes' || joinStatus == 'pending'
                                              ? 'Leaving...'
                                              : 'Joining...',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            decoration: TextDecoration.none,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                _handleJoinOrLeaveOrganization();
                              },
                        child: _isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                joinStatus == 'yes' ||
                                        joinStatus == 'pending' ||
                                        joinStatus == 'block' ||
                                        joinStatus == 'blocked'
                                    ? 'Leave'
                                    : 'Join',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      orgAbout ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}