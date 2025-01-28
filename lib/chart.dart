import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
import 'geometry.dart';

class SyncfusionLineChart extends StatelessWidget {
  final List<List<double>> pts;

  const SyncfusionLineChart(this.pts, {super.key});

  @override
  Widget build(BuildContext context) {
    // Step 1: Calculate circumcenter and radius
    var result = circumcenter(pts);
    double radius = result[0];
    List<double> center = result[1];

    // Generate circle points
    // var circleData = circlePoints(center, radius);

    // Step 2: Apply scaling to the points
    List<List<double>> scaledPoints = scalePoints(pts, center, radius);
    // List<List<double>> scaledCircleData =
    //     scalePoints(circleData, center, radius);

    // Combine all points for min/max calculation
    List<List<double>> allPoints = List.from(scaledPoints)..add(center);
    double minX = allPoints.map((point) => point[0]).reduce(min);
    double minY = allPoints.map((point) => point[1]).reduce(min);
    double maxX = allPoints.map((point) => point[0]).reduce(max);
    double maxY = allPoints.map((point) => point[1]).reduce(max);

    // Calculate range for both axes
    double xRange = maxX - minX;
    double yRange = maxY - minY;

    // Use the larger range to ensure both axes are scaled the same
    double range = max(xRange, yRange);

    // Center both axes around their respective midpoints
    double xMid = (minX + maxX) / 2;
    double yMid = (minY + maxY) / 2;
    double rangeAdjuster = 1.2;
    // Adjust the min and max values for both axes to ensure equal scaling
    double adjustedMinX = xMid - range / rangeAdjuster;
    double adjustedMaxX = xMid + range / rangeAdjuster;
    double adjustedMinY = yMid - range / rangeAdjuster;
    double adjustedMaxY = yMid + range / rangeAdjuster;

    // Add padding to avoid points being placed directly on the axes
    double axisPadding = 0.05 * range; // 5% padding

    // Ensure that the padding keeps the points away from the axis
    adjustedMinX -= axisPadding;
    adjustedMaxX += axisPadding;
    adjustedMinY -= axisPadding;
    adjustedMaxY += axisPadding;

    // Map points to chart data
    List<_ChartData> mainPoints = scaledPoints
        .asMap()
        .map((index, point) => MapEntry(
              index,
              _ChartData(point[0], point[1], _getColorByIndex(index)),
            ))
        .values
        .toList();
    // List<_ChartData> circlePointsData = scaledCircleData
    //     .map((point) => _ChartData(point[0], point[1], Colors.pink))
    //     .toList();
    // Define the data for the line joining A to P
    List<_ChartData> aToPLine = [
      _ChartData(
          scaledPoints[0][0], scaledPoints[0][1], Colors.white), // Point A
      _ChartData(
          scaledPoints[3][0], scaledPoints[3][1], Colors.white), // Point P
    ];
    // Define the data for the line joining P to B
    List<_ChartData> pToBLine = [
      _ChartData(
          scaledPoints[3][0], scaledPoints[3][1], Colors.white), // Point P
      _ChartData(
          scaledPoints[1][0], scaledPoints[1][1], Colors.white), // Point B
    ];

    // Step 3: Create the Syncfusion chart
    return Scaffold(
      body: SfCartesianChart(
        backgroundColor: Colors.black,
        title: ChartTitle(
          text: 'Geometric Visualization',
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 18, // Adjust the font size
            fontWeight: FontWeight.bold, // Set a bold font weight
            fontStyle: FontStyle.italic, // Make the font italic
            letterSpacing: 1.5, // Add some letter spacing for a clean look
            shadows: <Shadow>[
              Shadow(
                color: Colors.yellow
                    .withValues(blue: 0.2), // Add shadow to the title
                offset: const Offset(1, 1), // Set the shadow offset
                blurRadius: 5, // Set the blur radius for the shadow
              ),
            ],
          ),
          alignment: ChartAlignment.center, // Center the title
        ),
        primaryXAxis: NumericAxis(
          title: AxisTitle(
              text: 'Easting', textStyle: const TextStyle(color: Colors.white)),
          labelStyle: const TextStyle(color: Colors.white),
          numberFormat: NumberFormat('###0'),
          minimum: adjustedMinX,
          maximum: adjustedMaxX,
          // placeLabelsNearAxisLine: false,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
              text: 'Northing',
              textStyle: const TextStyle(color: Colors.white)),
          labelStyle: const TextStyle(color: Colors.white),
          labelRotation: 300,
          numberFormat: NumberFormat('###0'),
          minimum: adjustedMinY,
          maximum: adjustedMaxY,
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          // Circle points
          // LineSeries<_ChartData, double>(
          //   dataSource: circlePointsData,
          //   xValueMapper: (_ChartData data, _) => data.x,
          //   yValueMapper: (_ChartData data, _) => data.y,
          //   color: Colors.pink,
          //   width: 2,
          //   name: 'Circle (A to P)',
          // ),
          // Line from A to P
          LineSeries<_ChartData, double>(
            dataSource: aToPLine,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
            name: 'Line stn1 to current location',
          ),
          // Line from P to B
          LineSeries<_ChartData, double>(
            dataSource: pToBLine,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
            name: 'Line P to B',
          ),
          // Main points (Scatter points)
          ScatterSeries<_ChartData, double>(
            dataSource: mainPoints,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            pointColorMapper: (_ChartData data, _) => data.color,
            markerSettings: const MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              width: 10,
              height: 10,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                // Add custom labels for the points
                switch (pointIndex) {
                  case 0:
                    return const Text('STN-A',
                        style: TextStyle(color: Colors.white));
                  case 1:
                    return const Text('STN-B',
                        style: TextStyle(color: Colors.white));
                  case 2:
                    return const Text('STN-C',
                        style: TextStyle(color: Colors.white));
                  default:
                    return const Text('STN-P',
                        style: TextStyle(color: Colors.white));
                }
              },
            ),
          ),
          // Connecting lines (between all points)
          LineSeries<_ChartData, double>(
            dataSource: mainPoints,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
          ),
        ],
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.xy,
        ),
      ),
    );
  }

  // Function to scale the points based on the circumcenter and radius
  List<List<double>> scalePoints(
      List<List<double>> points, List<double> center, double radius) {
    return points.map((point) {
      double scaledX = (point[0] - center[0] / (radius));
      double scaledY = (point[1] - center[1] / (radius));
      return [scaledX, scaledY];
    }).toList();
  }

  // Function to calculate the angle between two vectors (in radians)
  double calculateAngle(
      List<double> point1, List<double> point2, List<double> point3) {
    // Vector AP = (point2 - point1)
    double ax = point2[0] - point1[0];
    double ay = point2[1] - point1[1];

    // Vector BP = (point3 - point2)
    double bx = point3[0] - point2[0];
    double by = point3[1] - point2[1];

    // Calculate the dot product and magnitude of vectors
    double dotProduct = ax * bx + ay * by;
    double magnitudeA = sqrt(ax * ax + ay * ay);
    double magnitudeB = sqrt(bx * bx + by * by);

    // Calculate the angle in radians and then convert to degrees
    double angleRadians = acos(dotProduct / (magnitudeA * magnitudeB));
    return angleRadians * (180 / pi); // Convert to degrees
  }

  // Function to get a color based on the index
  Color _getColorByIndex(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      default:
        return Colors.yellow;
    }
  }
}

// Chart data class
class _ChartData {
  final double x;
  final double y;
  final Color color;

  _ChartData(this.x, this.y, this.color);
}
