import 'package:flutter/material.dart';
import 'package:flutter_admin/secure_storage/secure_service.dart';
import 'package:flutter_admin/provider/adminprovider.dart';
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin/admin/signout.dart';
import 'package:flutter_admin/admin/usermanagement.dart';
import 'package:flutter_admin/admin/admin.dart';

void main() {
  runApp(MyAppDesktop());
}

class MyAppDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureService>(create: (_) => SecureService()),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,

        ),
        home: FutureBuilder<bool>(
          future: _isAdminLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터를 기다리는 동안 로딩 표시를 표시할 수 있습니다.
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                // 에러가 발생한 경우 처리할 수 있습니다.
                return Center(child: Text('Error occurred'));
              } else {
                // 토큰의 존재 여부에 따라 페이지를 결정합니다.
                if (snapshot.data!) {
                  return AdminPage();
                } else {
                  return LoginAdminPage();
                }
              }
            }
          },
        ),
      ),
    );
  }

  // 관리자가 로그인되어 있는지 확인하는 비동기 함수
  Future<bool> _isAdminLoggedIn() async {
    final storageService = SecureService();
    String? token = await storageService.readToken("accessToken");
    return token != null && token.isNotEmpty;
  }
}



