import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:nanonime/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _fadeOutController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _introOpacityAnim;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _fadeOutAnim;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.elasticOut),
    );

    _introOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _offsetAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
        );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );

    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeOutController.forward();
      }
    });

    _fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          AppRouter.toHome(context, replace: true);
        }
      }
    });

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SlideTransition(
          position: _offsetAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _introOpacityAnim,
              child: FadeTransition(
                opacity: _fadeOutAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "NanoNime",
                      style: GoogleFonts.pixelifySans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
