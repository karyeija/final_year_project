import 'package:flutter/material.dart';
import 'package:gnsspro/modules/specifications.dart';
import 'package:gnsspro/user_guide.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: 'Options',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            // height: pageHeight * 0.1,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Text('Options')),
          ),
          ListTile(
            tileColor: Colors.amber,
            title: const Text('About'),
            leading: const Icon(
              Icons.info_outline,
              size: 30,
            ),
            onTap: () => showGeneralDialog(
              context: context,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return AboutPage();
              },
            ),
          ),
          ListTile(
              tileColor: Colors.amber[300],
              title: const Text('Use guide'),
              leading: const Icon(
                Icons.help_rounded,
                size: 30,
              ),
              onTap: () => showUserGuide(context))
        ],
      ),
    );
  }
}
