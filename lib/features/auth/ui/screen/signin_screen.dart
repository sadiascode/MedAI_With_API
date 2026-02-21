import 'package:flutter/material.dart';
import '../../../../common/custom_button.dart';
import '../../../home/ui/screen/home_screen.dart';
import '../../services/auth_service.dart';
import '../widget/custom_field.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_google.dart';
import 'signup_screen.dart';
import 'forget_screen.dart';
import '../../data/signin_model.dart';
import '../../../../app/urls.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool rememberMe = false;
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signinUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final signinData = SigninModel(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    try {
      final response = await http.post(
        Uri.parse(Urls.User_signin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(signinData.toJson()),
      );

      print('Signin Response status: ${response.statusCode}');
      print('Signin Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response and extract access token
        final responseData = jsonDecode(response.body);
        String? accessToken = responseData['access'];

        if (accessToken != null && accessToken.isNotEmpty) {
          // Initialize AuthService session (handles storage internally now)
          final int userId = responseData['id'] ?? 0;
          AuthService.initializeUserSession(userId, accessToken);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['email'] != null) {
            errorMessage = errorData['email'];
          } else if (errorData['password'] != null) {
            errorMessage = errorData['password'];
          }
        } catch (e) {
          errorMessage = response.body;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Signin Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffFFF0E6),
      body: CustomScreen(
        svgPath: 'assets/logo.svg',
        svgHeight: screenHeight * 0.16,
        svgWidth: screenWidth * 0.30,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Welcome to Med AI",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 15),
              CustomField(
                hintText: "Email",
                borderColor: const Color(0xffE0712D),
                controller: emailController,
              ),
              const SizedBox(height: 17),
              CustomField(
                hintText: "Password",
                borderColor: const Color(0xffE0712D),
                isPassword: true,
                controller: passwordController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember Me", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgetScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 14, color: Color(0xff333333)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: "Sign In",
                onTap: _signinUser,
                isLoading: isLoading,
              ),
              SizedBox(height: screenHeight * 0.02),
              const CustomGoogle(
                  text: "Sign in with Google", svgPath: "assets/google.svg"),
              SizedBox(height: screenHeight * 0.011),
              const CustomGoogle(
                  text: "Sign in with Apple", svgPath: "assets/apple.svg"),
              SizedBox(height: screenHeight * 0.020),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE0712D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}