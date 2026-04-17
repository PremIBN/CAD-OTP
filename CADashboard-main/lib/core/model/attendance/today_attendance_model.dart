class TodayAttendance {
  final bool isSignedIn;
  final DateTime? signInAt;
  final DateTime? signOutAt;

  TodayAttendance({
    required this.isSignedIn,
    required this.signInAt,
    required this.signOutAt,
  });
}

