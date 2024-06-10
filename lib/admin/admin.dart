import 'package:flutter/material.dart';
import 'package:flutter_admin/admin/signout.dart';
import 'package:flutter_admin/admin/usermanagement.dart';
import 'package:flutter_admin/constant.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/dto/AuthLogoutRequest.dart';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/secure_storage/secure_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin/admin/faq.dart';
import 'package:flutter_admin/admin/notice.dart';
import 'package:flutter_admin/admin/log.dart';
import 'package:flutter_admin/admin/qna/qna.dart';
import 'package:flutter_admin/admin/itemList.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final SecureService _secureService = SecureService();
  late AdminDTO? admin;

  final List<Widget> _pages = [
    UserManagementPage(),
    ItemPage(),  // 예제용 설정 페이지
    FAQPage(),
    TabBarPage(),
    NoticePage(),
    Text('레시피 목록'),
    LogPage(),
  ];

  Future<void> logout(AuthLogoutRequest request) async {
    final url = Uri.parse('${Constants.baseUrl}/api/admin/logout');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'id': request.id,
      'refresh_token': request.refreshToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // 로그아웃 성공
        print('로그아웃 성공');
      } else {
        // 로그아웃 실패
        print('로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류
      print('네트워크 오류: $e');
    }
  }

  Future<void> _initializeAdmin() async {
    await Provider.of<AdminProvider>(context, listen: false).initializeAdmin();
    setState(() {
      admin = Provider.of<AdminProvider>(context, listen: false).admin;
      print(admin!.id);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();  // Drawer를 닫기 위해
  }

  @override
  void initState() {
    super.initState();
    _initializeAdmin();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('관리자 페이지'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                String? token = await _secureService.readToken("refreshToken");
                print(token);
                print(admin);
                final authlogoutRequest = AuthLogoutRequest(id: admin!.id, refreshToken: token!);
                logout(authlogoutRequest);
                await _secureService.deleteToken("accessToken");
                await _secureService.deleteToken("refreshToken");
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginAdminPage()));
              }
            },
            itemBuilder: (BuildContext context) {
              return {'logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text('Logout'),
                );
              }).toList();
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('사용자'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: Text('식재료'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text('FAQ'),
              onTap: () => _onItemTapped(2),
            ),ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('답변'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.speaker_notes),
              title: Text('공지사항'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('레시피 목록'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.timelapse),
              title: Text('로그'),
              onTap: () => _onItemTapped(6),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

