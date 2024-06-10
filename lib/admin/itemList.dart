import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_admin/constant.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_admin/dto/ItemDTO.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';
import 'package:flutter_admin/provider/adminprovider.dart';

class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<ItemDTO> items = [];
  bool isLoading = true;
  XFile? _image;
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();
  int? selectedCode;
  int? currentAdminId;
  late AdminDTO? admin;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/items/list'));

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> itemList = json.decode(responseBody);
      setState(() {
        items = itemList.map((data) => ItemDTO.fromJson(data)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    admin = Provider.of<AdminProvider>(context, listen: false).admin;
    currentAdminId = admin!.id;
    fetchData();
  }

  Future<void> getImage(int code, ImageSource imageSource) async{
    try{
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if(pickedFile != null){
        _image = XFile(pickedFile.path);
        selectedCode = code;
        cropImage();
      }
    }catch(e){
      print(e);
    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기/회전하기',
            toolbarColor: Colors.grey[100],
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '이미지 자르기/회전하기',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          uploadImage(selectedCode!, croppedFile);
        });
      }
    }
  }

  Future uploadImage(int code, CroppedFile imageFile) async {
    var url = Uri.parse('${Constants.baseUrl}/items/upload');
    var request = http.MultipartRequest('POST', url);
    request.fields['item_code'] = code.toString(); // 사용자 ID 추가
    request.fields['id'] = currentAdminId.toString();
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      String image = await response.stream.bytesToString();
      print('Image: $image');
      setState(() {
         // 서버에서 받은 이미지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지가 업로드 되었습니다.')),
        );
      });
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(child: Text('품목이 없습니다'))
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
            child: Center(child:
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent),
                border: TableBorder.all(
                  width: 1.0,),
              columns: [
                DataColumn(label: Expanded(child: Text('카테고리', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('품목명', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('검색수', textAlign: TextAlign.center))),
                DataColumn(label: Expanded(child: Text('이미지 업로드', textAlign: TextAlign.center))),
              ],
              rows: items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.category.categoryName, textAlign: TextAlign.center,)),
                    DataCell(Text(item.itemName, textAlign: TextAlign.center,)),
                    DataCell(Text(item.count.toString(), textAlign: TextAlign.center,)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          getImage(item.itemCode, ImageSource.gallery);
                        },
                        child: Text('Upload'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // 원하는 모양의 border radius 설정
                          ),
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

}