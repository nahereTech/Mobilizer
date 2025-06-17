// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:nahere/bloc/search/organization_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:nahere/common/common/constants.dart';
// import 'package:nahere/common/common/sharepreference.dart';
// import 'package:nahere/models/organization/my_organization_response.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
// import 'package:nahere/models/organization/organization_plan_response.dart';
// import 'package:nahere/models/organization/organization_tree_response.dart';
// import 'package:nahere/pages/organization/add_organizations.dart';
// import 'package:nahere/pages/organization/my_organizations.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';

// class OrganizationEdit extends StatefulWidget {
//   static String routeName = 'organization_edit_screen';
//   const OrganizationEdit({Key? key}) : super(key: key);

//   @override
//   State<OrganizationEdit> createState() => _OrganizationEditState();
// }

// class _OrganizationEditState extends State<OrganizationEdit> {
//   MyNode _selectedNode = MyNode();
//   final picker = ImagePicker();
//   File? _imageLogo;
//   File? _imageBanner;

//   String _tree_id = "";
//   String _orgID = '';
//   String _selectedPlanID = '';
//   String _selectedPlanDesc = '';
//   String _selectedStatus = '';
//   String _orgLogo = '';
//   String _orgBanner = '';
//   int _selectedLevel = -1;
//   int _selectedIndex = -1;

//   bool _loadingAddTownhall = false;
//   bool _loadingCustomTownhall = false;
//   bool _loadingRenameTownhall = false;
//   bool _loadingDeleteTownhall = false;
//   bool memberRequiredConfirmation = false;
//   bool privateOrganization = false;
//   bool _loadingPlan = true;
//   bool _hasChildren = false;
//   bool _hasNextSibling = false;
//   String message = "";
//   var _childName;
//   bool _active_status = false;

//   List<Postable> postableList = [];
//   List<Available> availableList = [];
//   List<dynamic> avail = [];
//   List<dynamic> post = [];
//   List<dynamic> statusData = ['Active', 'Inactive'];
//   List<PlanData> planData = [];
//   Data? treeData;
//   List<MyNode> _roots = <MyNode>[];

//   final _formKey1 = GlobalKey<FormState>();
//   final _formKey2 = GlobalKey<FormState>();
//   final _formKey3 = GlobalKey<FormState>();
//   final _controllerOrgName = TextEditingController();
//   final _controllerOrgDescription = TextEditingController();
//   final _controllerOrgUsername = TextEditingController();
//   final _controllerOrgPlan = TextEditingController();
//   final _controllerOrgStatus = TextEditingController();
//   final _controllerPassword = TextEditingController();
//   late final TreeController<MyNode> _treeController;

//   void initState() {
//     Future.delayed(Duration.zero, () {
//       final orgData =
//           ModalRoute.of(context)!.settings.arguments as OrganizationData;
//       _orgLogo = orgData.org_image!;
//       _orgBanner = orgData.org_banner;
//       _active_status = orgData.active_status == "yes" ? true : false;
//       _controllerOrgPlan.text =
//           orgData.org_plan_name != null ? orgData.org_plan_name! : '';

//       _selectedPlanDesc =
//           orgData.org_plan_name != null ? orgData.org_plan_name! : '';
//       print("Print: ${_selectedPlanDesc}");
//       _controllerOrgDescription.text = orgData.org_desc!;
//       _controllerOrgName.text = orgData.org_name!;
//       _controllerOrgUsername.text = orgData.org_username!;
//       _selectedPlanID = orgData.org_plan!.toString();
//       privateOrganization = orgData.org_privacy == "open" ? true : false;
//       memberRequiredConfirmation =
//           orgData.requires_confirmation == "yes" ? true : false;
//       _treeController = TreeController<MyNode>(
//         // Provide the root nodes that will be used as a starting point when
//         // traversing your hierarchical data.
//         roots: _roots,
//         // Provide a callback for the controller to get the children of a
//         // given node when traversing your hierarchical data. Avoid doing
//         // heavy computations in this method, it should behave like a getter.
//         childrenProvider: (MyNode node) => node.children,
//       );
//       BlocProvider.of<OrganizationBloc>(context)
//           .add(GetOrganizationPlanEvent());

//       if (orgData.available_townhalls != null) {
//         for (AvailableTownhallData available in orgData.available_townhalls!) {
//           var status = available.is_checked == "yes" ? true : false;
//           availableList.add(
//             Available(available.name, available.pic, status),
//           );
//         }
//         print(availableList[0].pic);
//       }
//       if (orgData.postable_townhalls != null) {
//         for (PostableTownhallData postable in orgData.postable_townhalls!) {
//           var status = postable.is_checked == "yes" ? true : false;
//           postableList.add(
//             Postable(postable.name, postable.pic, status),
//           );
//         }
//       }
//       if (_selectedPlanID == "3") {
//         BlocProvider.of<OrganizationBloc>(context).add(GetOrganizationTreeEvent(
//             tree: '1', org_id: orgData.org_id.toString()));
//         setState(() {
//           _loadingCustomTownhall = true;
//         });
//       }
//     });

//     super.initState();
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.pop(context, 'refresh');
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     OrganizationData _data =
//         ModalRoute.of(context)!.settings.arguments as OrganizationData;
//     _orgID = _data.org_id.toString();

//     return WillPopScope(
//       onWillPop: () async => !Loader.isShown,
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: BlocConsumer<OrganizationBloc, OrganizationState>(
//               listener: (context, state) {
//             if (state is GetOrganizationTreeState) {
//               treeData = state.getOrganizationTreeResponse.data;
//               setState(() {
//                 _buildTreeNodes(treeData!);
//                 _loadingCustomTownhall = false;
//                 _tree_id = treeData!.id.toString();
//               });
//             }
//             if (state is CreateCustomTownhallState) {
//               print("Am here2");
//               Navigator.pop(context);
//               var townhallID =
//                   state.createCustomTownhallResponse.data!.townhall_id;

//               setState(() {
//                 _loadingAddTownhall = false;
//                 _loadingCustomTownhall = false;
//                 _selectedLevel =
//                     _selectedLevel == _selectedNode.levelID! && _hasChildren
//                         ? _selectedLevel
//                         : _selectedNode.levelID! + 1;
//                 _selectedNode.children.add(
//                   MyNode(
//                       title: _selectedLevel == _selectedNode.levelID
//                           ? ''
//                           : 'LEVEL ${_selectedLevel.toString()}',
//                       sideTitle: _childName,
//                       parentID: _selectedNode.townhallID,
//                       townhallID: townhallID.toString(),
//                       levelID: _selectedLevel),
//                 );

//                 _treeController.rebuild();
//                 _treeController.expandAll();
//               });

//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Townhall was successfully created"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               // Future.delayed(Duration(seconds: 5), () {
//               //   Navigator.pop(context);
//               // });
//             }
//             if (state is AddCustomTownhallLoadingState) {
//               setState(() {
//                 _loadingAddTownhall = true;
//               });
//             }
//             if (state is RenameCustomTownhallLoadingState) {
//               setState(() {
//                 _loadingRenameTownhall = true;
//               });
//             }
//             if (state is DeleteCustomTownhallLoadingState) {
//               setState(() {
//                 _loadingDeleteTownhall = true;
//               });
//             }
//             if (state is RenameCustomTownhallState) {
//               _renameChild(_selectedNode.townhallID!, _childName);
//               setState(() {
//                 _loadingRenameTownhall = false;
//                 _loadingCustomTownhall = false;
//               });
//               Navigator.pop(context);
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Townhall was successfully edited"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//             if (state is DeleteCustomTownhallState) {
//               // _removeParent(_positionID);

//               Navigator.pop(context);
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Townhall was successfully removed"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);

//               setState(() {
//                 _loadingDeleteTownhall = false;
//                 _removeNode(_selectedNode.townhallID!);
//               });
//             }
//             if (state is GetOrganizationPlanState) {
//               planData = state.getOrganizationPlanResponse.data!;
//             }
//             if (state is UpdateOrganizationState) {
//               Loader.hide();
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Group was successfully updated"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               var pageData = getPageData('page_my_organization');
//             }
//             if (state is VerifyPasswordState) {
//               print("Am inside verify password state");
//               setState(() {
//                 message = "Deleting...";
//               });
//               BlocProvider.of<OrganizationBloc>(context)
//                   .add(DeleteEvent(org_id: _orgID));
//             }
//             if (state is DeleteOrganizationState) {
//               print("Am inside the delete state");
//               //remove the organization from the cached data in the list
//               _deleteCachedData(_orgID);
//               setState(() {
//                 message = "";
//                 Loader.hide();
//               });

//               //show snack bar
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Group was successfully Deleted"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               Future.delayed(Duration(seconds: 5), () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return BlocProvider(
//                     create: (context) => OrganizationBloc(),
//                     child: MyOrganizationsScreen(),
//                   );
//                 }));
//               });
//             }
//             if (state is UpdateOrgBannerState) {
//               setState(() {
//                 _orgBanner = state.image!;
//               });
//               Loader.hide();
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Successfully uploaded"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               _updateCachedData(_orgID, _orgBanner, '');
//             }
//             if (state is UpdateOrgLogoState) {
//               setState(() {
//                 _orgLogo = state.image!;
//               });
//               print("Update Logo: ${state.image!}");
//               Loader.hide();
//               final snackBar = SnackBar(
//                   backgroundColor: Color.fromARGB(255, 85, 207, 132),
//                   content: Text("Successfully uploaded"));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               _updateCachedData(_orgID, '', _orgLogo);
//             }
//             if (state is NetworkState) {
//               setState(() {
//                 Loader.hide();
//               });
//               print(state.message);
//               // loading = false;
//               final snackBar = SnackBar(
//                   backgroundColor: Color(0xFFcf5555),
//                   content: Text(state.message.toString()));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//             if (state is OrganizationErrorState) {
//               setState(() {
//                 Loader.hide();
//               });
//               print(state.message);
//               // loading = false;
//               final snackBar = SnackBar(
//                   backgroundColor: Color(0xFFcf5555),
//                   content: Text(state.message.toString()));
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//           }, builder: (context, state) {
//             return Column(
//               children: [
//                 Stack(
//                     alignment: AlignmentDirectional.center,
//                     clipBehavior: Clip.none,
//                     children: [
//                       _orgBanner == ""
//                           ? SizedBox()
//                           : Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 4.0, vertical: 32.0),
//                               height: size.height - 625,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 border: Border(
//                                   bottom: BorderSide(
//                                     color: Colors.grey,
//                                     width: 3.0,
//                                   ),
//                                 ),
//                                 image: DecorationImage(
//                                     image: NetworkImage("${_orgBanner}"),
//                                     fit: BoxFit.cover),
//                               ),
//                               child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     IconButton(
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       },
//                                       iconSize: 25,
//                                       icon: FaIcon(
//                                         FontAwesomeIcons.arrowLeft,
//                                         size: 25,
//                                         color: Colors.blue,
//                                       ),
//                                     ),

//                                     // Container(
//                                     //   decoration: BoxDecoration(
//                                     //       color: Colors.orange, shape: BoxShape.circle),
//                                     //   child: IconButton(
//                                     //     onPressed: () {
//                                     //       Navigator.pop(context);
//                                     //       print("back was clicked");
//                                     //     },
//                                     //     iconSize: 25,
//                                     //     icon: FaIcon(
//                                     //       FontAwesomeIcons.arrowLeft,
//                                     //       size: 25,
//                                     //       color: Colors.white,
//                                     //     ),
//                                     //   ),
//                                     // ),
//                                     SizedBox(
//                                       height: 28,
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(top: 8),
//                                         child: IconButton(
//                                             alignment: Alignment.topRight,
//                                             icon: Icon(Icons.edit,
//                                                 color: Colors.grey),
//                                             iconSize: 20.0,
//                                             onPressed: () {
//                                               selectImageSource('banner');
//                                             }),
//                                       ),
//                                     ),
//                                   ]),
//                             ),
//                       Positioned(
//                         top: size.height - 675,
//                         child: _orgLogo == ''
//                             ? SizedBox()
//                             : Stack(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 63,
//                                     backgroundColor: Colors.grey,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(75),
//                                       child: Image.network(
//                                         "${_orgLogo}",
//                                         width: 120,
//                                         height: 120,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: 50,
//                                     height: 50,
//                                     child: Center(
//                                       child: MaterialButton(
//                                         shape: CircleBorder(
//                                           side: BorderSide(
//                                             width: 2,
//                                             color: Colors.white,
//                                             style: BorderStyle.solid,
//                                           ),
//                                         ),
//                                         child: Icon(
//                                           Icons.camera_alt,
//                                           size: 20.0,
//                                         ),
//                                         color: Colors.white,
//                                         textColor: Colors.blue,
//                                         onPressed: () {
//                                           selectImageSource('logo');
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                       )
//                     ]),
//                 SizedBox(
//                   height: 100,
//                 ),
//                 Form(
//                   key: _formKey1,
//                   child: Container(
//                     padding: EdgeInsets.only(top: 10),
//                     width: double.infinity,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 32),
//                           child: TextFormField(
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                   RegExp("[0-9a-zA-Z]"))
//                             ],
//                             onChanged: (value) {
//                               // _controllerUserName.value =
//                               TextEditingValue(
//                                   text: value.toLowerCase().trim(),
//                                   selection: _controllerOrgName.selection);
//                             },
//                             //readOnly: _disableUsername,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15.0)),
//                                 hintText: 'Enter Organization Name'),
//                             controller: _controllerOrgName,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter Organization name';
//                               }
//                               elseif(validateUsername(value)) {
//                                 return 'Invalid Organization name';
//                               }

//                               return null;
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 20),
//                           child: TextFormField(
//                             minLines: 3,
//                             maxLines: 5,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                   RegExp("[0-9a-zA-Z]"))
//                             ],
//                             onChanged: (value) {
//                               // _controllerUserName.value =
//                               TextEditingValue(
//                                   text: value.toLowerCase().trim(),
//                                   selection:
//                                       _controllerOrgDescription.selection);
//                             },
//                             //readOnly: _disableUsername,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15.0)),
//                                 hintText:
//                                     'Enter Description for your organization'),
//                             controller: _controllerOrgDescription,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter Organization description';
//                               }

//                               return null;
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 0),
//                           child: TextFormField(
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                   RegExp("[0-9a-zA-Z]"))
//                             ],
//                             onChanged: (value) {
//                               // _controllerUserName.value =
//                               TextEditingValue(
//                                   text: value.toLowerCase().trim(),
//                                   selection: _controllerOrgUsername.selection);
//                             },
//                             readOnly: true,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15.0)),
//                                 hintText: 'Enter Organization Username'),
//                             controller: _controllerOrgUsername,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter username';
//                               }

//                               return null;
//                             },
//                           ),
//                         ),
//                         Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 20, right: 35, top: 20, bottom: 10),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Checkbox(
//                                       value: memberRequiredConfirmation,
//                                       onChanged: (val) {
//                                         setState(() {
//                                           memberRequiredConfirmation = val!;
//                                         });
//                                       }),
//                                 ),
//                                 Flexible(
//                                   child: Container(
//                                     width: 300,
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
//                                   ),
//                                 )
//                               ],
//                             )),
//                         Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 20, right: 35, top: 20, bottom: 10),
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
//                                 Flexible(
//                                   child: Container(
//                                     width: 300,
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           SizedBox(
//                                             height: 12,
//                                           ),
//                                           Text(
//                                             "Private Organization",
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                           SizedBox(height: 5),
//                                           Text(
//                                             "If checked, your organization will not be found through the search box but through invitation link sent by you",
//                                             style:
//                                                 TextStyle(color: Colors.grey),
//                                           ),
//                                         ]),
//                                   ),
//                                 )
//                               ],
//                             )),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 20),
//                           child: TextFormField(
//                             readOnly: true,
//                             decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15.0)),
//                                 labelText: '-- Choose plan --',
//                                 hintText: 'Plan'),
//                             controller: _controllerOrgPlan,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please select a plan';
//                               }

//                               return null;
//                             },
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext contextTwo) {
//                                   return AlertDialog(
//                                     scrollable: true,
//                                     title: Text('Select Plan'),
//                                     content: Container(
//                                       height: 200.0,
//                                       width: 400.0,
//                                       child: ListView.builder(
//                                         shrinkWrap: true,
//                                         itemCount: planData.length,
//                                         itemBuilder: (BuildContext contextOne,
//                                             int index) {
//                                           return ListTile(
//                                             title: Text(planData[index].name),
//                                             onTap: () {
//                                               setState(() {
//                                                 _selectedPlanID =
//                                                     planData[index]
//                                                         .id
//                                                         .toString();
//                                                 _selectedPlanDesc =
//                                                     planData[index].desc;
//                                                 _controllerOrgPlan.text =
//                                                     planData[index].name;
//                                               });

//                                               Navigator.of(contextTwo,
//                                                       rootNavigator: true)
//                                                   .pop();
//                                             },
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                         _selectedPlanDesc != ""
//                             ? Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 32, vertical: 5),
//                                 child: Text("*${_selectedPlanDesc}"),
//                               )
//                             : SizedBox(),
//                         Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 10),
//                             child: Divider(thickness: 1.0)),
//                         if (_selectedPlanID == '3')
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 18),
//                             child: _loadingCustomTownhall
//                                 ? SpinKitWave(
//                                     color: Colors.grey,
//                                     size: 15.0,
//                                   )
//                                 : Container(
//                                     height: 300,
//                                     width: double.infinity,
//                                     child: AnimatedTreeView<MyNode>(
//                                       shrinkWrap: true,
//                                       treeController: _treeController,
//                                       nodeBuilder: (BuildContext context,
//                                           TreeEntry<MyNode> entry) {
//                                         // Provide a widget to display your tree nodes in the tree view.
//                                         //
//                                         // Can be any widget, just make sure to include a [TreeIndentation]
//                                         // within its widget subtree to properly indent your tree nodes.
//                                         return _myTreeTile(
//                                             // Add a key to your tiles to avoid syncing descendant animations.
//                                             // key: ValueKey(entry.node),
//                                             // Your tree nodes are wrapped in TreeEntry instances when traversing
//                                             // the tree, these objects hold important details about its node
//                                             // relative to the tree, like: expansion state, level, parent, etc.
//                                             //
//                                             // TreeEntrys are short lived, each time TreeController.rebuild is
//                                             // called, a new TreeEntry is created for each node so its properties
//                                             // are always up to date.
//                                             entry,
//                                             // Add a callback to toggle the expansion state of this node.
//                                             () => _treeController
//                                                 .toggleExpansion(entry.node),
//                                             context);
//                                       },
//                                     ),
//                                   ),
//                           ),
//                         if (_selectedPlanID == '3' &&
//                             _loadingCustomTownhall == false)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 1),
//                             child: Divider(
//                               thickness: 1.0,
//                             ),
//                           ),
//                         if (availableList.length > 0 &&
//                             _selectedPlanID != '' &&
//                             _selectedPlanID != '1' &&
//                             _selectedPlanID != '3')
//                           _showAvailable(),
//                         if (postableList.length > 0 &&
//                             _selectedPlanID != '' &&
//                             _selectedPlanID != '1' &&
//                             _selectedPlanID != '3')
//                           _showPostable(),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 5),
//                           child: Row(
//                             children: [
//                               Switch(
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _active_status = value;
//                                   });
//                                 },
//                                 value: _active_status,
//                                 activeColor: Colors.blue,
//                                 activeTrackColor: Colors.grey,
//                                 inactiveTrackColor: Colors.grey,
//                               ),
//                               SizedBox(
//                                 width: 7,
//                               ),
//                               Text(
//                                 "${_active_status ? 'Active' : 'Inactive'}",
//                               )
//                             ],
//                           ),
//                         ),
//                         Container(
//                           width: 370,
//                           height: 75,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           padding: EdgeInsets.only(
//                               left: 16.0, right: 16.0, top: 26.0),
//                           child:
//                               BlocListener<OrganizationBloc, OrganizationState>(
//                             listener: (context, state) {
//                               //your state here
//                             },
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 if (_formKey1.currentState!.validate()) {
//                                   Map<String, dynamic> map = Map();
//                                   if (availableList.length > 0) {
//                                     var i = 0;
//                                     for (Available obj in availableList) {
//                                       if (obj.is_checked) {
//                                         avail.add({
//                                           'name': obj.name,
//                                           'pic': obj.pic,
//                                           'is_checked':
//                                               obj.is_checked ? 'yes' : 'no'
//                                         });
//                                         map["available_townhalls[" +
//                                             i.toString() +
//                                             "]"] = {
//                                           'name': obj.name,
//                                           'pic': obj.pic,
//                                           'is_checked': "yes"
//                                         };
//                                         i++;
//                                       }
//                                     }
//                                   }
//                                   if (postableList.length > 0) {
//                                     var i = 0;
//                                     for (Postable obj in postableList) {
//                                       if (obj.is_checked) {
//                                         post.add({
//                                           'name': obj.name,
//                                           'pic': obj.pic,
//                                           'is_checked':
//                                               obj.is_checked ? 'yes' : 'no'
//                                         });
//                                         map["postable_townhalls[" +
//                                             i.toString() +
//                                             "]"] = {
//                                           'name': obj.name,
//                                           'pic': obj.pic,
//                                           'is_checked': "yes"
//                                         };
//                                         i++;
//                                       }
//                                     }
//                                   }
//                                   if (_selectedPlanID == '3') {
//                                     map["tree_view_id"] = _tree_id;
//                                   }

//                                   map["org_id"] = _orgID.toString();
//                                   map["org_name"] = _controllerOrgName.text;
//                                   map["org_desc"] =
//                                       _controllerOrgDescription.text;
//                                   map["active_status"] =
//                                       _active_status ? "yes" : "no";
//                                   map["org_plan"] = _selectedPlanID;
//                                   map["requires_confirmation"] =
//                                       memberRequiredConfirmation == true
//                                           ? "yes"
//                                           : "no";
//                                   map["org_privacy"] =
//                                       privateOrganization ? "open" : "close";
//                                   print("updateData: ${map}");
//                                   BlocProvider.of<OrganizationBloc>(context)
//                                       .add(
//                                     UpdateOrganizationEvent(
//                                         updateOrganizationRequest: map),
//                                   );
//                                   Loader.show(
//                                     context,
//                                     //isSafeAreaOverlay: false,
//                                     //isBottomBarOverlay: false,
//                                     //overlayFromBottom: 80,
//                                     overlayColor: Colors.black26,
//                                     progressIndicator: Container(
//                                       width: 200.0,
//                                       height: 120.0,
//                                       child: Column(
//                                         children: [
//                                           SpinKitCircle(
//                                             color: Colors.blue,
//                                             size: 45.0,
//                                           ),
//                                           Text(
//                                             'Creating...',
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 decoration: TextDecoration.none,
//                                                 color: Colors.black54),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: Text(
//                                 'Update',
//                                 style: TextStyle(fontSize: 20),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(12), // <-- Radius
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 30),
//                           child: GestureDetector(
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext contextA) {
//                                   return AlertDialog(
//                                     scrollable: true,
//                                     title: Center(
//                                       child: Text(
//                                         "Password Verification",
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                     content: Padding(
//                                       padding:
//                                           EdgeInsets.only(top: 1, bottom: 1),
//                                       child: Form(
//                                         child: Column(
//                                           children: [
//                                             // Text(
//                                             //     "Password is need to proceed"),
//                                             TextFormField(
//                                               obscureText: true,
//                                               decoration: InputDecoration(
//                                                   border: OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15.0)),
//                                                   hintText: 'Password'),
//                                               controller: _controllerPassword,
//                                               validator: (value) {
//                                                 if (value == null ||
//                                                     value.isEmpty) {
//                                                   return 'Please enter password';
//                                                 }

//                                                 return null;
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     actions: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 17.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             ElevatedButton(
//                                               child: const Text("Cancel"),
//                                               style: ElevatedButton.styleFrom(
//                                                   // primary: Colors
//                                                   //     .grey, // Background color
//                                                   backgroundColor: Colors.grey),
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                               },
//                                             ),
//                                             ElevatedButton(
//                                               child: const Text("Proceed"),
//                                               onPressed: () async {
//                                                 Navigator.pop(context);
//                                                 if (_controllerPassword.text ==
//                                                     "") {
//                                                   final snackBar = SnackBar(
//                                                       backgroundColor:
//                                                           Color(0xFFcf5555),
//                                                       content: Text(
//                                                           "You need to provide a valid password"));
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(snackBar);
//                                                 } else {
//                                                   BlocProvider.of<
//                                                               OrganizationBloc>(
//                                                           context)
//                                                       .add(
//                                                     VerifyPasswordEvent(
//                                                         password:
//                                                             _controllerPassword
//                                                                 .text),
//                                                   );
//                                                   setState(() {
//                                                     message = "Validating...";
//                                                   });
//                                                   Loader.show(
//                                                     context,
//                                                     //isSafeAreaOverlay: false,
//                                                     //isBottomBarOverlay: false,
//                                                     //overlayFromBottom: 80,
//                                                     overlayColor:
//                                                         Colors.black26,
//                                                     progressIndicator:
//                                                         Container(
//                                                       width: 200.0,
//                                                       height: 120.0,
//                                                       child: Column(
//                                                         children: [
//                                                           SpinKitCircle(
//                                                             color: Colors.blue,
//                                                             size: 45.0,
//                                                           ),
//                                                           Text(
//                                                             '${message}',
//                                                             style: TextStyle(
//                                                                 fontSize: 17,
//                                                                 decoration:
//                                                                     TextDecoration
//                                                                         .none,
//                                                                 color: Colors
//                                                                     .black54),
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }
//                                                 // your code
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );

//                               // Alert(
//                               //   context: context,
//                               //   style: AlertStyle(
//                               //       titleStyle: TextStyle(
//                               //           fontWeight: FontWeight.bold),
//                               //       overlayColor: Colors.black54),
//                               //   title: "Confirm",
//                               //   desc: "Are you sure",
//                               //   buttons: [
//                               //     DialogButton(
//                               //       color: Colors.black45,
//                               //       child: Text(
//                               //         "No",
//                               //         style: TextStyle(
//                               //             color: Colors.white, fontSize: 20),
//                               //       ),
//                               //       onPressed: () {
//                               //         Navigator.pop(context);
//                               //       },
//                               //       width: 120,
//                               //     ),
//                               //     DialogButton(
//                               //       child: Text(
//                               //         "Yes",
//                               //         style: TextStyle(
//                               //             color: Colors.white, fontSize: 20),
//                               //       ),
//                               //       onPressed: () {
//                               //         // BlocProvider.of<OrganizationBloc>(context)
//                               //         //     .add(LeaveEvent(org_id: orgID.toString()));
//                               //         // Navigator.pop(context);
//                               //       },
//                               //       width: 120,
//                               //     )
//                               //   ],
//                               // ).show();
//                             },
//                             child: Text(
//                               "Delete Group",
//                               style: TextStyle(
//                                   color: Colors.red,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   void _updateCachedData(String orgID, String bgImage, String logo) async {
//     var pageData = await getPageData('page_my_organization');
//     if (pageData != null) {
//       var json = jsonDecode(pageData);
//       List<OrganizationData> data = json
//           .map<OrganizationData>((json) => OrganizationData.fromJson(json))
//           .toList();
//       int id = _findReturn(data, orgID);
//       print("Index: ${id}");
//       if (id != -1) {
//         if (bgImage != null || bgImage != "") {
//           data[id].org_banner = bgImage;
//           // AppSharedPreferences.setValue(
//           //     //rewrite to cache
//           //     key: 'page_my_organization',
//           //     value: jsonEncode(data));
//         }
//         if (logo != null || logo != "") {
//           data[id].org_image = logo;
//           // AppSharedPreferences.setValue(
//           //     //rewrite to cache
//           //     key: 'page_my_organization',
//           //     value: jsonEncode(data));
//         }
//         if (avail.length > 0) {
//           data[id].available_townhalls = [...avail];
//         }
//         if (post.length > 0) {
//           data[id].postable_townhalls = [...post];
//         }
//         AppSharedPreferences.setValue(
//             //rewrite to cache
//             key: 'page_my_organization',
//             value: jsonEncode(data));
//         print(data);
//       }
//     }
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
//                       // _parentIndex =
//                       //     _roots.indexWhere((item) => item == entry.node);
//                       // _childIndex = entry.node.children.length;
//                       print(entry.index);
//                       _selectedIndex = entry.index;
//                       _selectedLevel = entry.level;
//                       _hasChildren = entry.hasChildren;
//                       _hasNextSibling = entry.hasNextSibling;
//                       _selectedNode = entry.node;
//                     });

//                     _showDialogue(entry.node);
//                     print("Townhall ID " + _selectedNode.townhallID.toString());
//                     print("Parent ID " + _selectedNode.parentID.toString());
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
//                 _hasChildren == false
//                     ? SizedBox()
//                     : _selectedIndex == 0
//                         ? SizedBox()
//                         : Flexible(
//                             flex: 1,
//                             child: InkWell(
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 _showDelDialogue(node);
//                               },
//                               child: Text(
//                                 'Delete Townhall',
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   color: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium!
//                                       .color,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20.0,
//                                   fontFamily: 'SourceSansPro',
//                                 ),
//                               ),
//                             ),
//                           ),
//                 SizedBox(height: 20)
//               ],
//             ),
//           );
//         });
//   }

//   void _deleteCachedData(String orgID) async {
//     var pageData = await getPageData('page_my_organization');
//     if (pageData != null) {
//       var json = jsonDecode(pageData);
//       List<OrganizationData> data = json
//           .map<OrganizationData>((json) => OrganizationData.fromJson(json))
//           .toList();
//       int id = _findReturn(data, orgID);
//       if (id != -1) {
//         data.removeAt(id);
//         if (data.length > 0) {
//           List<int> reindexedData = List.from(data);
//           AppSharedPreferences.setValue(
//               //rewrite to cache
//               key: 'page_my_organization',
//               value: jsonEncode(reindexedData));
//         }
//       }
//     }
//   }

//   _showAddDialogue(MyNode node) {
//     return showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.5),
//         barrierDismissible: false,
//         builder: (contextA) {
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
//             content: Form(
//               key: _formKey2,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Text(
//                       node.sideTitle.toString(),
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22.0,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     width: 380,
//                     height: 55,
//                     // margin: EdgeInsets.only(top: 10),
//                     padding: const EdgeInsets.all(10.0),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(
//                             color: Colors.grey
//                                 .withOpacity(0.55), // set border color
//                             width: 2.0), // set border width
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(14.0),
//                         ) // set rounded corner radius
//                         ),
//                     child: TextFormField(
//                       //focusNode: _nodeText2,
//                       cursorColor:
//                           Theme.of(context).textTheme.titleMedium!.color,
//                       // validator: (value) => value!.isEmpty
//                       //     ? "Please enter password"
//                       //     : null,
//                       onSaved: (value) => _childName = value,
//                       // obscureText:

//                       decoration: InputDecoration(
//                         hintText: 'Townhall',
//                         hintStyle: TextStyle(
//                             fontSize: 15.0,
//                             fontFamily: 'SourceSansPro-regular',
//                             color: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium!
//                                 .color!
//                                 .withOpacity(0.3)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(color: Colors.black, fontSize: 14),
//                     ),
//                   ),
//                   Container(
//                     width: 400,
//                     height: 63,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                     child: ElevatedButton(
//                       onPressed: _loadingAddTownhall
//                           ? null
//                           : () async {
//                               // setState(() {
//                               //   _loadingAddTownhall = true;

//                               // });
//                               final form2 = _formKey2.currentState;
//                               form2!.save();

//                               Map<String, dynamic> map = Map();
//                               map["parent_id"] = _selectedNode.townhallID;
//                               map["child_name"] = _childName;

//                               BlocProvider.of<OrganizationBloc>(context).add(
//                                 CreateCustomTownhallEvent(
//                                     createCustomTownhallRequest: map),
//                               );
//                             },
//                       child: _loadingAddTownhall
//                           ? SpinKitWave(
//                               color: Colors.grey,
//                               size: 15.0,
//                             )
//                           : Text(
//                               'Add Townhall',
//                               style: TextStyle(fontSize: 20),
//                             ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _loadingAddTownhall
//                             ? Colors.grey.withOpacity(0.5)
//                             : Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12), // <-- Radius
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   _showEditDialogue(String parentName) {
//     return showDialog(
//       context: context,
//       barrierColor: Colors.grey.withOpacity(0.5),
//       barrierDismissible: false,
//       builder: (contextE) {
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
//           content: Container(
//             child: Form(
//               key: _formKey3,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Text(
//                       parentName,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22.0,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     width: 300,
//                     height: 50,
//                     // margin: EdgeInsets.only(top: 10),
//                     padding: const EdgeInsets.only(top: 1, left: 12),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(
//                             color: Colors.grey
//                                 .withOpacity(0.55), // set border color
//                             width: 2.0), // set border width
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(14.0),
//                         ) // set rounded corneRr radius
//                         ),
//                     child: TextFormField(
//                       //focusNode: _nodeText2,
//                       initialValue: _childName.toString(),
//                       cursorColor:
//                           Theme.of(context).textTheme.titleMedium!.color,
//                       // validator: (value) => value!.isEmpty
//                       //     ? "Please enter password"
//                       //     : null,
//                       onSaved: (value) => _childName = value,

//                       decoration: InputDecoration(
//                         hintStyle: TextStyle(
//                             fontSize: 15.0,
//                             fontFamily: 'SourceSansPro-regular',
//                             color: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium!
//                                 .color!
//                                 .withOpacity(0.3)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(color: Colors.black, fontSize: 14),
//                     ),
//                   ),
//                   Container(
//                     width: 400,
//                     height: 63,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: EdgeInsets.only(left: 9.0, right: 9.0, top: 18.0),
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         final form3 = _formKey3.currentState;
//                         form3!.save();
//                         // setState(() {
//                         //   _loadingRenameTownhall = true;
//                         // });

//                         if (_childName == null || _childName == '') {
//                           setState(() {
//                             _loadingRenameTownhall = false;
//                           });
//                           final snackBar = SnackBar(
//                               backgroundColor: Colors.red,
//                               content: Text("Please enter child name"));
//                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         } else {
//                           print(_childName);

//                           Map<String, dynamic> map = Map();
//                           map["townhall_id"] = _selectedNode.parentID;
//                           map["new_name"] = _childName;
//                           print(map);
//                           BlocProvider.of<OrganizationBloc>(context).add(
//                             RenameCustomTownhallEvent(
//                                 renameCustomTownhallRequest: map),
//                           );
//                         }
//                       },
//                       child: _loadingRenameTownhall
//                           ? SpinKitWave(
//                               color: Colors.grey,
//                               size: 15.0,
//                             )
//                           : Text(
//                               'Edit Name',
//                               style: TextStyle(fontSize: 20),
//                             ),
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12), // <-- Radius
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
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
//                     BlocProvider.of<OrganizationBloc>(context).add(
//                       DeleteCustomTownhallEvent(
//                           deleteCustomTownhallRequest: map),
//                     );
//                   },
//                   child: _loadingDeleteTownhall
//                       ? SpinKitWave(
//                           color: Colors.grey,
//                           size: 15.0,
//                         )
//                       : Text(
//                           'Yes',
//                           style: TextStyle(fontSize: 20),
//                         ),
//                   style: ElevatedButton.styleFrom(
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
//                     style: TextStyle(fontSize: 20),
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

//   Future<String?> getPageData(String value) async {
//     return AppSharedPreferences.getValue(key: value);
//   }

//   int _findReturn(List<OrganizationData> data, String orgID) {
//     for (var i = 0; i < data.length; i++) {
//       if (data[i].org_id.toString() == orgID) {
//         return i;
//       }
//     }
//     return -1;
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

//         updateProfileImage(selectType);
//       } else if (pickedFile != null && selectType == "banner") {
//         _imageBanner = File(pickedFile.path);
//         var path = pickedFile.path.split('/').last;
//         debugPrint(pickedFile.path);
//         updateProfileImage(selectType);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   void updateProfileImage(String selectType) async {
//     Loader.show(
//       context,
//       //isSafeAreaOverlay: false,
//       //isBottomBarOverlay: false,
//       //overlayFromBottom: 80,
//       overlayColor: Colors.black26,
//       progressIndicator: Container(
//         width: 200.0,
//         height: 120.0,
//         child: Column(
//           children: [
//             SpinKitCircle(
//               color: Colors.blue,
//               size: 45.0,
//             ),
//             Text(
//               'Uploading...',
//               style: TextStyle(
//                   fontSize: 17,
//                   decoration: TextDecoration.none,
//                   color: Colors.black54),
//             )
//           ],
//         ),
//       ),
//     );
//     if (selectType == "logo") {
//       List<int> imageBytesOne = File(_imageLogo!.path).readAsBytesSync();
//       String photoBase64One = base64Encode(imageBytesOne);
//       final logo = 'data:image/jpeg;base64,' + photoBase64One;
//       print(logo);
//       BlocProvider.of<OrganizationBloc>(context)
//           .add(UpdateOrgLogoEvent(org_id: _orgID, pic: logo));
//     }
//     if (selectType == "banner") {
//       List<int> imageBytesOne = File(_imageBanner!.path).readAsBytesSync();
//       String photoBase64One = base64Encode(imageBytesOne);
//       final banner = 'data:image/jpeg;base64,' + photoBase64One;
//       print(banner);
//       BlocProvider.of<OrganizationBloc>(context)
//           .add(UpdateOrgBannerEvent(org_id: _orgID, pic: banner));
//     }
//   }

//   Widget _showAvailable() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
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
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           SizedBox(
//             height: 55,
//           ),
//           Wrap(children: [
//             Container(
//               width: double.infinity,
//               height: 150,
//               child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: postableList.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     final available = availableList[index];
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
//                                 '${available.pic}',
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
//                             "${available.name}",
//                             style: TextStyle(fontSize: 17),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Transform.scale(
//                             scale: 1.3,
//                             child: Checkbox(
//                               value: availableList[index].is_checked,
//                               onChanged: (value) {
//                                 setState(() {
//                                   availableList[index].is_checked =
//                                       !availableList[index].is_checked;
//                                 });
//                                 print(availableList[index].is_checked);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//             ),
//           ]),
//           Divider(
//             thickness: 1.0,
//           )
//         ],
//       ),
//     );
//   }

//   void _buildTreeNodes(Data node) {
//     _roots.add(MyNode(
//       sideTitle: node.name,
//       title: node.level_name,
//       parentID: node.parent_id.toString(),
//       townhallID: node.id.toString(),
//       levelID: node.level,
//       children: node.children != null
//           ? node.children!.map((child) => _buildTreeNode(child)).toList()
//           : null,
//     ));
//     _treeController.rebuild();
//     _treeController.expandAll();
//   }

//   MyNode _buildTreeNode(Data node) {
//     return MyNode(
//       sideTitle: node.name,
//       title: node.level_name,
//       parentID: node.parent_id.toString(),
//       townhallID: node.id.toString(),
//       levelID: node.level,
//       children: node.children != null
//           ? node.children!.map((child) => _buildTreeNode(child)).toList()
//           : null,
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

//   Widget _showPostable() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
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
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           SizedBox(
//             height: 55,
//           ),
//           Wrap(children: [
//             Container(
//               width: double.infinity,
//               height: 150,
//               child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: postableList.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     // final post = postableList[index];
//                     // selectedPostableList.add(SelectedPostable(
//                     //     post.name, post.pic.toString(), false));
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
//                                 '${postableList[index].pic}',
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
//                             "${postableList[index].name}",
//                             style: TextStyle(fontSize: 17),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Transform.scale(
//                             scale: 1.3,
//                             child: Checkbox(
//                               value: postableList[index].is_checked,
//                               onChanged: (value) {
//                                 setState(() {
//                                   postableList[index].is_checked =
//                                       !postableList[index].is_checked;
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
//           Divider(
//             thickness: 1.0,
//           )
//         ],
//       ),
//     );
//   }
// }

// class Postable {
//   String name;
//   String pic;
//   bool is_checked;

//   Postable(this.name, this.pic, this.is_checked);
// }

// class Available {
//   String name;
//   String pic;
//   bool is_checked;
//   Available(this.name, this.pic, this.is_checked);
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
