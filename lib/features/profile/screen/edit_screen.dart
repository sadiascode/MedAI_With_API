import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/common/custom_medium.dart';
import 'package:care_agent/features/profile/screen/profile_screen.dart';
import 'package:care_agent/features/profile/widget/custom_edit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../common/app_shell.dart';
import '../models/profile_model.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/ui/screen/signin_screen.dart';
import '../services/profile_services.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _selectedImagePath;
  final box = GetStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _healthConditionController =
  TextEditingController();
  final TextEditingController _wakeupTimeController = TextEditingController();
  final TextEditingController _breakfastTimeController =
  TextEditingController();
  final TextEditingController _lunchTimeController = TextEditingController();
  final TextEditingController _dinnerTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _healthConditionController.dispose();
    _wakeupTimeController.dispose();
    _breakfastTimeController.dispose();
    _lunchTimeController.dispose();
    _dinnerTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // Check if user is authenticated
      final token = box.read('access_token');
      if (token == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please login to access your profile';
        });
        return;
      }

      print('Loading profile with token: ${token.substring(0, 10)}...');
      final profile = await ProfileService.getProfile();
      print('Profile loaded successfully');

      setState(() {
        _profile = profile;
        _isLoading = false;
        _error = null;

        _nameController.text = profile.fullName;
        _emailController.text = profile.email;
        _addressController.text = profile.address ?? '';
        _ageController.text = profile.age?.toString() ?? '';
        _healthConditionController.text = profile.healthCondition ?? '';
        _wakeupTimeController.text = profile.wakeupTime ?? '';
        _breakfastTimeController.text = profile.breakfastTime ?? '';
        _lunchTimeController.text = profile.lunchTime ?? '';
        _dinnerTimeController.text = profile.dinnerTime ?? '';
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    print('Save button tapped');
    if (_profile == null) {
      print('Profile is null, returning');
      return;
    }

    setState(() {
      _isSaving = true;
      print('Set saving state to true');
    });

    try {
      if (_selectedImagePath != null) {
        print('New image selected: $_selectedImagePath');
        // Store image path locally for display since API doesn't accept file paths
        await box.write('profile_image_path', _selectedImagePath!);
        print('Stored image path locally: $_selectedImagePath');
      }

      print('Creating updated profile object...');
      // Don't include profile_picture since API expects actual file, not path
      final updatedProfile = _profile!.copyWith(
        fullName: _nameController.text,
        email: _emailController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
        healthCondition: _healthConditionController.text.isEmpty
            ? null
            : _healthConditionController.text,
        wakeupTime: _wakeupTimeController.text.isEmpty
            ? null
            : _wakeupTimeController.text,
        breakfastTime: _breakfastTimeController.text.isEmpty
            ? null
            : _breakfastTimeController.text,
        lunchTime: _lunchTimeController.text.isEmpty
            ? null
            : _lunchTimeController.text,
        dinnerTime: _dinnerTimeController.text.isEmpty
            ? null
            : _dinnerTimeController.text,
      );

      print('Updating profile via API...');
      await ProfileService.updateProfile(
        profile: updatedProfile,
        imagePath: _selectedImagePath,
      );
      print('Profile updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } catch (e) {
      print('Save error: $e');
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('Save process completed');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SubPageScaffold(
        parentTabIndex: 4,
        backgroundColor: const Color(0xFFFFFAF7),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xffE0712D),
              size: 18,
            ),
          ),
          title: const Text(
            "Edit Profile",
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
      return SubPageScaffold(
        parentTabIndex: 4,
        backgroundColor: const Color(0xFFFFFAF7),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xffE0712D),
              size: 18,
            ),
          ),
          title: const Text(
            "Edit Profile",
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
                _error == 'Please login to access your profile'
                    ? 'Please login to access your profile'
                    : 'Error loading profile',
                style: TextStyle(
                  fontSize: 16,
                  color: _error == 'Please login to access your profile'
                      ? Colors.orange[700]
                      : Colors.red[700],
                ),
              ),
              if (_error != 'Please login to access your profile') ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _error == 'Please login to access your profile'
                    ? () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SigninScreen(),
                    ),
                        (route) => false,
                  );
                }
                    : _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE0712D),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _error == 'Please login to access your profile'
                      ? 'Go to Login'
                      : 'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SubPageScaffold(
      parentTabIndex: 4,
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xffE0712D),
            size: 18,
          ),
        ),
        title: const Text(
          "Edit Profile",
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
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                      child: _selectedImagePath != null
                          ? Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                      )
                          : _profile?.profilePicture != null
                          ? Image.network(
                        _profile!.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 150,
                            color: Colors.grey,
                          );
                        },
                      )
                          :Icon(Icons.person,size: 140,color: Colors.grey,)
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GestureDetector(
                onTap: _pickImage,
                child: const Text(
                  'Change photo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffE0712D),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xffE0712D),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CustomMedium(text: "Profile Info", onTap: () {}),
              const SizedBox(height: 20),
              CustomEdit(
                title: "Full Name",
                hintText: "Enter your name",
                controller: _nameController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Email",
                hintText: "Enter your email",
                controller: _emailController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Address",
                hintText: "Type your address here",
                controller: _addressController,
              ),
              const SizedBox(height: 20),
              CustomMedium(text: "Other Info", onTap: () {}),
              const SizedBox(height: 30),
              CustomEdit(
                title: "Age",
                hintText: "Type your age here",
                controller: _ageController,

              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Health condition",
                hintText: "Type your health condition here",
                controller: _healthConditionController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Wakeup time",
                hintText: "Type your wakeup time",
                controller: _wakeupTimeController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Breakfast time",
                hintText: "Type your breakfast time",
                controller: _breakfastTimeController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Lunch time",
                hintText: "Type your lunch time",
                controller: _lunchTimeController,
              ),
              const SizedBox(height: 15),
              CustomEdit(
                title: "Dinner time",
                hintText: "Type your dinner time",
                controller: _dinnerTimeController,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: _isSaving ? "Saving..." : "Save",
                onTap: _isSaving ? () {} : _saveProfile,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}