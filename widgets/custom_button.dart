import 'dart:math';

List<dynamic> circumcenter(List<List<double>> pts) {
  final x1 = pts[0][0];
  final y1 = pts[0][1];
  final x2 = pts[1][0];
  final y2 = pts[1][1];
  final x3 = pts[2][0];
  final y3 = pts[2][1];
  final a1 = x1 - x2;
  final b1 = y1 - y2;
  final c1 = x1 * x1 - x2 * x2;
  final d1 = y1 * y1 - y2 * y2;
  final a2 = x2 - x3;
  final b2 = y2 - y3;
  final c2 = x2 * x2 - x3 * x3;
  final d2 = y2 * y2 - y3 * y3;

  final yCenter = (a2 * (c1 + d1) - a1 * (c2 + d2)) / (a2 * b1 - a1 * b2) / 2;
  final xCenter = (c1 + d1 - 2 * b1 * yCenter) / (2 * a1);

  // Calculate the radius
  double radius = sqrt(pow(x1 - xCenter, 2) + pow(y1 - yCenter, 2));
  return [
    radius,
    [xCenter, yCenter]
  ];
}

var resti = circumcenter([[3,7],[4,2],[6,7]]);


void main() {
  
// print(resti);
}