import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'dart:convert';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/api/log/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> logsList = json.decode(responseBody);
        setState(() {
          logs = logsList.map((log) => log as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load logs');
      }
    } catch (e) {
      print('Error fetching logs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("log 목록을 불러오는 데 실패했습니다."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: logs.isEmpty
          ? Center(child: Text('No data found'))
          : Scrollbar(
            child: _buildTableView(),
      ),
    );
  }

  Widget _buildTableView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return Card(
      margin: EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Rectangular shape
      ),
      child: TableView.builder(
        columnCount: 3,
        rowCount: logs.length + 1,
        pinnedRowCount: 1,
        columnBuilder: (index) {
          return TableSpan(
            foregroundDecoration: index == 0 ? decoration : null,
            extent: FractionalTableSpanExtent(1 / 3),
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
          TextStyle textStyle = const TextStyle();

          if (isStickyHeader) {
            switch (vicinity.xIndex) {
              case 0:
                label = '이름';
                break;
              case 1:
                label = '내용';
                break;
              case 2:
                label = '시간';
                break;
            }
          } else {
            final log = logs[vicinity.yIndex - 1];
            switch (vicinity.xIndex) {
              case 0:
                label = log['adminDTO']["name"];
                break;
              case 1:
                label = log['content'];
                break;
              case 2:
                label = log['modifyDate'].toString().substring(0, 19).replaceAll("T", " ");
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
    );
  }
}
