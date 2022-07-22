import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';
import 'package:movies_app/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = '273e499ef399577fc02abf0bc044ff75';
  final String _languaje = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> movieCast = {};
  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );
  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _languaje, 'page': page.toString()});
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    // var url = Uri.https(_baseUrl, '3/movie/now_playing',
    //     {'api_key': _apiKey, 'language': _languaje, 'page': '1'});
    // final response = await http.get(url);
    // final nowPlayingResponse = NowPlayingResponse.fromJson(response.body);
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    // var url = Uri.https(_baseUrl, '3/movie/popular',
    //     {'api_key': _apiKey, 'language': _languaje, 'page': '1'});
    // final response = await http.get(url);
    // final popularResponse = PopularResponse.fromJson(response.body);
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    movieCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _languaje, 'query': query});
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String query) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionStreamController.add(results);
    };
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = query;
    });
    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
