import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/auth/ui/screen/successful_screen.dart';
import 'package:care_agent/features/auth/ui/screen/verify_screen.dart';
import 'package:care_agent/features/auth/data/set_password_model.dart';
import 'package:care_agent/app/urls.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widget/custom_field.dart';
import '../widget/custom_screen.dart';

class SetPassword extends StatefulWidget {
  final String email;

  const SetPassword({super.key, required this.email});

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    // Field validations
    if (newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final resetData = SetPasswordModel(
      email: widget.email,
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    try {
      final response = await http.post(
        Uri.parse(Urls.reset_password),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(resetData.toJson()),
      );

      print('Reset Password Response status: ${response.statusCode}');
      print('Reset Password Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessfulScreen()),
        );
      } else {
        String errorMessage = 'Password reset failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['new_password'] != null) {
            errorMessage = errorData['new_password'];
          } else if (errorData['confirm_password'] != null) {
            errorMessage = errorData['confirm_password'];
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
      print('Reset Password Error: $e');
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
                  Center(child: Text("Set New Password",style: TextStyle(fontSize: 24),)),

                  SizedBox(height: 13),
                  Center(
                    child: Text(
                      "Set your account password to secure your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  CustomField(
                    hintText: "New Password", 
                    isPassword: true,
                    controller: newPasswordController,
                  ),

                  SizedBox(height: 20),
                  CustomField(
                    hintText: "Retype New Password",
                    isPassword: true,
                    controller: confirmPasswordController,
                  ),

                  SizedBox(height: 20),
                  CustomButton(
                    text: "Save",
                    onTap: _resetPassword,
                    isLoading: isLoading,
                  )

                ]
            )
        )
    );
  }
}
