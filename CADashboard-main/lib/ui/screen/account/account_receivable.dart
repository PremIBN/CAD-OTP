import 'package:cadashboard/core/View_Model/account/account_receivable_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/services/app_locale_controller.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/account/Widget/account_receivable_widget.dart';
import 'package:cadashboard/ui/screen/account/Widget/details_widget.dart';
import 'package:flutter/material.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';

class AccountReceivableScreen extends StatefulWidget {
  const AccountReceivableScreen({super.key});

  @override
  State<AccountReceivableScreen> createState() =>
      _AccountReceivableScreenState();
}

class _AccountReceivableScreenState extends State<AccountReceivableScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  List tabs = ['Total', 'Details'];
  int tabIndex = 0;

  List search = [
    'All',
    'Financial Year',
    'Branch',
    'Currency',
    'Priority',
    'Firm',
    'Group'
  ];

  BorderSide tableBorder = const BorderSide(width: 1, color: Colors.grey);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext aRContext) {
    return StatelessBaseView(
      model: AccountReceivableVM(),
      onInitState: (p0) {
        p0.getCurrency(aRContext);
      },
      builder: (buildContext, model, child) {
        final locale = Localizations.localeOf(buildContext);
        return Scaffold(
          appBar: AppBar(
            // Rebuild when currency or app language changes (ApiTextLocalizer / glossary).
            title: ListenableBuilder(
              listenable: Listenable.merge([
                model.currency,
                AppLocaleController.locale,
              ]),
              builder: (context, _) {
                return Text(
                  ApiTextLocalizer.localize(
                    model.currency.value,
                    locale: Localizations.localeOf(context),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outlined),
                onPressed: () {
                  showDialog(
                    context: aRContext,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          model.dropDown(context);
                          return Dialog(
                            child: CommonLoader(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  searchDetailsDialog(aRContext, model);
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: tabController,
                tabs: tabs
                    .map((e) => Tab(
                          text: ApiTextLocalizer.localize(e.toString(), locale: locale),
                        ))
                    .toList(),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: model.viewLoader,
                  builder: (context, value, child) {
                    if (value == ViewState.loading) {
                      return CommonLoader();
                    } else if (value == ViewState.success) {
                      return TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          /// First Tab
                          model.totalData.data.isEmpty
                              ? EmptyData()
                              : Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10)
                                          .copyWith(top: 10),
                                  child: Column(
                                    children: [
                                      for (int index = 2; index < model.totalData.columns.length; index++)
                                        CustomText(
                                          title: model.totalData.columns[index],
                                          value: model.totalData.data[0][index],
                                          currency: model.totalData.data[0][1],
                                        ),
                                    ],
                                  ),
                                ),

                          /// Second Tab
                          model.receivableData.isEmpty
                              ? EmptyData()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ListView.builder(
                                    itemCount: model.receivableData.length,
                                    itemBuilder: (context, index) {
                                      var receivableData =
                                          model.receivableData[index];
                                      return ARDetailWidget(
                                        receivableData: receivableData,
                                        model: model,
                                      );
                                    },
                                  ),
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
        );
      },
    );
  }

  void searchDetailsDialog(BuildContext aRContext, AccountReceivableVM model) {
    showDialog(
      context: aRContext,
      builder: (context) {
        return Dialog(
          child: Container(
            height: search.length * 50,
            padding: const EdgeInsets.all(15),
            child: ListView.builder(
              itemCount: search.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showSearchDialog(aRContext, index, model);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          ApiTextLocalizer.localize(search[index].toString(), locale: Localizations.localeOf(aRContext)),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(
                        height: 10,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  showSearchDialog(BuildContext context, int index, AccountReceivableVM model) {
    return showDialog(
      context: context,
      builder: (context) {
        switch(index){
          case 0:
              Navigator.pop(context);
              model.getCurrency(context);
            case 1:
              model.getFinancialYear(context);
            case 2 :
              model.getBranch(context);
            case 3:
              model.getcurrency(context);
            case 4:
              model.getPriority(context);
            case 5:
              model.getFirmType(context);
            case 6 :
              model.getGroupType(context);
            default:
              Navigator.pop(context);
              model.Duration = showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime(DateTime.now().year + 10)
              ).toString();
          }
          return Dialog(child: CommonLoader());
        },
    );
  }
}
