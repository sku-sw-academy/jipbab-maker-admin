import 'package:flutter/material.dart';
import 'package:flutter_admin/admin/qna/answer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';
import 'package:flutter_admin/admin/qna/detail.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = []; // FAQ 목록을 저장하는 리스트
  int? currentAdminId;
  late AdminDTO? admin;
  bool isLoading = true; // 로딩 상태를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    admin = Provider.of<AdminProvider>(context, listen: false).admin;
    currentAdminId = admin!.id;
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/question/all/false');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> questionsList = json.decode(responseBody);
        setState(() {
          questions = questionsList.map((question) => question as Map<String, dynamic>).toList();
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        throw Exception('Failed to load Questions');
      }
    } catch (e) {
      print('Error fetching Questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("질문 목록을 불러오는 데 실패했습니다."),
        ),
      );
      setState(() {
        isLoading = false; // 데이터 로딩 실패
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : questions.isEmpty
          ? Center(
            child: Text(
          "질문 목록이 비어있습니다.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent),
              border: TableBorder.all(
              width: 1.0,),

              columns: [
                DataColumn(label: Expanded(child: Text('이메일', textAlign: TextAlign.center),)),
                DataColumn(label: Expanded(child: Text('제목', textAlign: TextAlign.center),)),
                DataColumn(label: Expanded(child: Text('날짜', textAlign: TextAlign.center),)),
                DataColumn(label: Expanded(child: Text('답변', textAlign: TextAlign.center),)),
              ],
              rows: questions.map((question) {
                return DataRow(cells: [
                  DataCell(Text(question['userDTO']['email'] ?? '',textAlign: TextAlign.center)),
                  DataCell(Text(question['title'] ?? '', textAlign: TextAlign.center)),
                  DataCell(Text(question['modifyDate'].toString().substring(0,10) ?? '', textAlign: TextAlign.center)),
                  DataCell(
                    question['deletedAt'] == null
                        ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnswerPage(question: question, adminId: currentAdminId!)),
                        ).then((_) {
                          // FAQ 작성 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
                          _fetchQuestions();
                        });
                      },
                      child: Text('답변'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // 원하는 모양의 border radius 설정
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContentPage(question: question)),
                        ).then((_) {
                          // FAQ 작성 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
                          _fetchQuestions();
                        });
                      },
                          child: Text('삭제됨'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // 원하는 모양의 border radius 설정
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
