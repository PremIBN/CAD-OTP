// ignore_for_file: use_build_context_synchronously

import 'package:cadashboard/core/View_Model/client/view_client_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/client/add_client_screen.dart';
import 'package:cadashboard/ui/screen/client/client_details_screen.dart';
import 'package:cadashboard/ui/widget/cilent_card.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cadashboard/core/repository/menu_repository.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';

class ViewClient extends StatefulWidget {
  const ViewClient({super.key});

  @override
  State<ViewClient> createState() => _ViewClientState();
}

class _ViewClientState extends State<ViewClient> {

  ScrollController scrollController = ScrollController();

  bool isSearch = false;

  @override
  Widget build(BuildContext viewClientContext) {
    return StatelessBaseView(
      model: ViewClientVM(),
      onInitState: (p0) {
        p0.checkToken(viewClientContext);
        scrollController.addListener(() {
          if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
            if(p0.maxPage != p0.client.length){
              p0.startPage = (p0.client.length+1);
              p0.updateUI();
              p0.checkToken(viewClientContext);
            }
          }
        });
      },
      builder: (buildContext, model, child) {
        return Localizations.override(
          context: buildContext,
          locale: const Locale('en'),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
            appBar: AppBar(
              title: Text(ApiTextLocalizer.localize('Client', locale: Localizations.localeOf(buildContext))),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    model.search ? model.search = false : model.search = true;
                    model.updateUI();
                    isSearch = true;
                  },
                ),
                if (MenuRepository.canAddClient)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(viewClientContext, cusNavigate(const AddClientScreen())).then((value) {
                        model.viewLoader.value = ViewState.loading;
                        model.client.clear();
                        model.search = false;
                        model.startPage = 0;
                        model.updateUI();
                        model.checkToken(viewClientContext);
                      });
                    },
                  ),
                const SizedBox(width: 10,),
              ],
            ),
            body: Column(
              children: [
                model.search ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                  child: TextFormField(
                    controller: model.searchController,
                    hintLocales: AppLocaleController.inputHintLocales(buildContext),
                    decoration: InputDecoration(
                      hintText: '3 character required by Search',
                      contentPadding: const EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(width: 1.5)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(width: 1.5)
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(CupertinoIcons.search),
                      ),
                      prefixIconConstraints: const BoxConstraints.tightForFinite(),
                    ),
                    onChanged: (value) async{
                      if(model.searchController.text.length > 2){
                        model.client.clear();
                        model.startPage = 0;
                        model.updateUI();
                        model.viewLoader.value = ViewState.loading;
                        await model.getAllClient(viewClientContext, value, "0");
                      }
                      if(model.searchController.text.isEmpty){
                        model.client.clear();
                        model.startPage = 0;
                        model.updateUI();
                        model.viewLoader.value = ViewState.loading;
                        await model.getAllClient(viewClientContext,"", null);
                      }

                    },
                  ),
                ) : const SizedBox(),
                ValueListenableBuilder(
                  valueListenable: model.viewLoader,
                  builder: (context, value, child) {
                    if(value == ViewState.loading){
                      FocusScope.of(context).unfocus();
                      return Padding(
                        padding:  EdgeInsets.symmetric(vertical: model.search ? 0 : MediaQuery.of(context).size.height / 2.5),
                        child: CommonLoader(),
                      );
                    } else if(value == ViewState.success){
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            try {
                              await model.refresh(buildContext);
                            } catch (_) {}
                          },
                          child: ListView.builder(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: (model.client.length+1),
                          itemBuilder: (context, index) {
                            if(model.maxPage <= index) {
                              return Padding(
                                padding: EdgeInsets.only(top: model.client.isEmpty ? MediaQuery.of(context).size.height / 2.5 : 0),
                                child: EmptyData(emptyData: 'No more client'),
                              );
                            } else {
                              if(index == model.client.length){
                                FocusScope.of(context).unfocus();
                                return CommonLoader();
                              } else {
                                var client = model.client[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 5),
                                  child: ClientCard(
                                    orgname: client.orgName,
                                    clientname: client.fullName,
                                    email: client.email,
                                    mobile: client.primaryMobile,
                                    mobile2: client.mobile,
                                    pan: client.panNumber,
                                    fileNumber: client.fileNumber,
                                    branchName: client.branchName,
                                    clientType: client.clientType,
                                    groupName: client.groupName,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      // Respect backend "Update" permission for Client.
                                      // When disabled, block navigation and show a clear message.
                                      if (!MenuRepository.canUpdateClient) {
                                        ScaffoldMessenger.of(viewClientContext).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.amber,
                                            behavior: SnackBarBehavior.floating,
                                            content: const Text(
                                              'You do not have permission to edit',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        cusNavigate(ClientDetails(
                                          orgID: client.orgId.toString(),
                                          branchName: client.branchName,
                                          clientType: client.clientType,
                                          currenyName: client.currency,
                                          groupName: client.groupName,
                                        )),
                                      ).then((value) {
                                        FocusScope.of(context).unfocus();
                                        model.viewLoader.value = ViewState.loading;
                                        model.client.clear();
                                        model.search = false;
                                        model.startPage = 0;
                                        model.updateUI();
                                        model.checkToken(viewClientContext);
                                      });
                                    },
                                  ),
                                );
                              }
                            }
                          },
                          ),
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          try {
                            await model.refresh(buildContext);
                          } catch (_) {}
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: EmptyData(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            /*bottomNavigationBar: Container(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 1,color: Colors.black38,),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, CusNavigate(ViewTasks()));
                        },
                        child: Column(
                          children: [
                            Image.asset(AppImages.task,width: 25,height: 25),
                            Text(
                              ApiTextLocalizer.localize('Task', locale: Localizations.localeOf(buildContext)),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset(AppImages.document,width: 25,height: 25),
                          Text(
                            ApiTextLocalizer.localize('Document', locale: Localizations.localeOf(buildContext)),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(AppImages.expense,width: 23,height: 21),
                          Text(
                            ApiTextLocalizer.localize('Expense', locale: Localizations.localeOf(buildContext)),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(AppImages.advance, color: Colors.grey, width: 30,height: 25),
                          Text(
                            ApiTextLocalizer.localize('Advance', locale: Localizations.localeOf(buildContext)),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            )*/

            ),
          ),
        );
      },
    );
  }
}