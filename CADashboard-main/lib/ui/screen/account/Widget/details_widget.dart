import 'package:cadashboard/core/View_Model/account/account_receivable_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/ui/screen/account/Widget/account_receivable_widget.dart';
import 'package:flutter/material.dart';

class ARDetailWidget extends StatelessWidget {
  const ARDetailWidget({
    super.key,
    required this.receivableData,
    required this.model,
  });

  final List<String> receivableData;
  final AccountReceivableVM model;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText('Invoice No.',color: AppColor.background),
                      ValueText(receivableData[model.invoiceNo],color: AppColor.background),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TitleText('Communication History'),
                    ValueText(CommonFunction.extractTextBeforeDate(receivableData[model.communicationHistory])),
                  ],
                ),
              ],
            ),
            const Divider(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText('Client Name  :  '),
                Expanded(child: ValueText(CommonFunction.removeNumberAndSymbol(receivableData[model.clientName]))),
              ],
            ),
            const Divider(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TitleText('Due Days  :  '),
                    ValueText(receivableData[model.dueDays]),
                  ],
                ),
                Row(
                  children: [
                    TitleText('Flag  :  '),
                    ValueText(receivableData[model.flag]),
                  ],
                ),
              ],
            ),
            const Divider(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TitleText('Invoice Amt.'),
                      ValueText(receivableData[model.invoiceAmount]),
                    ],
                  ),
                ),
                RawDivider(),
                Expanded(
                  child: Column(
                    children: [
                      TitleText('Received Amt.'),
                      ValueText(receivableData[model.receivedAmount]),
                    ],
                  ),
                ),
                RawDivider(),
                Expanded(
                  child: Column(
                    children: [
                      TitleText('Balance Amt.'),
                      ValueText(receivableData[model.balanceAmount]),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TitleText('Next Followup Date'),
                      ValueText(CommonFunction.dateTimeDecode(receivableData[model.nextFollowupDate].characters.take(9).string)),
                    ],
                  ),
                ),
                RawDivider(),
                Expanded(
                  child: Column(
                    children: [
                      TitleText('Exp. Payment Date'),
                      ValueText(CommonFunction.dateTimeDecode(receivableData[model.expectedPaymentDate].characters.take(9).string)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TitleText("Invoice Created From  :  "),
                Expanded(child: ValueText(receivableData[model.invoiceCreatedFrom])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}