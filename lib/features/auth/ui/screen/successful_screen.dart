import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/auth/ui/screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../widget/custom_screen.dart';
class SuccessfulScreen extends StatefulWidget {
  const SuccessfulScreen({super.key});

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
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
                  Center(
                    child: SvgPicture.asset(
                      'assets/log.svg',
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.16,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Text(
                      "Password Reset Successfully!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Text(
                      "Your password has been successfully reset.\nYou can now log in with your new password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                  CustomButton(text: "Save Successfully", onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SigninScreen()),
                    );
                  })
                ]
            )
        ),
    );
  }
}
