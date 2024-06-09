import 'package:flutter_admin/dto/ItemDTO.dart';

class PriceDTO {
  final String id;
  final String name;
  final ItemDTO itemCode;
  final String kindName;
  final int kindCode;
  final String rankName;
  final int rankCode;
  final String unit;
  final String dpr1;
  final String dpr2;
  final String dpr3;
  final String dpr5;
  final String dpr6;
  final String dpr7;
  final String regday;
  final double value;
  final bool status;

  PriceDTO({
    required this.id,
    required this.name,
    required this.itemCode,
    required this.kindName,
    required this.kindCode,
    required this.rankName,
    required this.rankCode,
    required this.unit,
    required this.dpr1,
    required this.dpr2,
    required this.dpr3,
    required this.dpr5,
    required this.dpr6,
    required this.dpr7,
    required this.regday,
    required this.value,
    required this.status,
  });

  // JSON 데이터를 PriceDTO 객체로 변환하는 factory 메서드
  factory PriceDTO.fromJson(Map<String, dynamic> json) {
    return PriceDTO(
      id: json['id'],
      name: json['name'],
      itemCode: ItemDTO.fromJson(json['itemCode']),
      kindName: json['kindName'],
      kindCode: json['kindCode'],
      rankName: json['rankName'],
      rankCode: json['rankCode'],
      unit: json['unit'],
      dpr1: json['dpr1'],
      dpr2: json['dpr2'],
      dpr3: json['dpr3'],
      dpr5: json['dpr5'],
      dpr6: json['dpr6'],
      dpr7: json['dpr7'],
      regday: json['regday'],
      value: json['values'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name': name,
    'itemCode' : itemCode.toJson(),
    'kindName' : kindName,
    'kindCode' : kindCode,
    'rankName' : rankName,
    'rankCode' : rankCode,
    'unit' : unit,
    'dpr1' : dpr1,
    'dpr2' : dpr2,
    'dpr3' : dpr3,
    'dpr5' : dpr5,
    'dpr6' : dpr6,
    'dpr7' : dpr7,
    'regday' : regday,
    'values' : value,
    'status' : status,
  };
}