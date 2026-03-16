import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/task/GetAllOrgTasks_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/material.dart';

class SubTaskVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  List<GetAllOrgTasksModel> subTask = [];

  int maxTask = 0;
  int task = 0;



  Future<void> getAllTask(BuildContext context, String parentTaskID, String taskStatus, String taskType) async {
    taskRepo.gettask(
      start: task.toString(),
      parentTaskID: parentTaskID,
      statusid: taskStatus,
      tasktypeid: taskType,
      success: (response) {

        if(subTask.isNotEmpty){
          subTask.addAll(response);
        } else {
          subTask = response;
          maxTask = response.last.taskId;
        }

        notifyListeners();
        appPrint("---Sub Task Length---> ${subTask.length}");
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        appPrint('Get Task  -----> $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }


}