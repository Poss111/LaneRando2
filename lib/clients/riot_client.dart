import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:lanerando/models/champions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

String baseUrl = 'https://ddragon.leagueoflegends.com/cdn';
String version = '11.22.1';
String baseUrlWVersion = '$baseUrl/$version';

Future<List<Champion>> fetchChampionNames() async {
  final response = await http.get(
    Uri.parse(
      '$baseUrlWVersion/data/en_US/champion.json'
    )
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    var champions = jsonResponse['data'] as Map<String, dynamic>;

    // Add a space before each uppercase letter that is not at the start of the word
    List<Champion> championList = champions.keys.map((rawName) {
      var parsedName = rawName.replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (match) {
        return ' ${match.group(0)}';
      });
      if (rawName == 'MonkeyKing') {
        parsedName = 'Wukong';
      }
      return Champion(rawName, parsedName);
    }).toList();

    prefs.setString('championNames', jsonEncode(championList));
    
    return championList;
  } else {
    throw Exception('Failed to load champion names');
  }
}

Future<List<Champion>> getChampionNames() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<dynamic>? championNamesDynamic = jsonDecode(prefs.getString('championNames')!);
  List<Champion>? championNames = championNamesDynamic?.map((champion) => Champion.fromJson(champion)).toList();
  
  if (championNames == null) {
    championNames = await fetchChampionNames();
  }

  return championNames;
}

Future<List<Champion>> getRandomUniqueChampionNames(int count) async {
  List<Champion>? championNames = await retrieveFromCache(count);

  championNames!.shuffle();
  return championNames.take(count).toList();
}

Future<List<Champion>?> retrieveFromCache(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString('championNames') ?? "[]";
  List<dynamic>? championNamesDynamic = jsonDecode(value);
  List<Champion>? championNames;
  
  if (championNamesDynamic == null || championNamesDynamic.length < count) {
    championNames = await fetchChampionNames();
  } else {
    championNames = championNamesDynamic?.map((champion) => Champion.fromJson(champion)).toList();
  }
  return championNames;
}

String getChampionImageURL(String rawName) {
  return '$baseUrlWVersion/img/champion/$rawName.png';
}