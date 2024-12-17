import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

import 'package:test/geometry.dart';
// import 'dart:io';

/// A reusable widget for creating a SizedBox containing styled text.
Widget reusableTextSizedBox({
  required String text,
  double height = 5,
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.bold,
  Color textColor = Colors.black,
}) {
  return SizedBox(
    height: height,
    child: Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
    ),
  );
}

// ignore: must_be_immutable
class ReportPage extends StatefulWidget {
  String distAB,
      distBC,
      distAC,
      bearingAB,
      bearingBC,
      bearingAC,
      backBearingAB,
      backBearingBC,
      backBearingAC,
      angleABC,
      anglePAB,
      angleAPB,
      angleBPC;

  ReportPage({
    super.key,
    // required this.bearingAB,
    required this.bearingAB,
    required this.bearingBC,
    required this.bearingAC,
    required this.distAB,
    required this.distBC,
    required this.distAC,
    required this.backBearingAB,
    required this.backBearingBC,
    required this.backBearingAC,
    required this.anglePAB,
    required this.angleABC,
    required this.angleAPB,
    required this.angleBPC,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  /// A reusable widget for creating a SizedBox containing styled text.
  Widget reusableTextSizedBox({
    required String text,
    double height = 5,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color textColor = Colors.black,
  }) {
    return SizedBox(
      height: height,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }

  /* ...........................................................
  ........................................................
  .......................................................... */
  //READERS PAGE

  get anglePAB => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Angle PAB: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.anglePAB,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get angleABC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Angle ABC: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.angleABC,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get angleAPB => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Angle APB(\u03b1): ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.angleAPB,
          style: TextStyle(
              fontSize: 20,
              color: dmsToDeg(widget.angleAPB) > 30 &&
                      dmsToDeg(widget.angleAPB) < 135
                  ? Colors.green
                  : Colors.red),
        ),
      ]));
  get angleBPC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Angle BPC(\u03b2): ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.angleBPC,
          style: TextStyle(
              fontSize: 20,
              color: dmsToDeg(widget.angleBPC) > 30 &&
                      dmsToDeg(widget.angleBPC) < 135
                  ? Colors.green
                  : Colors.red),
        ),
      ]));
  get brgAB => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Forward bearing  AB: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.bearingAB,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get brgBC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Forward bearing  BC: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.bearingBC,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get brgAC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Forward bearing  AC: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.bearingAC,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get backBrngAB => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Back Bearing AB: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.backBearingAB,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get BackBrngBC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Back Bearing BC: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.backBearingBC,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));
  get BackBrngAC => RichText(
          text: TextSpan(children: [
        TextSpan(
            text: 'Back Bearing AC: ',
            style: TextStyle(fontSize: 20, color: Colors.black)),
        TextSpan(
          text: widget.backBearingAC,
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ]));

  get distAB => Text('Distance AB: ${widget.distAB} metres',
      style: TextStyle(fontSize: 20, color: Colors.blue));
  get distBC => Text('Distance BC: ${widget.distBC} metres',
      style: TextStyle(fontSize: 20, color: Colors.blue));
  get distAC => Text('Distance AC: ${widget.distAC} metres',
      style: TextStyle(fontSize: 20, color: Colors.blue));

  //PRINTING PAGE
  /* ......................................................
  ...........................................................
  ......................................................................... */

  // get printData => pw.Column(children: [pw.Text('$anglePAB')]);

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Center(
          child: pw.Column(children: [
        pw.Text('A brief field report',
            style: pw.TextStyle(
              fontSize: 24,
            )),
        pw.SizedBox(
          // height: 5,
          child: pw.Text(
            'Angles.',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        // ANGLE PAB
        pw.Container(
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(Colors.white70.value),
                border: pw.Border.all(
                    color: PdfColor.fromInt(Colors.green.value), width: 4)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Angle PAB : ',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: widget.anglePAB,
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColor.fromInt(Colors.blue.value))),
                  ])),
                  // ANGLE ABC
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Angle ABC: ', style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: widget.angleABC,
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColor.fromInt(Colors.blue.value))),
                  ])),
                  // ANGLE APB
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Angle APB: ', style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: widget.angleAPB,
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: dmsToDeg(widget.angleAPB) > 30 &&
                                    dmsToDeg(widget.angleAPB) < 135
                                ? PdfColor.fromInt(Colors.green.value)
                                : PdfColor.fromInt(Colors.red.value))),
                  ])),
                  // ANGLE BPC
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Angle BPC: ', style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: widget.angleBPC,
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: dmsToDeg(widget.angleBPC) > 30 &&
                                    dmsToDeg(widget.angleBPC) < 135
                                ? PdfColor.fromInt(Colors.green.value)
                                : PdfColor.fromInt(Colors.red.value))),
                  ])),
                ])),
        // BEARING AB
        pw.SizedBox(
          // height: 5,
          child: pw.Text(
            'Bearings.',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(Colors.white70.value),
              border: pw.Border.all(
                  color: PdfColor.fromInt(Colors.green.value), width: 4)),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Forward bearing AB: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.bearingAB,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: PdfColor.fromInt(Colors.blue.value))),
                ])),
                // BEARING BC
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Forward bearing BC: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.bearingBC,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: dmsToDeg(widget.bearingBC) > 30
                              ? PdfColor.fromInt(Colors.blue.value)
                              : PdfColor.fromInt(Colors.red.value))),
                ])),
                // BEARING AC
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Forward bearing AC: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.bearingAC,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: dmsToDeg(widget.bearingAC) > 30
                              ? PdfColor.fromInt(Colors.blue.value)
                              : PdfColor.fromInt(Colors.red.value))),
                ])),
                // Back bearing AB
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Back bearing AB: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.backBearingAB,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: PdfColor.fromInt(Colors.blue.value))),
                ])),
                // Back bearing BC
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Back bearing BC: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.backBearingBC,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: PdfColor.fromInt(Colors.blue.value))),
                ])),
                // Back bearing AC
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'Back bearing AC: ',
                      style: pw.TextStyle(fontSize: 20)),
                  pw.TextSpan(
                      text: widget.backBearingAC,
                      style: pw.TextStyle(
                          fontSize: 20,
                          color: PdfColor.fromInt(Colors.blue.value))),
                ])),
              ]),
        ),
        pw.SizedBox(
          // height: 5,
          child: pw.Text(
            'Distances.',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        // DISTANCE AB
        pw.Container(
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(Colors.white70.value),
                border: pw.Border.all(
                    color: PdfColor.fromInt(Colors.green.value), width: 4)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Distance AB: ',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: '${widget.distAB} metres\n',
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColor.fromInt(Colors.blue.value))),
                    pw.TextSpan(
                        text: 'Distance BC: ',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: '${widget.distBC} metres\n',
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColor.fromInt(Colors.blue.value))),
                    pw.TextSpan(
                        text: 'Distance AC: ',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.TextSpan(
                        text: '${widget.distAC} metres',
                        style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColor.fromInt(Colors.blue.value))),
                  ])),
                ])),
      ])),
    ));

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Printing.layoutPdf(onLayout: generatePdf);
            },
          ),
        ],
      ),
      // the view window
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              // height: 5,
              child: Text(
                'Angles.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              // color: Colors.amber,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.green, width: 3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [anglePAB, angleABC, angleAPB, angleBPC],
              ),
            ),
            SizedBox(
              // height: 5,
              child: Text(
                'Bearings.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.green, width: 3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  brgAB,
                  brgBC,
                  brgAC,
                  backBrngAB,
                  BackBrngBC,
                  BackBrngAC,
                ],
              ),
            ),
            SizedBox(
              // height: 5,
              child: Text(
                'Distances.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.green, width: 3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [distAB, distBC, distAC],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
