import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/auth/ui/screen/set_password.dart';
import 'package:care_agent/features/auth/data/verify_model.dart';
import 'package:care_agent/features/auth/data/set_password_model.dart';
import 'package:care_agent/features/auth/data/verify_screen_model.dart';
import 'package:care_agent/app/urls.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widget/custom_screen.dart';
import 'successful_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String email;

  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _resendOTP() async {
    setState(() {
      isLoading = true;
    });

    final resendData = VerifyScreenModel(
      email: widget.email,
    );

    print('Sending resend OTP data: ${resendData.toJson()}');
    print('Request body: ${jsonEncode(resendData.toJson())}');

    try {
      final response = await http.post(
        Uri.parse(Urls.resend_otp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(resendData.toJson()),
      );

      print('Resend OTP Response status: ${response.statusCode}');
      print('Resend OTP Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMessage = 'Failed to resend OTP';
        try {
          final errorData = jsonDecode(response.body);
          print('Parsed error data: $errorData');
          
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['email'] != null) {
            errorMessage = errorData['email'];
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          } else if (errorData['non_field_errors'] != null) {
            errorMessage = errorData['non_field_errors'];
          }
        } catch (e) {
          print('Error parsing response: $e');
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
      print('Resend OTP Error: $e');
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
    }}

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

  Future<void> _verifyOTP() async {
    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter 6 digit OTP code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final verifyData = VerifyModel(
      email: widget.email,
      otp: otpController.text.trim(),
      purpose: 'password_reset',
    );

    print('Sending verification data: ${verifyData.toJson()}');
    print('Request body: ${jsonEncode(verifyData.toJson())}');
    print('Purpose field value: ${verifyData.purpose}');

    try {
      final response = await http.post(
        Uri.parse(Urls.signup_verifyotp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(verifyData.toJson()),
      );

      print('Verify OTP Response status: ${response.statusCode}');
      print('Verify OTP Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetPassword(email: widget.email)),
        );
      } else {
        String errorMessage = 'OTP verification failed';
        try {
          final errorData = jsonDecode(response.body);
          print('Parsed error data: $errorData');
          
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['otp'] != null) {
            errorMessage = errorData['otp'];
          } else if (errorData['email'] != null) {
            errorMessage = errorData['email'];
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          } else if (errorData['non_field_errors'] != null) {
            errorMessage = errorData['non_field_errors'];
          }
        } catch (e) {
          print('Error parsing response: $e');
          errorMessage = response.body.isNotEmpty ? response.body : 'Invalid OTP';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Verify OTP Error: $e');
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
                  SizedBox(height: 10),
                  Center(child: Text("Check your email",style: TextStyle(fontSize: 24),)),

                  SizedBox(height: 13),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "We sent a reset link to ${widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Please enter the 6 digit code.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 35),
                  PinCodeTextField(
                    length: 6,
                    obscureText: false,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeColor: Color(0xffE0712D),
                        selectedColor: Color(0xffE0712D),
                        inactiveColor: Color(0xffE0712D)),
                    animationDuration: const Duration(milliseconds: 300),
                    controller: otpController,
                    appContext: context,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _resendOTP,
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Container(
                          width: 83,
                          height: 1,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  CustomButton(
                    text: "Verify OTP",
                    onTap: _verifyOTP,
                    isLoading: isLoading,
                  )
                ]
            )
        )
    );
  }
}

