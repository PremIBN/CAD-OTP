import 'package:cadashboard/core/View_Model/forgot_password_vm.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPasswore extends StatefulWidget {
  const ForgotPasswore({super.key});

  @override
  State<ForgotPasswore> createState() => _ForgotPassworeState();
}

class _ForgotPassworeState extends State<ForgotPasswore> {

  final formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();


  @override
  Widget build(BuildContext mainContext) {
    var size = MediaQuery.of(mainContext).size;
    return StatelessBaseView(
      model: ForgotPasswordVM(),
      builder: (buildContext, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password'),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03,),
                  const Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text('Please provide your registered "Username & Email ID" to sent the reset password link.',style: TextStyle(
                      fontSize: 15, color: Colors.black38,
                    ),),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [

                        const SizedBox(height: 10,),

                        CusField(
                          controller: usernameController,
                          hint: 'Enter Username',
                          keyboardType: TextInputType.emailAddress,
                          icon: const Icon(Icons.person_outline_outlined),
                          onValidator: (value) {
                            return usernameController.text.isEmpty
                                ? 'Please enter username.'
                                : null;
                          },
                          onChanged: (value) {
                            value.isEmpty ? !formkey.currentState!.validate() : formkey.currentState!.validate();
                          },
                        ),

                        const SizedBox(height: 10,),
                        CusField(
                          controller: emailController,
                          hint: 'Enter Email',
                          keyboardType: TextInputType.emailAddress,
                          icon: const Icon(Icons.email_outlined,),
                          onValidator: (value) {
                            return emailController.text.isEmpty
                                ? 'Please enter email'
                                : !Utils.isEmail(emailController.text)
                                ? 'Please enter valid email Example"abc2@gmail.com".'
                                : null;
                          },
                          onChanged: (value) {
                            value.isEmpty ? !formkey.currentState!.validate() : formkey.currentState!.validate();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  ValueListenableBuilder(
                    valueListenable: model.loading,
                    builder: (context, value, child) {
                      return CusBtn(
                        btnName: 'Submit',
                        loading: value,
                        onTap: () {
                          setState(() {
                            model.loading.value = true;
                          });
                          if(formkey.currentState!.validate()) {
                            model.closeKeyboard();
                            model.forgot(mainContext, usernameController.text, emailController.text);
                          } else {
                            model.loading.value = false;
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
        );
      },
    );
  }
}
