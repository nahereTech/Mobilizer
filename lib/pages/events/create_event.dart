import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobilizer/bloc/events/events_bloc.dart';
import 'package:mobilizer/common/common/constants.dart';
import 'package:mobilizer/common/common/sharepreference.dart';
import 'dart:convert';
import 'package:mobilizer/models/townhall/townhalls_user_is_leader_in_response.dart';
import 'package:mobilizer/pages/events/events.dart';
import 'package:mobilizer/widget/bottom_navigational_bar.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class CreateEventScreen extends StatefulWidget {
  static String routeName = 'create_event_screen';
  List<Data> townhalls = [];
  CreateEventScreen({required this.townhalls, Key? key}) : super(key: key);
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _eventType;
  String? _organization;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _imagePath;

  List<EventType> eventTypes = [];
  List<Townhall> townhalls = [];
  final List<String> organizations = [];

  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingPointController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchEventTypes();
    _fetchTownhalls();
  }

  Future<void> _fetchEventTypes() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse('${domainName}/api/townhall/fetch_event_types'),
      headers: {
        'Authorization': '$authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'];
      setState(() {
        eventTypes = data.map((e) => EventType.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load event types');
    }
  }

  Future<void> _fetchTownhalls() async {
    final authToken = await AppSharedPreferences.getValue(key: 'token');
    final response = await http.get(
      Uri.parse('${domainName}/api/townhall/townhalls_user_is_leader_in'),
      headers: {
        'Authorization': '$authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'];
      setState(() {
        townhalls = data.map((e) => Townhall.fromJson(e)).toList();
        organizations.clear();
        organizations.addAll(
            townhalls.map((townhall) => townhall.townhall_name).toList());
      });
    } else {
      throw Exception('Failed to load townhalls');
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startTime ?? DateTime.now())
          : (_endTime ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _startTime = selectedDateTime;
            _endTime = null;
          } else {
            if (_startTime != null && selectedDateTime.isBefore(_startTime!)) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                        "Event End time cannot be earlier than start time."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              _endTime = selectedDateTime;
            }
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // Add this method in your _CreateEventsState class
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _isSubmitting = true;
      });
      // Show a loading dialog
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => Center(
      //       child: CircularProgressIndicator(backgroundColor: Colors.white)),
      // );

      try {
        // Prepare the request
        final authToken = await AppSharedPreferences.getValue(key: 'token');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${domainName}/api/townhall/create_event'),
        );

        request.headers['Authorization'] = '$authToken';

        // Add fields
        request.fields['title'] = _titleController.text;
        request.fields['desc'] = _descriptionController.text;
        request.fields['event_start_date_time'] =
            DateFormat('yyyy-MM-dd HH:mm').format(_startTime!);
        request.fields['event_end_date_time'] =
            DateFormat('yyyy-MM-dd HH:mm').format(_endTime!);
        request.fields['event_type'] = _eventType!;
        request.fields['meeting_point'] = _meetingPointController.text;
        request.fields['org_townhall_id'] =
            _organization!; // Use the selected organization

        // Add the image file
        request.files
            .add(await http.MultipartFile.fromPath('files[]', _imagePath!));

        // Send the request
        final response = await request.send();
        final responseData = await http.Response.fromStream(response);
        print("Fields: ${request.fields}"); // Form fields
        print("Headers: ${request.headers}"); // Headers including Authorization

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(responseData.body);

          // Check for success status
          if (jsonResponse['status'] == 200) {
            setState(() {
              _isSubmitting = false;
            });

            // Show success message
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Success'),
                  content: Text(jsonResponse['msg']),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        // Clear the form and navigate back to EventsScreen
                        if (mounted) {
                          _clearForm();
                        }
                        Navigator.of(context).pop(); // Close the dialog
                        await AppSharedPreferences.setValue(
                            key: 'currentViewedPage', value: 'events');
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => EventsBloc(),
                              ),
                            ],
                            child: EventsScreen(),
                          );
                        }));
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            setState(() {
              _isSubmitting = false;
            });
            throw Exception(jsonResponse['msg']);
          }
        } else {
          setState(() {
            _isSubmitting = false;
          });
          throw Exception('Failed to create event');
        }
      } on FormatException catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.source}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Add this method to clear the form
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _meetingPointController.clear();
    _imagePath = null;
    _eventType = null;
    _organization = null;
    _startTime = null;
    _endTime = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlayLoaderWithAppIcon(
      isLoading: _isSubmitting ? true : false,
      overlayBackgroundColor: Colors.grey,
      circularProgressColor: Colors.blue,
      appIconSize: 25,
      appIcon: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset(
          'images/icon_blue.png',
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Events'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        image: _imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imagePath == null
                          ? Center(
                              child: Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey[700]))
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(_titleController, 'Event Title'),
                  _buildTextField(_descriptionController, 'Event Description',
                      maxLines: 5),
                  _buildDropdownField('Event Type', _eventType, eventTypes,
                      (value) {
                    setState(() {
                      _eventType = value;
                    });
                  }),
                  _buildDateTimePicker(
                      'Select Start Date and Time', _startTime, true),
                  _buildDateTimePicker(
                      'Select End Date and Time', _endTime, false),
                  _buildTextField(_meetingPointController, 'Meeting Point'),
                  _buildDropdownField('Organization', _organization, townhalls,
                      (value) {
                    setState(() {
                      _organization = value;
                    });
                  }),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String? currentValue,
      List<dynamic> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          value: currentValue,
          items: items.map((item) {
            if (item is Townhall) {
              return DropdownMenuItem<String>(
                value: item.org_townhall_id, // Use org_townhall_id directly
                child: Text(item.townhall_name),
              );
            }
            return DropdownMenuItem<String>(
              value: item.id.toString(),
              child: Text(item.name),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select a $label' : null,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime? dateTime, bool isStart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _selectDateTime(context, isStart),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: dateTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(dateTime)
                  : 'Not selected',
            ),
            validator: (value) =>
                dateTime == null ? 'Please select a date and time' : null,
          ),
        ),
      ),
    );
  }
}

class EventType {
  final int id;
  final String name;

  EventType({required this.id, required this.name});

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Townhall {
  final int townhall_id;
  final String townhall_name;
  final String org_name;
  final int org_id;
  final String designation;
  final String org_townhall_id; // Change to String

  Townhall({
    required this.townhall_id,
    required this.townhall_name,
    required this.org_name,
    required this.org_id,
    required this.designation,
    required this.org_townhall_id, // Update constructor
  });

  factory Townhall.fromJson(Map<String, dynamic> json) {
    return Townhall(
      townhall_id: json['townhall_id'],
      townhall_name: json['townhall_name'],
      org_name: json['org_name'],
      org_id: json['org_id'],
      designation: json['designation'],
      org_townhall_id: json['org_townhall_id'], // Parse new field as String
    );
  }
}
