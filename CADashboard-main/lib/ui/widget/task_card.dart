import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksCard extends StatelessWidget {

  final String? clientName;
  final String? taskName;
  final String? taskNumber;
  final DateTime? endingDate;
  final String? priority;
  final String? assign;
  final DateTime? assignDate;
  final String? employeeName;
  final String? subTaskCount;
  final GestureTapCallback? onTap;
  final GestureTapCallback? subTaskTap;

  const TasksCard({super.key, this.clientName, this.endingDate, this.priority, this.assign, this.employeeName, this.assignDate, this.taskName, this.taskNumber, this.onTap, this.subTaskCount, this.subTaskTap});

  @override
  Widget build(BuildContext context) {
    return taskNumber == "" ? const SizedBox() : GestureDetector(
      onTap: onTap,
      child: Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        elevation: 3,
        child: Container(
          // height: size.height * 0.3,
          padding: Utils.cardPadding,
          // decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: Utils.cardRadius,
          //     boxShadow:  const [
          //       BoxShadow(
          //           color: Colors.black54,
          //           blurRadius: 2,
          //           blurStyle: BlurStyle.outer)
          //     ]),
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                if(taskNumber != null /*&& cilentNumber != ""*/)  Card(
                  elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      surfaceTintColor: AppColor.logoColor,
                      color: AppColor.logoColor,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(taskNumber!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  if(taskName != null) Expanded(
                    child: Text(ApiTextLocalizer.localize(taskName!, locale: Localizations.localeOf(context)),
                      style: const TextStyle(color: AppColor.textButtonColor),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(clientName != "")Text(ApiTextLocalizer.localize('Client Name', locale: Localizations.localeOf(context))),
                      // ignore: unrelated_type_equality_checks
                      if(endingDate != null && endingDate != "")Text(ApiTextLocalizer.localize('Ending Date', locale: Localizations.localeOf(context))),
                      if(priority != "")Text(ApiTextLocalizer.localize('Priority', locale: Localizations.localeOf(context))),
                      if(assign != "")Text(ApiTextLocalizer.localize('Status', locale: Localizations.localeOf(context))),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(clientName != "")Text('  :  ${ApiTextLocalizer.localize(clientName!, locale: Localizations.localeOf(context))}', overflow: TextOverflow.ellipsis),
                        // ignore: unrelated_type_equality_checks
                        if(endingDate != null && endingDate != "")Text('  :  ${DateFormat('dd-MMM-yyyy').format(endingDate!)}', overflow: TextOverflow.ellipsis),
                        if(priority != "")Text('  :  ${ApiTextLocalizer.localize(priority!, locale: Localizations.localeOf(context))}', overflow: TextOverflow.ellipsis),
                        if(assign != "")Text('  :  ${ApiTextLocalizer.localize(assign!, locale: Localizations.localeOf(context))}', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              if(employeeName != null && assignDate != null)Align(
                  alignment: FractionalOffset.centerRight,
                  child: Text('$employeeName on ${DateFormat('dd-MMM-yyyy  hh:mm a').format(assignDate!)}')),

              if(subTaskCount != null && subTaskCount != "" && subTaskCount != "0") Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  onTap: subTaskTap,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$subTaskCount Sub Task',style: const TextStyle(color: Colors.deepOrangeAccent,fontSize: 17)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
