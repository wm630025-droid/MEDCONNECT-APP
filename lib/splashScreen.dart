// ===================== Splash Screen =====================
import 'package:flutter/material.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/main.dart';
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
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    });
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
void main(){
  runApp(MyApp());
    
}