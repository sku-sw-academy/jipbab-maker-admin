import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'dart:convert';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> users = [];

  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/api/auth/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> userList = json.decode(responseBody);
        setState(() {
          users = userList.map((user) => user as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("user 목록을 불러오는 데 실패했습니다."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // Rectangular shape
              ),
              child: Scrollbar(
                child: TableView.builder(
                  columnCount: 5,
                  rowCount: users.length + 1,
                  pinnedRowCount: 1,
                  pinnedColumnCount: 0,
                  columnBuilder: (index) {
                    double extent;
                    switch (index) {
                      case 0:
                      case 1:
                      case 2:
                        extent = 0.2; // equal width for ID, Name, Email
                        break;
                      case 3:
                        extent = 0.2; // equal width for Actions
                        break;
                      case 4:
                        extent = 0.2; // equal width for Actions
                        break;
                      default:
                        extent = 1 / 4;
                        break;
                    }
                    return TableSpan(
                      foregroundDecoration: index == 0 ? decoration : null,
                      extent: FractionalTableSpanExtent(extent),
                    );
                  },
                  rowBuilder: (index) {
                    return TableSpan(
                      foregroundDecoration: index == 0 ? decoration : null,
                      extent: FixedTableSpanExtent(50),
                    );
                  },
                  cellBuilder: (context, vicinity) {
                    final isStickyHeader = vicinity.yIndex == 0;
                    String label = '';
                    Widget content;
                    TextStyle textStyle = const TextStyle();

                    if (isStickyHeader) {
                      switch (vicinity.xIndex) {
                        case 0:
                          label = 'Email';
                          break;
                        case 1:
                          label = '닉네임';
                          break;
                        case 2:
                          label = '알림';
                          break;
                        case 3:
                          label = '활성화';
                          break;
                        case 4:
                          label = '로그인/로그아웃';
                          break;
                      }
                      content = Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      );
                    } else {
                      final user = users[vicinity.yIndex - 1];
                      switch (vicinity.xIndex) {
                        case 0:
                          label = user['email']!;
                          content = Text(label);
                          break;
                        case 1:
                          label = user['nickname']!;
                          content = Text(label);
                          break;
                        case 2:
                          label = user['push']!.toString();
                          content = Text(label);
                          break;
                        case 3:
                          label = user['enabled']!.toString();
                          content = Text(label);
                          break;
                        case 4:
                          label = user['log']!.toString();
                          content = Text(label);
                          break;
                      }
                    }

                    return TableViewCell(
                        child:Container(
                        decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                    ),
                      child: ColoredBox(
                        color: isStickyHeader ? Colors.transparent : colorScheme.background,
                        child: Center(
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                label,
                                style: isStickyHeader
                                    ? TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                )
                                    : textStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
