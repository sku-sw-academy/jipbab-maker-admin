import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/admin/NoticeForm.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  List<Map<String, dynamic>> notices = []; // FAQ 목록을 저장하는 리스트
  int? currentAdminId;
  late AdminDTO? admin;

  @override
  void initState() {
    super.initState();
    admin = Provider.of<AdminProvider>(context, listen: false).admin;
    currentAdminId = admin!.id;
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/notice/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> noticesList = json.decode(responseBody);
        setState(() {
          notices = noticesList.map((notice) => notice as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load Notices');
      }
    } catch (e) {
      print('Error fetching Notices: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("공지사항 목록을 불러오는 데 실패했습니다."),
        ),
      );
    }
  }

  void _navigateToFAQForm() {
    // FAQ 작성 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeForm()),
    ).then((_) {
      // FAQ 작성 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
      _fetchNotices();
    });
  }

  void _navigateToFAQFormWithEdit(Map<String, dynamic> notice) {
    // 수정하는 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeForm(notice: notice)),
    ).then((_) {
      // FAQ 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
      _fetchNotices();
    });
  }

  Future<void> _deleteFAQ(Map<String, dynamic> notice) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/notice/delete');
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'adminId': notice['adminDTO']['id'], // FAQ 객체 안의 사용자 ID 전송
          'noticeId': notice['id'], // FAQ 객체의 ID 전송
        }),
      );

      if (response.statusCode == 200) {
        // FAQ 삭제 성공 시 알림 표시 및 FAQ 목록 다시 불러오기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("공지사항이 삭제되었습니다."),
          ),
        );
        _fetchNotices();
      } else {
        throw Exception('Failed to delete Notice');
      }
    } catch (e) {
      print('Error deleting Notice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("공지사항 삭제 중 오류가 발생했습니다."),
        ),
      );
    }
  }

  void _navigateToFAQDetail(Map<String, dynamic> notice) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeDetailPage(notice: notice)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return GestureDetector(
                  onTap: () => _navigateToFAQDetail(notice),
                  child: ListTile(
                    title: Text(notice['title'] ?? ''), // FAQ 제목 표시
                    subtitle: Text(notice['modifyDate'].toString().substring(0, 19).replaceAll("T", " ") ?? ''), // FAQ 내용 표시
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (notice['adminDTO']['id'] == currentAdminId)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // 수정 버튼을 눌렀을 때 처리할 작업
                              _navigateToFAQFormWithEdit(notice);
                            },
                          ),
                        if (notice['adminDTO']['id'] == currentAdminId)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // 삭제 버튼을 눌렀을 때 처리할 작업
                              _deleteFAQ(notice);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFAQForm,
        backgroundColor: Colors.white, // Example background color
        foregroundColor: Colors.black,// "등록하기" 버튼 클릭 시 처리할 작업
        child: Icon(Icons.add),
      ),
    );
  }
}


class NoticeDetailPage extends StatelessWidget {
  final Map<String, dynamic> notice;

  NoticeDetailPage({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Notice Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice['title'] ?? '', style: TextStyle(fontSize: 20),),
            Text('작성자: ${notice['adminDTO']['name'] ?? ''}'),
            SizedBox(height: 10),
            Text(notice['content'] ?? ''),
          ],
        ),
      ),
    );
  }
}