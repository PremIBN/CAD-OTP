class NotificationModel {
  NotificationModel({
    required this.tokenId,
    required this.notificationId,
    required this.notificationFor,
    required this.notificationBy,
    required this.message,
    required this.isRead,
    required this.notificationType,
    required this.itemId,
    required this.notificationForImg,
    required this.notificationByImg,
    required this.notificationDate,
    required this.notificationByName,
    required this.itemIdDecrypted,
    required this.validationErrors,
  });

  final dynamic tokenId;
  final int? notificationId;
  final int? notificationFor;
  final int? notificationBy;
  final String? message;
  final int? isRead;
  final int? notificationType;
  final String? itemId;
  final dynamic notificationForImg;
  final String? notificationByImg;
  final DateTime? notificationDate;
  final String? notificationByName;
  final String? itemIdDecrypted;
  final List<dynamic> validationErrors;

  factory NotificationModel.fromJson(Map<String, dynamic> json){
    return NotificationModel(
      tokenId: json["TokenID"],
      notificationId: json["NotificationID"],
      notificationFor: json["NotificationFor"],
      notificationBy: json["NotificationBy"],
      message: json["Message"],
      isRead: json["IsRead"],
      notificationType: json["NotificationType"],
      itemId: json["ItemID"],
      notificationForImg: json["NotificationForImg"],
      notificationByImg: json["NotificationByImg"],
      notificationDate: DateTime.tryParse(json["NotificationDate"] ?? ""),
      notificationByName: json["NotificationByName"],
      itemIdDecrypted: json["ItemID_Decrypted"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
