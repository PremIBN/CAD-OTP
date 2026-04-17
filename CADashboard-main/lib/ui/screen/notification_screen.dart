import 'package:cadashboard/core/View_Model/notification_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  ScrollController scrollController = ScrollController();

  int page = 15;

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView(
      model: NotificationVM(),
      onInitState: (p0) {
        p0.getNotification(context);

        scrollController.addListener(() {
          if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if(page < p0.maxNotification) {
              setState(() { (page += 15); });
              if(page > p0.maxNotification) {
                setState(() {
                  page = p0.maxNotification;
                });
              }
            }
          }
        });

      },
      builder: (buildContext, model, child) {
        return Scaffold(

          appBar: AppBar(
            title: Text(ApiTextLocalizer.localize('Notification', locale: Localizations.localeOf(buildContext)),style: const TextStyle()),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.delete),
                onPressed: () {
                  CommonFunction.alertDialog(
                    context: context,
                    title: 'All Clear ?',
                    subTitle: 'Are you sure you want to delete all notification?',
                    onNo: () {
                      Navigator.pop(context);
                    },
                    onYes: () {
                      Navigator.pop(context);
                      model.clearNotification(context);
                    },
                  );
                },
              ),
              const SizedBox(width: 10,),
            ],
          ),

          body: ValueListenableBuilder(
            valueListenable: model.viewLoader,
            builder: (context, value, child) {
              if(value == ViewState.loading) {
                return CommonLoader();
              } else if(value == ViewState.success) {
                return Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: model.notification.isEmpty
                    ? EmptyData(emptyData: 'Notification Not Found')
                    : ListView.builder(
                    controller: scrollController,
                    itemCount: model.notification.length,
                    itemBuilder: (context, index) {

                      return Card(
                        margin: const EdgeInsets.only(top: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: FractionalOffset.centerRight,
                                  child: Text(DateFormat('dd-MMM-yyyy hh:mm a').format(model.notification[index].notificationDate!),style: const TextStyle(fontSize: 12),)
                              ),
                              const SizedBox(height: 5,),
                              Html(
                                data: model.notification[index].message!,
                                style: {"b" :Style(fontWeight: FontWeight.w900,)},
                              ),
                              // Text(model.notification[index].message!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.grey.shade600),),
                            ],
                          ),
                        ),
                      );

                      /*if(index == page) {
                        return page==model.maxNotification ? EmptyData(emptyData: 'No More Notification') : CommonLoader();
                      } else if(model.notification.isEmpty){
                        return Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
                          child: EmptyData(emptyData: "No more Notification")
                        );
                      } else {

                      }*/
                    },
                  ),
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
