// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:nahere/bloc/auth/auth_bloc.dart';
// import 'package:nahere/common/common/navigation.dart';
// import 'package:nahere/pages/login/login.dart';
// import 'package:timer_snackbar/timer_snackbar.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:nahere/common/common/constants.dart';

// class Register2Screen extends StatefulWidget {
//   static String routeName = 'register2_screen';

//   const Register2Screen({Key? key}) : super(key: key);

//   @override
//   _Register2ScreenState createState() => _Register2ScreenState();
// }

// class _Register2ScreenState extends State<Register2Screen> {
//   final _controllerEmail = TextEditingController();
//   var loadingPercentage = 0;
//   bool loading = false;
//   // late WebViewController _controller;
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();

//     // _controller.loadUrl(
//     //     'https://townhall.empl-dev.site/organizations/orgreg?5f535cc1cc0954fc8021f2dfa5ad82b5&from=app');
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("${loadingPercentage}");
//     Size size = MediaQuery.of(context).size;
//     return Stack(
//       children: [
//         Scaffold(
//           resizeToAvoidBottomInset: false,
//           body: WebView(
//             initialUrl:
//                 'https://townhall.${domainName}/organizations/orgreg?5f535cc1cc0954fc8021f2dfa5ad82b5&from=app',
//             javascriptMode: JavascriptMode.unrestricted,
//             javascriptChannels: {
//               JavascriptChannel(
//                 name: 'messageHandler',
//                 onMessageReceived: (JavascriptMessage message) async {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (contextA) {
//                     return BlocProvider(
//                       create: (contextA) => AuthBloc(),
//                       child: LoginScreen(showSnack: 'yes'),
//                     );
//                   }));
//                   timerSnackbar(
//                     buttonLabel: '',
//                     backgroundColor: Colors.green,
//                     context: context,
//                     contentText: "You can now login",
//                     // buttonPrefixWidget: Image.asset(
//                     //   'assets/undo.png',
//                     //   width: 17.0,
//                     //   height: 15.0,
//                     //   alignment: Alignment.topCenter,
//                     //   color: Colors.blue[100],
//                     // ),
//                     afterTimeExecute: () => print("Operation Execute."),
//                     second: 5,
//                   );
//                 },
//               ),
//             },
//             onWebViewCreated: (_controller) {
//               this._controller = _controller;
//             },
//             onPageStarted: (url) {
//               setState(() {
//                 loadingPercentage = 0;
//               });
//             },
//             onProgress: (progress) {
//               setState(() {
//                 loadingPercentage = progress;
//               });
//             },
//             onPageFinished: (url) {
//               setState(() {
//                 loadingPercentage = 100;
//               });
//             },
//           ),
//         ),
//         if (loadingPercentage < 80)
//           Center(
//             child: Container(
//               width: 80.0,
//               height: 80.0,
//               child: SpinKitCircle(
//                 color: Colors.blue,
//                 size: 50.0,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
