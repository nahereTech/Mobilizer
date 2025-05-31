// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/utils.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:nahere/bloc/posts/posts_bloc.dart' as post;
// import 'package:nahere/bloc/search/organization_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/models/organization/default_available_twh_response.dart';
// import 'package:nahere/models/organization/default_postable_twh_response.dart';
// import 'package:nahere/models/organization/organization_plan_response.dart';
// import 'package:nahere/models/organization/organization_response.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
// import 'package:nahere/pages/feed/feed.dart';
// import 'package:nahere/pages/organization/my_organizations.dart';
// import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AddOrganization extends StatefulWidget {
//   static String routeName = 'add_organization_screen';
//   const AddOrganization({Key? key}) : super(key: key);

//   @override
//   State<AddOrganization> createState() => _AddOrganizationState();
// }

// class _AddOrganizationState extends State<AddOrganization> {
//   ScrollController _scrollControllerA = ScrollController();
//   ScrollController _scrollControllerV = ScrollController();
//   String? orgID;
//   String _selectedPlanID = '';
//   String _selectedTitle = '';
//   String _selectedPlanDesc = '';
//   String _logoString = '';
//   String _bannerString = '';
//   String _townhall_id_temp = '';
//   int _selectedIndex = -1; //to position the child//select parentID
//   int _entryIndex = 0;
//   int _newLevel = 0;
//   int selectedOption = 0; // Track selected option with a single variable
//   int? unread;

//   bool value = false;
//   bool loading = false;
//   bool _loadingAddTownhall = false;
//   bool _loadingCustomTownhall = false;
//   bool _loadingRenameTownhall = false;
//   bool _loadingDeleteTownhall = false;
//   bool _loadingPlan = true;
//   bool _hasChildren = false;
//   bool _hasNextSibling = false;
//   bool noResult = false;
//   bool _active_status = false;
//   bool memberRequiredConfirmation = false;
//   bool privateOrganization = false;
//   var _childName;

//   List<PostableData> postableData = [];
//   List<AvailableData> availableData = [];
//   List<SelectedPostable> selectedPostableList = [];
//   List<SelectedAvailable> selectedAvailableList = [];

//   final _formKey1 = GlobalKey<FormState>();
//   final _formKey2 = GlobalKey<FormState>();
//   final _formKey3 = GlobalKey<FormState>();
//   final _controllerOrgName = TextEditingController();
//   final _controllerOrgDescription = TextEditingController();
//   final _controllerOrgUrl = TextEditingController();
//   final _controllerOrgLogo = TextEditingController();
//   final _controllerOrgBanner = TextEditingController();
//   final _controllerOrgPlan = TextEditingController();
//   late final TreeController<MyNode> _treeController;

//   var focusNode = FocusNode();
//   final picker = ImagePicker();
//   File? _imageLogo;
//   File? _imageBanner;
//   List<MyNode> _roots = <MyNode>[];
//   MyNode _selectedNode = MyNode();
//   List<PlanData> planData = [];

//   void selectOption(int option) {
//     print("Select option ${option}");
//     setState(() {
//       selectedOption = option;
//       _selectedPlanID = option.toString();
//     });
//     if (_selectedPlanID.toString() == '3') {
//       if (_roots.length < 1) {
//         Map<String, dynamic> map = Map();
//         map["sample"] = '';
//         BlocProvider.of<OrganizationBloc>(context).add(
//             GetCustomOrganizationIDEvent(customOrganizationIDRequest: map));

//         setState(() {
//           _loadingCustomTownhall = true;
//         });
//       }
//     }
//   }

//   void initState() {
//     Future.delayed(Duration.zero, () {
//       final OrganizationBloc bloc = BlocProvider.of<OrganizationBloc>(context);
//       BlocProvider.of<OrganizationBloc>(context)
//           .add(GetOrganizationPlanEvent());
//     });
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<OrganizationBloc>(context)
//           .add(DefaultAvailableTWHEvent());
//     });
//     Future.delayed(Duration.zero, () {
//       BlocProvider.of<OrganizationBloc>(context).add(DefaultPostableTWHEvent());
//     });
//     super.initState();
//     _treeController = TreeController<MyNode>(
//       // Provide the root nodes that will be used as a starting point when
//       // traversing your hierarchical data.
//       roots: _roots,
//       // Provide a callback for the controller to get the children of a
//       // given node when traversing your hierarchical data. Avoid doing
//       // heavy computations in this method, it should behave like a getter.
//       childrenProvider: (MyNode node) => node.children,
//     );
//     _scrollControllerA = ScrollController();
//   }

//   void dispose() {
//     // Remember to dispose your tree controller to release resources.
//     _treeController.dispose();
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.pop(context, 'refresh');
//     return false;
//   }

//   @override
//   Widget build(BuildContext contextA) {
//     Size size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async => !Loader.isShown,
//       child: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 70,
//           //automaticallyImplyLeading: false,
//           backgroundColor: Colors.transparent,
//           bottomOpacity: 0.0,
//           elevation: 0.0,
//           shadowColor: Colors.white,
//           centerTitle: true,
//           // iconTheme: IconThemeData(
//           //   color: Colors.blue, //change your color here
//           // ),
//           title: Text(
//             'Create Organization2',
//             style: TextStyle(color: Colors.black),
//           ),
//         ),
//         body: BlocConsumer<OrganizationBloc, OrganizationState>(
//             listener: (context, state) async {
//           if (state is GetOrganizationPlanState) {
//             setState(() {
//               planData = state.getOrganizationPlanResponse.data!;
//               _loadingPlan = false;
//             });
//           }
//           if (state is OrganizationLoadingState) {
//             setState(() {});
//             loading = true;
//           }
//           if (state is AddCustomTownhallLoadingState) {
//             setState(() {
//               _loadingAddTownhall = true;
//             });
//           }
//           if (state is RenameCustomTownhallLoadingState) {
//             setState(() {
//               _loadingRenameTownhall = true;
//             });
//           }
//           if (state is DeleteCustomTownhallLoadingState) {
//             setState(() {
//               _loadingDeleteTownhall = true;
//             });
//           }
//           if (state is DefaultAvailableTWHState) {
//             setState(() {
//               availableData = state.defaultAvailableTWHResponse.data;
//               loading = false;
//             });
//           }
//           if (state is DefaultPostableTWHState) {
//             setState(() {
//               postableData = state.defaultPostableTWHResponse.data;
//               loading = false;
//             });
//           }
//           if (state is NoReturnState) {
//             setState(() {
//               loading = false;
//               _loadingPlan = false;
//               Loader.hide();
//             });
//           }
//           if (state is CreateOrganizationState) {
//             setState(() {
//               loading = false;
//               Loader.hide();
//             });
//             //clear all stored feeds before redirecting
//             _clearFeedCache();

//             final snackBar = SnackBar(
//                 backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                 content: Text("Group was successfully created"));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             Future.delayed(Duration(seconds: 5), () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return BlocProvider(
//                   create: (context) => post.PostsBloc(),
//                   child: Feed(),
//                 );
//               }));
//             });
//           }
//           if (state is GetCustomOrganizationIDState) {
//             setState(() {
//               _newLevel = 1;
//               _loadingCustomTownhall = false;
//               _townhall_id_temp = state
//                   .customOrganizationIDResponse.data.townhall_id
//                   .toString();

//               _roots.add(
//                 MyNode(
//                     title: 'LEVEL 1',
//                     sideTitle: _controllerOrgName.text == ""
//                         ? "Organization"
//                         : _controllerOrgName.text,
//                     parentID: '',
//                     townhallID: _townhall_id_temp,
//                     levelID: _newLevel),
//               );
//               _treeController.rebuild();
//               _treeController.expandAll();
//             });
//             print("Temp ID: $_townhall_id_temp");
//           }
//           if (state is ErrorCustomOrganizationIDState) {
//             setState(() {
//               _loadingCustomTownhall = false;
//               _selectedPlanID = '';
//               _controllerOrgPlan.text = '';
//             });
//           }
//           if (state is CreateCustomTownhallState) {
//             Navigator.pop(context);
//             var townhallID =
//                 state.createCustomTownhallResponse.data!.townhall_id;

//             if (_entryIndex != 0) {
//               //check if _hasChildren
//               //increment the last level
//               var parentNod =
//                   _findNodeById(_roots, _selectedNode.parentID.toString());
//               var parentChildrenCounts = parentNod!.children.length < 1
//                   ? 0
//                   : parentNod!.children.length;
//               setState(() {
//                 _loadingAddTownhall = false;
//                 _loadingCustomTownhall = false;
//                 print(
//                     "ParentName: ${parentNod.sideTitle} ParentLevel ID: ${parentNod.levelID} parentTownhall ${parentNod.townhallID} myownParentID ${_selectedNode.parentID}");
//                 _selectedNode.children.add(
//                   MyNode(
//                       title: _hasChildren == false
//                           ? 'LEVEL ${(parentNod.levelID! + 1).toString()}'
//                           : '',
//                       sideTitle: _childName,
//                       parentID: _selectedNode.townhallID,
//                       townhallID: townhallID.toString(),
//                       levelID: _hasChildren == false
//                           ? parentNod.levelID! + 1
//                           : parentNod.levelID),
//                 );
//                 _treeController.rebuild();
//                 _treeController.expandAll();
//               });
//             } else {
//               setState(() {
//                 _loadingAddTownhall = false;
//                 _loadingCustomTownhall = false;
//                 _selectedNode.children.add(
//                   MyNode(
//                       title: 'LEVEL 2',
//                       sideTitle: _childName,
//                       parentID: _selectedNode.townhallID,
//                       townhallID: townhallID.toString(),
//                       levelID: 2),
//                 );

//                 _treeController.rebuild();
//                 _treeController.expandAll();
//               });
//             }

//             final snackBar = SnackBar(
//                 backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                 content: Text("Townhall was successfully created"));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             // Future.delayed(Duration(seconds: 5), () {
//             //   Navigator.pop(context);
//             // });
//           }
//           if (state is RenameCustomTownhallState) {
//             FocusScope.of(context).unfocus();
//             _renameChild(_selectedNode.townhallID!, _childName);
//             setState(() {
//               _loadingRenameTownhall = false;
//               _loadingCustomTownhall = false;
//             });
//             Navigator.pop(context);
//             final snackBar = SnackBar(
//                 backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                 content: Text("Townhall was successfully edited"));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//           }
//           if (state is DeleteCustomTownhallState) {
//             // _removeParent(_positionID);

//             Navigator.pop(context);
//             final snackBar = SnackBar(
//                 backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                 content: Text("Townhall was successfully removed"));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);

//             setState(() {
//               _loadingDeleteTownhall = false;
//               _removeNode(_selectedNode.townhallID!);
//             });
//           }

//           if (state is NetworkState) {
//             setState(() {
//               loading = false;
//               Loader.hide();
//               noResult = false;
//               _loadingPlan = false;
//             });
//             print(state.message);
//             // loading = false;
//             final snackBar = SnackBar(
//                 backgroundColor: Color(0xFFcf5555),
//                 content: Text(state.message.toString()));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//           }
//           if (state is OrganizationErrorState) {
//             setState(() {
//               loading = false;
//               Loader.hide();
//               noResult = false;
//               _loadingRenameTownhall = false;
//               _loadingAddTownhall = false;
//               _loadingDeleteTownhall = false;
//               _loadingCustomTownhall = false;
//             });
//             print(state.message);
//             // loading = false;
//             final snackBar = SnackBar(
//                 backgroundColor: Color(0xFFcf5555),
//                 content: Text(state.message.toString()));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//           }
//           if (state is DuplicateErrorState) {
//             setState(() {
//               loading = false;
//               Loader.hide();
//               noResult = false;
//             });
//             print(state.message);
//             // loading = false;
//             final snackBar = SnackBar(
//                 backgroundColor: Color(0xFFcf5555),
//                 content: Text(state.message.toString()));
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//           }
//           if (state is PlanErrorState) {
//             setState(() {
//               _loadingPlan = false;
//             });
//             _showNotification(state.message.toString(), 'Error', false);
//           }
//           if (state is PlanNetworkState) {
//             setState(() {
//               _loadingPlan = false;
//             });
//             _showNotification(state.message.toString(), 'Error', false);
//           }
//         }, builder: (context, state) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Form(
//                   key: _formKey1,
//                   child: Container(
//                     padding: EdgeInsets.only(top: 1),
//                     width: double.infinity,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                               height:
//                                   20), // This provides spacing between the cards
//                           _loadingPlan
//                               ? Center(
//                                   child: Padding(
//                                     padding:
//                                         const EdgeInsets.only(bottom: 20.0),
//                                     child: SpinKitWave(
//                                       color: Colors.grey,
//                                       size: 15.0,
//                                     ),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   physics: NeverScrollableScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: planData.length,
//                                   itemBuilder:
//                                       (BuildContext contextOne, int index) {
//                                     return Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 32, right: 32, bottom: 20),
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           selectOption(planData[index].id);
//                                           setState(() {
//                                             _selectedPlanDesc =
//                                                 planData[index].desc;
//                                           });
//                                         },
//                                         child: Card(
//                                           color: _selectedPlanID ==
//                                                   planData[index].id.toString()
//                                               ? Colors.lightBlueAccent
//                                               : null,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(16.0),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Radio(
//                                                   value: planData[index].id,
//                                                   groupValue: selectedOption,
//                                                   onChanged: (value) =>
//                                                       selectOption(
//                                                           value as int),
//                                                 ),
//                                                 Text(
//                                                   planData[index].name,
//                                                   style: TextStyle(
//                                                     fontSize: 20,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 8),
//                                                 Text(
//                                                   planData[index].desc,
//                                                   style:
//                                                       TextStyle(fontSize: 14),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),

//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 32),
//                             child: TextFormField(
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp("[0-9a-zA-Z ]"))
//                               ],
//                               //readOnly: _disableUsername,
//                               decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(15.0)),
//                                   labelText: 'Organization name',
//                                   hintText: 'Enter Organization Name'),
//                               controller: _controllerOrgName,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter Organization name';
//                                 }
//                                 elseif(validateUsername(value)) {
//                                   return 'Invalid Organization name';
//                                 }

//                                 return null;
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 20),
//                             child: TextFormField(
//                               minLines: 3,
//                               maxLines: 5,
//                               decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(15.0)),
//                                   labelText: 'Description',
//                                   hintText:
//                                       'Enter Description for your organization'),
//                               controller: _controllerOrgDescription,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter Organization description';
//                                 }

//                                 return null;
//                               },
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               focusNode.requestFocus();
//                             },
//                             child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 15, vertical: 5),
//                                 margin: EdgeInsets.symmetric(horizontal: 32),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       'https://townhall.mobi/',
//                                       style: TextStyle(fontSize: 17),
//                                     ),
//                                     IntrinsicWidth(
//                                       child: TextFormField(
//                                         controller: _controllerOrgUrl,
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp("[0-9a-zA-Z]"))
//                                         ],
//                                         onChanged: (value) {
//                                           // _controllerUserName.value =
//                                           TextEditingValue(
//                                               text: value.toLowerCase().trim(),
//                                               selection:
//                                                   _controllerOrgUrl.selection);
//                                         },
//                                         focusNode: focusNode,
//                                         decoration: InputDecoration(
//                                           hintText: 'example',
//                                           border: InputBorder.none,
//                                           contentPadding: EdgeInsets.zero,
//                                         ),
//                                         autocorrect: false,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return 'Please enter Organization url';
//                                           }

//                                           return null;
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 )),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 25),
//                             child: Row(
//                               children: [
//                                 Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(14)),
//                                         color:
//                                             Color.fromARGB(255, 195, 200, 205)),
//                                     width: 60,
//                                     height: 60,
//                                     child: _imageLogo != null
//                                         ? ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(14),
//                                             child: Image.file(
//                                               _imageLogo!,
//                                               fit: BoxFit
//                                                   .cover, // Adjust the image's fit within the container
//                                             ),
//                                           )
//                                         : SizedBox()),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Container(
//                                   width: size.width - 135,
//                                   child: TextFormField(
//                                     onTap: () {
//                                       selectImageSource('logo');
//                                     },
//                                     readOnly: true,
//                                     decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(15.0)),
//                                         labelText: 'Organization Logo',
//                                         hintText: 'Enter Organization Logo'),
//                                     controller: _controllerOrgLogo,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 0),
//                             child: Row(
//                               children: [
//                                 Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(14)),
//                                         color:
//                                             Color.fromARGB(255, 195, 200, 205)),
//                                     width: 60,
//                                     height: 60,
//                                     child: _imageBanner != null
//                                         ? ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(14),
//                                             child: Image.file(
//                                               _imageBanner!,
//                                               fit: BoxFit
//                                                   .cover, // Adjust the image's fit within the container
//                                             ),
//                                           )
//                                         // CircleAvatar(
//                                         //     radius: 15,
//                                         //     backgroundColor: Colors.grey,
//                                         //     child: ClipRRect(
//                                         //       borderRadius:
//                                         //           BorderRadius.circular(15),
//                                         //       child: CircleAvatar(
//                                         //         radius: 1,
//                                         //         backgroundColor: Colors.black45,
//                                         //         backgroundImage:
//                                         //             FileImage(_imageBanner!),
//                                         //       ),
//                                         //     ),
//                                         //   )
//                                         : SizedBox()),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Container(
//                                   width: size.width - 135,
//                                   child: TextFormField(
//                                     onTap: () {
//                                       selectImageSource('banner');
//                                     },
//                                     readOnly: true,
//                                     decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(15.0)),
//                                         labelText: 'Organization Banner',
//                                         hintText: 'Select Banner'),
//                                     controller: _controllerOrgBanner,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 20, right: 35, top: 20, bottom: 10),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     child: Checkbox(
//                                         value: memberRequiredConfirmation,
//                                         onChanged: (val) {
//                                           setState(() {
//                                             memberRequiredConfirmation = val!;
//                                           });
//                                         }),
//                                   ),
//                                   Container(
//                                     width: size.width - 118,
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           SizedBox(
//                                             height: 12,
//                                           ),
//                                           Text(
//                                             "Membership Requires confirmation",
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                           SizedBox(height: 5),
//                                           Text(
//                                             "Joining members will neeed to be confirmed by you first before allowed in",
//                                             style:
//                                                 TextStyle(color: Colors.grey),
//                                           ),
//                                         ]),
//                                   )
//                                 ],
//                               )),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 20, right: 36, top: 20, bottom: 10),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Checkbox(
//                                       value: privateOrganization,
//                                       onChanged: (val) {
//                                         setState(() {
//                                           privateOrganization = val!;
//                                         });
//                                       }),
//                                 ),
//                                 Container(
//                                   width: size.width - 118,
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           height: 12,
//                                         ),
//                                         Text(
//                                           "Private Organization",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 17,
//                                           ),
//                                         ),
//                                         SizedBox(height: 5),
//                                         Text(
//                                           "If checked, your organization will not be found through the search box but through invitation link sent by you",
//                                           style: TextStyle(color: Colors.grey),
//                                         ),
//                                       ]),
//                                 )
//                               ],
//                             ),
//                           ),

//                           _selectedPlanDesc != ""
//                               ? Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 32, vertical: 5),
//                                   child: Text("${_selectedPlanDesc}"),
//                                 )
//                               : SizedBox(),
//                           // Padding(
//                           //   padding: const EdgeInsets.symmetric(
//                           //       horizontal: 32, vertical: 7),
//                           //   child: Divider(
//                           //     thickness: 1.0,
//                           //   ),
//                           // ),
//                           SizedBox(height: 8),
//                           if (availableData.length > 0 &&
//                               _selectedPlanID == '3')
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 18),
//                               child: _loadingCustomTownhall
//                                   ? SpinKitWave(
//                                       color: Colors.grey,
//                                       size: 15.0,
//                                     )
//                                   : Container(
//                                       height: 300,
//                                       width: double.infinity,
//                                       child: AnimatedTreeView<MyNode>(
//                                         shrinkWrap: true,
//                                         treeController: _treeController,
//                                         nodeBuilder: (BuildContext context,
//                                             TreeEntry<MyNode> entry) {
//                                           // Provide a widget to display your tree nodes in the tree view.
//                                           //
//                                           // Can be any widget, just make sure to include a [TreeIndentation]
//                                           // within its widget subtree to properly indent your tree nodes.
//                                           return _myTreeTile(
//                                               // Add a key to your tiles to avoid syncing descendant animations.
//                                               // key: ValueKey(entry.node),
//                                               // Your tree nodes are wrapped in TreeEntry instances when traversing
//                                               // the tree, these objects hold important details about its node
//                                               // relative to the tree, like: expansion state, level, parent, etc.
//                                               //
//                                               // TreeEntrys are short lived, each time TreeController.rebuild is
//                                               // called, a new TreeEntry is created for each node so its properties
//                                               // are always up to date.
//                                               entry,
//                                               // Add a callback to toggle the expansion state of this node.
//                                               () => _treeController
//                                                   .toggleExpansion(entry.node),
//                                               context);
//                                         },
//                                       ),
//                                     ),
//                             ),
//                           if (availableData.length > 0 &&
//                               _selectedPlanID == '3' &&
//                               _loadingCustomTownhall == false)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 32, vertical: 1),
//                               child: Divider(
//                                 thickness: 1.0,
//                               ),
//                             ),
//                           if (availableData.length > 0 &&
//                               _selectedPlanID != '' &&
//                               _selectedPlanID != '1' &&
//                               _selectedPlanID != '3')
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 32.0),
//                               child: _showAvailable(),
//                             ),
//                           if (postableData.length > 0 &&
//                               _selectedPlanID != '' &&
//                               _selectedPlanID != '1' &&
//                               _selectedPlanID != '3')
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 32, right: 32, top: 20),
//                               child: _showPostable(),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 5),
//                             child: GestureDetector(
//                               onTap: () {
//                                 _showBottomSheet(context);
//                               },
//                               child: Align(
//                                 alignment: Alignment.topLeft,
//                                 child: Text(
//                                   "Read More On Plans",
//                                   style: TextStyle(
//                                     decoration: TextDecoration.underline,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 5),
//                             child: Row(
//                               children: [
//                                 Switch(
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _active_status = value;
//                                     });
//                                   },
//                                   value: _active_status,
//                                   activeColor: Colors.blue,
//                                   activeTrackColor: Colors.grey,
//                                   inactiveTrackColor: Colors.grey,
//                                 ),
//                                 SizedBox(
//                                   width: 7,
//                                 ),
//                                 Text(
//                                   "${_active_status ? 'Active' : 'Inactive'}",
//                                 )
//                               ],
//                             ),
//                           ),
//                           Container(
//                             width: 400,
//                             height: 75,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             padding: EdgeInsets.only(
//                                 left: 30.0, right: 30.0, top: 18.0),
//                             child: BlocListener<OrganizationBloc,
//                                 OrganizationState>(
//                               listener: (context, state) {
//                                 //your state here
//                               },
//                               child: ElevatedButton(
//                                 onPressed: _loadingCustomTownhall
//                                     ? null
//                                     : () {
//                                         FocusScope.of(context).unfocus();
//                                         if (_formKey1.currentState!
//                                             .validate()) {
//                                           if (_selectedPlanID == "") {
//                                             final snackBar = SnackBar(
//                                                 backgroundColor: Colors.red,
//                                                 content: Text(
//                                                     "You need to select an organization structure"));
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(snackBar);
//                                           } else {
//                                             Map<String, dynamic> map = Map();
//                                             if (selectedAvailableList != null) {
//                                               int no = 0;
//                                               List newAvail = [];
//                                               for (var i = 0;
//                                                   i <
//                                                       selectedAvailableList
//                                                           .length;
//                                                   i++) {
//                                                 if (selectedAvailableList[i]
//                                                     .is_checked) {
//                                                   newAvail.add({
//                                                     'name':
//                                                         selectedAvailableList[i]
//                                                             .name,
//                                                     'pic':
//                                                         selectedAvailableList[i]
//                                                             .pic
//                                                   });
//                                                   no++;
//                                                 }
//                                               }
//                                               if (no > 0) {
//                                                 map['available_townhalls'] =
//                                                     newAvail;
//                                               }
//                                             }
//                                             if (selectedPostableList != null) {
//                                               int num = 0;
//                                               List newPost = [];
//                                               for (var i = 0;
//                                                   i <
//                                                       selectedPostableList
//                                                           .length;
//                                                   i++) {
//                                                 if (selectedPostableList[i]
//                                                     .is_checked) {
//                                                   newPost.add({
//                                                     'name':
//                                                         selectedPostableList[i]
//                                                             .name,
//                                                     'pic':
//                                                         selectedPostableList[i]
//                                                             .pic
//                                                   });
//                                                   num++;
//                                                 }
//                                               }
//                                               if (num > 0) {
//                                                 map['postable_townhalls'] =
//                                                     newPost;
//                                               }
//                                             }
//                                             map["org_pic"] = _logoString;
//                                             map["org_bg"] = _bannerString;
//                                             map["org_name"] =
//                                                 _controllerOrgName.text;
//                                             map["org_desc"] =
//                                                 _controllerOrgDescription.text;
//                                             map["org_url"] =
//                                                 _controllerOrgUrl.text;
//                                             map["org_plan"] = _selectedPlanID;
//                                             map["requires_confirmation"] =
//                                                 memberRequiredConfirmation ==
//                                                         true
//                                                     ? "yes"
//                                                     : "no";
//                                             map["org_privacy"] =
//                                                 privateOrganization
//                                                     ? "open"
//                                                     : "close";
//                                             map["active_status"] =
//                                                 _active_status ? "yes" : "no";
//                                             map["tree_view_id"] =
//                                                 _townhall_id_temp;
//                                             print(map);
//                                             BlocProvider.of<OrganizationBloc>(
//                                                     context)
//                                                 .add(
//                                               CreateOrganizationEvent(
//                                                   createOrganizationRequest:
//                                                       map),
//                                             );
//                                             Loader.show(
//                                               context,
//                                               //isSafeAreaOverlay: false,
//                                               //isBottomBarOverlay: false,
//                                               //overlayFromBottom: 80,
//                                               overlayColor: Colors.black26,
//                                               progressIndicator: Container(
//                                                 width: 200.0,
//                                                 height: 120.0,
//                                                 child: Column(
//                                                   children: [
//                                                     SpinKitCircle(
//                                                       color: Colors.blue,
//                                                       size: 45.0,
//                                                     ),
//                                                     Text(
//                                                       'Creating...',
//                                                       style: TextStyle(
//                                                           fontSize: 17,
//                                                           decoration:
//                                                               TextDecoration
//                                                                   .none,
//                                                           color:
//                                                               Colors.black54),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                         }
//                                       },
//                                 child: Text(
//                                   'Create',
//                                   style: TextStyle(
//                                       fontSize: 20, color: Colors.white),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(12), // <-- Radius
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 60,
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled:
//           true, // Ensures that the bottom sheet content fits within the screen
//       builder: (BuildContext builder) {
//         return Container(
//           // height:
//           //     MediaQuery.of(context).size.height * 0.85, // 3/4 of screen height
//           constraints: BoxConstraints.expand(
//               height: MediaQuery.of(context).size.height * 0.65),
//           child: const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.all(10.0),
//                     child: Text(
//                       'Pricing Plans',
//                       style: TextStyle(
//                           fontSize: 22.0, fontWeight: FontWeight.bold),
//                     ),
//                   ),

//                   SizedBox(height: 10.0),

//                   Padding(
//                     padding: EdgeInsets.only(
//                         right: 10.0, left: 10.0, top: 10, bottom: 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Free',
//                           style: TextStyle(
//                               fontSize: 20.0, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '\$0/month',
//                           style: TextStyle(fontSize: 20.0, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           '< 1,000 Members',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.close,
//                           color: Colors.red,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Add Free',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.close,
//                           color: Colors.red,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Fund Raising',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.close,
//                           color: Colors.red,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Townhall Elections',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 25.0),

//                   Padding(
//                     padding: EdgeInsets.only(
//                         right: 10.0, left: 10.0, top: 10, bottom: 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Standard',
//                           style: TextStyle(
//                               fontSize: 20.0, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '\$50/month',
//                           style: TextStyle(fontSize: 20.0, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Unlimited Members',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Add Free',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.close,
//                           color: Colors.red,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Fund Raising',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.close,
//                           color: Colors.red,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Townhall Elections',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 25.0),

//                   Padding(
//                     padding: EdgeInsets.only(
//                         right: 10.0, left: 10.0, top: 10, bottom: 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Premium',
//                           style: TextStyle(
//                               fontSize: 20.0, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '\$150/month',
//                           style: TextStyle(fontSize: 20.0, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Unlimited Members',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Add Free',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Fund Raising',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                             width:
//                                 5.0), // Adjust the spacing between icon and text as needed
//                         Text(
//                           'Townhall Elections',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 25.0),

//                   // Add more content here as needed
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _myTreeTile(
//       TreeEntry<MyNode> entry, VoidCallback onTap, BuildContext contextA) {
//     return TreeIndentation(
//       entry: entry,
//       // Provide an indent guide if desired. Indent guides can be used to
//       // add decorations to the indentation of tree nodes.
//       // This could also be provided through a DefaultTreeIndentGuide
//       // inherited widget placed above the tree view.
//       guide: const IndentGuide.connectingLines(indent: 48),
//       // The widget to render next to the indentation. TreeIndentation
//       // respects the text direction of `Directionality.maybeOf(context)`
//       // and defaults to left-to-right.
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0),
//               child: entry.hasChildren
//                   ? Row(
//                       children: [
//                         Text(
//                           entry.node.title != null
//                               ? entry.node.title.toString()
//                               : '',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     )
//                   : SizedBox(),
//             ),
//             Row(
//               children: [
//                 // Add a widget to indicate the expansion state of this node.
//                 // See also: ExpandIcon.

//                 FolderButton(
//                   //icon: Icon(Icons.plus_one),
//                   openedIcon: Icon(Icons.folder),
//                   isOpen: entry.hasChildren ? entry.isExpanded : null,
//                   onPressed: entry.hasChildren ? onTap : null,
//                 ),
//                 Text(entry.node.sideTitle.toString()),
//                 SizedBox(
//                   width: 5,
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     setState(() {
//                       print('children' + entry.level.toString());
//                       // _parentIndex =
//                       //     _roots.indexWhere((item) => item == entry.node);
//                       // _childIndex = entry.node.children.length;
//                       print(entry.index);
//                       _entryIndex = entry.index;
//                       _hasChildren = entry.hasChildren;
//                       _hasNextSibling = entry.hasNextSibling;
//                       _selectedNode = entry.node;
//                     });

//                     _showDialogue(entry.node);
//                     print("Townhall ID " + _selectedNode.townhallID.toString());
//                     print("Parent ID " + _selectedNode.parentID.toString());
//                     print('has Next Sibling ${_hasNextSibling}');
//                   },
//                   child: Icon(
//                     Icons.edit,
//                     size: 17,
//                     color: Colors.grey,
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   selectImageSource(String selectType) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(8.0),
//             ),
//           ),
//           content: Stack(
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Container(height: 10.0),
//                   Text(
//                     "Pick Image",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Container(height: 20.0),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       getImageFromCamera(selectType);
//                     },
//                     child: Row(
//                       children: <Widget>[
//                         Icon(
//                           Icons.camera_alt,
//                           color: Colors.blueGrey,
//                         ),
//                         Container(width: 10.0),
//                         Text('Camera')
//                       ],
//                     ),
//                   ),
//                   Container(height: 15.0),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       getImageFromGallery(selectType);
//                     },
//                     child: Row(
//                       children: <Widget>[
//                         Icon(
//                           Icons.storage,
//                           color: Colors.blueGrey,
//                         ),
//                         Container(width: 10.0),
//                         Text('Gallery')
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.topRight,
//                   child: ClipOval(
//                     child: Material(
//                       elevation: 5,
//                       color: Colors.blueGrey, // button color
//                       child: InkWell(
//                         splashColor: Colors.red, // inkwell color
//                         child: SizedBox(
//                             width: 25,
//                             height: 25,
//                             child: Icon(
//                               Icons.close,
//                               size: 20,
//                               color: Colors.white,
//                             )),
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future getImageFromCamera(String selectType) async {
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     setState(() {
//       if (pickedFile != null && selectType == "logo") {
//         _imageLogo = File(pickedFile.path);
//         updateProfileImage(selectType);
//       } else if (pickedFile != null && selectType == "banner") {
//         _imageBanner = File(pickedFile.path);
//         updateProfileImage(selectType);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future getImageFromGallery(String selectType) async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null && selectType == "logo") {
//         _imageLogo = File(pickedFile.path);
//         var path = pickedFile.path.split('/').last;
//         _controllerOrgLogo.text = path.replaceAll(RegExp('image_picker_'), '');
//         updateProfileImage(selectType);
//       } else if (pickedFile != null && selectType == "banner") {
//         _imageBanner = File(pickedFile.path);
//         var path = pickedFile.path.split('/').last;
//         _controllerOrgBanner.text =
//             path.replaceAll(RegExp('image_picker_'), '');
//         debugPrint(pickedFile.path);
//         updateProfileImage(selectType);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   void updateProfileImage(String selectType) async {
//     if (selectType == "logo") {
//       List<int> imageBytesOne = File(_imageLogo!.path).readAsBytesSync();
//       String photoBase64One = base64Encode(imageBytesOne);
//       setState(() {
//         _logoString = 'data:image/jpeg;base64,' + photoBase64One;
//       });
//     }
//     if (selectType == "banner") {
//       List<int> imageBytesOne = File(_imageBanner!.path).readAsBytesSync();
//       String photoBase64One = base64Encode(imageBytesOne);
//       setState(() {
//         _bannerString = 'data:image/jpeg;base64,' + photoBase64One;
//       });
//     }
//   }

//   Widget _showAvailable() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
//       decoration: BoxDecoration(
//         color: Color.fromARGB(255, 228, 228, 228),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Wrap(
//         children: [
//           Text(
//             "Visible Levels",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Text(
//             "Only levels selected will be visible to your members.",
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(
//             height: 75,
//           ),
//           Wrap(children: [
//             Container(
//               width: double.infinity,
//               height: 152,
//               child: ListView.builder(
//                   controller: _scrollControllerA,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: availableData.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     final avail = availableData[index];

//                     selectedAvailableList.add(
//                       SelectedAvailable(
//                           avail.name, avail.pic.toString(), false),
//                     );
//                     return Container(
//                       margin: EdgeInsets.only(right: 15),
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.grey,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.network(
//                                 '${avail.pic}',
//                                 width: 55,
//                                 height: 55,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 15,
//                           ),
//                           Text(
//                             "${avail.name}",
//                             style: TextStyle(fontSize: 17),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Transform.scale(
//                             scale: 1.3,
//                             child: Checkbox(
//                               value: selectedAvailableList[index].is_checked,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedAvailableList[index].is_checked =
//                                       !selectedAvailableList[index].is_checked;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//             ),
//           ]),
//         ],
//       ),
//     );
//   }

//   Widget _showPostable() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
//       decoration: BoxDecoration(
//         color: Color.fromARGB(255, 228, 228, 228),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Wrap(
//         children: [
//           Text(
//             "Levels members can post in",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Text(
//             "Only townhall leaders within visible levels will be able to post in levels selected",
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(
//             height: 95,
//           ),
//           Wrap(children: [
//             Container(
//               width: double.infinity,
//               height: 152,
//               child: ListView.builder(
//                   controller: _scrollControllerV,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: postableData.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     final post = postableData[index];
//                     selectedPostableList.add(SelectedPostable(
//                         post.name, post.pic.toString(), false));
//                     return Container(
//                       margin: EdgeInsets.only(right: 15),
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.grey,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.network(
//                                 '${post.pic}',
//                                 width: 55,
//                                 height: 55,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 15,
//                           ),
//                           Text(
//                             "${post.name}",
//                             style: TextStyle(fontSize: 17),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Transform.scale(
//                             scale: 1.3,
//                             child: Checkbox(
//                               value: selectedPostableList[index].is_checked,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedPostableList[index].is_checked =
//                                       !selectedPostableList[index].is_checked;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//             ),
//           ]),
//         ],
//       ),
//     );
//   }

//   _showDialogue(MyNode node) {
//     return showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.5),
//         barrierDismissible: false,
//         builder: (context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(12),
//               ),
//             ),
//             title: Align(
//               alignment: Alignment.topRight,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.close,
//                   size: 20,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _selectedIndex == 0
//                     ? SizedBox()
//                     : Flexible(
//                         flex: 1,
//                         child: InkWell(
//                           onTap: () {
//                             setState(() {
//                               _childName = node.sideTitle;
//                             });
//                             var nod = _findNodeById(
//                                 _roots, _selectedNode.parentID.toString());
//                             var parentName = nod != null ? nod.sideTitle : '';
//                             Navigator.pop(context);
//                             _showEditDialogue(parentName.toString());
//                           },
//                           child: Text(
//                             'Rename Townhall',
//                             style: TextStyle(
//                               decoration: TextDecoration.underline,
//                               color: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium!
//                                   .color,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                               fontFamily: 'SourceSansPro',
//                             ),
//                           ),
//                         ),
//                       ),
//                 SizedBox(
//                   height: _selectedIndex == 0 ? 0 : 25,
//                 ),
//                 Flexible(
//                   flex: 1,
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);

//                       _showAddDialogue(node);
//                     },
//                     child: Text(
//                       'Add Child',
//                       style: TextStyle(
//                         decoration: TextDecoration.underline,
//                         color: Theme.of(context).textTheme.titleMedium!.color,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20.0,
//                         fontFamily: 'SourceSansPro',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 25),
//                 // _hasChildren == false
//                 //     ? SizedBox()
//                 //     :
//                 _selectedIndex == 0
//                     ? SizedBox()
//                     : Flexible(
//                         flex: 1,
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.pop(context);
//                             _showDelDialogue(node);
//                           },
//                           child: Text(
//                             'Delete Townhall',
//                             style: TextStyle(
//                               decoration: TextDecoration.underline,
//                               color: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium!
//                                   .color,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                               fontFamily: 'SourceSansPro',
//                             ),
//                           ),
//                         ),
//                       ),
//                 SizedBox(height: 20)
//               ],
//             ),
//           );
//         });
//   }

//   _showAddDialogue(MyNode node) {
//     return showDialog(
//       context: context,
//       barrierColor: Colors.grey.withOpacity(0.5),
//       barrierDismissible: false,
//       builder: (contextA) {
//         return StatefulBuilder(
//           builder: (contextA, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(12)),
//               ),
//               title: Align(
//                 alignment: Alignment.topRight,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Icon(
//                     Icons.close,
//                     size: 20,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//               content: Form(
//                 key: _formKey2,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: Text(
//                         node.sideTitle.toString(),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 22.0,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       width: 380,
//                       height: 55,
//                       padding: const EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(
//                           color: Colors.grey.withOpacity(0.55),
//                           width: 2.0,
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(14.0)),
//                       ),
//                       child: TextFormField(
//                         cursorColor:
//                             Theme.of(context).textTheme.titleMedium!.color,
//                         onSaved: (value) => _childName = value,
//                         decoration: InputDecoration(
//                           hintText: 'Townhall',
//                           hintStyle: TextStyle(
//                             fontSize: 15.0,
//                             fontFamily: 'SourceSansPro-regular',
//                             color: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium!
//                                 .color!
//                                 .withOpacity(0.3),
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.only(
//                               left: 10.0, top: 10.0, bottom: 10.0),
//                         ),
//                         style: TextStyle(color: Colors.black, fontSize: 14),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       width: 400,
//                       height: 63,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       padding:
//                           EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                       child: ElevatedButton(
//                         onPressed: _loadingAddTownhall
//                             ? null
//                             : () async {
//                                 FocusScope.of(contextA).unfocus();
//                                 setState(() {
//                                   _loadingAddTownhall = true;
//                                 });

//                                 final form2 = _formKey2.currentState;
//                                 form2!.save();

//                                 Map<String, dynamic> map = Map();
//                                 map["parent_id"] = _selectedNode.townhallID;
//                                 map["child_name"] = _childName;
//                                 print("Map $map");

//                                 // Dispatch the event
//                                 BlocProvider.of<OrganizationBloc>(context).add(
//                                   CreateCustomTownhallEvent(
//                                     createCustomTownhallRequest: map,
//                                   ),
//                                 );

//                                 // Close the dialog after submission completes
//                                 // Use BlocListener or similar to listen for state change
//                                 // and close dialog on success
//                               },
//                         child: _loadingAddTownhall
//                             ? SpinKitWave(
//                                 color: Colors.grey,
//                                 size: 15.0,
//                               )
//                             : Text(
//                                 'Add Townhall',
//                                 style: TextStyle(
//                                     fontSize: 20, color: Colors.white),
//                               ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _loadingAddTownhall
//                               ? Colors.grey.withOpacity(0.5)
//                               : Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   _showEditDialogue(String parentName) {
//     return showDialog(
//       context: context,
//       barrierColor: Colors.grey.withOpacity(0.5),
//       barrierDismissible: false,
//       builder: (contextE) {
//         return StatefulBuilder(builder: (contextE, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(12),
//               ),
//             ),
//             title: Align(
//               alignment: Alignment.topRight,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.close,
//                   size: 20,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//             content: Container(
//               child: Form(
//                 key: _formKey3,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: Text(
//                         parentName,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 22.0,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       width: 300,
//                       height: 50,
//                       // margin: EdgeInsets.only(top: 10),
//                       padding: const EdgeInsets.only(top: 1, left: 12),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(
//                               color: Colors.grey
//                                   .withOpacity(0.55), // set border color
//                               width: 2.0), // set border width
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(14.0),
//                           ) // set rounded corneRr radius
//                           ),
//                       child: TextFormField(
//                         //focusNode: _nodeText2,
//                         initialValue: _childName.toString(),
//                         cursorColor:
//                             Theme.of(context).textTheme.titleMedium!.color,
//                         // validator: (value) => value!.isEmpty
//                         //     ? "Please enter password"
//                         //     : null,
//                         onSaved: (value) => _childName = value,

//                         decoration: InputDecoration(
//                           hintStyle: TextStyle(
//                               fontSize: 15.0,
//                               fontFamily: 'SourceSansPro-regular',
//                               color: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium!
//                                   .color!
//                                   .withOpacity(0.3)),
//                           border: InputBorder.none,
//                         ),
//                         style: TextStyle(color: Colors.black, fontSize: 14),
//                       ),
//                     ),
//                     Container(
//                       width: 400,
//                       height: 63,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       padding:
//                           EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                       child: ElevatedButton(
//                         onPressed: _loadingRenameTownhall
//                             ? null
//                             : () async {
//                                 FocusScope.of(contextE).unfocus();
//                                 final form3 = _formKey3.currentState;
//                                 form3!.save();

//                                 if (_childName == null || _childName == '') {
//                                   setState(() {
//                                     _loadingRenameTownhall = false;
//                                   });
//                                   final snackBar = SnackBar(
//                                       backgroundColor: Colors.red,
//                                       content: Text("Please enter child name"));
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(snackBar);
//                                 } else {
//                                   print(_childName);
//                                   setState(() {
//                                     _loadingRenameTownhall = true;
//                                   });
//                                   Map<String, dynamic> map = Map();
//                                   map["townhall_id"] = _selectedNode.parentID;
//                                   map["new_name"] = _childName;
//                                   print(map);
//                                   BlocProvider.of<OrganizationBloc>(context)
//                                       .add(
//                                     RenameCustomTownhallEvent(
//                                         renameCustomTownhallRequest: map),
//                                   );
//                                 }
//                               },
//                         child: _loadingRenameTownhall
//                             ? SpinKitWave(
//                                 color: Colors.grey,
//                                 size: 15.0,
//                               )
//                             : Text(
//                                 'Edit Name',
//                                 style: TextStyle(
//                                     fontSize: 20, color: Colors.white),
//                               ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _loadingRenameTownhall
//                               ? Colors.grey.withOpacity(0.5)
//                               : Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(12), // <-- Radius
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   _showDelDialogue(MyNode node) {
//     return showDialog(
//       context: context,
//       barrierColor: Colors.grey.withOpacity(0.5),
//       barrierDismissible: false,
//       builder: (contextD) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(12),
//             ),
//           ),
//           title: Align(
//             alignment: Alignment.topRight,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(
//                 Icons.close,
//                 size: 20,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Text(
//                   node.sideTitle.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22.0,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Are you sure you want to delete this townhall?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16.0,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'All townhalls under this townhalls will be deleted',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16.0,
//                 ),
//               ),
//               Container(
//                 width: 400,
//                 height: 63,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 padding: EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     Map<String, dynamic> map = Map();
//                     map["townhall_id"] = _selectedNode.townhallID;
//                     print(map);
//                     print("map " + _selectedNode.townhallID.toString());
//                     BlocProvider.of<OrganizationBloc>(context).add(
//                       DeleteCustomTownhallEvent(
//                           deleteCustomTownhallRequest: map),
//                     );
//                   },
//                   child: Text(
//                     'Yes',
//                     style: TextStyle(fontSize: 20, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // <-- Radius
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Container(
//                 width: 400,
//                 height: 63,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 padding: EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context, rootNavigator: true).pop();
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(fontSize: 20, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // <-- Radius
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _renameChild(String townhallID, String newName) {
//     setState(() {
//       _selectedNode.sideTitle = newName;
//     });
//   }

//   void _removeNode(String nodeId) {
//     setState(() {
//       _removeNodeById(_roots, nodeId);
//       _treeController.rebuild();
//     });
//   }

//   void _removeNodeById(List<MyNode> nodes, String parentID) {
//     for (var node in nodes) {
//       if (node.townhallID == parentID) {
//         nodes.remove(node);
//         break;
//       }
//       if (node.children != null) {
//         _removeNodeById(node.children.cast<MyNode>(), parentID);
//       }
//     }
//   }

//   MyNode? _findNodeById(List<MyNode> nodes, String townhallID) {
//     for (var node in nodes) {
//       print(node.townhallID == townhallID);
//       if (node.townhallID == townhallID) {
//         return node;
//       }
//       if (node.children != null) {
//         final foundNode =
//             _findNodeById(node.children!.cast<MyNode>(), townhallID);
//         if (foundNode != null) {
//           return foundNode;
//         }
//       }
//     }
//     return null;
//   }

//   _showNotification(String message, String messageType, bool canDismiss) {
//     return showDialog(
//       context: context,
//       barrierDismissible: canDismiss,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(8.0),
//             ),
//           ),
//           content: Stack(
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Container(height: 10.0),
//                   Text(
//                     messageType,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Container(height: 20.0),
//                   Row(
//                     children: <Widget>[Text(message)],
//                   ),
//                 ],
//               ),
//               // Positioned.fill(
//               //   child: Align(
//               //     alignment: Alignment.topRight,
//               //     child: ClipOval(
//               //       child: Material(
//               //         elevation: 5,
//               //         color: Colors.blueGrey, // button color
//               //         child: InkWell(
//               //           splashColor: Colors.red, // inkwell color
//               //           child: SizedBox(
//               //               width: 25,
//               //               height: 25,
//               //               child: Icon(
//               //                 Icons.close,
//               //                 size: 20,
//               //                 color: Colors.white,
//               //               )),
//               //           onTap: () {
//               //             Navigator.pop(context);
//               //           },
//               //         ),
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// void _clearFeedCache() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   Set<String> keys = prefs.getKeys();
//   List<String> filteredKeys =
//       keys.where((key) => key.contains("page_feed_")).toList();
//   List<String> filteredTopKeys =
//       keys.where((key) => key.contains("page_feed_top_")).toList();
//   prefs.setString('orgID', '');
//   prefs.setString('orgName', '');
//   prefs.setString('groupID', '');
//   if (filteredKeys.length > 0) {
//     for (var i = 0; i < filteredKeys.length; i++) {
//       await AppSharedPreferences.removeValue(key: '${filteredKeys[i]}');
//     }
//   }
//   if (filteredTopKeys.length > 0) {
//     for (var i = 0; i < filteredTopKeys.length; i++) {
//       await AppSharedPreferences.removeValue(key: '${filteredKeys[i]}');
//     }
//   }
// }

// class SelectedPostable {
//   String name;
//   String pic;
//   bool is_checked;

//   SelectedPostable(this.name, this.pic, this.is_checked);
// }

// class SelectedAvailable {
//   String name;
//   String pic;
//   bool is_checked;
//   SelectedAvailable(this.name, this.pic, this.is_checked);
// }

// class MyNode {
//   MyNode({
//     this.title,
//     this.sideTitle,
//     this.parentID,
//     this.townhallID,
//     this.levelID,
//     List<MyNode>?
//         children, // Making children nullable to assign it in the constructor
//   }) : children = children ?? [];

//   String? title;
//   String? sideTitle;
//   String? parentID;
//   String? townhallID;
//   int? levelID;
//   List<MyNode> children;
// }
