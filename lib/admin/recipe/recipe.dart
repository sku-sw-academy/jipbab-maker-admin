import 'package:flutter/material.dart';
import 'package:flutter_admin/admin/recipe/recipeDetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_admin/constant.dart';
import 'package:flutter_admin/dto/RecipeDTO.dart';

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<RecipeDTO>> recipeList;

  @override
  void initState() {
    super.initState();
    recipeList = fetchRecipes();
  }

  Future<List<RecipeDTO>> fetchRecipes() async {
    final response =
    await http.get(Uri.parse('${Constants.baseUrl}/recipe/listAll'));

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      List jsonResponse = json.decode(responseBody);
      return jsonResponse.map((data) => RecipeDTO.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<void> updateRecipeShareStatus(int id) async {
    final response = await http
        .put(Uri.parse('${Constants.baseUrl}/recipe/status/$id'));

    if (response.statusCode == 200) {
      print('Recipe status updated successfully.');
    } else {
      throw Exception('Failed to update recipe status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<List<RecipeDTO>>(
          future: recipeList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load recipes'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No recipes found'));
            } else {
              return Center(
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent),
                  border: TableBorder.all(
                    width: 1.0,),
                  columns: [
                    DataColumn(label: Expanded(child:Text('제목', textAlign: TextAlign.center,))),
                    DataColumn(label: Expanded(child:Text('상태', textAlign: TextAlign.center,))),
                    DataColumn(label: Expanded(child:Text('삭제', textAlign: TextAlign.center,))),
                    DataColumn(label: Expanded(child:Text('내용/공유', textAlign: TextAlign.center,))),
                  ],
                  rows: snapshot.data!.map((recipe) {
                    return DataRow(cells: [
                      DataCell(Text(recipe.title)),
                      DataCell(recipe.status
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.cancel, color: Colors.red)),
                      DataCell(
                          Text(recipe.deletedAt ? 'Yes' : 'No')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.content_paste),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailPage(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                            if (recipe.status)
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  updateRecipeShareStatus(recipe.id);
                                },
                              ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
