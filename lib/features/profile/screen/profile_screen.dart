import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/profile/screen/edit_screen.dart';
import 'package:care_agent/features/profile/screen/myprofile_screen.dart';
import 'package:care_agent/features/profile/screen/prescp_screen.dart';
import 'package:care_agent/features/profile/widget/custom_new.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../common/app_shell.dart';
import '../../auth/ui/screen/signin_screen.dart';
import '../../chat/widget/custom_minibutton.dart';
import '../services/profile_services.dart';
import '../widget/custom_edit.dart';
import '../models/profile_model.dart';

class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _deletePasswordController = TextEditingController();

  // Change Password controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      print('Profile loaded: ${profile.fullName}');
      print('Profile picture URL from API: ${profile.profilePicture}');


      final localImagePath = await ProfileService.getLocalImagePath();
      print('Local image path: $localImagePath');

      ProfileModel updatedProfile = profile;
      if (localImagePath != null) {
        print('Using local image path: $localImagePath');
        updatedProfile = profile.copyWith(profilePicture: localImagePath);
      }

      setState(() {
        _profile = updatedProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your current password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await ProfileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) {
        // Clear controllers
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Close dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAF7),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Color(0xffE0712D),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffE0712D)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAF7),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Color(0xffE0712D),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_error == 'Please login to access your profile')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE0712D),
                  ),
                  child: const Text('Go to Login'),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 15),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyprofileScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: const Border(
                      left: BorderSide(color: Color(0xffE0712D), width: 5),
                      top: BorderSide(color: Color(0xffE0712D), width: 1),
                      right: BorderSide(color: Color(0xffE0712D), width: 1),
                      bottom: BorderSide(color: Color(0xffE0712D), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Builder(
                          builder: (context) {
                            print(
                              'Displaying image: ${_profile?.profilePicture}',
                            );
                            if (_profile?.profilePicture != null &&
                                _profile!.profilePicture!.isNotEmpty) {
                              print('Image path: ${_profile!.profilePicture!}');

                              // Check if it's a local file path or network URL
                              if (_profile!.profilePicture!.startsWith(
                                '/data/',
                              ) ||
                                  _profile!.profilePicture!.startsWith(
                                    'file://',
                                  )) {
                                print(
                                  'Loading local file: ${_profile!.profilePicture!}',
                                );
                                return Image.file(
                                  File(_profile!.profilePicture!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Local image load error: $error');
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    );
                                  },
                                );
                              } else {
                                print(
                                  'Loading network image: ${_profile!.profilePicture!}',
                                );
                                return Image.network(
                                  _profile!.profilePicture!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Network image load error: $error');
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    );
                                  },
                                );
                              }
                            } else {
                              print('No profile picture, showing default icon');
                              return Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[600],
                              );
                            }
                          },
                        ),
                      ),

                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Expanded(
                        child: Text(
                          "My Profile",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios,
                        size: MediaQuery.of(context).size.width * 0.045,
                        color: Color(0xffE0712D),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              CustomNew(
                text: "Change Password",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFFFFFAF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomEdit(
                                title: "Current Password",
                                hintText: "**************",
                                controller: _currentPasswordController,
                              ),
                              const SizedBox(height: 10),
                              CustomEdit(
                                title: "New Password",
                                hintText: "**************",
                                controller: _newPasswordController,
                              ),
                              const SizedBox(height: 10),
                              CustomEdit(
                                title: "Retype New Password",
                                hintText: "**************",
                                controller: _confirmPasswordController,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomMinibutton(
                                text: 'Yes',
                                textcolor: Colors.white,
                                onTap: _changePassword,
                                backgroundColor: const Color(0xFFE0712D),
                              ),
                              const SizedBox(width: 7),
                              CustomMinibutton(
                                text: 'No',
                                textcolor: const Color(0xffE0712D),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: const Color(0xffFFFAF7),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 10),
              CustomNew(
                text: "Your Prescriptions",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescpScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),

              CustomNew(text: "Privacy Policy"),
              SizedBox(height: 10),

              CustomNew(text: "Terms and Conditions"),
              SizedBox(height: 10),

              CustomNew(text: "Delete Account",onTap: (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Color(0xffFFFAF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 35,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Confirm Delete Account",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Are you sure you want to delete your account?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomEdit(
                                title: "Current Password",
                                hintText: "**************",
                                controller: _deletePasswordController,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () async {
                                      final password = _deletePasswordController.text.trim();

                                      if (password.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Please enter your password'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        final success = await ProfileService.deleteAccount(password);

                                        if (success) {
                                          await ProfileService.signOut();

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const SigninScreen(),
                                            ),
                                                (route) => false,
                                          );

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Account deleted successfully'),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to delete account. Please check your password and try again.'),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 5),
                                              action: SnackBarAction(
                                                label: 'Retry',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Network error: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                            action: SnackBarAction(
                                              label: 'Retry',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                );
              },),
              SizedBox(height: 10),

              SizedBox(height: 35),
              CustomButton(
                text: "Sign Out",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Color(0xffFFFAF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 35,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Confirm Sign Out",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Are you sure you want to sign out?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () async {
                                      // Clear stored tokens on sign out
                                      await ProfileService.signOut();

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const SigninScreen(),
                                        ),
                                            (route) => false,
                                      );
                                    },
                                    child: const Text(
                                      "Sign Out",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Standalone version with navbar - redirects to AppShell
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(initialIndex: 4);
  }
}