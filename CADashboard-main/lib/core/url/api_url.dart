// ignore_for_file: constant_identifier_names

class Urls{

  static const String baseUrl = 'https://www.cadashboard.com/web/api/';
  static const String Authenticate = '${baseUrl}Authenticate/';
  static const String HomeDashboard = '${baseUrl}HomeDashboard/';
  static const String Task = '${baseUrl}Task/';
  /// ASP.NET Web API: `ComboBoxController` → route segment **ComboBox** (suffix `Controller` omitted).
  static const String ComboBox = '${baseUrl}ComboBox/';
  static const String Org = '${baseUrl}Org';
  static const String SavePanNumber = '${baseUrl}OrgAttributes/AddUpdateOrgAttributeValue';
  static const String clientInformation = '${baseUrl}OrgAttributes/GetAttributesByOrgID';
  static const String Report = '${baseUrl}Report/';

  static const String notification = '${baseUrl}WebNotification/GetEmployeeUnreadNotification';
  static const String clearNotification = '${baseUrl}WebNotification/ClearWebNotification';

  static const String checkLocation = '${baseUrl}OrgSettings/IsLocationWithinGeofence';

  static const String AuthenticateUser = '${Authenticate}AuthenticateUser';
  static const String ValidateToken = '${Authenticate}ValidateToken';
  static const String LogoutUser = '${Authenticate}LogoutUser';
  static const String forgotPassword = '${Authenticate}RequestForgotPassword';
  /// OTP login (WhatsApp/SMS) - backend-driven.
  static const String GenerateLoginOTP = '${Authenticate}GenerateLoginOTP';
  /// Verifies OTP and returns login credentials (existing backend API).
  static const String ValidateOTPAndLogin = '${Authenticate}ValidateOTPAndLogin';
  static const String AddLoggedInAreaAddress = '${HomeDashboard}AddLoggedInAreaAddress';
  static const String GetAttendanceDetails = '${HomeDashboard}GetAttendanceDetails';
  static const String MarkAttendance = '${HomeDashboard}MarkAttendance';
  static addLoggedInAreaAddress({required String tokenID, required String address, required String loginDetailID, required String latitude, required String longitude, required String isLogin})
  => "${HomeDashboard}AddLoggedInAreaAddress?tokenID=$tokenID&address=$address&LoginDetailID=$loginDetailID&latitude=$latitude&longitude=$longitude&IsLogin=$isLogin";

  static const String ChangePassword = '${baseUrl}User/UserChangePassword';
  static const String GetAllClient = '${baseUrl}org/GetAllOrganisations';

  static const String GetTaskStatusCount = '${Task}GetTaskStatusCount';
  static const String GetTaskRelatedDropDowns = '${Task}GetTaskRelatedDropDowns';
  static const String GetAllOrgTasks = '${Task}GetAllOrgTasks';
  static const String getAllTaskDetailsByID = '${Task}GetAllTaskDetailsByID';
  static const String addUpdateTask = '${Task}AddUpdateTask';
  static const String addUpdateTaskNote = '${Task}AddUpdateTaskNotes';
  static const String addUpdateTaskEffort = '${Task}AddUpdateTaskEffort';

  static const String PANCheck = '$Org/CheckIfPannumberExists';
  static const String AddUpdateClient = '$Org/AddUpdateOrganisation';
  static const String SpecificClient = '$Org/GetOrganisationByID';
  static const String Address = '$Org/GetOrgAddressByID';
  static const String ownerDetails = '$Org/GetAllContactPersonOrgID';

  static const String GetAllCurrency = '${ComboBox}GetAllCurrency';
  static const String GetAllCurrencyList = '${ComboBox}GetAllCurrencyList';
  static const String PriorityDropDown = '${ComboBox}GetCodeValueByCodeGroup';
  static const String GetBranch = '${ComboBox}GetBranchListByID';
  static const String GetDepartment = '${ComboBox}GetAllDepartments';
  static const String ClientDropDown = '${ComboBox}GetCodeValueByCodeGroup';
  static const String clientSupplyTypeDropDown = '${ComboBox}GetCodeValueByCodeGroup';
  /// [HttpGet] `ComboBoxController.GetAllCountry()`
  ///
  /// **Full URL:** `https://www.cadashboard.com/web/api/ComboBox/GetAllCountry`
  ///
  /// JSON rows include `STDCode`, `CountryCode`, `CodeName`, `CodeID`, etc.
  /// Used for country / STD list (OTP login picker, Add Client STD, etc.).
  static const String comboBoxControllerGetAllCountry = '${ComboBox}GetAllCountry';
  static const String GetAllCountry = comboBoxControllerGetAllCountry;
  static const String STDCodeList = comboBoxControllerGetAllCountry;
  static const String GroupTypeDropDown = '${ComboBox}GetOrgnGroupListByID';
  static const String BranchList = '${ComboBox}GetBranchListByID';
  static const String FinancialYear = '${ComboBox}GetFinancialYearList';
  static const String ARPriorityList = '${ComboBox}GetCodeValueByCodeGroup';

  static const String ReceivableData = '${Report}GetAccountReceivableData';
  static const String GetCurrencyWiseTotalAmountDetails = '${Report}GetCurrencyWiseTotalAmountDetails';
  static const String GetTodaysAttendanceHistory = '${Report}GetTodaysAttendanceHistory';

  /// Menu / RBAC
  /// Returns role-filtered menu and submenu items for the authenticated user.
  static const String CreateMenuSubMenu = '${Authenticate}CreateMenuSubMenu';


  /// Document
  static const String Document = '${baseUrl}Document/';
  static String getFolderList({
    required String tokenID,
    String clientOrgID = '2',
    String? financialYearID,
  }) {
    var url = '${Document}GetFolderList?tokenID=$tokenID&clientOrgID=$clientOrgID';
    if (financialYearID != null && financialYearID.isNotEmpty) {
      // Use same query key as Task APIs: "financialyearid"
      url += '&financialyearid=$financialYearID';
    }
    return url;
  }
  /// Folder contents (FolderDocuments + FolderList) for download. Same client/fy as current filter.
  static String getFolderContents({
    required String tokenID,
    required int folderID,
    String clientOrgID = '0',
    String? financialYearID,
  }) {
    var url = '${Document}GetFolderList?tokenID=$tokenID&clientOrgID=$clientOrgID&folderID=$folderID';
    if (financialYearID != null && financialYearID.isNotEmpty) {
      url += '&financialyearid=$financialYearID';
    }
    return url;
  }
  static String getDocumentURL({required String tokenID, required int id}) =>
      '${Document}GetDocumentURL?tokenID=$tokenID&id=$id';
  static String downloadDocument({required String tokenID, required int documentID}) =>
      '${Document}DownloadDocument?tokenID=$tokenID&documentID=$documentID';
  static String checkFolderNameExist({
    required String tokenID,
    required String foldername,
    required int parentfolderid,
  }) =>
      '${Document}CheckIfFolderNameExist?tokenID=$tokenID&foldername=${Uri.encodeComponent(foldername)}&parentfolderid=$parentfolderid';
  static const String addFolder = '${Document}AddFolder';

  /// Upload override: full URL for document upload. Must match backend action name exactly (PascalCase: UploadDocument).
  static const String documentUploadEndpointOverride =
      'https://www.cadashboard.com/web/api/Document/UploadFile';

  /// Upload: POST multipart. App tries override first, then these paths (SaveDocument, UploadDocument, UploadFile, etc.).
  static const String primaryDocumentUploadPath = '${Document}SaveDocument';
  static const String saveDocumentPath = primaryDocumentUploadPath;
  static const String uploadDocumentPath = '${Document}UploadDocument';
  static const String uploadPath = '${Document}Upload';
  static const String uploadFilePath = '${Document}UploadFile';
  static const String addDocumentPath = '${Document}AddDocument';
  static const String postDocumentPath = '${Document}Post';
  static String primaryDocumentUploadWithQuery({required String tokenID, required int docFolderID}) =>
      '${primaryDocumentUploadPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String uploadDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${uploadDocumentPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String uploadWithQuery({required String tokenID, required int docFolderID}) =>
      '${uploadPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String uploadFileWithQuery({required String tokenID, required int docFolderID}) =>
      '${uploadFilePath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String addDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${addDocumentPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String postDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${postDocumentPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String saveDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${saveDocumentPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';

  static const String uploadDocumentJsonPath = '${Document}UploadDocument';
  static const String addDocumentJsonPath = '${Document}AddDocument';

  static String documentControllerWithQuery({required String tokenID, required int docFolderID}) =>
      '${baseUrl}Document?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';

  static const String Documents = '${baseUrl}Documents/';
  static String documentsUploadWithQuery({required String tokenID, required int docFolderID}) =>
      '${Documents}Upload?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String documentsUploadFileWithQuery({required String tokenID, required int docFolderID}) =>
      '${Documents}UploadFile?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String documentsUploadDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${Documents}UploadDocument?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String documentsSaveDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${Documents}SaveDocument?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String documentsAddDocumentWithQuery({required String tokenID, required int docFolderID}) =>
      '${Documents}AddDocument?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static const String documentsUploadDocumentPath = '${Documents}UploadDocument';
  static const String documentsAddDocumentPath = '${Documents}AddDocument';

  static const String File = '${baseUrl}File/';
  static const String fileUploadPath = '${File}Upload';
  static const String fileUploadFilePath = '${File}UploadFile';
  static String fileUploadWithQuery({required String tokenID, required int docFolderID}) =>
      '${fileUploadPath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';
  static String fileUploadFileWithQuery({required String tokenID, required int docFolderID}) =>
      '${fileUploadFilePath}?tokenID=${Uri.encodeComponent(tokenID)}&docFolderID=$docFolderID';

  static String moveDocument({
    required String tokenID,
    required int documentID,
    required int targetFolderID,
  }) =>
      '${Document}MoveDocument?tokenID=$tokenID&documentID=$documentID&targetFolderID=$targetFolderID';
  static String moveFolder({
    required String tokenID,
    required int folderID,
    required int targetFolderID,
  }) =>
      '${Document}MoveFolder?tokenID=$tokenID&folderID=$folderID&targetFolderID=$targetFolderID';
  static String lockDocument({required String tokenID, required int id}) =>
      '${Document}LockDocument?tokenID=$tokenID&id=$id';
  static String unlockDocument({required String tokenID, required int id}) =>
      '${Document}UnLockDocument?tokenID=$tokenID&id=$id';
  static String unshareDocument({required String tokenID, required int id}) =>
      '${Document}UnShareDocument?tokenID=$tokenID&id=$id';

  ///     ComboBox value
  static const String clientType = 'ClientType';
  static const String firmType = 'FirmType';
  static const String industryType = 'IndustryType';
  static const String aRPriority = 'ARPriority';

  static const String youtube = 'https://www.youtube.com/channel/UCwqPI-XdpWlnxUEm6IrYMVg';
  static const String facebook = 'https://www.facebook.com/CADashboard';
  static const String linkedin = 'https://www.linkedin.com/company/cadashboard';
  static const String cadashboard = 'https://www.cadashboard.com';
  static const String twitter = 'https://twitter.com/CAdashboard';

  static const String privacy_policy = 'https://www.cadashboard.com/privacy_policy';
  static const String termsAndCondition = 'https://www.cadashboard.com/termsandcondition';


}