import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';

class AnswerUpdatePage extends StatefulWidget {
  final Map<String, dynamic> question;
  final int adminId;

  AnswerUpdatePage({required this.question, required this.adminId});

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerUpdatePage> {
  String answer = '';
  late Map<String, dynamic> answers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnswer();
  }

  Future<void> _fetchAnswer() async {
    try {
      final questionId = widget.question["id"];
      final url = Uri.parse('${Constants.baseUrl}/answer/question/$questionId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> answerData = json.decode(responseBody);
        setState(() {
          answer = answerData['content'] ?? '';
          answers = answerData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Answer');
      }
    } catch (e) {
      print('Error fetching Answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("답변을 불러오는 데 실패했습니다."),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('답변 수정'),
        scrolledUnderElevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
            Text(
              '답변 수정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                setState(() {
                  answer = value;
                });
              },
              maxLines: 3,
              enabled: false,
              controller: TextEditingController(text: answer),
              decoration: InputDecoration(
                hintText: '답변을 수정해주세요.',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
