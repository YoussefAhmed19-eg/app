import 'package:dio/dio.dart';
import 'package:movie_app/models/movie_model.dart';

class ApiService {
  final Dio _dio = Dio();

  final String baseUrl = "https://movies-api.accel.li/api/v2/list_movies.json";

  Future<List<MovieModel>> fetchMovies() async {
    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        return moviesJson
                ?.map((movie) => MovieModel.fromJson(movie))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      print("Error fetchMovies: $e");
      return [];
    }
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {"query_term": query},
      );
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        return moviesJson
                ?.map((movie) => MovieModel.fromJson(movie))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      print("Error searchMovies: $e");
      return [];
    }
  }

  Future<List<MovieModel>> fetchMoviesByCategory(String genre) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {"genre": genre},
      );
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        return moviesJson
                ?.map((movie) => MovieModel.fromJson(movie))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      print("Error fetchByCategory: $e");
      return [];
    }
  }

  Future<MovieModel?> fetchMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        "https://movies-api.accel.li/api/v2/movie_details.json",
        queryParameters: {
          "movie_id": movieId,
          "with_cast": true,
          "with_images": true,
        },
      );

      if (response.statusCode == 200) {
        final movieJson = response.data['data']['movie'];
        return MovieModel.fromJson(movieJson);
      }
      return null;
    } catch (e) {
      print("Error fetchDetails: $e");
      return null;
    }
  }

  Future<List<MovieModel>> fetchSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get(
        "https://movies-api.accel.li/api/v2/movie_suggestions.json",
        queryParameters: {"movie_id": movieId},
      );
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        return moviesJson
                ?.map((movie) => MovieModel.fromJson(movie))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      print("Error fetchSimilar: $e");
      return [];
    }
  }
}
