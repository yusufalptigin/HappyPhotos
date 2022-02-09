import 'dart:convert';
import 'dart:typed_data';

class Photos{

  final Uint8List bytes;

  Photos({this.bytes});

  static Map<String, dynamic> toMap(Photos photo) {
    return {
      'bytes': base64Encode(photo.bytes),
    };
  }

  static Photos fromJson(Map<String, dynamic> map) {
    return Photos(
      bytes : base64Decode(map['bytes']),
    );
  }

  static String encodeItems(List<Photos> list){
    return jsonEncode(list.map<Map<String, dynamic>>((item) => Photos.toMap(item)).toList());
  }

  static List<Photos> decodeItems(String list){
    return (jsonDecode(list) as List<dynamic>).map<Photos>((item) => Photos.fromJson(item)).toList();
  }

}

