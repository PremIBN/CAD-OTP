import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.03,),
            Center(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  dialog();
                },
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 52,
                      child: CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person,size: 35),
                      ),
                    ),
                    Positioned(
                      bottom: size.width * 0.01,
                      right: size.width * 0.001,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 13,
                            child: Icon(Icons.camera_alt,size: 16,)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.05,),

            Form(
              key: formKey,
              child: Column(
                children: [
                  CusField(
                    hint: 'Username',
                    controller: usernameController,
                    icon: const Icon(CupertinoIcons.person),
                    onValidator: (value) {
                      return usernameController.text.isEmpty ? 'Please enter username' : null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04,),
                  CusField(
                    hint: 'Email',
                    controller: emailController,
                    icon: const Icon(Icons.email_outlined),
                    readOnly: true,
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            CusBtn(
              btnName: 'Submit',
              onTap: () {
                !formKey.currentState!.validate();
                if(formKey.currentState!.validate()){
                  Navigator.pop(context);
                  CommonFunction.showSnackBar(context: context, isError: false, message: 'Profile update successfully');
                }else{
                  appPrint('No');
                }
              },
            )

          ],
        ),
      ),
    );
  }

  dialog () {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
                children: [

                  SizedBox(height: MediaQuery.of(context).size.height * 0.03,),

                  ListTile(

                    leading: const Icon(CupertinoIcons.camera_fill),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(AppImages.gallery,width: 25),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ]
            ),
          );
        },
    );
  }

}
