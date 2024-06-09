import 'package:flutter/material.dart';
import 'package:flutter_admin/admin/qna/question.dart';
import 'package:flutter_admin/admin/qna/answerList.dart';

class TabBarPage extends StatefulWidget {
  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '질문'),
              Tab(text: '답변'),
            ],
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                QuestionPage(),
                AnswerListPage() // 예시로 다른 페이지 추가
              ],
            ),
          ),
        ],
      ),
    );
  }
}