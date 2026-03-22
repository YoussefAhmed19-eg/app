import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/services/api_services.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    bool isEn = context.locale == const Locale('en');

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isEn ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FutureBuilder<MovieModel?>(
            future: ApiService().fetchMovieDetails(movieId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFFFFBB3B),
                ),
                onPressed: () => toggleWatchlist(snapshot.data!),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<MovieModel?>(
        future: ApiService().fetchMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                "error_loading_details".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      movie.poster,
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFFFFBB3B),
                        size: 80,
                      ),
                      onPressed: () {
                        print("Playing trailer: ${movie.trailerCode}");
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        movie.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.year,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => addToHistory(movie),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                          ),
                          child: Text(
                            "watch".tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoIcon(Icons.favorite, "15"),
                          _buildInfoIcon(
                            Icons.access_time,
                            "${movie.runtime} ${"minutes".tr()}",
                          ),
                          _buildInfoIcon(Icons.star, movie.rating.toString()),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: isEn ? Alignment.centerLeft : Alignment.centerRight,
                        child: Text(
                          "storyline".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFBB3B), size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  void toggleWatchlist(MovieModel movie) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set(movie.toJson());
  }

  void addToHistory(MovieModel movie) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(movie.id.toString())
        .set(movie.toJson());
  }
}
