import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Onboarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Inter', // Ensure 'Inter' font is added to pubspec.yaml
      ),
      home: const OnBoardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingSlideData {
  final String imageUrl;
  final String appNamePrefix; // Replaced by slideXTitle
  final String appName; // Replaced by slideXDesc
  final IconData icon;

  OnboardingSlideData({
    required this.imageUrl,
    required this.appNamePrefix,
    required this.appName,
    required this.icon,
  });
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  static const String _defaultImageUrl =
      'https://imagedelivery.net/BgK_7WpdFl6ls9CBX3q89Q/69ab5c95-f314-4caa-d279-bf8d840b0d00/public';
  List<OnboardingSlideData> _slides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlideImages();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        int newPage = _pageController.page!.round();
        if (newPage != _currentPage) {
          setState(() {
            _currentPage = newPage;
          });
        }
      }
    });
  }

  Future<void> _loadSlideImages() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch slide images with default fallback
    final slide1 = prefs.getString('presentation_org_slide_1')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_1')!
        : _defaultImageUrl;
    final slide2 = prefs.getString('presentation_org_slide_2')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_2')!
        : _defaultImageUrl;
    final slide3 = prefs.getString('presentation_org_slide_3')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_3')!
        : _defaultImageUrl;

    // Fetch slide titles (for appNamePrefix) with default fallback
    final slide1Title = prefs.getString('presentation_org_slide_1_title')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_1_title')!
        : "Welcome to";
    final slide2Title = prefs.getString('presentation_org_slide_2_title')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_2_title')!
        : "Discover";
    final slide3Title = prefs.getString('presentation_org_slide_3_title')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_3_title')!
        : "Experience";

    // Fetch slide descriptions (for appName) with default fallback
    final slide1Desc = prefs.getString('presentation_org_slide_1_desc')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_1_desc')!
        : "JOIN LOCAL CAMPAIGN GROUPS";
    final slide2Desc = prefs.getString('presentation_org_slide_2_desc')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_2_desc')!
        : "MOMENTS";
    final slide3Desc = prefs.getString('presentation_org_slide_3_desc')?.isNotEmpty == true
        ? prefs.getString('presentation_org_slide_3_desc')!
        : "PRIVACY";

    // Print SharedPreferences values for debugging
    print('SharedPreferences values:');
    print('presentation_org_slide_1: ${prefs.getString('presentation_org_slide_1') ?? 'null'}');
    print('presentation_org_slide_2: ${prefs.getString('presentation_org_slide_2') ?? 'null'}');
    print('presentation_org_slide_3: ${prefs.getString('presentation_org_slide_3') ?? 'null'}');
    print('presentation_org_slide_1_title: ${prefs.getString('presentation_org_slide_1_title') ?? 'null'}');
    print('presentation_org_slide_2_title: ${prefs.getString('presentation_org_slide_2_title') ?? 'null'}');
    print('presentation_org_slide_3_title: ${prefs.getString('presentation_org_slide_3_title') ?? 'null'}');
    print('presentation_org_slide_1_desc: ${prefs.getString('presentation_org_slide_1_desc') ?? 'null'}');
    print('presentation_org_slide_2_desc: ${prefs.getString('presentation_org_slide_2_desc') ?? 'null'}');
    print('presentation_org_slide_3_desc: ${prefs.getString('presentation_org_slide_3_desc') ?? 'null'}');

    setState(() {
      _slides = [
        OnboardingSlideData(
          imageUrl: slide1,
          icon: Icons.forum_rounded,
          appNamePrefix: slide1Title,
          appName: slide1Desc,
        ),
        OnboardingSlideData(
          imageUrl: slide2,
          icon: Icons.camera_alt_rounded,
          appNamePrefix: slide2Title,
          appName: slide2Desc,
        ),
        OnboardingSlideData(
          imageUrl: slide3,
          icon: Icons.shield_rounded,
          appNamePrefix: slide3Title,
          appName: slide3Desc,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          width: _currentPage == index ? 12.0 : 8.0,
          height: _currentPage == index ? 12.0 : 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? const Color(0xFF4DB6AC)
                : Colors.white.withOpacity(0.6),
          ),
        );
      }),
    );
  }

  Widget _buildPageContent(BuildContext context, OnboardingSlideData slideData, bool isLastPage) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          slideData.imageUrl,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.blueGrey[900],
              child: const Center(
                child: Text(
                  "Unable to load background",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32.0, 20.0, 32.0, 15.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.60),
                ),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        slideData.appNamePrefix,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        slideData.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildPageIndicator(),
                      const SizedBox(height: 20.0),
                      if (isLastPage) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB6AC),
                            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),


                        const SizedBox(height: 15.0),
                        
                      ] else ...[
                        const SizedBox(height: (14.0 * 2 + 14) + 15.0 + 20.0),
                      ],
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return _buildPageContent(context, _slides[index], index == _slides.length - 1);
              },
            ),
    );
  }
}