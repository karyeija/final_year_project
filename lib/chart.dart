import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    var circleData = circlePoints(center, radius);

    // Step 2: Apply scaling to the points
    List<List<double>> scaledPoints = scalePoints(pts, center, radius);
    List<List<double>> scaledCircleData =
        scalePoints(circleData, center, radius);

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

    // Adjust the min and max values for both axes to ensure equal scaling
    double adjustedMinX = xMid - range / 1.2;
    double adjustedMaxX = xMid + range / 1.2;
    double adjustedMinY = yMid - range / 1.2;
    double adjustedMaxY = yMid + range / 1.2;

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
    List<_ChartData> circlePointsData = scaledCircleData
        .map((point) => _ChartData(point[0], point[1], Colors.pink))
        .toList();
    // Define the data for the line joining A to P
    List<_ChartData> aToPLine = [
      _ChartData(
          scaledPoints[0][0], scaledPoints[0][1], Colors.white), // Point A
      _ChartData(
          scaledPoints[3][0], scaledPoints[3][1], Colors.white), // Point P
    ];
    // Define the data for the line joining A to P
    List<_ChartData> pToBLine = [
      _ChartData(
          scaledPoints[3][0], scaledPoints[3][1], Colors.white), // Point P
      _ChartData(
          scaledPoints[1][0], scaledPoints[1][1], Colors.white), // Point A
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
                color:
                    Colors.yellow.withOpacity(0.4), // Add shadow to the title
                offset: Offset(5, 4), // Set the shadow offset
                blurRadius: 5, // Set the blur radius for the shadow
              ),
            ],
          ),
          alignment: ChartAlignment.center, // Center the title
        ),
        primaryXAxis: NumericAxis(
          title: AxisTitle(
              text: 'Easting', textStyle: TextStyle(color: Colors.white)),
          labelStyle: TextStyle(color: Colors.white),
          // Hide the numeric labels
          numberFormat: NumberFormat('###0'),
          // isVisible: false,
          minimum: adjustedMinX,
          maximum: adjustedMaxX,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
              text: 'Northing', textStyle: TextStyle(color: Colors.white)),
          labelStyle: TextStyle(color: Colors.white), // Hide the numeric labels
          isVisible: true,
          labelRotation: 300,
          numberFormat: NumberFormat('###0'),
          // isInversed: true,

          minimum: adjustedMinY,
          maximum: adjustedMaxY,
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          // Circle points
          LineSeries<_ChartData, double>(
            dataSource: circlePointsData,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.pink,
            width: 2,
          ),
          // Add the following LineSeries to your existing `series` list:
          LineSeries<_ChartData, double>(
            dataSource: aToPLine,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
          ),
// Add the following LineSeries to your existing `series` list:
          LineSeries<_ChartData, double>(
            dataSource: pToBLine,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
          ),
          // Main points
          ScatterSeries<_ChartData, double>(
            dataSource: mainPoints,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            pointColorMapper: (_ChartData data, _) => data.color,
            markerSettings: MarkerSettings(
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
                    return Text('A', style: TextStyle(color: Colors.white));
                  case 1:
                    return Text('B', style: TextStyle(color: Colors.white));
                  case 2:
                    return Text('C', style: TextStyle(color: Colors.white));
                  default:
                    return Text('P', style: TextStyle(color: Colors.white));
                }
              },
            ),
          ),
          // Connecting lines
          LineSeries<_ChartData, double>(
            dataSource: mainPoints,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Colors.white,
            width: 2,
          ),
        ],
      ),
    );
  }

  // Function to scale the points based on the circumcenter and radius
  List<List<double>> scalePoints(
      List<List<double>> points, List<double> center, double radius) {
    return points.map((point) {
      double scaledX = (point[0] - center[0]);
      double scaledY = (point[1] - center[1]);
      return [scaledX, scaledY];
    }).toList();
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
