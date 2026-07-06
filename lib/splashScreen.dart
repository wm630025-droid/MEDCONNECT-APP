// ===================== Splash Screen =====================
import 'package:flutter/material.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/find_item_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MedConnectSplash extends StatefulWidget {
  const MedConnectSplash({super.key});

  @override
  State<MedConnectSplash> createState() => _MedConnectSplashState();
}

class _MedConnectSplashState extends State<MedConnectSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..forward();

    Future.delayed(const Duration(seconds: 3), () {
      _navigateAfterSplash();
    });
  }
  Future<void> _navigateAfterSplash() async {
    await ApiService.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final bool hasAccount = prefs.getBool('has_account') ?? false;
    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    Widget target;
    if (ApiService.isLoggedIn) {
      target = const MainScreen();
    } else if (!hasAccount && !seenOnboarding) {
      // First-time user without account -> show first onboarding page
      target = const OnboardingFindItemScreen();
    } else {
      // Has account before or already saw onboarding -> go to intro/login
      target = const IntroScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => target),
      );
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الخلفية
          Image.asset(
            'assets/images/intro_BackGround.png',
            fit: BoxFit.cover,
            color: const Color.fromRGBO(0, 0, 0, 0.7),
            colorBlendMode: BlendMode.darken,
          ),

          // المحتوى
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // اللوجو
              Image.asset(
                "assets/images/logoPNG.png",
                width: 220,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // شريط التحميل
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
