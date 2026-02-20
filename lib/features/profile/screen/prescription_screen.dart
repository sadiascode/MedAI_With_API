import 'package:care_agent/features/profile/widget/custom_details.dart';
import 'package:care_agent/features/profile/widget/custom_details1.dart';
import 'package:care_agent/features/profile/widget/custom_info.dart';
import 'package:care_agent/features/profile/services/prescription_service.dart';
import 'package:care_agent/features/profile/models/prescription_model.dart';
import 'package:care_agent/features/doctor/services/doctor_api_service.dart';
import 'package:care_agent/features/doctor/models/doctor_list_model.dart';
import 'package:flutter/material.dart';

import '../../../common/app_shell.dart';
import '../models/prescription_medicine_model.dart';
import '../widget/custom_bull.dart';

class PrescriptionScreen extends StatefulWidget {
  final int prescriptionId;
  final int parentTabIndex;

  const PrescriptionScreen({
    super.key,
    required this.prescriptionId,
    required this.parentTabIndex,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  PrescriptionModel? prescription;
  List<DoctorListModel> doctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Fetch both prescription and doctors data in parallel
      final results = await Future.wait([
        PrescriptionService.getPrescriptionById(widget.prescriptionId),
        DoctorApiService.getDoctorList(),
      ]);

      setState(() {
        prescription = results[0] as PrescriptionModel;
        doctors = results[1] as List<DoctorListModel>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchData();
  }

  // Helper method to get doctor name by ID
  String getDoctorName(int doctorId) {
    try {
      final doctor = doctors.firstWhere(
        (doc) => doc.id == doctorId,
        orElse: () => DoctorListModel(
          id: 0,
          name: 'Unknown Doctor',
          sex: '',
          specialization: '',
          hospitalName: '',
          designation: '',
        ),
      );
      return doctor.name.isNotEmpty ? doctor.name : 'Unknown Doctor';
    } catch (e) {
      print('Error finding doctor with ID $doctorId: $e');
      return 'Unknown Doctor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      parentTabIndex: widget.parentTabIndex,
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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18),
        ),
        title: const Text(
          "Prescription Details",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    } else if (error != null) {
      return _buildErrorState();
    } else if (prescription == null || prescription!.id == 0) {
      return _buildEmptyState();
    } else {
      return _buildContentState();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xffE0712D)),
          SizedBox(height: 16),
          Text('Loading prescription details...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load prescription',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Prescription not found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Patient Information Section
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE0712D), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Patient's information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomDetails(name: "Patient's name", medicine: prescription!.patient.displayName),
                    const SizedBox(height: 10),
                    CustomDetails(name: "Doctor's name", medicine: 'Dr. ${getDoctorName(prescription!.doctor)}'),
                    const SizedBox(height: 10),
                    CustomInfo(
                      name: "Patient's age", 
                      age: prescription!.patient.displayAge, 
                      sex: 'Sex', 
                      gender: prescription!.patient.displaySex,
                    ),
                    const SizedBox(height: 10),
                    CustomDetails(name: 'Health Issue', medicine: prescription!.patient.displayHealthIssues),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Prescription Details Section
          if (prescription!.hasMedicines) ...[
            Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffE0712D), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prescription Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...prescription!.medicines.map((medicine) => _buildMedicineDetails(medicine)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
          
          // Medical Tests Section
          if (prescription!.hasMedicalTests) ...[
            Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffE0712D), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medical tests',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...prescription!.medicalTests.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final test = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CustomDetails(
                                name: 'Test $index',
                                medicine: test.displayName,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
          
          // Next Follow-up Section
          if (prescription!.hasNextAppointment) ...[
            Center(
              child: Text(
                "Next follow-up: ${prescription!.formattedNextAppointment}",
                style: TextStyle(color: Color(0xffE0712D)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineDetails(PrescriptionMedicineModel medicine) {
    return Column(
      children: [
        CustomDetails(name: 'Medicine Name', medicine: medicine.name),
        const SizedBox(height: 10),
        if (medicine.hasMorning) ...[
          CustomDetails1(name: "Morning", subtitle: medicine.morningTime),
          const SizedBox(height: 10),
        ],
        if (medicine.hasAfternoon) ...[
          CustomDetails1(name: "Afternoon", subtitle: medicine.afternoonTime),
          const SizedBox(height: 10),
        ],
        if (medicine.hasEvening) ...[
          CustomDetails1(name: "Evening", subtitle: medicine.eveningTime),
          const SizedBox(height: 10),
        ],
        if (medicine.hasNight) ...[
          CustomDetails1(name: "Night", subtitle: medicine.nightTime),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
