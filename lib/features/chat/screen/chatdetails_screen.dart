import 'package:care_agent/features/chat/models/chat_prescription_model.dart';
import 'package:care_agent/features/chat/screen/chats_screen.dart';
import 'package:care_agent/features/chat/widget/custom_linkwith.dart';
import 'package:care_agent/features/doctor/models/doctor_list_model.dart';
import 'package:care_agent/features/doctor/services/doctor_api_service.dart';
import 'package:flutter/material.dart';
import '../../../app/urls.dart';
import '../../../common/app_shell.dart';
import '../../profile/widget/custom_bull.dart';
import '../../profile/widget/custom_details.dart';
import '../../profile/widget/custom_details1.dart';
import '../../profile/widget/custom_info.dart';
import '../widget/custom_minibutton.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ChatdetailsScreen extends StatefulWidget {
  const ChatdetailsScreen({super.key});

  @override
  State<ChatdetailsScreen> createState() => _ChatdetailsScreenState();
}

class _ChatdetailsScreenState extends State<ChatdetailsScreen> {

  ChatPrescriptionModel? prescriptionData;
  bool isLoading = true;
  String? errorMessage;
  

  List<DoctorListModel> doctors = [];
  bool isLoadingDoctors = true;
  String? doctorError;


  List<String> selectedMeals = [];


  int? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = currentUserId;
    _fetchPrescriptionData();
    _fetchDoctors();
  }


  Future<void> _fetchPrescriptionData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final box = GetStorage();
      final token = box.read('access_token');
      

      final response = await http.post(
        Uri.parse(Urls.Chat_Bot),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': currentUserId,
          'text': 'Show me my prescription details', 
        }),
      );

      print(' Prescription API Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final prescription = ChatPrescriptionModel.fromJson(jsonData);
        

        final mealCount = prescription.data.isNotEmpty 
            ? prescription.data.first.medicines.length * 4
            : 0;
        selectedMeals = List.filled(mealCount, 'After Meal');

        setState(() {
          prescriptionData = prescription;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load prescription: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error fetching prescription data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctorList = await DoctorApiService.getDoctorList();
      setState(() {
        doctors = doctorList;
        isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        doctorError = e.toString();
        isLoadingDoctors = false;
      });
    }
  }


  int _getMealIndex(int medicineIndex, int timeSlot) {
    return (medicineIndex * 4) + timeSlot;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SubPageScaffold(
      parentTabIndex: 3,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading prescription: $errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : prescriptionData == null || prescriptionData!.data.isEmpty
                  ? const Center(
                      child: Text(
                        'No prescription data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
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
                                      "Patient's information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    CustomDetails(
                                      name: "Patient's name", 
                                      medicine: prescriptionData!.data.first.patient?.name ?? 'N/A'
                                    ),
                                    const SizedBox(height: 10),
                                    CustomDetails(
                                      name: "Doctor's name", 
                                      medicine: prescriptionData!.data.first.doctor != null 
                                          ? 'Dr. ID: ${prescriptionData!.data.first.doctor}' 
                                          : 'N/A'
                                    ),
                                    const SizedBox(height: 10),
                                    CustomInfo(
                                      name: "Patient's age", 
                                      age: prescriptionData!.data.first.patient?.age.toString() ?? 'N/A', 
                                      sex: 'Sex', 
                                      gender: prescriptionData!.data.first.patient?.sex ?? 'N/A'
                                    ),
                                    const SizedBox(height: 10),
                                    CustomDetails(
                                      name: 'Health Issue', 
                                      medicine: prescriptionData!.data.first.patient?.healthIssues ?? 'N/A'
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          

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
                                        

                                        ...prescriptionData!.data.first.medicines.asMap().entries.map((entry) {
                                          final medicineIndex = entry.key;
                                          final medicine = entry.value;
                                          return _buildMedicineSection(medicine, medicineIndex);
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          

                          _buildMedicalTestsSection(),
                          const SizedBox(height: 15),
                          

                          _buildNextAppointmentSection(),
                          const SizedBox(height: 20),
                          

                          _buildDoctorListSection(screenWidth),
                          const SizedBox(height: 20),
                          

                          _buildActionButtons(screenWidth),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }


  Widget _buildMedicineSection(Medicine medicine, int medicineIndex) {
    return Column(
      children: [
        CustomDetails(name: 'Medicine Name', medicine: medicine.name),
        const SizedBox(height: 10),
        

        if (medicine.morning != null) ...[
          CustomDetails1(name: "Morning", subtitle: medicine.morning?.time ?? 'N/A'),
          CustomDetails1(name: "How many time/day", subtitle: medicine.howManyDay?.toString() ?? 'N/A'),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 0)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 0)] = value;
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        

        if (medicine.afternoon != null) ...[
          CustomDetails1(name: "Afternoon", subtitle: medicine.afternoon?.time ?? 'N/A'),
          CustomDetails1(name: "How many time/day", subtitle: medicine.howManyDay?.toString() ?? 'N/A'),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 1)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 1)] = value;
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        

        if (medicine.evening != null) ...[
          CustomDetails1(name: "Evening", subtitle: medicine.evening?.time ?? 'N/A'),
          CustomDetails1(name: "How many time/day", subtitle: medicine.howManyDay?.toString() ?? 'N/A'),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 2)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 2)] = value;
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        

        if (medicine.night != null) ...[
          CustomDetails1(name: "Night", subtitle: medicine.night?.time ?? 'N/A'),
          CustomDetails1(name: "How many time/day", subtitle: medicine.howManyDay?.toString() ?? 'N/A'),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 3)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 3)] = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }


  Widget _buildMedicalTestsSection() {
    final medicalTests = prescriptionData!.data.first.medicalTests;
    
    return Column(
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
                  

                  if (medicalTests.isEmpty)
                    const Text('No medical tests available')
                  else
                    ...medicalTests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final test = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomDetails(
                          name: 'Test ${index + 1}', 
                          medicine: test.toString()
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildNextAppointmentSection() {
    final nextAppointment = prescriptionData!.data.first.nextAppointmentDate;
    
    return Column(
      children: [
        if (nextAppointment != null)
          Center(
            child: Text(
              "Next follow-up: $nextAppointment",
              style: const TextStyle(color: Color(0xffE0712D), fontSize: 17),
            ),
          )
        else
          const Center(
            child: Text(
              "No follow-up appointment scheduled",
              style: TextStyle(color: Color(0xffE0712D), fontSize: 17),
            ),
          ),
      ],
    );
  }

  Widget _buildDoctorListSection(double screenWidth) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width * 0.96,
          decoration: BoxDecoration(
            color: const Color(0xffE0712D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              "Doctor List",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        

        Container(
          height: 200,
          child: isLoadingDoctors
              ? const Center(child: CircularProgressIndicator())
              : doctorError != null
                  ? Center(
                      child: Text(
                        'Error loading doctors',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CustomLinkwith(
                            doctorName: doctor.name,
                            specialization: doctor.specialization,
                            hospital: doctor.hospitalName,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }


  Widget _buildActionButtons(double screenWidth) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.18),
        CustomMinibutton(
          text: "save",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatsScreen()),
            );
          },
          textcolor: Colors.white,
          backgroundColor: const Color(0xffE0712D),
        ),
        SizedBox(width: screenWidth * 0.05),
        CustomMinibutton(
          text: "Decline",
          onTap: () {

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AppShell(initialIndex: 3)),
                  (route) => false,
            );
          },
          textcolor: const Color(0xffE0712D),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }
}
