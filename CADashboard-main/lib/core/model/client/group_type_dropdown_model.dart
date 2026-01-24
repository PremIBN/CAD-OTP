class GroupTypeModel {
  GroupTypeModel({
    required this.tokenId,
    required this.orgCode,
    required this.groupName,
    required this.orgGroupId,
    required this.orgName,
    required this.orgId,
    required this.requestComment,
    required this.requestStatus,
    required this.status,
    required this.clientOrgId,
    required this.orgGroupRelId,
    required this.requestDate,
    required this.orgGroupRequestId,
    required this.serviceRequestId,
    required this.createdByOrgId,
    required this.addedBy,
    required this.modifiedBy,
    required this.addedDate,
    required this.modifiedDate,
    required this.assignedToCount,
    required this.validationErrors,
  });

  final dynamic tokenId;
  final int? orgCode;
  final String? groupName;
  final int? orgGroupId;
  final dynamic orgName;
  final int? orgId;
  final dynamic requestComment;
  final int? requestStatus;
  final String? status;
  final int? clientOrgId;
  final int? orgGroupRelId;
  final DateTime? requestDate;
  final int? orgGroupRequestId;
  final int? serviceRequestId;
  final int? createdByOrgId;
  final dynamic addedBy;
  final dynamic modifiedBy;
  final dynamic addedDate;
  final dynamic modifiedDate;
  final int? assignedToCount;
  final List<dynamic> validationErrors;

  factory GroupTypeModel.fromJson(Map<String, dynamic> json){
    return GroupTypeModel(
      tokenId: json["TokenID"],
      orgCode: json["OrgCode"],
      groupName: json["GroupName"],
      orgGroupId: json["OrgGroupID"],
      orgName: json["OrgName"],
      orgId: json["OrgID"],
      requestComment: json["RequestComment"],
      requestStatus: json["RequestStatus"],
      status: json["Status"],
      clientOrgId: json["ClientOrgID"],
      orgGroupRelId: json["OrgGroupRelID"],
      requestDate: DateTime.tryParse(json["RequestDate"] ?? ""),
      orgGroupRequestId: json["OrgGroupRequestID"],
      serviceRequestId: json["ServiceRequestID"],
      createdByOrgId: json["CreatedByOrgId"],
      addedBy: json["AddedBy"],
      modifiedBy: json["ModifiedBy"],
      addedDate: json["AddedDate"],
      modifiedDate: json["ModifiedDate"],
      assignedToCount: json["AssignedToCount"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
