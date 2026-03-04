import '../models/album.dart';
import '../models/artist.dart';
import '../models/token.dart';
import 'discogs.dart';
import 'token.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class API {
  final apiURL = dotenv.get('API_DOMAIN');

  Future<Map<String, String>> getHeaders() async {
    Token token = await fetchToken();
    return {
      "Authorization": "Bearer ${token.accessToken}",
      "Content-Type": "application/json; charset=UTF-8",
    };
  }

  Future<List<dynamic>> fetchAlbumByArtist(String artist) async {
    List<Album> albums = [];
    try {
      final response = await http
          .post(Uri.https(apiURL, "/album/artist"),
              headers: await getHeaders(),
              body: jsonEncode(<String, String>{"artist": artist}))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.contains("Artist not found")) {
          return [];
        }
        var decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var album in decodedData) {
          albums.add(Album.fromJSON(album));
        }
      } else if (response.statusCode == 401) {
        fetchToken(force: true);
        return fetchAlbumByArtist(artist);
      } else {
        throw Exception('Failed to load album');
      }
      return albums;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Artist>> fetchArtists() async {
    print("fetchArtists");

    List<Artist> artists = [];
    try{
    final response = await http
        .get(
          Uri.https(apiURL, "/artists"),
          headers: await getHeaders(),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401 ||
        utf8.decode(response.bodyBytes).contains("Failed to validate JWT.")) {
      fetchToken(force: true);
      return fetchArtists();
    } else if (response.statusCode == 200) {
      for (var artist in jsonDecode(utf8.decode(response.bodyBytes))) {
        artists.add(Artist(artist));
      }
      return artists;
    } else {
      throw Exception('Failed to load album');
    }
    } catch (e){
      throw e.toString();
    }
  }

  Future<String> handleAlbum(Album album) async {
    final discogs = DiscogsAPI();
    Uri uri = Uri.https(apiURL, "/new/album");

    if (album.id != "") {
      uri = Uri.https(apiURL, "/update/album");
    }

    if (album.discogs.id == 0) {
      album.discogs = await discogs.get(album);
    }

    final response = await http
        .post(uri,
            headers: await getHeaders(), body: jsonEncode(album.toJson()))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["Message"].toString();
    } else if (response.statusCode == 401) {
      fetchToken(force: true);
      return handleAlbum(album);
    } else if (response.statusCode == 502) {
      return "Servidor fora do ar";
    } else {
      return jsonDecode(response.body)["Message"].toString();
    }
  }

  Future<int> deleteAlbum(Album album) async {
    final response = await http
        .post(Uri.https(apiURL, "/delete/album"),
            headers: await getHeaders(),
            body: jsonEncode(<String, dynamic>{
              "id": album.id,
            }))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["Message"];
    } else if (response.statusCode == 401) {
      fetchToken(force: true);
      return deleteAlbum(album);
    } else {
      return jsonDecode(response.body)["Message"];
    }
  }

  Future<Map<String, dynamic>> fetchTotals() async {
    print("fetchTotals");
    
    try {
      final response = await http
          .get(
            Uri.https(apiURL, "/totals"),
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 ||
          utf8.decode(response.bodyBytes).contains("Failed to validate JWT.")) {
        fetchToken(force: true);
        return fetchTotals();
      } else if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load totals');
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
