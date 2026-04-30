import 'dart:developer';

import 'package:cadashboard/core/View_Model/task/add_task_vm.dart';
import 'package:cadashboard/core/View_Model/task/task_details_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/task/add_task_screen.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_dropdown.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/speech_to_text.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/repository/menu_repository.dart';

class TaskDetailsScreen extends StatefulWidget {

  final bool? isSubtask;
  final String taskId;
  final String taskName;
  final DateTime? pStartDate;
  final DateTime? pEndDate;
  const TaskDetailsScreen({super.key, required this.taskId, required this.taskName, this.isSubtask = false, this.pStartDate, this.pEndDate});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> with SingleTickerProviderStateMixin{

  AddTaskVM addTaskVM = AddTaskVM();

  final noteFormKey = GlobalKey<FormState>();
  final effortFormKey = GlobalKey<FormState>();

  late TabController tabController;

  ValueNotifier<bool> isAddNote = ValueNotifier(false);
  ValueNotifier<bool> isAddEffort = ValueNotifier(false);

  TextEditingController addTaskNote = TextEditingController();
  List<String?> billable = ['No','Yes'];
  List<String?> tabName = ['Info','Notes','Efforts','Logs'];

  List<TaskStatusList> taskStatusList = [];

  @override
  void initState() {
    super.initState();
    getTaskStatusList();
  }

  getTaskStatusList() async {
    await addTaskVM.getSpecificTask(context, widget.taskId);
    appPrint("Task List 1 : ${addTaskVM.taskStatusList}");
  }

  Widget divider() {
    return const SizedBox(height: 10);
  }
  Widget text(String txt){
    return Builder(
      builder: (context) {
        return Text(
          ApiTextLocalizer.localize(txt, locale: Localizations.localeOf(context)),
          style: const TextStyle(fontWeight: FontWeight.w800,fontSize: 15),
        );
      },
    );
  }



  @override
  Widget build(BuildContext detailTaskContext) {
    final locale = Localizations.localeOf(detailTaskContext);
    // Build-time guard: if backend has disabled Task "Update", never show the
    // update form — show permission message so UI directly reflects API.
    if (!MenuRepository.canUpdateTask && widget.isSubtask != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (detailTaskContext.mounted) {
          ScaffoldMessenger.of(detailTaskContext).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              behavior: SnackBarBehavior.floating,
              content: Text(
                ApiTextLocalizer.localize("You don't have permission to update", locale: locale),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
          Navigator.of(detailTaskContext).pop();
        }
      });
      return Scaffold(
        appBar: AppBar(
          title: Text(ApiTextLocalizer.localize('Update Task', locale: locale)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(detailTaskContext).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 56, color: Colors.amber[700]),
                const SizedBox(height: 20),
                Text(
                  ApiTextLocalizer.localize("You don't have permission to update", locale: locale),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(detailTaskContext).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text(
                    ApiTextLocalizer.localize('Go back', locale: locale),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StatelessBaseView(
      model:TaskDetailsVM() ,
      onInitState: (p0) {
        appPrint("Task ID :- ${widget.taskId}");
        tabController = TabController(length: tabName.length, vsync: this);
        p0.getSpecificTask(detailTaskContext, widget.taskId);
        p0.getRestrictTillDays();
        if(widget.isSubtask == true){
          p0.startDate = widget.pStartDate;
          p0.endDate = widget.pEndDate;
          p0.updateUI();
        }
        isAddNote.addListener(() {
          appPrint("isAddNote : ${isAddNote.value}");
          if(isAddNote.value == true){
            addNoteDialog(detailTaskContext, p0, detailTaskContext);
          }
        });
        isAddEffort.addListener(() {
          appPrint("isAddEffort : ${isAddEffort.value}");
          if(isAddEffort.value == true){
            addEffortDialog(p0, detailTaskContext, detailTaskContext);
          }
        });
      },
      builder: (buildContext, model, child) {
        return Scaffold(
          appBar: AppBar(
            // title: Text(widget.taskName),
            title: Text(
              ApiTextLocalizer.localize(
                widget.isSubtask == true ? 'Update Sub Task' : 'Update Task',
                locale: Localizations.localeOf(buildContext),
              ),
            ),
            actions: [
              if(widget.isSubtask == false)IconButton(
                icon: const Icon(CupertinoIcons.add),
                onPressed: () {
                  Navigator.pushReplacement(detailTaskContext, cusNavigate(AddTakScreen(
                    subTask: true,
                    parentID: widget.taskId,
                    service: model.task.serviceId,
                    clientId: model.task.clientOrgId,
                    clientName: model.task.clientName!,
                    fy: model.task.financialYearId,
                    pStartDate: model.task.startDate,
                    pEndDate: model.task.endDate,
                  )));
                },
              ),

              IconButton(
                icon: const Icon(CupertinoIcons.mic_fill),
                onPressed: () async {
                  addTaskNote.clear();
                  await speechToTextDialog(buildContext, model, detailTaskContext);
                },
              ),
              const SizedBox(width: 10,)
            ],
          ),
          body: DefaultTabController(
            length: tabName.length,
            child: Column(
              children: [

                TabBar(
                  tabs: tabName
                      .map((e) => Tab(text: ApiTextLocalizer.localize(e ?? '', locale: Localizations.localeOf(buildContext))))
                      .toList(),
                ),

                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: model.viewLoader,
                    builder: (context, value, child) {
                      if(value == ViewState.loading){
                        return CommonLoader();
                      } else if (value == ViewState.success){
                        return TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [

                            /// taskInfo
                            widget.isSubtask == false
                                ? AddTakScreen(updateTask: true, parentID: widget.taskId)
                                : AddTakScreen(
                                    subTask: true,
                                    updateTask: true,
                                    updateSubTask: true,
                                    taskID: model.task.taskId.toString(),
                                    parentID: widget.taskId,
                                    service: model.task.serviceId,
                                    clientId: model.task.clientOrgId,
                                    clientName: model.task.clientName!,
                                    fy: model.task.financialYearId,
                                    pStartDate: model.startDate,
                                    pEndDate: model.endDate,
                                  ),

                            /// taskNotes
                            Stack(
                              children: [
                                model.task.taskNotes.isEmpty ? EmptyData() : ListView.builder(
                                  itemCount: model.task.taskNotes.length,
                                  itemBuilder: (context, index) {
                                    var taskNote = model.task.taskNotes[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                  alignment: FractionalOffset.centerRight,
                                                  child: Text(DateFormat('dd-MMM-yyyy hh:mm a').format(taskNote.addedDate!))
                                              ),
                                              const SizedBox(height: 3,),
                                              const Text('Employee Name,',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text(taskNote.addedBy ?? ""),
                                              const SizedBox(height: 5,),
                                              const Text('Note,',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text(taskNote.notes ?? ""),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Card(
                                    elevation: 3,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        addTaskNote.clear();
                                        addNoteDialog(context, model, detailTaskContext);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Icon(CupertinoIcons.add),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            /// taskEfforts
                            Stack(
                              children: [
                                model.task.taskEfforts.isEmpty ? EmptyData() : ListView.builder(
                                  itemCount: model.task.taskEfforts.length,
                                  itemBuilder: (context, index) {
                                    var taskEfforts = model.task.taskEfforts[index];
                                    String actualEffortsHRs = taskEfforts.actualEffortsHRs.toString().length == 1 ? "0${taskEfforts.actualEffortsHRs}" : "${taskEfforts.actualEffortsHRs}";
                                    String actualEffortsMins = taskEfforts.actualEffortsMins.toString().length == 1 ? "0${taskEfforts.actualEffortsMins}" : "${taskEfforts.actualEffortsMins}";
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Effort note,",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text(taskEfforts.notes ?? ""),
                                              const SizedBox(height: 7,),
                                              const Text("Employee name,",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text(taskEfforts.fullName ?? ""),
                                              const SizedBox(height: 7,),
                                              const Text("Actual effort,",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text("$actualEffortsHRs : $actualEffortsMins"),
                                              // Text(DateFormat('hh : mm').format(DateTime(0,0,0,0,taskEfforts.actualEffortsMins,00))),
                                              const SizedBox(height: 7,),
                                              const Text("Effort date,",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                              Text(DateFormat('dd-MMM-yyyy').format(taskEfforts.effortDate!)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                ),

                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Card(
                                    elevation: 3,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        model.effortDate = null;
                                        model.addTaskEffort.text = "";
                                        model.effortHours.text = "";
                                        model.effortMinute.text = "";
                                        model.effortDateController.clear();
                                        addEffortDialog(model, detailTaskContext, context);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Icon(CupertinoIcons.add),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            /// taskLogs
                            model.task.taskLogs.isEmpty ? EmptyData() : ListView.builder(
                              itemCount: model.task.taskLogs.length,
                              itemBuilder: (context, index) {
                                var taskLog = model.task.taskLogs[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Align(
                                              alignment: FractionalOffset.centerRight,
                                              child: Text(DateFormat('dd-MMM-yyyy hh:mm a').format(taskLog.addedDate!))
                                          ),
                                          Html(
                                            data: taskLog.description,
                                            style: {"b" :Style(fontWeight: FontWeight.w900,)},
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        );
                      } else {
                        return EmptyData(emptyData: model.errorMessage);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> speechToTextDialog(BuildContext buildContext, TaskDetailsVM model, BuildContext detailTaskContext) async {
    await showDialogForListen(context: buildContext, onListing: (speech) async {
      if (speech.isEmpty) {
        CommonFunction.showSnackBar(context: context, isError: true, message: "Your voice is too low. Please try again.");
      } else{

        /*addTaskVM.taskStatusList.forEach((element) {
        appPrint("aa : ${element.displayValue} :: ${element.displayName}");
      });*/

        String lowerSpeech = speech.toLowerCase();
        List<String> statusKeywords = [
          "mark status", "mark", "status", "change task status",
          "change status", "task status", "change", "task", "status"
        ];
        List<String> statusList = [
          "assigned", "closed", "completed", "invoiced", "need approval",
          "pending for review", "pending from client", "work in progress"
        ];

        bool containsStatusKeyword = statusKeywords.any((word) => lowerSpeech.contains(word));
        bool containsStatus = statusList.any((status) => lowerSpeech.contains(status));

        appPrint("Speech to Text :  $lowerSpeech");

        if (lowerSpeech.startsWith("add note") || lowerSpeech.startsWith("ed note ")
            || lowerSpeech.startsWith("add not ") || lowerSpeech.startsWith("ed not ")) {

          listenAddNoteFunction(lowerSpeech, buildContext, model, detailTaskContext);

        } else if (lowerSpeech.startsWith("add effort") || lowerSpeech.startsWith("ed effort") || lowerSpeech.startsWith("ad effort")
            || lowerSpeech.startsWith("add efforts") || lowerSpeech.startsWith("ed efforts") || lowerSpeech.startsWith("ad efforts")) {

          listenAddEffortFunction(lowerSpeech, buildContext, model, detailTaskContext);

        } else if (containsStatusKeyword && containsStatus) {
          String matchedStatus = statusList.firstWhere((status) => lowerSpeech.contains(status), orElse: () => "");
          if (matchedStatus.isNotEmpty) {
            taskStatusChangeFunction(matchedStatus, lowerSpeech, model);
          }
          isAddNote.value = false;
          isAddEffort.value = false;
        } else {
          // If speech does not match any predefined format
          isAddNote.value = false;
          isAddEffort.value = false;
          CommonFunction.showSnackBar(context: context, isError: true, message: "Command not recognized. Please try again.");
        }
      }
    });
  }

  void taskStatusChangeFunction(String matchedStatus, String lowerSpeech, TaskDetailsVM model) {
     var selectedStatus = addTaskVM.taskStatusList.firstWhere((element) {
      return element.displayName!.toLowerCase().contains(matchedStatus);
    });

    log(name: "Status 1", selectedStatus.toString());

    if (selectedStatus != null) {
      log(name: "Status 2", "${selectedStatus.displayName} ::: ${selectedStatus.displayValue} ::: $lowerSpeech");
      CommonFunction.showSnackBar(context: context, isError: false, message: "Status has been changed successfully to ${selectedStatus.displayName}");
      updateTask(context: context, addTaskVm: addTaskVM, taskDetailVm: model, status: selectedStatus.displayValue);
    } else {
      log(name: "Status 3", "${selectedStatus.displayName} ::: ${selectedStatus.displayValue} ::: $lowerSpeech");
      CommonFunction.showSnackBar(context: context, isError: true, message: "Status not found. Please try again.");
    }
  }

  void listenAddNoteFunction(String lowerSpeech, BuildContext buildContext, TaskDetailsVM model, BuildContext detailTaskContext) {
    if(lowerSpeech.startsWith("add note ")){
      addTaskNote.text = lowerSpeech.replaceRange(0, 9, "").trim().capitalize();
    } else if(lowerSpeech.startsWith("ed note ") || lowerSpeech.startsWith("add not ")){
      addTaskNote.text = lowerSpeech.replaceRange(0, 8, "").trim().capitalize();
    } else if(lowerSpeech.startsWith("ed not ")){
      addTaskNote.text = lowerSpeech.replaceRange(0, 7, "").trim().capitalize();
    }

    appPrint("Add Note : $lowerSpeech");
    Navigator.pop(context);
    isAddNote.value = true;
    // model.speechToAddNote(detailTaskContext, widget.taskId, lowerSpeech.replaceAll('add note', ""));
    addNoteDialog(buildContext, model, detailTaskContext);
  }

  String cleanDateString(String dateStr) {
    // Remove ordinal suffixes like "st", "nd", "rd", "th"
    return dateStr.replaceAll(RegExp(r'(st|nd|rd|th)'), '');
  }

  Future<void> listenAddEffortFunction(String lowerSpeech, BuildContext buildContext, TaskDetailsVM model, BuildContext detailTaskContext) async {

    model.effortDate = null;
    model.addTaskEffort.text = "";
    model.effortHours.text = "";
    model.effortMinute.text = "";

    //Add effort on 20th Feb 2025 for 2 hours 20 minutes Completed review
    appPrint("Speech Text : $lowerSpeech");

    final dateRegex = RegExp(r'(\d{1,2}(st|nd|rd|th)? (January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))');
    final timeRegex = RegExp(r'(\d+ (hour|hours))|(\d+ (minute|minutes))');

    // Parse date
    final dateMatch = dateRegex.firstMatch(lowerSpeech);
    DateTime? parsedDate;
    if (dateMatch != null) {
      String dateStr = dateMatch.group(0) ?? "";
      dateStr = cleanDateString(dateStr); // Clean the string
      parsedDate = DateFormat("d MMM").parse(dateStr); // Parse the cleaned string
      parsedDate = DateTime(DateTime.now().year, parsedDate.month, parsedDate.day);
    }else{
      CommonFunction.showSnackBar(context: context, isError: true, message: "Date format are not match");
    }

    // Parse time (hours and minutes)
    int? hours = 0;
    int? minutes = 0;
    for (var match in timeRegex.allMatches(lowerSpeech)) {
      if (match.group(2)?.contains("hour") ?? false) {
        hours = int.parse(match.group(1)?.split(' ')[0] ?? '0');
      } else if (match.group(4)?.contains("minute") ?? false) {
        minutes = int.parse(match.group(3)?.split(' ')[0] ?? '0');
      }
    }

    appPrint("Effort Date : $parsedDate");
    appPrint("Effort Time : $hours : $minutes");

    if(dateMatch != null && parsedDate == null){
      CommonFunction.showSnackBar(context: context, isError: true, message: "Please speck date as well format");
    } else{
      model.effortDate = parsedDate;
      model.effortDateController.text = DateFormat('dd-MMM-yyyy').format(model.effortDate!);
      model.updateUI();
    }

    if(hours == null){
      CommonFunction.showSnackBar(context: context, isError: true, message: "Please speck hours as well format");
    } else {
      model.effortHours.text = hours.toString();
    }

    if(minutes == null){
      CommonFunction.showSnackBar(context: context, isError: true, message: "Please speck minute as well format");
    } else {
      model.effortMinute.text = minutes.toString();
    }

    if(lowerSpeech.split('description').length >= 2){
      List effortsNote = lowerSpeech.split('description');
      effortsNote.removeAt(0);
      // model.addTaskEffort.text = effortsNote.join(',');
    }

    if(parsedDate != null && hours != null && minutes != null){
      Navigator.pop(context);
      isAddEffort.value = true;
      addEffortDialog(model, detailTaskContext, buildContext);
    }

  }

  void addNoteDialog(BuildContext context, TaskDetailsVM model, BuildContext detailTaskContext) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Task Note'),
                    IconButton(
                      icon: const Icon(CupertinoIcons.mic_fill),
                      onPressed: () {
                        showDialogForListen(context: context, onListing: (speech) {
                          setState(() {
                            addTaskNote.text += " $speech";
                          });
                        });
                      },
                    ),
                  ],
                ),
                content: Form(
                  key: noteFormKey,
                  child: TextFormField(
                    hintLocales: AppLocaleController.inputHintLocales(context),
                    controller: addTaskNote,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter Note',
                      contentPadding: const EdgeInsets.all(10),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      enabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      errorBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.red)
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.red)
                      ),
                    ),
                    onSaved: (newValue) { },
                    validator: (value) {
                      if(value == null || value == ""){
                        return 'Please Enter Some Note.';
                      }else{
                        return null;
                      }
                    },
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: model.btnLoader,
                          builder: (context, value, child) {
                            return CusBtn(
                              btnName: 'Submit',
                              localizeText: false,
                              loading: value,
                              onTap: () {
                                model.btnLoader.value = true;
                                if(noteFormKey.currentState!.validate()){
                                  isAddNote.value = false;
                                  model.addNote(detailTaskContext, widget.taskId, addTaskNote.text);
                                }else{
                                  model.btnLoader.value = false;
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: CusBtn(
                          btnName: 'Cancel',
                          localizeText: false,
                          btnColor: true,
                          onTap: () {
                            isAddNote.value = false;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  )
                ],

              );
            }
          ),
        );
      },
    ).then((value) {
      isAddNote.value = false;
    });
  }

  void addEffortDialog(TaskDetailsVM model, BuildContext detailTaskContext, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (aContext, setState) {
              return AlertDialog(
                title: const Text('Add Actual Efforts'),
                content: Form(
                  key: effortFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextFormField(
                                hintLocales: AppLocaleController.inputHintLocales(context),
                                controller: model.effortHours,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: 'Hours',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(8),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  enabledBorder:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  errorBorder:OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),

                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(color: Colors.red)
                                  ),
                                ),
                                onSaved: (newValue) {},
                                validator: (value) {
                                  if(value==""){
                                    return 'Enter Hours';
                                  }else{
                                    return null;
                                  }
                                  // value==null ||  value.isEmpty ? "Enter Hours" : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                hintLocales: AppLocaleController.inputHintLocales(context),
                                controller: model.effortMinute,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: 'Minutes',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(8),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  enabledBorder:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  errorBorder:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                ),
                                onSaved: (newValue) {},
                                validator: (value) {
                                  if(value==""){
                                    return 'Enter Minute';
                                  }else{
                                    return null;
                                  }
                                  // value == null||value.isEmpty ? "Enter Minute" : "null";
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10,),

                        TextFormField(
                          hintLocales: AppLocaleController.inputHintLocales(context),
                          controller: model.effortDateController,
                          decoration: InputDecoration(
                            hintText: 'Effort Date',
                            contentPadding:  const EdgeInsets.all(15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            suffixIcon: const Icon(CupertinoIcons.right_chevron,color: Colors.black54),
                          ),
                          readOnly: true,
                          onTap: () async {

                            await model.getRestrictTillDays();
                            int? firstDate = model.restrictTillDays;
                            appPrint("Date : $firstDate");

                            model.effortDate = await showDatePicker(
                              context: context,
                              locale: const Locale('en'),
                              initialDate: DateTime.now(),
                              firstDate: firstDate == null ? DateTime(DateTime.now().year - 1) : DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().day - firstDate)),
                              lastDate: DateTime.now(),
                            );
                            if(model.effortDate != null){
                              model.effortDateController.text = DateFormat('dd-MMM-yyyy').format(model.effortDate!);
                            }
                            model.updateUI();
                          },
                          onSaved: (newValue) {},
                          validator: (value) {
                            int? firstDate = model.restrictTillDays;
                            return value?.isEmpty ?? true
                              ? 'Please select effort date'
                              : firstDate != null && !(firstDate <= (DateTime.now().day - (model.effortDate?.day ?? 0)))
                                ? 'Effort date restricted by $firstDate day'
                                : null;
                          },
                        ),

                        /*InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async{
                            if(model.startDate != null){
                              model.effortDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(model.startDate!.year - 1),
                                lastDate: DateTime.now(),
                              );
                            } else{
                              CommonFunction.showSnackBar(context: context, isError: true, message: 'First select start date');
                            }
                            setState(() {});
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(width: 1)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(model.effortDate == null
                                    ? 'Effort Date'
                                    : DateFormat('dd-MMM-yyyy').format(model.effortDate!)
                                ),
                                const Spacer(),
                                const Icon(CupertinoIcons.right_chevron)
                              ],
                            ),
                          ),
                        ),*/

                        const SizedBox(height: 10,),
                        TextFormField(
                          hintLocales: AppLocaleController.inputHintLocales(context),
                          controller: model.addTaskEffort,
                          decoration: InputDecoration(
                            hintText: 'Effort Note',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(8),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            errorBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                          ),
                          onSaved: (newValue) {},
                          validator: (value) {
                            if(value==""){
                              return 'Enter Note';
                            }else{
                              return null;
                            }
                            // value==null || value.isEmpty || value == "" ? "Enter Effort Note" : null;
                          },
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CusDropDown(
                                label: 'Approved',
                                hint: 'select approved',
                                dropDownValue: billable[model.isApproved],
                                radius: 15,
                                items: billable.map((e) {
                                  return DropdownMenuItem(value: e, child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e ?? ""),
                                      const Divider(height: 10,),
                                    ],
                                  ));
                                }).toList(),
                                onChanged: (value) {
                                  value == 'No' ? model.isApproved = 0 : model.isApproved = 1;
                                  model.updateUI();
                                },
                                selectedItemBuilder: (context) {
                                  return billable.map((e){
                                    return Text(e ?? "null");
                                  }).toList();
                                },
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: CusDropDown(
                                label: 'Billable',
                                hint: 'select billable',
                                dropDownValue: billable[model.isBillable],
                                radius: 15,
                                items: billable.map((e) {
                                  return DropdownMenuItem(value: e, child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e ?? ""),
                                      const Divider(height: 10,),
                                    ],
                                  ));
                                }).toList(),
                                onChanged: (value) {
                                  value == 'No' ? model.isBillable = 0 : model.isBillable = 1;
                                  model.updateUI();
                                },
                                selectedItemBuilder: (context) {
                                  return billable.map((e){
                                    return Text(e!);
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: model.btnLoader,
                          builder: (context, value, child) {
                            return CusBtn(
                              btnName: 'Submit',
                              localizeText: false,
                              loading: value,
                              onTap: () async {
                                isAddEffort.value = false;
                                model.btnLoader.value = true;
                                if(effortFormKey.currentState?.validate() ?? false){
                                  if(model.effortDate != null /*&& model.isBillable != null && model.isApproved != null*/) {
                                    model.addEffort(
                                      detailTaskContext,
                                      widget.taskId,
                                      model.effortHours.text,
                                      model.effortMinute.text,
                                      model.effortDate.toString(),
                                      model.addTaskEffort.text,
                                      model.isBillable.toString(),
                                      model.isApproved.toString()
                                    );
                                  } else if(model.effortDate == null) {
                                    CommonFunction.showSnackBar(context: aContext, isError: true, message: 'Please Select Effort Date');
                                  }/* else if(model.isApproved == null) {
                                    CommonFunction.showSnackBar(context: Acontext, isError: true, message: 'Please Select Approved');
                                  } else if(model.isBillable == null){
                                    CommonFunction.showSnackBar(context: Acontext, isError: true, message: 'Please Select Billable');
                                  }*/
                                } else {
                                  appPrint("No");
                                  model.btnLoader.value = false;
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: CusBtn(
                          btnName: 'Cancel',
                          localizeText: false,
                          btnColor: true,
                          onTap: () {
                            isAddEffort.value = false;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((value) => isAddEffort.value = false);
  }

  updateTask({required BuildContext context, required AddTaskVM addTaskVm, required TaskDetailsVM taskDetailVm, required int status}){
    taskDetailVm.viewLoader.value = ViewState.loading;
    if(widget.isSubtask == true && addTaskVm.task.taskId != null){
      appPrint('==========> Update Sub Task');
      // log('''==========> Update Sub Task ::: ${addTaskVm.task.taskId.toString()}, ${widget.taskId}, ${addTaskVm.service!.toString()}, ${status.toString()}, ${addTaskVm.assToID!},
      //     ${addTaskVm.client.toString()}, ${addTaskVm.taskNameController.text}, ${addTaskVm.taskNoteController.text},
      //     ${addTaskVm.startDate!}, ${addTaskVm.endDate!}, ${addTaskVm.branch}, ${addTaskVm.department}, ${addTaskVm.priority.toString()}, ${addTaskVm.billable.toString()},
      //     ${addTaskVm.currencyController.text}, ${addTaskVm.currency!.toString()} \n ========================================================================================''');
      addTaskVm.updateSubTask(context, addTaskVm.task.taskId.toString(), widget.taskId, addTaskVm.service!.toString(), status.toString(), addTaskVm.assToID!,
          addTaskVm.client.toString(), addTaskVm.taskNameController.text, addTaskVm.taskNoteController.text,
          addTaskVm.startDate!, addTaskVm.endDate!, addTaskVm.branch, addTaskVm.department, addTaskVm.priority.toString(), addTaskVm.billable.toString(),
          addTaskVm.currencyController.text, addTaskVm.currency!.toString());
    } else {
      appPrint('==========> Update Task');
      // log('''==========> Update Task ::: ${widget.taskId} , "$status", ${addTaskVm.taskNameController.text}, ${taskDetailVm.task.startDate!},
      //     ${taskDetailVm.task.endDate!}, "${addTaskVm.priority}", "${addTaskVm.billable}", ${addTaskVm.currencyController.text}, ${addTaskVm.fy}''');
      addTaskVm.updateTask(context, widget.taskId , "$status", addTaskVm.taskNameController.text, taskDetailVm.task.startDate!,
          taskDetailVm.task.endDate!, "${addTaskVm.priority}", "${addTaskVm.billable}", addTaskVm.currencyController.text, addTaskVm.fy);
    }
    // Future.delayed(const Duration(seconds: 5),() {
    //   taskDetailVm.viewLoader.value = ViewState.success;
    //   taskDetailVm.updateUI();
    // });
    taskDetailVm.updateUI();
  }

}
