import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String appName = 'GNSS pro';
const String appVersion = '1.0.0';
const String developerName = 'Karyeija Felex';
const String developerEmail = 'felonetsolutions@gmail.com';
const String logoPath = 'icons/myLogo.png';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void launchEmail(String email) {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: Image(
        image: AssetImage(logoPath),
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.width * 0.1,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Developed by: $developerName',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () => launchEmail(developerEmail),
          child: Text(
            'Email:$developerEmail',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
