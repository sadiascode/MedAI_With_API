class Urls {
  static const String baseUrl = "https://test15.fireai.agency";

  // Signup
  static const String Signup = "$baseUrl/users/signup/";

  // verify otp for signup and forgot
  static const String signup_verifyotp = "$baseUrl/users/otp/verify/";

  //forget pass
  static const String forget_password = "$baseUrl/users/otp/request/";

  //resend otp for Signup and Forget
  static const String resend_otp = "$baseUrl/users/otp/request/";

  //reset password
  static const String reset_password = "$baseUrl/users/password/reset/";

  //resend otp
  static const String forgot_pass = "$baseUrl/users/otp/resend/";

  // login
  static const String User_signin = "$baseUrl/users/login/";

  // Log out
  static const String Log_Out = "$baseUrl/users/logout/";


  // profile
  static const String profile = "$baseUrl/users/profile/";
  static const String update_profile = "$baseUrl/users/profile/";
  static const String Delete_Account = "$baseUrl/users/account/deactivate/";
  static const String Change_Password = "$baseUrl/users/password/change/";

  // All Doctor list
  static const String Doctor_list = "$baseUrl/doctors/profile/";

  // Single Doctor
  static String singleDoctor(int id) {
    return "$baseUrl/doctors/profile/$id/";
  }

  // Add doctor
  static const String Add_doctor = "$baseUrl/doctors/profile/";

  // Add Doctor Note
  static String addNote(int doctorId) {
    return "$baseUrl/doctors/profile/$doctorId/notes/";
  }

  //Home Dashboard
  static String homeDashboard({DateTime? date}) {
    final d = date ?? DateTime.now();
    return "$baseUrl/users/dashboard/${d.year}-${d.month}-${d.day}/";
  }

  // All Medicine
  static const String All_Medicine = "$baseUrl/treatments/medicines/";

  // Get Medicine By id
  static String refillMedicine(int id) {
    return "$baseUrl/treatments/medicines/$id/";
  }

  // Update Medicine Stock
  static String updateMedicineStock(int id) {
    return "$baseUrl/treatments/medicine/stock/$id/";
  }

 // Medicine List
  static const String Medicine_list = "$baseUrl/treatments/pharmacy/";

  // Add Pharmacy
  static const String Add_pharmacy = "$baseUrl/treatments/pharmacy/";

  // Get all prescriptions
  static const String Get_all_prescriptions = "$baseUrl/treatments/prescription/";

  // Delete Prescription
  static String deletePrescription(int id) {
    return "$baseUrl/treatments/prescription/$id/";
  }

  // ChatBot
  static const String Chat_Bot = "$baseUrl/chatbot/chat/";
  static const String Chat_History = "$baseUrl/chatbot/history/";

  // Delete Account
  static const String delete_account = "$baseUrl/users/account/delete/";
}
