// import 'dart:ffi';
import 'dart:math';
import 'package:location/location.dart';
import 'package:utm/utm.dart';

final List<List<double>> pts = [
  [124, 1000],
  [454, 2934],
  [1756, 1840],
  [986, 10]
];

// Forward Bearing
double forwardBearing(List<double> pointA, List<double> pointB) {
  // ΔN is change in latitude, ΔE is change in longitudes
  double deltaN = pointB[1] - pointA[1];
  double deltaE = pointB[0] - pointA[0];
  double isLowest =
      (atan2(deltaE, deltaN) * 180 / pi) % 360; // atan2 in Dart returns radians
  return isLowest;
}

double calcDistance(List<double> firstPoint, List<double> secondPoint,
    {int precision = 2}) {
  // ΔN is change in latitude, ΔE is change in longitudes
  double deltaN = secondPoint[1] - firstPoint[1];
  double deltaE = secondPoint[0] - firstPoint[0];
  double dist12 = sqrt(pow(deltaE, 2) + pow(deltaN, 2));

  return double.parse(dist12.toStringAsFixed(precision));
}

// Back Bearing
double backBearing(List<double> pointA, List<double> pointB) {
  // ΔN is change in latitude, ΔE is change in longitudes
  double deltaN = pointA[1] - pointB[1];
  double deltaE = pointA[0] - pointB[0];
  double bearing =
      (atan2(deltaE, deltaN) * 180 / pi) % 360; // atan2 in Dart returns radians
  return bearing;
}

// DMS (Decimal Degrees to DMS Format)
String dms(double angle) {
// Normalize the angle to be within the range of [0, 360)
  angle = angle % 360;
  if (angle < 0) angle += 360;
  int degree = angle.truncate();
  String degrees = (degree.abs() < 10) ? "0$degree" : degree.toString();

  double floatMin = (angle - degree).abs() * 60;
  int minute = floatMin.truncate();
  var minutes = minute;
  String myMin = (minute < 10) ? "0$minutes" : minute.toString();

  double floatSec = (floatMin - minute) * 60;
  int sec = floatSec.truncate();
  String seconds = (sec < 10) ? "0$sec" : sec.toString();

  return "$degrees\u00b0 $myMin\u0022 $seconds\u0022";
}

/// Checks if a value is between two other values.
///
/// Args:
///
///   lowerBound:The lower bound.
///
///   testValue:The value to check.
///
///   upperBound:The upper bound.
///
///   inclusive: If true, the bounds are inclusive; otherwise, they are exclusive.
///
/// Returns:
///   True if b is between a and c, false otherwise.
bool isBetween({
  required double lowerBound,
  required double testValue,
  required double upperBound,
  bool inclusive = true,
}) {
  if (inclusive) {
    return testValue >= lowerBound && testValue <= upperBound;
  } else {
    return testValue > lowerBound && testValue < upperBound;
  }
}

/// Checks if the value is not the highest of other values
///
/// Args:
///
///  a: The value to check.
///
///  values: A list of values to compare against.
///
/// Returns:
///   True if a is not the highest, false otherwise.
bool isLowest({
  required double testValue,
  required List<double> others,
}) {
  return others.any((value) => testValue < value);
}

// Convert DMS string to decimal degrees
double dmsToDeg(String dmsString) {
  // Extract degrees, minutes, and seconds
  RegExp regExp = RegExp(r'-?\d+');
  Iterable<Match> matches = regExp.allMatches(dmsString);

  if (matches.length < 2) {
    throw ArgumentError(
        "Invalid DMS string format. Expected format is 23° 45' 30\"");
  }

  int degrees = int.parse(matches.elementAt(0).group(0)!);
  int minutes = int.parse(matches.elementAt(1).group(0)!);
  int seconds =
      (matches.length > 2) ? int.parse(matches.elementAt(2).group(0)!) : 0;

  double decimalDegrees = degrees.abs() + (minutes / 60) + (seconds / 3600);

  // Handle negative degrees
  if (degrees < 0) {
    decimalDegrees = -decimalDegrees;
  }

  return decimalDegrees;
}

// calculating the circumcenter of three points
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

// Step 2: Generate points for the circle
List<List<double>> circlePoints(List<double> center, double radius) {
  var numPoints = 360;
  List<List<double>> circlePoints = [];
  for (var i = 0; i < numPoints; i++) {
    var theta = 2 * pi * i / numPoints;
    var x = center[0] + radius * cos(theta);
    var y = center[1] + radius * sin(theta);
    circlePoints.add([x, y]);
  }
  return circlePoints;
}

// Convert latitude/longitude to UTM
Map<String, dynamic> convertLatLngToUtm(
    double latitude, double longitude, int precision) {
  final utm = UTM.fromLatLon(
      lat: latitude, lon: longitude, type: GeodeticSystemType.wgs84);

  var utmEasting =
      double.parse((utm.easting + -84.3244).toStringAsFixed(precision));
  var utmNorthing =
      double.parse((utm.northing + 294.3789).toStringAsFixed(precision));

  return {
    'zone': utm.zone,
    'easting': utmEasting,
    'northing': utmNorthing,
  };
}

Future<double?> getElevation() async {
  Location location = Location();

  // Get the location data
  LocationData locationData = await location.getLocation();

  // Return the elevation (altitude) if available
  return locationData.altitude;
}

/// Checks if point P(X, Y) is inside the triangle formed by vertices A, B, and C.
///
/// Args:
///   xTestValue: X-coordinate of point P.
///   yTestValue: Y-coordinate of point P.
///   ax: X-coordinate of vertex A.
///   ay: Y-coordinate of vertex A.
///   bx: X-coordinate of vertex B.
///   by: Y-coordinate of vertex B.
///   cx: X-coordinate of vertex C.
///   cy: Y-coordinate of vertex C.
///
/// Returns:
///   True if P is inside the triangle ABC, false otherwise.
bool isPointInTriangle({
  required double xTestValue,
  required double yTestValue,
  required double ax,
  required double ay,
  required double bx,
  required double by,
  required double cx,
  required double cy,
}) {
  // Function to calculate the area of a triangle given its vertices
  double triangleArea(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    return ((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)).abs()) / 2;
  }

  // Area of the full triangle ABC
  double areaABC = triangleArea(ax, ay, bx, by, cx, cy);

  // Areas of the sub-triangles PAB, PBC, and PCA
  double areaPAB = triangleArea(xTestValue, yTestValue, ax, ay, bx, by);
  double areaPBC = triangleArea(xTestValue, yTestValue, bx, by, cx, cy);
  double areaPCA = triangleArea(xTestValue, yTestValue, cx, cy, ax, ay);

  // Check if the sum of the areas of PAB, PBC, and PCA is equal to areaABC
  return (areaPAB + areaPBC + areaPCA) == areaABC;
}

// Interior Angle Calculation
double calculateAngle(
    List<double> point1, List<double> point2, List<double> point3,
    {int precision = 6}) {
  // Calculate distances between points
  double ab = calcDistance(point1, point2);
  double bc = calcDistance(point2, point3);
  double ac = calcDistance(point1, point3);
  // Calculate the angle in radians and then convert to degrees
  double angleRadians = acos((ab * ab + bc * bc - ac * ac) / (2 * ab * bc));
  double angleDegrees = angleRadians * (180 / pi);

  // Round to the specified precision
  return double.parse(angleDegrees.toStringAsFixed(precision));
}
