class AttendanceHistoryRow {
  final int srNo;
  final String time;
  final String signInOrSignOut;
  final String loginMode;
  final String address;

  AttendanceHistoryRow({
    required this.srNo,
    required this.time,
    required this.signInOrSignOut,
    required this.loginMode,
    required this.address,
  });

  factory AttendanceHistoryRow.fromJson(Map<String, dynamic> json, int index) {
    return AttendanceHistoryRow(
      srNo: index + 1,
      time: json['Time']?.toString() ?? '',
      signInOrSignOut: json['SignInOrSignOut']?.toString() ??
          json['SignInOrSignOutText']?.toString() ??
          '',
      loginMode: json['LoginMode']?.toString() ?? '',
      address: (json['Address']?.toString().isNotEmpty ?? false)
          ? json['Address'].toString()
          : '-',
    );
  }

  /// Backend `GetTodaysAttendanceHistory` sometimes returns a table-like payload:
  /// `{ columns: [...], data: [[..., Time, SignInOrSignOut, LoginMode, Address], ...] }`
  /// In that case each row is a List (not a Map).
  factory AttendanceHistoryRow.fromList(List row, int index) {
    String readAt(int i) {
      if (i < 0 || i >= row.length) return '';
      final v = row[i];
      if (v == null) return '';
      return v.toString();
    }

    final time = readAt(1);
    final sign = readAt(2);
    final mode = readAt(3);
    final addrRaw = readAt(4);
    final addr = addrRaw.trim().isEmpty ? '-' : addrRaw;
    return AttendanceHistoryRow(
      srNo: index + 1,
      time: time,
      signInOrSignOut: sign,
      loginMode: mode,
      address: addr,
    );
  }
}

