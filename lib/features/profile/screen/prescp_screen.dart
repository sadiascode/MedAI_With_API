import 'package:care_agent/common/app_shell.dart';
import 'package:care_agent/features/profile/screen/prescription_screen.dart';
import 'package:care_agent/features/profile/services/prescription_service.dart';
import 'package:care_agent/features/profile/services/prescription_pdf_service.dart';
import 'package:care_agent/features/profile/models/prescription_model.dart';
import 'package:care_agent/features/profile/widget/custom_prescriptions.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PrescpScreen extends StatefulWidget {
  const PrescpScreen({super.key});

  @override
  State<PrescpScreen> createState() => _PrescpScreenState();
}

class _PrescpScreenState extends State<PrescpScreen> {
  List<PrescriptionModel> prescriptions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await PrescriptionService.getAllPrescriptions();
      setState(() {
        prescriptions = data;
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
    await _fetchPrescriptions();
  }

  Future<void> _deletePrescription(int prescriptionId, String prescriptionName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFAF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$prescriptionName"?\n\nThis action cannot be undone.',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await PrescriptionService.deletePrescription(prescriptionId);
      
      if (success) {
        // Remove from local list immediately
        setState(() {
          prescriptions.removeWhere((p) => p.id == prescriptionId);
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete prescription: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18),
          ),
          title: const Text(
            "Prescription",
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
        )
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    } else if (error != null) {
      return _buildErrorState();
    } else if (prescriptions.isEmpty) {
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
          Text('Loading prescriptions...'),
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
            'Failed to load prescriptions',
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
            'No prescriptions found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: prescriptions.map((prescription) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: CustomPrescriptions(
                prescriptionName: prescription.prescriptionName,
                date: prescription.formattedNextAppointment,
                onDownload: () async {
                  try {
                    // Generate PDF locally with platform-specific handling
                    final bool success = await PrescriptionPdfService.generateAndSavePrescriptionPdf(prescription);
                    
                    if (success) {
                      // Show platform-specific success message
                      String successMessage = Platform.isIOS 
                          ? 'Prescription PDF ready for sharing!' 
                          : 'Prescription PDF saved to Downloads folder!';
                          
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(successMessage),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'OK',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to generate PDF: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }
                },
                onShow: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrescriptionScreen(prescriptionId: prescription.id,  parentTabIndex: 4,),
                    ),
                  );
                },
                onDelete: () {
                  _deletePrescription(prescription.id, prescription.prescriptionName);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotImplementedMessage(String action, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action functionality not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
