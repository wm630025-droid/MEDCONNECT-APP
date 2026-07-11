import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:medconnect_app/on_board_screen.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// MedConnect - Onboarding Screen ("Can't Find What You Need?")
/// Flutter port of the HTML mock. Colors, spacing and layout
/// values below map 1:1 to the Tailwind config / inline styles
/// used in the original HTML file.
/// NOTE: Uses the "Inter" font. Add it via `google_fonts` or as a
/// bundled asset font in pubspec.yaml, otherwise it falls back to
/// the platform default font.
/// ============================================================

class AppColors {
  // ---- tailwind.config "colors" (only the ones actually used here) ----
  static const Color surface = Color(0xFFF8F9FF); // background / surface
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF424654);
  static const Color outline = Color(0xFF727786);
  static const Color outlineVariant = Color(0xFFC2C6D7);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---- inline-style overrides from the HTML (these win over the
  // tailwind "primary" token, exactly like in the source file) ----
  static const Color primary = Color(0xFF005A9C); // active dot + button
  static const Color blobPrimaryFixed = Color(0xFFE0F2F1); // top-left blob
  static const Color blobSecondaryFixed = Color(0xFF89F5E7); // right blob
  static const Color buttonShadow = Color(0x26005A9C); // rgba(0,90,156,0.15)
}

class AppSpacing {
  static const double xs = 4;
  static const double base = 8;
  static const double sm = 12;
  static const double md = 24;
  static const double gutter = 24;
  static const double lg = 48;
  static const double xl = 80;
  static const double marginMobile = 16;
}

class AppText {
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 16 / 14,
    letterSpacing: 0.01 * 14,
    fontWeight: FontWeight.w500,
  );
}

class OnboardingFindItemScreen extends StatefulWidget {
  const OnboardingFindItemScreen({super.key});

  @override
  State<OnboardingFindItemScreen> createState() =>
      _OnboardingFindItemScreenState();
}

class _OnboardingFindItemScreenState extends State<OnboardingFindItemScreen> {
  // Index of the active pagination dot (0-based). First dot is
  // pre-active here, exactly like the HTML markup for this page.
  int _activeDot = 0;

  void _onSkip() {
    _finishOnboardingAndGoToIntro();
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Future<void> _finishOnboardingAndGoToIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ---------------- Ambient background blobs ----------------
          _blob(
            top: -80,
            left: -80,
            size: 384,
            color: AppColors.blobPrimaryFixed,
          ),
          _blob(
            top: MediaQuery.of(context).size.height / 2,
            right: -80,
            size: 256,
            color: AppColors.blobSecondaryFixed,
          ),

          // ---------------- Foreground layout ----------------
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(child: _mainContent()),

                _footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Blob background helper ----------------
  Widget _blob({
    double? top,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Opacity(
            opacity: 0.4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Header: h-16, Skip button ----------------
  Widget _header() {
    return Container(
      height: 64, // h-16
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(), // leading icon slot (empty, as in source)
          TextButton(
            onPressed: _onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.outline,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip',
              style: AppText.labelMd.copyWith(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Main content: illustration + copy ----------------
  Widget _mainContent() {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512), // max-w-lg
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illustration container (aspect-square, mb-lg)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tonal grounding circle behind the illustration
                      Container(
                        width: 256,
                        height: 256,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child:Image.asset('assets/images/second_image.png',

                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  size: 64, color: AppColors.outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Copy section
              const Text(
                "Can't Find What You Need?",
                textAlign: TextAlign.center,
                style: AppText.headlineLgMobile,
              ),
              const SizedBox(height: 16), // mb-4 under h1
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: const Text(
                  "Send a custom request and we'll source it for you.",
                  textAlign: TextAlign.center,
                  style: AppText.bodyMd,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ---------------- Footer: pagination dots + primary button ----------------
  Widget _footer() {
    return Padding(
       padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _paginationDots(),
          const SizedBox(height: AppSpacing.xl), // gap-xl
          _nextButton(),
        ],
      ),
    );
  }

  Widget _paginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = index == _activeDot;
        return GestureDetector(
          onTap: () => setState(() => _activeDot = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4), // gap-2 / 2
            height: 8, // h-2
            width: isActive ? 32 : 8, // w-8 : w-2
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  Widget _nextButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // rounded-xl
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.08),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.buttonShadow,
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: AppText.labelMd.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: AppColors.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}