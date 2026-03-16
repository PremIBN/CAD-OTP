**Document**

**Upload (mobile app):** The app uploads via multipart/form-data or JSON (POST) with `tokenID`, `docFolderID`, and file. If the server returns "No action was found on the controller", the backend must add a document upload action. See **BACKEND_DOCUMENT_UPLOAD_SPEC.md** for the exact contract and set `Urls.documentUploadEndpointOverride` in `lib/core/url/api_url.dart` to the correct URL once the backend implements it.

**URL**

https://www.cadashboard.com/web/api/Document/GetFolderList?tokenID=9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea&clientOrgID=0

(Get Folder And Documents inside folder on page load)

**Web service Response**

{

\[

{

\"ModifiedDate\": \"2019-07-17T11:57:55\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 588307,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"/Umesh Private Ltd\",

\"ParentFolderId\": 0,

\"FolderName\": \"Umesh Private Ltd\",

\"FolderDocuments\": \[

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 132236,

\"DocumentName\": \"CAdashboard_UploadEmployee.xlsx\",

\"FilePath\": \"367687_1/132236_1.xlsx\",

\"DocFolderID\": 588307,

\"ServiceId\": 232456,

\"FileSize\": 14162,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"CAdashboard_UploadEmploye.xlsx\",

\"Version\": 0,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 1,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 16394188,

\"SubCategoryID\": 0,

\"Comments\": \"hi this is for test\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-19T17:51:22\",

\"ModifiedBy\": 372322,

\"ModifiedByName\": \"Client5.test test\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 132237,

\"DocumentName\": \"Admin Cadashboard Renewals.xls\",

\"FilePath\": \"367687_1/132237_1.xls\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 41984,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"Come.xls\",

\"Version\": 0,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-08-31T14:43:09\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 133824,

\"DocumentName\": \"GST uSER MANUAL - COMBINED.pdf\",

\"FilePath\": \"367687_1/133824_1.pdf\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 7571722,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"GST uSER MANUAL - COMBINED.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-08-19T16:16:40\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 0,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134290,

\"DocumentName\": \"130183642_1561539781663.xls\",

\"FilePath\": \"367687_1/134290_1.xls\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 30720,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"130183642_1561539781663.xls\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-08-31T14:58:14\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 0,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134342,

\"DocumentName\": \"QTN-00000003.pdf\",

\"FilePath\": \"367687_1/134342_1.pdf\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 31866,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"QTN-00000003.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-04T12:27:59\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 0,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134508,

\"DocumentName\": \"Expense.pdf\",

\"FilePath\": \"367687_1/134508_1.pdf\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 436545,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"Expense.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-09T16:04:19\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134510,

\"DocumentName\": \"Expense.pdf\",

\"FilePath\": \"367687_1/134510_1.pdf\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 436545,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"Expense.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-19T17:51:37\",

\"ModifiedBy\": 372322,

\"ModifiedByName\": \"Client5.test test\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134578,

\"DocumentName\": \"CA Basic Works.docx\",

\"FilePath\": \"367687_1/134578_1.docx\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 19492,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"CA Basic Works.docx\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 1,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-11T16:35:34\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134979,

\"DocumentName\": \"RCPT-26865.pdf\",

\"FilePath\": \"367687_1/134979_1.pdf\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 6544,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"RCPT-26865.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-23T12:55:33\",

\"ModifiedBy\": 372325,

\"ModifiedByName\": \"Employee5 test\",

\"ClientID\": 0,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

}

\],

\"DefaultFolderType\": 1,

\"FolderList\": \[

{

\"ModifiedDate\": \"2019-07-25T11:15:23\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 588454,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 588307,

\"FolderName\": \"test\",

\"FolderDocuments\": \[\],

\"DefaultFolderType\": 0,

\"FolderList\": \[

{

\"ModifiedDate\": \"2019-07-25T11:15:42\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 588455,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 588454,

\"FolderName\": \"abcd\",

\"FolderDocuments\": \[

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 132258,

\"DocumentName\": \"INV-00000001.pdf\",

\"FilePath\": \"367687_1/132258_1.pdf\",

\"DocFolderID\": 588455,

\"ServiceId\": 0,

\"FileSize\": 2590,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"INV-00000001.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 0,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-08-31T14:54:54\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 0,

\"LoginOrgID\": 0,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

}

\],

\"DefaultFolderType\": 0,

\"FolderList\": \[\],

\"ValidationErrors\": \[\]

}

\],

\"ValidationErrors\": \[\]

},

{

\"ModifiedDate\": \"2019-08-31T14:34:53\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 589238,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 588307,

\"FolderName\": \"ABCD\",

\"FolderDocuments\": \[\],

\"DefaultFolderType\": 0,

\"FolderList\": \[\],

\"ValidationErrors\": \[\]

}

\],

\"ValidationErrors\": \[\]

},

{

\"ModifiedDate\": \"2019-07-17T11:57:55\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 588308,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"/Shared To Me\",

\"ParentFolderId\": 0,

\"FolderName\": \"Shared To Me\",

\"FolderDocuments\": \[\],

\"DefaultFolderType\": 2,

\"FolderList\": \[\],

\"ValidationErrors\": \[\]

},

{

\"ModifiedDate\": \"2019-07-17T11:57:55\",

\"ModifiedByName\": \"Umesh Kaudare\",

\"TokenID\": \"9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea\",

\"DocFolderID\": 588309,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"/Shared By Me\",

\"ParentFolderId\": 0,

\"FolderName\": \"Shared By Me\",

\"FolderDocuments\": \[

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 133825,

\"DocumentName\": \"GST uSER MANUAL - COMBINED.pdf\",

\"FilePath\": \"367687_1/133825_1.pdf\",

\"DocFolderID\": 588761,

\"ServiceId\": 0,

\"FileSize\": 7571722,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"GST uSER MANUAL - COMBINED.pdf\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 1,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-08-31T14:40:23\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 367873,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

},

{

\"RaisedByOrgName\": null,

\"RaisedByUserName\": null,

\"ModifiedDateDisplay\": null,

\"Link\": null,

\"Acknowledgename\": null,

\"IsClient\": 0,

\"TaskNumber\": null,

\"TokenID\": \"\",

\"DocumentID\": 134578,

\"DocumentName\": \"CA Basic Works.docx\",

\"FilePath\": \"367687_1/134578_1.docx\",

\"DocFolderID\": 588307,

\"ServiceId\": 0,

\"FileSize\": 19492,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"Tags\": \"CA Basic Works.docx\",

\"Version\": 1,

\"IsLocked\": 0,

\"IsControlled\": 0,

\"IsVersionControlled\": 0,

\"IsVisibleToClient\": 1,

\"FinancialYearID\": 12040,

\"StatusID\": 0,

\"CategoryID\": 0,

\"SubCategoryID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 0,

\"FolderName\": \"\",

\"ModifiedDate\": \"2019-09-11T16:35:34\",

\"ModifiedBy\": 372085,

\"ModifiedByName\": \"Umesh Kaudare\",

\"ClientID\": 367881,

\"LoginOrgID\": 367687,

\"DocumentLinks\": \"\",

\"ValidationErrors\": \[\]

}

\],

\"DefaultFolderType\": 3,

\"FolderList\": \[\],

\"ValidationErrors\": \[\]

}

\]

}

**URL**

https://www.cadashboard.com/web/api/Document/DeleteFolder?tokenID=9dee7b98-2d2f-4683-a6b3-2e7bd00e09ea&id=588454

(Delete Folder)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/DeleteFile?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=133824

(Delete Specific File)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/ShareDocument?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=132181

(Share Document with client)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/UnShareDocument?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=132181

(Un-Share Document with client)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/DownloadDocument?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&documentID=132181

(Download Document)

**Web service Response**

{

{

\"DocumentName\": \"CA Basic Works.docx\",

\"filebytes\":
\"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\"

}

}

**URL**

https://www.cadashboard.com/web/api/Document/LockDocument?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=132181

(Lock Document)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/UnLockDocument?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=132181

(Un-Lock Document)

**Web service Response**

{

\"Record inserted successfully.\"

}

**URL**

https://www.cadashboard.com/web/api/Document/GetDocumentURL?tokenID=562693d1-2cb8-4439-8e8c-4b7668105ea3&id=132181

(View Document)

**Web service Response**

{

\"{\\\"url\\\":\\\"https://cadprodnew.s3-ap-southeast-1.amazonaws.com/caddata/367687_1/132181_1.docx?AWSAccessKeyId=AKIAJSUYAY4BEBSCHTGQ&Expires=1569311970&Signature=OsBIRdIWFdtUKuVp0v%2FEwVRCPPs%3D\\\"}\"

}

Add Folder:- First check whether folder name already exists. Then add
Folder.

Both APIS are below.

**URL**

https://www.cadashboard.com/web/api/Document/CheckIfFolderNameExist?tokenID=8c75988b-85a4-42a3-ae7b-77cfd609d670&foldername=ABCD&parentfolderid=588307

(Add Folder:- Check if folder Exists)

**Web service Response** (If Folder Already Exists)

{

\[

{

\"ModifiedDate\": \"2019-09-24T14:49:23.0592572+05:30\",

\"TokenID\": \"8c75988b-85a4-42a3-ae7b-77cfd609d670\",

\"DocFolderID\": 589238,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 588307,

\"FolderName\": \"ABCD\",

\"FolderDocuments\": null,

\"ModifiedByName\": \"\",

\"DefaultFolderType\": 0,

\"ClientID\": 0,

\"ValidationErrors\": \[\]

}

\]

}

**URL**

https://www.cadashboard.com/web/api/Document/CheckIfFolderNameExist?tokenID=8c75988b-85a4-42a3-ae7b-77cfd609d670&foldername=Test
1&parentfolderid=588307

(Add Folder :- Check if folder Exists)

**Web service Response** (If Folder Not Exists)

{

\[

\]

}

**\[POST METHOD\]**

**URL**

https://www.cadashboard.com/web/api/Document/AddFolder

(Add Folder)

**parameters**

{

{

\"DocFolderID\":0,

\"FolderName\":\"Test 1\",

\"FolderPath\":\"\",

\"TokenID\":\"8c75988b-85a4-42a3-ae7b-77cfd609d670\",

\"FinancialYearID\":0,

\"ParentFolderId\":588307,

\"Comments\":\"\",

\"ClientID\":0

}

}

**Web service Response**

{

\"Record inserted successfully.\"

}

Rename Folder:- First check whether folder name already exists. Then
rename Folder.

Both APIS are below.

**URL**

https://www.cadashboard.com/web/api/Document/CheckIfFolderNameExist?tokenID=8c75988b-85a4-42a3-ae7b-77cfd609d670&foldername=ABCD&parentfolderid=588307

(Rename Folder:- Check if folder Exists)

**Web service Response** (If Folder Already Exists)

{

\[

{

\"ModifiedDate\": \"2019-09-24T14:49:23.0592572+05:30\",

\"TokenID\": \"8c75988b-85a4-42a3-ae7b-77cfd609d670\",

\"DocFolderID\": 589238,

\"OrgID\": 367687,

\"OrgTypeID\": 1,

\"FinancialYearID\": 0,

\"Comments\": \"\",

\"FolderPath\": \"\",

\"ParentFolderId\": 588307,

\"FolderName\": \"ABCD\",

\"FolderDocuments\": null,

\"ModifiedByName\": \"\",

\"DefaultFolderType\": 0,

\"ClientID\": 0,

\"ValidationErrors\": \[\]

}

\]

}

**URL**

https://www.cadashboard.com/web/api/Document/CheckIfFolderNameExist?tokenID=8c75988b-85a4-42a3-ae7b-77cfd609d670&foldername=Test
1&parentfolderid=588307

(Rename Folder :- Check if folder Exists)

**Web service Response** (If Folder Not Exists)

{

\[

\]

}

**\[POST METHOD\]**

**URL**

https://www.cadashboard.com/web/api/Document/AddFolder

(Rename Folder)

**parameters**

{

{

\"DocFolderID\":589611,

\"FolderName\":\"Test 2\",

\"FolderPath\":\"\",

\"TokenID\":\"8c75988b-85a4-42a3-ae7b-77cfd609d670\",

\"FinancialYearID\":0,

\"ParentFolderId\":588307,

\"Comments\":\"\",

\"ClientID\":0

}

}

**Web service Response**

{

\"Record inserted successfully.\"

}
