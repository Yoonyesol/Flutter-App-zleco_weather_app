import 'package:http/http.dart' as http;
import 'dart:convert';

class GeoNetwork {
  final String doroUrl; //geocodingAPI
  GeoNetwork(this.doroUrl);

  //도로명
  Future<dynamic> getDoro() async {
    http.Response response = await http.get(Uri.parse(doroUrl));
    if(response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      return parsingData;
    }
  }
}