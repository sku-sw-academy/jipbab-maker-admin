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
  List<Map<String, dynamic>> notices = []; // Notice 목록을 저장하는 리스트
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

  void _navigateToNoticeForm() {
    // Notice 작성 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeForm()),
    ).then((_) {
      // Notice 작성 폼에서 돌아온 후 Notice 목록을 다시 불러오기
      _fetchNotices();
    });
  }

  void _navigateToNoticeFormWithEdit(Map<String, dynamic> notice) {
    // 수정하는 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeForm(notice: notice)),
    ).then((_) {
      // Notice 폼에서 돌아온 후 Notice 목록을 다시 불러오기
      _fetchNotices();
    });
  }

  Future<void> _deleteNotice(Map<String, dynamic> notice) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/notice/delete');
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'adminId': notice['adminDTO']['id'], // Notice 객체 안의 사용자 ID 전송
          'noticeId': notice['id'], // Notice 객체의 ID 전송
        }),
      );

      if (response.statusCode == 200) {
        // Notice 삭제 성공 시 알림 표시 및 Notice 목록 다시 불러오기
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

  void _navigateToNoticeDetail(Map<String, dynamic> notice) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticeDetailPage(notice: notice)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notices.isEmpty
          ? Center(
        child: Text(
          '공지사항이 없습니다.',
          style: TextStyle(fontSize: 20),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.lightBlueAccent),
              border: TableBorder.all(
                width: 1.0,
              ),
              columns: [
                DataColumn(
                    label: Text('작성자', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('제목', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('게시일', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('수정', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('삭제', textAlign: TextAlign.center)),
              ],
              rows: notices.map((notice) {
                return DataRow(cells: [
                  DataCell(
                    Text(notice['adminDTO']['name']),
                    onTap: () => _navigateToNoticeDetail(notice),
                  ),
                  DataCell(
                    Text(notice['title'] ?? ''),
                    onTap: () => _navigateToNoticeDetail(notice),
                  ),
                  DataCell(
                    Text(notice['modifyDate']
                        .toString()
                        .substring(0, 19)
                        .replaceAll("T", " ") ??
                        ''),
                    onTap: () => _navigateToNoticeDetail(notice),
                  ),
                  if (notice['adminDTO']['id'] == currentAdminId)
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // 수정 버튼을 눌렀을 때 처리할 작업
                          _navigateToNoticeFormWithEdit(notice);
                        },
                      ),
                    )
                  else
                    DataCell(Text('')),
                  if (notice['adminDTO']['id'] == currentAdminId)
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // 삭제 버튼을 눌렀을 때 처리할 작업
                          _deleteNotice(notice);
                        },
                      ),
                    )
                  else
                    DataCell(Text('')),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNoticeForm,
        backgroundColor: Colors.white, // Example background color
        foregroundColor: Colors.black, // "등록하기" 버튼 클릭 시 처리할 작업
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
        title: Text('내용'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice['title'] ?? '',
              style: TextStyle(fontSize: 20),
            ),
            Text('작성자: ${notice['adminDTO']['name'] ?? ''}'),
            SizedBox(height: 10),
            Text(notice['content'] ?? ''),
          ],
        ),
      ),
    );
  }
}
