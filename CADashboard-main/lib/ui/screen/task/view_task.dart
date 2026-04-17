import 'package:cadashboard/core/View_Model/task/task_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/task/add_task_screen.dart';
import 'package:cadashboard/ui/screen/task/sub_task.dart';
import 'package:cadashboard/ui/screen/task/task_details_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/task_card.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cadashboard/core/repository/menu_repository.dart';

import '../../../core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';

class ViewTasks extends StatefulWidget {
  const ViewTasks({super.key});

  @override
  State<ViewTasks> createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> {

  ScrollController scrollController = ScrollController();
  String? client;
  String? employee;
  String? fy;
  List search = ['All', 'Client', 'Employee', 'Financial Year'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView<TaskVM>(
      model: TaskVM(),
      onInitState: (p0) {
        p0.dropDown(context);
        scrollController.addListener(() {
          if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if(p0.task < p0.maxTask){
              appPrint("Call Pagination");
              p0.task = p0.getTask.length;
              // p0.getAllTask(context, p0.tabId[tabController.index].toString(),client,employee,FY);
              p0.getAllTask(context, p0.tabIndex.toString(),client,employee,fy);
              p0.updateUI();
            }
          }
        });
      },
      builder: (buildContext, model, child) {
        // appPrint("Task Tab Length : ${model.tabs.length}");
        return Localizations.override(
          context: buildContext,
          locale: const Locale('en'),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTabController(
              length: model.tabs.length,
              child: Scaffold(
            appBar: AppBar(
              title: Text(ApiTextLocalizer.localize('Task', locale: Localizations.localeOf(buildContext))),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    onClickSearchTask(context, model);
                  },
                ),
                if (MenuRepository.canAddTask)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(context, cusNavigate(const AddTakScreen())).then((value){
                        model.getTask.clear();
                        model.task = 0;
                        model.updateUI();
                        model.viewLoader.value = ViewState.loading;
                        model.taskLoader.value = ViewState.loading;
                        model.getTaskList(context,null,null,null);
                      });
                    },
                  ),
                const SizedBox(width: 10,),
              ],
            ),

            body: ValueListenableBuilder(
              valueListenable: model.viewLoader,
              builder: (context, value, child) {
                if(value == ViewState.loading){
                  return CommonLoader();
                }
                else if (value == ViewState.success) {
                  // tabController.length = model.tabId.length;
                  return Column(
                    children: [

                    ///   Tabs
                    SizedBox(
                      height: 50,width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: model.tabs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: model.taskLoader.value == ViewState.loading ? null : () async {
                                model.tabIndex = model.tabId[index];
                                model.getTask.clear();
                                model.task = 0;
                                model.updateUI();
                                model.taskLoader.value = ViewState.loading;
                                model.getAllTask(context, model.tabIndex.toString(),client,employee,fy);
                                appPrint(model.tabId[index]);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: model.tabIndex == model.tabId[index] ?  AppColor.background : Colors.white,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                child: Text(
                                  ApiTextLocalizer.localize(
                                    model.tabs[index],
                                    locale: AppLocaleController.locale.value,
                                  ),
                                  style: TextStyle(color: model.tabIndex == model.tabId[index] ? Colors.white : AppColor.background ),
                                )
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    ///   View
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: model.taskLoader,
                        builder: (context, value, child) {
                          // appPrint('Length : ${model.getTask.length}');
                          // appPrint('Length : ${model.getTask.length}  :::  ${model.maxTask+1}');
                          if(value == ViewState.loading){
                            return CommonLoader();
                          } else if(value == ViewState.success) {
                            Future<void> onRefresh() async {
                              try {
                                await model.refresh(buildContext, client, employee, fy);
                              } catch (_) {}
                            }
                            if(model.getTask.length == 1){
                              return RefreshIndicator(
                                onRefresh: onRefresh,
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: EmptyData(),
                                  ),
                                ),
                              );
                            } else {
                              return RefreshIndicator(
                                onRefresh: onRefresh,
                                child: ListView.builder(
                                  controller: scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: (model.getTask.length + 1),
                                itemBuilder: (context, index) {
                                  if(model.getTask.length == index){
                                    return (model.getTask.length >= (model.maxTask+1)) ? EmptyData(emptyData: "End of list ") : CommonLoader();
                                  } else {
                                    var task = model.getTask[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 8),
                                      child: TasksCard(
                                        taskNumber: task.taskNumber,
                                        clientName: task.clientOrgId == 0 ? "Internal" : task.clientName,
                                        taskName: task.taskName,
                                        assignDate: task.addedDate,
                                        endingDate: task.endDate,
                                        priority: task.priority,
                                        employeeName: task.assignedByEmpName,
                                        assign: task.taskStatus,
                                        subTaskCount: task.subTaskCount.toString(),
                                        onTap: () {
                                          if (!MenuRepository.canUpdateTask) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.amber,
                                                behavior: SnackBarBehavior.floating,
                                                content: const Text(
                                                  "You don't have permission to update",
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            cusNavigate(
                                              TaskDetailsScreen(
                                                taskId: task.taskId.toString(),
                                                taskName: task.taskName!,
                                              ),
                                            ),
                                          ).then((value) {
                                            model.getTask.clear();
                                            model.task = 0;
                                            model.updateUI();
                                            model.taskLoader.value = ViewState.loading;
                                            model.getTaskList(context, client, employee, fy);
                                          });
                                        },
                                        subTaskTap: () {
                                          Navigator.push(context, cusNavigate(SubTasks(
                                              parentTaskID: task.taskId.toString(),
                                              taskStatus: model.taskStatus,
                                              taskType: model.taskType
                                          )));
                                        },
                                      ),
                                    );
                                  }
                                },
                                ),
                              );
                            }
                          } else{
                            return RefreshIndicator(
                              onRefresh: () async {
                                try {
                                  await model.refresh(buildContext, client, employee, fy);
                                } catch (_) {}
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: EmptyData(emptyData: model.errorMessage),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  ],
                  );
                }
                else if(value == ViewState.failed){
                  return EmptyData(emptyData: model.errorMessage);
                }
                else{
                  return EmptyData();
                }
              },
            ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onClickSearchTask(BuildContext context, TaskVM model) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              child: Container(
                height: search.length * 60,
                padding: const EdgeInsets.all(15),
                child: ListView.builder(
                  itemCount: search.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        if(index == 0){
                          onClickAll(model, context, setState);
                        } else if(index == 1){
                          onClickClient(context, model);
                        } else if(index == 2){
                          onClickEmployee(context, model);
                        } else if(index == 3){
                          onClickFinancialYear(context, model);
                        }
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(search[index],style: const TextStyle(fontSize: 18)),
                          ),
                          const Divider(height: 10,)
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onClickAll(TaskVM model, BuildContext context, StateSetter setState) {
    appPrint('All');
    model.searchAll(context);
    setState((){
      client = null;
      employee = null;
      fy = null;
    });
    Navigator.pop(context);
  }


  void onClickClient(BuildContext context, TaskVM model) {

    List<ClientListElement> searchClientList = model.clientList;
    TextEditingController controller = TextEditingController();
    appPrint('Client : ${searchClientList.length}');

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) {
              appPrint("Model : ${model.clientList.length}");
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller,
                      hintLocales: AppLocaleController.inputHintLocales(context),
                      decoration: InputDecoration(
                        hintText: ApiTextLocalizer.localize('3 character required by Search', locale: Localizations.localeOf(context)),
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
                      onChanged: (value) async {
                        if(value.length > 2){
                          if(value.isEmpty){
                            Future.delayed(const Duration(milliseconds: 300),() {
                              searchClientList = model.clientList;
                              setState(() {});
                            });
                          } else {
                            final data = model.clientList;
                            List<ClientListElement> tempClient = [];
                            appPrint("Length : ${data.length}");
                            for (var element in data) {
                              if(element.displayName != null && element.displayName!.contains(value)){
                                tempClient.add(element);
                                appPrint("Length 2 : ${tempClient.length}");
                              }
                            }
                            searchClientList = tempClient;
                            setState(() {});
                          }
                        }else{
                          searchClientList = model.clientList;
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: searchClientList.isEmpty
                          ? Center(child: Text(ApiTextLocalizer.localize('No Client Found', locale: Localizations.localeOf(context))))
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchClientList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState((){
                                client = searchClientList[index].displayValue.toString();
                              });
                              model.searchClient(context, client, employee, fy);
                              Navigator.pop(context);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    ApiTextLocalizer.localize(searchClientList[index].displayName ?? "null", locale: Localizations.localeOf(context)),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const Divider(height: 10,)
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((value) => Navigator.pop(context));
  }

  void onClickEmployee(BuildContext context, TaskVM model) {
    appPrint('Employee');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.builder(
                  itemCount: model.employeeList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        appPrint('Employee ----> ${model.employeeList[index].displayValue}');
                        setState((){
                          employee = model.employeeList[index].displayValue.toString();
                        });
                        model.searchClient(context, client, employee, fy);
                        // model.searchEmployee(context, employee!);
                        Navigator.pop(context);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(model.employeeList[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                          ),
                          const Divider(height: 10,)
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    ).then((value) => Navigator.pop(context));
  }

  void onClickFinancialYear(BuildContext context, TaskVM model) {
    appPrint('Financial Year');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.builder(
                  itemCount: model.fyList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        appPrint('Financial Year ----> ${model.fyList[index].displayValue}');
                        setState((){
                          fy = model.fyList[index].displayValue.toString();
                        });
                        model.searchClient(context, client, employee, fy);
                        Navigator.pop(context);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(model.fyList[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                          ),
                          const Divider(height: 10,)
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    ).then((value) => Navigator.pop(context));
  }

}
