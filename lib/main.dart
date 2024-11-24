import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Use the FilePicker from the package
import 'package:nnn/screens/add_filePage.dart';
import 'package:nnn/screens/showCountJob.dart'; // Make sure this path is correct for your app

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FileUploadPage(),
    );
  }
}
