import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DriverDataScreen extends StatefulWidget {
  final List<List<dynamic>> excelData;
  final String driverCode;
  final double profitPercentage;

  final String name;
  late int x;
  final int numbercode;

  final excel;
  int? totalIndex;
  int? cartIndex;
  int? nolonIndex;
  int? tasrehDateIndex;
  int? customerIndex;
  int? driverNameIndex;
  double? ahda;
  double? safy;

  DriverDataScreen(
      {required this.excelData,
      required this.driverCode,
      required this.profitPercentage,
      required this.name,
      required this.numbercode,
      this.excel});

  @override
  _DriverDataScreenState createState() => _DriverDataScreenState();
}

class _DriverDataScreenState extends State<DriverDataScreen> {
  List<Map<String, dynamic>> driverRecords = [];
  Map<int, double> allowances = {}; // لتخزين العهدة لكل صف

  @override
  void initState() {
    super.initState();
    done();

    loadDriverData();
  }

  void loadDriverData() {
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    print(widget.excelData.length);
    double allTotal = 0;
    double allnolon = 0;
    double allkarta = 0;
    double allsafy = 0;
    double allahda = 0;

    int w = 1;
    for (int x = 2; x < widget.excelData.length - 1; x++) {
      var row = widget.excelData[x];
      int length = widget.excelData[x].length;
      for (int i = 0; i < 1; i++) {
        print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

        if (row[widget.numbercode] == widget.driverCode) {
          print('cccccccccccccccccccccccccccccccccccc');
          print(row[widget.numbercode]);

          double freight =
              double.tryParse(row[widget.cartIndex!].toString()) ?? 0;
          double cartage =
              (double.tryParse(row[widget.nolonIndex!].toString()) ??
                  0); // تخفيض 20%
          double total = double.parse(row[widget.totalIndex!].toString()) ?? 0;

          if (total == 0) {
            total = 0;
          } else {
            total = total - freight;
            total = total * (100 - widget.profitPercentage) / 100;
            total = total + freight;
          }

          driverRecords.add({
            'serial': (w++),
            'driverCode': row[widget.numbercode],
            'driverName': row[widget.driverNameIndex!],
            'date': row[widget.tasrehDateIndex!].toString().split('T')[0],
            'destination': row[widget.customerIndex!],
            'cartage': cartage,
            'freight': freight,
            'total': total,
            'allowance': 0,
            'net': total,
          });

          allTotal = allTotal + total;
          allkarta += freight;
          allnolon += cartage;
        } else {
          continue;
        }
      }
    }

    print(allTotal);
    print(allnolon);
    print(allkarta);
  }

  void done() {
    var sheet = widget.excel.tables[widget.excel.tables.keys.first];

    var secondRow = sheet?.rows[1];
    if (secondRow != null) {
      for (var i = 0; i < secondRow.length; i++) {
        var cellValue = secondRow[i]?.value.toString();
        if (cellValue == 'إجمالى') {
          widget.totalIndex = i;
        } else if (cellValue == 'كارتات') {
          widget.cartIndex = i;
        } else if (cellValue == 'نولون') {
          widget.nolonIndex = i;
        } else if (cellValue == 'Tasreh date') {
          widget.tasrehDateIndex = i;
        } else if (cellValue == 'عميل التحميل') {
          widget.customerIndex = i;
        } else if (cellValue == 'Driver Name') {
          widget.driverNameIndex = i;
        }
      }
    }
  }

  void generateAndSharePDF() async {
    double totalFreight =
        driverRecords.fold(0, (sum, record) => sum + (record['freight'] ?? 0));
    double totalCartage =
        driverRecords.fold(0, (sum, record) => sum + (record['cartage'] ?? 0));
    double totalAllowance = driverRecords.fold(
        0, (sum, record) => sum + (record['allowance'] ?? 0));
    double totalNet =
        driverRecords.fold(0, (sum, record) => sum + (record['net'] ?? 0));
    double grandTotal =
        driverRecords.fold(0, (sum, record) => sum + (record['total'] ?? 0));
    final pdf = pw.Document();

    // إنشاء محتوى PDF

    final amiri = pw.Font.ttf(
        await rootBundle.load('lib/assets/fonts/Amiri/Amiri-Regular.ttf'));
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // العنوان الرئيسي
          pw.Center(
              child: pw.Container(
            padding: pw.EdgeInsets.all(10),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('بيانات السائق ${widget.name}',
                style: pw.TextStyle(
                  font: amiri,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
                textDirection: pw.TextDirection.rtl),
          )),
          pw.SizedBox(height: 20),

          // جدول البيانات
          pw.Table.fromTextArray(
            columnWidths: const {
              0: pw.FixedColumnWidth(10),
              1: pw.FixedColumnWidth(20),
              2: pw.FixedColumnWidth(40),
              3: pw.FixedColumnWidth(35),
              4: pw.FixedColumnWidth(30),
              5: pw.FixedColumnWidth(20),
              6: pw.FixedColumnWidth(20),
              7: pw.FixedColumnWidth(20), // العهد
              9: pw.FixedColumnWidth(20), // الصافي
            },
            headers: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('N',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('كود السائق ',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('اسم السائق',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('التاريخ',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('الوجهة',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('النولون',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('الكارتة',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('الإجمالي',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('العهدة',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('الصافي',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
            ],
            data: driverRecords.map((record) {
              return [
                record['serial'].toString(),
                record['driverCode'].toString(),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(record['driverName'].toString(),
                      style: pw.TextStyle(
                        font: amiri,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textDirection: pw.TextDirection.rtl),
                ),
                record['date'].toString(),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(record['destination'].toString(),
                      style: pw.TextStyle(
                        font: amiri,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textDirection: pw.TextDirection.rtl),
                ),
                record['cartage'].toString(),
                record['freight'].toString(),
                record['total'].toString(),
                record['allowance'].toString(),
                record['net'].toString(),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(color: PdfColors.grey),
          ),

          pw.SizedBox(height: 20),

          // جدول الإجماليات
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('الاجماليات',
                style: pw.TextStyle(
                  font: amiri,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
                textDirection: pw.TextDirection.rtl),
          ),
          pw.Table.fromTextArray(
            headers: [
              pw.Container(
                padding: pw.EdgeInsets.all(3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('مجموع الإجمالي',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('إجمالي النولون',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('إجمالي الكارتة',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('إجمالي العهدة',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('إجمالي الصافي',
                    style: pw.TextStyle(
                      font: amiri,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    textDirection: pw.TextDirection.rtl),
              ),
            ],
            data: [
              [
                grandTotal.toStringAsFixed(2),
                totalCartage.toStringAsFixed(2),
                totalFreight.toStringAsFixed(2),
                totalAllowance.toStringAsFixed(2),
                totalNet.toStringAsFixed(2),
              ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(color: PdfColors.grey),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    // final filePath = "${output.path}\\driver_data.pdf";  //for win
    final filePath = "${output.path}/driver_data.pdf"; //for android
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'xxxxx',
    );
  }

  void updateNet(int index, double allowance) {
    setState(() {
      driverRecords[index]['allowance'] = allowance;
      driverRecords[index]['net'] = driverRecords[index]['total'] - allowance;
      widget.safy = driverRecords[index]['net'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalFreight =
        driverRecords.fold(0, (sum, record) => sum + (record['freight'] ?? 0));
    double totalCartage =
        driverRecords.fold(0, (sum, record) => sum + (record['cartage'] ?? 0));
    double totalAllowance = driverRecords.fold(
        0, (sum, record) => sum + (record['allowance'] ?? 0));
    double totalNet =
        driverRecords.fold(0, (sum, record) => sum + (record['net'] ?? 0));
    double grandTotal =
        driverRecords.fold(0, (sum, record) => sum + (record['total'] ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text('بيانات السائق ${widget.name}'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // الجدول الأول
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('المسلسل')),
                    DataColumn(label: Text('كود السائق')),
                    DataColumn(label: Text('           اسم السائق')),
                    DataColumn(label: Text('     التاريخ')),
                    DataColumn(label: Text('         الوجهة')),
                    DataColumn(label: Text(' النولون')),
                    DataColumn(label: Text('الكارتة')),
                    DataColumn(label: Text('الإجمالي')),
                    DataColumn(label: Text('العهدة')),
                    DataColumn(label: Text('الصافي')),
                  ],
                  rows: List<DataRow>.generate(
                    driverRecords.length,
                    (index) {
                      final record = driverRecords[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(record['serial'].toString())),
                          DataCell(Text(record['driverCode'].toString())),
                          DataCell(
                              Text('    ${record['driverName'].toString()}')),
                          DataCell(Text(record['date'].toString())),
                          DataCell(Text(record['destination'].toString())),
                          DataCell(Text('    ${record['cartage'].toString()}')),
                          DataCell(Text(record['freight'].toString())),
                          DataCell(Text(record['total'].toString())),
                          DataCell(
                            TextFormField(
                              initialValue: record['allowance'].toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                double allowance = double.tryParse(value) ?? 0;
                                setState(() {
                                  driverRecords[index]['allowance'] = allowance;
                                  updateNet(index, allowance);
                                });
                              },
                            ),
                          ),
                          DataCell(Text(record['net'].toString())),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const Center(
                child: Text(
              "الاجماليات",
              style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            )),

            // الجدول الثاني (الملخص)
            Padding(
              padding: const EdgeInsets.all(50),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('مجموع الإجمالي')),
                  DataColumn(label: Text('إجمالي النولون')),
                  DataColumn(label: Text('إجمالي الكارتة')),
                  DataColumn(label: Text('إجمالي العهدة')),
                  DataColumn(label: Text('إجمالي الصافي')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(grandTotal.toStringAsFixed(2))),
                      DataCell(Text(totalCartage.toStringAsFixed(2))),
                      DataCell(Text(totalFreight.toStringAsFixed(2))),
                      DataCell(Text(totalAllowance.toStringAsFixed(2))),
                      DataCell(Text(totalNet.toStringAsFixed(2))),
                    ],
                  ),
                ],
              ),
            ),

            // زر مشاركة PDF
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  generateAndSharePDF();
                },
                child: Text('مشاركة كـ PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
