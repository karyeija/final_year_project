import 'package:flutter/material.dart';
import 'package:gnsspro/geometry.dart';
import 'package:gnsspro/modules/widgetbuilders.dart';
// Ensure the required geometry functions are imported

class PreviewPage extends StatelessWidget {
  final List<List<double>> pts;
  final double fontsize = 20;
  // Constructor to accept points
  const PreviewPage({super.key, required this.pts});

  @override
  Widget build(BuildContext context) {
    // angle BPC
    final angleBPC = dms(calculateAngle(pts[1], pts[3], pts[2]));

    // angle PAB
    final anglePAB = dms(calculateAngle(pts[3], pts[0], pts[1]));
    // Calculating the required angles
    String angleAPB = dms(calculateAngle(pts[0], pts[3], pts[1]));
    String angleABP = dms(calculateAngle(pts[0], pts[1], pts[3]));
    String anglePBC = dms(calculateAngle(pts[3], pts[1], pts[2]));
    String angleBCP = dms(calculateAngle(pts[1], pts[2], pts[3]));

    final distAB = calcDistance(pts[0], pts[1]).toStringAsFixed(2);
    final distBC = calcDistance(pts[1], pts[2]).toStringAsFixed(2);
    final distAC = calcDistance(pts[0], pts[2]).toStringAsFixed(2);
    final distBP = calcDistance(pts[1], pts[3]).toStringAsFixed(2);
    final distCP = calcDistance(pts[2], pts[3]).toStringAsFixed(2);
    final distAP = calcDistance(pts[0], pts[3]).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: Text('Geometric attributes',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  buildSectionTitle('Interior angles',
                      fontSize: 30, fontWeight: FontWeight.bold),

                  Text('Angle AP\u0305B: $angleAPB ',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(angleAPB) < 30 ||
                                  dmsToDeg(angleAPB) > 120
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 20),
                  Text('Angle BP\u0305C: $angleBPC',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(angleBPC) < 30 ||
                                  dmsToDeg(angleBPC) > 120
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 20),
                  Text('Angle PA\u0305B: $anglePAB',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(anglePAB) < 30 ||
                                  dmsToDeg(anglePAB) > 120
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 20),
                  Text('Angle AB\u0305P: $angleABP',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(angleABP) < 30 ||
                                  dmsToDeg(angleABP) > 120
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 20),
                  Text('Angle PB\u0305C: $anglePBC',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(anglePBC) < 30 ||
                                  dmsToDeg(anglePBC) > 120
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 20),
                  Text('Angle BC\u0305P: $angleBCP',
                      style: TextStyle(
                          fontSize: fontsize,
                          color: dmsToDeg(angleBCP) < 30 ||
                                  dmsToDeg(angleBCP) > 120
                              ? Colors.red
                              : Colors.green)),

                  buildSectionTitle('Baselines',
                      fontSize: 30, fontWeight: FontWeight.bold),
                  // SizedBox(height: 20),
                  Text('Distance AB: $distAB meters',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(height: 20),
                  Text('Distance BC: $distBC meters',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(height: 20),
                  Text('Distance AC: $distAC meters',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(height: 20),
                  Text('Distance BP: $distBP meters',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(height: 20),
                  Text('Distance CP: $distCP meters',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(height: 20),
                  Text('Distance AP: $distAP meters',
                      style: TextStyle(fontSize: fontsize))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
