class ClientInfoModel {
  ClientInfoModel({
    required this.raisedByOrgName,
    required this.orgName,
    required this.attributeId,
    required this.attributeTypeId,
    required this.attributeName,
    required this.attributeDescription,
    required this.orgId,
    required this.isDefault,
    required this.isActive,
    required this.isDeleted,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.orgAttributeValue,
    required this.orgAttributeId,
    required this.clientOrgId,
    required this.tokenId,
    required this.documentId,
    required this.documentName,
    required this.insertionType,
    required this.isBulkUpdate,
    required this.validationErrors,
  });

  final dynamic raisedByOrgName;
  final dynamic orgName;
  final int? attributeId;
  final int? attributeTypeId;
  final String? attributeName;
  final String? attributeDescription;
  final int? orgId;
  final int? isDefault;
  final int? isActive;
  final int? isDeleted;
  final int? addedBy;
  final dynamic addedDate;
  final int? modifiedBy;
  final dynamic modifiedDate;
  final String? orgAttributeValue;
  final int? orgAttributeId;
  final int? clientOrgId;
  final String? tokenId;
  final int? documentId;
  final String? documentName;
  final int? insertionType;
  final int? isBulkUpdate;
  final List<dynamic> validationErrors;

  factory ClientInfoModel.fromJson(Map<String, dynamic> json){
    return ClientInfoModel(
      raisedByOrgName: json["RaisedByOrgName"],
      orgName: json["OrgName"],
      attributeId: json["AttributeID"],
      attributeTypeId: json["AttributeTypeID"],
      attributeName: json["AttributeName"],
      attributeDescription: json["AttributeDescription"],
      orgId: json["OrgID"],
      isDefault: json["IsDefault"],
      isActive: json["IsActive"],
      isDeleted: json["IsDeleted"],
      addedBy: json["AddedBy"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      orgAttributeValue: json["OrgAttributeValue"],
      orgAttributeId: json["OrgAttributeID"],
      clientOrgId: json["ClientOrgID"],
      tokenId: json["TokenID"],
      documentId: json["DocumentID"],
      documentName: json["DocumentName"],
      insertionType: json["InsertionType"],
      isBulkUpdate: json["IsBulkUpdate"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
