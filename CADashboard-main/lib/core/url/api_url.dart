// ignore_for_file: constant_identifier_names

class Urls{

  static const String baseUrl = 'https://www.cadashboard.com/web/api/';
  static const String Authenticate = '${baseUrl}Authenticate/';
  static const String HomeDashboard = '${baseUrl}HomeDashboard/';
  static const String Task = '${baseUrl}Task/';
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
  static const String AddLoggedInAreaAddress = '${HomeDashboard}AddLoggedInAreaAddress';
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
  static const String STDCodeList = '${ComboBox}GetAllCountry';
  static const String GroupTypeDropDown = '${ComboBox}GetOrgnGroupListByID';
  static const String BranchList = '${ComboBox}GetBranchListByID';
  static const String FinancialYear = '${ComboBox}GetFinancialYearList';
  static const String ARPriorityList = '${ComboBox}GetCodeValueByCodeGroup';

  static const String ReceivableData = '${Report}GetAccountReceivableData';
  static const String GetCurrencyWiseTotalAmountDetails = '${Report}GetCurrencyWiseTotalAmountDetails';




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