import 'package:cadashboard/core/View_Model/change_password_vm.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_textfield.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return StatelessBaseView(
      model: ChangePasswordVM(),
      builder: (buildContext, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(ApiTextLocalizer.localize('Change Password', locale: Localizations.localeOf(buildContext))),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.05,),
                    CusField(
                      controller: model.oldController,
                      hint: ApiTextLocalizer.localize('Old Password', locale: Localizations.localeOf(buildContext)),
                      icon: const Icon(Icons.password),
                      visible: !model.visiable1,
                      onValidator: (value) {
                        return model.oldController.text.isEmpty
                            ? 'Old password is empty'
                            : null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(model.visiable1 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          model.visiable1 ? model.visiable1 = false : model.visiable1 = true;
                          model.updateUI();
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.03,),
                    CusField(
                      controller: model.newController,
                      hint: ApiTextLocalizer.localize('New Password', locale: Localizations.localeOf(buildContext)),
                      icon: const Icon(Icons.password),
                      visible: !model.visiable2,
                      suffixIcon: IconButton(
                        icon: Icon(model.visiable2 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          model.visiable2 ? model.visiable2 = false : model.visiable2 = true;
                          model.updateUI();
                        },
                      ),
                      onValidator: (value) {
                        appPrint(Utils.isPassword(model.newController.text));
                        return model.newController.text.isEmpty
                            ? 'New password is empty'
                            : Utils.isPassword(model.newController.text) == false
                              ? 'Make one Capital letter, one small letter, one number and 1 special character compulsory'
                              : null;
                      },
                    ),
                    SizedBox(height: size.height * 0.05,),
                    ValueListenableBuilder(
                      valueListenable: model.buttonLoader,
                      builder: (context, value, child) {
                        return CusBtn(
                          btnName: ApiTextLocalizer.localize('Submit', locale: Localizations.localeOf(buildContext)),
                          loading: value,
                          onTap: () {
                            model.buttonLoader.value = true;
                            model.updateUI();
                            if(formkey.currentState!.validate()){
                              model.changePassword(context);
                            }else{
                              model.buttonLoader.value = false;
                              model.updateUI();
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
