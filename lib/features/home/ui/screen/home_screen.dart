import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../common/app_shell.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../widgets/appointment_cart_widget.dart';
import '../widgets/medicine_card_widget.dart';
import '../widgets/time_header_widget.dart';
import 'notification_screen.dart';
import '../../../profile/models/prescription_model.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  DateTime selectedDate = DateTime.now();
  DashboardModel? dashboardData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await DashboardService.getDashboardData(date: selectedDate);
      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _onDateChanged(DateTime date) async {
    setState(() {
      selectedDate = date;
    });
    await _fetchDashboardData();
  }

  Future<void> _refresh() async {
    await _fetchDashboardData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/lo.svg',
          height: 39,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            icon: SvgPicture.asset(
              'assets/notification.svg',
              height: 24,
              width: 24,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Today ${_formatDate(selectedDate)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                DatePicker(
                  DateTime.now(),
                  initialSelectedDate: selectedDate,
                  height: 75,
                  width: 48,
                  selectionColor: Color(0xffE0712D),
                  selectedTextColor: Colors.white,
                  dateTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  dayTextStyle: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff1C1C1C),
                  ),

                  monthTextStyle: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff1C1C1C),
                  ),
                  onDateChange: _onDateChanged,
                ),

                const SizedBox(height: 30),
                if (isLoading)
                  _buildLoadingState()
                else if (error != null)
                  _buildErrorState()
                else if (dashboardData != null)
                  _buildContentState()
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const Text(
          "Today's Medicine",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Color(0xffE0712D)),
              SizedBox(height: 16),
              Text('Loading dashboard data...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const Text(
          "Today's Medicine",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Text(
          "Today's Medicine",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Icon(Icons.medication_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No medicines scheduled for this day',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medicine sections - only show if data exists
        if (dashboardData!.hasAnyMedicines) ...[
          const Text(
            "Today's Medicine",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Morning medicines
          if (dashboardData!.morning.isNotEmpty) ...[
            const TimeHeader(svgPath: 'assets/morning.svg', title: "Morning"),
            ...dashboardData!.morning.map((medicine) => MedicineCard(
              time: medicine.formattedTime,
              name: medicine.medicineName,
              dosage: 'As prescribed',
              subtitle: medicine.mealInfo.isNotEmpty ? medicine.mealInfo : '',
            )),
            const SizedBox(height: 20),
          ],

          // Afternoon medicines
          if (dashboardData!.afternoon.isNotEmpty) ...[
            const TimeHeader(svgPath: 'assets/noon.svg', title: "Afternoon"),
            ...dashboardData!.afternoon.map((medicine) => MedicineCard(
              time: medicine.formattedTime,
              name: medicine.medicineName,
              dosage: 'As prescribed',
              subtitle: medicine.mealInfo.isNotEmpty ? medicine.mealInfo : '',
            )),

            const SizedBox(height: 20),
          ],

          // Evening medicines
          if (dashboardData!.evening.isNotEmpty) ...[
            const TimeHeader(svgPath: 'assets/sunset.svg', title: "Evening"),
            ...dashboardData!.evening.map((medicine) => MedicineCard(
              time: medicine.formattedTime,
              name: medicine.medicineName,
              dosage: 'As prescribed',
              subtitle: medicine.mealInfo.isNotEmpty ? medicine.mealInfo : '',
            )),
            const SizedBox(height: 20),
          ],

          // Night medicines
          if (dashboardData!.night.isNotEmpty) ...[
            const TimeHeader(svgPath: 'assets/night.svg', title: "Night"),
            ...dashboardData!.night.map((medicine) => MedicineCard(
              time: medicine.formattedTime,
              name: medicine.medicineName,
              dosage: 'As prescribed',
              subtitle: medicine.mealInfo.isNotEmpty ? medicine.mealInfo : '',
            )),
            const SizedBox(height: 20),
          ],
        ] else ...[

          // No medicines state
          const Text(
            "Today's Medicine",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(Icons.medication_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No medicines scheduled for this day',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Appointments section - show based on API data
        if (dashboardData!.nextAppointment.isNotEmpty) ...[
          const Text(
            "Today's Appointments",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ...dashboardData!.nextAppointment.map((appointment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppointmentCartWidget(
                doctorName: appointment.doctorName.isNotEmpty 
                    ? appointment.doctorName 
                    : 'Not specified',
              ),
            );
          }).toList(),
        ] else ...[
          const Text(
            "Today's Appointments",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No appointments scheduled for today',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }



  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',

      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return const AppShell(initialIndex: 0);

  }

}