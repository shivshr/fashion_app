import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/core/utils/validators.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+91');

  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await ref.read(authServiceProvider).sendOtp(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (_) {
        setState(() => _loading = false);
        context.push(AppRoutes.otpVerify,
            extra: _phoneController.text.trim());
      },
      onError: (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e),
            backgroundColor: AppColors.error,
          ),
        );
      },
      onAutoVerified: () {
        setState(() => _loading = false);
        context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7ED),

      body: Column(
        children: [

          /// TOP GREEN SPACE
          const SizedBox(height: 120),

          /// FULL SCREEN WHITE CARD
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    /// BALAJI LOGO
                    Image.asset(
                      "assets/images/logo_transparent.png",
                      height: 350,
                    ),

    

                    /// WELCOME BACK
                    const Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F6C5C),
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// SUBTITLE
                    const Text(
                      "Unlock The World of Textile With Balaji",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// PHONE FIELD
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),

                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF0F6C5C),
                              width: 1.5,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF0F6C5C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    /// LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// ADMIN LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F6C5C),
                              Color(0xFF043B30),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push(AppRoutes.adminLogin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            "Admin Login",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),


                    const SizedBox(height: 20),

                    const Text(
                      'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}