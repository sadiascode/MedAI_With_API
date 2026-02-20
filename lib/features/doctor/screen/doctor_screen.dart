import 'package:care_agent/features/doctor/screen/view_screen.dart';
import 'package:care_agent/features/medicine/widget/custom_search.dart';
import 'package:care_agent/features/profile/widget/custom_edit.dart';
import 'package:flutter/material.dart';
import '../../../common/app_shell.dart';
import '../models/doctor_list_model.dart';
import '../widget/custom_doctor.dart';
import '../services/doctor_api_service.dart';

class DoctorScreenContent extends StatefulWidget {
  const DoctorScreenContent({super.key});

  @override
  State<DoctorScreenContent> createState() => _DoctorScreenContentState();
}

class _DoctorScreenContentState extends State<DoctorScreenContent> {
  List<DoctorListModel> doctors = [];
  List<DoctorListModel> filteredDoctors = [];
  bool isLoading = true;
  String? error;

  // Text editing controllers for add doctor dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  // Sex dropdown
  String? _selectedSex;
  final List<String> _sexOptions = ['male', 'female', 'other'];

  bool _isAddingDoctor = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctorList = await DoctorApiService.getDoctorList();
      setState(() {
        doctors = doctorList;
        filteredDoctors = doctorList; // initialize filtered list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void searchDoctor(String query) {
    if (query.isEmpty) {
      filteredDoctors = doctors;
    } else {
      filteredDoctors = doctors
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  // Map UI values to API-compatible lowercase values
  String _mapSexToApiValue(String? uiValue) {
    switch (uiValue?.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'other':
        return 'other';
      default:
        return uiValue?.toLowerCase() ?? 'other';
    }
  }

  Future<void> _addDoctor() async {
    // Validate fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter doctor name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSex == null || _selectedSex!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select sex'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_specializationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter specialization'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hospitalNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter hospital name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_designationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter designation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAddingDoctor = true;
    });

    try {
      await DoctorApiService.addDoctor(
        name: _nameController.text.trim(),
        sex: _mapSexToApiValue(_selectedSex),
        specialization: _specializationController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        designation: _designationController.text.trim(),
        doctorEmail: _emailController.text.trim(),
      );

      // Clear controllers
      _nameController.clear();
      _emailController.clear();
      _specializationController.clear();
      _hospitalNameController.clear();
      _designationController.clear();
      _selectedSex = null;

      // Close dialog
      Navigator.pop(context);

      // Refresh doctor list
      await _fetchDoctors();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add doctor: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAddingDoctor = false;
      });
    }
  }

  void _showAddDoctorDialog() {
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
                  title: "Doctor Name",
                  hintText: "doctor name here",
                  controller: _nameController,
                ),
                const SizedBox(height: 10),
                CustomEdit(
                  title: "Email",
                  hintText: "Email address",
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                CustomEdit(
                  title: "Sex",
                  hintText: "Select sex",
                  dropdownItems: _sexOptions,
                  selectedValue: _selectedSex,
                  onDropdownChanged: (String? value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                CustomEdit(
                  title: "Specialization",
                  hintText: "specialization",
                  controller: _specializationController,
                ),
                const SizedBox(height: 10),
                CustomEdit(
                  title: "Hospital name",
                  hintText: "Please enter hospital name",
                  controller: _hospitalNameController,
                ),
                const SizedBox(height: 10),
                CustomEdit(
                  title: "Designation",
                  hintText: "Please enter designation",
                  controller: _designationController,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _isAddingDoctor ? null : _addDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE0712D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 11,
                    ),
                  ),
                  child: _isAddingDoctor
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Your doctors",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // SEARCH
            CustomSearch(
              onChanged: searchDoctor,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showAddDoctorDialog,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Color(0xFFE0712D), size: 20),
                      SizedBox(width: 5),
                      Text(
                        'Add doctors',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE0712D),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFE0712D),
                          decorationThickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (filteredDoctors.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Most recent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: filteredDoctors.take(1).map((doctor) {
                        return CustomDoctor(
                          doctorName: doctor.name,
                          specialization: doctor.specialization,
                          hospital: doctor.hospitalName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewScreen(doctorId: doctor.id),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (filteredDoctors.length > 1) ...[
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'recent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: filteredDoctors.skip(1).take(2).map((doctor) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CustomDoctor(
                              doctorName: doctor.name,
                              specialization: doctor.specialization,
                              hospital: doctor.hospitalName,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewScreen(doctorId: doctor.id),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
              if (filteredDoctors.length > 3) ...[
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Earlier',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: filteredDoctors.skip(3).map((doctor) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CustomDoctor(
                              doctorName: doctor.name,
                              specialization: doctor.specialization,
                              hospital: doctor.hospitalName,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewScreen(doctorId: doctor.id),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              const Center(
                child: Text(
                  'No doctors found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(initialIndex: 2);
  }
}
