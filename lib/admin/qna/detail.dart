import 'package:flutter/material.dart';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'dart:convert';

class ContentPage extends StatefulWidget {
  final Map<String, dynamic> question;

  ContentPage({required this.question});

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('질문'),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              '질문 내용',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("${widget.question["content"]}", style: TextStyle(fontSize: 13)),

            SizedBox(height: 10),
            // 여기에 질문 내용을 표시하는 위젯 추가
          ],
        ),
      ),
    );
  }
}
