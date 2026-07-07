// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get appTitle => 'ABSENSI AH..';

  @override
  String get loginSubtitle =>
      'Sign in to record real-time location-based attendance.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register here';

  @override
  String get errEmailEmpty => 'Email cannot be empty';

  @override
  String get errEmailInvalid => 'Invalid email format';

  @override
  String get errPasswordEmpty => 'Password cannot be empty';

  @override
  String get errPasswordMin => 'Password must be at least 6 characters';

  @override
  String get registerTitle => 'Registration';

  @override
  String get registerHeader => 'Create New Account';

  @override
  String get registerSubtitle =>
      'Register to start recording attendance today.';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get registerButton => 'Register';

  @override
  String get hasAccountLogin => 'Already have an account? Login here';

  @override
  String errFieldEmpty(String field) {
    return '$field cannot be empty';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get defaultUser => 'PPKD Participant';

  @override
  String get lightModeTooltip => 'Light Mode';

  @override
  String get darkModeTooltip => 'Dark Mode';

  @override
  String get todayAttendance => 'Today\'s Attendance';

  @override
  String get timeAnomalyBadge => '⚠️ Time Anomaly';

  @override
  String get statusLate => '• Late';

  @override
  String get statusOnTime => '• On Time';

  @override
  String get checkInLabel => 'Check In';

  @override
  String get checkOutLabel => 'Check Out';

  @override
  String get permitButton => 'Request Permit / Sick Leave';

  @override
  String get statTotal => 'Total';

  @override
  String get statPresent => 'Present';

  @override
  String get statPermit => 'Permit';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get historyTitle => 'Attendance History';

  @override
  String get emptyHistory => 'No attendance history yet.';

  @override
  String get dateNotAvailable => 'Date not available';

  @override
  String get viewMapMenu => 'View Map';

  @override
  String get deleteAttendanceMenu => 'Delete Attendance';

  @override
  String get permitReasonLabel => 'Permit Reason:';

  @override
  String get errIdNotFound => 'Attendance ID not found.';

  @override
  String get deleteDialogTitle => 'Delete Attendance?';

  @override
  String get deleteDialogContent =>
      'This attendance record will be deleted from server. Continue?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get errCoordsNotAvailable => 'Location coordinates not available.';

  @override
  String get submitMapTitleCheckIn => 'Check In (Live Map)';

  @override
  String get submitMapTitleCheckOut => 'Check Out (Live Map)';

  @override
  String get officeName => 'PPKD Office';

  @override
  String get officeDesc => 'Regional Vocational Training Center';

  @override
  String yourPosition(String distance) {
    return 'Your Position (${distance}m)';
  }

  @override
  String gpsAccuracy(String accuracy) {
    return 'GPS Accuracy: ±${accuracy}m';
  }

  @override
  String get detectingLocation =>
      'Detecting real-time location & GPS signal...';

  @override
  String get inGeofence => 'Within Geofence Radius';

  @override
  String get outGeofence => 'Outside Office Radius';

  @override
  String distanceInfo(String distance, String max) {
    return 'Distance: ${distance}m (Max ${max}m)';
  }

  @override
  String get gpsWeak => '(Weak >50m)';

  @override
  String get gpsGood => '(Good)';

  @override
  String get tooFarButton => 'Too Far from Office';

  @override
  String get searchingGpsButton => 'Searching for Stable GPS...';

  @override
  String get confirmCheckInButton => 'Confirm Check In';

  @override
  String get confirmCheckOutButton => 'Confirm Check Out';

  @override
  String get detailMapTitle => 'Attendance Location';

  @override
  String get pointInfoTitle => 'Attendance Point Details:';

  @override
  String checkInPointInfo(String time, String address) {
    return 'Check In ($time): $address';
  }

  @override
  String checkOutPointInfo(String time, String address) {
    return 'Check Out ($time): $address';
  }

  @override
  String get googleMapsTitle => 'Google Maps';

  @override
  String get searchingLocation => 'Searching Location...';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get currentAddressLabel => 'Your Current Address:';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String errOpenExternalMap(String error) {
    return 'Failed to open external map: $error';
  }

  @override
  String get permitFormTitle => 'Permit Application';

  @override
  String get permitFormHeader => 'Permit / Absence Form';

  @override
  String get permitFormSubtitle => 'Please fill in the details below clearly.';

  @override
  String get permitDateLabel => 'Permit Date';

  @override
  String get selectDateHint => 'Select Date...';

  @override
  String get permitReasonFieldLabel => 'Permit Reason';

  @override
  String get permitReasonHint =>
      'Example: Dengue fever (medical certificate attached)';

  @override
  String get submitPermitButton => 'Submit Permit';

  @override
  String get errSelectDateFirst => 'Please select permit date first.';

  @override
  String get errPermitReasonEmpty => 'Permit reason cannot be empty.';

  @override
  String get pickFromGallery => 'Choose from Gallery';

  @override
  String get takePhotoCamera => 'Take Photo (Camera)';

  @override
  String get photoUpdateSuccess => 'Profile photo updated successfully.';

  @override
  String get photoUpdateFailed => 'Failed to update profile photo.';

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutConfirm =>
      'Are you sure you want to sign out of this session?';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get personalInfoSection => 'Personal Information';

  @override
  String get editButton => 'EDIT';

  @override
  String get fieldFullName => 'FULL NAME';

  @override
  String get fieldEmail => 'EMAIL';

  @override
  String get fieldGender => 'GENDER';

  @override
  String get fieldMajor => 'MAJOR';

  @override
  String get fieldBatch => 'BATCH';

  @override
  String get securitySection => 'Security';

  @override
  String get changePasswordMenu => 'Change Password';

  @override
  String get notificationMenu => 'Notifications';

  @override
  String get notifActive => 'Active';

  @override
  String get notifInactive => 'Inactive';

  @override
  String get languageSection => 'Language';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get darkModeMenu => 'Dark Mode';

  @override
  String get darkModeDesc => 'Use dark theme for better eye comfort';

  @override
  String get aboutAppMenu => 'About Application';

  @override
  String get loadingText => 'Loading...';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get requiredField => 'Required field';

  @override
  String get majorFieldLabel => 'Major (Training)';

  @override
  String get batchFieldLabel => 'Batch';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile.';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get stubWarning =>
      'Notice: /api/change-password API is not yet available. This operation is currently simulated (stub).';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get errPasswordMismatch => 'Passwords do not match';

  @override
  String get updatePasswordButton => 'Update Password';

  @override
  String get passwordChangeSuccess => 'Password changed successfully.';

  @override
  String get passwordChangeFailed => 'Failed to change password.';

  @override
  String get errAlreadyCheckedInToday => 'You have already checked in today.';

  @override
  String get errAlreadyPermittedToday =>
      'You have already submitted a permit for this date.';

  @override
  String get errSessionExpired =>
      'Your session has expired. Please login again.';

  @override
  String get errNetworkError =>
      'Network error occurred. Please check your internet connection.';

  @override
  String get errServer500 => 'Server error occurred. Please try again later.';

  @override
  String get errInvalidData => 'Submitted data is invalid.';

  @override
  String get errCheckInFailed => 'Failed to check in.';

  @override
  String get errCheckOutFailed =>
      'Failed to check out. You haven\'t checked in today.';

  @override
  String get errPermitFailed => 'Failed to submit permit.';

  @override
  String get errDeleteFailed => 'Failed to delete attendance data.';

  @override
  String get errLoginFailed =>
      'Login failed. Please check your email and password.';

  @override
  String get permitSuccess => 'Permit submitted successfully.';

  @override
  String get checkInSuccess => 'Check-in successful.';

  @override
  String get checkOutSuccess => 'Check-out successful.';

  @override
  String get deleteSuccess => 'Attendance data deleted successfully.';
}
