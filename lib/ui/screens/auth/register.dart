import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:nanonime/core/router/app_router.dart';
import 'package:nanonime/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthRegisterScreen extends StatefulWidget {
  const AuthRegisterScreen({super.key});

  @override
  State<AuthRegisterScreen> createState() => _AuthRegisterScreenState();
}

class _AuthRegisterScreenState extends State<AuthRegisterScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Nanonime",
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Silakan login untuk melanjutkan",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.foreground, fontSize: 14),
              ),
              const SizedBox(height: 40),

              _buildField(
                "Full Name",
                Icons.person_outline,
                controller: nameController,
              ),
              const SizedBox(height: 16),
              _buildField(
                "Username",
                Icons.alternate_email,
                controller: usernameController,
              ),
              const SizedBox(height: 16),
              _buildField(
                "Email",
                Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 16),
              _buildField(
                "Password",
                Icons.lock_outline,
                isPass: true,
                controller: passwordController,
              ),
              const SizedBox(height: 24),

              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          await Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).register(
                            name: nameController.text,
                            username: usernameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          AppRouter.toLogin(context);
                        } catch (e) {
                          setState(() {
                            error = e.toString();
                          });
                        } finally {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "REGISTER",
                        style: TextStyle(color: Colors.white),
                      ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: null,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Login Now",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            AppRouter.toLogin(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon, {
    bool isPass = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: AppColors.foreground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.mutedForeground),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.card,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
