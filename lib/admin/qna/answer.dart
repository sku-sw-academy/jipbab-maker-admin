import 'package:flutter/material.dart';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'dart:convert';

class AnswerPage extends StatefulWidget {
  final Map<String, dynamic> question;
  final int adminId;

  AnswerPage({required this.question, required this.adminId});

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  String answer = '';

  Future<void> _sendAnswer() async {
    try {
      final questionId = widget.question["id"];
      final adminId = widget.adminId;

      if (questionId != null && adminId != null) {
        // questionId와 adminId가 모두 null이 아닌 경우에만 요청을 보냅니다.
        final url = Uri.parse('${Constants.baseUrl}/answer/send');
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'id': questionId.toString(), // 질문의 고유 ID
            'adminId': adminId.toString(), // 관리자의 고유 ID
            'content': answer, // 답변 내용
          },
        );
        if (response.statusCode == 200) {
          // 성공적으로 답변을 전송한 경우
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('답변이 성공적으로 전송되었습니다.'),
            ),
          );
          // 이전 화면으로 돌아가기
          Navigator.pop(context);
        } else {
          // 서버로부터 오류가 발생한 경우
          throw Exception('Failed to send answer');
        }
        // 나머지 코드는 여기에 있어야 합니다.
      } else {
        // questionId나 adminId 중 하나라도 null이면 오류 처리를 수행합니다.
        print('Question ID or Admin ID is null');
      }

    } catch (e) {
      // 예외 처리
      print('Error sending answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('답변을 전송하는 중에 오류가 발생했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('답변 작성'),
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
            Text(
              '답변 작성:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                setState(() {
                  answer = value;
                });
              },
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '답변을 작성해주세요.',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (answer.isNotEmpty) {
                  print(widget.question["id"]);
                  _sendAnswer();
                } else {
                  print(widget.question["id"]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('답변 내용을 작성해주세요.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 원하는 모양의 border radius 설정
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('보내기'),
            ),
          ],
        ),
      ),
    );
  }
}
