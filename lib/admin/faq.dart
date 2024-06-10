import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/admin/faqform.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<Map<String, dynamic>> faqs = []; // FAQ 목록을 저장하는 리스트
  int? currentAdminId;
  late AdminDTO? admin;

  @override
  void initState() {
    super.initState();
    admin = Provider.of<AdminProvider>(context, listen: false).admin;
    currentAdminId = admin!.id;
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/faq/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> faqList = json.decode(responseBody);
        setState(() {
          faqs = faqList.map((faq) => faq as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      print('Error fetching FAQs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("FAQ 목록을 불러오는 데 실패했습니다."),
        ),
      );
    }
  }

  void _navigateToFAQForm() {
    // FAQ 작성 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQForm()),
    ).then((_) {
      // FAQ 작성 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
      _fetchFAQs();
    });
  }

  void _navigateToFAQFormWithEdit(Map<String, dynamic> faq) {
    // 수정하는 폼으로 이동하는 함수
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQForm(faq: faq)),
    ).then((_) {
      // FAQ 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
      _fetchFAQs();
    });
  }

  Future<void> _deleteFAQ(Map<String, dynamic> faq) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/faq/delete');
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'adminId': faq['adminDTO']['id'], // FAQ 객체 안의 사용자 ID 전송
          'faqId': faq['id'], // FAQ 객체의 ID 전송
        }),
      );

      if (response.statusCode == 200) {
        // FAQ 삭제 성공 시 알림 표시 및 FAQ 목록 다시 불러오기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("FAQ가 삭제되었습니다."),
          ),
        );
        _fetchFAQs();
      } else {
        throw Exception('Failed to delete FAQ');
      }
    } catch (e) {
      print('Error deleting FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("FAQ 삭제 중 오류가 발생했습니다."),
        ),
      );
    }
  }

  void _navigateToFAQDetail(Map<String, dynamic> faq) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQDetailPage(faq: faq)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return GestureDetector(
                  onTap: () => _navigateToFAQDetail(faq),
                  child: ListTile(
                    title: Text(faq['title'] ?? ''), // FAQ 제목 표시
                    subtitle: Text(faq['modifyDate'].toString().substring(0, 19).replaceAll("T", " ") ?? ''), // FAQ 내용 표시
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (faq['adminDTO']['id'] == currentAdminId)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // 수정 버튼을 눌렀을 때 처리할 작업
                              _navigateToFAQFormWithEdit(faq);
                            },
                          ),
                        if (faq['adminDTO']['id'] == currentAdminId)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // 삭제 버튼을 눌렀을 때 처리할 작업
                              _deleteFAQ(faq);
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


class FAQDetailPage extends StatelessWidget {
  final Map<String, dynamic> faq;

  FAQDetailPage({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ Details'),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(faq['title'] ?? '', style: TextStyle(fontSize: 20),),
            Text('작성자: ${faq['adminDTO']['name'] ?? ''}'),
            SizedBox(height: 10),
            Text(faq['content'] ?? ''),
          ],
        ),
      ),
    );
  }
}