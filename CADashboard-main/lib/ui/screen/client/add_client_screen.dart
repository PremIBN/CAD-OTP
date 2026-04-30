import 'package:cadashboard/core/View_Model/client/add_client_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/widget/custom_dropdown.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddClientScreen extends StatefulWidget {

  final String? orgId;
  const AddClientScreen({super.key, this.orgId});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {

  InputBorder borders = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(width: 1.5)
  );

  InputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(width: 1.5, color: Colors.red)
  );

  static const TextStyle _addClientLabelStyle =
      TextStyle(fontWeight: FontWeight.w800, fontSize: 15);
  static const TextStyle _addClientFieldStyle =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 15);
  static const TextStyle _addClientHintStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: Colors.black38,
  );
  static const TextStyle _addClientErrorStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  Widget clientField({
    required String label,
    required String hint,
    required Widget prefix,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged? onChanged,
    FormFieldValidator? onValidator}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            return Text(
              ApiTextLocalizer.localize(label, locale: Localizations.localeOf(context)),
              style: _addClientLabelStyle,
            );
          },
        ),
        const SizedBox(height: 5,),
        TextFormField(
          controller: controller,
          hintLocales: AppLocaleController.inputHintLocales(context),
          style: _addClientFieldStyle,
          textInputAction: label == 'Referred By' ? TextInputAction.send : TextInputAction.next,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: ApiTextLocalizer.localize(hint, locale: Localizations.localeOf(context)),
            hintStyle: _addClientHintStyle,
            contentPadding: const EdgeInsets.all(15),
            enabledBorder: borders,
            focusedBorder: borders,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorStyle: _addClientErrorStyle,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: prefix,
            ),
            prefixIconConstraints: const BoxConstraints.tightForFinite(),
          ),
          onSaved: (newValue) { },
          validator: onValidator,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final formkey = GlobalKey<FormState>();

    return StatelessBaseView(
      model: AddClientVM(),
      onInitState: (p0) {
        p0.token(context, widget.orgId);
      },
      builder: (buildContext, model, child) {
        return Scaffold(

          appBar: AppBar(
            title: Text(
              ApiTextLocalizer.localize(
                widget.orgId == null ? 'Add Client' : 'Update Client',
                locale: Localizations.localeOf(buildContext),
              ),
            ),
          ),

          body: ValueListenableBuilder(
            valueListenable: model.viewLoader,
            builder: (context, value, child) {

              if(value == ViewState.loading){
                return CommonLoader();
              } else if(value == ViewState.success){
                return ValueListenableBuilder(
                  valueListenable: model.loading,
                  builder: (context, value, child) {
                    return Stack(
                      children: [

                        if(value)Container(
                          width: double.infinity,height: double.infinity,
                          color: Colors.black38,
                          child: CommonLoader(),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
                          child: SingleChildScrollView(
                            child: Form(
                              key: formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  clientField(
                                    controller: model.companyNameController,
                                    label: 'Company Name',
                                    hint: 'Enter Company Name',
                                    prefix: Image.asset(AppImages.company,width: 25,height: 25,),
                                    onValidator: (value) {
                                      return model.companyNameController.text.isEmpty
                                          ? ApiTextLocalizer.localize('Please enter company name', locale: Localizations.localeOf(buildContext))
                                          : null;
                                    },
                                  ),

                                  clientField(
                                    controller: model.firstNameController,
                                    label: 'First Name',
                                    hint: 'Enter First Name',
                                    prefix: const Icon(Icons.person_outlined),
                                    onValidator: (value) {
                                      return model.firstNameController.text.isEmpty
                                          ? ApiTextLocalizer.localize('PLease enter first name', locale: Localizations.localeOf(buildContext))
                                          : null;
                                    },
                                  ),

                                  clientField(
                                    controller: model.lastNameController,
                                    label: 'Last Name',
                                    hint: 'Enter Last Name',
                                    prefix: const Icon(Icons.person_outlined),
                                    onValidator: (value) {
                                      return model.lastNameController.text.isEmpty
                                          ? ApiTextLocalizer.localize('PLease enter last name', locale: Localizations.localeOf(buildContext))
                                          : null;
                                    },
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Client Type', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Client Type', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.client == 0 ? null : model.client,
                                    items: model.clientType.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.client = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.clientType.map((e){
                                        return Text(e.displayName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null
                                          ? ApiTextLocalizer.localize('Please select client type', locale: Localizations.localeOf(buildContext))
                                          : null;
                                    },
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Client Supply Type', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Client Supply Type', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.clientSupplyTypeValue == 0 ? null : model.clientSupplyTypeValue,
                                    items: model.clientSupplyType.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.clientSupplyTypeValue = value;
                                      appPrint("Client Supply Type : $value ::: ${model.clientSupplyTypeValue}");
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.clientSupplyType.map((e){
                                        return Text(e.displayName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    // validator: (value) {
                                    //   return value == null ? 'Please select client supply type' : null;
                                    // },
                                  ),

                                  Text(
                                    ApiTextLocalizer.localize('Client joining Date', locale: Localizations.localeOf(buildContext)),
                                    style: _addClientLabelStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: model.startDateController,
                                    hintLocales: AppLocaleController.inputHintLocales(context),
                                    style: _addClientFieldStyle,
                                    decoration: InputDecoration(
                                      hintText: ApiTextLocalizer.localize('Select Client joining Date', locale: Localizations.localeOf(buildContext)),
                                      hintStyle: _addClientHintStyle,
                                      contentPadding:  const EdgeInsets.all(15),
                                      enabledBorder: borders,
                                      errorBorder: errorBorder,
                                      focusedErrorBorder: errorBorder,
                                      focusedBorder: borders,
                                      disabledBorder: borders,
                                      errorStyle: _addClientErrorStyle,
                                      suffixIcon: const Icon(CupertinoIcons.right_chevron,color: Colors.black54),
                                    ),
                                    onSaved: (newValue) {},
                                    // validator: (value) {
                                    //   return value!.isEmpty ? "Please select start date" : null;
                                    // },
                                    readOnly: true,
                                    onTap: () async{
                                      var startDate = await showDatePicker(
                                        context: context,
                                        locale: const Locale('en'),
                                        initialDate: model.startDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (startDate != null) {
                                        model.startDate = startDate;
                                        model.updateUI();
                                        model.startDateController.text = DateFormat('dd-MMM-yyyy').format(startDate);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(height: 15),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('STD Code', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select STD Code', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.stdCode == 0 ? null : model.stdCode,
                                    items: model.stdCodeType.map((e) {
                                      return DropdownMenuItem(
                                        value: int.parse((e.stdCode != null && e.stdCode != "") ? e.stdCode! : "0"),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(e.codeName ?? "", style: _addClientFieldStyle),
                                            const Divider(height: 10,),
                                          ],
                                        )
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      appPrint("STD CODE : $value");
                                      model.stdCode = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.stdCodeType.map((e){
                                        return Text(
                                          e.codeName ?? "",
                                          style: _addClientFieldStyle,
                                        );
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null ? 'Please select std code' : null;
                                    },
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Firm Type', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Firm Type', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.firm == 0 ? null : model.firm,
                                    items: model.firmType.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.firm = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.firmType.map((e){
                                        return Text(e.displayName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? 'Please select firm type' : null;
                                    },*/
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Industry Type', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Industry Type', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.industry == 0 ? null : model.industry,
                                    items: model.industryType.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.industry = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.industryType.map((e){
                                        return Text(e.displayName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? 'Please select industry type' : null;
                                    },*/
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Group Type', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Group Type', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.group == 0 ? null : model.group,
                                    items: model.groupType.map((e) {
                                      return DropdownMenuItem(value: e.orgGroupId, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.groupName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.group = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.groupType.map((e){
                                        return Text(e.groupName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? 'Please select group type' : null;
                                    },*/
                                  ),

                                  CusDropDown(
                                    label: ApiTextLocalizer.localize('Branch Name', locale: Localizations.localeOf(buildContext)),
                                    hint: ApiTextLocalizer.localize('Please Select Branch Name', locale: Localizations.localeOf(buildContext)),
                                    dropDownValue: model.branch == 0 ? null : model.branch,
                                    items: model.branchList.map((e) {
                                      return DropdownMenuItem(value: e.branchId, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.branchName ?? "", style: _addClientFieldStyle),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.branch = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.branchList.map((e){
                                        return Text(e.branchName ?? "", style: _addClientFieldStyle);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? 'Please select branch type' : null;
                                    },*/
                                  ),

                                  clientField(
                                    controller: model.phoneNumberController,
                                    label: 'Phone Number',
                                    hint: 'Enter Phone Number',
                                    prefix: const Icon(CupertinoIcons.phone),
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(10)],
                                    keyboardType: TextInputType.phone,
                                    // OnValidator: (value) {
                                    //   return phoneNumberController.text.isEmpty ? 'PLease enter phone number' : null;
                                    // },
                                  ),

                                  clientField(
                                    controller: model.emailController,
                                    label: 'Email',
                                    hint: 'Enter Email',
                                    prefix: const Icon(Icons.email_outlined),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      Utils.isEmail(value) == false ? !formkey.currentState!.validate() : formkey.currentState!.validate();
                                    },
                                    onValidator: (value) {
                                      if(model.emailController.text.isNotEmpty){
                                        return Utils.isEmail(value) == false ? "Please enter valid email id." : null;
                                      }else{
                                        return null;
                                      }
                                    },
                                  ),

                                  clientField(
                                    controller: model.panNumberController,
                                    label: 'PAN Number',
                                    hint: 'Enter PAN Number',
                                    prefix: const Icon(CupertinoIcons.creditcard),
                                    onValidator: (value) {
                                      return model.panNumberController.text.isEmpty
                                          ? ApiTextLocalizer.localize('PLease enter PAN number', locale: Localizations.localeOf(buildContext))
                                          : null;
                                      /*model.panRepo.checkPAN(panNumber: value).then((value){return value;}) != 0 ? 'PAN number already exists ' : null;*/
                                    },
                                  ),

                                  clientField(
                                    controller: model.fileNumberController,
                                    label: 'File Number',
                                    hint: 'Enter File Number',
                                    prefix: Image.asset(AppImages.file, width: 25,height: 25,),
                                    /*OnValidator: (value) {
                              return fileNumberController.text.isEmpty ? 'PLease enter file number' : null;
                            }*/
                                  ),

                                  clientField(
                                    controller: model.referredController,
                                    label: 'Referred By',
                                    hint: 'Enter Referred By',
                                    prefix: Image.asset(AppImages.referredBy, width: 25,height: 25,),
                                    /*OnValidator: (value) {
                                        return referredController.text.isEmpty ? 'PLease enter Referred By' : null;
                                    },*/
                                  ),

                                  Container(
                                    height: 60,width: double.infinity,
                                    margin: const EdgeInsets.symmetric(vertical: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              model.loading.value = true;
                                              if(formkey.currentState!.validate()){

                                                appPrint("Client Data :->: ${model.panNumberController.text.trim()} : ${model.firm} : ${model.industry} : ${model.group} : ${model.client} : ${model.branch}");

                                                if(widget.orgId != null) {
                                                  model.addClient(
                                                    context,
                                                    firm: model.firm!,
                                                    industry: model.industry!,
                                                    group: model.group!,
                                                    clientType: model.client!,
                                                    branch: model.branch!,
                                                    panNumber: model.panNumberController.text,
                                                    orgID: widget.orgId,
                                                    stdCode: model.stdCode,
                                                    clientSupplyType: model.clientSupplyTypeValue ?? 0,
                                                    clientJoiningDate: model.startDate,
                                                  );
                                                } else {
                                                  model.checkPAN(
                                                    context,
                                                    model.panNumberController.text,
                                                    model.stdCode,
                                                    model.firm,
                                                    model.industry,
                                                    model.group,
                                                    model.client,
                                                    model.branch,
                                                    model.clientSupplyTypeValue ?? 0,
                                                    model.startDate,
                                                  );
                                                }

                                              } else {
                                                appPrint("No");
                                                model.loading.value = false;
                                                model.updateUI();
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.background,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  ApiTextLocalizer.localize('Submit', locale: Localizations.localeOf(buildContext)),
                                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.background.withValues(alpha: (0.7)),
                                                borderRadius: BorderRadius.circular(8.0)
                                              ),
                                              
                                              child: Center(
                                                child: Text(
                                                  ApiTextLocalizer.localize('Cancel', locale: Localizations.localeOf(buildContext)),
                                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return EmptyData(emptyData: model.errorMessage);
              }
            },
          ),
        );
      },
    );
  }
}
