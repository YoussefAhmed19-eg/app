import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  List<Map<String, String>> get onboardingData => [
    {
      "image": "assets/images/MoviesPosters.png",
      "title": "onboarding_title_1".tr(),
      "subtitle": "onboarding_subtitle_1".tr(),
    },
    {
      "image": "assets/images/Discover.jpg",
      "title": "onboarding_title_2".tr(),
      "subtitle": "onboarding_subtitle_2".tr(),
    },
    {
      "image": "assets/images/Explorer.jpg",
      "title": "onboarding_title_3".tr(),
      "subtitle": "onboarding_subtitle_3".tr(),
    },
    {
      "image": "assets/images/Creat.jpg",
      "title": "onboarding_title_4".tr(),
      "subtitle": "onboarding_subtitle_4".tr(),
    },
    {
      "image": "assets/images/Rate.jpg",
      "title": "onboarding_title_5".tr(),
      "subtitle": "onboarding_subtitle_5".tr(),
    },
    {
      "image": "assets/images/Start.jpg",
      "title": "onboarding_title_6".tr(),
      "subtitle": "",
    },
  ];

  void nextPage() {
    if (_pageController.page!.toInt() < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void previousPage() {
    if (_pageController.page!.toInt() > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataList = onboardingData;
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: dataList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final data = dataList[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: nextPage,
                child: Image.asset(
                  data["image"]!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (data["subtitle"] != "")
                        Text(
                          data["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFFB83B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: previousPage,
                                child: Text(
                                  "back".tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                          if (index > 0) const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB83B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: nextPage,
                              child: Text(
                                index < dataList.length - 1
                                    ? "next".tr()
                                    : "finish".tr(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
