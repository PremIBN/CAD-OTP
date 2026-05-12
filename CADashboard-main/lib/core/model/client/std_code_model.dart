import 'package:cadashboard/core/utils/iso_country_dial_fallback.dart';

class StdCodeModel {
  StdCodeModel({
    required this.stdCode,
    required this.countryCode,
    required this.codeValue,
    required this.codeId,
    required this.codeName,
    required this.codeGroup,
    required this.validationErrors,
  });

  final String? stdCode;
  /// ISO 3166-1 alpha-2 from API `CountryCode` (may be empty on some rows).
  final String? countryCode;
  final int? codeValue;
  final int? codeId;
  final String? codeName;
  final String? codeGroup;
  final List<dynamic> validationErrors;

  factory StdCodeModel.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return StdCodeModel(
      stdCode: json['STDCode'] as String?,
      countryCode: json['CountryCode'] as String?,
      codeValue: asInt(json['CodeValue']),
      codeId: asInt(json['CodeID']),
      codeName: json['CodeName'] as String?,
      codeGroup: json['CodeGroup'] as String?,
      validationErrors:
          json['ValidationErrors'] == null ? [] : List<dynamic>.from((json['ValidationErrors'] as List).map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        'STDCode': stdCode,
        'CountryCode': countryCode,
        'CodeValue': codeValue,
        'CodeID': codeId,
        'CodeName': codeName,
        'CodeGroup': codeGroup,
        'ValidationErrors': validationErrors.map((x) => x).toList(),
      };

  /// Digits-only calling code for OTP: prefers `STDCode`, else `CountryCode` → known E.164 map.
  String? effectiveDialDigits() {
    final fromStd = (stdCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (fromStd.isNotEmpty) return fromStd;
    final iso = (countryCode ?? '').trim().toUpperCase();
    if (iso.length == 2) {
      final d = kIso2ToDialDigits[iso];
      if (d != null && d.isNotEmpty) return d;
    }
    return null;
  }
}
