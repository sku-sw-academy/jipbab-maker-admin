import 'package:flutter/material.dart';
import 'package:flutter_admin/admin/qna/answer.dart'; // AnswerPage의 경로에 맞게 수정하세요.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';
import 'package:flutter_admin/admin/qna/updateAnswer.dart';

class AnswerListPage extends StatefulWidget {
  @override
  _AnswerListState createState() => _AnswerListState();
}

class _AnswerListState extends State<AnswerListPage> {
  List<Map<String, dynamic>> answers = [];
  bool isLoading = true;
  int? currentAdminId;
  late AdminDTO? admin;

  @override
  void initState() {
    super.initState();
    admin = Provider.of<AdminProvider>(context, listen: false).admin;
    currentAdminId = admin!.id;
    _fetchAnswers();
  }

  Future<void> _fetchAnswers() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/answer/all/$currentAdminId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> answersList = json.decode(responseBody);
        setState(() {
          answers = answersList.map((answer) => answer as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Answer');
      }
    } catch (e) {
      print('Error fetching Answers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("답변 목록을 불러오는 데 실패했습니다."),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAnswer(int id) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/answer/delete/$id');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("답변이 삭제되었습니다."),
          ),
        );
        _fetchAnswers(); // 목록을 새로 고침
      } else {
        throw Exception('Failed to delete Answer');
      }
    } catch (e) {
      print('Error deleting Answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("답변을 삭제하는 데 실패했습니다."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : answers.isEmpty
          ? Center(
        child: Text(
          "답변 목록이 비어있습니다.",
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
              border: TableBorder.all(width: 1.0),
              columns: [
                DataColumn(label: Expanded(child: Text('이름', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('제목', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('날짜', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('수정', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('삭제', textAlign: TextAlign.center))),
              ],
              rows: answers.map((answer) {
                return DataRow(cells: [
                  DataCell(Text(answer['admin']['name'] ?? '', textAlign: TextAlign.center)),
                  DataCell(Text(answer['question']["title"] ?? '', textAlign: TextAlign.center)),
                  DataCell(Text(answer['modifyDate'].toString().substring(0, 10) ?? '', textAlign: TextAlign.center)),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswerUpdatePage(question: answer['question'], adminId: currentAdminId!),
                          ),
                        ).then((_) {
                          _fetchAnswers();
                        });
                      },
                      child: Text('수정'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        _deleteAnswer(answer['id']);
                      },
                      child: Text('삭제'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Colors.white,
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
