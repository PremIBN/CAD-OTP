import 'package:cadashboard/core/utils/colors.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {

  final String? orgname;
  final String? clientname;
  final String? email;
  final String? mobile;
  final String? mobile2;
  final String? pan;
  final String? fileNumber;
  final String? branchName;
  final String? clientType;
  final String? groupName;
  final GestureTapCallback? onTap;


  const ClientCard({super.key, this.clientname, this.email, this.mobile, this.pan, this.fileNumber, this.branchName, this.clientType, this.groupName, this.onTap, this.mobile2, this.orgname});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if(orgname != null && orgname != "")Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Text(orgname!,style: const TextStyle(color: AppColor.background,fontSize: 17)),
            ),
            const Divider(height: 0),

            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(clientname != null && clientname != "")const Text('Name'),
                      // if(email != null && email != "")Text('Email'),
                      // if(mobile != null && mobile != "")Text('Mobile'),
                      // if(pan != null && pan != "")Text('PAN'),
                      if(fileNumber != null && fileNumber != "")const Text('File Number'),
                      if(branchName != null && branchName != "")const Text('Branch Name'),
                      if(clientType != null && clientType != "")const Text('Client Type'),
                      // if(groupName != null && groupName != "")Text('Group Name'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(clientname != null && clientname != "")Text(clientname!.length > 30 ? ' :  ${clientname!.characters.take(30)}...' : "  : $clientname"),
                      // if(email != null && email != "")Text(' :  $email'),
                      /*(mobile2 != null && mobile2 != "") ? Text(' :  $mobile, $mobile2')
                          : (mobile != null && mobile != "") ? Text(' :  $mobile') : SizedBox(),*/
                      // if(pan != null && pan != "")Text(' :  $pan'),
                      if(fileNumber != null && fileNumber != "")Text(fileNumber!.length > 25 ? ' :  ${fileNumber!.characters.take(25)}...' : "  : $fileNumber"),
                      if(branchName != null && branchName != "")Text(branchName!.length > 30 ? ' :  ${branchName!.characters.take(30)}...' : "  : $branchName"),
                      if(clientType != null && clientType != "")Text(clientType!.length > 30 ? ' :  ${clientType!.characters.take(30)}...' : "  : $clientType"),
                      // if(groupName != null && groupName != "")Text(' :  $groupName'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
