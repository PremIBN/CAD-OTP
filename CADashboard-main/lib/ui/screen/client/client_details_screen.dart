import 'package:cadashboard/core/View_Model/client/client_details_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/client/add_client_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';
import 'package:cadashboard/core/repository/menu_repository.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';

class ClientDetails extends StatefulWidget{

  final String orgID;
  final String? orgName;
  final String? clientName;
  final String? fileNumber;
  final String? branchName;
  final String? clientType;
  final String? groupName;
  final String? currenyName;


  const ClientDetails({super.key, this.orgName, this.clientName, this.branchName, this.clientType, this.groupName, this.fileNumber, required this.orgID, this.currenyName});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> with TickerProviderStateMixin {

  late TabController tabController;

  List tabs = ['Client Info','Address','Owner Details'];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
  }


  Widget text(String text){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,style: const TextStyle(fontWeight: FontWeight.w100,color: Colors.black87,fontSize: 14)),
        const SizedBox(height: 10,)
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget Details(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label,",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
        text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView(
        model: ClientDetailsVM(),
          onInitState: (p0) {
          p0.clientDetails(context, widget.orgID);
        },
        builder: (buildContext, model, child) {
          final locale = Localizations.localeOf(buildContext);
          return Scaffold(
            appBar: AppBar(
              title: Text(ApiTextLocalizer.localize('Client Details', locale: locale)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    if (!MenuRepository.canUpdateClient) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ApiTextLocalizer.localize('You do not have permission to edit', locale: locale)),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      cusNavigate(AddClientScreen(orgId: widget.orgID)),
                    ).then((value) {
                      model.viewLoader.value = ViewState.loading;
                      model.owner.clear();
                      model.address.clear();
                      model.clientInfo.clear();
                      model.updateUI();
                      model.clientDetails(context, widget.orgID);
                    });
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),

            body: Column(
              children: [
                TabBar(
                  controller: tabController,
                  tabs: tabs.map((e) => Tab(text: ApiTextLocalizer.localize(e.toString(), locale: locale))).toList(),
                ),

                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: model.viewLoader,
                    builder: (context, value, child) {
                      if(value == ViewState.loading) {
                        return CommonLoader();
                      } else if(value == ViewState.success) {
                        return TabBarView(
                          controller: tabController,
                          children: [

                            Padding(
                              padding: const EdgeInsets.all(10).copyWith(top: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(model.client.orgName != "")Details('Org. Name','${model.client.orgName}'),
                                    if(model.client.firstName != "")Details('Name', "${model.client.firstName} ${model.client.lastName}"),
                                    if(model.client.email != "")Details('Email ID', "${model.client.email}"),
                                    if(model.client.primaryMobile != "")Details('Mobile No.', "${model.client.primaryMobile}"),
                                    if(model.client.fileNumber != "")Details('File Number', "${model.client.fileNumber}"),
                                    if(model.branch != null && model.branch != "")Details('Branch Name', "${model.branch}"),
                                    if(model.clientType != null && model.clientType != "")Details('Client Type', "${model.clientType}"),
                                    if(widget.currenyName != "")Details('Currency Type', "${widget.currenyName}"),
                                    if(model.groupType != null && model.groupType != "")Details('Group Name', "${model.groupType}"),
                                    for(int i=0; i<model.clientInfo.length; i++)Details(model.clientInfo[i].attributeName!, model.clientInfo[i].orgAttributeValue!),
                                  ],
                                ),
                              )
                            ),
                            
                            model.address.isNotEmpty ? Padding(
                              padding: const EdgeInsets.all(10).copyWith(top: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: model.address.length,
                                      itemBuilder: (context, index) {
                                        var address = model.address[index];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 15),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(address.addressType != "")Details('Address Type', "${address.addressType}"),
                                                if(address.addressLine1 != "")Details('Address', "${address.addressLine1}  ${address.addressLine2}"),
                                                if(address.countryName != "")Details('Country', "${address.countryName}"),
                                                if(address.stateName != "")Details('State', "${address.stateName}"),
                                                if(address.cityName != "")Details('City', "${address.cityName}"),
                                                if(address.zip != "")Details('Pin Code', "${address.zip}"),
                                                if(address.mobileNo1 != "")Details('Mobile 1', "${address.mobileNo1}"),
                                                if(address.mobileNo2 != "")Details('Mobile 2', "${address.mobileNo2}"),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ) : EmptyData(),

                            model.owner.isNotEmpty ? Padding(
                              padding: const EdgeInsets.all(10).copyWith(top: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: model.owner.length,
                                      itemBuilder: (context, index) {
                                        var owner = model.owner[index];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(owner.fullName != "")Details('Name', "${owner.fullName}"),
                                                if(owner.email != "")Details('Email ID', "${owner.email}"),
                                                if(owner.mobile != "")Details('Mobile 1', "${owner.mobile}"),
                                                if(owner.mobile2 != "")Details('Mobile 2', "${owner.mobile2}"),
                                                if(owner.landline1 != "")Details('Landline 1', "${owner.landline1}"),
                                                if(owner.landline2 != "")Details('Landline 2', "${owner.landline2}"),
                                                if(owner.description != "")Details('Description', "${owner.description}"),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ) : EmptyData(),
                          ],
                        );
                      } else {
                        return EmptyData();
                      }
                    },
                  ),
                )
              ],
            ),
          );
        }
    );
  }
}
