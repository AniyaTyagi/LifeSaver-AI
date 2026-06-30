import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "Predict Missed Deadlines",
      "description": "LifeSaver AI actively scans your schedule and workspace to predict conflict and procrastination risks before they happen.",
    },
    {
      "title": "Smart Calendar Blocks",
      "description": "Our scheduling agent automatically locks focus hours inside your Google Calendar, finding open slots in your busy day.",
    },
    {
      "title": "Actionable Interventions",
      "description": "No more passive alerts. LifeSaver AI walks you through starting tasks, helping you break them down into micro-steps.",
    }
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Logo/Branding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: colors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'LifeSaver AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              
              // Walkthrough Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stylized Illustration Placeholder
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withOpacity(0.05),
                            border: Border.all(color: colors.primary.withOpacity(0.2), width: 2),
                          ),
                          child: Icon(
                            index == 0 ? Icons.analytics_outlined :
                            index == 1 ? Icons.calendar_month_outlined : Icons.tips_and_updates_outlined,
                            size: 80,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        Text(
                          slide["title"]!,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 24,
                            color: colors.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          slide["description"]!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onBackground.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Slide Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? colors.primary : colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              
              // Authentication triggers
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Firebase google sign-in routing simulation
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                child: Text(
                  'Skip for demo mode',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
