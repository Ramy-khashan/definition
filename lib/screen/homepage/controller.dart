import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HomePageController {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "cb6ddd944d2489ac3d6a3ff098b09e939925a296";
  final searchcontroller = TextEditingController();
  StreamController? streamController;
  Stream? stream;
  Timer? timer;
  bool? connected;
  search() async {
    if (searchcontroller.text.isEmpty) {
      streamController!.add(null);
      return;
    }
    streamController!.add("wait");
    var response = await http.get(Uri.parse(url + searchcontroller.text.trim()),
        headers: {"Authorization": "Token " + token});
    streamController!.add(json.decode(response.body));
  }
}
