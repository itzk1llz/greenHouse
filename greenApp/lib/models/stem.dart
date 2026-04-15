import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

class Stem {
  String stem_name;
  String stem_function;
  String stem_id;

  Stem({
    required this.stem_name,
    required this.stem_function,
    required this.stem_id,
  });



  Future<List<Stem>> fetchStem() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8080/getstemlist'));

    var responseData = json.decode(response.body);

    List<Stem> stemlist = [];

    for(var onestem in responseData) {
      Stem stem = Stem (
        stem_name: onestem["Stem_name"],
        stem_function: onestem["Stem_function"],
        stem_id: onestem["Stem_id"],
      );
      stemlist.add(stem);
    }

    return stemlist;
  }
}