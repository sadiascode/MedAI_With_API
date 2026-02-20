import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/auth/ui/screen/verify_screen.dart';
import 'package:care_agent/features/auth/ui/screen/set_password.dart';
import 'package:care_agent/features/auth/data/forget_model.dart';
import 'package:care_agent/app/urls.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widget/custom_field.dart';
import '../widget/custom_screen.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendResetCode() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final forgetData = ForgetModel(
      email: emailController.text.trim(),
    );

    try {
      final response = await http.post(
        Uri.parse(Urls.forget_password),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(forgetData.toJson()),
      );

      print('Forgot Password Response status: ${response.statusCode}');
      print('Forgot Password Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset code sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen(email: emailController.text.trim())),
        );
      } else {
        String errorMessage = 'Failed to send reset code';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['email'] != null) {
            errorMessage = errorData['email'];
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : 'Something went wrong';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Forgot Password Error: $e');
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
        backgroundColor: Color(0xffFFF0E6),
        body: CustomScreen(
            svgPath: 'assets/logo.svg',
            svgHeight: screenHeight * 0.16,
            svgWidth: screenWidth * 0.30,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(child: Text("Forgot password?",style: TextStyle(fontSize: 24),)),

                  SizedBox(height: 13),
                  Center(
                    child: Text(
                      "Enter your email and we will send you a verification Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 60),
                  CustomField(
                    hintText: "Email",
                    controller: emailController,
                  ),
                  
                  SizedBox(height: 20),
                  CustomButton(
                    text: "Send Code",
                    onTap: _sendResetCode,
                    isLoading: isLoading,
                  )

                ]
            )
        )
    );
  }
}
