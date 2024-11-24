import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nnn/screens/showCountJob.dart';
import 'package:nnn/widgets/textEdit.dart';

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? excelFile;
  var excel;
  List<List<dynamic>> excelData = [];
  TextEditingController profitController = TextEditingController();

  Future<List<dynamic>> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'xml'],
    );

    if (result != null) {
      setState(() {
        excelFile = File(result.files.single.path!);
        excelData.clear(); // تفريغ البيانات القديمة
      });
    }

    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        for (var row in sheet!.rows) {
          List<dynamic> rowData = [];
          for (var cell in row) {
            rowData
                .add(cell?.value?.toString() ?? ''); // التعامل مع القيم الفارغة
          }
          excelData.add(rowData);
        }
      }

      if (excelData.isEmpty) {
        _showError(
            'لم يتم العثور على بيانات في الملف. تأكد من أن الملف يحتوي على بيانات.');
      }
    }
    return excelData;
  }

  void onNext() {
    if (excelFile != null && profitController.text.isNotEmpty) {
      double? profitPercentage = double.tryParse(profitController.text);
      if (profitPercentage != null &&
          profitPercentage >= 0 &&
          profitPercentage <= 100) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriversTablePage(
              file: excelFile!,
              profitPercentage: profitPercentage,
              data: excelData,
              excel: excel,
            ),
          ),
        );
      } else {
        _showError('الرجاء إدخال نسبة ربح صحيحة بين 0 و 100.');
      }
    } else {
      _showError('الرجاء تحميل الملف وإدخال نسبة الربح.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildDataPreview() {
    if (excelData.isEmpty) {
      return Center(child: Text('لم يتم تحميل بيانات '));
    }
    return Center(child: Text('تم تحميل بيانات '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تحميل الملف وإدخال نسبة الربح'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            GestureDetector(
              onTap: pickFile,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    excelFile == null
                        ? 'اضغط هنا لتحميل الملف (Excel أو XML)'
                        : 'تم تحميل الملف: ${excelFile!.path.split('/').last}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDataPreview(),
            const SizedBox(height: 60),
            ProfitInputField(controller: profitController),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: onNext,
                child: Text('التالي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
