import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:nnn/screens/showSheetAnd%20Share.dart';

class DriversTablePage extends StatelessWidget {
  final File file;
  final double profitPercentage;
  final List<List<dynamic>> data;
  final excel;

  late int driveID;
  late int driveName;
  late List driverCodeCount = [];
  late List drivercode = [];
  late List nameOnly = [];

  DriversTablePage({
    super.key,
    required this.file,
    required this.profitPercentage,
    required this.data,
    this.excel,
  })

  //////////////////////تشغيل دول الى انشاتها عشان اجهز الصفحه التانيه

  {
    findDriverColumns();

    colomSevenFreqwansy();
    removeDuplicateNames();
  }
////////////////////////////////////// // حساب و استخراج  تكرار الأرقام في العمود السابع
  void colomSevenFreqwansy() {
    List<dynamic> columnSeven = [];
    for (int i = 2; i < data.length - 1; i++) {
      columnSeven.add(data[i][driveID]);
    }

    Map<dynamic, dynamic> frequencyMap = {};
    for (var number in columnSeven) {
      if (frequencyMap.containsKey(number)) {
        frequencyMap[number] = frequencyMap[number]! + 1;
      } else {
        frequencyMap[number] = 1;
      }
    }

    // عرض الأرقام وتكرارها

    frequencyMap.forEach((number, count) {
      drivercode.add(number);
      driverCodeCount.add(count);
    });
  }

  ////////////////////////////    مسح التكرارات من الاسماء

  void removeDuplicateNames() {
    Set<String> seenNames = {};
    List<List<dynamic>> excelOnly = [];

    // نبدأ من الصف 2 (المؤشر 2)
    for (int i = 2; i < data.length; i++) {
      var row = data[i];
      String name = row[driveName]; // العمود السابع (المؤشر 6) يمثل الاسم
      if (!seenNames.contains(name)) {
        seenNames.add(name);
        excelOnly.add(row);
        nameOnly.add(row[driveName]);
      }
    }
  }

//////////////////////////////////////////////// تجديد مكان الاعمده
  void findDriverColumns() {
    // البحث عن أعمدة 'Driver Code' و 'Driver Name' في الصف الأول
    String targetWord1 = 'Driver Code';
    String targetWord2 = 'Driver Name';

    bool found = false;
    bool found2 = false;
    print('0000000000000000000000000000000000000000000000000000');
    print(data[1][2]);

    for (int col = 0; col < data[1].length; col++) {
      if (data[1][col] == targetWord1) {
        driveID = col;
        found = true;
      }
      if (data[1][col] == targetWord2) {
        driveName = col;
        found2 = true;
      }
    }

    if (!found) {
      print("لم يتم العثور على كود السائق في الصف الأول.");
    }
    if (!found2) {
      print("لم يتم العثور على اسم السائق في الصف الأول.");
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // هنا يتم ترتيب البيانات حسب عدد مرات العمل (يمكنك تعديل هذه الجزء حسب الحاجة)

    return Scaffold(
      appBar: AppBar(
        title: Text('جدول السائقين وعدد مرات العمل'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('عدد مرات العمل')),
            DataColumn(label: Text('اسم السائق')),
            DataColumn(label: Text('كود السائق')),
            DataColumn(label: Text('المسلسل')),
            DataColumn(label: Text('عرض السجل')),
          ],
          rows: List.generate(drivercode.length - 1, (index) {
            return DataRow(cells: [
              DataCell(Text(driverCodeCount[index].toString())),
              DataCell(Text(nameOnly[index] ?? '--')),
              DataCell(Text(drivercode[index])),
              DataCell(Text((index + 1).toString())),
              DataCell(IconButton(
                icon: Icon(Icons.start),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DriverDataScreen(
                      excel: excel,
                      numbercode: driveID,
                      driverCode: drivercode[index],
                      excelData: data,
                      profitPercentage: profitPercentage,
                      name: nameOnly[index],
                    );
                  }));
                },
              )), // عدد مرات العمل
            ]);
          }),
        ),
      ),
    );
  }
}
