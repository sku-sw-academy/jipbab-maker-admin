import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/provider/adminprovider.dart';

class FAQForm extends StatefulWidget {
  final Map<String, dynamic>? faq;

  FAQForm({this.faq});

  @override
  _FAQFormState createState() => _FAQFormState();
}

class _FAQFormState extends State<FAQForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // 수정 모드인 경우, 기존 FAQ 정보를 폼 필드에 채워 넣기
    if (widget.faq != null) {
      _isEditing = true;
      _titleController.text = widget.faq!['title'] ?? '';
      _contentController.text = widget.faq!['content'] ?? '';
    }
  }

  Future<void> _sendData(String id, String title, String content) async {
    final url = Uri.parse('${Constants.baseUrl}/faq/${_isEditing ? 'update' : 'save'}');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'id': id,
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode != 200) {
      print('Failed to send data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to send data');
    }
  }

  void _handleSubmit() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (adminProvider.admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("관리자 정보가 없습니다. 다시 로그인해주세요."),
        ),
      );
      return;
    }

    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      try {
        await _sendData(
          _isEditing ? widget.faq!["id"].toString() : adminProvider.admin!.id.toString(),
          _titleController.text,
          _contentController.text,
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("완료"),
              content: Text("${_isEditing ? '수정' : '작성'}이 완료되었습니다."),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("데이터 전송에 실패했습니다. 다시 시도해주세요."),
          ),
        );
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("제목과 내용을 모두 입력해주세요."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'FAQ 수정' : 'FAQ 작성'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "제목",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "내용",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(_isEditing ? "수정 완료" : "작성 완료"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide(color: Colors.grey, width: 1),
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
