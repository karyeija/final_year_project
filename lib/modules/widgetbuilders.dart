import 'package:flutter/material.dart';
import 'package:gnsspro/chart.dart';

Widget buildChartContainer(
    double chartWidth, double chartHeight, List<List<double>> pts) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        // color: Colors.black54,
      ),
      width: chartWidth,
      height: chartHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: chartWidth,
        height: chartHeight,
        child: SyncfusionLineChart(pts), // Assuming this is your chart widget
      ),
    ),
  );
}

Widget buildControlStations(double controlsHeight, double pageWidth,
    List<TextEditingController> textfields) {
  return SizedBox(
    height: controlsHeight,
    child: Column(
      children: List.generate(3, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: controlsHeight / 3,
              child: buildStationRow(
                'STN ${String.fromCharCode(64 + index + 1)}',
                textfields[index * 2],
                textfields[index * 2 + 1],
                controlsHeight,
                pageWidth,
              ),
            ),
          ],
        );
      }),
    ),
  );
}

Widget buildStationRow(String stationLabel, TextEditingController xControl,
    TextEditingController yControl, double controlsHeight, double pageWidth) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(stationLabel),
      SizedBox(width: pageWidth * 0.01),
      buildCoordinateRow(xControl, yControl, controlsHeight, pageWidth),
    ],
  );
}

Widget buildCoordinateRow(TextEditingController xControl,
    TextEditingController yControl, double controlsHeight, double pageWidth) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildCoordinateInput(
          xControl, controlsHeight, pageWidth, 'Enter Easting'),
      SizedBox(width: pageWidth * 0.04),
      buildCoordinateInput(
          yControl, controlsHeight, pageWidth, 'Enter Northing'),
    ],
  );
}

Widget buildCoordinateInput(TextEditingController control,
    double controlsHeight, double pageWidth, String label) {
  return SizedBox(
    width: pageWidth * 0.38,
    height: controlsHeight * 0.38,
    child: TextField(
      controller: control,
      keyboardType: const TextInputType.numberWithOptions(),
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ),
  );
}

Widget buildUserLocationEntry(double controlsHeight, double pageWidth,
    List<TextEditingController> textfields) {
  return Center(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: pageWidth * 0.1),
        buildCoordinateRow(
            textfields[6], textfields[7], controlsHeight, pageWidth),
      ],
    ),
  );
}

Widget buildUserButtons(double pageWidth, VoidCallback submitButtonClicked,
    VoidCallback refreshButtonClicked) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      buildButton('Submit', submitButtonClicked),
      buildButton('Refresh', refreshButtonClicked),
    ],
  );
}

Widget buildButton(String label, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    onPressed: onPressed,
    child: Text(label, style: const TextStyle(fontSize: 26)),
  );
}

/// Helper to build bold section titles
Widget buildSectionTitle(String title,
    {double fontSize = 24.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black}) {
  return Text(
    title,
    style: TextStyle(fontWeight: fontWeight, fontSize: 30, color: Colors.black),
  );
}

Widget buildSectionHeading(
  String text, {
  double fontSize = 24.0,
}) {
  return FittedBox(
    fit: BoxFit.fill,
    child: SizedBox(
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: Colors.black),
      ),
    ),
  );
}

/// Helper to build a RichText with an icon and description that can have the icon placed anywhere in the text
Widget buildRichTextWithIcon({required List<InlineSpan> children}) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black, fontSize: 16),
      children: children,
    ),
  );
}
