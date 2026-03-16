import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text("CADashboard is the brainchild of orgpro software's Pvt. Ltd While interacting with our CA/CS, we observed that communication was lost/ delayed. We had to remember compliance dates and events. This was a pain point. But in this pain, we saw a business opportunity. Why not create a platform between CA's/CS's and their clients. Hence was born CADashboard. Our mission is to simplify communication between CA's/CS's and clients. How? By letting you do your core tasks. You already have enough to look after, so back-office and recurring tasks should never waste your valuable time. With CADashboard, we've created tools that clear your plate for the work you really want to do.",),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    if(!await launchUrl(Uri.parse(Urls.cadashboard),mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch';
                    }
                  },
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle
                    ),
                    child: Image.asset(AppImages.logo,color: Colors.white,)
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    if(!await launchUrl(Uri.parse(Urls.facebook),mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch';
                    }
                  },
                  child: Image.asset(AppImages.facebook,width: 40)
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    if(!await launchUrl(Uri.parse(Urls.linkedin),mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch';
                    }
                  },
                  child: Image.asset(AppImages.linkedin,width: 40)
                ),
                InkWell(
                  overlayColor: const WidgetStatePropertyAll(Colors.white),
                  onTap: () async {
                    if(!await launchUrl(Uri.parse(Urls.twitter),mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch';
                    }
                  },
                  child: Image.asset(AppImages.twitter,width: 55)
                ),
                InkWell(
                  overlayColor: const WidgetStatePropertyAll(Colors.white),
                  onTap: () async {
                    if(!await launchUrl(Uri.parse(Urls.youtube),mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch';
                    }
                  },
                  child: Image.asset(AppImages.youtube,width: 45)
                ),
              ],
            ),
          ],
        ),
      ),
      
    );
  }
}


/*

Also please add all social links:-
1) Cadashboard Website:- https://www.cadashboard.com
2) Facebook:- https://www.facebook.com/CADashboard
3) Linkedin:- https://www.linkedin.com/company/cadashboard
4) Twitter:- https://twitter.com/CAdashboard
5) Youtube:- https://www.youtube.com/channel/UCwqPI-XdpWlnxUEm6IrYMVg

*/


