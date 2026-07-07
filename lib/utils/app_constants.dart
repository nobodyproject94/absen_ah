class AppConstants {
  // PPKD Office Default Location (Example: PPKD Jakarta Pusat)
  // Edit these coordinates to match the exact office location.
  static const double officeLatitude = -6.210491;
  static const double officeLongitude = 106.813218;

  // Geofence Radius in meters
  static const double attendanceRadius = 500.0;

  // Time Deadline for Check-In (e.g. 08:00 AM)
  static const String checkInDeadline = "08:00";

  // Time Anomaly Threshold in milliseconds (5 minutes)
  static const int timeAnomalyThresholdMs = 5 * 60 * 1000;

  // Minimum GPS Accuracy required in meters (50 meters)
  static const double minGpsAccuracyMeters = 50.0;
}
