import 'package:care_agent/features/medicine/screen/add_screen.dart';
import 'package:flutter/material.dart';
import '../../../common/app_shell.dart';
import '../widget/custom_refill.dart';
import '../widget/custom_search.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

class MedicineScreenContent extends StatefulWidget {
  const MedicineScreenContent({super.key});

  @override
  State<MedicineScreenContent> createState() =>
      _MedicineScreenContentState();
}

class _MedicineScreenContentState extends State<MedicineScreenContent> {
  List<MedicineModel> medicines = [];
  List<MedicineModel> filteredMedicines = [];
  bool isLoading = true;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    try {
      final data = await MedicineService.fetchMedicines();
      medicines = data;
      filteredMedicines = data;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchMedicine(String query) {
    searchText = query;

    if (query.isEmpty) {
      filteredMedicines = medicines;
    } else {
      filteredMedicines = medicines
          .where((m) =>
          m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Medicine List",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            //SEARCH
            CustomSearch(
              onChanged: searchMedicine,
            ),

            const SizedBox(height: 10),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: Color(0xffE0712D),
                  ),
                ),
              )
            else if (filteredMedicines.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: const [
                      Icon(Icons.medication_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No medicines found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filteredMedicines.map((medicine) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: CustomRefill(
                      medicineName: medicine.name,
                      remainingCount: medicine.stock,
                      onRefill: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddScreen(medicine: medicine),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(initialIndex: 1);
  }
}
