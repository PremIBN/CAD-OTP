import 'package:cadashboard/core/View_Model/task/add_task_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/widget/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTakScreen extends StatefulWidget {

  final bool subTask;
  final bool updateSubTask;
  final bool updateTask;
  final String? parentID;
  final String? taskID;
  final int? service;
  final String? clientName;
  final int? fy;
  final int? clientId;
  final DateTime? pStartDate;
  final DateTime? pEndDate;

   const AddTakScreen({super.key, this.subTask = false, this.updateSubTask = false, this.parentID,this.updateTask = false, this.service, this.clientName, this.fy, this.pStartDate, this.pEndDate, this.clientId, this.taskID});

  @override
  State<AddTakScreen> createState() => _AddTakScreenState();
}

class _AddTakScreenState extends State<AddTakScreen> {

  List<String?> bill = ['No','Yes'];
  
  int mandate = 0;
  int showOtherDetail = 0; 

  int multipleEmployee = -1;

  final OutlineInputBorder _border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25)
  );
  final OutlineInputBorder _errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.red)
  );


  Widget cusDivider() {
    return  const SizedBox(height: 10);
  }

  getMandateNumber() async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    
    setState(() {
      mandate = pre.getInt(PreferenceHelper.mandateNumber) ?? 0;
      showOtherDetail = pre.getInt(PreferenceHelper.showOtherTaskDetails) ?? 0;
    });
  } 
  
  @override
  Widget build(BuildContext addTaskContext) {

    final formKey = GlobalKey<FormState>();

    return StatelessBaseView(
      model: AddTaskVM(),
      onInitState: (p0) {
        getMandateNumber();
        if(widget.updateTask == true && widget.parentID != null){
          p0.getSpecificTask(context, widget.parentID!);
        }else{
          p0.dropDown(addTaskContext);
        }
        if(widget.subTask == true){
          p0.service = widget.service;
          p0.client = widget.clientId;
          p0.clientController.text = widget.clientId == 0 ? "Internal" : widget.clientName!;
          p0.fy = widget.fy;
          p0.startDate = widget.pStartDate;
          p0.endDate = widget.pEndDate;
          p0.updateUI();
        }
      },
      builder: (buildContext, model, child) {
        return Scaffold(
          appBar: widget.updateTask == false && widget.updateSubTask == false ? AppBar(
            title:  Text(widget.subTask ? 'Add Sub Task' : 'Add Task'),
          ) : null,

          body: ValueListenableBuilder(
            valueListenable: model.viewLoader,
            builder: (context, value, child) {
              if(value == ViewState.loading){
                return CommonLoader();
              } else if(value == ViewState.success){
                return ValueListenableBuilder(
                  valueListenable: model.btnLoader,
                  builder: (context, value, child) {
                    return Stack(
                      children: [

                        if(model.btnLoader.value == true)Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: CommonLoader(),
                        ),

                        Container(
                          padding:  const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 5),
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  /// Task Name
                                  const Text('Task Name',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.taskNameController,
                                    decoration: InputDecoration(
                                        hintText: 'Task Name',
                                        contentPadding:  const EdgeInsets.all(15),
                                        enabledBorder: _border,
                                        errorBorder: _errorBorder,
                                        focusedErrorBorder: _errorBorder,
                                        focusedBorder: _border
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      return value!.isEmpty ? "Please enter task name" : null;
                                    },
                                  ),
                                  cusDivider(),

                                  /// Services
                                  CusDropDown(
                                    label: 'Service Type',
                                    hint: 'Select Service Type',
                                    dropDownValue: model.service == 0 ? null : model.service,
                                    items: model.serviceList.map((e) {
                                      return DropdownMenuItem(
                                          value: e.displayValue,
                                          child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: widget.subTask == true ? null : (value) {
                                      model.service = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.serviceList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null ? "Please selected service type" : null;
                                    },
                                  ),

                                  /// Status
                                  CusDropDown(
                                    label: 'Status',
                                    hint: 'Select Status',
                                    dropDownValue: model.status == 0 ? null : model.status,
                                    items: model.taskStatusList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.status = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.taskStatusList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null ? "Please selected status" : null;
                                    },
                                  ),

                                  /// Employee
                                  const Text('Assigned To',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.employeeController,
                                    decoration: InputDecoration(
                                        hintText: 'Assigned to employee',
                                        contentPadding:  const EdgeInsets.all(15),
                                        enabledBorder: _border,
                                        errorBorder: _errorBorder,
                                        focusedErrorBorder: _errorBorder,
                                        focusedBorder: _border,
                                        disabledBorder: _border,
                                      suffixIcon: const Icon(Icons.arrow_drop_down,color: Colors.black54),
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      return value!.isEmpty ? "Please assigned to employee" : null;
                                    },
                                    readOnly: true,
                                    onTap: () {
                                      showDialog(
                                        context: addTaskContext,
                                        useSafeArea: true,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {

                                              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {setState((){
                                                model.assToID = model.employeeId.map((e){
                                                  return e;
                                                }).join(',');
                                                model.employeeController.text = model.employeeName.map((e){
                                                  return e;
                                                }).join(',');
                                              });});

                                              return Dialog(
                                                child: SizedBox(
                                                  // height: MediaQuery.of(context).size.height / 2,
                                                  height: model.employeeList.length.toDouble() * 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(15.0),
                                                    child: ListView.builder(
                                                      itemCount: model.employeeList.length,
                                                      itemBuilder: (context, index) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            CheckboxListTile(
                                                              value: model.isChecked[index],
                                                              onChanged: (value) {
                                                                setState(() {

                                                                  if(model.isChecked[index] == true){
                                                                    model.isChecked[index] = false;
                                                                    model.employeeName.remove(model.employeeList[index].displayName);
                                                                    model.employeeId.remove(model.employeeList[index].displayValue.toString());
                                                                  } else {
                                                                    model.isChecked[index] = true;
                                                                    model.employeeName.add(model.employeeList[index].displayName);
                                                                    model.employeeId.add(model.employeeList[index].displayValue.toString());
                                                                  }

                                                                });
                                                              },
                                                              title: Text(model.employeeList[index].displayName!,style: const TextStyle(fontSize: 17)),
                                                            ),
                                                            const Divider(height: 10,),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ).then((value) {
                                        model.updateUI();
                                      });
                                    },
                                  ),
                                  cusDivider(),

                                  /// Assignor
                                  CusDropDown(
                                    label: 'Assignor',
                                    hint: 'Select Assignor',
                                    dropDownValue: model.assignor == 0 ? null : model.assignor,
                                    items: model.employeeList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.assignor = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.employeeList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? "Please selected assignor" : null;
                                    },*/
                                  ),

                                  /// Reviewer
                                  CusDropDown(
                                    label: 'Reviewer',
                                    hint: 'Select Reviewer',
                                    dropDownValue: model.reviewer == 0 ? null : model.reviewer,
                                    items: model.employeeList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.reviewer = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.employeeList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    /*validator: (value) {
                                      return value == null ? "Please selected reviewer" : null;
                                    },*/
                                  ),

                                  /// Client
                                  const Text('Client Name',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.clientController,
                                    style: TextStyle(color: widget.subTask == true ? Colors.grey : null),
                                    decoration: InputDecoration(
                                      hintText: 'Select Client',
                                      contentPadding:  const EdgeInsets.all(15),
                                      enabledBorder: _border,
                                      errorBorder: _errorBorder,
                                      focusedErrorBorder: _errorBorder,
                                      focusedBorder: _border,
                                      disabledBorder: _border,
                                      suffixIcon: Icon(Icons.arrow_drop_down,color: widget.subTask == true ? Colors.grey : Colors.black54),
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      return value!.isEmpty ? "Please select client" : null;
                                    },
                                    readOnly: true,
                                    onTap: widget.subTask == true ? null : () {

                                      List<ClientListElement> searchClientList = model.clientList;
                                      TextEditingController controller = TextEditingController();

                                      showModalBottomSheet(
                                        context: addTaskContext,
                                        showDragHandle: true,
                                        enableDrag: true,
                                        isDismissible: false,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        builder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  children: [

                                                    TextFormField(
                                                      controller: controller,
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
                                                      child: ListView.builder(
                                                        itemCount: searchClientList.length,
                                                        itemBuilder: (context, index) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                    model.client = searchClientList[index].displayValue;
                                                                    model.clientController.text = searchClientList[index].displayName!;
                                                                    model.updateUI();
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(5.0),
                                                                          child: Text(searchClientList[index].displayName!,style: const TextStyle(fontSize: 17)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                              ),
                                                              const Divider(height: 10,),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  cusDivider(),

                                  /// Task Note
                                  if(widget.updateTask == false)Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Task Note',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                      const SizedBox(height: 5,),
                                      TextFormField(
                                        controller: model.taskNoteController,
                                        decoration: InputDecoration(
                                            hintText: 'Task Note',
                                            contentPadding:  const EdgeInsets.all(15),
                                            enabledBorder: _border,
                                            errorBorder: _border,
                                            focusedErrorBorder: _border,
                                            focusedBorder: _border
                                        ),
                                        onSaved: (newValue) {},
                                        /*validator: (value) {
                                      return value!.isEmpty ? "Please enter note" : null;
                                    },*/
                                      ),
                                      cusDivider(),
                                    ],
                                  ),

                                  /// Start Date
                                  const Text('Start Date',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.startDateController,
                                    decoration: InputDecoration(
                                      hintText: 'Select start date',
                                      contentPadding:  const EdgeInsets.all(15),
                                      enabledBorder: _border,
                                      errorBorder: _errorBorder,
                                      focusedErrorBorder: _errorBorder,
                                      focusedBorder: _border,
                                      disabledBorder: _border,
                                      suffixIcon: const Icon(CupertinoIcons.right_chevron,color: Colors.black54),
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      return value!.isEmpty ? "Please select start date" : null;
                                    },
                                    readOnly: true,
                                    onTap: () async{
                                      var startDate = await showDatePicker(
                                          context: addTaskContext,
                                          initialDate: widget.subTask == true&&widget.pStartDate!=null ? widget.pStartDate! : DateTime.now(),
                                          firstDate: widget.subTask == true&&widget.pStartDate!=null ? widget.pStartDate! : DateTime.now(),
                                          lastDate: widget.subTask == true&&widget.pEndDate!=null ? widget.pEndDate! : DateTime(DateTime.now().year + 10)
                                      );
                                      if(startDate != null){
                                        model.startDate = startDate;
                                        model.updateUI();
                                        model.startDateController.text = DateFormat('dd-MMM-yyyy').format(startDate);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  /*
                                                                    Container(
                                    height: 50,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(width: 1)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Start Date',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                        const Spacer(),
                                        InkWell(
                                            onTap: () async{
                                              startDate = await showDatePicker(
                                                  context: addTaskContext,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(DateTime.now().year + 10)
                                              );
                                              setState(() {});
                                            },
                                            child: Text(startDate == null
                                                ? 'select start date'
                                                : DateFormat('dd-MMM-yyyy').format(startDate!)
                                            )
                                        ),
                                        const SizedBox(width: 5,),
                                        const Icon(CupertinoIcons.right_chevron)
                                      ],
                                    ),

                                   */
                                  cusDivider(),

                                  /// End Date
                                  const Text('End Date',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.endDateController,
                                    decoration: InputDecoration(
                                      hintText: 'Select end date',
                                      contentPadding:  const EdgeInsets.all(15),
                                      enabledBorder: _border,
                                      errorBorder: _errorBorder,
                                      focusedErrorBorder: _errorBorder,
                                      focusedBorder: _border,
                                      disabledBorder: _border,
                                      suffixIcon: const Icon(CupertinoIcons.right_chevron,color: Colors.black54),
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      return value!.isEmpty ? "Please select start date" : null;
                                    },
                                    readOnly: true,
                                    onTap: () async{
                                      if(model.startDate != null){
                                        var endDate = await showDatePicker(
                                          context: addTaskContext,
                                          initialDate: model.startDate!,
                                          firstDate: model.startDate!,
                                          lastDate: widget.subTask == true&&widget.pEndDate!=null ? widget.pEndDate! : DateTime(model.startDate!.year + 10),
                                        );
                                        if(endDate != null){
                                          model.endDate = endDate;
                                          model.updateUI();
                                          model.endDateController.text = DateFormat('dd-MMM-yyyy').format(endDate);
                                        }
                                      } else{
                                        CommonFunction.showSnackBar(context: addTaskContext, isError: true, message: 'First select start date');
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  /*Container(
                                    // height: 50,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(width: 1)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('End Date',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                        const Spacer(),
                                        InkWell(
                                            onTap: () async{
                                              if(startDate != null){
                                                endDate = await showDatePicker(
                                                  context: addTaskContext,
                                                  initialDate: startDate!,
                                                  firstDate: startDate!,
                                                  lastDate: DateTime(startDate!.year + 10),
                                                );
                                              } else{
                                                CommonFunction.showSnackBar(context: addTaskContext, isError: true, message: 'Firest select start date');
                                              }



                                              setState(() {});
                                            },
                                            child: Text(endDate == null
                                                ? 'select end date'
                                                : DateFormat('dd-MMM-yyyy').format(endDate!)
                                            )
                                        ),
                                        const SizedBox(width: 5,),
                                        const Icon(CupertinoIcons.right_chevron)
                                      ],
                                    ),
                                  ),*/
                                  cusDivider(),

                                  ///  Branch
                                  CusDropDown(
                                    label: 'Branch',
                                    hint: 'Select Branch',
                                    dropDownValue: model.branch == 0 ? null : model.branch,
                                    items: model.branchList.map((e) {
                                      return DropdownMenuItem(value: e.branchId, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.branchName ?? ""),
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
                                        return Text(e.branchName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      if(showOtherDetail == 1){
                                        return value == null
                                            ? "Please selected branch"
                                            : null;
                                      }else{
                                        return null;
                                      }
                                    },
                                  ),

                                  /// Department
                                  CusDropDown(
                                    label: 'Department',
                                    hint: 'Select Department',
                                    dropDownValue: model.department == 0 ? null : model.department,
                                    items: model.departmentList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.department = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.departmentList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      if(showOtherDetail == 1){
                                        return value == null
                                            ? "Please selected department"
                                            : null;
                                      }else{
                                        return null;
                                      }
                                    },
                                  ),

                                  /// Priority
                                  CusDropDown(
                                    label: 'Priority',
                                    hint: 'Select Priority',
                                    dropDownValue: model.priority == 0 ? null : model.priority,
                                    items: model.priorityList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                      model.priority = value;
                                      model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.priorityList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      // if(model.priority == null){return "Please selected priority";}else{return null;}
                                      return value == null ? "Please selected priority" : null;
                                    },
                                  ),

                                  ///  FinancialYear
                                  CusDropDown(
                                    label: 'Financial Year',
                                    hint: 'Select Financial Year',
                                    dropDownValue: model.fy == 0 ? null : model.fy,
                                    items: model.yearList.map((e) {
                                      return DropdownMenuItem(value: e.displayValue, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.displayName ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: widget.subTask == true ? null : (value) {
                                      setState(() {
                                        model.fy = value;
                                        model.updateUI();
                                      });
                                    },
                                    selectedItemBuilder: (context) {
                                      return model.yearList.map((e){
                                        return Text(e.displayName!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null ? "Please selected financial year" : null;
                                    },
                                  ),

                                  /// Mandate Number
                                  const Text('Mandate Number',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                  const SizedBox(height: 5,),
                                  TextFormField(
                                    controller: model.mandateController,
                                    decoration: InputDecoration(
                                        hintText: 'Mandate Number',
                                        contentPadding:  const EdgeInsets.all(15),
                                        enabledBorder: _border,
                                        errorBorder: _errorBorder,
                                        focusedErrorBorder: _errorBorder,
                                        focusedBorder: _border
                                    ),
                                    onSaved: (newValue) {},
                                    validator: (value) {
                                      if(mandate == 1) {
                                        return value!.isEmpty ? "Please enter mandate number" : null;
                                      }else{
                                        return null;
                                      }
                                    },
                                  ),
                                  cusDivider(),

                                  ///  Billable
                                  CusDropDown(
                                    label: 'Billable',
                                    hint: 'Select Billable',
                                    dropDownValue: bill[model.billable],
                                    items: bill.map((e) {
                                      return DropdownMenuItem(value: e, child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e ?? ""),
                                          const Divider(height: 10,),
                                        ],
                                      ));
                                    }).toList(),
                                    onChanged: (value) {
                                        value == "No" ? model.billable = 0 : model.billable = 1;
                                        model.updateUI();
                                    },
                                    selectedItemBuilder: (context) {
                                      return bill.map((e){
                                        return Text(e!);
                                      }).toList();
                                    },
                                    validator: (value) {
                                      return value == null ? "Please selected billable" : null;
                                    },
                                  ),

                                  ///  Amount
                                  if(model.billable != 0)Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount',style:  TextStyle(fontWeight: FontWeight.w800,fontSize: 15),),
                                      cusDivider(),
                                      TextFormField(
                                        controller: model.currencyController,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Enter Amount',
                                          contentPadding:  const EdgeInsets.all(15),
                                          enabledBorder: _border,
                                          errorBorder: _errorBorder,
                                          focusedErrorBorder: _errorBorder,
                                          focusedBorder: _border,
                                          disabledBorder: _border,
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: SizedBox(
                                              height: 50,width: 165,
                                              child: DropdownButtonFormField(
                                                value: model.currencyList[0].codeId,
                                                borderRadius: BorderRadius.circular(25),
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                items: model.currencyList.map((e) {
                                                  return DropdownMenuItem(value: e.codeId, child: Text(e.codeName!));
                                                }).toList(),
                                                onChanged: (value) {
                                                  model.currency = int.parse(value.toString());
                                                  model.updateUI();
                                                },
                                                isExpanded: true,
                                                selectedItemBuilder: (context) {
                                                  return model.currencyList.map((e){
                                                    return Text(e.codeName!);
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        onSaved: (newValue) {},
                                        validator: (value) {
                                          return value!.isEmpty ? "Please enter amount" : null;
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30,),

                                  SizedBox(
                                    height: 60,width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              model.btnLoader.value = true;
                                              if(formKey.currentState!.validate()){

                                                if(widget.updateSubTask == true && widget.parentID != null && widget.taskID != null){
                                                  appPrint('==========> Update Sub Task');
                                                  model.updateSubTask(addTaskContext, widget.taskID, widget.parentID,model.service!.toString(), model.status.toString(), model.assToID!,
                                                      model.client.toString(), model.taskNameController.text, model.taskNoteController.text,
                                                      model.startDate!, model.endDate!, model.branch, model.department, model.priority.toString(), model.billable.toString(),
                                                      model.currencyController.text, model.currency!.toString());
                                                } else if(widget.subTask == true){
                                                  appPrint('==========> Add Sub Task ${widget.updateSubTask}' );
                                                  model.addUpdateTask(addTaskContext, widget.parentID,model.service!.toString(), model.status.toString(), model.assToID!,
                                                      model.client.toString(), model.taskNameController.text, model.taskNoteController.text,
                                                      model.startDate!, model.endDate!, model.branch, model.department, model.priority.toString(), model.billable.toString(),
                                                      model.currencyController.text, model.currency!.toString());
                                                } else if(widget.updateTask == true && widget.parentID != null){
                                                  appPrint('==========> Update Task');
                                                  model.updateTask(context, widget.parentID! , "${model.status}", model.taskNameController.text, model.startDate!,
                                                      model.endDate!, "${model.priority}", "${model.billable}", model.currencyController.text, model.fy);
                                                } else {
                                                  appPrint('==========> Add Task');
                                                  model.addUpdateTask(addTaskContext, null,model.service!.toString(), model.status.toString(), model.assToID!,
                                                      model.client.toString(), model.taskNameController.text, model.taskNoteController.text,
                                                      model.startDate!, model.endDate!, model.branch, model.department, model.priority.toString(), model.billable.toString(),
                                                      model.currencyController.text, model.currency!.toString());
                                                }

                                              } else {
                                                appPrint('NO');
                                                model.btnLoader.value = false;
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColor.background,
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child:  const Center(child: Text('Submit',style: TextStyle(color: Colors.white,fontSize: 20))),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Expanded(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: () {
                                              Navigator.pop(addTaskContext);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColor.background.withValues(alpha: (0.7)),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child:  const Center(child: Text('Cancel',style: TextStyle(color: Colors.white,fontSize: 20))),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 30,),

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
                return EmptyData();
              }
            },
          ),
        );
      },
    );
  }
}
