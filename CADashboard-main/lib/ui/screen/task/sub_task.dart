import 'package:cadashboard/core/View_Model/task/sub_task_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/task/task_details_screen.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/task_card.dart';
import 'package:flutter/material.dart';

class SubTasks extends StatefulWidget {
  final String parentTaskID;
  final String taskType;
  final String taskStatus;
  const SubTasks({super.key, required this.parentTaskID, required this.taskType, required this.taskStatus});

  @override
  State<SubTasks> createState() => _SubTasksState();
}

class _SubTasksState extends State<SubTasks> {

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView(
      model: SubTaskVM(),
      onInitState: (p0) {
        p0.getAllTask(context, widget.parentTaskID, widget.taskStatus, widget.parentTaskID);
        scrollController.addListener(() {
          if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if(p0.task < p0.maxTask){
              appPrint("Call Pagination");
              p0.task = p0.subTask.length;
              p0.getAllTask(context, widget.parentTaskID, widget.taskStatus, widget.parentTaskID);
              p0.updateUI();
            }
          }
        });
      },
      builder: (buildContext, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sub Tasks'),
          ),
          body: ValueListenableBuilder(
            valueListenable: model.viewLoader,
            builder: (context, value, child) {

              if(value == ViewState.loading){
                return CommonLoader();
              } else if(value == ViewState.success){
                return ListView.builder(
                  controller: scrollController,
                  itemCount: (model.subTask.length + 1),
                  itemBuilder: (context, index) {

                    if(index == model.subTask.length){
                      return (model.subTask.length >= (model.maxTask+1))  ? EmptyData(emptyData: "End of list ") : CommonLoader();
                    } else {
                      var task = model.subTask[index];
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
                          // subTaskCount: task.subTaskCount.toString(),
                          onTap: () {
                            Navigator.push(context, cusNavigate(TaskDetailsScreen(
                              taskId: task.taskId.toString(),
                              taskName: task.taskName!,
                              isSubtask: true,
                              pStartDate: task.startDate,
                              pEndDate: task.endDate,
                            ))).then((value){
                              model.subTask.clear();
                              model.updateUI();
                              model.viewLoader.value = ViewState.loading;
                              model.getAllTask(context, widget.parentTaskID, widget.taskStatus, widget.taskType);
                            });
                          },
                        ),
                      );
                    }
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
